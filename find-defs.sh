#
cat - <<EOF
Usage: $0 symbol-name

Finds all definitions of a symbol.
EOF

if [[ $# -gt 0 ]]
then
	echo Arguments were provided.
	trparse -l -t ANTLRv4 *.g4 2> /dev/null | \
		trxgrep " //(parserRuleSpec/RULE_REF[text()='"$1"'] | lexerRuleSpec/TOKEN_REF[text()='"$1"'])" | \
		trcaret
else
	echo No arguments were provided.
	trparse -l -t ANTLRv4 *.g4 2> /dev/null | \
		trxgrep " //(parserRuleSpec/RULE_REF | lexerRuleSpec/TOKEN_REF)" | \
		trcaret
fi
