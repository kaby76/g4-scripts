#

# This is a wrapper for TestRig that does some extra bookkeeping,
# which TestRig does not do:
#    * Allows one to use different version of Antlr4, automatically
#      downloading the desired version. This script uses the
#      antlr4-tools tool set.
#    * Extracts the grammar name and start rule name from the grammar
#      so you do not need to read the grammar to figure out these
#      values. It does this using the Trash toolkit.
#    * Runs the Antlr tool and compiles the generated Java code.
# 
# The options recognized here must be
# updated if the options for TestRig are changed.
# Here is what TestRig currently accepts.
# java org.antlr.v4.gui.TestRig GrammarName startRuleName
#   [-tokens] [-tree] [-gui] [-ps file.ps] [-encoding encodingname]
#   [-trace] [-diagnostics] [-SLL]
#   [input-filename(s)]

while getopts 'xv:s:g:-:' OPT; do
    if [ "$OPT" = "-" ]; then    # long option: reformulate OPT and OPTARG
        OPT="${OPTARG%%=*}"       # extract long option name
        OPTARG="${OPTARG#$OPT}"   # extract long option argument (may be empty)
        OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
    fi
    case "$OPT" in
    g)
        grammar="${OPTARG}"
        ;;
    s)
        start="${OPTARG}"
        ;;
    v)
        v="${OPTARG}"
        vv="-v $v"
        ;;
    x)
        set -x
        ;;
    gui)
        gui="-gui"
        ;;
    ps)
        ps="-ps ${OPTARG}"
        ;;
    encoding)
        encoding="-encoding ${OPTARG}"
        ;;
    trace)
        trace="-trace"
        ;;
    diagnostics)
        diagnostics="-diagnostics"
        ;;
    SLL)
        SLL="-SLL"
        ;;
    tree)
        tree="-tree"
        ;;
    tokens)
        tokens="-tokens"
        ;;
    ?|h)
        cat - <<EOF
NAME
       testrig - test Antlr4 grammars using org.antlr.v4.gui.TestRig

SYNOPSIS
       $(basename $0) ( -g ... | -s ... | -v ... | -x |
                --tokens | --tree | --gui | --ps file.ps | --encoding encodingname |
                --trace | --diagnostics | --SLL )* [test-file]

DESCRIPTION
       Tests Antlr4 grammars. Assumes a standardized grammar start rule, combined
       or split grammar, no preprocessor grammars. This script must be run under
       Linux Bash or Windows MSYS2 Bash. Requirements: dotnet, bash, OpenJDK,
       Python3, antlr4-tools. If the grammar is not in a clone of
       https://github.com/antlr/grammars-v4 then the Trash toolkit will also need to
       be installed. https://github.com/kaby76/Domemtech.Trash#installation

OPTIONS
    -g
        Specifies the grammar name. For split grammar, do not include "Parser" in the
        name. Do not include ".g4" in the name.
    -h
        Output this help message.
    -s
        Specifies the start rule if the script cannot find the correct start rule.
    -v
        Specifies the Antlr version, e.g., "4.12.0". Without the option, the latest
        is used.
    -x
        Execute "set -x" to debug script.

    Options that are passed to the TestRig program:

    --tokens
        Print the tokens of the input.

    --tree
        Print "ToStringTree" of the parse tree.

    --gui
        Open a GUI drawing of the parse tree.

    --ps file.ps
        Write the drawing of the parse tree in PostScript to a file.

    --encoding encodingname
        Set the input file encoding.

    --trace
        Set trace on the parse.

    --diagnostics
        Set diagnostics on the parse.

    --SLL
        Set SLL on the parse.


EXAMPLE USAGE
    git clone https://github.com/antlr/grammars-v4.git
    cd grammars-v4/abb
    testrig -gui examples/robdata.sys
    cd ../java/java20
    cat examples/helloworld.java | testrig -gui

EOF
        exit 0
        ;;
    esac
done
shift $((OPTIND - 1))
files="$@"

