#
if [[ $# -gt 0 ]]
then
	echo Arguments were provided.
	echo Finding unused lexer symbols in grammars...
	rm -rf foobarfoobar
	mkdir foobarfoobar
	cp $@ foobarfoobar
	cd foobarfoobar
	echo 1st pass: fold string literals in parser rules to make explicit lexer rule used.
	dotnet trparse -- *.g4 2> /dev/null | dotnet trfoldlit | dotnet trsponge -- -c true 2> /dev/null
	echo 2nd pass: find unreferenced lexer rule symbols.
	dotnet trparse -- *.g4 2> /dev/null | \
		dotnet trxgrep -- ' //lexerRuleSpec[
			not(doc("*")//ruleBlock//TOKEN_REF/text() = ./TOKEN_REF/text())
			and not(doc("*")//lexerRuleBlock//TOKEN_REF/text() = ./TOKEN_REF/text())
			and not(./lexerRuleBlock//lexerCommands)
			]/TOKEN_REF' | \
		dotnet trtext
	cd ..
	rm -rf foobarfoobar
else
	echo No arguments were provided.
	echo Finding unused lexer symbols in grammars...
	for i in `find . -name desc.xml | grep -v Generated\*`
	do
		echo $i
		d=`dirname $i`
		pushd $d > /dev/null 2>&1
		# Parse all grammar files so that any imports can also be checked.
		rm -rf foobarfoobar
		mkdir foobarfoobar
		cp *.g4 foobarfoobar
		cd foobarfoobar
		echo 1st pass: fold string literals in parser rules to make explicit lexer rule used.
		dotnet trparse -- *.g4 2> /dev/null | dotnet trfoldlit | dotnet trsponge -- -c true 2> /dev/null
		echo 2nd pass: find unreferenced lexer rule symbols.
		dotnet trparse -- *.g4 2> /dev/null | \
			dotnet trxgrep -- ' //lexerRuleSpec[
			not(doc("*")//ruleBlock//TOKEN_REF/text() = ./TOKEN_REF/text())
			and not(doc("*")//lexerRuleBlock//TOKEN_REF/text() = ./TOKEN_REF/text())
			and not(./lexerRuleBlock//lexerCommands)
			]/TOKEN_REF' | \
		dotnet trtext
		cd ..
		rm -rf foobarfoobar
		popd > /dev/null 2>&1
	done
fi
