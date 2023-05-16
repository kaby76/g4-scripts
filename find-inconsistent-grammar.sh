#!/bin/sh

d=`find . -name '*.g4' | grep -v examples | grep -v Generated | sed 's#/[^/]*.g4##' | sort -u`
# find all other grammars in this directory and check if they are
# inconsistently combined or splitted.
for i in $d
do
	for j in $i/*.g4
	do
		spgrammar=no
		slgrammar=no
		cat $j | grep "parser[ \t\n\r]*grammar" > /dev/null
		if [[ $? == 0 ]]
		then
			spgrammar=yes
		fi
		cat $j | grep "lexer[ \t\n\r]*grammar" > /dev/null
		if [[ $? == 0 ]]
		then
			slgrammar=yes
		fi
		for k in $i/*.g4
		do
			sopgrammar=no
			solgrammar=no
			if [[ "$j" == "$k" ]]
			then
				continue
			fi
			cat $k | grep "parser[ \t\n\r]*grammar" > /dev/null
			if [[ $? == 0 ]]
			then
				sopgrammar=yes
			fi
			cat $k | grep "lexer[ \t\n\r]*grammar" > /dev/null
			if [[ $? == 0 ]]
			then
				solgrammar=yes
			fi

			if [[ $spgrammar == "yes" || "$slgrammar" == "yes" ]]
			then
				if [[ $sopgrammar == "no" && "$solgrammar" == "no" ]]
				then
					echo $spgrammar $slgrammar $sopgrammar $solgrammar
					echo A Inconsistent split/combine grammars in $i
				fi
			fi
			if [[ "$spgrammar" == "no" && "$slgrammar" == "no" ]]
			then
				if [[ "$sopgrammar" == "yes" || "$solgrammar" == "yes" ]]
				then
					echo $spgrammar $slgrammar $sopgrammar $solgrammar
					echo B Inconsistent split/combine grammars in $i
				fi
			fi
		done
	done
done

f=`find . -name '*.g4' | grep -v examples | grep -v Generated`
for i in $f
do

	echo $i | grep -i parser > /dev/null
	if [[ $? == 0 ]]
	then
		pfile=yes
	else
		pfile=no
	fi
	cat $i | grep "parser[ \t\n\r]*grammar" > /dev/null
	if [[ $? == 0 ]]
	then
		pgrammar=yes
	else
		pgrammar=no
	fi

	echo $i | grep -i lexer > /dev/null
	if [[ $? == 0 ]]
	then
		lfile=yes
	else
		lfile=no
	fi
	
	cat $i | grep "lexer[ \t\n\r]*grammar" > /dev/null
	if [[ $? == 0 ]]
	then
		lgrammar=yes
	else
		lgrammar=no
	fi

	if [[ "$pgrammar" == "yes" && "$pfile" == "no" ]]
	then
		echo $pgrammar $pfile $lgrammar $lfile
		echo problem A with $i
	fi
	if [[ "$pgrammar" == "no" && "$pfile" == "yes" ]]
	then
		echo $pgrammar $pfile $lgrammar $lfile
		echo problem B with $i
	fi

	if [[ "$lgrammar" == "yes" && "$lfile" == "no" ]]
	then
		echo $pgrammar $pfile $lgrammar $lfile
		echo problem C with $i
	fi
	if [[ "$lgrammar" == "no" && "$lfile" == "yes" ]]
	then
		echo $pgrammar $pfile $lgrammar $lfile
		echo problem D with $i
	fi

done


