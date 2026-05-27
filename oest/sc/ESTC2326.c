/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*=============================================================================
Nom de l'application          :
nom du source                 : ESTC2326.c
revision                      :
date de creation              : 10/1997
auteur                        : CGI Kuhna
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description : Calcul des ecarts
 Synchro sur la partie retrocession : contrat/avenant/N section/
 Exercice/N Ordre exercice/Monnaie/Annee de compte/
 Periode de compte debut/Periode de compte fin et sur
 Poste comptable (partie acceptation).


------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    1998/08/04    M.HA-THUC	On ne sort plus d'anomalies si des lignes du GTAR
				n'ont pas d'equivalent dans le GTR sur la cle
				de synchronisation

    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
[003] 25/06/2012 R. Cassis   :spot:23802  Agrandissement tableau contrats retro de 7500 a 30000 et de 3000 a 10000

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
#define MAXLINGTAr    50000
#define MAXLINGTR     50000

#define GT_OVRCOM_R   GT_RETKEY_CF + 1
#define GT_FIN        GT_OVRCOM_R  + 2


/*----------------------------------*/

typedef struct {
CS_TINYINT      SSD_CF;
CS_TINYINT      ESB_CF;
CS_SMALLINT     BALSHEY_NF;
CS_TINYINT      BALSHRMTH_NF;
CS_TINYINT      BALSHRDAY_NF;
CS_CHAR         TRNCOD_CF[9];
CS_CHAR         DBLTRNCOD_CF[9];
CS_CHAR         CTR_NF[10];
CS_TINYINT      END_NT;
CS_TINYINT      SEC_NF;
CS_SMALLINT     UWY_NF;
CS_TINYINT      UW_NT;
CS_SMALLINT     OCCYEA_NF;
CS_SMALLINT     ACY_NF;
CS_TINYINT      SCOSTRMTH_NF;
CS_TINYINT      SCOENDMTH_NF;
CS_INT          CLM_NF;
CS_CHAR         CUR_CF[4];
CS_FLOAT        AMT_M;
CS_INT          CED_NF;
CS_INT          BRK_NF;
CS_INT          PAY_NF;
CS_CHAR         KEY_NF[3];
CS_FLOAT        RETAMT_M;
} T_GTAr;

typedef struct {
CS_TINYINT      SSD_CF;
CS_TINYINT      ESB_CF;
CS_SMALLINT     BALSHEY_NF;
CS_TINYINT      BALSHRMTH_NF;
CS_TINYINT      BALSHRDAY_NF;
CS_CHAR         TRNCOD_CF[9];
CS_CHAR         DBLTRNCOD_CF[9];
CS_CHAR         RETCTR_NF[10];
CS_TINYINT      RETEND_NT;
CS_TINYINT      RETSEC_NF;
CS_SMALLINT     RTY_NF;
CS_TINYINT      RETUW_NT;
CS_SMALLINT     RETOCCYEA_NF;
CS_SMALLINT     RETACY_NF;
CS_TINYINT      RETSCOSTRMTH_NF;
CS_TINYINT      RETSCOENDMTH_NF;
CS_INT          RCL_NF;
CS_CHAR         RETCUR_CF[4];
CS_FLOAT        RETAMT_M;
CS_INT          PLC_NT;
CS_INT          RTO_NF;
CS_INT          INT_NF;
CS_INT          RETPAY_NF;
CS_CHAR         RETKEY_CF;
CS_FLOAT        OVRCOM_R;
} T_GTR;


/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE  	     *Kp_OutputFil, /*pointeur sur le fichier de sortie: GTArR*/
  	           *Kp_GTAno;     /*pointeur sur le fichier de sortie en cas
                                    d'anomalie : GTAno*/
T_RUPTURE_VAR      bd_RuptGTAr;   /*variable de gestion de la rupture sur
                                    le fichier GTArR*/
T_RUPTURE_SYNC_VAR bd_RuptGTR;   /*variable de gestion de la synchro
                                    entre le fic GTAr et le fic GTR*/

T_GTAr            Kptb_GTAr[MAXLINGTAr];
T_GTR             Kptb_GTR[MAXLINGTR];


double             Kd_MrGTAr,
                   Kd_MrGTR;

int                Kn_i,
                   Kn_j,
                   Kn_LgGTAr,
                   Kn_LgGTR;

short		   Kn_GtrPa ; /* indicateur de synchronisation du GTR avec le GTAR */

static int Kb_TGTARDepass;
static int Kb_TGTRDepass;

double             Kd_Seuil;

char               MsgAno[200];

                                 /* Valeur renvoyee par le programme */
