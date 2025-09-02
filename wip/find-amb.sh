#

if [[ $# -gt 0 ]]
then
    echo Finding ambiguity in grammars... 1>&2
    dotnet trparse -l -t ANTLRv4 $@ 2> /dev/null | \
        dotnet trxgrep '
		//alternative[
			./element/atom//(TOKEN_REF | RULE_REF)/text() = following-sibling::*[1]/atom//(TOKEN_REF | RULE_REF)/text()
			and
			./ancestor::parserRuleSpec/RULE_REF/text() = ./atom//(TOKEN_REF | RULE_REF)/text()]/atom//(TOKEN_REF | RULE_REF)/text()
			]' | dotnet trcaret
else
    echo Finding ambiguity in grammars... 1>&2
    for i in `find . -name desc.xml | grep -v Generated\* | grep -v examples`
    do
        echo $i
        d=`dirname $i`
        pushd $d > /dev/null 2>&1
        if [ ! -z $(find . -maxdepth 1 -name '*.g4' -printf 1 -quit) ]
        then 
            # Parse all grammar files so that any imports can also be checked.
            dotnet trparse -l -t ANTLRv4 *.g4 2> /dev/null | \
		        dotnet trxgrep ' ' | dotnet trcaret
        fi
        popd > /dev/null 2>&1
    done
fi
