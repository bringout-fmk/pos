#!/bin/sh

cp $1 $1.orig

sed -e "s/^\(PROC.*\)[ ]\(.*\)/function \2/" $1 > tmp1

sed -e "s/^\(FUNC.*\)[ ]\(.*\)/function \2/" tmp1 > tmp2
sed -e "s/RETURN/return/" tmp2 > tmp3


sed -e "/function/{G;s/$/\*\{/;}" tmp3 > tmp4 
sed -e "/return/{G;s/$/\*\}/;}" tmp4 > $1
