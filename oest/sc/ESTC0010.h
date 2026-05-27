#ifndef __prg
#define __prg

/*****************************************************************************
_________________
MODIFICATION    [001]
Auteur:         D.GATIBELZA
Date:           22/07/2008
Version:        8.1
Description:    ESTDOM15823 Echange interne  agrandissement d'un tableau en memoire pour charger les références internes
                passage de MAX_SSDACTR 20000 à : MAX_SSDACTR 50000
_________________
MODIFICATION    [002]
Auteur:         JF VDV
Date:           08/10/2012
Version:         
Description:    [24327] Echange interne agrandissement du tableau en memoire pour charger les références internes
                passage de MAX_SSDACTR 50 000 à : MAX_SSDACTR 500 000           
[003] 27/06/2014 R. Cassis :spot:25036 Modifie compteur du Kn_MaxLigFBOTRSLNK (triplé)
*****************************************************************************/
#define FTECLEDR_RETCTR_NF 0
#define FTECLEDR_RETSEC_NF 1
#define FTECLEDR_RTY_NF 2
#define FTECLEDR_PLC_NT 3
#define FTECLEDR_SSD_CF 4
#define FTECLEDR_RETCUR_CF 5
#define FTECLEDR_TRNCOD_CF 6
#define FTECLEDR_RETAMT_M 7
#define FTECLEDR_CTR_NF 8


#define MAX_SSDACTR     500000           //[24327] 500 000 ancien 50 000 ; [001] 20000
T_SSDACTR Ktbd_SsdActr[MAX_SSDACTR] ;   /* tableau des correspondances retro vers acceptation */

int n_ChargerSSDACTR( void ) ;
int n_RechercheSSDACTR( char *RetCtr, short Rty, long Plc, unsigned char RetSec ) ;



/*
** Objet  : FCLEDR (Maitre)
** Entree : prg_I1
** Cle    : (RETCTR_NF, RTY_NF, RETSEC_NF, PLC_NT, TRNCOD_CF, RETCUR_CF, RETAMT_M) (7 champs)
*/


T_RUPTURE_VAR Kbd_ruptFCLEDR;

int n_InitFCLEDR(T_RUPTURE_VAR *pbd_Rupt);
int n_IsR1FCLEDR(char **pbd_InRec, char **pbd_InRec_Cur);
int n_ActionF1FCLEDR(char **pbd_InRec_Cur);

int n_ActionLigneFCLEDR(char **pbd_InRec_Cur);


/*
** Objet  : FSSDACTR (Esclave --> FCLEDR)
** Entree : prg_I2
** Cle    : (RETCTR_NF, RTY_NF, RETSEC_NF, PLC_NT) (4 champs)
*/


FILE            *Kp_InputFilSsdActr ;   /* pointeur sur le fichier des correspondances retro vers acceptation */

/*
T_RUPTURE_SYNC_VAR Kbd_ruptFSSDACTR;

int n_InitSyncFSSDACTR(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncFSSDACTR(char **ptb_InRecOwner, char **ptb_InRecChild);
int n_ActionLigneSyncFSSDACTR (char **ptb_InRecOwner, char **ptb_InRecChild);
*/




/*
** Objet  : FBOTRSLNK (Binaire)
** Entree : prg_I3
*/

FILE *Kp_FBOTRSLNK;
/* Structure pour la recuperation des donnees dans le fichier binaire FTRSLNK */
#define Kn_MaxLigFBOTRSLNK   100000  // [003]



T_FBOTRSLNK Ktbd_FBOTRSLNK[Kn_MaxLigFBOTRSLNK];

int n_ChargerFBOTRSLNK();
int n_RechTrn(char *sz_trn );

#define MaxLigAcmTrs 600


/*
** Objet  : OUT1
** Sortie : prg_O1
*/

FILE *Kp_OutputFileOUT1;

/* ancienne methode de chargement des postes 750 */
/* int n_ChargerTRSLNK(short s_TrtCod); */
/* T_TRSLNK Ktbd_TRSLNK[Kn_MaxLigTRSLNK]; */
/* const char* rech_PcpTrs_cf(char *dettrs_cf); */
/* FILE *Kp_TRSLNK; */
/* #define Kn_MaxLigTRSLNK   10000 */




#endif /* __prg */