unsigned char      Kc_ReturnStatus = 0;

int Kn_initGTR(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int Kn_isR1GTAr(char **ptb_InRec,char **ptb_InRec_Cur);
int n_ActionFirstRuptGTAr(char **ptb_InRec_Cur);
int n_ActionLigneGTR(char **ptb_InRecOwner,char **pbd_InRecChild);
int n_ActionLastRuptGTAr(char **ptb_InRec_Cur);
int n_ConditionSyncGTR(char **ptb_InRecOwner,char **pbd_InRecChild);

int n_ActionFilsSansPereGTR(char **ptb_InRec);

int Kn_initGTAr(T_RUPTURE_VAR  *pbd_Rupt);
int n_ActionLigneGTAr(char **pbd_InRec_Cur);

int n_ProcessingRuptureSyncVar (
  T_RUPTURE_SYNC_VAR  *pbd_Rupt,
  char  	      **ptb_InRecOwner);

int n_ProcessingRuptureVar(
  T_RUPTURE_VAR       *pbd_Rupt);

void o_ConstConvGTAr(char **ptb_L);
void o_ConstConvGTR(char **ptb_L);
int  n_EcritLigGTArR(
  T_GTAr        *pdb_1,
  T_GTR        *pdb_2,
  unsigned char c_TypEc,
  double        d_MtAcc,
  double        d_MtRetro);
/*=============================================================================
objet :
        cette fct alimente la Kn_ieme ligne du tableau GTAr avec chacun
        des champs de la ligne en cours de synchro du GTAr (ces champs
        sont convertis dans leur type d'origine)

==============================================================================*/
void o_ConstConvGTAr(
  char **ptb_L)     /* i- pointeur sur ligne GTAr en cours de traitement */

{
  Kptb_GTAr[Kn_i].SSD_CF        = (unsigned char)
                                atoi(ptb_L[GT_SSD_CF]);
  Kptb_GTAr[Kn_i].ESB_CF        = (unsigned char)
                                atoi(ptb_L[GT_ESB_CF]);
  Kptb_GTAr[Kn_i].BALSHEY_NF    = (short)
                                atoi(ptb_L[GT_BALSHEY_NF]);
  Kptb_GTAr[Kn_i].BALSHRMTH_NF  = (unsigned char)
                                atoi(ptb_L[GT_BALSHRMTH_NF]);
  Kptb_GTAr[Kn_i].BALSHRDAY_NF  = (unsigned char)
                                atoi(ptb_L[GT_BALSHRDAY_NF]);

  strcpy(Kptb_GTAr[Kn_i].TRNCOD_CF,ptb_L[GT_TRNCOD_CF]);
  strcpy(Kptb_GTAr[Kn_i].DBLTRNCOD_CF,ptb_L[GT_DBLTRNCOD_CF]);
  strcpy(Kptb_GTAr[Kn_i].CTR_NF,ptb_L[GT_CTR_NF]);

  Kptb_GTAr[Kn_i].END_NT        = (unsigned char)
                                atoi(ptb_L[GT_END_NT]);
  Kptb_GTAr[Kn_i].SEC_NF        = (unsigned char)
                                atoi(ptb_L[GT_SEC_NF]);
  Kptb_GTAr[Kn_i].UWY_NF        = (short)
                                atoi(ptb_L[GT_UWY_NF]);
  Kptb_GTAr[Kn_i].UW_NT         = (unsigned char)
                                atoi(ptb_L[GT_UW_NT]);
  Kptb_GTAr[Kn_i].OCCYEA_NF     = (short)
                                atoi(ptb_L[GT_OCCYEA_NF]);
  Kptb_GTAr[Kn_i].ACY_NF        = (short)
                                atoi(ptb_L[GT_ACY_NF]);
  Kptb_GTAr[Kn_i].SCOSTRMTH_NF  = (unsigned char)
                                atoi(ptb_L[GT_SCOSTRMTH_NF]);
  Kptb_GTAr[Kn_i].SCOENDMTH_NF  = (unsigned char)
                                atoi(ptb_L[GT_SCOENDMTH_NF]);
  Kptb_GTAr[Kn_i].CLM_NF        = atoi(ptb_L[GT_CLM_NF]);

  strcpy(Kptb_GTAr[Kn_i].CUR_CF,ptb_L[GT_CUR_CF]);

  Kptb_GTAr[Kn_i].AMT_M         = (double)
                                atof(ptb_L[GT_AMT_M]);
  Kptb_GTAr[Kn_i].CED_NF        = atoi(ptb_L[GT_CED_NF]);
  Kptb_GTAr[Kn_i].BRK_NF        = atoi(ptb_L[GT_BRK_NF]);
  Kptb_GTAr[Kn_i].PAY_NF        = atoi(ptb_L[GT_PAY_NF]);
  strcpy(Kptb_GTAr[Kn_i].KEY_NF,ptb_L[GT_KEY_NF]);

  Kptb_GTAr[Kn_i].RETAMT_M      = (double)
                                atof(ptb_L[GT_RETAMT_M]);
}


/*=============================================================================
objet :
        cette fct alimente la Kn_jeme ligne du tableau GTR avec chacun
        des champs de la ligne en cours de synchro du GTR (ces champs
        sont convertis dans leur type d'origine)

==============================================================================*/
void o_ConstConvGTR(
  char **ptb_L)     /* i- pointeur sur ligne GTR en cours de traitement */
{
  strcpy(Kptb_GTR[Kn_j].TRNCOD_CF,ptb_L[GT_TRNCOD_CF]);
  strcpy(Kptb_GTR[Kn_j].RETCTR_NF,ptb_L[GT_RETCTR_NF]);

  Kptb_GTR[Kn_j].RETEND_NT     = (unsigned char)
                                atoi(ptb_L[GT_RETEND_NT]);
  Kptb_GTR[Kn_j].RETSEC_NF     = (unsigned char)
                                atoi(ptb_L[GT_RETSEC_NF]);
  Kptb_GTR[Kn_j].RTY_NF        = (short)
                                atoi(ptb_L[GT_RTY_NF]);
  Kptb_GTR[Kn_j].RETUW_NT      = (unsigned char)
                                atoi(ptb_L[GT_RETUW_NT]);
  Kptb_GTR[Kn_j].RETOCCYEA_NF  = (short)
                                atoi(ptb_L[GT_RETOCCYEA_NF]);
  Kptb_GTR[Kn_j].RETACY_NF     = (short)
                                atoi(ptb_L[GT_RETACY_NF]);
  Kptb_GTR[Kn_j].RETSCOSTRMTH_NF  = (unsigned char)
                                atoi(ptb_L[GT_RETSCOSTRMTH_NF]);
  Kptb_GTR[Kn_j].RETSCOENDMTH_NF  = (unsigned char)
                                atoi(ptb_L[GT_RETSCOENDMTH_NF]);
  Kptb_GTR[Kn_j].RCL_NF        = atoi(ptb_L[GT_RCL_NF]);

  strcpy(Kptb_GTR[Kn_j].RETCUR_CF,ptb_L[GT_RETCUR_CF]);

  Kptb_GTR[Kn_j].RETAMT_M      = (double)
                                atof(ptb_L[GT_RETAMT_M]);
  Kptb_GTR[Kn_j].PLC_NT        = atoi(ptb_L[GT_PLC_NT]);
  Kptb_GTR[Kn_j].RTO_NF        = atoi(ptb_L[GT_RTO_NF]);
  Kptb_GTR[Kn_j].INT_NF        = atoi(ptb_L[GT_INT_NF]);
  Kptb_GTR[Kn_j].RETPAY_NF     = atoi(ptb_L[GT_RETPAY_NF]);
  Kptb_GTR[Kn_j].RETKEY_CF     = *(ptb_L[GT_RETKEY_CF]);
  Kptb_GTR[Kn_j].OVRCOM_R      = (double)
                                atof(ptb_L[GT_OVRCOM_R]);
}

/*============================================================================
objet :
        dans cette fct on ecrit 1 ligne format GT dans le fic de sortie
        Suivant les valeurs de c_TypEc, la ligne a ecrire est differente
        (elle est composee de champs provenant du GTAr et du GTR, les montants
        y figurant sont passes en parametres)

ctee fct renvoie   OK ---> pas de probleme
                   ERR --> probleme pour ecrire
=============================================================================*/
int n_EcritLigGTArR(
  T_GTAr        *pdb_1,   /* i - pointeur sur 1 ligne GTAr */
  T_GTR        *pdb_2,   /* i - pointeur sur 1 ligne GTR */
  unsigned char c_TypEc,  /* i - Type d'ecriture a effectuer */
  double        d_MtAcc,  /* i - Montant Acceptation */
  double        d_MtRetro)/* i - Montant Retrocession */

{
  switch (c_TypEc)
    {
      case 0 :                      /* Ecriture anomalie */
        if (fprintf(Kp_GTAno,
            "~~~~~%s~~~~~~~~~~~~~~~~~~",
            pdb_2->TRNCOD_CF) < 0) return ERR;

        if (fprintf(Kp_GTAno,
            "%s~%d~%d~%d~%d~~~~~~%s~%.3lf~~~~~\n",
            pdb_2->RETCTR_NF,
            (int) pdb_2->RETEND_NT,
            (int) pdb_2->RETSEC_NF,
            (int) pdb_2->RTY_NF,
            (int) pdb_2->RETUW_NT,
            pdb_2->RETCUR_CF,
            d_MtRetro - d_MtAcc) < 0) return ERR;
        break;

       case 1 :                       /* Ecriture ligne "normale" */
         if (fprintf(Kp_OutputFil,
             "%d~%d~%d~%d~%d~%s~%s~",
             (int) pdb_1->SSD_CF,
	     (int) pdb_1->ESB_CF,
             (int) pdb_1->BALSHEY_NF,
             (int) pdb_1->BALSHRMTH_NF,
             (int) pdb_1->BALSHRDAY_NF,
             pdb_1->TRNCOD_CF,
             pdb_1->DBLTRNCOD_CF) < 0) return ERR;

         if (fprintf(Kp_OutputFil,
             "%s~%d~%d~%d~%d~%d~%d~%d~%d~%d~%s~%.3lf~",
             pdb_1->CTR_NF,
             (int) pdb_1->END_NT,
             (int) pdb_1->SEC_NF,
             (int) pdb_1->UWY_NF,
             (int) pdb_1->UW_NT,
             (int) pdb_1->OCCYEA_NF,
             (int) pdb_1->ACY_NF,
             (int) pdb_1->SCOSTRMTH_NF,
             (int) pdb_1->SCOENDMTH_NF,
             (int) pdb_1->CLM_NF,
             pdb_1->CUR_CF,
             d_MtAcc) < 0) return ERR;

         if (fprintf(Kp_OutputFil,
             "%d~%d~%d~%s~",
             (int) pdb_1->CED_NF,
             (int) pdb_1->BRK_NF,
             (int) pdb_1->PAY_NF,
             (int) pdb_1->KEY_NF) < 0) return ERR;

         if (fprintf(Kp_OutputFil,
             "%s~%d~%d~%d~%d~%d~%d~%d~%d~%d~%s~%.3lf~",
             pdb_2->RETCTR_NF,
             (int) pdb_2->RETEND_NT,
             (int) pdb_2->RETSEC_NF,
             (int) pdb_2->RTY_NF,
             (int) pdb_2->RETUW_NT,
             (int) pdb_2->RETOCCYEA_NF,
             (int) pdb_2->RETACY_NF,
             (int) pdb_2->RETSCOSTRMTH_NF,
             (int) pdb_2->RETSCOENDMTH_NF,
             (int) pdb_2->RCL_NF,
             pdb_2->RETCUR_CF,
             d_MtRetro) < 0) return ERR;

         if (fprintf(Kp_OutputFil,
             "%d~%d~%d~%d~%c\n",
             (int) pdb_2->PLC_NT,
             (int) pdb_2->RTO_NF,
             (int) pdb_2->INT_NF,
             (int) pdb_2->RETPAY_NF,
             (int) pdb_2->RETKEY_CF) < 0) return ERR;
         break;
      }
  return OK;
}

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

                        /* Recuperation du seuil */
  Kd_Seuil=d_GetFloatArgv(1);

				/* Ouverture du fichier de sortie : GTArR */
  if (n_OpenFileAppl ("ESTC2326_O1","wt",&Kp_OutputFil) == ERR)
    ExitPgm(ERR_XX ,"");

				/* Ouverture du fichier de sortie anomalie:
                                   GTAno */
  if (n_OpenFileAppl ("ESTC2326_O2","wt",&Kp_GTAno) == ERR)
    ExitPgm(ERR_XX ,"");

				/* Initialisation var bd_RuptPlc */
  if (Kn_initGTAr(&bd_RuptGTAr) == ERR)
    ExitPgm(ERR_XX ,"");

				/* Initialisation var bd_RuptGTR */
  if (Kn_initGTR(&bd_RuptGTR) == ERR)
    ExitPgm(ERR_XX ,"");


				/* Lancement traitement fic des GTAr */
  if (n_ProcessingRuptureVar(&bd_RuptGTAr) == ERR)
    ExitPgm(ERR_XX,"Too much lines in array\n");

				/* Fermeture des fichiers */
  if (n_CloseFileAppl("ESTC2326_I1",&(bd_RuptGTAr.pf_InputFil)) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_CloseFileAppl("ESTC2326_I2",&(bd_RuptGTR.pf_InputFil)) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_CloseFileAppl("ESTC2326_O1",&Kp_OutputFil) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_CloseFileAppl("ESTC2326_O2",&Kp_GTAno) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_EndPgm() == ERR)
    ExitPgm ( ERR_XX , "" );

  exit(Kc_ReturnStatus);
}


