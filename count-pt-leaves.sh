#

while getopts 'xh' opt; do
    case "$opt" in
    x)
        set -x
        ;;
    ?|h)
        cat - <<EOF
NAME
       count-lexers - count the number of lexer rules in an Antlr4 grammar

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
    count-lexers *.g4
    cd ../java/java20
    trparse *.g4 | count-lexers

EOF
        exit 0
        ;;
    esac
done
shift $((OPTIND - 1))
files=("$@")
temp=`mktemp`
if [ ${#files[@]} -gt 0 ]
then
    trparse -t ANTLRv4 ${files[@]} > $temp
else
    cat - > $temp
fi

cat $temp | trxgrep ' count(//*/name()[
		starts-with(.,"A") or
		starts-with(.,"B") or
		starts-with(.,"C") or
		starts-with(.,"D") or
		starts-with(.,"E") or
		starts-with(.,"F") or
		starts-with(.,"G") or
		starts-with(.,"H") or
		starts-with(.,"I") or
		starts-with(.,"J") or
		starts-with(.,"K") or
		starts-with(.,"L") or
		starts-with(.,"M") or
		starts-with(.,"N") or
		starts-with(.,"O") or
		starts-with(.,"P") or
		starts-with(.,"Q") or
		starts-with(.,"R") or
		starts-with(.,"S") or
		starts-with(.,"T") or
		starts-with(.,"U") or
		starts-with(.,"V") or
		starts-with(.,"W") or
		starts-with(.,"X") or
		starts-with(.,"Y") or
		starts-with(.,"Z")
		])'

rm -f $temp
		