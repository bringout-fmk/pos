#include "pos.ch"


/*! \file  fmk/pos/db/1g/db.prg
    \brief Funkcije nad bazom podataka POS
 */


/*! \fn PostojiPromet()
 *  \brief Provjerava postojanje zapisa u DOKSu
 */
 
function PostojiPromet()
*{

O_DOKS
select doks
if reccount2()==0
	use
   	return .f.
else
   	use
   	return .t.
endif
*}


/*! \fn PostojiDokument(cTipDok, dDate)
 *  \brief Provjerava da li postoje dokumenti cTipDok na datum dDate
 *  \param cTipDok - tip dokumenta, npr "42" - racun, "19" - nivelacija
 *  \param dDate - datum dokumenta
 *  \return .t. ako postoji, .f. ako ne postoji
 */
function PostojiDokument(cTipDok, dDate)
*{
O_DOKS
select doks
set order to tag "2"
seek cTipDok + DTOS(dDate)

if Found()
	return .t.
else
	return .f.
endif

return
*}


/*! \fn StanjeRoba(_IdPos,_IdRoba)
 *  \brief
 *  \param _IdPos
 *  \param _IdRoba
 *  \return nStanje
 */
 
function StanjeRoba(_IdPos, _IdRoba)
*{

local nStanje

select pos
//"5", "IdPos+idroba+DTOS(Datum)", KUMPATH+"POS")
set order to 5  
seek _IdPos+_idroba

nStanje:=0

do while !eof() .and. pos->(IdPos+IdRoba)==(_IdPos+_IdRoba)
	if POS->idvd $ "16#00"
        	nStanje += POS->Kolicina
        elseif Pos->idvd $ "IN"
          	nStanje += POS->Kol2 - POS->Kolicina
        elseif POS->idvd $ "42#01#96"
          	nStanje -= POS->Kolicina
        endif
        SKIP
enddo
select pos
set order to 1
return nStanje
*}


/*! \fn OpenPos()
 *  \brief Uzmi datumski period, odredi vrste dokumenata
 */
 
function OpenPos()
*{

O_RNGOST
O_VRSTEP
O_DIO
O_ODJ
O_KASE
O_OSOB
set order to tag "NAZ"
O_TARIFA 
O_VALUTE
O_SIFK
O_SIFV
O_SIROV
O_ROBA

O_DOKS
O_POS
return
*}

/*! \fn OSif()
 *  \brief
 */
 
function OSif()
*{

O_KASE
O_UREDJ
if gModul=="HOPS"
	O_MJTRUR
  	O_ROBAIZ
  	O_SAST
  	O_SIROV
  	O_DIO
endif
O_ODJ
O_ROBA
O_TARIFA
O_VRSTEP
O_VALUTE
O_RNGOST

O_OSOB
O_STRAD

O_SIFK
O_SIFV

return
*}


/*! \fn O_InvNiv()
 *  \brief
 */
 
function O_InvNiv()
*{

O_UREDJ
O_MJTRUR
O_ODJ
O_DIO

O_SIFK
O_SIFV

O_SAST
O_SIROV
O_ROBA

O_DOKS
O_POS
O__POS
O_PRIPRZ
return
*}


/*! \fn OpenZad()
 *  \brief
 */
 
function OpenZad()
*{
O_UREDJ
O_MJTRUR
O_ODJ  
O_DIO
O_TARIFA

O_DOKS
O_POS
O__POS
O_PRIPRZ

O_SIFK
O_SIFV

O_ROBA 
O_SIROV
return
*}

/*! \fn ODbRpt()
 *  \brief Otvori database  za izvjestaje
 */
 
function ODbRpt()
*{

O_OSOB
O_SIFK
O_SIFV
O_VRSTEP 
O_ROBA
O_ODJ 
O_DIO
O_KASE
O_POS
O_DOKS
return
*}


/*! \fn O_Nar()
 *  \brief
 */
 
function O_Nar()
*{

if gPratiStanje $ "D!"
	O_POS
endif

if gModul=="HOPS"
	O_DIO 
	O_ROBAIZ
endif

O_MJTRUR 
O_UREDJ 
O_ODJ 
O_K2C
O_ROBA
O_SIFK
O_SIFV
O__PRIPR 
O__POS

return
*}


/*! \fn O_StAzur()
 *  \brief
 */
 
function O_StAzur()
*{
O__POS
O_ODJ
O_VRSTEP
O_RNGOST
O_OSOB
O_VALUTE
O_TARIFA
O_DOKS
O_POS
O_ROBA
return
*}

/*! \fn RacIznos(cIdPos,cIdVD,dDatum,cBrDok)
 *  \brief
 *  \param cIdPos
 *  \param cIdVD
 *  \param dDatum
 *  \param cBrDok
 *  \return nIznos   - iznos racuna
 */
 
function RacIznos(cIdPos,cIdVD,dDatum,cBrDok)
*{

if cIdPos==nil
	cIdPos:=doks->IdPos
  	cIdVD:=doks->IdVD
  	dDatum:=doks->Datum
  	cBrDok:=doks->BrDok
endif

nIznos:=0
SELECT POS
Seek2(cIdPos+cIdVd+dtos(dDatum)+cBrDok)
do while !eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==(cIdPos+cIdVd+dtos(dDatum)+cBrDok)
	nIznos+=POS->(Kolicina * Cijena)
  	SKIP
end
SELECT DOKS
return (nIznos)
*}



// Ovo je bilo ali mi je nelogicno !!!
//function DokIznos(fUI,cIdPos,cIdVD,dDatum,cBrDok)

