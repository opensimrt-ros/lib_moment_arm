cmake_minimum_required(VERSION 3.16)
project(lib_moment_arm)
set( CMAKE_EXPORT_COMPILE_COMMANDS ON )

## Compile as C++11, supported in ROS Kinetic and newer
add_compile_options(-std=c++11 -O3)

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
include(cmake/CMakeHelpers.cmake)

## Find catkin macros and libraries
## if COMPONENTS list like find_package(catkin REQUIRED COMPONENTS xyz)
## is used, also find other catkin packages
find_package(catkin REQUIRED COMPONENTS
  roscpp
)

## System dependencies are found with CMake's conventions
find_package(OpenSim) 
find_package(simbody)
## I wonder if catkin does this for me.
include_directories(${OpenSim_INCLUDE_DIRS})
link_directories(${OpenSim_LIB_DIR})

set(CMAKE_RELEASE_POSTFIX "" CACHE STRING "Release postfix")
set(CMAKE_DEBUG_POSTFIX "" CACHE STRING "Debug postfix")
set(CMAKE_RELWITHDEBINFO_POSTFIX "" CACHE STRING "Release with debug info postfix")
set(CMAKE_MINSIZEREL_POSTFIX "" CACHE STRING "Minimum size release postfix")
mark_as_advanced(CMAKE_RELEASE_POSTFIX)
mark_as_advanced(CMAKE_DEBUG_POSTFIX)
mark_as_advanced(CMAKE_RELWITHDEBINFO_POSTFIX)
mark_as_advanced(CMAKE_MINSIZEREL_POSTFIX)


###################################
## catkin specific configuration ##
###################################
## The catkin_package macro generates cmake config files for your package
## Declare things to be passed to dependent projects
## INCLUDE_DIRS: uncomment this if your package contains header files
## LIBRARIES: libraries you create in this project that dependent projects also need
## CATKIN_DEPENDS: catkin_packages dependent projects also need
## DEPENDS: system dependencies of this project that dependent projects also need
catkin_package(
#  INCLUDE_DIRS include
#  LIBRARIES lib_moment_arm
#  CATKIN_DEPENDS Opensim roscpp
#  DEPENDS system_lib
)

###########
## Build ##
###########

## Specify additional locations of header files
## Your package locations should be listed before other locations
include_directories(
  include
  ${catkin_INCLUDE_DIRS}
)

## Declare a C++ library
# add_library(${PROJECT_NAME}
#   src/${PROJECT_NAME}/lib_moment_arm.cpp
# )

## Add cmake target dependencies of the library
## as an example, code may need to be generated before libraries
## either from message generation or dynamic reconfigure
# add_dependencies(${PROJECT_NAME} ${${PROJECT_NAME}_EXPORTED_TARGETS} ${catkin_EXPORTED_TARGETS})

## Declare a C++ executable
## With catkin_make all packages are built within a single CMake context
## The recommended prefix ensures that target names across packages don't collide
# add_executable(${PROJECT_NAME}_node src/lib_moment_arm_node.cpp)

## Rename C++ executable without prefix
## The above recommended prefix causes long target names, the following renames the
## target back to the shorter version for ease of user use
## e.g. "rosrun someones_pkg node" instead of "rosrun someones_pkg someones_pkg_node"
# set_target_properties(${PROJECT_NAME}_node PROPERTIES OUTPUT_NAME node PREFIX "")

## Add cmake target dependencies of the executable
## same as for the library above
# add_dependencies(${PROJECT_NAME}_node ${${PROJECT_NAME}_EXPORTED_TARGETS} ${catkin_EXPORTED_TARGETS})

## Specify libraries to link a library or executable target against
# target_link_libraries(${PROJECT_NAME}_node
#   ${catkin_LIBRARIES}
# )

set(subject_list "03")
#set(subject_list "02" "03" "04" )

set(model gait2392)

foreach(subject IN LISTS subject_list)
	message(parsing ${subject})
	set (file "generated_src/${model}MomentArm_${subject}.cpp"
)
	add_custom_command(
	    OUTPUT 	${file}    
	    COMMAND python3 symbolic_moment_arm_v40.py ${subject} ${model} ${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_LIB_DESTINATION}
	    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
	    VERBATIM
	)
	add_library(${model}MomentArmLib_${subject} ${file})

	
	include_directories(include)
	add_dependencies(${model}MomentArmLib_${subject} ${OpenSim_LIBRARIES})
	set_target_properties( ${model}MomentArmLib_${subject} 
		PROPERTIES LINKER_LANGUAGE CXX PREFIX "")
	#add_dependencies(${target} generate_${subject}cpp)

	#############
	## Testing ##
	#############

	## Add gtest based cpp test target and link libraries
	# catkin_add_gtest(${PROJECT_NAME}-test test/test_lib_moment_arm.cpp)
	# if(TARGET ${PROJECT_NAME}-test)
	#   target_link_libraries(${PROJECT_NAME}-test ${PROJECT_NAME})
	# endif()

	## Add folders to be run by python nosetests
	# catkin_add_nosetests(test)

	#addTests(
	#  TESTPROGRAMS ${tests_${subject}}
	#  LINKLIBS ${target} ${OpenSim_LIBRARIES})
endforeach()
