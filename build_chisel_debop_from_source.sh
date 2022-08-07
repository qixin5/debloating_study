#!/bin/bash

CURRDIR=$(pwd)

if [ ! -d tools/debaug ]; then
    echo "Please get into tools directory, download debaug, and build it with setup_full.sh."
    exit 1
fi

if [ ! -d tools/debaug/llvm-project ]; then
    echo "llvm-project is not found in tools/debaug."
    echo "Please get into tools directory, download debaug, and build it with setup_full.sh."
    exit 1
fi


if [ ! -d tools ]; then
    echo "Missing tools directory. Have you built the tools with setup.sh?"
    exit 1
fi

cd tools
if [ -d chisel ]; then
    rm -fr chisel
fi
if [ -d debop ]; then
    rm -fr debop
fi


#Build chisel
export PATH="${DEBAUG_DIR}/llvm-project/build/bin:${PATH}"
sudo apt-get install -y libmlpack-dev
git clone https://github.com/aspire-project/chisel
cd chisel && git checkout 3ba2826eb
cp -r ../debaug/include/spdlog ./include/
sed -i 's|include_directories(include)|include_directories(include)\ninclude_directories(../debaug/llvm-project/clang/include)\ninclude_directories(../debaug/llvm-project/build/tools/clang/include)|g' CMakeLists.txt
mkdir build && cd build
cmake ..
make



#Build debop
cd ${CURRDIR}/tools
git clone https://github.com/qixin5/debop.git
cd debop && git checkout 1b21950
cp -r ../debaug/include/spdlog ./include/
sed -i 's|include_directories(/home/qxin6/llvm-project/clang/include) #Change to your own path!|include_directories(../debaug/llvm-project/clang/include)|g' CMakeLists.txt
sed -i 's|include_directories(/home/qxin6/llvm-project/build/tools/clang/include) #Change to your own path!|include_directories(../debaug/llvm-project/build/tools/clang/include)|g' CMakeLists.txt
mkdir build && cd build
cmake ..
make
