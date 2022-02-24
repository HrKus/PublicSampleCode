#!/bin/sh

#  claident_analysis_temp.sh
#  
#
#  Created by Yuh Nammoku on 2018/12/20.
#
#$WORKINGDIR  作業ディレクトリ $THREAD 計算に使うCPUの数
echo "Variable: WORKINGDIR = ${WORKINGDIR}, THREAD = ${THREAD}"

cd $WORKINGDIR || exit $?

clmakecachedb --blastdb=semiall_species --numthreads=${THREAD} $WORKINGDIR/result_03_*/output_clrun/ITSx_otu.fasta $WORKINGDIR/output_clmak || exit $?


clidentseq blastn -task megablast -word_size 16 end --blastdb=output_clmak --numthreads=${THREAD} --method=1,95% $WORKINGDIR/result_03_*/output_clrun/ITSx_otu.fasta $WORKINGDIR/output_cliden_95per_top || exit $?
clidentseq blastn -task megablast -word_size 16 end --blastdb=output_clmak --numthreads=${THREAD} --method=1,99% $WORKINGDIR/result_03_*/output_clrun/ITSx_otu.fasta $WORKINGDIR/output_cliden_99per_top || exit $?


classigntax --taxdb=semiall_species --minnsupporter=1 $WORKINGDIR/output_cliden_95per_top $WORKINGDIR/output_class_95per_top || exit $?
    
classigntax --taxdb=semiall_species --minnsupporter=1 $WORKINGDIR/output_cliden_99per_top $WORKINGDIR/output_class_99per_top || exit $?

clidentseq blastn -task megablast -word_size 16 end --blastdb=output_clmak --numthreads=${THREAD} $WORKINGDIR/result_03_*/output_clrun/ITSx_otu.fasta $WORKINGDIR/output_cliden_QC || exit $?

classigntax --taxdb=semiall_species --maxpopposer=0.1 --minsoratio=9 $WORKINGDIR/output_cliden_QC $WORKINGDIR/output_class_QC_lt_1_10 || exit $?

classigntax --taxdb=semiall_species $WORKINGDIR/output_cliden_QC $WORKINGDIR/output_class_QC || exit $?



rm -r result_04_*

mkdir result_04_`date +%Y%m%d%H%M` || exit $?
mv output* result_04_* || exit $?

echo 'Finished correctly!'

#Command line options
#====================
#blastn options end
#Specify commandline options for blastn.
#(default: -task dc-megablast -word_size 11 -template_type coding_and_optimal
#-template_length 16)

#--bdb, --blastdb=BLASTDB(,BLASTDB)
#Specify name of BLAST database or cache database. (default: none)

#--method=QC|NNC|NNC+QC|INTEGER|INTEGER%|INTEGER,INTEGER%
#Specify identification method. (default: QC)

#--negativegilist=FILENAME
#Specify file name of negative GI list. (default: none)

#--negativegi=GI(,GI..)
#Specify negative GIs.

#--negativeseqidlist=FILENAME
#Specify file name of negative SeqID list. (default: none)

#--negativeseqid=SeqID(,SeqID..)
#Specify negative SeqIDs.

#--minlen=INTEGER
#Specify minimum length of query sequence. (default: 50)

#--minalnlen=INTEGER
#Specify minimum alignment length of center vs neighborhoods.
#(default: 50)

#--minalnlennn=INTEGER
#Specify minimum alignment length of query vs nearest-neighbor.
#(default: 100)

#--minalnlenb=INTEGER
#Specify minimum alignment length of query/nearest-neighbor vs borderline.
#(default: 50)

#--minalnpcov=DECIMAL
#Specify minimum percentage of alignment coverage of center vs neighborhoods.
#(default: 0.5)

#--minalnpcovnn=DECIMAL
#Specify minimum percentage of alignment coverage of query vs nearest-neighbor.
#(default: 0.5)

#--minalnpcovb=DECIMAL
#Specify minimum percentage of alignment coverage of query/nearest-neighbor vs
#borderline. (default: 0.5)

#--minnneighborhoodseq=INTEGER
#Specify minimum number of neighborhood sequences. (default: 2)

#-n, --numthreads=INTEGER
#Specify the number of processes. (default: 1)

#--ht, --hyperthreads=INTEGER
#Specify the number of threads of each process. (default: 1)

#--nodel
#If this option is specified, all temporary files will not deleted.