/*! \fn DokIznos(lUI)
 *  \brief funkcija vraca ukupan iznos iz pregleda racuna
 *  \lUI - True - ulazi; False - izlazi; NIL - stanje bez obzira na prirodu dokumenta
 */

function DokIznos(lUI)
*{
local cRet:=SPACE(13)
local l_u_i
local nIznos:=0
local cIdPos, cIdVd, cBrDok
local dDatum

SELECT doks

cIdPos:=doks->idPos
cIdVd:=doks->idVd
cBrDok:=doks->brDok
dDatum:=doks->datum

//SEEK cIdPos + cIdVd + DTOS(dDatum) + cBrDok
 
 
if ((lUI==NIL) .or. lUI)
	// ovo su ulazi ...
    	if doks->IdVd $ VD_ZAD+"#"+VD_PCS+"#"+VD_REK
      		SELECT pos
      		SEEK cIdPos+cIdVd+DTOS(dDatum)+cBrDok
      		do while !eof().and.pos->(IdPos+IdVd+DTOS(datum)+BrDok)==cIdPos+cIdVd+DTOS(dDatum)+cBrDok
        		nIznos+=pos->kolicina*pos->cijena
        		SKIP
      		enddo
		if doks->idvd==VD_REK
			nIznos:=-nIznos
		endif
    	endif
	
endif

if ((lUI==NIL) .or. !lUI)
	// ovo su, pak, izlazi ...
    	if doks->IdVd $ VD_RN+"#"+VD_OTP+"#"+VD_RZS+"#"+VD_PRR+"#"+"IN"+"#"+"IN"

      		SELECT pos
      		SEEK cIdPos+cIdVd+DTOS(dDatum)+cBrDok
      		do while !eof() .and. pos->(IdPos+IdVd+DTOS(datum)+BrDok)==cIdPos+cIdVd+DTOS(dDatum)+cBrDok
        		do case
          			case doks->IdVd=="IN"
            				nIznos+=(pos->kol2-pos->kolicina)*pos->cijena
          			case doks->IdVd==VD_NIV
            				nIznos+=pos->kolicina*(pos->nCijena-POS->Cijena)
          			otherwise
            				nIznos+=pos->kolicina*pos->cijena
        		endcase
        		SKIP
      		enddo
    	endif
endif

SELECT doks
cRet:=STR(nIznos,13,2)

return (cRet)
*}



/*! \fn _Pripr2_POS()
 *  \brief
 */
 
function _Pripr2_POS(cIdVrsteP)
local cBrdok
local nTrec := 0
local nPopust

// prebacit ce u _POS sadrzaj _PRIPR

if cIdVrsteP == nil
	cIdVrsteP := ""
endif

nPopust := 0

if IsPlanika() .and. !EMPTY(cIdVrsteP)
	get_vrpl_popust(cIdVrsteP, @nPopust)
endif

select _pripr
go top

cBrdok:=brdok

do while !eof()
	
	Scatter()
	
	select _pos
  	append blank
  	
	if (gRadniRac=="N")
   		// u _PRIPR mora biti samo jedan dokument!!!
		_brdok:=cBrDok   
  	endif

	altd()
	
	_IdVrsteP := cIdVrsteP
  	
	if ( IsPlanika() .and. nPopust > 0 ;
		.and. gPopust == 0 .and. gPopIznP == 0 ;
		.and. !gClanPopust )
		
		_ncijena := ROUND( _cijena * nPopust / 100, gPopDec )
	endif
	
	gather()
  	
	select _pripr
  	skip
enddo

SELECT _PRIPR
Zapp () 
__dbPack()
return


  
/*! \fn BrisiDok(cIdPos,cIdVD,dDatum,cBrojR)
 *  \brief
 *  \param cIdPos
 *  \param cIdVD
 *  \param dDatum
 *  \param cBrojR
 */
 
function BrisiDok(cIdPos,cIdVD, dDatum, cBrojR)
*{
local cDatum

SELECT POS
cDatum:=DTOS(dDatum)
set order to 1
Seek cIdPos+cIDVD+cDatum+cBrojR
do while !eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==(cIdPos+cIdVD+cDatum+cBrojR)
	skip
	nTTR:=recno()
	skip -1
        delete        // DOKS
        sql_azur(.t.)
        sql_delete()
        go nTTR
enddo
SELECT DOKS
delete       // DOKS
sql_azur(.t.)
sql_delete()
return
*}


/*! \fn IspraviDV(cLast, dOrigD, dDatum, cVrijeme, cBroj)
 *  \brief Ispravi datum i vrijeme racuna
 *  \param cLast
 *  \param dOrigD
 *  \param dDatum
 *  \param cVrijeme
 *  \param cNBrDok - novi broj, ako je nil ne mjenjaj broj
 */
 
