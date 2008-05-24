#define F_T_OSTAV		220
#define F_T_PARTN		221
#define F_T_PARAMS	222

#xcommand O_OSTAV_P => SELECT (F_T_OSTAV); USE (KUMPATH+"OSTAV_P"); set order to tag "ID"
#xcommand O_PARTN_P => SELECT (F_T_PARTN); USE (KUMPATH+"PARTN_P"); set order to tag "ID"
#xcommand O_PARAMS_P => SELECT (F_T_PARAMS); USE (KUMPATH+"PARAMS_P"); set order to tag "ID"
