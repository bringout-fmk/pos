#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/specif/tigra/1g/tigra.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.2 $
 * $Log: tigra.prg,v $
 * Revision 1.2  2002/06/17 12:02:55  sasa
 * no message
 *
 *
 */
 

/*! \fn tgrDuploAzur()
 *  \brief
 */
 
function tgrDuploAzur()
*{
// ni slucajno ne stavljati u SQL LOG !!!!!
// !!!!!(izazvalo bi dupliranje ) !!!!!!!!!
select pos
use
use (trim(gDuploKum)+"POS")
set order to 1  // pos2
select doks
use
use (trim(gDuploKum)+"doks")
set order to 1  // doks2
// utvrdi naredni broj dokumenta u doks 2
cStalRac:=NarBrDok(cIdPos,VD_RN)
select roba
use
use (trim(gDuploSif)+"Roba"); set order to tag "ID" // roba2

SELECT _POS
seek cIdPos+"42"+dtos(gDatum)+cRadRac
Scatter()
_BrDok:=cStalRac
_Vrijeme:=cVrijeme
_IdVrsteP := cNacPlac
_IdGost   := cIdGost
_IdOdj    := SPACE (LEN (_IdOdj))
_M1       := OBR_NIJE
SELECT _POS
cDatum:=dtos(gDatum)  // uzmi gDatum za azuriranje
nStavki:=0
do while !eof() .and. _POS->(IdPos+IdVd+dtos(Datum)+BrDok)==(cIdPos+"42"+cDatum+cRadRac)
	Scatter ()
       	_Kolicina := 0
       	select roba
	hseek _idroba
	select _pos
       	// pozicioniraj se na robe iz sifranika 2
       	do while !eof() .and. _POS->(IdPos+IdVd+dtos(Datum)+BrDok)==(cIdPos+"42"+cDatum+cRadRac) .and.;
        	_POS->(IdRoba+IdCijena)==(_IdRoba+_IdCijena) .and. ;
             	_POS->Cijena==_Cijena
         	// saberi ukupnu kolicinu za jedan artikal
         	if (gRadniRac="D" .and. gVodiTreb=="D" .and. GT=OBR_NIJE)
           		// vodi se po trebovanjima, a za ovu stavku trebovanje nije izgenerisano
           		replace kolicina with 0 // nuliraj kolicinu
         	endif
         	if roba->(found())   // roba se nalazi u knjigovodstvenom sifrarniku
            		_Kolicina += _POS->Kolicina
           		// uzimaj cijene iz sifrarnika 2
           		_Cijena:=roba->cijena1
         	endif
         	REPLACE m1 WITH "Z"
         	SKIP
       	enddo
       	_Prebacen := OBR_NIJE
       	SELECT ODJ
	HSEEK _IdOdj
       	if ODJ->Zaduzuje=="S"
        	_M1 := OBR_NIJE
       	else
        	// za robe (ako odjeljenje zaduzuje robe) ne pravim razduzenje
         	// sirovina
         	_M1 := OBR_JEST
       	endif
       	if round(_kolicina,4)<>0
        	++nStavki
        	SELECT POS  // DODAJ U KUMULATIV samo ako je kolicina<>0
        	_BrDok:=cStalRac
		_Vrijeme:=cVrijeme
        	// izgleda da idvrstep i idgost ne postoje u POS.DBF
        	_IdVrsteP := cNacPlac
        	_IdGost:= cIdGost
        	append blank
        	sql_append()
        	Gather()
       	endif
       	select _pos
enddo

// doks ...
if nstavki>0
	SELECT _POS
       	seek cIdPos+"42"+dtos(gDatum)+cRadRac
       	Scatter()
       	// TIGRA-AURA
       	SELECT DOKS
       	_BrDok    := cStalRac
       	_Vrijeme  := cVrijeme
       	_IdVrsteP := cNacPlac
       	_IdGost   := cIdGost
       	_IdOdj    := SPACE (LEN (_IdOdj))
       	_M1       := OBR_NIJE
       	append Blank     // _POS
       	Gather()
endif

// ponovo otvori standardne
select pos
use
O_POS
select doks
use
O_DOKS
select roba
use
O_ROBA

return
*}

