
# Function to compile individual package and generate deb. Previously need compile dependecies
# and installed or compile with colcon build and source the install folder generated.
compile_package() {
  current_ws="$(pwd)"
  pkg_dir="$(dirname $1)"
  echo "Creating deb package from: $pkg_dir"
  cd $pkg_dir

  # Generate debian folder
  bloom-generate rosdebian

  # Avoid dependency error if not found (used for robotnik_motordrive_lib)
  sed -i 's#dh_shlibdeps -l$(CURDIR)/debian.*#& --dpkg-shlibdeps-params=--ignore-missing-info#' debian/rules

  # Compile and generate deb package
  ./debian/rules binary

  cd $current_ws
}

# Source ROS2 Installation
source /opt/ros/foxy/setup.bash

# Compile all packages in order to get cmake configs for individual deb package creation
cd /colcon_ws
colcon build
source ./install/local_setup.bash

# Compile each package and generate deb package
export -f compile_package
find ./src/ -type f -name package.xml -exec  bash -c 'compile_package "$0"' {} \;

# Copy all deb package in debs folder
mkdir /debs/
mv $(find ./src/ -name '*.deb') /debs/