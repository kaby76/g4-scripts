#
# set -e
export MSYS2_ARG_CONV_EXCL="*"
where=`dirname -- "$0"`
cd "$where"
where=`pwd`
cd "$where"
echo "$where"
cd "$where"
bash ../find-useless-parentheses.sh grammars/Up1.g4
if [ $? -ne 0 ]
then
	echo Test "'bash ../find-useless-parentheses.sh grammars/Up1.g4'" failed.
	exit 1
else
	exit 0
fi
