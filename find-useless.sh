#!/bin/bash
main() {
    if [[ $# -gt 0 ]]
    then
        dotnet trparse -- -l -t ANTLRv4 $@ > o.pt
#        if [ -f o.pt ] && [ -s o.pt ]
#        then
            compute
#            rm -f o.pt
#        fi
    else
        for i in `find . -name desc.xml | grep -v Generated\*`
        do
            d=`dirname $i`
            pushd $d > /dev/null 2>&1
            if [ ! -z $(find . -maxdepth 1 -name '*.g4' -printf 1 -quit) ]
            then 
#                dotnet trparse -- -l -t ANTLRv4 *.g4 2> /dev/null > o.pt
		echo running parser and computing useless parentheses.
                dotnet trparse -- -l -t ANTLRv4 *.g4 > o.pt
#                if [ -f o.pt ] && [ -s o.pt ]
#                then
                    compute
#                    rm -f o.pt
#                fi
            fi
            popd > /dev/null 2>&1
        done
    fi
}

compute() {
    cat o.pt | dotnet trxgrep -- '
        (: Find all blocks... :)
        //block[
            (: except not one of these ... :)
            not(./parent::ebnf/blockSuffix and ./altList/OR) and
            not(./parent::ebnf/blockSuffix and count(./altList/alternative/element) > 1) and
            not(./altList/OR and ../../following-sibling::element) and
            not(./altList/OR and ../../preceding-sibling::element) and
            not(./parent::labeledElement/(ASSIGN or PLUS_ASSIGN))
            ]' | dotnet trcaret -- -H > up-output.txt
    cat o.pt | dotnet trxgrep -- '
        (: Find all blocks... :)
        //lexerBlock[
            (: except not one of these ... :)
            not(./parent::lexerElement/ebnfSuffix and ./lexerAltList/OR) and
            not(./parent::lexerElement/ebnfSuffix and count(./lexerAltList/lexerAlt/lexerElements/lexerElement) > 1) and
            not(./lexerAltList/OR and ../following-sibling::lexerElement) and
            not(./lexerAltList/OR and ../preceding-sibling::lexerElement) and
(:          not(./parent::lexerElement/ebnfSuffix and ./lexerAltList/lexerAlt/lexerElements/lexerElement/lexerAtom/characterRange) and :)
            not(count(./lexerAltList/lexerAlt) > 1 and ../../../lexerCommands) and
            not(./parent::labeledLexerElement/(ASSIGN or PLUS_ASSIGN))
            ]' | dotnet trcaret -- -H >> up-output.txt
    cat o.pt | dotnet trxgrep -- '
        (: Find all blockSets... :)
        //blockSet[
            (: except not one of these ... :)
            not(./OR)
            ]' | dotnet trcaret -- -H >> up-output.txt
	if [ -s up-output.txt ]
	then
	    echo Found useless parentheses in grammars...  1>&2
		cat up-output.txt 1>&2
	fi
	rm -f up-output.txt
}

main $@
