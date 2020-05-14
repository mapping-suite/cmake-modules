# Fonction pour fusionner plusieur libs static en une seule lib
# Basé sur l'exemple fourni ici : https://cristianadam.eu/20190501/bundling-together-static-libraries-with-cmake/
# 
# Exemple d'utilisation :
#
#		bundle_static_library(NAME mappingCompoLib
#					  		  LIBS mappingCompoArgLib mappingCompoDataLib mappingCompoFontLib
#					       		   mappingCompoExtOptLib mappingCompoFormatLegacyLib mappingCompoFormatLib
#						           mappingCompoImageLib mappingCompoMemoryLib mappingCompoProcessDataLib
#						           mappingCompoProcessPrintingJSONLib mappingCompoProcessPrintingLegacyXPSLib
#						           mappingCompoToolsLib
#					 		)
#
#


function(bundle_static_library)

	cmake_parse_arguments(
        PARSED_ARGS # prefix of output variables
        "" # list of names of the boolean arguments (only defined ones will be true)
        "NAME" # NAME of the output lib
        "LIBS" # libs to merge
        ${ARGN} # arguments of the function to parse, here we take the all original ones
    )
	
	if(NOT PARSED_ARGS_NAME)
        message(FATAL_ERROR "You must provide a name")
    endif(NOT PARSED_ARGS_NAME)
	set(bundled_tgt_name ${PARSED_ARGS_NAME})
		
    foreach(lib ${PARSED_ARGS_LIBS})
		list(APPEND static_libs ${lib})
    endforeach(lib)

  list(REMOVE_DUPLICATES static_libs)
  
  file( TOUCH ${CMAKE_CURRENT_SOURCE_DIR}/dummy.cpp)
  add_library(${bundled_tgt_name} STATIC ${CMAKE_CURRENT_SOURCE_DIR}/dummy.cpp)
  add_dependencies(${bundled_tgt_name} ${static_libs})

  if (CMAKE_CXX_COMPILER_ID MATCHES "^(Clang|GNU)$")
  
	set(debug_suffix "")
	if(${CMAKE_BUILD_TYPE} STREQUAL  "Debug")
		set(debug_suffix "d")
	endif()
	
	set(bundled_tgt_full_name 
    ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}/${CMAKE_STATIC_LIBRARY_PREFIX}${bundled_tgt_name}${debug_suffix}${CMAKE_STATIC_LIBRARY_SUFFIX})
	
    file(WRITE ${CMAKE_BINARY_DIR}/${bundled_tgt_name}.ar.in
      "CREATE ${bundled_tgt_full_name}\n" )
        
    foreach(tgt IN LISTS static_libs)
      file(APPEND ${CMAKE_BINARY_DIR}/${bundled_tgt_name}.ar.in
        "ADDLIB $<TARGET_FILE:${tgt}>\n")
    endforeach()
    
    file(APPEND ${CMAKE_BINARY_DIR}/${bundled_tgt_name}.ar.in "SAVE\n")
    file(APPEND ${CMAKE_BINARY_DIR}/${bundled_tgt_name}.ar.in "END\n")

    file(GENERATE
      OUTPUT ${CMAKE_BINARY_DIR}/${bundled_tgt_name}.ar
      INPUT ${CMAKE_BINARY_DIR}/${bundled_tgt_name}.ar.in)

    set(ar_tool ${CMAKE_AR})
    if (CMAKE_INTERPROCEDURAL_OPTIMIZATION)
      set(ar_tool ${CMAKE_CXX_COMPILER_AR})
    endif()

    add_custom_command(
	  TARGET ${bundled_tgt_name}
      COMMAND ${ar_tool} -M < ${CMAKE_BINARY_DIR}/${bundled_tgt_name}.ar
      COMMENT "Bundling ${bundled_tgt_name}"
      VERBATIM)
  elseif(MSVC)
  
	message("BUNDLE MSVC" )
	string(REPLACE "link.exe"
       "lib.exe" lib_tool ${CMAKE_LINKER}  )
 
    foreach(tgt IN LISTS static_libs)
      list(APPEND static_libs_full_names $<TARGET_FILE:${tgt}>)
    endforeach()

    add_custom_command(
	  TARGET ${bundled_tgt_name}
      COMMAND ${lib_tool} /NOLOGO /OUT:${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}/$<CONFIG>/${CMAKE_STATIC_LIBRARY_PREFIX}${bundled_tgt_name}$<$<CONFIG:Debug>:d>${CMAKE_STATIC_LIBRARY_SUFFIX} ${static_libs_full_names}
      COMMENT "Bundling ${bundled_tgt_name}"
      VERBATIM)
  else()
    message(FATAL_ERROR "Unknown bundle scenario!")
  endif()

endfunction()