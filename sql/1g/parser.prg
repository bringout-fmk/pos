#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/sql/1g/parser.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.2 $
 * $Log: parser.prg,v $
 * Revision 1.2  2002/06/21 14:18:11  ernad
 *
 *
 * pos - planika, import sql
 *
 * Revision 1.1  2002/06/21 02:28:36  ernad
 * interni sql parser - init, testiranje pos-sql
 *
 *
 */
 

function ImportDSql(cSqlLog)
*{
local i
local nHLog

return

O_POS
O_DOKS
if (cSqlLog==nil)
	cSqlLog:="c:\sigma\sql\99.log"
endif

nHLog:=FOPEN(cSqlLog)

Box(,4,60)
i:=0
do while .t.
	cSql:=FREADLN(nHLog,1,512)
	if LEN(cSql)==0
		exit
	endif
	cSql:=LEFT(cSql,LEN(cSql)-LEN(NRED))
	Sql2Dbf(cSql)
	@ m_x+1, m_y+2 SAY STR(++i,4)
enddo
BoxC()

FCLOSE(nHLog)
CLOSE ALL
return
*}

function Sql2Dbf(cSql)
*{
local cPom
local cOperacija
local i
local nPos
local cTable

cSql:=alltrim(cSql)

cOperacija:=TOKEN(cSql,1)
nPos:=ATTOKEN(cSql," ",2)

cSql:=SUBSTR(cSql,nPos)

cOperacija:=UPPER(cOperacija)
do case
	case cOperacija=="UPDATE"
		//DOKS SET IDPOS='7 ',IDVD='NI' WHERE _OID_=44455
		cTable:=TOKEN(cSql," ",1)
		//ne interesuje nas SET
		nPos:=ATTOKEN(cSql," ",3)
		cSql:=SUBSTR(cSql, nPos)
		//IDPOS='7 ',IDVD='NI' WHERE _OID_=44455
		Upd2Dbf(cTable, cSql)
	case cOperacija=="INSERT"
		//cSql="into POS (_OID_) values(4444555)
		//into nas ne interesuje
		cTable:=TOKEN(cSql," ",2)
		nPos:=ATTOKEN(cSql," ",3)
		cSql:=SUBSTR(cSql,nPos)
		//cSql="(_OID_) values(4445555)
		Ins2Dbf(cTable, cSql)
	case cOperacija=="DELETE"
		MsgBeep("nije implementirano")
	case cOperacija==""
		//nista
	otherwise
		MsgBeep("Nepoznata komanda")
end case

return
*}

function Ins2Dbf(cTable,cSql)
*{
local cPolje
local cValues
local cValue
local nArea

//dolazi mi string tipa
//cSql="(_OID_) values(4445555)

if (" WHERE " $ cSql)
	MsgBeep("insert ... where nije podrzan !!!")
	return 0
endif

cPolje:=ALLTRIM(UPPER(TOKEN(cSql,1)))
// values me ne interesuje
cValues:=TOKEN(cSql,3)

if !(UPPER(cPolje)=="_OID_")
	MsgBeep("insert: podrzan je samo (_OID_)")
	return 0
endif

cValue:=TOKEN(cValues,"()",1)
nValue:=VAL(cValue)

nArea:=DbfArea(cTable)
SELECT(nArea)
APPEND BLANK
RLOCK()
field->_OID_:=nValue
UNLOCK

return 1
*}

return
*}

function Upd2Dbf(cTable, cSql)
*{
local cPolje
local aValues
local nOid
local i
local nFieldPos

//IDPOS='7 ',IDVD='NI,XX' WHERE _OID_=44455

aValues:={}
do while .t.	
	if UPPER(LEFT(ALLTRIM(cSql),5))=="WHERE"
		cSql:=SUBSTR(ALLTRIM(cSql),7)
		exit
	endif
	cPolje:=TOKEN(cSql,"=",1)
	cPolje:=ALLTRIM(cPolje)
	if LEFT(cPolje,1)=","
		cPolje:=SUBST(cPolje,2)
	endif
	nPos:=ATTOKEN(cSql,"=",2)
	cSql:=SUBSTR(cSql,nPos)
	//'7 ',IDVD= ....
	if LEFT(cSql,1)="'"
		//string,date
		cValue:=TOKEN(cSql,"'",1)
		nPos:=ATTOKEN(cSql,"'",2)
		cSql:=SUBSTR(cSql,nPos)
		//IDVD=......
		AADD(aValues,{ALLTRIM(cPolje),cValue})
	else
		//numeric
		cValue:=TOKEN(cSql,",",1)
		nPos:=ATTOKEN(cSql,",",2)
		cSql:=SUBSTR(cSql,nPos)
		AADD(aValues,{ALLTRIM(cPolje),VAL(cValue)})
	endif
enddo
// ostao je samo dio iza WHERE ..
// cSql= _OID_=44555
cPolje:=TOKEN(cSql,"=",1)
cValue:=TOKEN(cSql,"=",2)
cPolje:=ALLTRIM(cPolje)
cValue:=ALLTRIM(cValue)
if cPolje<>"_OID_"
	MsgBeep("update: iza where mora biti _OID_")
	return 0
endif
nOid:=VAL(cValue)

nArea:=DbfArea(cTable)
SELECT(nArea)
SET ORDER TO TAG "_OID_"
SEEK nOid
RLOCK()
	for i:=1 to LEN(aValues)
		nFieldPos:=FIELDPOS(aValues[i,1])
		FIELDPUT(nFieldPos,aValues[i,2])
	next
UNLOCK
*}
