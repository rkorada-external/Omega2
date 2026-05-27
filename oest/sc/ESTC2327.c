/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*=============================================================================
Nom de l'application          :
nom du source                 : ESTC2327.c
revision                      :
date de creation              : 10/1997
auteur                        : CGI Kuhna
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description : Calcul de l'ecart brut
 Synchro sur la partie retrocession : contrat/avenant/N section/
 Exercice/N Ordre exercice entre le perimetre et le fichier de synthese
 des ecarts

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
	   ...           ...            ...              ...
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <stdarg.h>
#include <struct.h>

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE  	     *Kp_OutputFil; /*pointeur sur le fichier de sortie */

T_RUPTURE_VAR      bd_RuptPer;   /*variable de gestion de la rupture sur
                                    le fichier perimetre*/
T_RUPTURE_SYNC_VAR bd_RuptEcart;   /*variable de gestion de la synchro */

int Kn_initPer(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLignePer(char **pbd_InRec_Cur);

int Kn_initEcart(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ActionLigneEcart(char **ptb_InRecOwner,char **pbd_InRecChild);
int n_ConditionSyncEcart(char **ptb_InRecOwner,char **pbd_InRecChild);

int n_ProcessingRuptureSyncVar (
  T_RUPTURE_SYNC_VAR  *pbd_Rupt,
  char  	      **ptb_InRecOwner);

int n_ProcessingRuptureVar(
  T_RUPTURE_VAR       *pbd_Rupt);

/*==============================================================================
objet : point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc,char *argv[])
{
				/* Initialisation des signaux */
  InitSig ();

  if (n_BeginPgm (argc,argv) == ERR)
    ExitPgm(ERR_XX ,"");

				/* Ouverture du fichier de sortie */
  if (n_OpenFileAppl ("ESTC2327_O1","wt",&Kp_OutputFil) == ERR)
    ExitPgm(ERR_XX ,"");

				/* Initialisation var bd_RuptPlc */
  if (Kn_initPer(&bd_RuptPer) == ERR)
    ExitPgm(ERR_XX ,"");

				/* Initialisation var bd_RuptEcart */
  if (Kn_initEcart(&bd_RuptEcart) == ERR)
    ExitPgm(ERR_XX ,"");

				/* Lancement traitement fic des Per */
  if (n_ProcessingRuptureVar(&bd_RuptPer) == ERR)
    ExitPgm(ERR_XX,"");

				/* Fermeture des fichiers */
  if (n_CloseFileAppl("ESTC2327_I1",&(bd_RuptPer.pf_InputFil)) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_CloseFileAppl("ESTC2327_I2",&(bd_RuptEcart.pf_InputFil)) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_CloseFileAppl("ESTC2327_O1",&Kp_OutputFil) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_EndPgm() == ERR)
    ExitPgm ( ERR_XX , "" );

  exit(OK);
}


/*==============================================================================
objet :
	fonction d'initialisation de la variable de gestion de rupture
        du fichier Per.

retour :
	0K
==============================================================================*/
int Kn_initPer(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

					/* Ouverture du fic Per */
  if (n_OpenFileAppl("ESTC2327_I1","rt",&(pbd_Rupt->pf_InputFil)) == ERR)
    return ERR;

  pbd_Rupt->n_NbRupture = 0;

  pbd_Rupt->n_ActionLigne         = n_ActionLignePer;

  pbd_Rupt->c_Separ = SEPARATEUR;

  RETURN_VAL(OK);
}

/*==============================================================================
objet :
	fonction lancee pour chaque ligne du perimetre
        -> Synchro avec le fichier synthese des ecarts

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionLignePer(char **ptb_InRec_Cur)
{
  /* Synchronisation avec le fichier Ecart */
  n_ProcessingRuptureSyncVar(&bd_RuptEcart,ptb_InRec_Cur);

  RETURN_VAL(OK);
}

/*==============================================================================
objet :
     Initialisation de la synchronisation du fic maitre (fic Per)
     avec l'esclave (fic Ecart)

retour :
	OK
==============================================================================*/
int Kn_initEcart(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR)) ;

				/* Ouverture du fichier esclave (Ecart) */
  if (n_OpenFileAppl ("ESTC2327_I2","rt",&(pbd_Rupt->pf_InputFil)) == ERR)
    ExitPgm(ERR_XX,"");

				/* Fonction de test de la ligne du maitre
 			       	   Per avec l'esclave Ecart */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncEcart;

				/* Fonction d'action sur la ligne courante
                                   du fichier esclave Ecart */
  pbd_Rupt->n_ActionLigne = n_ActionLigneEcart;

  pbd_Rupt->c_Separ = SEPARATEUR;

  RETURN_VAL(OK);
}


/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0	---> pbd_InRecOwner = pbd_InRecChild
	> 0   	---> pbd_InRecOwner > pbd_InRecChild
	< 0   	---> pbd_InRecOwner < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncEcart(
  char **pbd_InRecOwner, /* adresse de la ligne du maitre fic Per */
  char **pbd_InRecChild) /* adresse de la ligne de l'esclave Ecart*/
{
  int ret ;

  if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[FRAPP_RETCTR_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[FRAPP_RETEND_NT] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[FRAPP_RETSEC_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[FRAPP_RTY_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[FRAPP_RETUW_NT] ) ) != 0 ) return ret ;

  RETURN_VAL(0);
}

/*============================================================================
objet :
	fonction lancee pour chaque ligne

retour :OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionLigneEcart(
  char **ptb_InRecOwner, /* adresse de la ligne du maitre fic Per */
  char **ptb_InRecChild) /* adresse de la ligne de l'esclave Ecart */

{
  int n_i;

  double d_SommeMt,
         d_EcartEpure,
         d_EcartBrut;

  char sz_EcartEpure[30],
       sz_EcartBrut[30];
                                    /* Calcul Ecart brut */
  d_EcartBrut =  atof(ptb_InRecChild[FRAPP_ACRES_M])
               - atof(ptb_InRecChild[FRAPP_THRES_M]);

                                    /* Calcul somme des AMTi_M
                                       (i de 2 a 11) */
  d_SommeMt = 0;
  for (n_i = FRAPP_AMT2_M ; n_i <= FRAPP_AMT11_M ; n_i++)
   d_SommeMt = d_SommeMt + atof(ptb_InRecChild[n_i]);

                                    /* Calcul ecat epure */
  d_EcartEpure = d_EcartBrut - d_SommeMt;

  sprintf(sz_EcartBrut,"%.3lf",d_EcartBrut);
  sprintf(sz_EcartEpure,"%.3lf",d_EcartEpure);

  ptb_InRecChild[FRAPP_AMT1_M] = sz_EcartBrut;
  ptb_InRecChild[FRAPP_AMT12_M] = sz_EcartEpure;

  if (atoi(ptb_InRecOwner[PER_RETCTRCAT_CF])==2)
    ptb_InRecChild[FRAPP_RETNAT_CF] = "N";
  else ptb_InRecChild[FRAPP_RETNAT_CF] = "P";

  n_WriteCols(Kp_OutputFil,ptb_InRecChild,SEPARATEUR,0);

  RETURN_VAL(OK);
}