/*==============================================================================
objet :
	fonction d'initialisation de la variable de gestion de rupture
        du fichier GTAr.

retour :
	0K
==============================================================================*/
int Kn_initGTAr(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

					/* Ouverture du fic GTAr */
  if (n_OpenFileAppl("ESTC2326_I1","rt",&(pbd_Rupt->pf_InputFil)) == ERR)
    return ERR;

  pbd_Rupt->n_NbRupture = 1;

  pbd_Rupt->n_ConditionRupture[0] = Kn_isR1GTAr;
  pbd_Rupt->n_ActionFirst[0]      = n_ActionFirstRuptGTAr;
  pbd_Rupt->n_ActionLigne         = n_ActionLigneGTAr;
  pbd_Rupt->n_ActionLast[0]       = n_ActionLastRuptGTAr;

  pbd_Rupt->c_Separ = SEPARATEUR;

  return OK;
}

/*==============================================================================
objet :
	fonction de test de rupture de niveau 1

retour :
	0 ---> pas de rupture
	dif de 0 ---> rupture
===========================================================================*/
int Kn_isR1GTAr(char **ptb_InRec,char **ptb_InRec_Cur)
{
  int ret;
				/* Test de correspondance entre ligne courante
                                   et ligne suivante sur :
                              		  	    Contrat retrocession */
  ret = strcmp(ptb_InRec[GT_RETCTR_NF],ptb_InRec_Cur[GT_RETCTR_NF]);
  if (ret != 0)
     return ret;

                              			  /* Avenant retrocession */
  ret = strcmp(ptb_InRec[GT_RETEND_NT],ptb_InRec_Cur[GT_RETEND_NT]);
  if (ret != 0)
     return ret;

                               			 /* Num Section retrocession */
  ret = strcmp(ptb_InRec[GT_RETSEC_NF],ptb_InRec_Cur[GT_RETSEC_NF]);
  if (ret != 0)
     return ret;

                               			 /* Exercice retrocession */
  ret = strcmp(ptb_InRec[GT_RTY_NF],ptb_InRec_Cur[GT_RTY_NF]);
  if (ret != 0)
     return ret;

                               			 /* Num ordre exercice
                                                    retrocession */
  ret = strcmp(ptb_InRec[GT_RETUW_NT],ptb_InRec_Cur[GT_RETUW_NT]);
  if (ret != 0)
     return ret;

						/* Monnaie compte retrocession*/
  ret = strcmp(ptb_InRec[GT_RETCUR_CF],ptb_InRec_Cur[GT_RETCUR_CF]);
  if (ret != 0)
     return ret;

						/* Poste comptable */
  ret = strcmp(ptb_InRec[GT_TRNCOD_CF],ptb_InRec_Cur[GT_TRNCOD_CF]);
  if (ret != 0)
     return ret;

  /**************************************/
  /* Modifs du 20/07/98 - M.HA-THUC 	*/
  /* Suppression dans la cle de     	*/
  /* rupture de RETOCCYEA_NF et RCL_NF	*/
  /**************************************/
                                                /* Annee de survenance */
  /* ret = strcmp(ptb_InRec[GT_RETOCCYEA_NF],ptb_InRec_Cur[GT_RETOCCYEA_NF]);
  if (ret != 0)
     return ret; */

                                                /* Num de sinistre*/
  /* ret = strcmp(ptb_InRec[GT_RCL_NF],ptb_InRec_Cur[GT_RCL_NF]);
  if (ret != 0)
     return ret; */

  /******************************************/
  /* Modifs du 19/01/99 - M.Bourdaillet	    */
  /* Suppression dans la cle de     	    */
  /* rupture de RETACY_NF et RETSCOENDMTH_NF*/
  /* et de RETSCOENDMTH_NF                  */
  /******************************************/
                                                /* Annee de compte */
  /*ret = strcmp(ptb_InRec[GT_RETACY_NF],ptb_InRec_Cur[GT_RETACY_NF]);
  if (ret != 0)
     return ret;*/

                                                /* Debut de periode de compte*/
  /*ret = strcmp(ptb_InRec[GT_RETSCOSTRMTH_NF],ptb_InRec_Cur[GT_RETSCOSTRMTH_NF]);
  if (ret != 0)
     return ret;*/

                                                /* Fin de periode de compte*/
  /*ret = strcmp(ptb_InRec[GT_RETSCOENDMTH_NF],ptb_InRec_Cur[GT_RETSCOENDMTH_NF]);
  if (ret != 0)
     return ret;*/

  return 0;
}


