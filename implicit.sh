#
trparse *.g4 2> /dev/null | \
	trxgrep ' //parserRuleSpec//ruleBlock//TOKEN_REF[not(text() = doc("*")//lexerRuleSpec/TOKEN_REF/text())]/text()'