function IspraviDV(cLast, dOrigD, dDatum, cVrijeme, cNBrDok)
*{
local cBrDok
local fSvi

fSvi:=.f.
if (cNBrDok==nil) .and. Pitanje(,"Zelite li ispravku datuma SVIH RACUNA datuma " + dtoc(dOrigD) + " ?", "N")=="D"
	fSvi:=.t.
endif
cIdPos:=field->idPos 
cIdVd:=field->idVd
cBrDok:=field->brDok


SELECT doks
// prodji kroz sve racune ..."

do while (!EOF() .and. field->datum==dOrigD .and. field->idPos==cIdPos .and. field->idVd==cIdVd)
	
	cIdPos:=field->idPos 
	cIdVd:=field->idVd
	cBrDok:=field->brDok

	SKIP
        nTDRec:=recno()
        SKIP -1
        SELECT POS

	if (cNBrDok==nil) .and. IsDocExists(cIdPos, cIdVd, dDatum, cBrDok)
		// kada mjenjam broj dokumenta interesuje cBrDok
		MsgBeep("Vec postoji racun pod istim brojem "+cIdPos+"-"+cIdVd+"-"+cBrDok+"/"+DTOC(dDatum))
		go nTDRec
		loop
	endif
	

	if (cNBrDok<>nil) .and. IsDocExists(cIdPos, cIdVd, dDatum, cNBrDok)
		// kada mjenjam broj dokumenta trazi cNBrDok
		MsgBeep("Vec postoji racun pod brojem "+cIdPos+"-"+cIdVd+"-"+cNBrDok+"/"+DTOC(dDatum))
		go nTDRec
		loop
	endif


	// POS
        SELECT pos
	seek cIdPos+cIdVd+DTOS(dOrigD)+cBrDok
        do while (!EOF() .and. cIdPos+cIdVd+DTOS(dOrigD)+cBrDok==IdPos+IdVd+DTOS(datum)+BrDok)
	        skip
		nTTTrec:=recno()
		skip -1
                if cLast $ "DV"
                	REPLACE Datum with dDatum
			REPLSQL Datum WITH dDatum
                endif
		
                if ((cNBrDok<>nil) .and. (cBrDok<>cNBrDok))
			REPLACE brDok WITH cNBrDok
			REPLSQL brDok WITH cNBrDok
		endif
		
		go nTTTRec
        enddo

	// DOKS
        SELECT doks
	seek cIdPos+cIdVd+DTOS(dOrigD)+cBrDok
        if cLast $ "SV"
        	REPLACE Vrijeme with cVrijeme
        	REPLSQL Vrijeme with cVrijeme
        endif
        if cLast $ "DV"
        	REPLACE Datum with dDatum
        	REPLSQL Datum with dDatum
        endif
        if ((cNBrDok<>nil) .and. (cBrDok<>cNBrDok))
		REPLACE brDok WITH cNBrDok
		REPLSQL brDok WITH cNBrDok
	endif
	
        UzmiIzIni(PRIVPATH+"fmk.ini",'POS','XPM',"0000", 'WRITE')
        if !fSvi
		exit
	endif
        go nTDRec
enddo

return 1
*}


*string IzFmkIni_ExePath_TOPS_PitanjePrijeAzuriranja;
/*! \ingroup ini
 *  \var IzFmkIni_ExePath_TOPS_PitanjePrijeAzuriranja
 *  \brief Upit prije azuiranja racuna
 */

/*! \fn AzurRacuna(cIdPos,cStalRac,cRadRac,cVrijeme,cNacPlac,cIdGost)
 *  \brief Azuriranje racuna ( _POS->POS, _POS->DOKS )
 *  \param cIdPos
 *  \param cStalRac    - prilikom azuriranja daje se broj cStalRac
 *  \param cRadRac     - racun iz _POS.DBF sa brojem cRadRac se prenosi u POS, DOKS
 *  \param cVrijeme
 *  \param cNacPlac
 *  \param cIdGost
 */
 
function AzurRacuna(cIdPos, cStalRac, cRadRac, cVrijeme, cNacPlac, cIdGost)
*{

local cDatum
local nStavki

lNaX:=.f.

altd()
if IzFmkIni("TOPS","PitanjePrijeAzuriranja","N",EXEPATH)=="D"
	lNaX:=(Pitanje(,"Azurirati racun? (D/N)","D")=="N")
endif

if (cNacPlac==nil)
	cNacPlac:=gGotPlac
endif
if (cIdGost==nil)
	cIdGost:=""
endif

SELECT _POS
SEEK cIdPos+"42"+dtos(gDatum)+cRadRac
Scatter()

SELECT DOKS
_BrDok:=cStalRac
_Vrijeme:=cVrijeme
_IdVrsteP:=cNacPlac
_IdGost:=cIdGost
_IdOdj:=SPACE(LEN(_IdOdj))
_M1:=OBR_NIJE

if gModul == "HOPS" .and. gBrojSto=="D"
	_Zakljucen:="N"
endif

//Append Blank  radi mreza ne idemo na ovu varijantu!
seek cIdPos+"42"+dtos(gdatum)+cStalRac
if (field->idRadnik != "////")
	MsgBeep("Nesto nije u redu zovite servis - radnik bi morao biti //// !!!")
endif

if lNaX
	nTRec:=RECNO()
  	_BrDok:=cStalRac:=NarBrDok("X ","42")
  	_idpos:="X "
  	GO (nTRec)
endif

Gather()
sql_azur(.t.)
GathSQL()

SELECT _POS
// uzmi gDatum za azuriranje
cDatum:=dtos(gDatum)  
private nIznRn:=0

do while !eof() .and. _POS->(IdPos+IdVd+dtos(Datum)+BrDok)==(cIdPos+"42"+cDatum+cRadRac)
	Scatter()
  	_Kolicina:=0
  	do while !eof() .and. _POS->(IdPos+IdVd+dtos(Datum)+BrDok)==(cIdPos+"42"+cDatum+cRadRac) .and._POS->(IdRoba+IdCijena)==(_IdRoba+_IdCijena) .and._POS->Cijena==_Cijena
    		// saberi ukupnu kolicinu za jedan artikal
    		if gRadniRac="D".and.gVodiTreb=="D".and.GT=OBR_NIJE
      			// vodi se po trebovanjima, a za ovu stavku trebovanje nije izgenerisano
      			replace kolicina with 0 // nuliraj kolicinu
    		endif
		
		_Kolicina += _POS->Kolicina
    		REPLACE m1 WITH "Z"
    		if lNaX
      			SKIP 1
			nTRec:=RECNO()
      			SKIP -1
      			REPLACE idpos WITH "X "
      			GO (nTRec)
    		else
      			SKIP 1
    		endif
	enddo
  	_Prebacen:=OBR_NIJE
  	SELECT ODJ
  	HSEEK _IdOdj
  	if odj->Zaduzuje=="S"
    		_M1 := OBR_NIJE
  	else
    		// za robe (ako odjeljenje zaduzuje robe) ne pravim razduzenje
    		// sirovina
    		_M1 := OBR_JEST
  	endif
  	if ROUND(_kolicina,4)<>0
		SELECT POS
		_BrDok:=cStalRac
		_Vrijeme:=cVrijeme
		_IdVrsteP:=cNacPlac
		_IdGost:=cIdGost
		append blank
		Sql_append()
		if lNaX
	  		_idpos:="X "
		endif
		Gather()
		Sql_azur(.t.)
		GathSQL()
		nIznRn+=POS->Kolicina * POS->cijena
  	endif
  	select _pos
enddo

// ako se koristi varijanta evidentiranja podataka o nacinu placanja
// nIznRn = iznos zakljucenog racuna
// cStalRac = broj zakljucenog racuna
// cVrijeme = vrijeme zakljucenog racuna

if gEvidPl=="D"
	AzurCek(aCKData, nIznRN, cStalRac, cVrijeme)
	AzurSindKredit(aSKData, nIznRN, cStalRac, cVrijeme)
	AzurGarPismo(aGPData, nIznRN, cStalRac, cVrijeme)
endif

return
*}


