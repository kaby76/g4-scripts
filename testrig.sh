#

while getopts 'xv:s:g:' opt; do
    case "$opt" in
    v)
        v="${OPTARG}"
        vv="-v $v"
        ;;
    s)
        start="${OPTARG}"
        ;;
    g)
        grammar="${OPTARG}"
        ;;
    x)
        set -x
        ;;
    ?|h)
        cat - <<EOF
NAME
       testrig - test Antlr4 grammars using org.antlr.v4.gui.TestRig

SYNOPSIS
       $(basename $0) ([-g ... | -s ... | -v ... | -x ])* [test-file]

DESCRIPTION
       Tests Antlr4 grammars. Assumes a standardized grammar start rule, combined
       or split grammar, no preprocessor grammars. This script must be run under
	   Linux Bash or Windows MSYS2 Bash. Requirements: dotnet, git, bash, JavaSDK,
	   antlr4-tools. If the grammar is not in a clone of https://github.com/antlr/grammars-v4
	   then the Trash toolkit will also need to be installed.

OPTIONS
    -g
        Specifies the grammar name. For split grammar, do not include "Parser" in the
        name. Do not include ".g4" in the name.
    -s
        Specifies the start rule if the script cannot find the correct start rule.
    -v
        Specifies the Antlr version, e.g., "4.12.0". Without the option, the latest
        is used.
    -x
        Execute "set -x" to debug script.
EOF
        exit 0
        ;;
    esac
done
shift $((OPTIND - 1))
files="$@"

assumptions_failed=0

# git must be installed.
# This is needed to clean up the mess created by this script.
command -v git
if [ $? -eq 1 ]; then
    echo git not installed.
    assumptions_failed=1
fi

# JavaSDK must be installed.
# We cannot compile and run a Java program without it.
command -v javac
if [ $? -eq 1 ]; then
    echo JavaSDK not installed.
    assumptions_failed=1
fi

# antlr4 tool must be installed.
# We use the antlr4-tools to run the Antlr4 tool,
# and referemce on executing the java program.
command -v antlr4
if [ $? -eq 1 ]; then
    echo antlr4-tools not installed.
    assumptions_failed=1
fi

# dotnet must be installed.
# We need the Trash toolkit to extract the
# start rule and grammar name from the grammar.
command -v dotnet
if [ $? -eq 1 ]; then
    echo dotnet sdk not installed.
    assumptions_failed=1
fi

# Ideally, this grammar is in a clone of
# https://github.com/antlr/grammars-v4. That is because
# the Trash toolkit is installed locally, and there would
# be nothing more to install. But, we'd like to handle
# grammars outside this structure. In that case, we'd need
# a global install of the Trash toolkit. Let's test on
# how to call the toolkit.
local_kit=1
dotnet tool restore | grep 'Cannot find a manifest file'
if [ $? -ne 1 ]
then
	# Try global Trash toolkit.
	command -v trparse
	if [ $? -ne 0 ]
	then
		echo "You do not have a local cache tool .config directory"
		echo "and neither a global cache of the Trash toolkit."
		echo "You can install the local cache by copying"
		echo "https://github.com/antlr/grammars-v4/tree/master/.config here"
		echo "or installing the Trash toolkit globally,"
		echo "https://github.com/kaby76/Domemtech.Trash#installation"
		echo "then trying this over."
	    assumptions_failed=1
	else
		local_kit=0
	fi
fi

if [ $assumptions_failed -eq 1 ]
then
    exit 1
fi

#
java=java
javac=javac

# Get current version of Antlr.
if [ "$v" == "" ]
then
    v=`antlr4 | grep 'ANTLR Parser Generator  Version' | awk '{print $5}'`
    vv="-v $v"
fi

# Get grammar name.
if [ "$grammar" == "" ]
then
	if [ $local_kit -eq 1 ]
	then
	    grammar_before_mod=(`dotnet trparse -- *.g4 2> /dev/null | dotnet trxgrep -- ' //grammarSpec/grammarDecl[not(grammarType/LEXER)]/identifier/(TOKEN_REF | RULE_REF)/text()'`)
	else
	    grammar_before_mod=(`trparse *.g4 2> /dev/null | trxgrep ' //grammarSpec/grammarDecl[not(grammarType/LEXER)]/identifier/(TOKEN_REF | RULE_REF)/text()'`)
	fi
    if [ ${#grammar_before_mod[@]} -ne 1 ]; then
        echo "Grammar name cannot be determined. ${grammar[@]}"
        exit 1
    fi
	grammar=`echo -n $grammar_before_mod | sed 's/Parser$//'`
fi
echo "Grammar $grammar"

# Get start symbol. The grammar helps disambiguate the start rule to
# choose.
if [ "$start" == "" ]
then
	if [ $local_kit -eq 1 ]
	then
	    start=(`dotnet trparse -- *.g4 2> /dev/null | dotnet trxgrep -- '
		    /grammarSpec[grammarDecl[not(grammarType/LEXER)]/identifier/(TOKEN_REF | RULE_REF)/text() = "'$grammar_before_mod'"]
	        //parserRuleSpec[ruleBlock//TOKEN_REF/text()="EOF"]/RULE_REF/text()' | tr -d '\r'`)
	else
	    start=(`trparse *.g4 2> /dev/null | trxgrep '
		    /grammarSpec[grammarDecl[not(grammarType/LEXER)]/identifier/(TOKEN_REF | RULE_REF)/text() = "'$grammar_before_mod'"]
	        //parserRuleSpec[ruleBlock//TOKEN_REF/text()="EOF"]/RULE_REF/text()' | tr -d '\r'`)
	fi
    if [ ${#start[@]} -ne 1 ]; then
        echo "Start rule cannot be determined. ${start[@]}"
        exit 1
    fi
fi
echo "Start $start"

# Generate parser and lexer from grammars.
antlr4 $vv *.g4
if [ $? -ne 0 ]
then
    echo antlr4 failed.
    exit 1
fi

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac

# Set up m2 directory, which is where Antlr jar will be.
if [[ "$machine" == "MinGw" || "$machine" == "Msys" ]]
then
    m2=$USERPROFILE/.m2
    sep=";"
else
    m2=~/.m2
    sep=":"
fi

# Find Antlr jar.
a=`find $m2 -name '*-complete.jar' | fgrep "/$v/"`
echo "Antlr $a"

# Add Java sources if the Java directory is present.
if [ -d Java ]
then
    morejava="Java/*.java"
else
    morejava=""
fi

# Compile.
$javac -cp ".$sep$a" *.java $morejava

# Test.
$java -cp ".$sep$a""$sep""Java/" org.antlr.v4.gui.TestRig $grammar $start -gui -tree $files

# Clean up.
git clean -f .

# This clean up might be overkill because 'git clean -f .' should have
# removed everything, at least if it was not on the .gitignore list.
# Those files are never removed by git.
# At least make sure to remove everything that the Antlr tool generates
# (some of which are not listed as being generated by the tool such as
# the .tokens and .interp files) and the Java compiler output.
rm -f `antlr4 -depend *.g4 | awk '{print $1}'`
rm -f *.tokens *.interp *.class
