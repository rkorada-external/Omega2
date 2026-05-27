/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

 /*==============================================================================
nom de l'application          : SHERPA
nom du source                 : ESTC1029.c
revision                      : $Revision:   1.1  $
date de creation              : 07/1998
auteur                        : L.Capomazza
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
description :
	Ajout des zeros manquants

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	22/07/99		ANB			Modification temporaire : suppresion utilisation fichier SUBSID
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <ESTC1029.h>

#define NB_SSD_MAX	150	/*Nbre max de filiales*/
#define NB_BRCHE	 30
#define NB_PSTE		 18
#define NB_PF		  5

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

typedef struct {
                  unsigned char SSD;         /* filiale */
                  char          LAG;         /* Langue filiale */
	          char		LIBSSD[17];  /* Libelle Filiale */
		  char		LIBCUR[4];   /* Libelle monnaie */
	       } T_LIB_SSD;

struct poste {
		int indicateur;
		char *nom;
		};

struct branche {
		int indicateur;
		char *nom;
		struct poste pste[NB_PSTE];
		};

struct portefeuille {
		int indicateur;
		char *nom;
		struct branche brche[NB_BRCHE];
		};


T_RUPTURE_VAR Kbd_Rupt;
FILE *Kp_GolIFil;
FILE *Kp_GoelPeopOFil;
FILE *Kp_Libelle;
		
T_LIB_SSD Kbd_Lib[NB_SSD_MAX];

int Kpn_ind[NB_SSD_MAX];

struct portefeuille tab_pf[NB_PF];

char Ksz_clodat[9];
char Ksz_inv[5];

/*---------------------------*/
/* Declaration des fonctions */
/*---------------------------*/

int NB_COD = 0;
int n_InitPeop(T_RUPTURE_VAR  *pbd_Rupt);
int n_IsR1(char **pbd_InRec ,char **pbd_InRec_Cur);
int n_ActionLignePeop(char **ptb_InRec_Cur);
int n_ActionFirst(char **ptb_InRec_Cur);
int n_ActionLast(char **ptb_InRec_Cur);
int init_struct();
/*static int n_ChargLib(FILE *p_Libelle);*/
int n_Write_out(char **ptb_InRec_Cur,FILE *f,char *monnaie); 

/*==============================================================================
objet :
   point d'entree du programme 
retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/       
       
int main(int argc ,char *argv[])
{
		
  /* Initialisation des signaux */
  InitSig ();
   
  if (n_BeginPgm(argc,argv) == ERR)
	ExitPgm (ERR_XX , "erreur beginpgm");
 
 /* Modif temporaire ANB le 22/7/99 */
 /* Suppression utilisation du fichier SUBSID */ 

 /*if (n_OpenFileAppl ("ESTC1029_I2","rb",&Kp_Libelle) == ERR)
    exit(ERR);*/

 /*if (n_ChargLib(Kp_Libelle) == ERR) 
    exit(ERR); */

  if (n_OpenFileAppl("ESTC1029_O1","wt",&Kp_GoelPeopOFil) == ERR )
	ExitPgm ( ERR_XX , "" );

	n_InitPeop(&Kbd_Rupt);
	  
  /* Détermination de l'inventaire Sherpa */

  strcpy(Ksz_inv,"0000");
  strcpy(Ksz_clodat, psz_GetCharArgv(1));
	if (strcmp(Ksz_clodat,"19980630")==0)
		strcpy(Ksz_inv,"2T98");
	if (strcmp(Ksz_clodat,"19981231")==0)
		strcpy(Ksz_inv,"4T98");
	if (strcmp(Ksz_clodat,"19990630")==0)
		strcpy(Ksz_inv,"2T99");
	if (strcmp(Ksz_clodat,"19991231")==0)
		strcpy(Ksz_inv,"4T99");
    if (strcmp(Ksz_clodat,"20000630")==0)
		strcpy(Ksz_inv,"2T00");
	if (strcmp(Ksz_clodat,"20001231")==0)
		strcpy(Ksz_inv,"4T00");

	if (strcmp(Ksz_inv,"0000")==0)
		strcpy(Ksz_inv,"2T99");

  /* Anb le 12/1/00 */
  /* Modification temporaire */
    strcpy(Ksz_inv,"4T99");

  if (n_ProcessingRuptureVar(&Kbd_Rupt)==ERR)
    ExitPgm (ERR_XX , "");

  if (n_CloseFileAppl("ESTC1029_I1",&(Kbd_Rupt.pf_InputFil)) == ERR)
    ExitPgm (ERR_XX ,"");
    
  /*if (n_CloseFileAppl("ESTC1029_I2",&Kp_Libelle) == ERR)
    ExitPgm (ERR_XX ,"");*/

  if (n_CloseFileAppl("ESTC1029_O1",&Kp_GoelPeopOFil) == ERR)
    ExitPgm (ERR_XX ,"");
    
  if (n_EndPgm() == ERR)
    ExitPgm (ERR_XX , "");
  
  exit(OK) ;
  }
