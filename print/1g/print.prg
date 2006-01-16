#include "\dev\fmk\pos\pos.ch"
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


