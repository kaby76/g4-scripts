move //labeledAlt/(POUND | identifer)/@* ./ancestor::labeledAlt;
delete //labeledAlt/(POUND | identifier);

move //labeledLexerElement/(identifier | ASSIGN | PLUS_ASSIGN)/@* ./ancestor::labeledLexerElement;
delete //labeledLexerElement/(identifier | ASSIGN | PLUS_ASSIGN);

move //labeledElement/identifier/@WS ./ancestor::labeledElement;
delete //labeledElement/(identifier | ASSIGN | PLUS_ASSIGN);

