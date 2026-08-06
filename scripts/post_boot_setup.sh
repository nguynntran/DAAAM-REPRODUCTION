#!/bin/bash
set -e
# ROS 2 apt repo + packages
sudo apt update
sudo apt install -y curl
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
sudo apt update
sudo apt install -y ros-jazzy-ros-base python3-rosdep
sudo rosdep init || true
rosdep update

# Conda shell init
echo 'source /workspace/miniconda3/etc/profile.d/conda.sh' >> ~/.bashrc

# Git identity + credential caching
git config --global user.email 150054667+nguynntran@users.noreply.github.com
git config --global user.name "nguynntran"
git config --global credential.helper store
