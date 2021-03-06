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
 */

/*! \file fmk/pos/db/1g/db_admin.prg
 *  \brief Administratorske funkcije nad tabelama
 */

/*! \fn NaprPom(aDbf)
 *  \brief Uklanja SVE tragove prethodne pomocne datoteke, ukljucujuci i CDX fajlove, kako bi se nova mogla napraviti (CDX fajlovi smetaju kad se ucitaju s novom strukturom DBF-a)
 *  \param aDbf
 */

function NaprPom(aDbf,cPom)
*{

if cPom==nil
	cPom:="POM"
endif

cPomDBF:=ToUnix(PRIVPATH+cPom+".DBF")
cPomCDX:=ToUnix(PRIVPATH+cPom+".CDX")

if File(cPomDBF)
	FErase(cPomDBF)
endif

if File (cPomCDX)
	FErase(cPomCDX)
endif

if File(UPPER(cPomDBF))
	FErase(UPPER(cPomDBF))
endif

if File (UPPER(cPomCDX))
	FErase(UPPER(cPomCDX))
endif

DBcreate2(cPomDBF, aDbf)

return
*}


/*! \fn Reindex_All()
 *  \brief 
 */
 
function Reindex_All()
*{

OX_DOKS
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

OX_PROMVP
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

OX_POS
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

OX_ROBA
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

OX_SIROV
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

OX_SAST
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

OX_STRAD
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

SELECT(F_PARAMS)
usex(PRIVPATH+"PARAMS")
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

SELECT(F_KPARAMS)
usex(KUMPATH+"KPARAMS")
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
close

OX_OSOB
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

OX_TARIFA
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

OX_VALUTE
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

OX_VRSTEP
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

OX_KASE
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

OX_ODJ
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
close

OX_DIO
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
close

OX_UREDJ
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

OX_RNGOST
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

OX_MARS
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close
*}

/*! \fn BrisiDSif(nAreaSif)
 *  \brief Izbrisi duple sifre (ID-ove) u sifrarniku
 */
function BrisiDSif(nAreaSif)
*{
local cId
local nTRec

GO TOP
do while !EOF()
	cId:=field->id
	skip
	if (field->id==cId)
		do while !EOF() .and. (field->id==cId)
			SKIP
			nTRec:=RECNO()
			SKIP -1
			DELETE
			GO nTRec
		enddo
	endif
enddo

*}

/*! \fn ChkTblPromVp()
 *  \brief Provjeri verziju tabele promvp
 *  \sa tbl_pos_promvp
 *  Ako je tabela stara verzija, izbrisi postojecu pa kreiraj novu
 *
 */
 
function ChkTblPromVp()
*{
local cTbl

cTbl:=DbfName(F_PROMVP,.t.)+'.'+DBFEXT
if (FILE(cTbl))
	O_PROMVP
	if (FIELDPOS("polog01")==0 .or. FIELDPOS("_SITE_")==0)
		USE
		goModul:oDatabase:kreiraj(F_PROMVP)
		USE
	endif
	USE
endif

return
*}


/*! \fn CrePosISifData()
 *  \brief Napravi inicijalne podatke u sifranicima osoblja, statusi radnika
 *  Ako nema podataka u sifrarnicima napravi inicijalne 
 *
 */

function CrePosISifData()
*{
O_STRAD
if (RECCOUNT2()==0)
	
	MsgO("Kreiram ini STRAD")
	APPEND BLANK
	replace id WITH "0"
	replace prioritet WITH "0"
	replace naz WITH "Nivo admin"
	
	APPEND BLANK
	replace id WITH "1"
	replace prioritet WITH "1"
	replace naz WITH "Nivo upravn"
	
	APPEND BLANK
	replace id WITH "3"
	replace prioritet WITH "3"
	replace naz WITH "Nivo prod"
	MsgC()
	
endif

CLOSE ALL

O_OSOB

if (RECCOUNT2()==0)
	
	MsgO("Kreiram ini OSOB")
	APPEND BLANK
	replace id with "0001"
	replace korSif with CryptSc(PADR("PARSON",6))
	replace naz with "Admin"
	replace status with "0"
	
	APPEND BLANK
	replace id with "0005"
	replace korSif with CryptSc(PADR("UPRAVN",6))
	replace naz with "Upravnik"
 	replace status with "1"

	APPEND BLANK
	replace id with "0010"
	replace korSif with CryptSc(PADR("P1",6))
	replace naz with "Prodavac 1"
 	replace status with "3"
	
	APPEND BLANK
	replace id with "0011"
	replace korSif with CryptSc(PADR("P2",6))
	replace naz with "Prodavac 2"
 	replace status with "3"
	MsgC()
endif

CLOSE ALL

return
*}

