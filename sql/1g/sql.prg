#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/sql/1g/sql.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.11 $
 * $Log: sql.prg,v $
 * Revision 1.11  2003/10/27 13:01:24  sasavranic
 * Dorade
 *
 * Revision 1.10  2003/01/19 23:44:18  ernad
 * test network speed (sa), korekcija bl.lnk
 *
 * Revision 1.9  2002/08/19 10:01:12  ernad
 *
 *
 * sql synchro cijena1, idtarifa za tabelu roba
 *
 * Revision 1.8  2002/07/30 17:40:59  ernad
 * SqlLog funkcije - Fin modul
 *
 * Revision 1.7  2002/06/24 16:11:53  ernad
 *
 *
 * planika - uvodjenje izvjestaja 98-reklamacija, izvjestaj planika/promet po vrstama placanja, debug
 *
 * Revision 1.6  2002/06/24 07:01:38  ernad
 *
 *
 * meniji, u oDatabase:scan ubacen GwDiskFree ..., debug...
 *
 * Revision 1.5  2002/06/23 11:57:23  ernad
 * ciscenja sql - planika
 *
 * Revision 1.4  2002/06/21 14:18:12  ernad
 *
 *
 * pos - planika, import sql
 *
 * Revision 1.3  2002/06/19 19:46:47  ernad
 *
 *
 * rad u sez.podr., debug., gateway
 *
 * Revision 1.2  2002/06/17 12:19:51  sasa
 * no message
 *
 *
 */
 

/*! \fn MenuSQLLogs()
 *  \brief Funkcije za rad sa SQL logovima
 */

function MenuSQLLogs()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. sql poc stanje           ")
AADD(opcexe,{|| SQL_0() })
AADD(opc,"2. sql ucitaj log")
AADD(opcexe,{|| Iz_Sql_Log(99,.f.) })
AADD(opc,"3. log period")
AADD(opcexe,{|| LogPeriod()})
AADD(opc,"4. synchro cijene, tarife")
AADD(opcexe,{|| SynTarCij()})

Menu_SC("msql")
return .f.
*}


/*! \fn O_Log()
 *  \brief Ucitavanje SQL log fajla
 */
 
function O_Log()
*{
local cPom
local cLogF

cPom:=ToUnix(KUMPATH+SLASH+"SQL")
DirMak2(cPom)

cLogF:=cPom+SLASH+replicate("0",8)

OKreSQLPar(cPom)

public gSQLSite:=field->_SITE_
public gSQLUser:=1
use

//postavi site
Gw("SET SITE "+Str(gSQLSite))
Gw("SET TODATABASE OFF")
Gw("SET MODUL "+gModul)

AImportLog()

return
*}


/*! \fn Sql_0()
 *  \brief Generisanje sql loga pocetnog stanja
 */
 
function Sql_0()
*{
local nStartSec
if !SigmaSif("SQLPS")
	MsgBeep("Neispravna sifra ...")
  	return
endif

GW_STATUS="GEN_SQL_LOG"

if Pitanje(,"SQL pocetno stanje ?","N")=="N"
	return
endif

Box(,3,60)
@ m_x+1,m_y+2 SAY "Formiram sql log ..."
nStartSec:=SECONDS()
Gw("SET POCSTANJE ON")

// ove tabele se nalaze u direktoriju sifrarnika
GW("SET TABLE_DIRSIF  #ROBA#SIFK#SIFV#OSOB#TARIFA#VALUTE#VRSTEP#ODJ#UREDJ#STRAD")
GW("SET TABLE_DIRKUM  #POS#DOKS#")

Gw("ZAP ROBA")
Gw("ZAP SIFK")
Gw("ZAP SIFV")
Gw("ZAP OSOB")
Gw("ZAP TARIFA")
Gw("ZAP VALUTE")
Gw("ZAP VRSTEP")
Gw("ZAP ODJ")
Gw("ZAP UREDJ")
Gw("ZAP STRAD")

O_TARIFA
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("TARIFA")

O_ROBA
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("ROBA")


O_SIFK
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("SIFK")

O_SIFV
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("SIFV")

O_OSOB
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("OSOB")

O_VALUTE
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("VALUTE")

O_VRSTEP
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("VRSTEP")

O_ODJ
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("ODJ")

O_UREDJ
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("UREDJ")

O_STRAD
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("STRAD")

Gw("ZAP POS")
Gw("ZAP DOKS")
Gw("ZAP KPARAMS")
Gw("ZAP PROMVP")
O_POS
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("POS")

O_DOKS
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("DOKS")

O_KPARAMS
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("KPARAMS")

O_PROMVP
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("PROMVP")


Gw("ZAP PARAMS")
O_PARAMS
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("PARAMS")

close all

GW_STATUS="-"
BoxC()


#ifdef PROBA
	MsgBeep("Trajanje operacije:"+ALLTRIM(STR(SECONDS()-nStartSec)))
#endif

return
*}



/*! \fn Iz_Sql_Log(nSite,lSilent)
 *  \brief
 *  \param nSite
 *  \param lSilent   - .t. ili .f. => batch varijanta
 */
