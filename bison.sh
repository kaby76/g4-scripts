#

if [[ $# -gt 0 ]]
then
	dotnet trparse -t Bison $@ 2> /dev/null | dotnet trquery 'delete //(input_/(prologue_declarations | PercentPercent | epilogue_opt) | BRACED_CODE | actionBlock | epilogue_opt);' | dotnet trsponge -c
fi
