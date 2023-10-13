#

while getopts 'xh' opt; do
    case "$opt" in
    x)
        set -x
        ;;
    ?|h)
        cat - <<EOF
NAME
       $(basename $0) - get the depth of the deepest node in the parse tree

SYNOPSIS
       $(basename $0) ([-x | -h])* [files]

DESCRIPTION
       This script must be run under Linux Bash or Windows MSYS2 Bash or Windows WSL Linux.

OPTIONS
    -h
        Output this help message.
    -x
        Execute "set -x" to debug script.

EXAMPLE USAGE

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
    trparse -l ${files[@]} > $temp
else
    cat - > $temp
fi

# cat $temp | trxgrep ' //*[not(*) and count(ancestor::*) = max(//*[not(*)]/count(ancestor::*))]/(self::node|..)' | trcaret
cat $temp | trxgrep ' for $i in max(//*[not(*)]/count(ancestor::*))
    return
	(for $j in (//*[not(*) and count(ancestor::*) = $i])
	    return $j/(self::node|..))' | trcaret
rm -f $temp
