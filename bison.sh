#

if [[ $# -gt 0 ]]
then
	trparse $@ 2> /dev/null | \
		trquery '
			delete //input_/prologue_declarations;
			delete //input_/PercentPercent;
			delete //input_/epilogue_opt;
			delete //BRACED_CODE;
			delete //actionBlock;
			delete //epilogue_opt;'
fi
