function(generate_def_file)
  cmake_parse_arguments(ARG "" "TARGET" "CONTENT" ${ARGN})

  if (NOT LLVM_NM)
    find_program(LLVM_NM llvm-nm)
    if (NOT LLVM_NM)
      message(FATAL_ERROR "You need llvm-nm to be able to generate the def file")
    endif()
  endif()

  file(GENERATE OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${ARG_TARGET}.semicolon CONTENT "${ARG_CONTENT}")

  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/msvc_generate_def.cmake "
    file(REMOVE ${CMAKE_CURRENT_BINARY_DIR}/${ARG_TARGET}.def)
    file(READ \"${CMAKE_CURRENT_BINARY_DIR}/${ARG_TARGET}.semicolon\" input_content)

    foreach(f \${input_content})
      file(TO_NATIVE_PATH \"\${f}\" native_f)
      string(APPEND resp_input \"\${native_f} \")
    endforeach()
    file(WRITE \"${CMAKE_CURRENT_BINARY_DIR}/${ARG_TARGET}.resp\" \"-g \${resp_input}\")

    execute_process(COMMAND ${LLVM_NM} \"@${CMAKE_CURRENT_BINARY_DIR}/${ARG_TARGET}.resp\" OUTPUT_FILE \"${CMAKE_CURRENT_BINARY_DIR}/${ARG_TARGET}.def.all\")
    file(STRINGS \"${CMAKE_CURRENT_BINARY_DIR}/${ARG_TARGET}.def.all\" def_all REGEX \"^[0-9a-f]+ [TDBR] .*$\")

    list(FILTER def_all EXCLUDE REGEX \"^.*\\\\?\\\\?\\\\$_.*$\")
    list(FILTER def_all EXCLUDE REGEX \"^.*\\\\?\\\\?_[CEGR].*$\")
    list(FILTER def_all EXCLUDE REGEX \"^.*\\\\?\\\\?1\\\\?.*$\") # destructor
    list(FILTER def_all EXCLUDE REGEX \"^.*\\\\?A0x[0-9a-f]+@.*$\") # anonymous namespace
    list(REMOVE_DUPLICATES def_all)
    string(REGEX REPLACE \"[0-9a-f]+ [TDBR] \" \" \" def_all \"\${def_all}\")
    string(REPLACE \";\" \"\\n\" def_all \"\${def_all}\")
    file(WRITE \"${CMAKE_CURRENT_BINARY_DIR}/${ARG_TARGET}.def\" \"EXPORTS\n\")
    file(APPEND \"${CMAKE_CURRENT_BINARY_DIR}/${ARG_TARGET}.def\" \${def_all})
    ")

  add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${ARG_TARGET}.def
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${ARG_TARGET}.semicolon ${ARG_CONTENT}
    COMMAND "${CMAKE_COMMAND}" -P "${CMAKE_CURRENT_BINARY_DIR}/msvc_generate_def.cmake")
endfunction()
