(: reformat all Antlr grammar rules in one line per rule. :)

replace //ruleSpec/(lexerRuleSpec|parserRuleSpec)/(TOKEN_REF|RULE_REF)/../@WS '';
replace //@WS ' ';
