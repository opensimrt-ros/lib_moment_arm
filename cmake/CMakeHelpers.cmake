include(CMakeParseArguments)


function(addLibrary)
  # Create module library
  #
  # Parse Arguments
  # ---------------
  # MASK_UNITY_BUILD: define if this library should be build normally
  # UNITY_BUILD_EXCLUDE: Define if UNITY_EXCLUDED_SOURCES is defined.
  # KIT: Name of the library (e.g., Common).
  # LINKLIBS: List of libraries (targets) to link against.
  # INCLUDES: List of header files for the library (obtain via file(GLOB ...)).
  # SOURCES: List of cpp files for the library (obtain via file(GLOB ...)).
  # UNITY_BUILD_EXCLUDED_SOURCES: List of sources to exclude from unity build in
  #   case of conflicts.
  #
  # Example:
  #
  #   addLibrary(
  #       UNITY_EXCLUDE
  #       KIT Common
  #       LINKLIBS ${Simbody_LIBRARIES}
  #       INCLUDES ${INCLUDES}
  #       SOURCES ${SOURCES}
  #       UNITY_EXCLUDED_SOURCES ${EXCLUDED_SOURCES}
  #   )
  # *****************************************************************************

  # Parse arguments.
  # ----------------
  set(options MASK_UNITY_BUILD UNITY_EXCLUDE)
  set(oneValueArgs KIT)
  set(multiValueArgs LINKLIBS INCLUDES SOURCES UNITY_EXCLUDED_SOURCES)
  cmake_parse_arguments(
    ADDLIB "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  # Version stuff.
  # --------------
  set(ADDLIB_LIBRARY_NAME ${ADDLIB_KIT})

  # Unity Build
  if((NOT ADDLIB_MASK_UNITY_BUILD) AND USE_UNITY_BUILD)
    if(ADDLIB_UNITY_EXCLUDE)
      unityBuild(
        EXCLUDE_FROM_SOURCES
        UNIT_SUFFIX ${ADDLIB_LIBRARY_NAME}
        PROJECT_SOURCES ADDLIB_SOURCES
        EXCLUDED_SOURCES ${ADDLIB_UNITY_EXCLUDED_SOURCES}
        )
    else()
      unityBuild(
        UNIT_SUFFIX ${ADDLIB_LIBRARY_NAME}
        PROJECT_SOURCES ADDLIB_SOURCES
        )
    endif()
  endif()

  # Create the library using the provided source and include files.
  add_library(${ADDLIB_LIBRARY_NAME} SHARED
    ${ADDLIB_SOURCES} ${ADDLIB_INCLUDES})

  # This target links to the libraries provided as arguments to this func.
  target_link_libraries(${ADDLIB_LIBRARY_NAME} ${ADDLIB_LINKLIBS})

  set_target_properties(${ADDLIB_LIBRARY_NAME}
    PROPERTIES
    PROJECT_LABEL ${ADDLIB_LIBRARY_NAME}
    FOLDER "Libraries"
    )

  # Install.
  # --------
  # Shared libraries are needed at runtime for applications, so we put them
  # at the top level in bin/*.dll (Windows) or lib/*.so
  # (Linux) or lib/*.dylib (Mac). Windows .lib files, and Linux/Mac
  # .a static archives are only needed at link time so go in sdk/lib.

  install(TARGETS ${ADDLIB_LIBRARY_NAME}
    EXPORT ${TARGET_EXPORT_NAME}
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    )


  # Install headers.
  # ----------------
  set(_INCLUDE_PREFIX "${CMAKE_INSTALL_INCLUDEDIR}")
  set(_INCLUDE_LIBNAME ${ADDLIB_KIT})
  install(FILES ${ADDLIB_INCLUDES}
    DESTINATION ${_INCLUDE_PREFIX}/${_INCLUDE_LIBNAME}
    )

endfunction()



function(unityBuild)
  # Create unity build
  #
  # Parse Arguments
  # ---------------
  # EXCLUDE_FROM_SOURCES: Defined if EXCLUDED_SOURCES are provided.
  # PROJECT_SOURCES: The sources that will be compiled into a single unit.
  #   Should be provided by reference (e.g. SOURCES, not ${SOURCES}).
  # EXCLUDED_SOURCES: List of sources to exclude from unity build in
  #   case of conflicts.
  #
  # Example:
  #       OsimUnityBuild(
  #           EXCLUDE_FROM_SOURCES
  #           PROJECT_SOURCES sources
  #           EXCLUDED_SOURCES ${excluded}
  #       )
  # *****************************************************************************

  # Parse arguments.
  # ----------------
  # http://www.cmake.org/cmake/help/v2.8.9/cmake.html#module:CMakeParseArguments
  set(options EXCLUDE_FROM_SOURCES)
  set(oneValueArgs UNIT_SUFFIX)
  set(multiValueArgs PROJECT_SOURCES EXCLUDED_SOURCES)
  cmake_parse_arguments(
    UNITYBUILD "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  set(files ${${UNITYBUILD_PROJECT_SOURCES}})

  if (UNITYBUILD_EXCLUDE_FROM_SOURCES)
    list(REMOVE_ITEM files ${UNITYBUILD_EXCLUDED_SOURCES})
  endif()

  # Generate a unique filename for the unity build translation unit
  set(unit_build_file ${CMAKE_CURRENT_BINARY_DIR}/${UNITYBUILD_UNIT_SUFFIX}_UnityBuild.cpp)

  # Exclude all translation units from compilation
  set_source_files_properties(${files} PROPERTIES HEADER_FILE_ONLY true)

  # Open the unity build file
  file(WRITE ${unit_build_file} "// Unity Build generated by CMake\n")

  # Add include statement for each translation unit
  foreach(source_file ${files} )
    file( APPEND ${unit_build_file} "#include <${source_file}>\n")
  endforeach(source_file)

  # Complement list of translation units with the name of ub
  set(${UNITYBUILD_PROJECT_SOURCES} ${${UNITYBUILD_PROJECT_SOURCES}} ${unit_build_file} PARENT_SCOPE)

endfunction()


function(addTests)
  # Create test targets for this directory.
  #
  # Parse Arguments
  # ---------------
  # TESTPROGRAMS: Names of test CPP files. One test will be created for each cpp
  #   of these files.
  # LINKLIBS: Arguments to TARGET_LINK_LIBRARIES.
  #
  # Example:
  #   addTests(
  #       TESTPROGRAMS ${TEST_PROGRAMS}
  #       LINKLIBS osimCommon osimSimulation osimAnalyses
  #   )
  # *****************************************************************************

  if(BUILD_TESTING)

    # Parse arguments.
    # ----------------
    set(options)
    set(oneValueArgs)
    set(multiValueArgs TESTPROGRAMS LINKLIBS)
    cmake_parse_arguments(
      ADDTESTS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # TODO
    # # If EXECUTABLE_OUTPUT_PATH is set, then that's where the tests will be
    # # located. Otherwise, they are located in the current binary directory.
    # if(EXECUTABLE_OUTPUT_PATH)
    #     set(TEST_PATH "${EXECUTABLE_OUTPUT_PATH}")
    # else()
    #     set(TEST_PATH "${CMAKE_CURRENT_BINARY_DIR}")
    # endif()

    enable_testing()

    # Make test targets.
    foreach(test_program ${ADDTESTS_TESTPROGRAMS})
      # NAME_WE stands for "name without extension"
      get_filename_component(TEST_NAME ${test_program} NAME_WE)

      add_executable(${TEST_NAME} ${test_program})
      target_link_libraries(${TEST_NAME} ${ADDTESTS_LINKLIBS})
      add_test(NAME ${TEST_NAME} COMMAND ${TEST_NAME})
      set_target_properties(${TEST_NAME}
        PROPERTIES
        PROJECT_LABEL "Test - ${TEST_NAME}"
        FOLDER "Tests"
        )
    endforeach()
  endif()
endfunction()



function(addApplications)
  # Create an application/executable. To be used in the Appliations directory.
  #
  # Parse Arguments
  # ---------------
  # SOURCES: Source files for the executables
  # LINKLIBS: List of libraries to link.
  #
  # Example:
  #   addApplication(
  #       SOURCES ${application_program}
  #       LINKLIBS ${target} ${DEPENDENCY_LIBRARIES}
  #   )
  # *****************************************************************************

  # Parse arguments.
  # ----------------
  set(options)
  set(oneValueArgs)
  set(multiValueArgs SOURCES LINKLIBS)
  cmake_parse_arguments(
    ADDAPPLICATION "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  foreach(application_program ${ADDAPPLICATION_SOURCES})
    # NAME_WE stands for "name without extension"
    get_filename_component(APPLICATION_NAME ${application_program} NAME_WE)

    add_executable(${APPLICATION_NAME} ${application_program})
    target_link_libraries(${APPLICATION_NAME} ${ADDAPPLICATION_LINKLIBS})
    install(
      TARGETS ${APPLICATION_NAME}
      DESTINATION "${CMAKE_INSTALL_BINDIR}"
      )

    set_target_properties(${APPLICATION_NAME}
      PROPERTIES
      FOLDER "Applications"
      PROJECT_LABEL "Application - ${APPLICATION_NAME}"
      )
  endforeach()
endfunction()