/*==============================================================================
objet :
	fonction lancee a la rupture premiere de niveau 1

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionFirstRuptGTAr(char **ptb_InRec_Cur)
{
				/* Initialisation des cumuls
				   montants retrocession */
  Kd_MrGTAr = 0;
  Kd_MrGTR = 0;

				/* Initialisation des indices de
                                   parcours des 2 tableaux a construire*/
  Kn_i = 0;
  Kn_j = 0;

				/* Initialisation de la variable de participation */
  Kn_GtrPa = 0 ;
				/* Initialisation variable de depassement */
  Kb_TGTRDepass=0;
  Kb_TGTARDepass=0;
                                /* Synchronisation avec le GTR */
  if (n_ProcessingRuptureSyncVar(&bd_RuptGTR,ptb_InRec_Cur) == ERR)
    return ERR;

  return OK;
}

/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionLigneGTAr(char **ptb_InRec_Cur)
{
   char MsgAno[300];
        DEBUT_FCT ("n_ActionLigneGTAr") ;

if (Kb_TGTARDepass==0)
   {
					/* Construction du tab Kptb_GTAr
                                           Conversion des donnees exprimees
                                           sous forme de chaines de caracteres
                                           en donnees numeriques*/

   o_ConstConvGTAr(ptb_InRec_Cur);

					/* Cumul des montants retrocession
                                           de GTAr*/
   Kd_MrGTAr = Kd_MrGTAr + Kptb_GTAr[Kn_i].RETAMT_M;

   Kn_i ++;                              /* Incrementation ind tab GTAr */

   if (Kn_i >= MAXLINGTAr)               /* Depassement de capacite tab GTAr */
        {
         sprintf(MsgAno,"The number of records in GTAr file for contract (/RETCTR %s /RETEND %s /RETSEC %s /RTY %s /RETUW %s) overflows the program's storage capacity\n",
                      ptb_InRec_Cur[GT_RETCTR_NF],
                      ptb_InRec_Cur[GT_RETEND_NT],
                      ptb_InRec_Cur[GT_RETSEC_NF],
                      ptb_InRec_Cur[GT_RTY_NF],
                      ptb_InRec_Cur[GT_RETUW_NT]);

        n_WriteAno(MsgAno);
        Kb_TGTARDepass=1;
        Kc_ReturnStatus = 1;
        }
   }
  return OK;
}

