set (MAPPING_LIBS_BASE_URL "http://${ARTIFACTORY_USER}:${ARTIFACTORY_PASSWORD}@${ARTIFACTORY_IP}/artifactory/Onyx/Libs")


# Get OS name (+ Visual Studio version)
if (CMAKE_HOST_WIN32)
	if(${MSVC_TOOLSET_VERSION} STREQUAL  "143")
		set (VS "vs2022")
	elseif(${MSVC_TOOLSET_VERSION} STREQUAL  "141")
		set (VS "vs2017")
	elseif(${MSVC_TOOLSET_VERSION} STREQUAL  "140")
		set (VS "vs2015")
	elseif(${MSVC_TOOLSET_VERSION} STREQUAL  "120")
		set (VS "vs2013")
	endif()
	set (OSNAME "win64-${VS}")
	set (LIBS_FOLDER "Win_x64")
else()
	execute_process(COMMAND cat /etc/os-release COMMAND grep "VERSION_ID" COMMAND cut -d \" -f2 OUTPUT_VARIABLE OSNAME)
	string(STRIP el${OSNAME} OSNAME)
	string(TOUPPER RH${OSNAME} LIBS_FOLDER)
	set(LIBS_FOLDER ${LIBS_FOLDER}_x64)
endif()


# Create folder
set(PATH_DEPENDENCIES ${CMAKE_CURRENT_SOURCE_DIR}/dependencies)

file(MAKE_DIRECTORY ${PATH_DEPENDENCIES})
file(MAKE_DIRECTORY download)


# Function getDependencies
function(getDependencies dependencies_file)

	FILE(STRINGS ${CMAKE_CURRENT_SOURCE_DIR}/${dependencies_file} libs)

	message(STATUS "Start check dependencies for ${dependencies_file} ...")	

	foreach(lib IN LISTS libs)
		
		STRING(REGEX REPLACE ":" ";" libinfos "${lib}")
		list(GET libinfos 0 libname)
		list(GET libinfos 1 libversion)

		message(STATUS "Lib Name = ${libname}")
		message(STATUS "Lib Version = ${libversion}")

		if(NOT EXISTS "${PATH_DEPENDENCIES}/${libname}/include")
			set(LIBURL ${MAPPING_LIBS_BASE_URL}/${LIBS_FOLDER}/${libname}-${OSNAME}-${libversion}.tar.gz)
			message(STATUS "Download Lib ${libname} from ${LIBURL} ...")
			file(DOWNLOAD ${LIBURL} download/${libname}-${OSNAME}-${libversion}.tar.gz STATUS http_messages)
			list(GET http_messages 0 http_code)
			
			if(NOT ${http_code})
				message(STATUS "Install Lib ${libname} ...")
				execute_process(COMMAND tar xzf download/${libname}-${OSNAME}-${libversion}.tar.gz -C ${PATH_DEPENDENCIES})
				
				if(EXISTS "${PATH_DEPENDENCIES}/${libname}")
					message(STATUS "Lib ${libname} installed.")
				else()
					message(SEND_ERROR "Error : Lib ${libname} not installed." )
				endif()
			else()
				list(GET http_messages 1 http_txt)
				message(STATUS "HTTP Error, return code = ${http_code}, message : '${http_txt}' " )
				message(SEND_ERROR "Error : Lib ${libname} version ${libversion} not found." )
			endif()
			
		else()
			message(STATUS "Lib ${libname} already installed.")
		endif()
		
		string(TOUPPER ${libname} CURLIBS_FOLDER)
		
		if(NOT DEFINED ${CURLIBS_FOLDER}_INCLUDES)
			set (${CURLIBS_FOLDER}_INCLUDES ${PATH_DEPENDENCIES}/${libname}/include PARENT_SCOPE)
		endif()
			
		if(NOT DEFINED ${CURLIBS_FOLDER}_LIBS)
			set (${CURLIBS_FOLDER}_LIBS ${PATH_DEPENDENCIES}/${libname}/lib PARENT_SCOPE)
		endif()


	endforeach()

	message(STATUS "End check dependencies for ${dependencies_file}.")

endfunction()
