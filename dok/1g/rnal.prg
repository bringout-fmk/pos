#include "pos.ch"



// -----------------------------------------------------
// prikaz stanja prenosa rnal-a
// -----------------------------------------------------
function sh_rnal( cIdPos, dDatum, cIdvd, cBroj )
local xRet := "--"
local nTArea := SELECT()

select doksrc
go top
seek cIdPos + cIdvd + cBroj + DTOS(dDatum) + PADR("KUPAC", 10)

if FOUND()
	xRet := ""
	xRet += ALLTRIM( field->src_brdok )
	xRet += "/" 
	xRet += ALLTRIM( field->src_opis )
endif

select (nTArea)
return PADR( xRet, 25 )



// ---------------------------------------------------
// unesi broj naloga za tekuci racun
// ---------------------------------------------------
function get_rnal( cIdPos, dDatum, cBroj )
local nTArea := SELECT()
local GetList := {}
local nNalog := 0
local nKupac := 0
local cOk := "D"
local cKupId := ""
local cKupNaz := ""
local dDatNalog := DATE()
local cNalog := ""

Box(, 6, 60)
	
	@ m_x + 1, m_y + 2 SAY "Broj naloga:" GET nNalog PICT "9999999999"
	
	read

	if nNalog = 0
		cKupId := PADR( cKupId, 6 )
		cKupNaz := PADR( cKupNaz, 50 )
	else
	  	// napravi link sa rnal-om
	  	_g_from_rnal( nNalog, @cKupId, @cKupNaz, @dDatNalog )
	
		cKupId := PADR( cKupId, 6 )
		cKupNaz := PADR( cKupNaz, 50 )

		cNalog := ALLTRIM(STR( nNalog ))
	endif

	if nNalog <> 0
		@ m_x + 2, m_y + 2 SAY ">>> RNAL link"
	endif

	@ m_x + 3, m_y + 2 SAY "kupac sifra:" GET cKupId 
	@ m_x + 4, m_y + 2 SAY "kupac naziv:" GET cKupNaz PICT "@S30"
	
	@ m_x + 6, m_y + 2 SAY "Snimiti promjene ?" GET cOk PICT "@!" ;
		VALID cOk $ "DN"

	read


BoxC()

if cOk == "D"
	// dodaj u doksrc
	add_p_doksrc( cIdPos, "42", cBroj, dDatum, "KUPAC", "", "", ;
		cNalog, dDatNalog, "", "", cKupId, cKupNaz, PRIVPATH )
	// prebaci u kumulativ
	p_to_doksrc()
endif

select (nTArea)
return


// ------------------------------------------------
// veza sa rnal-om
// ------------------------------------------------
static function _g_from_rnal( nNalog, cId, cNaz, dDatum )
local nKupac

// napravi link sa rnal
xSif_path := ALLTRIM( gRNALSif )
xKum_path := ALLTRIM( gRNALKum )

use ( xSif_path + "customs" ) new alias r_cust
use ( xKum_path + "docs" ) new alias r_docs

cId := ""
cNaz := ""

select r_docs
go top
seek STR( nNalog, 10 )

if FOUND()

	nKupac := field->cust_id
	dDatum := field->doc_date
	
	select r_cust
	go top
	
	seek STR(nKupac, 4)

	cId := ALLTRIM( STR( nKupac ) )
	cNaz := ALLTRIM( field->cust_desc )

endif

return


