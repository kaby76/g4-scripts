#!/usr/bin/bash

for i in `find . -name '*.g4' | grep -v Generated | grep -v examples | grep -v Lexer`
do
 count=`trparse $i 2> /dev/null \
  | trxgrep ' //parserRuleSpec//alternative/element[.//TOKEN_REF/text()="EOF"]/following-sibling::element' \
  | trtext -c`
 if [ "$count" != "0" ]
 then
  echo $i has an EOF usage followed by another element.
 fi
 count=`trparse $i 2> /dev/null \
  | trxgrep ' //labeledAlt[.//TOKEN_REF/text()="EOF" and count(../labeledAlt) > 1]' \
  | trtext -c`
 if [ "$count" != "0" ]
 then
  echo $i has an EOF in one alt, but not in another.
 fi
done

