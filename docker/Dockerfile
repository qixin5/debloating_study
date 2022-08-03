FROM ubuntu:bionic-20220531

RUN apt-get update && apt-get -y install sudo && \
    sudo apt-get -y install build-essential \
    git zip unzip git-lfs cmake clang-9 \
    openjdk-8-jdk python-pip python3-pip bc opt wget curl vim emacs && \
    sudo pip install pyelftools && \
    sudo pip install capstone && \
    sudo pip install gdown && \
    sudo apt-get -y install python-pefile

RUN sudo ln -s /usr/bin/clang-9 /usr/bin/clang && \
    sudo ln -s /usr/bin/llvm-cov-9 /usr/bin/llvm-cov && \
    sudo ln -s /usr/bin/llvm-profdata-9 /usr/bin/llvm-profdata && \
    sudo ln -s /usr/bin/opt-9 /usr/bin/opt


ENV DEBSTUDY_DIR /debloating_study
ENV DEBAUG_DIR /debloating_study/tools/debaug
ENV ROPGDT_DIR /debloating_study/tools/ROPgadget
ENV CHISEL_DIR /debloating_study/tools/chisel
ENV DEBOP_DIR /debloating_study/tools/debop
ENV RAZOR_DIR /debloating_study/tools/razor