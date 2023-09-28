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
       or split grammar, no preprocessor grammars.

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

# git must be installed.
# This is needed to clean up the mess created by this script.
command -v git
if [ $? -eq 1 ]; then
    echo git not installed.
    exit 1
fi

# JavaSDK must be installed.
# We cannot compile and run a Java program without it.
command -v javac
if [ $? -eq 1 ]; then
    echo JavaSDK not installed.
    exit 1
fi

# antlr4 tool must be installed.
# We use the antlr4-tools to run the Antlr4 tool,
# and referemce on executing the java program.
command -v antlr4
if [ $? -eq 1 ]; then
    echo antlr4-tools not installed.
    exit 1
fi

# dotnet must be installed.
# We need the Trash toolkit to extract the
# start rule and grammar name from the grammar.
command -v dotnet
if [ $? -eq 1 ]; then
    echo dotnet sdk not installed.
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

# Assume this is in a cloned grammars-v4 repo.
# Get local Trash toolkit tools.
dotnet tool restore 1> /dev/null
if [ $? -ne 0 ]
then
    echo Trash toolkit restore is not working.
    dotnet tool restore
    exit 1
fi

# Get start symbol.
if [ "$start" == "" ]
then
    start=(`dotnet trparse -- *.g4 2> /dev/null | dotnet trxgrep -- ' //parserRuleSpec[ruleBlock//TOKEN_REF/text()="EOF"]/RULE_REF/text()' | tr -d '\r'`)
    if [ ${#start[@]} -ne 1 ]; then
        echo "Start rule cannot be determined. ${start[@]}"
        exit 1
    fi
fi
echo "Start $start"

# Get grammar name.
if [ "$grammar" == "" ]
then
    grammar=(`dotnet trparse -- *.g4 2> /dev/null | dotnet trxgrep -- ' //grammarSpec/grammarDecl[not(grammarType/LEXER)]/identifier/(TOKEN_REF | RULE_REF)/text()' | sed "s/Parser$//"`)
    if [ ${#grammar[@]} -ne 1 ]; then
        echo "Grammar name cannot be determined. ${start[@]}"
        exit 1
    fi
fi
echo "Grammar $grammar"

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
$java -cp ".$sep$a$sepJava/" org.antlr.v4.gui.TestRig $grammar $start -gui -tree $files

# Clean up.
git clean -f .
rm -f *.tokens
