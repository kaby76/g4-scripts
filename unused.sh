#
echo Finding unused parser symbols in grammars...
for i in `find . -name desc.xml | grep -v Generated\*`
do
  echo $i
  d=`dirname $i`
  pushd $d > /dev/null 2>&1
  # Parse all grammar files so that any imports can also be checked.
  trparse *.g4 2> /dev/null | trxgrep ' //parserRuleSpec[not(doc("*")//ruleBlock//RULE_REF/text() = ./RULE_REF/text()) and not(./ruleBlock//TOKEN_REF/text() = "EOF")]/RULE_REF' | trtext
  popd > /dev/null 2>&1
done
