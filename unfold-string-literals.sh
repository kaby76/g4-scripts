#

while getopts 'xh' opt; do
    case "$opt" in
    x)
        set -x
	optx="-x"
        ;;
    ?|h)
        cat - <<EOF
NAME
       $(basename $0) -- unfold lexer rules for string literals

SYNOPSIS
       $(basename $0) ([-x | -h])* [grammar-files]

DESCRIPTION
       Unfold lexer rules for string literals in an Antlr4 grammar. The string literal
       must appear in a lexer rule.

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
if [ ${#files[@]} -gt 0 ]
then
    trparse -t ANTLRv4 ${files[@]} > $temp
else
    cat - > $temp
fi

# Get full path of this script.
full_path_script=$(realpath $0)
full_path_script_dir=`dirname $full_path_script`

cat $temp | trxgrep -e '
	//lexerRuleSpec[
	not(FRAGMENT) and
	lexerRuleBlock
	/lexerAltList[not(OR)]
        /lexerAlt[not(lexerCommands)]
	/lexerElements[count(*)=1]
	/lexerElement[not(ebnfSuffix)]
	/lexerAtom
	/terminal[not(elementOptions)]]/TOKEN_REF/text()' | sed 's/^/"/' | sed 's/$/",/' | tr -d '\n' | tr -d '\r' > rule_names.txt

cat $temp | trunfold ' //parserRuleSpec/ruleBlock//terminal/TOKEN_REF[text()= ('`cat rule_names.txt`'"")]' | trsponge -c

rm -f $temp rule_names.txt
