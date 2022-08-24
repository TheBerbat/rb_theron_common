### PKG-BUILDER
# -> for download, compile and compress output files that will be installed in post-images
#
FROM ros:foxy-ros-core-focal as package-builder

# Install colcon and generate debs dependencies
RUN apt-get update \
  && apt-get install -q -y \
  --no-install-recommends \
	python3-colcon-common-extensions \
	python3-bloom \
	python3-rosdep \
	fakeroot \
	dh-make \
	g++ \
  && apt-get clean -q -y \
  && apt-get autoremove -q -y \
  && rm -rf /var/lib/apt/lists/*

# Copy src package of build
COPY ./rb_theron_description /colcon_ws/src/rb_theron_description

RUN true \
  && cd /colcon_ws/ \
  && rosdep init \
  && apt-get update \
  && rosdep update \
  && rosdep install --from-paths src --ignore-src -r -y \
  && apt-get clean -q -y \
  && apt-get autoremove -q -y \
  && rm -rf /var/lib/apt/lists/* \
  && true

  # Rosdep file to include dependencies
COPY ./scripts/rosdep.yaml /colcon_ws/rosdep.yaml
RUN true \ 
  && echo "yaml file:///colcon_ws/rosdep.yaml" > /etc/ros/rosdep/sources.list.d/50-my-packages.list \
  && rosdep update

# Build script for each package
COPY ./scripts/build_deb_packages.sh /colcon_ws/build_deb_packages.sh
RUN /bin/bash -c "/colcon_ws/build_deb_packages.sh"

# ^
### PKG-BUILDER

FROM ros:foxy-ros-core-focal as base

COPY --from=package-builder ./debs/ /debs/
RUN apt-get update \
  && apt-get install -q -y \
  --no-install-recommends \
	/debs/*.deb \
  && apt-get clean -q -y \
  && apt-get autoremove -q -y \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /debs


RUN apt-get update \
  && apt-get install -q -y \
  --no-install-recommends \
	  ros-foxy-rmw-cyclonedds-cpp \
  && apt-get clean -q -y \
  && apt-get autoremove -q -y \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /debs

ENV RMW_IMPLEMENTATION rmw_cyclonedds_cpp
ENV RCUTILS_COLORIZED_OUTPUT 1

COPY ./scripts/startup.sh /startup.sh
RUN sed -i 's#exec#. /startup.sh \nexec#' /ros_entrypoint.sh

# Configure start-up script
SHELL [ "/bin/bash", "-c" ]
CMD ros2 launch rb_theron_description default.launch.py