assumptions_failed=0

# Python must be installed.
# It's required for antlr4 of the antlr4-tools, but we'll
# test it here anyway.
command -v python > /dev/null 2>&1
if [ $? -eq 1 ]; then
    echo "Python is required."
    assumptions_failed=1
fi

# antlr4 tool must be installed.
# We use the antlr4-tools to run the Antlr4 tool,
# and referemce on executing the java program.
command -v antlr4 > /dev/null 2>&1
if [ $? -eq 1 ]; then
    echo "antlr4-tools not installed. https://github.com/antlr/antlr4-tools"
    assumptions_failed=1
fi

# dotnet must be installed.
# We need the Trash toolkit to extract the
# start rule and grammar name from the grammar.
command -v dotnet > /dev/null 2>&1
if [ $? -eq 1 ]; then
    echo "dotnet sdk not installed. https://dotnet.microsoft.com/en-us/"
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
dotnet tool restore | grep 'Cannot find a manifest file' > /dev/null 2>&1
if [ $? -ne 1 ]
then
    # Try global Trash toolkit.
    command -v trparse
    if [ $? -ne 0 ]
    then
        cat - <<EOF
You do not have a local cache tool .config directory
and neither a global cache of the Trash toolkit.
You can install the local cache by copying
https://github.com/antlr/grammars-v4/tree/master/.config here
or installing the Trash toolkit globally,
https://github.com/kaby76/Domemtech.Trash#installation
then trying this over.
EOF
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
        grammar_before_mod=(`dotnet trparse -- -t ANTLRv4 *.g4 2> /dev/null | dotnet trxgrep -- ' //grammarSpec/grammarDecl[not(grammarType/LEXER)]/identifier/(TOKEN_REF | RULE_REF)/text()' | tr -d '\r'`)
    else
        grammar_before_mod=(`trparse -t ANTLRv4 *.g4 2> /dev/null | trxgrep ' //grammarSpec/grammarDecl[not(grammarType/LEXER)]/identifier/(TOKEN_REF | RULE_REF)/text()' | tr -d '\r'`)
    fi
    if [ ${#grammar_before_mod[@]} -gt 1 ]; then
        echo "Grammar name cannot be determined. Possible grammar names are: ${grammar_before_mod[@]}"
        exit 1
    fi
    if [ ${#grammar_before_mod[@]} -eq 0 ]; then
        echo "Grammar name cannot be determined."
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
        start=(`dotnet trparse -- -t ANTLRv4 *.g4 2> /dev/null | dotnet trxgrep -- '
            /grammarSpec[grammarDecl[not(grammarType/LEXER)]/identifier/(TOKEN_REF | RULE_REF)/text() = "'$grammar_before_mod'"]
            //parserRuleSpec[ruleBlock//TOKEN_REF/text()="EOF"]/RULE_REF' | trtext | tr -d '\r'`)
    else
        start=(`trparse -t ANTLRv4 *.g4 2> /dev/null | trxgrep '
            /grammarSpec[grammarDecl[not(grammarType/LEXER)]/identifier/(TOKEN_REF | RULE_REF)/text() = "'$grammar_before_mod'"]
            //parserRuleSpec[ruleBlock//TOKEN_REF/text()="EOF"]/RULE_REF' | trtext | tr -d '\r'`)
    fi
    if [ ${#start[@]} -ne 1 ]; then
        echo "Start rule cannot be determined. ${start[@]}"
        exit 1
    fi
fi
echo $start | grep -e ':' > /dev/null 2>&1
if [ $? -eq 0 ]
then        
    start=`echo $start | awk -F: '{print $2}'`
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
$java -cp ".$sep$a""$sep""Java/" org.antlr.v4.gui.TestRig $grammar $start $tokens $tree $gui $ps $encoding $trace $diagnostics $SLL $files

# Clean up.

rm -f `antlr4 -depend *.g4 | awk '{print $1}'`
rm -f *.tokens *.interp *.class Java/*.class
