#include "pos.ch"

static __stanje
static __vrijednost
static __dok_br


// --------------------------------------------
// prenos pocetnog stanja....
// --------------------------------------------
function p_poc_stanje()
local dPrenOd
local dPrenDo
local dDatPs
local cIdPos
local nPren := 0
local cMsg := ""
local nPadr := 60

// provjeri da li je sve preneseno u ng
// da li je nova sezona
if _chk_ng( ) == .f.
	return 
endif

// uzmi parametre...
if _get_vars( @dPrenOd, @dPrenDo, @dDatPs, @cIdPos ) == 0

	MsgBeep("Operacija prekinuta...")
	return
	
endif

__stanje := 0
__vrijednost := 0
__dok_br := ""

nPren := _pren_pst( dPrenOd, dPrenDo, dDatPs, cIdPos )

if nPren > 0
	cMsg := "!" + PADC("Izvrsen prenos pocetnog stanja", nPadr) + "!"
	cMsg += "##"
	cMsg += PADR("broj stavki dokumenta: " + ALLTRIM(STR(nPren)), nPadr)
	cMsg += "#"
	cMsg += PADR("stanje: " + ALLTRIM(STR(__stanje, 12, 2)), nPadr/2 )
	cMsg += PADR(", vrijednost: " + ALLTRIM(STR( __vrijednost, 12, 2 )), nPadr/2)
	cMsg += "##"
	cMsg += PADR("broj dokumenta: " + VD_ZAD + "-" + ALLTRIM( __dok_br ), nPadr)
else
	cMsg := "Nema dokumenata za prenos !!!"
endif

MsgBeep(cMsg)

return


// --------------------------------------------
// provjeri da li je sezona prenesena
// --------------------------------------------
static function _chk_ng()
local lRet := .t.

// provjeri da li je razdvojena sezona....
if goModul:oDataBase:cSezona <> PADR( ALLTRIM( STR( YEAR(DATE()) ) ), 4 ) ;
	.and. goModul:oDataBase:cRadimUSezona == "RADP"

	MsgBeep("Ova opcija dostupna samo u novoj godini !!!")
	
	lRet := .f.

endif

return lRet



// --------------------------------------------
// parametri prenosa
// --------------------------------------------
static function _get_vars(dDatOd, dDatDo, dDatPs, cIdPos)
local nX := 1
local nBoxX := 8
local nBoxY := 60
private GetList:={}

dDatOd := CToD( "01.01." + ALLTRIM(STR(YEAR(DATE())-1)) )
dDatDo := CToD( "31.12." + ALLTRIM(STR(YEAR(DATE())-1)) )
dDatPs := CToD( "01.01." + ALLTRIM(STR(YEAR(DATE()))) )

cIdPos := gIdPos

Box(, nBoxX, nBoxY )

	set cursor on
	
	@ m_x + nX, m_y + 2 SAY "Parametri prenosa u novu godinu" COLOR "BG+/B"
	
	nX += 2
	
	@ m_x + nX, m_y + 2 SAY "pos ID" GET cIdPos VALID !EMPTY(cIdPos)
	
	nX += 2
	
	@ m_x + nX, m_y + 2 SAY "Datum prenosa od:" GET dDatOd VALID !EMPTY(dDatOd)
	@ m_x + nX, col() + 1 SAY "do:" GET dDatDo VALID !EMPTY(dDatDo)
	
 	nX += 2
	
	@ m_x + nX, m_y + 2 SAY "Datum dokumenta pocetnog stanja:" GET dDatPs VALID !EMPTY(dDatPs)
	
	read
	
BoxC()

if LastKey() == K_ESC
	return 0
endif

return 1


// --------------------------------------------
// prenesi pocetno stanje....
// --------------------------------------------
static function _pren_pst( dDateFrom, dDateTo, dDatPs, cIdPos )
local cPredSez := ""
local cDokBr := "999999"
local cNDokBr := ""
local nCount := 0
local nRCijena := 0
local cRTarifa := ""
local cNazRoba := ""

// otvori tabele u prethodnoj sezoni

// prethodna sezona je...
cPredSez := ALLTRIM( STR(  VAL(goModul:oDataBase:cSezona) - 1 ) )

close all

// POS_SEZ
select (245)
use ( KUMPATH + cPredSez + SLASH + "POS" ) ALIAS POS_SEZ

O_POS
O_DOKS
O_ROBA
O_TARIFA

select doks

cNDokBr := NarBrDok( cIdPos, VD_ZAD )
__dok_br := cNDokBr

select pos_sez
set order to tag "5"
// idpos + idroba + DTOS(datum)
go top

seek cIdPos

Box(, 3, 65 )

@ m_x + 1, m_y + 2 SAY "generacija dokumenta u toku..." COLOR "BG+/B"

do while !EOF() .and. field->idpos == cIdPos

	cIdRoba := field->idroba

	select roba
	set order to tag "ID"
	go top
	seek cIdRoba

	cNazRoba := ALLTRIM(field->naz)
	nRCijena := field->cijena1
	cRTarifa := field->idtarifa
	
	select pos_sez

	nStanje := 0
	nVrijednost := 0

	do while !EOF() .and. field->idpos == cIdPos ;
			.and. field->idroba == cIdRoba

		if field->datum < dDateFrom .and. field->datum > dDateTo
		
			skip
			loop
		
		endif

		cIdVd := field->idvd
		
		if cIdVd $ "16#00"
				
			nStanje += field->kolicina 
			nVrijednost += field->kolicina * field->cijena
				
		elseif cIdVd $ "IN#NI" + DOK_IZLAZA
			
		   do case
		       case cIdvd == "IN"
					
		         nStanje -= (field->kolicina) - (field->kol2)
			 nVrijednost -= (field->kolicina - field->kol2) * ;
			 		field->cijena
			
		       case cIdVd == "NI"
			 
			 // kolicina ne utice
			 nVrijednost := field->kolicina * field->cijena

		       otherwise
		         
			 nStanje -= field->kolicina
			 nVrijednost -= field->kolicina * field->cijena
		       
		       endcase
		
		endif
		
		select pos_sez
		skip

	enddo

	// zavrsio sa artiklom upisi ga u dokument 16... u novoj sezoni

	if ROUND(nStanje, 4) <> 0
	
		select pos
		append blank
		
		Scatter()
		
		_idpos := cIdPos
		_idvd := "16"
		_brdok := cNDokBr
		_idroba := cIdRoba
		_kolicina := nStanje
		_cijena := nRCijena
		_datum := dDatPs
		_idradnik := "XXXX"
		_idtarifa := cRTarifa
		_prebacen := "1"
		_smjena := "1"
		_mu_i := "1"
		
		Gather()

		++ nCount

		__stanje += nStanje
		__vrijednost += nVrijednost
		
		@ m_x + 3, m_y + 2 SAY PADR("", 65)
		@ m_x + 3, m_y + 2 SAY "artikal: " + ALLTRIM(cIdRoba) + ;
				" " + PADR(cNazRoba, 30)
		
		select pos_sez
		
	endif

enddo

if nCount > 0
	
	select doks
	append blank

	Scatter()

	_idpos := cIdPos
	_idvd := VD_ZAD
	_brdok := cNDokBr
	_datum := dDatPs
	_idradnik := "XXXX"
	_prebacen := "1"
	_smjena := "1"

	Gather()

endif

BoxC()

return nCount



