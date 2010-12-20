#include "pos.ch"

// --------------------------------------
// stampa fiskalnog racuna
// --------------------------------------
function fisc_rn( cIdPos, dDat, cBrRn )
local nErr := 0

if gFc_use == "N"
	return
endif

do case
	case ALLTRIM(gFc_type) == "FLINK"
		nErr := _flink_rn( cIdPos, dDat, cBrRn )
	case ALLTRIM(gFc_type) == "TRING"
		nErr := _tring_rn( cIdPos, dDat, cBrRn )
	case ALLTRIM(gFc_type) == "FPRINT"
		nErr := _fprint_rn( cIdPos, dDat, cBrRn )

endcase

if gFC_error == "D" .and. nErr > 0
	// ima greska
	msgbeep("Problem sa stampanjem na fiskalni stampac !!!")
endif

// ako ne provjeravamo greske uvijek vrati 0
if gFC_error == "N"
	nErr := 0
endif

return nErr


// -------------------------------------
// stampa fiskalnog racuna FLINK
// -------------------------------------
function _fprint_rn( cIdPos, dDat, cBrRn )
local aRn := {}
local nTArea := SELECT()
local nRbr := 1
local nCtrl := 0
local lStorno := .t.
local nErr := 0
local nPLU := 0
local nPopust := 0

// pronadji u bazi racun
select pos
set order to tag "1"
go top
seek cIdPos + "42" + DTOS(dDat) + cBrRn

do while !EOF() .and. field->idpos == cIdPos ;
		.and. field->brdok == cBrRn
	
	if field->kolicina > 0
		lStorno := .f.
	endif

	cT_c_1 := ""
	nPopust := 0

	if pos->(FIELDPOS("C_1")) <> 0
		// ovo je broj racuna koji se stornira 
		cT_c_1 := field->c_1
	endif

	cArtikal := field->idroba

	select roba
	seek cArtikal

	nPLU := roba->fisc_plu

	select pos

	if field->ncijena > 0
		nPopust := ( field->ncijena / field->cijena ) * 100
	endif

	++ nCtrl

	// kolicina uvijek ide apsolutna vrijednost
	// storno racun fiskalni stampac tretira kao regularni unos

	cRobaNaz := ""
	_fix_naz( roba->naz, @cRobaNaz )

	AADD( aRn, { cBrRn, ;
		ALLTRIM(STR(++nRbr)), ;
		field->idroba, ;
		cRobaNaz, ;
		field->cijena, ;
		ABS( field->kolicina ), ;
		field->idtarifa, ;
		cT_c_1, ;
		nPLU, ;
		nPopust } )

	skip
enddo

select (nTArea)

if nCtrl = 0
	msgbeep("fiskal: nema stavki za stampu !!!")
	nErr := 1
	return nErr
endif

// idemo sada na upis rn u fiskalni fajl
nErr := fp_pos_rn( ALLTRIM(gFc_path), ALLTRIM(gFc_name), aRn, ;
	lStorno, gFc_error )

// pokreni komandu ako postoji
_fc_cmd()

return nErr


// -------------------------------------
// stampa fiskalnog racuna FLINK
// -------------------------------------
function _flink_rn( cIdPos, dDat, cBrRn )
local aRn := {}
local nTArea := SELECT()
local nRbr := 1
local nCtrl := 0
local lStorno := .t.
local nErr := 0
local nPLU := 0

// pronadji u bazi racun
select pos
set order to tag "1"
go top
seek cIdPos + "42" + DTOS(dDat) + cBrRn

