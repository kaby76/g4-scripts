# g4-checks

This repo contains some useful [Trash](https://github.com/kaby76/Domemtech.Trash) scripts
for Antlr4 grammars.

### Testing
* [testrig.sh](https://github.com/kaby76/g4-checks/blob/main/testrig.sh) -- Script that simplifies running the org.antlr.v4.gui.TestRig program.
* [find-cover.sh](https://github.com/kaby76/g4-checks/blob/main/find-cover.sh) -- Generate cover.html, which is a "heat map" of the grammar showing what rules were used in the parse.

### Antlr4 grammar linting
* [find-unused-parser-symbols.sh](https://github.com/kaby76/g4-checks/blob/main/find-unused-parser-symbols.sh) -- Find unused parser symbols.
* [find-unused-lexer-symbols.sh](https://github.com/kaby76/g4-checks/blob/main/find-unused-lexer-symbols.sh) -- Find unused lexer symbols. 

### Antlr4 grammar properties
* [find-start.sh](https://github.com/kaby76/g4-checks/blob/main/find-start.sh) -- Find start-rule.
* [all-rules.sh](https://github.com/kaby76/g4-checks/blob/main/all-rules.sh) -- Finds the transitive closure of a rule in a parser grammar.
* [count-lexers.sh](https://github.com/kaby76/g4-checks/blob/main/count-lexers.sh) -- Count the number of lexer leaf nodes in a parse tree.
* [count-parsers.sh](https://github.com/kaby76/g4-checks/blob/main/count-parsers.sh) -- Count the number of internal parse tree nodes in a parse tree.
* [find-defs.sh](https://github.com/kaby76/g4-checks/blob/main/find-defs.sh) -- Finds all definitions of a symbol.
* [find-refs.sh](https://github.com/kaby76/g4-checks/blob/main/find-refs.sh) -- Finds all references (applied and defining) of a symbol.
* [find-actions.sh](https://github.com/kaby76/g4-checks/blob/main/find-actions.sh) -- Finds all actions in a grammar.

### Antlr4 grammar clean ups
* [delete-useless-parentheses.sh](https://github.com/kaby76/g4-checks/blob/main/find-useless.sh) -- Find useless parentheses. Contains test option.
* [remove-underscores-grammars.sh](https://github.com/kaby76/g4-checks/blob/main/remove-underscores-grammars.sh) -- Remove trailing underscores on symbols.
* [strip-python.sh](https://github.com/kaby76/g4-checks/blob/main/strip-python.sh) -- Strip the python.gram file of attributes and other assorted junk.
* [strip.xq](https://github.com/kaby76/g4-scripts/blob/main/strip.xq) -- trquery script to strip all junk from an Antlr4 grammar.
* [delabel.xq](https://github.com/kaby76/g4-scripts/blob/main/delabel.xq) -- trquery script to "delabel" an Antlr4 grammar.

### Grammar conversion
* [bison.sh](https://github.com/kaby76/g4-checks/blob/main/bison.sh) -- Convert Bison grammar to Antlr4. ___Not finished.___