function BrisiDupleSifre()
*{
local nTekRec

nCounter:=0

if !SigmaSif("BRDPLS")
	return
endif

O_ROBA
select roba
set order to tag ID
go top
Box(,3,60)
aPom:={}
do while !eof()
	if (_OID_ == 0)
		// vec ova cinjenica govori nam da stavka nije u redu
		skip
		nTekRec := RECNO()
		skip -1
		AADD(aPom, {id, naz})
		DELETE
		// sljedeci zapis
		nCounter++
		go nTekRec
		// idemo na vrh petlje
		LOOP
	endif
	cId:=id
	@ m_x+1, m_y+2 SAY cId
	skip 
	if (roba->id == cId)
		// ako je dupli zapis, izbrisi drugi
		// cinjenica je medjutim da nismo siguruni da smo izbrisali pravu sifru, ali pretpostavljam da ce se uvijek naci _OID_ = 0 sifre.
		skip
		nTekRec := RECNO()
		skip  -1
		AADD(aPom, {id, naz})
		DELETE
		nCounter++
		// sljedeci zapis
		go nTekRec
		// idemo na vrh petlje
		LOOP
	else
		skip -1
	endif
	skip
enddo										BoxC()

START PRINT CRET

? "Pobrisanih sifara " + ALLTRIM(STR(nCounter))
? "---------------------------"
for i:=1 to LEN(aPom)
	? aPom[i, 1] + " - " + aPom[i, 2] 
next
?

END PRINT

return
*}



function UzmiBkIzSez()
*{
if !SigmaSif("BKIZSEZ")
	MsgBeep("Ne cackaj!")
	return
endif

Box(,5,60)
	cUvijekUzmi := "N"
	@ 1+m_x, 2+m_y SAY "Uvijek uzmi BARKOD iz sezone (D/N)?" GET cUvijekUzmi PICT "@!" VALID cUvijekUzmi $ "DN"
	
	read
BoxC()

O_ROBA
O_ROBASEZ

select roba

set order to tag "ID"
go top

Box(,3,60)

do while !eof()
	
	cIdRoba := roba->id
	
	SELECT robasez
	set order to tag "ID"
	hseek cIdRoba
	
	if !Found()
		select roba
		skip
		loop
	endif
	
	cBkSez := robasez->barkod
	
	@ m_x+1,m_y+2 SAY "Roba : " + cIdRoba
	
	if (EMPTY( roba->barkod ) .and. !empty(cBkSez)) .or. ((cUvijekUzmi == "D") .and. !empty(cBkSez))
		
		select roba
		replace barkod with cBkSez
		
		@ m_x+2, m_y+2 SAY "set Barkod " + cBkSez
	endif
	
	SELECT ROBA
	skip
	
enddo		

BoxC()

MsgBeep("Setovao barkodove iz sezonskog podrucja")
return
*}

function SetPdvCijene()
*{
if !SigmaSif("SETPDVC")
	MsgBeep("Ne cackaj!")
	return
endif

//ppp tarifa
cIdTarifa:=SPACE(6)

cZaTarifu:=SPACE(6)
nZaokruzenje:=2
cPdvTarifa:=PADR("PDV17", 6)

O_ROBA
O_ROBASEZ
O_TARIFA


SET CURSOR ON
Box(,5,60)
	cUvijekUzmi := "N"
	@ 1+m_x, 2+m_y SAY "Set cijene za tarifu  (prazno sve tarife)?" GET cZaTarifu PICT "@!" VALID  EMPTY(cZaTarifu) .or. P_Tarifa(@cZaTarifu)
	@ 2+m_x, 2+m_y SAY "Zaokruzenje cijene na koliko decimala "  get nZaokruzenje PICT "9"
	@ 3+m_x, 3+m_y SAY "PDV tarifa " GET cPdvTarifa VALID P_Tarifa(@cPdvTarifa)
	READ
	
BoxC()


select roba

set order to tag "ID"
go top

Box(,3,60)

aPorezi := {}

do while !eof()
	
	cIdRoba := roba->id
	
	SELECT robasez
	set order to tag "ID"
	hseek cIdRoba
	
	if !Found()
		select roba
		skip
		loop
	endif

	cIdTarifa:=robasez->idtarifa
	nMpcSaP1 := robasez->cijena1
	nMpcSaP2 := robasez->cijena2
	
	
	if !empty(cZaTarifu) .and. (cIdTarifa <> cZaTarifu)
		select roba
		skip
		loop	
	endif
	
	@ m_x+1,m_y+2 SAY "Roba / Tarifa : " + cIdRoba + "/" + cIdTarifa

	// ako je konto prazan, onda gledaj samo sifrarnik
	Tarifa( "", cIdRoba, @aPorezi, cIdTarifa)
	
	
	// nc = 99999 jer je ne trebamo
	nMpcBP1 := MpcBezPor( nMpcSaP1, aPorezi, , 99999)
	nMpcBP2 := MpcBezPor( nMpcSaP2, aPorezi, , 99999)

	SELECT tarifa
	SEEK cPdvTarifa
	nPdvTarifa := tarifa->opp
	
	nPdvC1 := nMpcBP1 * ( 1 + nPdvTarifa/100 )
	nPdvC1 := ROUND( nPdvC1, nZaokruzenje)
		
	nPdvC2 := nMpcBP2 * ( 1 + nPdvTarifa/100 )
	nPdvC2 := ROUND( nPdvC2, nZaokruzenje)

	SELECT ROBA
	replace Cijena1 with nPdvC1, Cijena2 with nPdvC2, ;
	        IdTarifa with cPdvTarifa
		
 	
	skip
	
enddo		

BoxC()

MsgBeep("Formirao PDV cijene u sifrarniku TOPS")
return
*}


