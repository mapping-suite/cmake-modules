
function(version fileversion constant)

file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/version.txt" version)

message(STATUS "Create ${fileversion} with version ${version}")	

set(CONTENT "#define ${constant} \"${version}\"")

file(WRITE ${fileversion} ${CONTENT})

endfunction()