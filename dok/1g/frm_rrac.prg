/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 *
 *
 */
 
/*! \fn P_RadniRac(cBroj)
 *  \brief Pregled svih otvorenih radnih racuna za radnika
 *  \param cBroj
 */
 
function P_RadniRac(cBroj)
*{

if cBroj==nil
	cBroj:=SPACE(LEN(_POS->BrDok))
else
	cBroj:=cBroj
endif

cBroj:=PADL(ALLTRIM(cBroj),LEN(cBroj))

SELECT _POS
Seek2 (gIdPos+VD_RN+dtos(gDatum)+cBroj)
// prvo provjeri da ne pokusa uzeti tudji
if FOUND().and.M1<>"Z".and.IdRadnik!=gIdRadnik
	return (.t.)
endif
ImeKol:={ { "Datum",       {|| Datum }, },;
          { "Broj",        {|| BrDok }, },;
          { "Sto",         {|| Sto   }, },;
          { "Roba",        {|| Left (RobaNaz, 30) }, },;
          { "Kolicina",    {|| STR (Kolicina, 8, 2) }, },;
          { "Cijena",      {|| STR (Cijena, 8, 2) }, },;
          { "Iznos stavke",{|| STR (Kolicina*Cijena, 12, 2) }, },;
          { "G.T.",        {|| IIF (GT=="1"," NE "," DA ")},};
        }
if gModul=="HOPS"
	Kol:={1, 2, 3, 4, 5, 6, 7,8}
else
  	Kol:={1, 3, 4, 5, 6, 7 }
endif

cFilt1:="IDRADNIK=="+cm2str(gIdRadnik)+".and.IdVd=='42'.and.(M1<>'Z')"

SET FILTER TO &cFilt1
GO TOP
Skip 0
ObjDBedit( , 20, 77, {|| P_RRproc () }, ;
            "  OTVORENI RADNI RACUNI  ", "", .F., ;
            "<Enter> - Odabir         </> - Tekuci iznos")
SET FILTER TO

if LASTKEY()==K_ESC
	return (.f.)
endif
if EMPTY(_POS->BrDok)
	return (.f.)
endif

cBroj:=_POS->BrDok
return (.t.)
*}



/*! \fn P_RRproc()
 *  \brief Radni racuni - handler
 */
 
function P_RRproc()
*{

if M->Ch==0
	return (DE_CONT)
endif

if (CHR(LastKey())=="B" .or. CHR(LastKey())=="b") 
	if Pitanje(,"Izbrisati stavku racuna (D/N)?","D") == "N"
		return (DE_CONT)
	endif
	delete
	return (DE_REFRESH)
endif

if LASTKEY()==K_ESC.or.LASTKEY()==K_ENTER
	return (DE_ABORT)
endif

if CHR(LASTKEY())=="/"
	Msg("Tekuci iznos racuna je: " +STR(RR_iznos(_POS->IdPos, _POS->BrDok), 10,2),20)
endif

return (DE_CONT)
*}


/*! \fn RR_Iznos(cIdPos,cBrDok)
 *  \brief
 *  \param cIdPos
 *  \param cBrDok
 */
 
function RR_Iznos(cIdPos,cBrDok)
*{

// - koristi gDatum

SELECT _POS
nTekRec:=RECNO()
nIznos:=0
Seek2 (cIdPos+VD_RN+dtos(gdatum)+cBrDok)
do while !eof().and._POS->(IdPos+IdVd+dtos(datum)+BrDok)==(cIdPos+VD_RN+dtos(gDatum)+cBrDok)
	nIznos += _POS->(Kolicina * Cijena)
  	SKIP
enddo
GO nTekRec
return (nIznos)
*}


/*! \fn AutoKeys()
 *  \brief Reaguje na programibilne tipke tako sto u polje za unos sifre artiklaunese sifru koja je vezana s tom tipkom!
 */
 
function AutoKeys()
*{

local nPrev

if !((GETLIST[1]:hasFocus).and.(GETLIST[1]:name="_idroba"))
	return	
endif

nPrev:=SELECT()

SELECT K2C
Seek2(STR(LASTKEY(),4))

if !FOUND()
	return
endif

GETLIST[1]:buffer:=K2C->IdRoba
GETLIST[1]:display()
GETLIST[1]:assign()
keyboard CHR(K_ENTER)
select (nprev)
return
*}


