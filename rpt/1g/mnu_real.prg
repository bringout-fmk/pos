#include "\cl\sigma\fmk\pos\pos.ch"

function RealMenu()
*{

private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. kase             ")
AADD(opcexe,{|| RealKase(.f.)})
AADD(opc,"2. odjeljenja")
AADD(opcexe,{|| RealOdj()})
AADD(opc,"3. radnici")
AADD(opcexe,{|| RealRadnik(.f.)})

#IFDEF DEPR
	AADD(opc,"4. dijelovi objekta ")
  	AADD(opcexe,{|| RealDio()})
#ELSE
  	AADD(opc,"------ ")
  	AADD(opcexe,nil)
#ENDIF

AADD(opc,"5. realizacija po K1")
AADD(opcexe,{|| RealKase(.f.,,,"2")})

Menu_SC("real")

return .f.
*}

