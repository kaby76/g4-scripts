#

test=0
while getopts 'htx' opt; do
    case "$opt" in
    t)
        test=1
        ;;
    x)
        set -x
        ;;
    ?|h)
        cat - <<EOF
NAME
       $(basename $0) - delete useless parentheses in an Antlr4 grammar

SYNOPSIS
       $(basename $0) ([-x | -h])* [grammar-files]

DESCRIPTION
       Delete useless parentheses in an Antlr4 grammar.

       This script must be run under Linux Bash or Windows MSYS2 Bash or Windows WSL Linux.

OPTIONS
    -h
        Output this help message.
    -t
        Test first and display using trcaret.
    -x
        Execute "set -x" to debug script.

EXAMPLE USAGE
    git clone https://github.com/antlr/grammars-v4.git
    cd grammars-v4/abb
    $(basename $0) *.g4
    cd ../java/java20
    trparse *.g4 | $(basename $0)

EOF
        exit 0
        ;;
    esac
done
shift $((OPTIND - 1))
files=("$@")
temp=`mktemp`
temp2=`mktemp`
if [ ${#files[@]} -gt 0 ]
then
    if [ $test -eq 1 ]
    then
        trparse -l -t ANTLRv4 ${files[@]} > $temp
    else
        trparse -t ANTLRv4 ${files[@]} > $temp
    fi
else
    cat - > $temp
fi

if [ $test -eq 0 ]
then
    command="trquery delete"
else
    command="trxgrep"
fi
cat $temp | $command '
        (: Find all blocks... :)
        //(block[
            (: except not one of these ... :)

            (: do not flag "a ( b | c )* d" or with other operator :)
            not(./parent::ebnf/blockSuffix and ./altList/OR) and

            (: do not flag "(a ( b | c )* )?" because it is not the same as the '*?'-operator. :)
            not(./parent::ebnf/blockSuffix/ebnfSuffix/QUESTION and ./altList[count(./*) = 1]/alternative[count(./*) = 1]/element[count(./*) = 1]/ebnf[./block and ./blockSuffix/ebnfSuffix/*]) and

            (: do not flag blocks that contain a lot of elements like "(a b c)*" :)
            not(./parent::ebnf/blockSuffix and count(./altList/alternative/element) > 1) and

            (: do not flag if there are alts *and* it is preceed or followed by an element,
               e.g., "a (b | c d)" or "(a | b) c". :)
            not(./altList/OR and ../../following-sibling::element) and
            not(./altList/OR and ../../preceding-sibling::element) and

            (: do not flag "a ( v += b )* c" or with other operator :)
            not(./altList/alternative/element/labeledElement/(ASSIGN or PLUS_ASSIGN) and ./parent::ebnf/blockSuffix) and

            not(./parent::labeledElement/(ASSIGN or PLUS_ASSIGN))
            ]
	|
        lexerBlock[
            (: except not one of these ... :)
            not(./parent::lexerElement/ebnfSuffix and ./lexerAltList/OR) and
            not(./parent::lexerElement/ebnfSuffix and count(./lexerAltList/lexerAlt/lexerElements/lexerElement) > 1) and
            not(./lexerAltList/OR and ../following-sibling::lexerElement) and
            not(./lexerAltList/OR and ../preceding-sibling::lexerElement) and
(:          not(./parent::lexerElement/ebnfSuffix and ./lexerAltList/lexerAlt/lexerElements/lexerElement/lexerAtom/characterRange) and :)
            not(count(./lexerAltList/lexerAlt) > 1 and ../../../lexerCommands) and
            not(./parent::labeledLexerElement/(ASSIGN or PLUS_ASSIGN))
            ]
	|
        blockSet[
            (: except not one of these ... :)
            not(./OR)
            ])/(LPAREN | RPAREN)' > $temp2

if [ $test -eq 0 ]
then
	if [ ${#files[@]} -gt 0 ]
	then
	    cat $temp2 | trsponge -c
	else
	    cat $temp2 | trtext
	fi
else
    cat $temp2 | trcaret
fi
rm -f $temp $temp2
