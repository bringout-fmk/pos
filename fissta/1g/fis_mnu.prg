#include "\dev\fmk\pos\pos.ch"


/*! \fn Fissta_mnu()
 *  \brief Menij za rad sa FISSTA
 */
function Fissta_mnu()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. startanje interfejsa FisCTT    ")
AADD(opcexe, {|| StartFisCTTInterfejs(gFisCTTPath, .f.)})
AADD(opc, "2. inicijaliziraj FisCTT    ")
AADD(opcexe, {|| NotImp()})

Menu_Sc("fst")

return
*}




