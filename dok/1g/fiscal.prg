#include "pos.ch"

// --------------------------------------
// stampa fiskalnog racuna
// --------------------------------------
function fisc_rn( cIdPos, dDat, cBrRn )

if gFc_use == "N"
	return
endif

do case
	case ALLTRIM(gFc_type) == "FLINK"
		_flink_rn( cIdPos, dDat, cBrRn )

endcase

return



// -------------------------------------
// stampa fiskalnog racuna FLINK
// -------------------------------------
function _flink_rn( cIdPos, dDat, cBrRn )
local aRn := {}
local nTArea := SELECT()
local nRbr := 1
local nCtrl := 0

// pronadji u bazi racun
select pos
seek cIdPos + "42" + DTOS(dDat) + cBrRn

do while !EOF() .and. field->idpos == cIdPos ;
		.and. field->brdok == cBrRn
	
	cArtikal := field->idroba
	select roba
	seek cArtikal

	select pos

	++ nCtrl

	AADD( aRn, { cBrRn, ;
		ALLTRIM(STR(++nRbr)), ;
		field->idroba, ;
		roba->naz, ;
		field->cijena, ;
		field->kolicina, ;
		field->idtarifa } )

	skip
enddo

select (nTArea)

if nCtrl = 0
	msgbeep("fiskalni racun nemoguce stampati !!!")
	return
endif

// idemo sada na upis rn u fiskalni fajl
fc_pos_rn( ALLTRIM(gFc_path), ALLTRIM(gFc_name), aRn )

// pokreni komandu ako postoji
_fc_cmd()

return



// ------------------------------------------
// izvrsi fiskalnu komandu, ako postoji
// ------------------------------------------
static function _fc_cmd()
private cFcCmd := ""

if EMPTY( ALLTRIM( gFc_cmd ) )
	return
endif

cFcCmd := ALLTRIM( gFc_cmd )
cFcCmd := STRTRAN( cFcCmd, "$1", ALLTRIM(gFc_cp1) )
cFcCmd := STRTRAN( cFcCmd, "$2", ALLTRIM(gFc_cp2) )
cFcCmd := STRTRAN( cFcCmd, "$3", ALLTRIM(gFc_cp3) )
cFcCmd := STRTRAN( cFcCmd, "$4", ALLTRIM(gFc_cp4) )
cFcCmd := STRTRAN( cFcCmd, "$5", ALLTRIM(gFc_cp5) )

run &cFcCmd

return


