#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/print/1g/print.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.2 $
 * $Log: print.prg,v $
 * Revision 1.2  2002/06/15 12:23:39  sasa
 * no message
 *
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


