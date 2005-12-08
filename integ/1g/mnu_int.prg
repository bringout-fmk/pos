#include "\dev\fmk\pos\pos.ch"


/*! \fn Mnu_Integ()
 *  \brief Osnovni menij opcija provjere integriteta
 */
function Mnu_Integ()
*{
private opc:={}
private opcexe:={}
private izbor:=1

AADD(opc, "1. INTEG-1: stanje artikala                   ")
AADD(opcexe, {|| CaseInt1()})
AADD(opc, "2. INTEG-2: stanje prodaje ")
AADD(opcexe, {|| CaseInt2()})
AADD(opc, "O. OIDERR: provjera duplih oid-a u tabelama ")
AADD(opcexe, {|| CaseIntOid()})

Menu_SC("int")

return
*}

/*! \fn CaseInt1()
 *  \brief pokretanje integ1 testa sa menija
 */
function CaseInt1()
*{
if gSamoProdaja=="D"
	UpdInt1(.t., .f.)
else
	if !EmptDInt(1)
		ChkInt1(.t., .f.)
		RptInteg(.t., .f.)
	endif
endif
return
*}

/*! \fn CaseInt2()
 *  \brief pokretanje integ2 testa sa menija
 */
function CaseInt2()
*{
if gSamoProdaja=="D"
	UpdInt2(.t., .f.)
else
	if !EmptDInt(2)
		ChkInt2(.t., .f.)
		RptInteg(.t., .f.)
	endif
endif
return
*}


/*! \fn CaseIntOid()
 *  \brief pokretanje provjere oid-a
 */
function CaseIntOid()
*{
if gSamoProdaja=="N"
	// prvo reindexiraj
	Reindex(.t.)
	BrisiError()
	OidChk(DATE(), DATE(), .t.)
	RptInteg(.t., .f.)
endif
return
*}



