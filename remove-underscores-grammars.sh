#!/bin/sh

d=`find . -name '*.g4' | grep -v examples | grep -v Generated | grep -v templates | sed 's#/[^/]*.g4##' | sort -u`
# find all other grammars in this directory and check if they are
# inconsistently combined or splitted.

echo "Setting MSYS2_ARG_CONV_EXCL so that Trash XPaths do not get mutulated."
export MSYS2_ARG_CONV_EXCL="*"
xxx=`pwd`
for i in $d
do
	if [[ -d $i/Generated ]]
	then
		rm -rf Generated
	fi
	cd $xxx/$i
	pwd
	for j in *.g4
	do
		echo $j
		trparse $j > /tmp/save.pt
		status=$?
		if [[ $status != "0" ]]
		then
			echo failed $j
			continue
		fi
		cat /tmp/save.pt | trxgrep '//RULE_REF/text()' 2>&1 | sort -u | awk '{print $1}' | grep '[_]$' > /tmp/save.txt

		# Rename list in the grammars.
		cat /tmp/save.txt | awk '{print $1 "," $1 ";"}' | sed 's/_;/;/' | tr -d '\n' > /tmp/save2.txt
		rename=`cat /tmp/save2.txt | sed 's/;$//'`
		if [[ "$rename" == "" ]]
		then
			echo none
			continue
		fi
		echo $rename
		trparse $j | trrename -r "$rename" > /tmp/save.pt
		status=$?
		if [[ $status != "0" ]]
		then
			echo failed $j
			continue
		fi
		cat /tmp/save.pt | trsponge -c true
	done
done
