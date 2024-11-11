#!/bin/sh

test=""
desc=`find . -name desc.xml | grep -v Generated | grep -v -E -e "save/|.ignore/|Generated/"`
for i in $desc
do
	dir=`dirname $i`
	names=`dotnet trparse -t ANTLRv4 $dir/*.g4 2>/dev/null | \
		dotnet trxgrep ' //parserRuleSpec[./ruleBlock//TOKEN_REF/text()="EOF"]/RULE_REF' | \
		dotnet trtext | \
		sed 's/^[^:]*://g'`
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
done
