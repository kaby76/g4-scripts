#!/usr/bin/bash
#set -x

# Check if EOF followed by another element.
count=(`dotnet trparse *.g4 | dotnet trxgrep ' //grammarSpec/grammarDecl[not(grammarType/LEXER)]//parserRuleSpec//alternative/element[.//TOKEN_REF/text()="EOF"]/following-sibling::element' | dotnet trtext -c`)
if [ ${#count[@]} -gt 0 ]
then
	for i in ${count[@]}
	do
		echo $i | grep -e ':' > /dev/null 2>&1
		if [ $? -eq 0 ]
		then		
			j=`echo $i | awk -F: '{print $2}'`
		else
			j=$i
		fi
		if [ "$j" != "0" ]
		then
		    echo $j has an EOF usage followed by another element.
		fi
	done
fi

# Check if EOF isn't at end of each alt.
count=`dotnet trparse *.g4 | dotnet trxgrep ' //grammarSpec/grammarDecl[not(grammarType/LEXER)]//labeledAlt[.//TOKEN_REF/text()="EOF" and count(../labeledAlt) > 1]' | dotnet trtext -c`
if [ ${#count[@]} -gt 0 ]
then
	for i in ${count[@]}
	do
		echo $i | grep -e ':' > /dev/null 2>&1
		if [ $? -eq 0 ]
		then		
			j=`echo $i | awk -F: '{print $2}'`
		else
			j=$i
		fi
		if [ "$j" != "0" ]
		then
		    echo $j has an EOF in one alt, but not in another.
		fi
	done
fi

start=(`dotnet trparse *.g4 | dotnet trxgrep -e '
    /grammarSpec[grammarDecl[not(grammarType/LEXER)]]
    //parserRuleSpec[ruleBlock//TOKEN_REF/text()="EOF"]/RULE_REF/text()' | tr -d '\r'`)
echo "Start rules:" 1>&2
echo ${start[@]}

# Check if start rule is on the RHS of another parser rule.
echo "Checking for RHS ref of start rule..."
for s in ${start[@]}
do
    dotnet trparse -l -t ANTLRv4 *.g4 2> /dev/null | dotnet trquery grep '
      //parserRuleSpec[.//ruleBlock//RULE_REF/text() = "'$s'" ]' | dotnet trcaret
done