/*! \fn AzurPriprZ(cBrDok,cIdVd)
 *  \brief priprz -> pos, doks
 *  \param cBrDok
 *  \param cIdVd
 */
 
function AzurPriprZ(cBrDok, cIdVd)
*{

SELECT PRIPRZ
GO TOP
Scatter()

SELECT DOKS
APPEND BLANK
sql_append()

_BrDok:=cBrDok 

altd()

// ako je zaduzenje pitaj da li je roba na stanju...
//g_roba_na_stanju(cIdVd)

// zakljucene stavke
if gBrojSto=="D"
	if cIdVd<>VD_RN
		_zakljucen := "Z"
	endif
endif


if (IsPlanika() .and. cIdVd==VD_REK)
	// reklamacija u pripremi ili realizovana
	_sto:=cRekOp4
endif
      
if cIdVd=="PD"
	_IdVd:="16"
else
	_IdVd:=cIdVd
endif

Gather()
sql_azur(.t.)
GathSQL()

SELECT PRIPRZ
// dodaj u datoteku POS
do while !eof()   
	
	SELECT PRIPRZ
	AzurRoba()
	SELECT PRIPRZ 

	Scatter ()
      	SELECT POS
      	APPEND BLANK
      	sql_append()
      	_BrDok := cBrDok
	if cIdVd=="PD"
		_IdVd:="16"
	else
		_IdVd:=cIdVd
	endif
	
	if cIdVD=="PD"
        	// !prva stavka storno
		_IdVd:="16"
        	_IdDio:=_IdVrsteP
        	_kolicina:=-_Kolicina
      	endif
      	Gather()
      	sql_azur(.t.)
      	GathSQL()
      	if cIdVD=="PD"  // druga stavka
        	append blank
        	sql_append()
        	// !druga stavka storno storna = "+"
		_idvd:="16"
        	// odjeljenje 2
		_IdOdj:=_IdVrsteP  
        	_IdDio:=""
        	_IdVrsteP:=""
        	_kolicina:=-_Kolicina
        	Gather()
        	sql_azur(.t.)
        	GathSQL()
	endif

      	SELECT PRIPRZ
      	Del_Skip()
enddo

SELECT PRIPRZ
__dbPack()

return
*}


// -----------------------------------
// da li je roba na stanju...
// -----------------------------------
function roba_na_stanju(cIdPos, cIdVd, cBrDok, dDatDok)
local lRet := .t.
local nTArea := SELECT()
O_DOKS
select doks
set order to tag "1"
seek cIdPos + cIdVd + DTOS(dDatDok) + cBrDok

if FOUND()
	if ALLTRIM(field->sto) == "N"
		lRet := .f.
	endif
endif

select (nTArea)
return lRet



// ---------------------------------------------------
// funkcija koja poziva upit da li je roba na stanju
// ---------------------------------------------------
function g_roba_na_stanju(cIdVd)
local cRobaNaStanju := "N"

// ako je ovaj parametar aktivan... prekoci
if gBrojSto == "D"
	return
endif

// ako nije zaduzenje - prekoci
if cIdVD <> VD_ZAD
	return
endif

//box_roba_stanje(@cRobaNaStanju)

// setuj robu na stanju pri importu zaduzenja na N
_sto := cRobaNaStanju

return

// -------------------------------
// box roba na stanju
// -------------------------------
function box_roba_stanje(cRStanje)
private GetList:={}

if EMPTY(cRStanje)
	cRStanje := "D"
endif

Box(,3, 50)
	@ 2+m_x, 2+m_y SAY "Da li je roba zaprimljena u prodavnicu (D/N)?" GET cRStanje VALID cRStanje $ "DN" PICT "@!"
	read
BoxC()

if LastKey() == K_ESC
	cRStanje := cRStanje
	return 0
endif

return 1