/*==============================================================================
objet :
	fonction lancee en rupture derniere de niveau 1

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionLastRuptGTAr(char **ptb_InRec_Cur)
{
  static T_GTAr   *pdb_1;
  static T_GTR    *pdb_2;

  static double    d_Acc,
                   d_Retro,
                   d_Taux;

  int              n_i,
                   n_j;

                                       /* Lg des 2 tab GTAr et GTR */
  Kn_LgGTAr = Kn_i;
  Kn_LgGTR = Kn_j;

  /**************************************************************/
  /* Generation d'une anomalie si des lignes du GTAR n'ont pas	*/
  /* d'equivalent dans le GTR sur la cle de synchro et si le	*/
  /* montant cumule est non nul					*/
  /**************************************************************/
  if ( Kn_GtrPa == 0 && fabs( Kd_MrGTAr ) > Kd_Seuil )
  {
	sprintf(MsgAno,"There is no row in GTR corresponding to\
          %s %s %s %s %s %s %s %s %s %s from GTAr\n",
          ptb_InRec_Cur[GT_RETCTR_NF],
          ptb_InRec_Cur[GT_RETEND_NT],
          ptb_InRec_Cur[GT_RETSEC_NF],
          ptb_InRec_Cur[GT_RTY_NF],
          ptb_InRec_Cur[GT_RETUW_NT],
          ptb_InRec_Cur[GT_RETCUR_CF],
          ptb_InRec_Cur[GT_TRNCOD_CF],
	  ptb_InRec_Cur[GT_RETACY_NF],
	  ptb_InRec_Cur[GT_RETSCOSTRMTH_NF],
	  ptb_InRec_Cur[GT_RETSCOENDMTH_NF]
	) ;

  	n_WriteAno(MsgAno);
                        /* Valeur retournee par prog -> 1 */
/*  	Kc_ReturnStatus = 1; *//* On ne fait plus planter le prog (19/1/99)*/

  }

  if ((Kn_LgGTAr == 0) || (Kn_LgGTR == 0)) return OK;

  if (fabs(Kd_MrGTAr - Kd_MrGTR) > (Kd_Seuil * fabs( Kd_MrGTAr )))
                                       /* Les 2 cumuls ne coincident pas ?*/
    {                                  /* Generation d'erreur dans GTAno
                                              1 ligne format GT */
      n_EcritLigGTArR(NULL,Kptb_GTR,0,Kd_MrGTAr,Kd_MrGTR);

      return OK;                       /* Fin de traitement */
    }
				       /* Les 2 mts sont egaux a 1 unite pres */
				       /* Pour chacun des ele du tab GTAr */
    for (n_i = 0 ; n_i < Kn_LgGTAr ; n_i++)
      {
        pdb_1 = Kptb_GTAr + n_i;

				       /* Pour chacun des ele du tab GTR */
        for (n_j = 0 ; n_j < Kn_LgGTR ; n_j++)
          {
            pdb_2 = Kptb_GTR + n_j;

            if (Kd_MrGTR == 0)   /* Calcul du taux impossible */
            {                    /* Division par 0 */
              sprintf(MsgAno,"The retroceded accumulated amount is nul");
              n_WriteAno(MsgAno);
              return OK;         /* sortie de fonction */
            }

                                  /* Calcul Taux */
               /* Modif 15/06/99 : le taux doit etre negatif pour une commission */
            d_Taux = -1*((pdb_2->RETAMT_M) / Kd_MrGTR) * pdb_2->OVRCOM_R;

                                  /* Reajustement des montants */
          d_Acc   = pdb_1->AMT_M * d_Taux;
          d_Retro = pdb_1->RETAMT_M * d_Taux;

          if ((d_Acc != 0) || (d_Retro != 0))
                                      /* Si aucun des 2 montants est nul */
                                      /* Ecriture ligne GTAr-GTR */
            n_EcritLigGTArR(pdb_1,
                            pdb_2,
                            1,
                            d_Acc,
                            d_Retro);


        }  /*fin boucle n_j*/
      }  /*fin boucle n_i*/
  return OK;
}

