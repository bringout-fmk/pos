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


function ProdTestCP()
*{

if gnDebug > 0
	
	//START PRINT2 CRET gLocPort,SPACE(5)
	//END PRN2 13
	cCmd:=SPACE(100)	
	Box(,2,50)
		@ m_x+1, m_y+2 SAY "STR:" GET cCmd
		
		read
	BoxC()
	cCmd := ALLTRIM(&cCmd)
	//cCmd:=CnvrtStr2Hex(ALLTRIM(cCmd))
	
	MsgBeep(cCmd)
	Send2ComPort(cCmd)
endif

return
*}