/*! \fn VratiPripr(cIdVd,cIdRadnik,cIdOdj,cIdDio)
 *  \brief
 *  \param cIdVd
 *  \param cIdRadnik
 *  \param cIdOdj
 *  \param cIdDio
 */

function VratiPripr(cIdVd,cIdRadnik,cIdOdj,cIdDio)
*{

local cSta
local cBrDok

do case
	case cIdVd == VD_ZAD
    		cSta:="zaduzenja"
  	case cIdVd == VD_OTP
    		cSta:="otpisa"
  	case cIdVd == VD_INV
    		cSta:="inventure"
  	case cIdVd == VD_NIV
    		cSta:="nivelacije"
	otherwise 
		cSta:="ostalo"
endcase

SELECT _POS
set order to 2         
// IdVd+IdOdj+IdRadnik

Seek cIdVd+cIdOdj+cIdDio
if FOUND()      
// .and. (Empty (cIdDio) .or. _POS->IdDio==cIdDio)
	if _POS->IdRadnik <> cIdRadnik
    		// ne mogu dopustiti da vise radnika radi paralelno inventuru, nivelaciju
    		// ili zaduzenje
    		MsgBeep ("Drugi radnik je poceo raditi pripremu "+cSta+"#"+"AKO NASTAVITE, PRIPREMA SE BRISE!!!", 30)
    		if Pitanje(,"Zelite li nastaviti?", " ")=="N"
      			return .f.
    		endif
    		// xIdRadnik := _POS->IdRadnik
    		do while !eof() .and. _POS->(IdVd+IdOdj+IdDio)==(cIdVd+cIdOdj+cIdDio)     
			// IdRadnik, xIdRadnik
      			Del_Skip()
    		end do
    		MsgBeep("Izbrisana je priprema "+cSta)
  	else
    		Beep (3)
    		if Pitanje(,"Poceli ste pripremu! Zelite li nastaviti? (D/N)"," ") == "N"
      			// brisanje prethodne pripreme
      			do while !eof() .and. _POS->(IdVd+IdOdj+IdDio)==(cIdVd+cIdOdj+cIdDio)
        			Del_Skip()
      			enddo
      			MsgBeep ("Priprema je izbrisana ... ")
    		else
      			// vrati ono sto je poceo raditi
      			SELECT _POS
      			do while !eof() .and. _POS->(IdVd+IdOdj+IdDio)==(cIdVd+cIdOdj+cIdDio)
        			Scatter()
        			SELECT PRIPRZ
        			Append Blank
        			Gather()
        			SELECT _POS
        			Del_Skip()
      			enddo
      			SELECT PRIPRZ
      			GO TOP
    		endif
  	endif
endif
SELECT _POS
Set order to 1
return .t.
*}


/*! \fn ReindPosPripr()
 *  \brief
 */
 
function ReindPosPripr()
*{

MsgO("Sacekajte trenutak...") 
O__POS
reindex
use
O__PRIPR
reindex
use
MsgC()

return
*}


/*! \fn DBZakljuci()
 *  \brief _POS -> ZAKSM
 */
 
function DBZakljuci()
*{

close all
O_OSOB
set order to tag "NAZ"
O_POS 
O_DOKS
set order to 2
O__POS
set order to 1

aDbf:={}
AADD(aDbf, {"IdRadnik", "C",  4, 0})
AADD(aDbf, {"NazRadn",  "C", 30, 0})
AADD(aDbf, {"Zaklj",    "N", 12, 2})
AADD(aDbf, {"Otv",      "N", 12, 2})
Dbcreate2(PRIVPATH+"ZAKSM", aDbf)

select (F_ZAKSM)
USEX (PRIVPATH+"ZAKSM")
INDEX ON IdRadnik TAG ("1")           
index ON BRISANO+"10" TAG "BRISAN" 
Set Order To 1

// pokupi nezakljucene racune....................
SELECT _POS
Seek gIdPos+"42"
do while !eof() .and. _POS->(IdPos+IdVd)==(gIdPos+"42")
	if _POS->Datum==gDatum
    		if _POS->M1 <> "Z"
      			nOtv:=_POS->(Kolicina*Cijena)
      			nZaklj:=0
    		endif
    		SELECT ZAKSM
		Seek _POS->IdRadnik
    		if !FOUND()
      			Append Blank
      			REPLACE IdRadnik WITH _POS->IdRadnik
      			SELECT OSOB
			HSEEK _POS->IdRadnik
      			SELECT ZAKSM
      			REPLACE NazRadn WITH OSOB->Naz
    		endif
    		REPLACE Otv WITH Otv+nOtv
    		SELECT _POS
  	endif
  	SKIP
enddo
//
// Pokupi ono sto je zakljuceno (od racuna)
//

SELECT DOKS  
// "2", "IdVd+DTOS (Datum)+Smjena"
// prodji kroz DOKS (i POS) da napunis iznosima ZAKSM
SEEK "42"+DTOS(gDatum)+gSmjena
do while !EOF() .and. DOKS->IdVd=="42" .and. DOKS->Datum==gDatum .and. DOKS->Smjena == gSmjena
	if DOKS->IdPos <> gIdPos
    		SKIP
		LOOP
  	endif
  	SELECT ZAKSM
  	HSEEK DOKS->IdRadnik
  	if FOUND()
    		SELECT POS
    		HSEEK DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
    		nIzn := 0
    		do while !eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
      			nIzn += POS->(Kolicina*Cijena)
      			SKIP
    		enddo
    		// azuriraj iznos zakljucenih racuna
    		SELECT ZAKSM
    		REPLACE Zaklj WITH Zaklj+nIzn
	endif
  	SELECT DOKS
	SKIP
enddo

return
*}