/*=============================================================================
 objet: Initialisation Rupture : 0 rupture 
0=============================================================================*/
int n_InitPeop(T_RUPTURE_VAR  *pbd_Rupt)
{
  
  DEBUT_FCT("n_InitPeop");

  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

  /* Ouverture du fichier maitre */
  if (n_OpenFileAppl ("ESTC1029_I1","rt",&(pbd_Rupt->pf_InputFil)))
	RETURN_VAL (ERR); 


  /* Gestion de rupture */
  pbd_Rupt->n_NbRupture = 1;
  pbd_Rupt->c_Separ = '~';

	pbd_Rupt->n_ConditionRupture[0] = n_IsR1 ;
	
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirst ;
  
	pbd_Rupt->n_ActionLigne = n_ActionLignePeop;
	
	pbd_Rupt->n_ActionLast[0] = n_ActionLast ;


  RETURN_VAL (0);
}

/*==============================================================================
objet :	fonction de test de rupture de niveau 1

retour : 0	---> pas de rupture
	 sinon 	---> rupture
==============================================================================*/
int n_IsR1(char **pbd_InRec ,char **pbd_InRec_Cur  ) 
{
	int ret ;

	DEBUT_FCT( "n_IsR1" ) ;

	if ( ( ret = strcmp( pbd_InRec[TECLEDA_SSD_CF], pbd_InRec_Cur[TECLEDA_SSD_CF] ) ) != 0 ) return ret;

	if ( ( ret = strcmp( pbd_InRec[TECLEDA_COD_CF], pbd_InRec_Cur[TECLEDA_COD_CF] ) ) != 0 ) {
	NB_COD++;
	return ret;
	}

	RETURN_VAL( 0 ) ;
}

/*=======================================================================================

========================================================================================*/ 
int n_ActionLignePeop(char **ptb_InRec_Cur)
{
	int Local_fil = atoi(ptb_InRec_Cur[TECLEDA_SSD_CF]);
	
	n_Write_out(ptb_InRec_Cur,Kp_GoelPeopOFil,Kbd_Lib[Local_fil].LIBCUR);

RETURN_VAL(0);
}        

/*==============================================================================
objet  : fonction lancee en rupture premiere

retour : OK ---> traitement correctement effectue
==============================================================================*/
int n_ActionFirst(char **ptb_InRec_Cur) 
{
	init_struct();
	RETURN_VAL(OK);
}

/*==============================================================================
objet  : fonction lancee en rupture derniere

retour : OK ---> traitement correctement effectue
==============================================================================*/
int n_ActionLast(char **ptb_InRec_Cur) 
{
	int i,j,k;
	const char montant[6] = "0.000";

	/* pour toutes les repartitions sauf la retro, ajout des zeros manquants 
           dans le fichier de sortie */

	if ( strcmp(ptb_InRec_Cur[TECLEDA_COD_CF],"retro") != 0 ) {

	for ( i=0 ; i < NB_PF ; i++ )
		for ( j=0 ; j < NB_BRCHE ; j++ )
			for ( k=0 ; k < NB_PSTE ; k++ )
				if ( tab_pf[i].brche[j].pste[k].indicateur == 0 )
				fprintf(Kp_GoelPeopOFil,"%s~%s~%s~%s~%s~%s~%s~%s\n",
				Ksz_inv,
				ptb_InRec_Cur[TECLEDA_SSD_CF],
				tab_pf[i].nom,
				ptb_InRec_Cur[TECLEDA_COD_CF],
				tab_pf[i].brche[j].nom,
				tab_pf[i].brche[j].pste[k].nom,
				montant,
				"");
	}
	RETURN_VAL(OK);
}

