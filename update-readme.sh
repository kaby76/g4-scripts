#
echo Updating readme.md for grammars...

if [[ $# -gt 0 ]]
then
	echo Arguments were provided.
	action=`trparse -l -t ANTLRv4 *.g4 2> /dev/null | trxgrep ' //actionBlock' | trtext -c`
	
else
	echo No arguments were provided.
	for i in `find . -name desc.xml | grep -v Generated\*`
	do
		echo $i
		d=`dirname $i`
		pushd $d > /dev/null 2>&1
		if [ ! -z $(find . -maxdepth 1 -name '*.g4' -printf 1 -quit) ]
		then 
			action=`trparse -l -t ANTLRv4 *.g4 2> /dev/null | trxgrep ' //actionBlock' | trtext -c`
		fi
		popd > /dev/null 2>&1
	done
fi
