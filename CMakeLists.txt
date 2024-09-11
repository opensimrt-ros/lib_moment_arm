cmake_minimum_required(VERSION 3.15)
project(lib_moment_arm)
set( CMAKE_EXPORT_COMPILE_COMMANDS ON )

## Compile as C++11, supported in ROS Kinetic and newer
add_compile_options(-std=c++11 -O3)

#include(cmake/CMakeHelpers.cmake)

## Find catkin macros and libraries
## if COMPONENTS list like find_package(catkin REQUIRED COMPONENTS xyz)
## is used, also find other catkin packages
find_package(OpenSim REQUIRED)
find_package(casadi REQUIRED)
#find_package(coin-or REQUIRED)
#find_package(simbody REQUIRED PATHS /usr/local/include/simbody)
find_package(catkin REQUIRED COMPONENTS
  roscpp
)

## System dependencies are found with CMake's conventions

#find_package(OpenSim REQUIRED
#		simbody
#	)

message(NOTICE "============\nLIBMOMENTARM:OpenSim")
message(STATUS
	${OpenSim_INCLUDE_DIRS}

	)

catkin_package(INCLUDE_DIRS 
   include
#  LIBRARIES lib_moment_arm
  CATKIN_DEPENDS roscpp
  DEPENDS OpenSim
)

## I wonder if catkin does this for me.
include_directories(${OpenSim_INCLUDE_DIRS}
	${catkin_INCLUDE_DIRS}
	#${simbody_INCLUDE_DIRS}
	/opt/dependencies/
	)

link_directories(${OpenSim_LIB_DIR} ${catkin_LIBRARIES} )

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

set(models_dir "/srv/host_data/models")
#set(subject_list "02" "03" "04" )

file(GLOB models CONFIGURE_DEPENDS "${models_dir}/*.osim")



foreach(m ${models})
	message("\n---------------------------------------------------- ${m}----------------------------------------------------------------- \n")
endforeach()

foreach(model ${models})
	message(parsing ${model})
	get_filename_component(base ${model} NAME_WE)
	set (file "${CMAKE_CURRENT_SOURCE_DIR}/src/${base}MomentArm_generated.cpp"
)
	message(cpp file will be writen to ${file})
	add_custom_command(
	    OUTPUT 	${file}    
	    COMMAND python3 symbolic_moment_arm_v40.py 
	    --model=${model} 
	    --results_destination=${CATKIN_DEVEL_PREFIX}/share/${PROJECT_NAME}
	    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
	    VERBATIM
	)
	add_library(libMomentArm_${base} ${file})

	
	include_directories(include
		${catkin_INCLUDE_DIRS}
		${OpenSim_INCLUDE_DIRS}
		/usr/local/include/simbody #I totally shouldnt have to do this... well, if you fix it you will feel like a better programmer than me, so you have that going for you, which is nice
		)
	#add_dependencies(libMomentArm_${base} ${OpenSim_LIBRARIES})
	set_target_properties( libMomentArm_${base} 
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