/*! \fn UkloniRadne(cIdRadnik)
 *  \brief Ukloni radne racune (koj se nalaze u _POS tabeli)
 *  \param cIdRadnik
 */
 
function UkloniRadne(cIdRadnik)
*{

SELECT _POS
Set order to 1
SEEK gIdPos+VD_RN
while !eof() .and. _POS->(IdPos+IdVd)==(gIdPos+VD_RN)
	if _POS->IdRadnik==cIdRadnik .and. _POS->M1 == "Z"
    		Del_Skip ()
  	else
    		SKIP
  	endif
end
SELECT ZAKSM
return
*}

/*! \fn NarBrDok(cIdPos,cIdVd,cPadCh,dDat)
 *  \brief Naredni broj dokumenta
 *  \param cIdPos
 *  \param cIdVd
 *  \param cPadCh
 *  \param dDat
 *  \return cBrDok
 */
 
function NarBrDok(cIdPos,cIdVd,cPadCH,dDat)
*{

local cBrDok
local cFilter
local nRecs:=RecCount2()
local cBrDok1
local nObr:=0

if dDat==nil
	dDat:=gDatum
endif

seek cIdPos+cIdVd+chr(254)
if (IdPos+IdVd)<>(cIdPos+cIdVd)
	skip -1
endif

if (IdPos+IdVd)<>(cIdPos+cIdVd) .or. (year(dDat)>year(datum)) .or. (gSezonaTip=="M" .and. month(dDat)>month(datum) ) // m-tip i mjesec razlicit
	cBrDok:=SPACE(LEN(BrDok))
else
	cBrDok:=BrDok
endif

cBrdok:=(IncID(cBrDok,cPadCh))
cBrDok1:=cBrDok
nObr:=0

do while .t.
	if nObr>nRecs
   		// reindeksiraj pa trazi ispocetka
   		Reind_PB()
   		cBrDok:=cBrDok1
   		nObr:=0
 	endif
 	SEEK cidpos+cidvd+dtos(dDat)+cbrdok
 	if FOUND()
   		++nObr
   		cBrDok:=IncID (cBrDok, cPadCh)
 	else
   		EXIT
 	endif
enddo
return cBrDok
*}



/*! \fn Reind_PB()
 *  \brief Reindeksiraj _POS i DOKS 
 */
 
function Reind_PB()
*{ 

local cAlias:=ALIAS(SELECT())

MsgO("Indeksi nisu u redu?! Sacekajte trenutak da reindeksiram...")   

if UPPER(cAlias)="_POS"
	SELECT _POS
	USE
       	O__POS
       	reindex
	USE
       	O__POS
elseif UPPER(cAlias)="DOKS"
       	SELECT DOKS
	USE
       	OX_DOKS
       	reindex
	USE
       	O_DOKS
endif
MsgC()

return
*}



/*! \fn Del_Skip()
 *  \brief Namijenjena da se prevazidje problem kad se radi klasicni Delete i SKIP
 */ 
 
function Del_Skip()
*{
local nNextRec

nNextRec:=0
SKIP
nNextRec:=RECNO()
Skip -1
DELETE
GO nNextRec
return
*}


/*! \fn GoTop2()
 *  \brief Skipuje prvi Deleted() slog nakon GO TOP
 */
 
function GoTop2()
*{
GO TOP
if DELETED()
	SKIP
endif
return
*}


/*! \fn GenDoks()
 *  \brief Generisanje DOKS-a iz POS-a
 */
 
function GenDoks()
*{

if !SigmaSif("GENDOKS")
	return
endif
close all

O_DOKS

Box(,1,60)
	cTipDok := SPACE(2)
	@ 1+m_x, 2+m_y SAY "Tip dokumenta (prazno-svi)" GET cTipDok
	read
BoxC()

if Empty(ALLTRIM(cTipDok)) .and. Pitanje(,"Izbrisati doks ??","N")=="D"
	ZAPP()
	if gSQL=="D"
		Gw("update doks set BRISANO='1'")
   		Gw("delete from doks")
	endif
endif

O_POS
GO TOP

do while !eof()
	
	if !Empty(ALLTRIM(cTipDok))
		if pos->idvd <> cTipDok
			skip
			loop
		endif
	endif
	
	Scatter()
  	do while !eof() .and. _idpos==idpos .and. _idvd==idvd .and. _Datum==datum.and._brdok==brdok
     		skip
  	enddo
  	SELECT doks
	
	if !Empty(ALLTRIM(cTipDok))
		set order to tag "1"
		hseek _idpos + _idvd + DTOS(_datum)
		if Found()
			select pos
			skip
			loop
		endif
	endif
  	
	APPEND BLANK
	if gSQL=="D"
	  	sql_append()
	endif
  	replace idpos with _idpos,brdok with _brdok,idvd with _idvd,idradnik with _idradnik,smjena with _smjena,datum with _datum
	if gSQL=="D"
  		sql_azur(.t.)
	  	replsql idpos with _idpos, brdok with _brdok, idvd with _idvd,idradnik with _idradnik,smjena with _smjena,datum with _datum
	endif
  	SELECT pos
enddo
close all
return
*}


/*! \fn SR_ImaRobu(cPom,cIdRoba)
 *  \brief Funkcija koja daje .t. ako se cIdRoba nalazi na posmatranom racunu
 *  \param cPom
 *  \param cIdRoba
 */
 
