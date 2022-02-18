#!/bin/sh
#  gi_taxid.sh
#  
#
#  Created by Yuh Nammoku on 2019/02/23.
#
#目的　GIリスト:gi_list.txtからTaxonomyID対応表:gi_taxid_nucl_*に問い合わせてTaxonomyIDリストを得る。
#あらかじめ必要なもの　作業ディレクトリ直下にデータベース：gi_taxid_nucl/gi_taxid_nucl_*の用意が必要。

#ヘルプ(-h)gi_taxid.sh $1:作業ディレクトリへのパス $2:giリストファイル $3:gi_taxidファイル名 $4:taxidファイル名
if [[ $1 == -h ]]
then
echo "コマンド 作業ディレクトリへのパス giリストファイル(インプット) gi_taxidファイル名 taxidファイル名`\n`あらかじめ作業ディレクトリ直下に検索用データベース：gi_taxid_nucl/gi_taxid_nucl_*の用意が必要。"
exit
fi

#最終産物であるtaxidファイルおよびgi_taxidファイルの削除と変数初期化。
if [[ -e $1/$3 ]]
then
rm $1/$3
fi
if [[ -e $1/$4 ]]
then
rm $1/$4
fi
count=0
before_index=0
unset index_list
T=0

#問い合わせGIリスト:gi_list.txtの内容を変数:gi_listに配列として代入。
gi_list=$(cat $1/$2)
#GI-TaxonomyID対応表:gi_taxid_nucl_*のファイル名を変数:db_listに配列として代入。
db_list=($(ls $1/gi_taxid_nucl/gi_taxid_nucl_*))
db_number=$(ls -l $1/gi_taxid_nucl/gi_taxid_nucl_* | wc -l)

#index_list.txt（各gi_taxid_nucl_*の末尾のGIを記録したもの）の有無を調べる。
if [[ -e $1/index_list.txt ]]
then
T=1
fi

#index_list.txtがなければ先に作る。
if [[ T -eq 0 ]]
then
for i in $db_list
do
index_list+=" $(cat $i | tail -1 | sed -e s/$'\t'.*$//g)"
echo "$(cat $i | tail -1 | sed -e s/$'\t'.*$//g)"
done
echo $index_list > $1/index_list.txt
fi

#index_list.txtがあればそのまま、なければ上で作ったものを使う。
if [[ -e $1/index_list.txt ]]
then
index_list=($(cat $1/index_list.txt))
for j in $gi_list
do


#初期化忘れない。
before_index=0
for((i=0; i<$db_number; i++))
do
if [[ $j -gt $before_index && $j -le ${index_list[i]} ]]
then
#echoで""で囲わないと中のタブが勝手に半角スペースに変換される。
echo "$(grep ^$j$'\t' ${db_list[i]})" >> $1/$3
fi
#一つ前の${index_list[i]}を記録。
before_index=${index_list[i]}
done
done
fi
unset index_list

