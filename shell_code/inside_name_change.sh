#!/bin/sh
#  name_change.sh
#  
#
#  Created by Yu Nammoku on 2020/01/24.
#指定したディレクトリにあるフォルダ内の対象ファイル(全て同名)を全てフォルダの名前に変える。
#$1:ディレクトリ　$2:対象ファイル名(全て同名)

unset foldername
unset filenumber
unset beforename
unset aftername

foldername=($(ls $1)) || exit $?
echo "${foldername[@]}"

filenumber=$(ls -l $1 | wc -l) || exit $?
echo $filenumber

for((i=0; i<=$filenumber; i++))
do
beforename="$1/${foldername[i]}/$2"
aftername="$1/${foldername[i]}/${foldername[i]}"
mv $beforename $aftername
done

echo 'Finished correctly!'


