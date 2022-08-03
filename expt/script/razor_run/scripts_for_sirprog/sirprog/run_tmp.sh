#!/bin/bash

echo "make-3.79"
./clean_sirprog.sh make-3.79
screen ./train_and_debloat.sh make-3.79 p0.2train


echo "vim-5.8"
./clean_sirprog.sh vim-5.8
screen ./train_and_debloat.sh vim-5.8 p0.3train
