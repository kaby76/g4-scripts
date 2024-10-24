#
# set -e
export MSYS2_ARG_CONV_EXCL="*"
where=`dirname -- "$0"`
cd "$where"
where=`pwd`
cd "$where"
echo "$where"
cd "$where"
failed=0
dotnet tool restore
for t in grammars/*.g4
do
	bash ../find-useless-parentheses.sh $t
	if [ $? -ne 0 ]
	then
		echo Test "'bash ../find-useless-parentheses.sh $t'" failed.
		failed=1
	fi
done
if [ $failed -ne 0 ]
then
	exit 1
else
	exit 0
fi
