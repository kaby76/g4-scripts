# use in combination:
# trparse python-11.gram | bash strip-python.sh | trtext

trquery '
	delete //meta/(AT | name | string | newline);
	delete //rule_[rulename/name/NAME[contains(text(),"invalid_") or contains(text(),"expression_without_invalid")]];
	delete //rule_[rulename/name/NAME[contains(text(),"invalid_") or contains(text(),"expression_without_invalid")]];
	delete //action;
(:	replace //attribute " ";
	replace //attribute_name " "; :)
	delete //attribute;
	delete //attribute_name;
	delete //lookahead[AMPER];
	delete //memoflag;
	delete //forced_atom/AMPER;
	delete //alt[items/named_item/item/atom/name/NAME[contains(text(),"invalid_")]];
	delete //rule_/more_alts/alts/VBAR[not(following-sibling::*)];
	delete //rule_//VBAR[not(following-sibling::*)];
	delete //rule_//VBAR[following-sibling::*[1][name()="alts"]/*[1]/name()="VBAR"];

	delete //rule_[./rulename/name/NAME/text()="class_def_raw"]/more_alts/@Before[. = "
    "][following-sibling::alts/@Before[. = "
    "]];
	delete //rule_[./rulename/name/NAME/text()="function_def_raw"]/more_alts/@Before[. = "
    "][following-sibling::alts/@Before[. = "
    "]];
	delete //rule_[./rulename/name/NAME/text()="params"]/more_alts/@Before[. = "
    "][following-sibling::alts/@Before[. = "
    "]];
	delete //rule_[./rulename/name/NAME/text()="expression"]/more_alts/@Before[. = "
    "][following-sibling::alts/@Before[. = "
    "]];
	delete //rule_[./rulename/name/NAME/text()="lambda_kwds"]/more_alts/@Before[. = "
    "][following-sibling::alts/@Before[. = "
    "]];
	delete //rule_[./rulename/name/NAME/text()="kwarg_or_starred"]/more_alts/@Before[. = "
    "][following-sibling::alts/@Before[. = "
    "]];
	delete //rule_[./rulename/name/NAME/text()="kwarg_or_starred"]/more_alts/@Before[. = "
    "][following-sibling::alts/@Before[. = "
    "]];
	delete //rule_[./rulename/name/NAME/text()="star_etc"]/more_alts/@Before[. = "
    "][following-sibling::alts/@Before[. = "
    "]];
	delete //rule_[./rulename/name/NAME/text()="kwds"]/more_alts/@Before[. = "
    "][following-sibling::alts/@Before[. = "
    "]];
	delete //rule_[./rulename/name/NAME/text()="if_stmt"]/more_alts/@Before[. = "
    "][following-sibling::alts/@Before[. = "
    "]];
	delete //rule_[./rulename/name/NAME/text()="elif_stmt"]/more_alts/@Before[. = "
    "][following-sibling::alts/@Before[. = "
    "]];
	delete //rule_[./rulename/name/NAME/text()="else_block"]/more_alts/@Before[. = "
    "][following-sibling::alts/@Before[. = "
    "]];
	delete //rule_[./rulename/name/NAME/text()="while_stmt"]/more_alts/@Before[. = "
    "][following-sibling::alts/@Before[. = "
    "]];
	delete //rule_[./rulename/name/NAME/text()="for_stmt"]/more_alts/@Before[. = "
    "][following-sibling::alts/@Before[. = "
    "]];
	delete //rule_[./rulename/name/NAME/text()="with_stmt"]/more_alts/@Before[. = "
    "][following-sibling::alts/@Before[. = "
    "]];
	delete //rule_[./rulename/name/NAME/text()="try_stmt"]/more_alts/@Before[. = "
    "][following-sibling::alts/@Before[. = "
    "]];
	delete //rule_[./rulename/name/NAME/text()="except_block"]/more_alts/@Before[. = "
    "][following-sibling::alts/@Before[. = "
    "]];
	delete //rule_[./rulename/name/NAME/text()="except_star_block"]/more_alts/@Before[. = "
    "][following-sibling::alts/@Before[. = "
    "]];
	delete //rule_[./rulename/name/NAME/text()="finally_block"]/more_alts/@Before[. = "
    "][following-sibling::alts/@Before[. = "
    "]];
	delete //rule_[./rulename/name/NAME/text()="case_block"]/more_alts/@Before[. = "
    "][following-sibling::alts/@Before[. = "
    "]];
	delete //rule_[./rulename/name/NAME/text()="lambda_params"]/more_alts/@Before[. = "
    "][following-sibling::alts/@Before[. = "
    "]];
	delete //rule_[./rulename/name/NAME/text()="lambda_star_etc"]/more_alts/@Before[. = "
    "][following-sibling::alts/@Before[. = "
    "]];
	delete //rule_[./rulename/name/NAME/text()="kwarg_or_double_starred"]/more_alts/@Before[. = "
    "][following-sibling::alts/@Before[. = "
    "]];
	'
