#!/bin/sh

#  Claident_analysis.sh
#  
#
#  Created by Yuh Nammoku on 2018/12/13.
#

#Novagenの次世代データはfoward.fastaq.gzになっているので、forward.fastq.gzにあらかじめ直す。
#fastaqではなくfastq
#$WORKINGDIR 作業ディレクトリ $PREREGION　置換前領域名　$PRERUNNAME 置換前ラン名 $REGION　置換後領域名　$RUNNAME 置換後ラン名 $THREAD 計算に使うCPUの数
#qsub -v WORKINGDIR=/home/yu/claident_result_O,PREREGION=_HCGFCBCX2_L1,PRERUNNAME=O_TKD180203527-,REGION=__ITS,RUNNAME=O__,THREAD=24 claident_01.sh -l select=1:ncpus=24:mem=90gb
echo "Variable: WORKINGDIR = ${WORKINGDIR}, PREREGION = ${PREREGION}, PRERUNNAME = ${PRERUNNAME}, REGION = ${REGION}, RUNNAME = ${RUNNAME}, THREAD = ${THREAD}"

cd ${WORKINGDIR} || exit $?
pwd
rm -r output*

#clconcatpair　ペアエンドリードの連結
clconcatpair --output=DIRECTORY --mode=OVL --maxnmismatch=9999 --maxpmismatch=0.5 --minqual=0 --minlen=0 --compress=GZIP --numthreads=${THREAD} input_clcon output_clcon || exit $?

#climportfastqに渡すファイルの作成
if [ ! -f climportfastq_filename.txt ];then

unset input || exit $?
unset output || exit $?
unset filenumber || exit $?

