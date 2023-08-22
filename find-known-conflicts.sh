#!/bin/bash
main() {
    echo Finding potential in grammars...
    if [[ $# -gt 0 ]]
    then
        trparse -l -t ANTLRv4 $@ 2> /dev/null > o.pt
        if [ -f o.pt ] && [ -s o.pt ]
        then
            dochecks
            rm -f o.pt
        fi
    else
        for i in `find . -name desc.xml | grep -v Generated\*`
        do
            echo ""
            echo $i
            d=`dirname $i`
            pushd $d > /dev/null 2>&1
            if [ ! -z $(find . -maxdepth 1 -name '*.g4' -printf 1 -quit) ]
            then 
                trparse -l -t ANTLRv4 *.g4 2> /dev/null > o.pt
                if [ -f o.pt ] && [ -s o.pt ]
                then
                    dochecks
                fi
            fi
            popd > /dev/null 2>&1
        done
    fi
}

dochecks() {
    dochecks_csharp
    dochecks_cpp
    dochecks_dart
    dochecks_go
    dochecks_java
    dochecks_javascript
    dochecks_php
    dochecks_python3
    dochecks_typescript
}

dochecks_csharp() {
    echo "CSharp checks..."
    cat o.pt | trxgrep '
        //(RULE_REF|TOKEN_REF)[text() = (
            "abstract",
            "as",
            "base",
            "bool",
            "break",
            "byte",
            "case",
            "catch",
            "char",
            "checked",
            "class",
            "const",
            "continue",
            "decimal",
            "default",
            "delegate",
            "do",
            "double",
            "else",
            "enum",
            "event",
            "explicit",
            "extern",
            "false",
            "finally",
            "fixed",
            "float",
            "for",
            "foreach",
            "goto",
            "if",
            "implicit",
            "in",
            "int",
            "interface",
            "internal",
            "is",
            "lock",
            "long",
            "namespace",
            "new",
            "null",
            "object",
            "operator",
            "out",
            "override",
            "params",
            "private",
            "protected",
            "public",
            "readonly",
            "ref",
            "return",
            "sbyte",
            "sealed",
            "short",
            "sizeof",
            "stackalloc",
            "static",
            "string",
            "struct",
            "switch",
            "this",
            "throw",
            "true",
            "try",
            "typeof",
            "uint",
            "ulong",
            "unchecked",
            "unsafe",
            "ushort",
            "using",
            "virtual",
            "values",
            "void",
            "volatile",
            "while"     
        ) and not(./parent::identifier/parent::optionValue) and not(./parent::identifier/parent::lexerCommandName)]/..' | trcaret
}

dochecks_python3() {
    echo "Python3 checks..."
    cat o.pt | trxgrep '
        (: Find all RULE_REF that conflict with Python3 :)
        //(RULE_REF|TOKEN_REF)[text() = (
            "abs", "all", "and", "any", "apply", "as", "assert",
            "bin", "bool", "break", "buffer", "bytearray",
            "callable", "chr", "class", "classmethod", "coerce", "compile", "complex", "continue",
            "def", "del", "delattr", "dict", "dir", "divmod",
            "elif", "else", "enumerate", "eval", "execfile", "except",
            "file", "filter", "finally", "float", "for", "format", "from", "frozenset",
            "getattr", "global", "globals",
            "hasattr", "hash", "help", "hex",
            "id", "if", "import", "in", "input", "int", "intern", "is", "isinstance", "issubclass", "iter",
            "lambda", "len", "list", "locals",
            "map", "max", "min", "memoryview",
            "next", "nonlocal", "not",
            "object", "oct", "open", "or", "ord",
            "pass", "pow", "print", "property",
            "raise", "range", "raw_input", "reduce", "reload", "repr", "return", "reversed", "round",
            "set", "setattr", "slice", "sorted", "staticmethod", "str", "sum", "super",
            "try", "tuple", "type",
            "unichr", "unicode",
            "vars",
            "with", "while",
            "yield",
            "zip",
            "__import__",
            "True", "False", "None",
            "rule", "parserRule"
        ) and not(./parent::identifier/parent::optionValue) and not(./parent::identifier/parent::lexerCommandName)]/..' | trcaret
    cat o.pt | trxgrep '
        //(RULE_REF|TOKEN_REF)[text() = (
            "state", "_ctx", "_errHandler", "__syntaxErrors",
            "setTrace", "_precedenceStack", "_precedenceStack", "_interp",
            "type", "consume", "buildParseTrees",
            "enterEveryRule", "visitTerminal", "visitErrorNode", "exitEveryRule",
            "reset", "match", "matchWildcard", "getParseListeners", "addParseListener",
            "removeParseListener", "removeParseListeners", "triggerEnterRuleEvent",
            "triggerExitRuleEvent", "getNumberOfSyntaxErrors", "getTokenFactory",
            "setTokenFactory", "getATNWithBypassAlts", "compileParseTreePattern",
            "getInputStream", "setInputStream", "getTokenStream", "setTokenStream",
            "getCurrentToken", "notifyErrorListeners", "addContextToParseTree",
            "enterRule", "exitRule", "enterOuterAlt", "getPrecedence", "enterRecursionRule",
            "pushNewRecursionContext", "unrollRecursionContexts", "getInvokingContext",
            "precpred", "inContext", "isExpectedToken", "getExpectedTokens",
            "getExpectedTokensWithinCurrentRule", "getRuleIndex", "getRuleInvocationStack",
            "getDFAStrings", "dumpDFA", "getSourceName", "setTrace"
        ) and not(./parent::identifier/parent::optionValue) and not(./parent::identifier/parent::lexerCommandName)]/..' | trcaret
}

