delete //DOC_COMMENT;

move //labeledAlt/(POUND | identifer)/@WS ./ancestor::labeledAlt;
delete //labeledAlt/(POUND | identifier);

move //labeledLexerElement/(identifier | ASSIGN | PLUS_ASSIGN)/@WS ./ancestor::labeledLexerElement;
delete //labeledLexerElement/(identifier | ASSIGN | PLUS_ASSIGN);

move //labeledElement/identifier/@WS ./ancestor::labeledElement;
delete //labeledElement/(identifier | ASSIGN | PLUS_ASSIGN);

delete //rulePrequel;
delete //ruleReturns;
delete //exceptionGroup;
delete //throwsSpec;
delete //prequelConstruct;
delete //elementOptions;

move //actionBlock/@WS[1] ../..;
delete //actionBlock/(. | ./following-sibling::QUESTION[1]);

move //argActionBlock/@WS[1] ../..;
delete //argActionBlock;
