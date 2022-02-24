#!/bin/sh

#  Claident_analysis2.sh
#  
#
#  Created by Yuh Nammoku on 2018/12/18.
#
#$WORKINGDIR  作業ディレクトリ　$SEPARATE　サンプル毎に処理　 $THREAD 計算に使うCPUの数
#clcleanseqvはまとめてファイルを渡せるが１ラン分のデータが大きすぎる（1000万超）場合には$SEPARATEにTRUEを渡し、サンプルごとに処理する。
echo "Variable: WORKINGDIR = ${WORKINGDIR}, SEPARATE = ${SEPARATE}, THREAD = ${THREAD}"

cd $WORKINGDIR || exit $?

rm -r output*

unset input || exit $?
unset output || exit $?
unset filenumber || exit $?
unset filename || exit $?q
mkdir output_clcle_error

#サンプル毎
if [[ $SEPARATE == "TRUE" ]]; then
input=($(ls $WORKINGDIR/result_01_*/output_clfil/)) || exit $?
echo "input = ${input[@]}" || exit $?
output=($(ls $WORKINGDIR/result_01_*/output_clfil/ | sed s/\.fastq\.gz//)) || exit $?
echo "output = ${output[@]}" || exit $?
filenumber=$(ls $WORKINGDIR/result_01_*/output_clfil/ | wc -l) || exit $?

mkdir output_clcle || exit $?
for((i=0; i<$filenumber; i++))
do
clcleanseqv --derepmode=FULL --primarymaxnmismatch=0 --secondarymaxnmismatch=1 --pnoisycluster=0.5 --numthreads=${THREAD} $WORKINGDIR/result_01_*/output_clfil/${input[i]} ./output_clcle/${output[i]} || echo "ERROR in ${output[i]}" | mv ./output_clcle/${output[i]} output_clcle_error/
done

#１ランまとめて(こちらの方はエラーファイルをどう扱うかまだ実装してないので注意。)
else
filename=($(ls $WORKINGDIR/result_01_*/output_clfil/)) || exit $?
echo "filename = ${filename[@]}" || exit $?
filenumber=$(ls $WORKINGDIR/result_01_*/output_clfil/ | wc -l) || exit $?

for((i=0; i<$filenumber; i++))
do
input+="${WORKINGDIR}/result_01_*/output_clfil/${filename[i]} " || exit $?
done
echo "input = ${input[@]}" || exit $?

clcleanseqv --derepmode=FULL --primarymaxnmismatch=0 --secondarymaxnmismatch=1 --pnoisycluster=0.5 --numthreads=${THREAD} ${input[@]} ./output_clcle || exit $?
fi

rm -r result_02_*

mkdir result_02_`date +%Y%m%d%H%M` || exit $?
mv output* result_02_* || exit $?

echo 'Finished correctly!'


#clcleanseqv options inputfiles outputfolder

#--mode=NORMAL|EXACT
#Specify processing mode. (default: NORMAL)

#--derepmode=FULL|PREFIX
#Specify dereplication mode for VSEARCH. (default: PREFIX)

#--strand=PLUS|BOTH
#Specify search strand option for VSEARCH. (default: PLUS)

#--primarymaxnmismatch=INTEGER
#Specify the maximum number of acceptable mismatches for primary clustering. (default: 0)

#--secondarymaxnmismatch=INTEGER
#Specify the maximum number of acceptable mismatches for secondary clustering. (default: 1)

#--mincleanclustersize=INTEGER
#Specify minimum size of clean cluster. 0 means automatically determined (but this will take a while). (default: 0)

#--minsizeratio=DECIMAL
#Specify the minimum size ratio threshold for exact mode. (default: 2.0)

#--minsize=INTEGER
#Specify the minimum size for exact mode. (default: 3)

#--distance=INTEGER
#Specify the distance threshold of single-linkage clustering for exact mode. (default: 3)

#--warnsize=INTEGER
#Specify the minimum size threshold for warning in exact mode. (default: 100)

#--pnoisycluster=DECIMAL
#Specify the percentage of noisy cluster. (default: 0.5)

#--replicatelist=FILENAME
#Specify the list file of PCR replicates. (default: none)

#--minnreplicate=INTEGER
#Specify the minimum number of "presense" replicates required for clean and shared OTUs. (default: 2)

#--minpreplicate=DECIMAL
#Specify the minimum percentage of "presense" replicates per sample required for clean and shared OTUs. (default: 1)

#--minnpositive=INTEGER
#The OTU that consists of this number of reads will be treated as true positive in noisy/unshared sequence detection. (default: 1)

#--minppositive=DECIMAL
#The OTU that consists of this proportion of reads will be treated as true positive in noisy/unshared sequence detection. (default: 0)

#--minovllen=INTEGER
#Specify minimum overlap length. 0 means automatic. (default: 0)

#--runname=RUNNAME
#Specify run name for replacing run name. (default: given by sequence name)

#-n, --numthreads=INTEGER
#Specify the number of processes. (default: 1)
