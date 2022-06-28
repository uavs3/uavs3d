# uavs3d
 uavs3d is an opensource and cross-platform avs3 decoder, supports AVS3-P2 baseline profile. <br>
 features:
 1) AVS3-P2 baseline profile.
 2) supports to compile for Android/IOS/Windows/Linux/MacOS systems.
 3) optimized for ARMv7/ARMv8/SSE4/AVX2 chips.
 4) 10bit decoding on all supported platforms.
 5) The uavs3 codec has supported x86 and arm platforms, and has been tested and verified on the Kunpeng processor. 
 6) The ARM platform recommends the Kunpeng processor.
# license
  Copyright reserved by “Peking University Shenzhen Graduate School”, “Peng Cheng Laboratory”, and “Guangdong Bohua UHD Innovation Corporation” <br><br>
  This program is a free software. You can redistribute it and/or modify it under the terms of the BSD 3-clause license. <br>
  For more details, please view the file "COPYING" in the project.
  
# compile
  The default configuration only support 8bit decoding. <br>
  To support 10bit streams decoding: cmake -DCOMPILE_10BIT=1

## windows
Prerequisites:
  Visual Studio 2017

build:
  1. ./version.bat (to generate version.h)
  2. solution file: build/x86_windows/uavs3d.sln 
  
  To support 10bit streams decoding, edit source/decore/com_def.h : #define COMPILE_10BIT 1

## linux/mac
Prerequisites:
  1. gawk (http://www.gnu.org/software/gawk/)
  2. CMake (https://cmake.org) version 3.1 or higher
  
Build:
  1. mkdir build/linux
  2. cd build/linux && cmake -DCOMPILE_10BIT=0 ../..
  3. make && make install

  To support 10bit streams decoding: cmake -DCOMPILE_10BIT=1
  to build shared library, set BUILD_SHARED_LIBS=1 please.

## ios
Prerequisites:
  XCode

Build:
1. ./version.sh (generate the version.h) 
2. xcode solution file: build/ios/uavs3d.xcodeproj

## android
Prerequisites:
  Android NDK (https://developer.android.google.cn/ndk/downloads/).

Build ndk library or executable file: 
  1. ./version.sh (generate the version.h)
  2. cd build/android/ndk/jni
  3. $NDK_PATH/ndk-build  

# Run tests
## window/linux/mac/android
sample: ./uavs3d -i input.avs3 -o output.yuv -t 8 -l 2 -s 1

Arguments: <br>

| short name | long name | introduction |
|:-----------:|----------|-------------|
| -h | --help     | Print this help     |
| -v | --version  | Version information |
| -i | --input    | Input file          |
| -o | --output   | Output file         |
| -l | --loglevel | Log level: <br> 0: no message; 1: seq level; 2: frame level (default) |
| -t | --threads  | Number of frame-level threads |
| -f | --frames   | Total frames to decode        |
| -s | --check_md5| Enable to check md5 or not    |

## ios
  Edit build/ios/uavs3d/main.m to configure decoding options.

# Contributors
This program is originally developed by the team of Prof.Ronggang Wang (rgwang@pkusz.edu.cn) at Peking University Shenzhen Graduate School. <br>

* Main contributors:  
  * Zhenyu Wang (wangzhenyu@pkusz.edu.cn), Peking University Shenzhen Graduate School. 
  * Bingjie Han (hanbj@pkusz.edu.cn), Peking University Shenzhen Graduate School. 
  * Jiang Du, Peking University Shenzhen Graduate School. 
  * Kui Fan, Peking University Shenzhen Graduate School. 
  * Xi Xie, Peking University Shenzhen Graduate School. 
  * Guisen Xu, Peking University Shenzhen Graduate School. 
  * Xufeng Li, Peking University Shenzhen Graduate School. 
  * Yangang Cai, Peking University Shenzhen Graduate School. 
  * Hao Lv, Peng Cheng Laboratory. 
  * Min Chen.
  
  ** Ronggang Wang (rgwang@pkusz.edu.cn), Peking University Shenzhen Graduate School
