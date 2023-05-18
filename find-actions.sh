#
if [[ $# -gt 0 ]]
then
	echo Arguments were provided.
	echo Finding unused parser symbols in grammars...
	trparse -l -t ANTLRv4 $@ 2> /dev/null | trxgrep ' //actionBlock' | trcaret
else
	echo No arguments were provided.
	echo Finding unused parser symbols in grammars...
	for i in `find . -name desc.xml | grep -v Generated\*`
	do
		echo $i
		d=`dirname $i`
		pushd $d > /dev/null 2>&1
		if [ ! -z $(find . -maxdepth 1 -name '*.g4' -printf 1 -quit) ]
		then 
			# Parse all grammar files so that any imports can also be checked.
			trparse -l -t ANTLRv4 *.g4 2> /dev/null | trxgrep ' //actionBlock' | trcaret
		fi
		popd > /dev/null 2>&1
	done
fi
