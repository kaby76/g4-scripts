#

if [[ $# -gt 0 ]]
then
    echo Finding bad EOF refs in lexer rules... 1>&2
    trparse -l -t ANTLRv4 $@ 2> /dev/null | \
        trxgrep '//lexerRuleSpec//TOKEN_REF[text() = "EOF"]' | trcaret
else
    echo Finding bad EOF refs in lexer rules... 1>&2
    for i in `find . -name desc.xml | grep -v Generated\* | grep -v examples`
    do
        echo $i
        d=`dirname $i`
        pushd $d > /dev/null 2>&1
        if [ ! -z $(find . -maxdepth 1 -name '*.g4' -printf 1 -quit) ]
        then 
            # Parse all grammar files so that any imports can also be checked.
	    trparse -l -t ANTLRv4 *.g4 2> /dev/null | \
	        trxgrep '//lexerRuleSpec//TOKEN_REF[text() = "EOF"]' | trcaret
        fi
        popd > /dev/null 2>&1
    done
fi
