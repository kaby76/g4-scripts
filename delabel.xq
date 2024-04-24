move //labeledAlt[./(POUND | identifer)]/@* ./ancestor::labeledAlt;
delete //labeledAlt/(POUND | identifier);

move //labeledLexerElement[./(identifier | ASSIGN | PLUS_ASSIGN)]/@* ./ancestor::labeledLexerElement;
delete //labeledLexerElement/(identifier | ASSIGN | PLUS_ASSIGN);

move //labeledElement[./(identifier | ASSIGN | PLUS_ASSIGN)]/@* ./ancestor::labeledElement;
delete //labeledElement/(identifier | ASSIGN | PLUS_ASSIGN);

