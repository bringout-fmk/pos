#include "\cl\sigma\fmk\pos\pos.ch"

/* Copyright (C) 1997-2002, Sigma-com Zenica BiH
 * 
 * Header  : $Header: c:/cvsroot/cl/sigma/fmk/pos/main/1g/app_srv.prg,v 1.4 2003/10/27 13:01:23 sasavranic Exp $
 * Author  : $Author: sasavranic $
 * Date    : $Date: 2003/10/27 13:01:23 $
 * Revision: $Revision: 1.4 $
 *
 */

/*! \file fmk/pos/main/1g/app_srv.prg
 *
 *  \brief TOPS Applikacijski server - izvrsava poslove u batch rezimu
 *  Ovaj dio je uradjen radi importovanja SQL Log-ova 
 *  \bug Planika,TOPS, batch rezim, Gw se ne inicijalizira
 *  \bug Prijavljen je problem da funkcija ne radi ako se ona prva pokrene. Izgleda da se Gateway ne inicijalizira; stvar radi kada se udje u neki od TOPS-ova "normalno" (pri cemu se GW inicijalizira) pa se onda ova funkcija pokrene.
 */

/*! \fn RunAppSrv(oApp)
 */

function RunAppSrv(oApp)
*{
local cLog

? "Pokrecem RunAppSrv"

if mpar37("/ISQLLOG",oApp)
   if LEFT(oApp:cP5,3)=="/L="
       cLog:=SUBSTR(oApp:cP5,4)
       AS_ISQLLog(cLog)
   endif
endif

if mpar37("/IALLMSG",oApp) 
	? "Pokrecem POS: importovanje poruka" 
	InsertIntoAMessage()
	goModul:quit()
endif

return
*}

/*! \fn AS_ISQLLog(cLog)
 */
 
function AS_ISQLLog(cLog)
*{

O_KASE

seek gIdPos
? "vrsim import sql-loga", cLog
? "Kasa ", gIdPos, kase->naz

O_Log()
? Iz_SQL_Log(VAL(cLog))
goModul:quit()

return
*}

