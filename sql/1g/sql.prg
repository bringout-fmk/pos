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
#include "msg.ch"


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
GW("SET TABLE_DIRSIF  #ROBA#SIFK#SIFV#OSOB#TARIFA#VALUTE#VRSTEP#ODJ#UREDJ#STRAD#")
GW("SET TABLE_DIRKUM  #POS#DOKS#DOKSPF#")

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
if IsPDV()
	Gw("ZAP DOKSPF")
endif
Gw("ZAP KPARAMS")
Gw("ZAP PROMVP")

O_POS
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("POS")

O_DOKS
@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
Log_Tabela("DOKS")

if IsPDV()
	O_DOKSPF
	@ m_x+2,m_y+2 SAY "Logiram tabelu  "+padr(ALIAS(),15)
	Log_Tabela("DOKSPF")
endif

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
Gw("SET TABLE_DIRKUM  #POS#DOKS#KPARAMS#PROMVP#MESSAGE#DINTEG1#DINTEG2#INTEG1#INTEG2#DOKSPF#")
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

// nafiluj p_update/KALK
fill_p_update()

return 1


/*! \fn LogRecRoba(cIdRoba)
 *  \brief logiranje zapisa tabele roba
 *  \param cIdRoba - id roba
 */
function LogRecRoba(cIdRoba)
*{
O_ROBA
set order to tag "ID"
hseek cIdRoba
altd()

cSQL:="delete from ROBA where Id="+SQLValue(cIdRoba)
Gw(cSQL)

// logiraj record
Log_Record()

return
*}


/*! \fn NewRecRoba(cIdRoba)
 *  \brief dodavanje novog zapisa tabele roba
 *  \param cIdRoba - id roba
 */
function NewRecRoba(cIdRoba)
*{
local nTRec
O_ROBA
set order to tag "ID"
hseek cIdRoba
nTRec := RecNo()

cSQL:="delete from ROBA where Id="+SQLValue(cIdRoba)
Gw(cSQL)

// logiraj record
New_Record()

O_ROBA
go (nTRec)
if (roba->id == cIdRoba)
	delete
endif

return
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
@ m_x+3,m_y+2 SAY "Vrsta dok." GET cIdVD PICT "@!"
READ
BoxC()

if LASTKEY()==K_ESC
	return .f.
endif

// da li se radi o tabeli pologa pazara?
if (cIdVD == "PP")
	// logiraj tabelu polog pazara
	LogPPPer(dDatOd, dDatDo)
	return 1
endif
// da li se radi o tabeli poruka?
if (cIdVD == "MS")
	// logiraj tabelu poruka
	LogMsgPer(dDatOd, dDatDo)
	return 1
endif

private cFilter:=""

// ako se radi o dokumentima 90, 91 i 92
if cIdVD $ "90#91#92"
	cFilter:="IdVD="+cm2str(cIdvd)+" .and. _DataZ_>="+cm2str(dDatOd)+" .and. _DataZ_<="+cm2str(dDatDo)
else
	cFilter:="IdVD="+cm2str(cIdvd)+" .and. Datum>="+cm2str(dDatOd)+" .and. Datum<="+cm2str(dDatDo)
endif

O_DOKS

set FILTER to &cFilter

cSQL:="delete from DOKS where IdVD="+SQLValue(cIdVd)+" and Datum>="+SQLValue(dDatOd)+" and Datum<="+SQLValue(dDatDo)

Gw(cSQL)
go top
Log_Tabela()
use

O_POS
set FILTER to &cFilter
if cIdVD $ "90#91#92"
	cSQL:="delete from POS where IdVD="+SQLValue(cIdVd)+" and _DataZ_>="+SQLValue(dDatOd)+" and _DataZ_<="+SQLValue(dDatDo)
else
	cSQL:="delete from POS where IdVD="+SQLValue(cIdVd)+" and Datum>="+SQLValue(dDatOd)+" and Datum<="+SQLValue(dDatDo)
endif

Gw(cSQL)
go top
Log_Tabela()
use

return 1
*}


/*! \fn LogPPPer(dDat1, dDat2)
 *  \brief Logiranje pologa pazara, tabele PROMVP
 *  \param dDat1 - datum od
 *  \param dDat2 - datum do
 */
function LogPPPer(dDat1, dDat2)
*{
private cFilter:=""

cFilter:="PM=" + Cm2Str(gIdPos) + " .and. Datum>=" + Cm2Str(dDat1) + " .and. Datum<=" + Cm2Str(dDat2)

O_PROMVP

SET FILTER TO &cFilter

cSQL:="delete from PROMVP where PM="+SQLValue(gIdPos)+" and Datum>="+SQLValue(dDat1)+" and Datum<="+SQLValue(dDat2)

Gw(cSQL)
go top
Log_Tabela()
use

return
*}


/*! \fn LogMsgPer(dDat1, dDat2)
 *  \brief Logiranje poruka, tabele MESSAGE
 *  \param dDat1 - datum od
 *  \param dDat2 - datum do
 */
function LogMsgPer(dDat1, dDat2)
*{
private cFilter:=""

cFilter:="CREATED >= " + Cm2Str(dDat1) + " .and. CREATED <= " + Cm2Str(dDat2)

O_MESSAGE

SET FILTER TO &cFilter

cSQL:="delete from MESSAGE where CREATED >= "+SQLValue(dDat1)+" and CREATED <= "+SQLValue(dDat2)

Gw(cSQL)
go top
Log_Tabela()
use

return
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

