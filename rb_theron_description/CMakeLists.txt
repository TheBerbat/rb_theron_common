cmake_minimum_required(VERSION 3.5)
project(rb_theron_description)
find_package(ament_cmake REQUIRED)

install(
  DIRECTORY launch meshes robots rviz urdf
  DESTINATION share/${PROJECT_NAME}
)

ament_package()
