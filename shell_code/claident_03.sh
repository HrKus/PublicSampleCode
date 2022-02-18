#!/bin/sh

#  Claident_analysis2.sh
#  
#
#  Created by Yuh Nammoku on 2018/12/18.
#
#$WORKINGDIR  作業ディレクトリ　$SEPARATE　サンプル毎に処理　 $THREAD 計算に使うCPUの数 $ITS　ITS領域か否か
echo "Variable: WORKINGDIR = ${WORKINGDIR}, SEPARATE = ${SEPARATE}, THREAD = ${THREAD}, ITS = ${ITS}"

cd ${WORKINGDIR} || exit $?
rm -r output*

#サンプル毎に処理
if [[ ${SEPARATE} == "TRUE" ]]; then

unset foldername || exit $?
unset filernumber || exit $?
foldername=($(ls ${WORKINGDIR}/result_02_*/output_clcle)) || exit $?
echo "foldername = ${foldername[@]}" || exit $?
filenumber=$(ls ${WORKINGDIR}/result_02_*/output_clcle/ | wc -l) || exit $?
echo "filenumber = $filenumber" || exit $?

unset input || exit $?
for((i=0; i<$filenumber; i++))
do
input+="${WORKINGDIR}/result_02_*/output_clcle/${foldername[i]}/primarycluster.denoised.fasta " || exit $?
done
echo "clclassseqv_input = ${input[@]}" || exit $?

clclassseqv --minident=0.97 --strand=BOTH --numthreads=${THREAD} $input output_clcla || exit $?

unset input || exit $?
for((i=0; i<$filenumber; i++))
do
input+="${WORKINGDIR}/result_02_*/output_clcle/${foldername[i]}/primarycluster.fasta " || exit $?
done
echo "clrecoverseqv_input = ${input[@]}" || exit $?

clrecoverseqv --minident=0.97 --centroid=./output_clcla/clustered.fasta --numthreads=${THREAD} $input output_clrec


#１ランまとめて処理
else
clclassseqv --minident=0.97 --strand=BOTH --numthreads=${THREAD} ${WORKINGDIR}/result_02_*/output_clcle/primarycluster.denoised.fasta output_clcla || exit $?
clrecoverseqv --minident=0.97 --centroid=./output_clcla/clustered.fasta --numthreads=${THREAD} ${WORKINGDIR}/result_02_*/output_clcle/primarycluster.fasta output_clrec
fi


clsumclass --output=Matrix ${WORKINGDIR}/output_clrec/clustered.otu.gz output_clsum || exit $?
clrunuchime --numthreads=${THREAD} --otufile=output_clrec/clustered.otu.gz ${WORKINGDIR}/output_clrec/clustered.fasta ${WORKINGDIR}/output_clrun || exit $?

#ITSの両側の保存領域の除去
if [[ ${ITS} == "TRUE" ]]; then
cd ${WORKINGDIR}/output_clrun || exit $?
ITSx -i nonchimeras.fasta --cpu ${THREAD} || exit $?
cat ITSx_out.ITS1.fasta ITSx_out.ITS2.fasta > ITSx_out.fasta || exit $?
cat ITSx_out.fasta | sed -e "s/;size.*$//g" > ITSx_otu.fasta || exit $?

clfiltersum --otuseq=ITSx_otu.fasta ../output_clsum ../output_clfilsum || exit $?
fi

cd ${WORKINGDIR} || exit $?

rm -r result_03_* 


mkdir result_03_`date +%Y%m%d%H%M` || exit $?
mv output* result_03_* || exit $?

echo 'Finished correctly!'


###clclassseqv###
#clclassseqv options inputfiles outputfolder

#--minident=DECIMAL
#Specify the minimum identity threshold. (default: 0.97)

#--strand=PLUS|BOTH
#Specify search strand option for VSEARCH. (default: PLUS)

#--paddinglen=INTEGER
#Specify the length of padding. (default: 0)

