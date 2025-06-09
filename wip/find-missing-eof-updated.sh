#!/bin/sh

#set -x
set -e

if [ $# -ne 0 ]
then
	files+=( $@ )
else
	desc=`find . -name desc.xml | grep -v Generated | grep -v -E -e "save/|.ignore/|Generated/"`
	for i in $desc
	do
		dir=`dirname $i`
		for g in $dir/*.g4
		do
			files+=( $dir/$g )
		done
	done
fi
if [ ${#files[@]} -eq 0 ]
then
	echo no files specified.
	exit 1
fi
names=`dotnet trparse -t ANTLRv4 ${files[@]} 2>/dev/null | \
	dotnet trxgrep ' //parserRuleSpec[./ruleBlock//TOKEN_REF/text()="EOF"]/RULE_REF' | \
	dotnet trtext | \
	sed 's/^[^:]*://g'`
if [ "$names" == "" ]
then
	echo no start rule.
	exit 1
fi
echo start rules = $names
for s in $names
do
	cs=`dotnet trparse -t ANTLRv4 $dir/*.g4 2>/dev/null | \
		dotnet trxgrep " //parserRuleSpec[RULE_REF/text()='$s']/ruleBlock/ruleAltList/labeledAlt[not(.//TOKEN_REF[text()='EOF'])]" | \
		dotnet trtext -c | \
		sed 's/^[^:]*://g'`
	for c in $cs
	do
		if [ $c -gt 0 ]
		then
			echo problem for $dir $s $cs
		fi
	done
done
