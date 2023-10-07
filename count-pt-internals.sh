#

while getopts 'xv:s:g:' opt; do
    case "$opt" in
    x)
        set -x
        ;;
    ?|h)
        cat - <<EOF
NAME
       $(basename $0) - Count the number of internal nodes of a parse tree.

SYNOPSIS
       $(basename $0) ([-x | -h])* [input-files]

DESCRIPTION
       Counts the number of internal nodes of an Antlr4 parse tree.

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
files=("$@")

temp=`mktemp`
if [ ${#files[@]} -gt 0 ]
then
    trparse -t ANTLRv4 ${files[@]} > $temp
else
    cat - > $temp
fi

count=(`cat $temp | trxgrep ' //grammarSpec/grammarDecl[not(grammarType/LEXER)]//parserRuleSpec//alternative/element[.//TOKEN_REF/text()="EOF"]/following-sibling::element' | trtext -c`)
if [ ${#count[@]} -gt 0 ]
then
	for i in ${count[@]}
	do
		echo $i | grep -e ':' > /dev/null 2>&1
		if [ $? -eq 0 ]
		then		
			j=`echo $i | awk -F: '{print $2}'`
		else
			j=$i
		fi
		if [ "$j" != "0" ]
		then
		    echo $j has an EOF usage followed by another element.
		fi
	done
fi

trxgrep ' count(//*/name()[
		starts-with(.,"a") or
		starts-with(.,"b") or
		starts-with(.,"c") or
		starts-with(.,"d") or
		starts-with(.,"e") or
		starts-with(.,"f") or
		starts-with(.,"g") or
		starts-with(.,"h") or
		starts-with(.,"i") or
		starts-with(.,"j") or
		starts-with(.,"k") or
		starts-with(.,"l") or
		starts-with(.,"m") or
		starts-with(.,"n") or
		starts-with(.,"o") or
		starts-with(.,"p") or
		starts-with(.,"q") or
		starts-with(.,"r") or
		starts-with(.,"s") or
		starts-with(.,"t") or
		starts-with(.,"u") or
		starts-with(.,"v") or
		starts-with(.,"w") or
		starts-with(.,"x") or
		starts-with(.,"y") or
		starts-with(.,"z")
		])'