do while !EOF() .and. field->idpos == cIdPos ;
		.and. field->brdok == cBrRn
	
	if field->kolicina > 0
		lStorno := .f.
	endif

	cT_c_1 := ""

	if pos->(FIELDPOS("C_1")) <> 0
		// ovo je broj racuna koji se stornira 
		cT_c_1 := field->c_1
	endif

	cArtikal := field->idroba

	select roba
	seek cArtikal
	
	nPLU := roba->fisc_plu

	select pos

	++ nCtrl

	// kolicina uvijek ide apsolutna vrijednost
	// storno racun fiskalni stampac tretira kao regularni unos

	cRobaNaz := ""
	_fix_naz( roba->naz, @cRobaNaz )

	AADD( aRn, { cBrRn, ;
		ALLTRIM(STR(++nRbr)), ;
		field->idroba, ;
		cRobaNaz, ;
		field->cijena, ;
		ABS( field->kolicina ), ;
		_g_tar(field->idtarifa), ;
		cT_c_1, nPLU } )

	skip
enddo

select (nTArea)

if nCtrl = 0
	msgbeep("fiskal: nema stavki za stampu !!!")
	nErr := 1
	return nErr
endif

// idemo sada na upis rn u fiskalni fajl
nErr := fc_pos_rn( ALLTRIM(gFc_path), ALLTRIM(gFc_name), aRn, lStorno, gFc_error )

// pokreni komandu ako postoji
_fc_cmd()

return nErr



// --------------------------------------------
// stampa fiskalnog racuna TRING (www.kase.ba)
// --------------------------------------------
function _tring_rn( cIdPos, dDat, cBrRn )
local aRn := {}
local aKupac := nil
local nTArea := SELECT()
local nRbr := 1
local nCtrl := 0
local lStorno := .t.
local nErr := 0
local nPLU := 0

// pronadji u bazi racun
select pos
set order to tag "1"
go top
seek cIdPos + "42" + DTOS(dDat) + cBrRn

do while !EOF() .and. field->idpos == cIdPos ;
		.and. field->brdok == cBrRn
	
	if field->kolicina > 0
		lStorno := .f.
	endif

	cT_c_1 := ""

	if pos->(FIELDPOS("C_1")) <> 0
		// ovo je broj racuna koji se stornira 
		cT_c_1 := field->c_1
	endif

	cArtikal := field->idroba

	select roba
	seek cArtikal

	nPLU := roba->fisc_plu

	select pos

	++ nCtrl

	// kolicina uvijek ide apsolutna vrijednost
	// storno racun fiskalni stampac tretira kao regularni unos

	cRobaNaz := ""
	_fix_naz( roba->naz, @cRobaNaz )
	
	AADD( aRn, { cBrRn, ;
		ALLTRIM(STR( ++nRbr )), ;
		field->idroba, ;
		cRobaNaz, ;
		field->cijena, ;
		field->ncijena, ;
		ABS( field->kolicina ), ;
		_g_tar(field->idtarifa), ;
		cT_c_1, ;
		field->datum, ;
		roba->jmj, nPLU } )

	skip
enddo

select (nTArea)

if nCtrl = 0
	msgbeep("fiskal: nema stavki za stampu !!!")
	nErr := 1
	return nErr
endif

// idemo sada na upis rn u fiskalni fajl
nErr := fc_trng_rn( ALLTRIM(gFc_path), ALLTRIM(gFc_name), ;
	aRn, aKupac, lStorno, gFc_error )

return nErr




// -------------------------------------------
// popravlja naziv artikla
// -------------------------------------------
static function _fix_naz( cR_naz, cNaziv )

// prvo ga srezi na LEN(30)
cNaziv := PADR( cR_naz, 30 )

if ALLTRIM(gFc_type) == "FLINK"
	
	// napravi konverziju karaktera 852 -> eng
	cNaziv := StrKzn( cNaziv, "8", "E" )

	// konvertuj naziv na LOWERCASE()
	// time rjesavamo i veliko slovo "V" prvo
	cNaziv := LOWER( cNaziv )

	// zamjeni sve zareze u nazivu sa tackom
	cNaziv := STRTRAN( cNaziv, ",", "." )
endif

return


// ------------------------------------------
// vraca tarifu za fiskalni stampac
// ------------------------------------------
static function _g_tar( cIdTar )
cF_tar := "E"
do case
	case UPPER(cIdTar) = "PDV17"
		cF_tar := "E"
endcase
return cF_tar



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


