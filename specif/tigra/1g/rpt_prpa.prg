#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/specif/tigra/1g/rpt_prpa.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.1 $
 * $Log: rpt_prpa.prg,v $
 * Revision 1.1  2003/02/13 14:32:21  ernad
 * Promet partnera - partneri koji nisu bili aktivni u posljednjih n dana
 *
 *
 *
 */

/*! \fn RptPrpa()
 *  \brief Promet Partnera
 */

function RptPrPa()
*{
local cIdGost 

// datum posljednje transakcije
local dDatPT
local cLinija
local nDana
local nRbr

cIdGost:=0
nDana:=15

SET CURSOR ON
Box(,2,60)
@ m_x+1, m_y+2 SAY "Prikaz partnera koji nisu imali promet"
@ m_x+2, m_y+2 SAY "u posljednjih " GET nDana PICT "999"
@ m_x+2, m_y+2 SAY " dana"
READ
BoxC()

START PRINT CRET

cLinija := "--- -------- ---------------------------------------- --------"

O_RNGOST
SET ORDER TO TAG "ID"
O_DOKS
// IDGost + Placen + DTOS(DATUM)
SET ORDER TO TAG "3"
GO TOP

? "Pregled prometa partnera na  dan:", DATE()

? cLinija
? " Partner                                      Datum posljednje"
? "                                                   transakcije"

? cLinija

nRbr:=0

do while !EOF()
	cIdGost:=IdGost 
	dDatPT:=CTOD("")
	
	if EMPTY(cIdGost)
		skip
		loop
	endif
	
	do while !EOF() .and. cIdGost==IdGost
		if idVD $ "42"
			if doks->datum > dDatPT
				dDatPT:=doks->datum
			endif
		endif
		
		SKIP
	enddo

	if (dDatPT < DATE()-nDana)
		SELECT RNGOST
		SEEK cIdGost
		nRbr:=nRbr+1
		? STR(nRbr,3), cIdGost, rngost->naz, dDatPT
		SELECT DOKS
	endif
	
enddo


END PRINT

return
*}