function SR_ImaRobu(cPom,cIdRoba)
*{

local lVrati:=.f.
local nArr:=SELECT()

SELECT POS
Seek2(cPom+cIdRoba)

if POS->(IdPos+IdVd+dtos(datum)+BrDok+idroba)==cPom+cIdRoba
	lVrati:=.t.
endif

SELECT (nArr)
return (lVrati)
*}


/*! \fn Pos2_Pripr()
 *  \brief Prebaci racun iz POS u _PRIPR
 */
 
function Pos2_Pripr()
*{

SELECT _PRIPR
Zapp()
Scatter()

SELECT POS
seek DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
do while !eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
	Scatter ()
  	SELECT ROBA
  	HSEEK _IdRoba
  	_RobaNaz:=ROBA->Naz
  	_Jmj:=ROBA->Jmj
  	SELECT _PRIPR
  	Append Blank // _PRIPR
  	Gather()
  	SELECT POS
  	SKIP
enddo
SELECT _PRIPR
return
*}

/*! \fn NemaPrometa(cStariId, cNoviId)
 *  \brief Provjerava da li je bilo prometa
 *  \note ernad: Ugasio sam ovu funkciju .. administrator valjda zna sta treba da radi
 *  \todo promjenu Id-a prodajnog mjesta treba biti dostupna samo za L_ADMIN
 */
 
function NemaPrometa(cStariId, cNoviId)
*{

return .t.
/*
  if (cStariId == cNoviId)
    return .t.
  endif
  
  nPrev := SELECT()
  SELECT _POS
  Seek (cStariId)
  SELECT (nPrev)
  If _POS->(Found())
    MsgBeep ("Postoje dokumenti s starim ID prodajnog mjesta!!!#"+;
             "Promjena nije dozvoljena!!!")
    Return .F.
  EndIF
*/
return .t.
*}

/*! \fn Priprz2Pos()
 *  \brief prebaci iz priprz -> pos,doks
 *  \note azuriranje dokumenata zaduzenja, nivelacija
 *
 */

function Priprz2Pos()
*{
local lNivel

altd()
lNivel:=.f.

SELECT (cRsDbf)
SET ORDER TO TAG "ID"


SELECT PRIPRZ
GO TOP

Scatter()

SELECT DOKS
APPEND BLANK
sql_append()
Gather()

sql_azur(.t.)
GathSQL()


MsgO("prenos priprema->stanje")
// upis inventure/nivelacije
SELECT PRIPRZ  
do while !eof()
	Scatter()

	// dodaj stavku u pos
  	SELECT POS
	
	APPEND BLANK
	sql_append()
	
  	Gather()
  	sql_azur(.t.)
  	GathSQL()
	
  	SELECT PRIPRZ

	// azur sifrarnik robe na osnovu priprz
	AzurRoba()

	SELECT PRIPRZ
  	SKIP
enddo
MsgC()

MsgO("brisem pripremu....")
// ostalo je jos da izbrisemo stavke iz pomocne baze
SELECT PRIPRZ
Zapp()
MsgC()

return
*}



/*! \fn RealNaDan(dDatum)
 *  \brief Realizacija kase na dan = dDatum
 *
 */
function RealNaDan(dDatum)
*{
local nUkupno
local lOpened

SELECT(F_POS)
lOpened:=.t.
if !USED()
	O_POS
	lOpened:=.f.
endif


//"4", "dtos(datum)", KUMPATH+"POS"
SET ORDER TO TAG "4"
seek DTOS(dDatum)

nUkupno:=0
cPopust:=Pitanje(,"Uzeti u obzir popust","D")
do while !EOF() .and. dDatum==field->datum
	if field->idVd=="42"
		if cPopust=="D"
			nUkupno+=field->kolicina*(field->cijena-field->ncijena)
		else
			nUkupno+=field->kolicina*field->cijena
		endif
	endif
	SKIP
enddo

if !lOpened
	USE
endif
return nUkupno
*}


/*! \fn KasaIzvuci(cIdVd)
 *  \brief Punjenje podacima pomocne tabele za izvjestaj realizacije kase (tabela pos->pom)
 */

