#

while getopts 'xh' opt; do
    case "$opt" in
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
    trparse -t ANTLRv4 ${files[@]} > $temp
else
    cat - > $temp
fi

cat $temp | trquery delete '
        (: Find all blocks... :)
        //(block[
            (: except not one of these ... :)
            not(./parent::ebnf/blockSuffix and ./altList/OR) and
            not(./parent::ebnf/blockSuffix and count(./altList/alternative/element) > 1) and
            not(./altList/OR and ../../following-sibling::element) and
            not(./altList/OR and ../../preceding-sibling::element) and
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

if [ ${#files[@]} -gt 0 ]
then
    cat $temp2 | trsponge -c
else
    cat $temp2 | trtext
fi
	    
rm -f $temp $temp2
