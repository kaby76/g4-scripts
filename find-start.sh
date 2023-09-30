#!/usr/bin/bash

while getopts 'xv:s:g:' opt; do
    case "$opt" in
    x)
        set -x
        ;;
    ?|h)
        cat - <<EOF
NAME
       find-start - find the start rule in an Antlr4 grammar

SYNOPSIS
       $(basename $0) ([-x | -h])* [grammar-files]

DESCRIPTION
       Finds the start rule in an Antlr4 grammar. It also tests for unusual situations
       in the grammar that should be corrected.

       This script must be run under Linux Bash or Windows MSYS2 Bash or Windows WSL Linux.

OPTIONS
    -h
        Output this help message.
    -x
        Execute "set -x" to debug script.

EXAMPLE USAGE
    git clone https://github.com/antlr/grammars-v4.git
    cd grammars-v4/abb
    find-start *.g4
    cd ../java/java20
    cat *.g4 | find-start

EOF
        exit 0
        ;;
    esac
done
shift $((OPTIND - 1))
files="$@"

temp=`mktemp`
if [ ${#files[@]} -gt 0 ]
then
    trparse -t ANTLRv4 ${files[@]} > $temp
else
    cat - > $temp
fi

count=`cat $temp | trxgrep ' //parserRuleSpec//alternative/element[.//TOKEN_REF/text()="EOF"]/following-sibling::element' | trtext -c`
if [ "$count" != "0" ]
then
    echo $i has an EOF usage followed by another element.
fi

count=`cat $temp | trxgrep ' //labeledAlt[.//TOKEN_REF/text()="EOF" and count(../labeledAlt) > 1]' | trtext -c`
if [ "$count" != "0" ]
then
    echo $i has an EOF in one alt, but not in another.
fi

start=(`trparse -- *.g4 2> /dev/null | trxgrep -- '
    /grammarSpec[grammarDecl[not(grammarType/LEXER)]]
    //parserRuleSpec[ruleBlock//TOKEN_REF/text()="EOF"]/RULE_REF/text()' | tr -d '\r'`)
echo "Start rules:" 1>&2
echo ${start[@]}
