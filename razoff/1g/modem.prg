#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/razoff/1g/modem.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.6 $
 * $Log: modem.prg,v $
 * Revision 1.6  2002/06/17 13:19:57  sasa
 * no message
 *
 *
 */
 

/*! \fn MenuModem()
*   \brief Menij za aktiviranje alata za razmjenu podataka
*/

function MenuModem()
*{

private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. aktiviraj DIAL-UP Servera W9X")
AADD(opcexe,{|| DialUpOn()}) 
AADD(opc, "2. deaktiviraj DIAL-UP Server W9X")
AADD(opcexe,{|| DialUpOff()})
AADD(opc, "3. poziv modem (PcAny)")
AADD(opcexe,{|| ModemPcAny()})

Menu_SC("modem")

return .f.
*}


/*! \fn ModemPcAny()
 *    \brief Poziv PcAny-ja za transfer podataka (poziva fajl modem.bhf)
 */

function ModemPcAny()
*{

private cKom

if FILE("c:\tops\modem.bhf")
	cKom:="start c:\tops\modem.bhf"
else
       	copy file ("c:\windows\desktop\modem.bhf") TO ("c:\tops\modem.bhf")
       	cKom:="start c:\windows\desktop\modem.bhf"
endif
run &cKom

*}


/*! \fn DialUpOn()
 *   \brief Aktiviranje DialUp servera
 */

function DialUpOn()
*{
private cKom
if Pitanje(,"Aktivirati Dial-up Servera D ?","D")=="D"
	cKom:="serverok /ON"
        run &ckom
endif

return
*}


/*! \fn DialUpOff()
*   \brief Deaktiviranje DialUp servera
*/
function DialUpOff()
*{

private cKom

if pitanje(,"DEAKTIVIRATI Dial-up Server D ?","D")=="D"
	cKom:="serverok /OFF"    
	run &ckom
endif

return
*}
