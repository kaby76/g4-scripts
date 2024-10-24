#!/usr/bin/bash
# "Setting MSYS2_ARG_CONV_EXCL so that Trash XPaths do not get mutulated."
export MSYS2_ARG_CONV_EXCL="*"
dotnet trparse -t ANTLRv4 *.g4 \
   | dotnet trxgrep '
         //lexerRuleSpec
	     [./lexerRuleBlock/lexerAltList/lexerAlt/lexerCommands/lexerCommand/lexerCommandName/identifier/RULE_REF/text()="skip"]
         /TOKEN_REF/text()'

		
