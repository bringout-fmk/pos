#include "\dev\fmk\pos\pos.ch"


/*! \fn PlFlexTCases()
 *  \brief Centralna funkcija za poziv test case-ova planikaflex
 */
function PlFlexTCases()
*{

// TC-1: Vrati tekuci oid
// TGetCurrOid()

// TC-2: Vrati najmanji oid za tabele ROBA, TARIFA, DOKS, POS
// TGetMinOid()

// TC-3: Vrati najveci oid za tabele ROBA, TARIFA, DOKS, POS
// TGetMaxOid()

// TC-4: Vrati broj zapisa tabela ROBA, TARIFA, DOKS, POS
// TGetTblRecNo()

// TC-5: Da li postoji u tabelama duplih oid-a
// TChkDblOid()

// TC-6: Koliko ima oida sa prodavnickim prefixom a koliko sa knj.prefixom
// TChkOidPrefix()


return
*}

/*! \fn TGetCurrOid()
 *  \brief Vraca broj tekuceg oid-a
 */
function TGetCurrOid()
*{
O_SQLPAR
nTekOid := sqlpar->oidtek
? "Tekuci oid u tabeli sqlpar: ", STR(nTekOid)
return 
*}

/*! \fn TGetMinOid()
 *  \brief Vraca najmanji broj oida
 */
function TGetMinOid()
*{



return
*}

/*! \fn TGetMaxOid()
 *  \brief Vraca najveci broj oida
 */
function TGetMaxOid()
*{



return
*}

/*! \fn TGetTblRecNo()
 *  \brief Vraca broj zapisa tabela
 */
function TGetTblRecno()
*{

return
*}

/*! \fn TChkDblOid()
 *  \brief Provjera postojanja duplih oid-a
 */
function TChkDblOid()
*{

return
*}

/*! \fn TChkOidPrefix()
 *  \brief Provjera prefixa oid-a koliko ima prefixa prodavnice, koliko ima prefixa knjigovodstva
 */
function TChkOidPrefix()
*{

return
*}