input=($(ls $WORKINGDIR/output_clcon/)) || exit $?
echo "${input[@]}" || exit $?
output=($(ls ${WORKINGDIR}/output_clcon/ | sed s/\.fastq\.gz// | sed -e s/${PRERUNNAME}/${RUNNAME}/g | sed -e s/${PREREGION}/${REGION}/g )) || exit $?
echo "${output[@]}" || exit $?
filenumber=$(ls $WORKINGDIR/output_clcon/ | wc -l) || exit $?

for((i=0; i<$filenumber; i++))
do
echo ${input[i]}`printf "\t"`${output[i]} || exit $?
echo ${input[i]}`printf "\t"`${output[i]} >> climportfastq_filename.txt || exit $?
done

fi

#climportfastq　配列名の変更>>RUNNAME__SEQNAME__PRIMERNAME
cd ${WORKINGDIR}/output_clcon || exit $?
climportfastq --compress=GZIP --numthreads=${THREAD} --compress=GZIP ../climportfastq_filename.txt ../output_climp || exit $?


#clfilterseqのアウトプット用フォルダを作成
cd ${WORKINGDIR} || exit $?
mkdir output_clfil || exit $?

#clfilterseqのインプットファイル名を取得
unset filename || exit $?
unset filenumber || exit $?
filename=($(ls ${WORKINGDIR}/output_climp)) || exit $?
filenumber=$(ls ${WORKINGDIR}/output_climp/ | wc -l) || exit $?

#clfilterseq　条件にあった配列を除く
for((i=0; i<$filenumber; i++))
do
echo ${filename[i]} || exit $?
clfilterseq  --minqual=30 --minlen=100 --maxplowqual=0.1 --numthreads=${THREAD}  --output=DIRECTORY --append output_climp/${filename[i]} output_clfil || exit $?
done

#結果をresult_01_*に移動
rm -r result_01_*

mkdir result_01_`date +%Y%m%d%H%M` || exit $?
mv output* result_01_* || exit $?
mv climportfastq_filename.txt result_01_* || exit $?
echo 'Finished correctly!'


###clconcatpair###
#ペアエンドでシーケンスを行った場合には、clconcatpairを用いてフォワード配列とリバース配列を連結します。

#clconcatpair options inputfolder outputfolder 入力フォルダから*.forward.fastqと*.reverse.fastqを探しだして自動的に連結します。
#clconcatpair options inputfile1 inputfile2 ... inputfileN outputfolder 入力ファイルから*.forward.fastqと*.reverse.fastqを探しだして自動的に連結します。
#clconcatpair options forwardreadfile reversereadfile outputfile (or outputfolder) 入力ファイル名が*.forward.fastqと*.reverse.fastqになっていない場合は、このようにして1組のファイルの配列を連結可能です。

#-o, --output=FILE|DIRECTORY
#Specify output format. (default: DIRECTORY)

#-m, --mode=OVL|NON
#Specify the concatenation mode. (default: OVL)

#--maxnmismatch=INTEGER
#Specify the maximum number of mismatches. (default: 9999)

#--maxpmismatch=DECIMAL
#Specify the maximum percentage of mismatches. (default: 0.5)

#--minqual=INTEGER
#Specify the minimum quality value for 3'-tail trimming. (default: 0)

#--minlen=INTEGER
#Specify the minimum length after trimming. (default: 0)

#--minovllen=INTEGER
#Specify the minimum length of overlap. (default: 10)

#-p, --padding=SEQUENCE
#Specify the padding sequence for non-overlapped paired-end mode.(default: ACGTACGTACGTACGT)

#--compress=GZIP|BZIP2|XZ|DISABLE
#Specify compress output files or not. (default: GZIP)

#-n, --numthreads=INTEGER
#Specify the number of processes. (default: 1)



###climportfastq###
#climportfastq_filenameの中の右側に列はラン名__サンプル名__領域とすることに注意
#climportfastq options inputfile outputfolder

#--compress=GZIP|BZIP2|XZ|DISABLE
#Specify compress output files or not. (default: GZIP)

#-a, --append
#Specify outputfile append or not. (default: off)

#-n, --numthreads=INTEGER
#Specify the number of processes. (default: 1)




###clfilterseq###
#clfilterseq options inputfile outputfile

#-k, --keyword=REGEXP(,REGEXP..)
#Specify regular expression(s) for sequence names. You can use regular expression but you cannot use comma. All keywords will be used as AND conditions. (default: none)

#-n, --ngword=REGEXP(,REGEXP..)
#Specify regular expression(s) for sequence names. You can use regular expression but you cannot use comma. All ngwords will be used as AND conditions. (default: none)

#-c, --converse
#If this option is specified, matched sequences will be cut off and nonmatched sequences will be saved. (default: off)

#-a, --append
#Specify outputfile append or not. (default: off)

#-o, --output=FILE|DIRECTORY
#Specify output format. (default: FILE)

#--minlen=INTEGER
#Specify minimum length threshold. (default: 1)

#--maxlen=INTEGER
#Specify maximum length threshold. (default: Inf)

#--minqual=INTEGER
#Specify minimum quality threshold. (default: none)

#--minquallen=INTEGER
#Specify minimum quality length threshold. (default: 1)

#--minmeanqual=INTEGER
#Specify minimum mean quality threshold. (default: minqual)

#--maxplowqual=DECIMAL
#Specify maximum percent threshold of low quality sequences. (default: 1)

#--replaceinternal
#Specify whether internal low-quality characters replace to missing data (?) or not. (default: off)

#--contigmembers=FILENAME
#Specify file path to contigmembers file. (default: none)

#--otufile=FILENAME
#Specify file path to otu file. (default: none)

#--minnseq=INTEGER
#Specify the minimum number threshold for reads of contigs. (default: 0)

#--replicatelist=FILENAME
#Specify the list file of PCR replicates. (default: none)

#--minnreplicate=INTEGER
#Specify the minimum number of "presense" replicates required for clean and nonchimeric OTUs. (default: 2)

#--minpreplicate=DECIMAL
#Specify the minimum percentage of "presense" replicates per sample required for clean and nonchimeric OTUs. (default: 1)

#--minnpositive=INTEGER
#The OTU that consists of this number of reads will be treated as true positive in noise/chimera detection. (default: 1)

#--minppositive=DECIMAL
#The OTU that consists of this proportion of reads will be treated as true positive in noise/chimera detection. (default: 0)

#--runname=RUNNAME
#Specify run name for replacing run name. (default: given by sequence name)

#-n, --numthreads=INTEGER
#Specify the number of processes. (default: 1)
