#include "pos.ch"


// ---------------------------------------------
// menu fiskalni izvjestaji
// ---------------------------------------------
function mnu_f_rpt()
private izbor := 1
private opc := {}
private opcexe := {}

AADD(opc,"------ izvjestaji -----------------------")
AADD(opcexe,{|| .f. })
AADD(opc,"1. dnevni fiskalni izvjestaj           ")
AADD(opcexe,{|| fp_daily_rpt( ALLTRIM(gFC_path), ALLTRIM(gFC_name) ) })
AADD(opc,"2. fiskalni izvjestaj za period ")
AADD(opcexe,{|| fp_per_rpt( ALLTRIM(gFc_path), ALLTRIM(gFc_name) ) })
AADD(opc,"------ ostale komande --------------------")
AADD(opcexe,{|| .f. })
AADD(opc,"5. zatvori racun        ")
AADD(opcexe,{|| fp_close( ALLTRIM(gFC_path), ALLTRIM(gFC_name) ) })
AADD(opc,"6. zatvori nasilno racun ")
AADD(opcexe,{|| fp_void( ALLTRIM(gFc_path), ALLTRIM(gFc_name) ) })
AADD(opc,"7. proizvoljna komanda ")
AADD(opcexe,{|| fp_man_cmd( ALLTRIM(gFc_path), ALLTRIM(gFc_name) ) })

Menu_SC("izvf")

return



