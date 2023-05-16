#
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
  trparse *.g4 2> /dev/null | trfoldlit | trsponge -c true 2> /dev/null
  trparse *.g4 2> /dev/null | \
	trxgrep ' //lexerRuleSpec[
		not(doc("*")//ruleBlock//TOKEN_REF/text() = ./TOKEN_REF/text())
		and not(doc("*")//lexerRuleBlock//TOKEN_REF/text() = ./TOKEN_REF/text())
		and not(./lexerRuleBlock//lexerCommands)
		]/TOKEN_REF' | \
	trtext
  popd > /dev/null 2>&1
done