/*
int n_ActionFilsSansPereGTR(
  char **ptb_InRecChild)
{
  sprintf(MsgAno,"There is no row in GTAr corresponding to\
          %s %s %s %s %s %s %s %s %s %s from GTR\n",
          ptb_InRecChild[GT_RETCTR_NF],
          ptb_InRecChild[GT_RETEND_NT],
          ptb_InRecChild[GT_RETSEC_NF],
          ptb_InRecChild[GT_RTY_NF],
          ptb_InRecChild[GT_RETUW_NT],
          ptb_InRecChild[GT_RETCUR_CF],
          ptb_InRecChild[GT_TRNCOD_CF],
          ptb_InRecChild[GT_RETACY_NF],
          ptb_InRecChild[GT_RETSCOSTRMTH_NF],
          ptb_InRecChild[GT_RETSCOENDMTH_NF]
	);
  n_WriteAno(MsgAno);
  Kc_ReturnStatus = 1;
}
*/

/*==============================================================================
objet :
     Initialisation de la synchronisation du fic maitre (fic GTAr)
     avec l'esclave (fic GTR)

retour :
	OK
==============================================================================*/
int Kn_initGTR(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR)) ;

				/* Ouverture du fichier esclave (GTR) */
  if (n_OpenFileAppl ("ESTC2326_I2","rt",&(pbd_Rupt->pf_InputFil)) == ERR)
    ExitPgm(ERR_XX,"");

				/* Fonction de test de la ligne du maitre
 			       	   GTAr avec l'esclave GTR */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncGTR;

				/* Fonction d'action sur la ligne courante
                                   du fichier esclave GTR */
  pbd_Rupt->n_ActionLigne = n_ActionLigneGTR;