/*=======================================================================================
objet:  Initialisation de la structure

retour: OK
========================================================================================*/ 
int init_struct()
{
	int i,j,k;

	for ( i=0 ; i < NB_PF ; i++ ) {
		tab_pf[i].indicateur = 0;
		switch (i) {
		case 0 : tab_pf[i].nom = "traite.prop";
			break;
		case 1 : tab_pf[i].nom = "traite.nprop";
			break;
		case 2 : tab_pf[i].nom = "fac.prop";
			break;
		case 3 : tab_pf[i].nom = "fac.nprop";
			break;
		case 4 : tab_pf[i].nom = "autres";
			break;
		default : ;
			}
		for ( j=0 ; j < NB_BRCHE ; j++ ) {
			tab_pf[i].brche[j].indicateur = 0;
			switch (j) {
			case 0 : tab_pf[i].brche[j].nom = "incendie";
				break;
			case 1 : tab_pf[i].brche[j].nom = "catastrophe";
				break;
			case 2 : tab_pf[i].brche[j].nom = "bris.machine";
				break;
			case 3 : tab_pf[i].brche[j].nom = "risq.agricol";
				break;
			case 4 : tab_pf[i].brche[j].nom = "auto.ct";
				break;
			case 5 : tab_pf[i].brche[j].nom = "accident.div";
				break;
			case 6 : tab_pf[i].brche[j].nom = "risq.specia";
				break;
			case 7 : tab_pf[i].brche[j].nom = "decennale";
				break;
			case 8 : tab_pf[i].brche[j].nom = "trc.trm";
				break;
			case 9 : tab_pf[i].brche[j].nom = "auto.lt";
				break;
			case 10 : tab_pf[i].brche[j].nom = "resp.civile";
				break;
			case 11 : tab_pf[i].brche[j].nom = "accd.travail";
				break;
			case 12 : tab_pf[i].brche[j].nom = "cdt.caution";
				break;
			case 13 : tab_pf[i].brche[j].nom = "ass.transp";
				break;
			case 14 : tab_pf[i].brche[j].nom = "offshore";
				break;
			case 15 : tab_pf[i].brche[j].nom = "vie.epargne";
				break;
			case 16 : tab_pf[i].brche[j].nom = "vie.deces";
				break;
			case 17 : tab_pf[i].brche[j].nom = "vie.financmt";
				break;
			case 18 : tab_pf[i].brche[j].nom = "vie.lissage";
				break;
			case 19 : tab_pf[i].brche[j].nom = "vie.fronting";
				break;
			case 20 : tab_pf[i].brche[j].nom = "vie.affparti";
				break;
			case 21 : tab_pf[i].brche[j].nom = "vie.accident";
				break;
			case 22 : tab_pf[i].brche[j].nom = "vie.invalide";
				break;
			case 23 : tab_pf[i].brche[j].nom = "vie.maladie";
				break;
			case 24 : tab_pf[i].brche[j].nom = "vie.chomage";
				break;
			case 25 : tab_pf[i].brche[j].nom = "vie.depend";
				break;
			case 26 : tab_pf[i].brche[j].nom = "ass.aviation";
				break;
			case 27 : tab_pf[i].brche[j].nom = "espace";
				break;
			case 28 : tab_pf[i].brche[j].nom = "ass.autres";
				break;
			case 29 : tab_pf[i].brche[j].nom = "esp.autres";
				break;
			default : ;
				}
			for ( k=0 ; k < NB_PSTE ; k++ ) {
				tab_pf[i].brche[j].pste[k].indicateur = 0;
				switch(k) {
				case 0 : tab_pf[i].brche[j].pste[k].nom = "prime.emise";
					break;
				case 1 : tab_pf[i].brche[j].pste[k].nom = "Ent.portf.pr";
					break;
				case 2 : tab_pf[i].brche[j].pste[k].nom = "Ret.portf.pr";
					break;
				case 3 : tab_pf[i].brche[j].pste[k].nom = "rec.ouvertur";
					break;
				case 4 : tab_pf[i].brche[j].pste[k].nom = "rec.cloture";
					break;
				case 5 : tab_pf[i].brche[j].pste[k].nom = "sinist.payes";
					break;
				case 6 : tab_pf[i].brche[j].pste[k].nom = "E.portf.sin";
					break;
				case 7 : tab_pf[i].brche[j].pste[k].nom = "R.portf.sin";
					break;
				case 8 : tab_pf[i].brche[j].pste[k].nom = "sap.ouvertur";
					break;
				case 9 : tab_pf[i].brche[j].pste[k].nom = "sap.cloture";
					break;
				case 10 : tab_pf[i].brche[j].pste[k].nom = "IBNR.ouvert";
					break;
				case 11 : tab_pf[i].brche[j].pste[k].nom = "IBNR.cloture";
					break;
				case 12 : tab_pf[i].brche[j].pste[k].nom = "prov.cpl.ouv";
					break; 
 				case 13 : tab_pf[i].brche[j].pste[k].nom = "prov.cpl.clo";
					break;
				case 14 : tab_pf[i].brche[j].pste[k].nom = "com.payees";
					break;
				case 15 : tab_pf[i].brche[j].pste[k].nom = "dac.ouvertur";
					break;
				case 16 : tab_pf[i].brche[j].pste[k].nom = "dac.cloture";
					break; 
				case 17 : tab_pf[i].brche[j].pste[k].nom = "surcommiss";
					break;
				default : ; 
					}
				} 
			} 
		}
	RETURN_VAL(OK);
}

