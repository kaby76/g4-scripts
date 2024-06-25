#
if [[ $# -gt 0 ]]
then
	echo Arguments were provided.
	echo Finding unused parser symbols in grammars...
	trparse -t ANTLRv4 $@ 2> /dev/null | trquery delete ' //parserRuleSpec
		[not(doc("*")//ruleBlock//RULE_REF/text() = ./RULE_REF/text())
		 and not(./ruleBlock//TOKEN_REF/text() = "EOF")]' | trsponge -c
else
	echo No arguments were provided.
	echo Finding unused parser symbols in grammars...
	for i in `find . -name desc.xml | grep -v Generated\*`
	do
		echo $i
		d=`dirname $i`
		pushd $d > /dev/null 2>&1
		# Parse all grammar files so that any imports can also be checked.
		trparse -t ANTLRv4 *.g4 2> /dev/null \
		        | trquery delete ' //parserRuleSpec
			[not(doc("*")//ruleBlock//RULE_REF/text() = ./RULE_REF/text())
			and not(./ruleBlock//TOKEN_REF/text() = "EOF")]' | trsponge -c
		popd > /dev/null 2>&1
	done
fi

