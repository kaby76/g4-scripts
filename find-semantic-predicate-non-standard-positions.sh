#
if [[ $# -gt 0 ]]
then
	echo Finding actions in grammars... >&2
	dotnet trparse -l -t ANTLRv4 $@ | \
	dotnet trquery grep ' //actionBlock[following-sibling::QUESTION and not ./self[1] ]' | \
	dotnet trcaret
else
	echo Finding actions in grammars... >&2
	for i in `find . -name desc.xml | grep -v Generated\*`
	do
		echo $i
		d=`dirname $i`
		pushd $d > /dev/null 2>&1
		if [ ! -z $(find . -maxdepth 1 -name '*.g4' -printf 1 -quit) ]
		then 
			# Parse all grammar files so that any imports can also be checked.
			dotnet trparse -l -t ANTLRv4 *.g4 2> /dev/null | \
			dotnet trxgrep ' //actionBlock[following-sibling::QUESTION]' | \
			dotnet trcaret
		fi
		popd > /dev/null 2>&1
	done
fi
