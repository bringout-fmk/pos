#include "\dev\fmk\pos\pos.ch"


/*! \fn Mnu_Integ()
 *  \brief Osnovni menij opcija provjere integriteta
 */
function Mnu_Integ()
*{
private opc:={}
private opcexe:={}
private izbor:=1

AADD(opc, "INTEG-1: xxxxxxx               ")
AADD(opcexe, {|| NotImp()})
AADD(opc, "INTEG-2: prodaja")
AADD(opcexe, {|| NotImp()})

Menu_SC("int")

return
*}


