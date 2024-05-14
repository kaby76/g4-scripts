grammar Up1;

// https://github.com/kaby76/g4-scripts/issues/2
start : full_database_recovery EOF;
full_database_recovery
    : STANDBY? DATABASE (
        (
            UNTIL (CANCEL | TIME CHAR_STRING | CHANGE UNSIGNED_INTEGER | CONSISTENT)
            | USING BACKUP CONTROLFILE
            | SNAPSHOT TIME CHAR_STRING
        )+
    )?
    ;
