#!/usr/bin/bash
# "Setting MSYS2_ARG_CONV_EXCL so that Trash XPaths do not get mutulated."
export MSYS2_ARG_CONV_EXCL="*"
for i in `find . -name pom.xml | grep -v Generated | grep -v target`
do
    base=`dirname $i`
    echo $i
    grep -qs . $base/*.g4
    if [ "$?" = "0" ]
    then
	for j in "$base"/*.g4
	do
		echo $j | grep Parser.g4
		if [ "$?" = "0" ]
		then
			continue
		fi
		echo $j >> xxx-all
		fgrep "> skip" $j
		if [ "$?" = "0" ]
		then
			echo $j >> xxx-with
		fi
		fgrep "> channel" $j
		if [ "$?" = "0" ]
		then
			echo $j >> xxx-with
		fi
#		trparse -t antlr4 $j \
#		   | trxgrep -e '
#		      for $i in (
#		         //lexerRuleSpec
#		             [./lexerRuleBlock/lexerAltList/lexerAlt/lexerCommands/lexerCommand/lexerCommandName/identifier/RULE_REF/text()="skip"]
#		               /TOKEN_REF/text()])
#		         return concat("line ", $i/@Line, " col ", $i/@Column, " """, $i/@Text,"""")'
#		
	done
    fi
done