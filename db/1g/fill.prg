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
 

// ----------------------------------
// fill init db podatke
// ----------------------------------
function f_init_db()

close all

// kreiram inicijalne podatke u sifrarnicima ako nema nista
CrePosISifData()

if IsPDV()
	// kreiram poreznu fakturu
	dokspf_create()
endif

// kreiraj priprz tabelu
cre_priprz()

return


// -----------------------------------------------
// kreiraj priprz ako joj ne valja struktura
// -----------------------------------------------
static function cre_priprz()
local cFileName := PRIVPATH + "PRIPRZ"
local lCreate := .f.

if !FILE(cFileName + ".DBF") 
	lCreate := .t.
else
	 // postoji provjeri je li struktura nova
	close all
	O_PRIPRZ
	// ako nije priprema prazna ne brisi
	if reccount2() > 0
		return .f.
	endif

	if fieldpos("k7") == 0
		// stara struktura
		lCreate:= .t.
	endif
endif

close all
if lCreate
	aDbf := g_prip_fields() 
	DBcreate2 (cFileName, aDbf )
	CREATE_INDEX ("1", "IdRoba", cFileName)
endif

return