/*  pbd_Rupt->n_FilsSansPere = n_ActionFilsSansPereGTR;*/

  pbd_Rupt->c_Separ = SEPARATEUR;

  return OK;
}


/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0	---> pbd_InRecOwner = pbd_InRecChild
	> 0   	---> pbd_InRecOwner > pbd_InRecChild
	< 0   	---> pbd_InRecOwner < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncGTR(
  char **pbd_InRecOwner, /* adresse de la ligne du maitre fic GTAr */
  char **pbd_InRecChild) /* adresse de la ligne de l'esclave GTR*/
{
  int ret ;

  ret = strcmp(pbd_InRecOwner[GT_RETCTR_NF],pbd_InRecChild[GT_RETCTR_NF]);
  if (ret != 0)
     return ret;

                              			  /* Avenant retrocession */
  ret = strcmp(pbd_InRecOwner[GT_RETEND_NT],pbd_InRecChild[GT_RETEND_NT]);
  if (ret != 0)
     return ret;

                               			 /* Num Section retrocession */
  ret = strcmp(pbd_InRecOwner[GT_RETSEC_NF],pbd_InRecChild[GT_RETSEC_NF]);
  if (ret != 0)
     return ret;

                               			 /* Exercice retrocession */
  ret = strcmp(pbd_InRecOwner[GT_RTY_NF],pbd_InRecChild[GT_RTY_NF]);
  if (ret != 0)
     return ret;

                               			 /* Num ordre exercice
                                                    retrocession */
  ret = strcmp(pbd_InRecOwner[GT_RETUW_NT],pbd_InRecChild[GT_RETUW_NT]);
  if (ret != 0)
     return ret;

						/* Monnaie compte retrocession*/
  ret = strcmp(pbd_InRecOwner[GT_RETCUR_CF],pbd_InRecChild[GT_RETCUR_CF]);
  if (ret != 0)
     return ret;

						/* Poste comptable */
  ret = strcmp(pbd_InRecOwner[GT_TRNCOD_CF],pbd_InRecChild[GT_TRNCOD_CF]);
  if (ret != 0)
     return ret;

  /**************************************/
  /* Modifs du 20/07/98 - M.HA-THUC 	*/
  /* Suppression dans la cle de     	*/
  /* synchro de RETOCCYEA_NF et RCL_NF	*/
  /**************************************/
                                                /* Annee de survenance */
  /* ret = strcmp(pbd_InRecOwner[GT_RETOCCYEA_NF],pbd_InRecChild[GT_RETOCCYEA_NF]);
  if (ret != 0)
     return ret; */

                                                /* Num de sinistre*/
  /* ret = strcmp(pbd_InRecOwner[GT_RCL_NF],pbd_InRecChild[GT_RCL_NF]);
  if (ret != 0)
     return ret; */

  /******************************************/
  /* Modifs du 19/01/99 - M.Bourdaillet	    */
  /* Suppression dans la cle de     	    */
  /* rupture de RETACY_NF et RETSCOENDMTH_NF*/
  /* et de RETSCOENDMTH_NF                  */
  /******************************************/
                                                /* Annee de compte */
  /*ret = strcmp(pbd_InRecOwner[GT_RETACY_NF],pbd_InRecChild[GT_RETACY_NF]);
  if (ret != 0)
     return ret;*/

                                                /* Debut de periode de compte*/
  /*ret = strcmp(pbd_InRecOwner[GT_RETSCOSTRMTH_NF],
               pbd_InRecChild[GT_RETSCOSTRMTH_NF]);
  if (ret != 0)
     return ret;*/

                                                /* Fin de periode de compte*/
  /*ret = strcmp(pbd_InRecOwner[GT_RETSCOENDMTH_NF],
               pbd_InRecChild[GT_RETSCOENDMTH_NF]);
  if (ret != 0)
     return ret;*/

  return 0;
}