/*==============================================================================
objet :
   fonction d'extraction des donnees de la table TSUBSID de la base BREF
   Sont extraits le libelle (court) filiale, le code langue, la monnaie filiale

retour : OK
	 ERR
==============================================================================*/
/*
static int n_ChargLib(FILE *p_Libelle)
{
  T_LIB_SSD     bd_lu; 

  DEBUT_FCT ("n_ChargLib");

	memset(Kbd_Lib,0,sizeof(Kbd_Lib));


      while (fread(&bd_lu,sizeof(T_LIB_SSD),1,p_Libelle) > 0 )
      {
	if ( bd_lu.SSD <= NB_SSD_MAX )
		Kbd_Lib[(int)bd_lu.SSD] = bd_lu;
	else 
    		RETURN_VAL(ERR);

      }

  RETURN_VAL(OK);
}
*/
/*=============================================================================
 objet:  Procedure d'ecriture dans le fichier sortie

 retour: 
=============================================================================*/
int n_Write_out(char **ptb_InRec_Cur,FILE *f,char *monnaie) 
{
	int i=0;
	int j=0;
	int k=0;

	/* pour toutes les repartitions sauf retro, mise en place des
	   indicateurs de zeros manquants */
	
	if ( strcmp(ptb_InRec_Cur[TECLEDA_COD_CF],"RETRO") != 0 ) {

	while ( strcmp(tab_pf[i].nom,ptb_InRec_Cur[TECLEDA_NAT_CF]) != 0 ) i++;
	tab_pf[i].indicateur++;

	while ( strcmp(tab_pf[i].brche[j].nom,ptb_InRec_Cur[TECLEDA_LOBACC_CF]) != 0 ) j++;
	tab_pf[i].brche[j].indicateur++;


	while ( strcmp(tab_pf[i].brche[j].pste[k].nom,ptb_InRec_Cur[TECLEDA_TRNCOD_CF]) != 0 ) k++;
	tab_pf[i].brche[j].pste[k].indicateur++;
	}	

	fprintf(f,"%s~%s~%s~%s~%s~%s~%s~%s\n",
				Ksz_inv,
				ptb_InRec_Cur[TECLEDA_SSD_CF],
				ptb_InRec_Cur[TECLEDA_NAT_CF],
				ptb_InRec_Cur[TECLEDA_COD_CF],
				ptb_InRec_Cur[TECLEDA_LOBACC_CF],
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF],
				ptb_InRec_Cur[TECLEDA_AMT_M],
				"");
  RETURN_VAL(OK);
}
	
