#!/bin/bash
# Copyright (C) 2018 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Presubmit Checks Build Script.
set -ex

BUILD_ROOT=$PWD
SRC=$PWD/github/agi/
CURL="curl -fksLS --http1.1 --retry 3"

# Get bazel.
BAZEL_VERSION=6.5.0
$CURL -O https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh
echo "c0161a346b9c0d00e6eb3d3e8f9c4dece32f6292520248c5ab2e3527265601c1  bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh" | sha256sum --check
mkdir bazel
bash bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh --prefix=$PWD/bazel

# Get bazel build tools.
mkdir tools
export GOPATH=$PWD/tools
go install github.com/bazelbuild/buildtools/buildifier@latest
go install github.com/bazelbuild/buildtools/buildozer@latest

# Get clang-format.
$CURL -O https://apt.llvm.org/llvm-snapshot.gpg.key
echo "ce6eee4130298f79b0e0f09a89f93c1bc711cd68e7e3182d37c8e96c5227e2f0  llvm-snapshot.gpg.key" | sha256sum --check
sudo apt-key add llvm-snapshot.gpg.key
sudo add-apt-repository 'deb http://apt.llvm.org/focal/ llvm-toolchain-focal-16 main'
sudo apt-get -y update
sudo apt-get install -y clang-format-16

# Get recent Android build tools.
echo y | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --install 'build-tools;30.0.3' 'platforms;android-34'

# Python Format tool
pip install --root-user-action=ignore --user autopep8==1.6.0

# Setup environment.
export ANDROID_NDK_HOME=/opt/android-ndk-r16b
export BAZEL=$BUILD_ROOT/bazel/bin/bazel
export BUILDIFIER=$BUILD_ROOT/tools/bin/buildifier
export BUILDOZER=$BUILD_ROOT/tools/bin/buildozer
export CLANG_FORMAT=clang-format-16
export AUTOPEP8=~/.local/bin/autopep8

cd $SRC

. ./kokoro/presubmit/presubmit.sh
