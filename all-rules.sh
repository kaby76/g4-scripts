#

echo "Usage: start-symbol grammar-file-name" >2
echo "Finds the transitive closure of a rule in a parser grammar." >2
sym=$1
todo=($sym)
grammar=$2
visited=()
trparse -t ANTLRv4 $grammar > o.pt
while true
do
	if [ ${#todo[@]} -eq 0 ]; then
		break
	fi
	sym=${todo[0]}
	todo=("${todo[@]:1}")
	syms=`cat o.pt | trxgrep ' //parserRuleSpec[RULE_REF/text() = "'$sym'"]//atom/ruleref/RULE_REF' | trtext | dos2unix`
	for f in ${syms[*]}
	do
		if [[ ! $(echo ${visited[@]} | fgrep -w $f) ]]
		then
			visited[${#visited[@]}]=$f
			todo[${#todo[@]}]=$f
		fi
	done
done
for f in ${visited[*]}
do
	echo "$f"
done
