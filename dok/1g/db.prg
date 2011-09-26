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

// --------------------
// otvori baze potrebne za 
// pregled racuna
// --------------------
function o_pregled()

SELECT F_ODJ
if !used()
	O_ODJ
endif

SELECT F_OSOB
if !used()
	O_OSOB
endif

SELECT F_VRSTEP
if !used()
	O_VRSTEP
endif


SELECT F_POS
if !used()
	O_POS
endif

SELECT F_DOKS
if !used()
	O_DOKS
endif

SELECT F_DOKSPF
if !used()
	O_DOKSPF
endif

SELECT F_ROBA
if !used()
	O_ROBA
endif

SELECT F_TARIFA
if !used()
	O_TARIFA
endif

SELECT F_SIFK
if !used()
	O_SIFK
endif

SELECT F_SIFV
if !used()
	O_SIFV
endif

select doks
return


// -----------------------------------------------
// otvori tabele potrebne za unos stavki u racun
// ------------------------------------------------
function o_edit_rn()
select F__POS
if !used()
	O__POS
endif

select F__PRIPR
if !used()
	O__PRIPR
endif

SELECT F_K2C
if !used()
	O_K2C
endif

SELECT F_MJTRUR
if !used()
	O_MJTRUR 
endif

SELECT F_UREDJ
if !used()
	O_UREDJ 
endif



o_pregled()
return
