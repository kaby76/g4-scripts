if [[ $# -gt 0 ]]
then
    echo Finding direct left recursive symbols in grammars... 1>&2
    trparse -l -t ANTLRv4 $@ 2> /dev/null | \
        trxgrep ' //parserRuleSpec[RULE_REF/text() = ruleBlock/ruleAltList/labeledAlt/alternative/*[name()="element"][1]/atom/ruleref/*[1]/text()]' | trcaret
else
    echo Finding direct left recursive symbols in grammars... 1>&2
    for i in `find . -name desc.xml | grep -v Generated\*`
    do
        echo $i
        d=`dirname $i`
        pushd $d > /dev/null 2>&1
        if [ ! -z $(find . -maxdepth 1 -name '*.g4' -printf 1 -quit) ]
        then 
            # Parse all grammar files so that any imports can also be checked.
            trparse -l -t ANTLRv4 *.g4 2> /dev/null | \
		        trxgrep ' //parserRuleSpec[RULE_REF/text() = ruleBlock/ruleAltList/labeledAlt/alternative/*[name()="element"][1]/atom/ruleref/*[1]/text()]' | trcaret
        fi
        popd > /dev/null 2>&1
    done
fi
