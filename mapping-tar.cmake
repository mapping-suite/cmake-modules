
function(tarfile)

	set(oneValueArgs FILE DEST)
	cmake_parse_arguments(
        PARSED_ARGS # prefix of output variables
		""
        "${oneValueArgs}"
        "" 
		${ARGN} 
    )
	
	if(NOT PARSED_ARGS_FILE)
        message(FATAL_ERROR "You must provide a file")
    endif()
	set(file ${PARSED_ARGS_FILE})
	
	if(NOT PARSED_ARGS_DEST)
        message(FATAL_ERROR "You must provide a destination tar.gz")
    endif()
	set(dest ${PARSED_ARGS_DEST})
	
	get_filename_component(dir ${file} DIRECTORY)
	get_filename_component(fullfilename ${file} NAME)
	
	execute_process(COMMAND tar -czf ${dest} --directory=${dir} ${fullfilename})

endfunction()



function(tarfolder)

	set(oneValueArgs FOLDER DEST)
	cmake_parse_arguments(
        PARSED_ARGS # prefix of output variables
		""
        "${oneValueArgs}"
        "" 
		${ARGN} 
    )
	
	if(NOT PARSED_ARGS_FOLDER)
        message(FATAL_ERROR "You must provide a folder")
    endif()
	set(folder ${PARSED_ARGS_FOLDER})
	
	if(NOT PARSED_ARGS_DEST)
        message(FATAL_ERROR "You must provide a destination tar.gz")
    endif()
	set(dest ${PARSED_ARGS_DEST})
	
	file(GLOB files ${folder}/*)
	
	# get all file name in a list (without full path)
	foreach(file ${files})		
		get_filename_component(filename ${file} NAME)
		list(APPEND files_name ${filename})
	endforeach()
	
	# tar all files
	execute_process(COMMAND tar -czf ${dest} -C ${folder} ${files_name})

endfunction()
