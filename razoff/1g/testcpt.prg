#include "\dev\fmk\pos\pos.ch"


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