function Iz_Sql_Log(nSite,lSilent)
*{
local cTmp

if goModul:oDatabase:lAdmin
	return 0
endif

if lSilent==nil
	lSilent:=.t.
endif

#ifndef PROBA
if !lSilent 
	if !SigmaSif("SQLIMP")
   		MsgBeep("Neispravna sifra ...")
		return 0
	endif
      	nSite:=2
      	set cursor on
        Box(,2,60)
        @ m_x+1,m_y+2 SAY "Importuj log sa Site-a " GET nSite pict "99"
        read
        BoxC()
      	if Pitanje(,"Jeste li sigurni ?","N")=="D"
        	if LASTKEY()<>K_ESC
                	Iz_Sql_Log(nSite)
           	else
			return 0
		endif
		
      	endif
endif
#endif

cTmp:= ZGwPoruka()
if ("IMPORTSQL_OK"<>cTmp .and. "IMPORTSQL" $ cTmp)
	MsgBeep("Vec je u toku je import SQL-a !!?")
    	return 0
endif

if !gAppSrv .and. pitanje(,"Uzmi iz SQL-loga "+padl(alltrim(str(nsite)),2,"0")+" stanje ?","D")=="N"
   	return 0
endif

GW_STATUS="IMP_SQL_LOG"

close all
Box(,3,60)

@ m_x+1,m_y+2 SAY "Vrsim importovanje podataka"
Gw("SET TABLE_DIRSIF  #ROBA#SIFK#SIFV#OSOB#TARIFA#VALUTE#VRSTEP#ODJ#UREDJ#STRAD#")
Gw("SET TABLE_DIRKUM  #POS#DOKS#KPARAMS#PROMVP#MESSAGE#")
Gw("SET TABLE_DIRPRIV #PARAMS#")
Gw("SET DIRKUM "+KUMPATH)
Gw("SET DIRSIF "+SIFPATH)
Gw("SET DIRPRIV "+PRIVPATH)
GW_STATUS:="EXE_GET_SQLLOG"
cRezultat:=Gw("GET SQLLOG "+alltrim(str(nSite)))

if ("Fajl" $ cRezultat .and.  "ne postoji" $ cRezultat)
	if gAppSrv
       		? cRezultat
   	else
       		MsgBeep(cRezultat)
   	endif
else
 	nBroji2:=SECONDS()
 	do while .t.
   		cTmp:=GwStaMai(@nBroji2)
   		if (GW_STATUS != "NA_CEKI_K_SQL")
      			exit
   		endif
 	enddo
endif

GW_STATUS="-"
Boxc()

ScanDb()
return 1
*}

 
/*! \fn LogPeriod()
 *  \brief
 */
 
function LogPeriod()
*{
if !SigmaSif("SLGPER")
	return 0
endif

dDatOd:=Date()-1
dDatDo:=Date()-1
cIdVD:="42"

set cursor on
Box(,4,60)
@ m_x+1,m_y+2 SAY "Period od " GET dDatOd
@ m_x+2,m_y+2 SAY "       do " GET dDatDo
@ m_x+3,m_y+2 SAY "Vrsta dok." GET cIdVD
READ
BoxC()

if LASTKEY()==K_ESC
	return .f.
endif

private cFilter:="IdVD="+cm2str(cIdvd)+" .and. Datum>="+cm2str(dDatOd)+" .and. Datum<="+cm2str(dDatDo)

O_DOKS

set FILTER to &cFilter

cSQL:="delete from DOKS where IdVD="+SQLValue(cIdVd)+" and Datum>="+SQLValue(dDatOd)+" and Datum<="+SQLValue(dDatDo)

Gw(cSQL)
go top
Log_Tabela()
use

O_POS
set FILTER to &cFilter
cSQL:="delete from POS where IdVD="+SQLValue(cIdVd)+" and Datum>="+SQLValue(dDatOd)+" and Datum<="+SQLValue(dDatDo)
Gw(cSQL)
go top
Log_Tabela()
use

return 1
*}


/*! \fn AImportLog()
 *  \brief
 */
 
function AImportLog()
*{
local i
local cPomIni
local cLog

if goModul:oDatabase:lAdmin
	return 0
endif

cPomIni:=IzFmkIni("Gateway","AutoImportSQL_"+alltrim(str(gSQLSite)),"-",EXEPATH)

cLog:=""
for i:=1 to int(len(cPomIni)/3)
	cLog:=substr(cPomIni,(i-1)*3+1 ,2)
    	Iz_Sql_Log(val(cLog))
next

return 1
*}


/*! \fn SynTarCij()
 *  \brief Syhroniziraj tarife i cijene u sifrarniku (sql synhronizacija) lokalni<->udaljeni site
 */
 
function SynTarCij()
*{
local lCekaj

CLOSE ALL
O_ROBA

MsgO("Sinhroniziram tarife, cijene lokalni<->udaljeni site...")


SELECT roba
GO TOP
nCnt:=0
do while !eof()
	SELECT roba
	REPLSQL idtarifa with field->idtarifa
	REPLSQL cijena1 with field->cijena1
	skip
enddo

MsgC()

CLOSE ALL
return
*}

