# Fonction pour ajouter facilement des tests unitaires avec catch2
# 
# Exemple d'utilisation :
#
#		addtest( LIB mappingCompoToolsLib
#				 SRC ${unittest_source_files} )
#
#


# set catch2 include dir
set(CATCH2_INCLUDE ${CMAKE_CURRENT_LIST_DIR}/catch2)

include_directories(${CATCH2_INCLUDE})
	
include(CTest)

add_custom_target(BUILD_TESTS)


function(addtest)

	set(oneValueArgs LIB SRC)
    set(multiValueArgs DEP)
	cmake_parse_arguments(
        PARSED_ARGS # prefix of output variables
		""
        "${oneValueArgs}"
        "${multiValueArgs}" 
		${ARGN} 
    )
	
	if(NOT TEST_OUTPUT_DIRECTORY)
		message(FATAL_ERROR "ERROR : Mapping Unit Tests, Variable TEST_OUTPUT_DIRECTORY not set.")
	endif()
	
	if(NOT PARSED_ARGS_LIB)
        message(FATAL_ERROR "You must provide a lib")
    endif(NOT PARSED_ARGS_LIB)
	set(lib ${PARSED_ARGS_LIB})
	
	if(NOT PARSED_ARGS_SRC)
        message(FATAL_ERROR "You must provide sources for the test")
    endif(NOT PARSED_ARGS_SRC)
	set(src ${PARSED_ARGS_SRC})
	
	foreach(deplib ${PARSED_ARGS_DEP})
		list(APPEND dep_libs ${deplib})
    endforeach(deplib)

	set(name "UT_${lib}")


	add_executable(${name} ${src})
	
	target_link_libraries(${name} PUBLIC ${lib} ${dep_libs})
	
	set_target_properties(${name}
	   PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${TEST_OUTPUT_DIRECTORY}
    )
						
	add_test(
			NAME ${name} 
			COMMAND $<TARGET_FILE:${name}> "--success"
			)
			
	add_dependencies(BUILD_TESTS ${name})
	
	
	
endfunction()
