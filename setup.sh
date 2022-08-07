#!/bin/bash

pip3 install capstone

mkdir tools && cd tools

TOOLSDIR=$(pwd)


if [ ! -d radamsa ]; then

    echo "Install Radamsa"
    cd ${TOOLSDIR}
    git clone https://gitlab.com/akihe/radamsa.git
    cd radamsa
    git checkout 63fe66
    make
    sudo make install
fi


if [ ! -d ROPgadget ]; then

    echo "Install ROPgadget"
    cd ${TOOLSDIR}
    git clone https://github.com/JonathanSalwan/ROPgadget.git
    cd ROPgadget
    git checkout a448d99
fi


chisel_debop_binarylink="https://drive.google.com/uc?id=15oDniowCEq60RXVkRIMeyCWl5U3GjB5-"
debaug_binarylink="https://drive.google.com/uc?id=1oo5zTRL6PokZEHvmkDPHZbZkVlcWsCy7"


if [ ! -d chisel ]; then

    echo "Setup for Chisel binary"
    cd ${TOOLSDIR}
    mkdir -p chisel/build/bin

    gdown ${chisel_debop_binarylink}
    if [ ! -f chisel_debop_binaries.zip ]; then
	echo "Fail to download chisel and debop binaries from ${chisel_debop_binarylink}"
	exit 1

    else
	unzip chisel_debop_binaries.zip
	cp chisel_debop_binaries/chisel chisel/build/bin/
    fi    
fi


if [ ! -d debop ]; then

    echo "Setup for Debop binary"
    cd ${TOOLSDIR}
    mkdir -p debop/build/bin

    if [ ! -d chisel_debop_binaries ]; then
	gdown ${chisel_debop_binarylink}
	if [ ! -f chisel_debop_binaries.zip ]; then
            echo "Fail to download chisel and debop binaries from ${chisel_debop_binarylink}"
            exit 1
	else
	    unzip chisel_debop_binaries.zip
	fi
    fi

    cp chisel_debop_binaries/reducer debop/build/bin/
fi


if [ ! -d debaug ]; then

    echo "Install Debaug"
    cd ${TOOLSDIR}

    git clone https://github.com/qixin5/debaug
    cd debaug
    gdown ${debaug_binarylink}
    unzip debaug_binary.zip
    ./compile_java
    rm debaug_binary.zip
fi


if [ ! -d razor ]; then

    echo "Install Razor"
    cd ${TOOLSDIR}
    git clone https://github.com/cxreet/razor.git
    cd razor
    git checkout a74c84
    mkdir bin
    cp ../../expt/script/razor_run/simple_code_size.py ./bin/
    rm -fr stitcher
    cp -r ../../expt/script/razor_run/stitcher ./
    cp -r ../../expt/script/razor_run/scripts_for_* ./
    cd tracers
    python build.py dynamorio
    python build.py pin
fi


cd ${TOOLSDIR}
if [ -d chisel_debop_binaries ]; then
    rm -fr chisel_debop_binaries
fi
if [ -f chisel_debop_binaries.zip ]; then
    rm -fr chisel_debop_binaries.zip
fi



bash_workdir_link="https://drive.google.com/uc?id=1J3jb2gzMFKFF1cRZyddOZqMtcfjHRKiv"
make_workdir_link="https://drive.google.com/uc?id=1frAGBzgl4GEWzzN5UrZrsvOr6a1Dmh3O"
vim_workdir_link="https://drive.google.com/uc?id=1xBLC0jQC_fhSNrWHT82T8Ggir3EVZMwm"

cd ${DEBSTUDY_DIR}/expt/debaug/
mkdir working
cd working
gdown ${bash_workdir_link}
unzip bash.zip
gdown ${make_workdir_link}
unzip make.zip
gdown ${vim_workdir_link}
unzip vim.zip
rm -f *.zip


cd ${DEBSTUDY_DIR}/expt/debaug/benchmark/space
unzip reltest.zip

echo "Setup done"