#--minovllen=INTEGER
#Specify minimum overlap length. 0 means automatic. (default: 0)

#-n, --numthreads=INTEGER
#Specify the number of processes. (default: 1)



###clrecoverseqv###
#clrecoverseqv options inputfiles outputfolder

#--minident=DECIMAL
#Specify the minimum identity threshold. (default: 0.97)

#--strand=PLUS|BOTH
#Specify search strand option for VSEARCH. (default: PLUS)

#--centroid=FILENAME
#Specify the centroid sequence file. (default: none)

#--paddinglen=INTEGER
#Specify the length of padding. (default: 0)

#--minovllen=INTEGER
#Specify minimum overlap length. 0 means automatic. (default: 0)

#-n, --numthreads=INTEGER
#Specify the number of processes. (default: 1)



###clsumclass###
#clsumclass options inputfile outputfile

#--output=COLUMN|MATRIX
#Specify output format. (default: MATRIX)

#--runname=RUNNAME
#Specify run name for replacing run name. (default: given by sequence name)



###clrunuchime###
#clrunuchime options inputfile outputfolder

#--contigmembers=FILENAME
#Specify file path to contigmembers file. (default: none)

#--otufile=FILENAME
#Specify file path to otu file. (default: none)

#--referencedb=FILENAME
#Specify file path to reference database (default: none)

#-n, --numthreads=INTEGER
#Specify the number of processes. (default: 1)



###clfiltersum###
#clfiltersum --minpseqotu=0.005

#clfiltersum options inputfile outputfile

#--replicatelist=FILENAME
#Specify the list file of PCR replicates. (default: none)

#--otu=OTUNAME,...,OTUNAME
#Specify output OTU names. The unspecified OTUs will be deleted.

#--negativeotu=OTUNAME,...,OTUNAME
#Specify delete OTU names. The specified OTUs will be deleted.

#--sample=SAMPLENAME,...,SAMPLENAME
#Specify output sample names. The unspecified samples will be deleted.

#--negativesample=SAMPLENAME,...,SAMPLENAME
#Specify delete sample names. The specified samples will be deleted.

#--otulist=FILENAME
#Specify output OTU list file name. The file must contain 1 OTU name at a line.

#--negativeotulist=FILENAME
#Specify delete OTU list file name. The file must contain 1 OTU name at a line.

#--otuseq=FILENAME
#Specify output OTU sequence file name. The file must contain 1 OTU name at a line.

#--negativeotuseq=FILENAME
#Specify delete OTU sequence file name. The file must contain 1 OTU name at a line.

#--samplelist=FILENAME
#Specify output sample list file name. The file must contain 1 sample name at a line.

#--negativesamplelist=FILENAME
#Specify delete sample list file name. The file must contain 1 sample name at a line.

#--minnseqotu=INTEGER
#Specify minimum number of sequences of OTU. If the number of sequences of a OTU is smaller than this value at all samples, the OTU will be omitted. (default: 0)

#--minnseqsample=INTEGER
#Specify minimum number of sequences of sample. If the number of sequences of a sample is smaller than this value at all OTUs, the sample will be omitted. (default: 0)

#--minntotalseqotu=INTEGER
#Specify minimum total number of sequences of OTU. If the total number of sequences of a OTU is smaller than this value, the OTU will be omitted. (default: 0)

#--minntotalseqsample=INTEGER
#Specify minimum total number of sequences of sample. If the total number of sequences of a sample is smaller than this value, the sample will be omitted. (default: 0)

#--minpseqotu=DECIMAL
#Specify minimum percentage of sequences of OTU. If the number of sequences of a OTU / the total number of sequences of a OTU is smaller than this value at all samples, the OTU will be omitted.(default: 0)

#--minpseqsample=DECIMAL
#Specify minimum percentage of sequences of sample. If the number of sequences of a sample / the total number of sequences of a sample is smaller than this value at all OTUs, the sample will be omitted.(default: 0)

