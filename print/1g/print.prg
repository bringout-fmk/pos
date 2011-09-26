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
 */
 

/*! \fn gSjeciStr()
 *  \brief
 */
 
function gSjeciStr()
*{

Setpxlat()
if gPrinter=="R"
  	Beep(1)
  	FF
else
	qqout(gSjeciStr)
endif
konvtable()
return
*}


/*! \fn gOtvoriStr()
 *  \brief
 */
 
function gOtvorStr()
*{

Setpxlat()
if gPrinter<>"R"
	qqout(gOtvorStr)
endif
konvtable()
return
*}


/*! \fn PaperFeed()
 *  \brief Samo pomjeri papir da se moze otcijepiti /samo na kasi/
 */

function PaperFeed()
*{

if gVrstaRS <> "S"
	for i:=1 to nFeedLines
    		?
  	next
  	if gPrinter=="R"
  		Beep(1)
  		FF
  	else  
		gSjeciStr()
  	endif
endif
return
*}