dochecks_cpp() {
    echo "Cpp checks..."
    cat o.pt | trxgrep '
        //(RULE_REF|TOKEN_REF)[text() = (
            "alignas", "alignof", "and", "and_eq", "asm", "auto", "bitand",
            "bitor", "bool", "break", "case", "catch", "char", "char16_t",
            "char32_t", "class", "compl", "concept", "const", "constexpr",
            "const_cast", "continue", "decltype", "default", "delete", "do",
            "double", "dynamic_cast", "else", "enum", "explicit", "export",
            "extern", "false", "float", "for", "friend", "goto", "if",
            "inline", "int", "long", "mutable", "namespace", "new",
            "noexcept", "not", "not_eq", "nullptr", "NULL", "operator", "or",
            "or_eq", "private", "protected", "public", "register",
            "reinterpret_cast", "requires", "return", "short", "signed",
            "sizeof", "static", "static_assert", "static_cast", "struct",
            "switch", "template", "this", "thread_local", "throw", "true",
            "try", "typedef", "typeid", "typename", "union", "unsigned",
            "using", "virtual", "void", "volatile", "wchar_t", "while",
            "xor", "xor_eq", 
            "rule", "parserRule"
        ) and not(./parent::identifier/parent::optionValue) and not(./parent::identifier/parent::lexerCommandName)]/..' | trcaret
    cat o.pt | trxgrep '
        //(RULE_REF|TOKEN_REF)[text() = (
            "TRUE", "FALSE"
        ) and not(./parent::identifier/parent::optionValue) and not(./parent::identifier/parent::lexerCommandName)]/..' | trcaret
}

dochecks_dart() {
    echo "Dart checks..."
    cat o.pt | trxgrep '
        //(RULE_REF|TOKEN_REF)[text() = (
            "abstract", "dynamic", "implements", "show",
            "as", "else", "import", "static",
            "assert", "enum", "in", "super",
            "async", "export", "interface", "switch",
            "await", "extends", "is", "sync",
            "break", "external", "library", "this",
            "case", "factory", "mixin", "throw",
            "catch", "false", "new", "true",
            "class", "final", "null", "try",
            "const", "finally", "on", "typedef",
            "continue", "for", "operator", "var",
            "covariant", "Function", "part", "void",
            "default", "get", "rethrow", "while",
            "deferred", "hide", "return", "with",
            "do", "if", "set", "yield",
            "rule", "parserRule"
        ) and not(./parent::identifier/parent::optionValue) and not(./parent::identifier/parent::lexerCommandName)]/..' | trcaret
}

dochecks_go() {
    echo "Go checks..."
    cat o.pt | trxgrep '
        //(RULE_REF|TOKEN_REF)[text() = (
        (: keywords :)
        "break", "default", "func", "interface", "select",
        "case", "defer", "go", "map", "struct",
        "chan", "else", "goto", "package", "switch",
        "const", "fallthrough", "if", "range", "type",
        "continue", "for", "import", "return", "var",

        (: predeclared identifiers https://golang.org/ref/spec#Predeclared_identifiers :)
        "bool", "byte", "complex64", "complex128", "error", "float32", "float64",
        "int", "int8", "int16", "int32", "int64", "rune", "string",
        "uint", "uint8", "uint16", "uint32", "uint64", "uintptr",
        "true", "false", "iota", "nil",
        "append", "cap", "close", "complex", "copy", "delete", "imag", "len",
        "make", "new", "panic", "print", "println", "real", "recover",
        "string",

        (: interface definition of RuleContext from runtime/Go/antlr/rule_context.go :)
        "Accept", "GetAltNumber", "GetBaseRuleContext", "GetChild", "GetChildCount",
        "GetChildren", "GetInvokingState", "GetParent", "GetPayload", "GetRuleContext",
        "GetRuleIndex", "GetSourceInterval", "GetText", "IsEmpty", "SetAltNumber",
        "SetInvokingState", "SetParent", "String",

        (: misc :)
        "rule", "parserRule", "action",

        (: the use of start or stop abd others as a label name will cause the generation of a GetStart() or GetStop() method, which
         : then clashes with the GetStart() or GetStop() method that is generated by the code gen for the rule. So, we need to
         : convert it. This is not ideal as it will still probably confuse authors of parse listeners etc. but the code will
         : compile. This is a proof of Hyrums law.
         :)
        "start", "stop", "exception"
        ) and not(./parent::identifier/parent::optionValue) and not(./parent::identifier/parent::lexerCommandName)]/..' | trcaret
}

