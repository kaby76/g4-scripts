#
cat - <<EOF
Finds all references (applied and defining) of a symbol.

Usage: $0 symbol-name
Arg is optional. If not provided, then all references for all symbols is outputted.
EOF

if [[ $# -gt 0 ]]
then
	echo Arguments were provided.
	trparse -l -t ANTLRv4 *.g4 2> /dev/null | \
		trxgrep " //(lexerRuleSpec/lexerRuleBlock//(ruleref/RULE_REF[text()='"$1"'] | terminal/TOKEN_REF[text()='"$1"']) | parserRuleSpec/ruleBlock//(ruleref/RULE_REF[text()='"$1"'] | terminal/TOKEN_REF[text()='"$1"']) | parserRuleSpec/RULE_REF[text()='"$1"'] | lexerRuleSpec/TOKEN_REF[text()='"$1"'])" | \
		trcaret
else
	trparse -l -t ANTLRv4 *.g4 2> /dev/null | \
		trxgrep " //(lexerRuleSpec/lexerRuleBlock//(ruleref/RULE_REF | terminal/TOKEN_REF) | parserRuleSpec/ruleBlock//(ruleref/RULE_REF | terminal/TOKEN_REF) | parserRuleSpec/RULE_REF | lexerRuleSpec/TOKEN_REF)" | \
		trcaret
fi
