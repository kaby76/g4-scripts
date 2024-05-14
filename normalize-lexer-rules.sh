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
       $(basename $0) -- rename lexer rule names using standardized Unicode names

SYNOPSIS
       $(basename $0) ([-x | -h])* [grammar-files]

DESCRIPTION
       Renames lexer rule names using the standard Unicode name in an Antlr4 grammar.

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
	//lexerRuleSpec
	/lexerRuleBlock
 	/lexerAltList[not(OR)]
        /lexerAlt[not(lexerCommands)]
	/lexerElements[count(*)=1]
	/lexerElement[not(ebnfSuffix)]
	/lexerAtom
	/terminalDef[not(elementOptions)]
	/STRING_LITERAL[string-length(.) < 4]
	/text()' | sed "s/^'//" | sed "s/'$//" > chars.txt

cat $temp | trxgrep -e '
	//lexerRuleSpec
	[
	lexerRuleBlock
	/lexerAltList[not(OR)]
        /lexerAlt[not(lexerCommands)]
	/lexerElements[count(*)=1]
	/lexerElement[not(ebnfSuffix)]
	/lexerAtom
	/terminalDef[not(elementOptions)]
	/STRING_LITERAL[string-length(.) < 4]]
	/TOKEN_REF
	/text()' > original_names.txt

if [ `wc -l original_names.txt | awk '{print $1}'` -ne 0 ]
then
	if [ `wc -l original_names.txt | awk '{print $1}'` -eq `wc -l chars.txt | awk '{print $1}'` ]
	then
		rm -f new_names.txt
		for i in `cat chars.txt | tr -d '\n' | od -t x1 | cut -c 8-`
		do
			name=`grep "^00${i^^}" $full_path_script_dir/UCD/NamesList.txt | cut -c 6- | sed 's/ /_/g' | sed 's/-/_/g'`
			echo $name >> new_names.txt
		done
	fi
	paste original_names.txt new_names.txt | tr -d '\r' | tr '\t' ',' > renames.txt

	echo ""
	echo Renaming lexer symbols ...
	cat $temp | trrename -R renames.txt | trsponge -c

	echo ""
	echo Unfold string literals into all parser rules ...
	$full_path_script_dir/unfold-string-literals.sh $optx ${files[@]}

	echo ""
	echo Removing unused parentheses ...
	$full_path_script_dir/delete-useless-parentheses.sh $optx ${files[@]}

	echo ""
	echo Done.
fi
rm -f renames.txt original_names.txt new_names.txt chars.txt $temp