dochecks_javascript() {
    echo "JavaScript checks..."
    cat o.pt | trxgrep '
        //(RULE_REF|TOKEN_REF)[text() = (

        (: future reserved :)
        "enum", "await", "implements", "package", "protected", "static",
        "interface", "private", "public",

        (: future reserved in older standards :)
        "abstract", "boolean", "byte", "char", "double", "final", "float",
        "goto", "int", "long", "native", "short", "synchronized", "transient",
        "volatile",

        (: literals :)
        "null", "true", "false",

        (: misc :)
        "rule", "parserRule"
        ) and not(./parent::identifier/parent::optionValue) and not(./parent::identifier/parent::lexerCommandName)]/..' | trcaret
}


dochecks_java() {
    echo "Java checks..."
    cat o.pt | trxgrep '
        //(RULE_REF|TOKEN_REF)[text() = (
        "abstract", "assert", "boolean", "break", "byte", "case", "catch",
        "char", "class", "const", "continue", "default", "do", "double", "else",
        "enum", "extends", "false", "final", "finally", "float", "for", "goto",
        "if", "implements", "import", "instanceof", "int", "interface",
        "long", "native", "new", "null", "package", "private", "protected",
        "public", "return", "short", "static", "strictfp", "super", "switch",
        "synchronized", "this", "throw", "throws", "transient", "true", "try",
        "void", "volatile", "while",

        (: misc :)
        "rule", "parserRule"
        ) and not(./parent::identifier/parent::optionValue) and not(./parent::identifier/parent::lexerCommandName)]/..' | trcaret
}

dochecks_php() {
    echo "PHP checks..."
    cat o.pt | trxgrep '
        //(RULE_REF|TOKEN_REF)[text() = (
        "abstract", "and", "array", "as",
        "break",
        "callable", "case", "catch", "class", "clone", "const", "continue",
        "declare", "default", "die", "do",
        "echo", "else", "elseif", "empty", "enddeclare", "endfor", "endforeach",
        "endif", "endswitch", "endwhile", "eval", "exit", "extends",
        "final", "finally", "for", "foreach", "function",
        "global", "goto",
        "if", "implements", "include", "include_once", "instanceof", "insteadof", "interface", "isset",
        "list",
        "namespace", "new",
        "or",
        "print", "private", "protected", "public",
        "require", "require_once", "return",
        "static", "switch",
        "throw", "trait", "try",
        "unset", "use",
        "var",
        "while",
        "xor",
        "yield",
        "__halt_compiler", "__CLASS__", "__DIR__", "__FILE__", "__FUNCTION__",
        "__LINE__", "__METHOD__", "__NAMESPACE__", "__TRAIT__",

        (: misc :)
        "rule", "parserRule"
        ) and not(./parent::identifier/parent::optionValue) and not(./parent::identifier/parent::lexerCommandName)]/..' | trcaret
}

dochecks_typescript() {
    echo "TypeScript checks..."
    cat o.pt | trxgrep '
        //(RULE_REF|TOKEN_REF)[text() = (
            "any",
            "as",
            "boolean",
            "break",
            "case",
            "catch",
            "class",
            "continue",
            "const",
            "constructor",
            "debugger",
            "declare",
            "default",
            "delete",
            "do",
            "else",
            "enum",
            "export",
            "extends",
            "false",
            "finally",
            "for",
            "from",
            "function",
            "get",
            "if",
            "implements",
            "import",
            "in",
            "instanceof",
            "interface",
            "let",
            "module",
            "new",
            "null",
            "number",
            "package",
            "private",
            "protected",
            "public",
            "require",
            "return",
            "set",
            "static",
            "string",
            "super",
            "switch",
            "symbol",
            "this",
            "throw",
            "true",
            "try",
            "type",
            "typeof",
            "var",
            "void",
            "while",
            "with",
            "yield",
            "of"
        ) and not(./parent::identifier/parent::optionValue) and not(./parent::identifier/parent::lexerCommandName)]/..' | trcaret
}


main $@
