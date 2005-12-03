#include "\dev\fmk\pos\pos.ch"


/*! \fn CreInt1DB()
 *  \brief Kreiranje tabela dinteg1 i integ1
 */
function CreDIntDB()
*{

// provjeri da li postoji tabela ERRORS.DBF
if !FILE(PRIVPATH+"ERRORS.DBF")
	aDbf := {}
	AADD(aDbf, {"TYPE", "C", 10, 0})
	AADD(aDbf, {"IDROBA", "C", 10, 0})
	AADD(aDbf, {"DOKS", "C", 50, 0})
	AADD(aDbf, {"OPIS", "C", 100, 0})
	DBcreate2(PRIVPATH+"ERRORS.DBF", aDbf)
endif

// provjeri da li postoji tabela DINTEG1
if !FILE(KUMPATH + "DINTEG1.DBF")
	// kreiraj tabelu DINTEG1/2
	
	// definicija tabele DINTEG1/2
	aDbf := {}
	AADD(aDbf, {"ID", "N", 20, 0})
	AADD(aDbf, {"DATUM", "D", 8, 0})
	AADD(aDbf, {"VRIJEME", "C", 5, 0 })
	// + spec.OID polja
	if gSql=="D"
		AddOidFields(@aDbf)
	endif   
	// kreiraj tabelu DINTEG1/2
	DBcreate2(KUMPATH+"DINTEG1.DBF", aDbf)
	DBcreate2(KUMPATH+"DINTEG2.DBF", aDbf)
endif

// provjeri da li postoji tabela INTEG1
if !FILE(KUMPATH + "INTEG1.DBF")
	// kreiraj tabelu INTEG1

	// definicija tabele
	aDbf := {}
	AADD(aDbf, {"ID", "N", 20, 0})
	AADD(aDbf, {"IDROBA", "C", 10, 0})
	AADD(aDbf, {"OIDROBA", "N", 12, 0})
	AADD(aDbf, {"IDTARIFA", "C", 6, 0})
	AADD(aDbf, {"STANJEK", "N", 20, 5})
	AADD(aDbf, {"STANJEF", "N", 20, 5})
	AADD(aDbf, {"KARTCNT", "N", 6, 0})
	AADD(aDbf, {"SIFROBACNT", "N", 15, 0})
	AADD(aDbf, {"ROBACIJENA", "N", 15, 5})
	AADD(aDbf, {"KALKKARTCNT", "N", 6, 0})
	AADD(aDbf, {"KALKKSTANJE", "N", 20, 5})
	AADD(aDbf, {"KALKFSTANJE", "N", 20, 5})
	// + spec.OID polja
	if gSql=="D"
		AddOidFields(@aDbf)
	endif   
	// kreiraj tabelu INTEG1
	DBcreate2(KUMPATH+"INTEG1.DBF", aDbf)
endif

// provjeri da li postoji tabela INTEG2
if !FILE(KUMPATH + "INTEG2.DBF")
	// kreiraj tabelu INTEG2

	// definicija tabele
	aDbf := {}
	AADD(aDbf, {"ID", "N", 20, 0})
	AADD(aDbf, {"IDROBA", "C", 10, 0})
	AADD(aDbf, {"OIDROBA", "N", 12, 0})
	AADD(aDbf, {"IDTARIFA", "C", 6, 0})
	AADD(aDbf, {"KOLICINA", "N", 20, 5})
	AADD(aDbf, {"KARTCNT", "N", 6, 0})
	AADD(aDbf, {"SIFROBACNT", "N", 3, 0})
	// + spec.OID polja
	if gSql=="D"
		AddOidFields(@aDbf)
	endif   
	// kreiraj tabelu INTEG2
	DBcreate2(KUMPATH+"INTEG2.DBF", aDbf)
endif

// kreiraj index za tabelu DINTEG1/2
CREATE_INDEX ("1", "DTOS(DATUM)+VRIJEME+STR(ID)", KUMPATH+"DINTEG1")
CREATE_INDEX ("2", "ID", KUMPATH+"DINTEG1")
CREATE_INDEX ("1", "DTOS(DATUM)+VRIJEME+STR(ID)", KUMPATH+"DINTEG2")
CREATE_INDEX ("2", "ID", KUMPATH+"DINTEG2")

// kreiraj index za tabelu INTEG1
CREATE_INDEX ("1", "STR(ID)+IDROBA", KUMPATH+"INTEG1")

// kreiraj index za tabelu INTEG2
CREATE_INDEX ("1", "STR(ID)+IDROBA", KUMPATH+"INTEG2")

// kreiraj index za tabelu ERRORS
CREATE_INDEX ("1", "TYPE+IDROBA", PRIVPATH+"ERRORS")

return
*}

/*! \fn DInt1NextID()
 *  \brief Vrati sljedeci zapis polja ID za tabelu DINTEG1
 */
function DInt1NextID()
*{
local nArr 
nArr := SELECT()

O_DINTEG1
select dinteg1

nId := NextDIntID()

select (nArr)

return nId
*}


/*! \fn DInt2NextID()
 *  \brief Vrati sljedeci zapis polja ID za tabelu DINTEG2
 */
function DInt2NextID()
*{
local nArr 
nArr := SELECT()

O_DINTEG2
select dinteg2

nId := NextDIntID()

select (nArr)
return nId
*}


/*! \fn NextDIntID()
 *  \brief Vraca sljedeci ID broj za polje ID
 */
function NextDIntID()
*{
nId := 0
set order to tag "2"
go bottom
nId := field->id
nId := nId + 1

return nID
*}




