#include "\dev\fmk\pos\pos.ch"


/*! \fn Mnu_Integ()
 *  \brief Osnovni menij opcija provjere integriteta
 */
function Mnu_Integ()
*{
private opc:={}
private opcexe:={}
private izbor:=1

AADD(opc, "1. INTEG-1: stanje artikala       ")
AADD(opcexe, {|| CaseInt1()})
AADD(opc, "2. INTEG-2: stanje prodaje ")
AADD(opcexe, {|| CaseInt2()})

Menu_SC("int")

return
*}

function CaseInt1()
*{
if gSamoProdaja=="D"
	UpdInt1(.t.)
else
	ChkInt1(.t.)
endif
return
*}

function CaseInt2()
*{

return
*}