function KasaIzvuci(cIdVd, cDobId)
*{

// cIdVD - Id vrsta dokumenta
// Opis: priprema pomoce baze POM.DBF za realizaciju

if ( cDobId == nil )
	cDobId := ""
endif

if !gAppSrv
	MsgO("formiram pomocnu tabelu izvjestaja...")
endif

SEEK cIdVd+DTOS(dDat0)
do while !eof().and.doks->IdVd==cIdVd.and.doks->Datum<=dDat1

	if (kLevel>"0".and.doks->IdPos="X").or.(!EMPTY(cIdPos).and.doks->IdPos<>cIdPos).or.(!EMPTY(cSmjena).and.doks->Smjena<>cSmjena)
    		SKIP
		loop
  	endif
  	
	SELECT pos 
	SEEK doks->(IdPos+IdVd+dtos(datum)+BrDok)
  
  	do while !eof().and.pos->(IdPos+IdVd+dtos(datum)+BrDok)==doks->(IdPos+IdVd+dtos(datum)+BrDok)
    		if (!EMPTY(cIdOdj).and.pos->IdOdj<>cIdOdj).or.(!EMPTY(cIdDio).and.pos->IdDio<>cIdDio)
      			SKIP 
			loop
    		endif
    		
		SELECT roba 
		HSEEK pos->IdRoba

		if roba->(fieldpos("sifdob"))<>0
			if !Empty(cDobId)
				if roba->sifdob <> cDobId
					select pos
					skip
					loop
				endif
			endif
		endif
		
    		SELECT odj 
		HSEEK roba->IdOdj
		
		nNeplaca:=0
    		
		if RIGHT(odj->naz,5)=="#1#0#"  // proba!!!
     			nNeplaca:=pos->(Kolicina*Cijena)
    		elseif RIGHT(odj->naz,6)=="#1#50#"
     			nNeplaca:=pos->(Kolicina*Cijena)/2
    		endif
    		
		if gPopVar="P" 
			nNeplaca+=pos->(kolicina*nCijena) 
		endif

    		SELECT pom
		HSEEK doks->(IdPos+IdRadnik+IdVrsteP)+pos->(IdOdj+IdRoba+IdCijena)
		if !found()
      			APPEND BLANK
      			REPLACE IdPos WITH doks->IdPos,IdRadnik WITH doks->IdRadnik,IdVrsteP WITH doks->IdVrsteP,IdOdj WITH pos->IdOdj,IdRoba WITH pos->IdRoba,IdCijena WITH pos->IdCijena,Kolicina WITH pos->Kolicina,Iznos WITH pos->Kolicina*POS->Cijena,Iznos3 WITH nNeplaca
      			
			if gPopVar=="A"
         			REPLACE Iznos2 WITH pos->nCijena
      			endif

      			if roba->(fieldpos("K1")) <> 0
              			REPLACE K2 WITH roba->K2,K1 WITH roba->K1
      			endif
    		else
      			REPLACE Kolicina WITH Kolicina+POS->Kolicina,Iznos WITH Iznos+POS->Kolicina*POS->Cijena,Iznos3 WITH Iznos3+nNeplaca
      			if gPopVar=="A"
         			REPLACE Iznos2 WITH Iznos2+pos->nCijena
      			endif
    		endif
    		
		SELECT pos
    		skip
  	enddo
  	
	SELECT doks  
	skip

enddo

if !gAppSrv
	MsgC()
endif

return
*}


function IsDocExists(cIdPos, cIdVd, dDatum, cBrDok)
*{
local lFound

lFound:=.f.

SELECT POS	
PushWa()
SET ORDER TO TAG "1"
SEEK cIdPos+cIdVd+DTOS(dDatum)+cBrDok
if FOUND()
	lFound:=.t.
endif
PopWa()

SELECT DOKS
PushWa()
SET ORDER TO TAG "1"
SEEK cIdPos+cIdVd+DTOS(dDatum)+cBrDok

if FOUND()
	lFound:=.t.
endif
PopWa()

return lFound
*}


/*! \fn CreateTmpTblForDocReview()
 *  \brief Pravi pomocnu tabelu POM za stampu dokumenta iz pregleda dokumenata
 */
function CreateTmpTblForDocReView()
*{
aDbf := {}
AADD(aDbf, {"IdRoba",   "C", 10, 0})
AADD(aDbf, {"IdCijena", "C",  1, 0})
AADD(aDbf, {"Cijena",   "N", 10, 3})
AADD(aDbf, {"NCijena",   "N", 10, 3})
AADD(aDbf, {"Kolicina", "N", 10, 3})
AADD(aDbf, {"Datum", "D", 8, 0})

NaprPom (aDbf)

USEX (PRIVPATH+"POM") NEW

INDEX ON IdRoba+IdCijena+Str(Cijena, 10, 3) TAG ("1") TO (PRIVPATH+"POM")
set order to 1

return
*}

// ------------------------------------------
// azuriraj sifrarnik robe
// priprz -> roba
// ------------------------------------------
static function AzurRoba()

altd()
// u jednom dbf-u moze biti vise IdPos
// ROBA ili SIROV
select (cRSDbf)
set order to tag "ID"

// pozicioniran sam na robi
hseek priprz->idroba  

lNovi:=.f.
if (!FOUND())
	// novi artikal
	// roba (ili sirov)
	append blank
	sql_append()
	sql_azur(.t.)

	SmReplace("id", priprz->idroba)
	SmReplace("idodj", priprz->idodj)
	
endif

// azuriraj sifrarnik robe
SmReplace("naz", priprz->RobaNaz)
SmReplace("jmj", priprz->jmj)

if !IsPDV() 
	// u ne-pdv rezimu je bilo bitno da preknjizenje na pdv ne pokvari
	// star cijene
	if katops->idtarifa <> "PDV17"
		SmReplace("cijena1", ROUND(priprz->cijena, 3))
	endif
else

	if cIdVd == "NI"
	  // nivelacija - u sifrarnik stavi novu cijenu
	  SmReplace("cijena1", ROUND(priprz->ncijena, 3))
	else
	  SmReplace("cijena1", ROUND(priprz->cijena, 3))
	endif
	
endif

SmReplace("idtarifa", priprz->idtarifa)

if roba->(FIELDPOS("K1"))<>0  .and. priprz->(FIELDPOS("K2"))<>0
	SmReplace("k1", priprz->k1)
	SmReplace("k2", priprz->k2)
endif

if roba->(fieldpos("K7"))<>0  .and. priprz->(FIELDPOS("K9"))<>0
	SmReplace("k7", priprz->k7)
	SmReplace("k8", priprz->k8)
	SmReplace("k9", priprz->k9)
endif

if roba->(FIELDPOS("N1"))<>0  .and. priprz->(FIELDPOS("N2"))<>0
	SmReplace("n1", priprz->n1)
	SmReplace("n2", priprz->n2)
endif

if (roba->(FIELDPOS("BARKOD"))<>0 .and. priprz->(FIELDPOS("BARKOD"))<>0)
	SmReplace("barkod", priprz->barkod)
endif

sql_azur(.t.)

return