/*============================================================================
objet :
	fonction lancee pour chaque ligne

retour :OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionLigneGTR(
  char **ptb_InRecOwner, /* adresse de la ligne du maitre fic GTAr */
  char **ptb_InRecChild) /* adresse de la ligne de l'esclave GTR */

{
   char MsgAno[300];
        DEBUT_FCT ("n_ActionLigneGTR") ;

					/* Participation du GTR */
  Kn_GtrPa = 1 ;

if (Kb_TGTRDepass==0)
   {
					/* Construction du tab Kptb_GTR */
   o_ConstConvGTR(ptb_InRecChild);
					/* Cumul des montants retrocession
                                           de GTR*/
   Kd_MrGTR = Kd_MrGTR + Kptb_GTR[Kn_j].RETAMT_M;

   Kn_j ++;                               /* Incrementation ind tab GTR */
   if (Kn_j >= MAXLINGTR) /* Depassement de capacite tab GTR */
        {
         sprintf(MsgAno,"The number of records in GTR file for contract (/RETCTR %s /RETEND %s /RETSEC %s /RTY %s /RETUW %s) overflows the program's storage capacity\n",
                      ptb_InRecChild[GT_RETCTR_NF],
                      ptb_InRecChild[GT_RETEND_NT],
                      ptb_InRecChild[GT_RETSEC_NF],
                      ptb_InRecChild[GT_RTY_NF],
                      ptb_InRecChild[GT_RETUW_NT]);

        n_WriteAno(MsgAno);
        Kb_TGTRDepass=1;
        Kc_ReturnStatus = 1;

        }
   }
  return OK;
}
