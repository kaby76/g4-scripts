#!/bin/bash
if [[ $# -gt 0 ]]
then
	echo Arguments were provided.
	echo Finding useless parentheses in grammars...
	trparse -l -t ANTLRv4 $@ 2> /dev/null > o.pt
	if [ -f o.pt ] && [ -s o.pt ]
	then
		echo "Python3 checks..."
		cat o.pt | trxgrep '
			(: Find all RULE_REF that conflict with Python3 :)
			//RULE_REF[text() = ("abs", "all", "and", "any", "apply", "as", "assert",
			"bin", "bool", "break", "buffer", "bytearray",
			"callable", "chr", "class", "classmethod", "coerce", "compile", "complex", "continue",
			"def", "del", "delattr", "dict", "dir", "divmod",
			"elif", "else", "enumerate", "eval", "execfile", "except",
			"file", "filter", "finally", "float", "for", "format", "from", "frozenset",
			"getattr", "global", "globals",
			"hasattr", "hash", "help", "hex",
			"id", "if", "import", "in", "input", "int", "intern", "is", "isinstance", "issubclass", "iter",
			"lambda", "len", "list", "locals",
			"map", "max", "min", "memoryview",
			"next", "nonlocal", "not",
			"object", "oct", "open", "or", "ord",
			"pass", "pow", "print", "property",
			"raise", "range", "raw_input", "reduce", "reload", "repr", "return", "reversed", "round",
			"set", "setattr", "slice", "sorted", "staticmethod", "str", "sum", "super",
			"try", "tuple", "type",
			"unichr", "unicode",
			"vars",
			"with", "while",
			"yield",
			"zip",
			"__import__",
			"True", "False", "None",
			"rule", "parserRule")]/..' | trcaret
		cat o.pt | trxgrep '
			//RULE_REF[text() = (
			"state", "_ctx", "_errHandler", "__syntaxErrors",
			"setTrace", "_precedenceStack", "_precedenceStack", "_interp",
			"type", "consume", "buildParseTrees",
			"enterEveryRule", "visitTerminal", "visitErrorNode", "exitEveryRule",
			"reset", "match", "matchWildcard", "getParseListeners", "addParseListener",
			"removeParseListener", "removeParseListeners", "triggerEnterRuleEvent",
			"triggerExitRuleEvent", "getNumberOfSyntaxErrors", "getTokenFactory",
			"setTokenFactory", "getATNWithBypassAlts", "compileParseTreePattern",
			"getInputStream", "setInputStream", "getTokenStream", "setTokenStream",
			"getCurrentToken", "notifyErrorListeners", "addContextToParseTree",
			"enterRule", "exitRule", "enterOuterAlt", "getPrecedence", "enterRecursionRule",
			"pushNewRecursionContext", "unrollRecursionContexts", "getInvokingContext",
			"precpred", "inContext", "isExpectedToken", "getExpectedTokens",
			"getExpectedTokensWithinCurrentRule", "getRuleIndex", "getRuleInvocationStack",
			"getDFAStrings", "dumpDFA", "getSourceName", "setTrace"
			)]/..' | trcaret
			
		rm -f o.pt
	fi
else
	echo No arguments were provided.
	echo Finding useless parentheses in grammars...
	for i in `find . -name desc.xml | grep -v Generated\*`
	do
		echo $i
		d=`dirname $i`
		pushd $d > /dev/null 2>&1
		if [ ! -z $(find . -maxdepth 1 -name '*.g4' -printf 1 -quit) ]
		then 
			trparse -l -t ANTLRv4 *.g4 2> /dev/null > o.pt
			if [ -f o.pt ] && [ -s o.pt ]
			then
				cat o.pt | trxgrep '
  					]' | trcaret
				rm -f o.pt
			fi
		fi
		popd > /dev/null 2>&1
	done
fi
