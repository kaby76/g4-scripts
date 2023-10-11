# g4-checks

This repo contains some useful [Trash](https://github.com/kaby76/Domemtech.Trash) scripts
for Antlr4 grammars.

### Testing
* [testrig.sh](https://github.com/kaby76/g4-checks/blob/main/testrig.sh) -- Wrapper script for the org.antlr.v4.gui.TestRig program that includes extraction of grammar name and start rule via Trash.
* [find-cover.sh](https://github.com/kaby76/g4-checks/blob/main/find-cover.sh) -- Generate cover.html.

### Grammar linting
* [find-useless.sh](https://github.com/kaby76/g4-checks/blob/main/find-useless.sh) -- Find useless parentheses. 
* [unused.sh](https://github.com/kaby76/g4-checks/blob/main/unused.sh) -- Find unused parser symbols.
* [unused-lexer.sh](https://github.com/kaby76/g4-checks/blob/main/unused-lexer.sh) -- Find unused lexer symbols. 

### Grammar properties
* [find-start.sh](https://github.com/kaby76/g4-checks/blob/main/find-start.sh) -- Find start-rule.
* [all-rules.sh](https://github.com/kaby76/g4-checks/blob/main/all-rules.sh) -- Finds the transitive closure of a rule in a parser grammar.
* [count-lexers.sh](https://github.com/kaby76/g4-checks/blob/main/count-lexers.sh) -- Count the number of lexer leaf nodes in a parse tree.
* [count-parsers.sh](https://github.com/kaby76/g4-checks/blob/main/count-parsers.sh) -- Count the number of internal parse tree nodes in a parse tree.
* [find-defs.sh](https://github.com/kaby76/g4-checks/blob/main/find-defs.sh) -- Finds all definitions of a symbol.
* [find-refs.sh](https://github.com/kaby76/g4-checks/blob/main/find-refs.sh) -- Finds all references (applied and defining) of a symbol.
* [find-actions.sh](https://github.com/kaby76/g4-checks/blob/main/find-actions.sh) -- Finds all actions in a grammar.

### Grammar clean ups
* [remove-underscores-grammars.sh](https://github.com/kaby76/g4-checks/blob/main/remove-underscores-grammars.sh) -- Remove trailing underscores on symbols.
* [strip-python.sh](https://github.com/kaby76/g4-checks/blob/main/strip-python.sh) -- Strip the python.gram file of attributes and other assorted junk.

### Grammar conversion
* [bison.sh](https://github.com/kaby76/g4-checks/blob/main/bison.sh) -- Convert Bison grammar to Antlr4.
