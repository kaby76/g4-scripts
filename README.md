# g4-checks

This repo contains some useful [Trash](https://github.com/kaby76/Domemtech.Trash) scripts.

### Testing
* [testrig.sh](https://github.com/kaby76/g4-checks/blob/main/testrig.sh) -- Runs the org.antlr.v4.gui.TestRig program on an input file.
* [find-cover.sh](https://github.com/kaby76/g4-checks/blob/main/find-cover.sh) -- Generate cover.html.

### Grammar linting
* [find-useless.sh](https://github.com/kaby76/g4-checks/blob/main/find-useless.sh) -- Find useless parentheses. 
* [unused.sh](https://github.com/kaby76/g4-checks/blob/main/unused.sh) -- Find unused parser symbols.
* [unused-lexer.sh](https://github.com/kaby76/g4-checks/blob/main/unused-lexer.sh) -- Find unused lexer symbols. 
* [find-probs.sh](https://github.com/kaby76/g4-checks/blob/main/find-probs.sh) -- Find start-rule problems. 

### Grammar properties
* [all-rules.sh](https://github.com/kaby76/g4-checks/blob/main/all-rules.sh) -- Finds the transitive closure of a rule in a parser grammar.

### Grammar clean ups
* [remove-underscores-grammars.sh](https://github.com/kaby76/g4-checks/blob/main/remove-underscores-grammars.sh) -- Remove trailing underscores on symbols.

### Grammar conversion
* [bison.sh](https://github.com/kaby76/g4-checks/blob/main/bison.sh) -- Convert Bison grammar to Antlr4.
