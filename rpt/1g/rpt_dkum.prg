#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/rpt/1g/rpt_dkum.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.5 $
 * $Log: rpt_dkum.prg,v $
 * Revision 1.5  2003/06/28 15:05:36  mirsad
 * omogucen ispis naziva firme na izvjestajima
 *
 * Revision 1.4  2002/06/14 14:02:43  mirsad
 * prirpeme za doxy dokumenter
 *
 *
 */

/*! \file fmk/pos/rpt/1g/rpt_dkum.prg
 *  \brief Kumulativ prometa
 */

/*! \fn PrepisKumPr()
 *  \brief Izvjestaj kumulativa prometa
 */

function PrepisKumPr()
*{
local nSir:=80
local nRobaSir:=40
local cLm:=SPACE(5)
local cPicKol:="999999.999"

START PRINT CRET

if gVrstaRS=="S"
	P_INI
	P_10CPI
else
	nSir:=40
	nRobaSir:=18
	cLM:=""
	cPicKol:="9999.999"
endif

ZagFirma()

if empty(DOKS->IdPos)
	? PADC("KUMULATIV PROMETA "+ALLTRIM(DOKS->BrDok),nSir)
else
	? PADC("KUMULATIV PROMETA "+ALLTRIM(DOKS->IdPos)+"-"+ALLTRIM(DOKS->BrDok),nSir)
endif

?
? PADC(FormDat1(DOKS->Datum),nSir)
?
SELECT VRSTEP
HSEEK DOKS->IdVrsteP

if gVrstaRS=="S"
	cPom:=VRSTEP->Naz
else
	cPom:=LEFT(VRSTEP->Naz,23)
endif

? cLM+"Vrsta placanja:",cPom

SELECT RNGOST
HSEEK DOKS->IdGost

if gVrstaRS=="S"
	cPom:=RNGOST->Naz
else
	cPom:=LEFT(RNGOST->Naz,23)
endif

? cLM+"Gost / partner:",cPom

if DOKS->Placen==PLAC_JEST.or.DOKS->IdVrsteP==gGotPlac
	? cLM+"       Placeno:","DA"
else
	? cLM+"       Placeno:","NE"
endif

SELECT POS
HSEEK DOKS->(IdPos+IdVd+dtos(datum)+BrDok)

? cLM
if gVrstaRS=="S"
	?? "Sifra    Naziv                                    JMJ Cijena  Kolicina"
	m:=cLM+"-------- ---------------------------------------- --- ------- ----------"
else
	?? "Sifra    Naziv              JMJ Kolicina"
	m:=cLM+"-------- ------------------ --- --------"
endif
? m

/****
Sifra    Naziv                                    JMJ Cijena  Kolicina
-------- ---------------------------------------- --- ------- ----------
01234567 0123456789012345678901234567890123456789     9999.99 999999.999
                                                      999,999,999,999.99
Sifra    Naziv              JMJ Kolicina
-------- ------------------ --- --------
01234567 012345678901234567 012 9999.999
         012345 01234567 01
                            9,999,999.99
****/

nFin:=0
SELECT POS

do while !eof().and.POS->(IdPos+IdVd+dtos(datum)+BrDok)==DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
	if gVrstaRS=="S".and.prow()>63-gPstranica
		FF
	endif
	? cLM
	?? IdRoba,""
	SELECT ROBA
	HSEEK POS->IdRoba
	?? PADR(ROBA->Naz,nRobaSir),ROBA->Jmj,""
	SELECT POS
	if gVrstaRS=="S"
		?? TRANS(POS->Cijena,"9999.99"),""
	endif
	?? TRANS(POS->Kolicina,cPicKol)
	nFin+=POS->(Kolicina*Cijena)
	skip
enddo

if gVrstaRS=="S".and.prow()>63-gPstranica-7
	FF
endif

? m
? cLM

if gVrstaRS=="S"
	?? PADL("IZNOS DOKUMENTA ("+TRIM(gDomValuta)+")",13+nRobaSir),TRANS(nFin,"999,999,999,999.99")
else
	?? PADL("IZNOS DOKUMENTA ("+TRIM(gDomValuta)+")",10+nRobaSir),TRANS(nFin,"9,999,999.99")
endif

? m

if gVrstaRS=="S"
	FF
else
	PaperFeed()
endif

END PRINT
SELECT DOKS
return
*}


