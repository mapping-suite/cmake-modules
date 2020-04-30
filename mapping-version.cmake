
function(version fileversion constant)

file(STRINGS "${MAPPING_VERSION_FULL_PATH}" version)

message(STATUS "Create ${fileversion} with version ${version}")	

set(CONTENT "#define ${constant} \"${version}\"")

file(WRITE ${fileversion} ${CONTENT})

endfunction()