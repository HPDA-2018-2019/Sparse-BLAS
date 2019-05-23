#!/bin/bash

if [ $1 -gt 0 ]
then
  NGPU=$1
else
  NGPU=8
fi
KERNEL=1

./test_spmv g 10000 $NGPU 10 $KERNEL
./test_spmv g 20000 $NGPU 10 $KERNEL
./test_spmv g 30000 $NGPU 10 $KERNEL
./test_spmv g 100000 $NGPU 10 $KERNEL
./test_spmv g 200000 $NGPU 10 $KERNEL
./test_spmv g 300000 $NGPU 10 $KERNEL
