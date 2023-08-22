#

if [[ $# -gt 0 ]]
then
	echo Arguments were provided.
	echo Converting bison grammar.
	trparse -l $@ 2> /dev/null | \
		trquery -i '
			delete "//input_/prologue_declarations";
			delete "//input_/PercentPercent";
			delete "//input_/epilogue_opt";
			delete "//BRACED_CODE";' | \
		trtext
fi
