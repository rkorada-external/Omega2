/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*=============================================================================
Nom de l'application          :
nom du source                 : ESTC8932.c
revision                      :
date de creation              : 1/8/1997
auteur                        : Kuhna
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
 Generation du GTArR pour les retrocessionnaires internes a partir du GTAr
 et du GTrR. Synchro sur la partie retrocession : contrat/avenant/N section/
 Exercice/N Ordre exercice/Monnaie/Annee de survenance/Annee de compte/
 Periode de compte debut/Periode de compte fin/N sinistre et sur
 Poste comptable (partie acceptation).


------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>

Changement du nom du prog C ( anciennement INVC8932.c ) effectue par M.Ha-Thuc
le 27/02/1998

    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
    09/12/2011   JF VDV      SPOT 23025  multiplier par 10 les deux compteurs  MAXLINGTAr et MAXLINGTrR

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
#define MAXLINGTAr      200000
#define MAXLINGTrR      100000

#define GT_SSDRTO_B   GT_RETKEY_CF+1
#define GT_FIN        GT_RETKEY_CF+2


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
CS_BIT          SSDRTO_B;
} T_GTrR;


/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE  	           *Kp_OutputFil, /*pointeur sur le fichier de sortie: GTArR*/
  	           *Kp_GTAno;     /*pointeur sur le fichier de sortie en cas
                                    d'anomalie : GTAno*/
T_RUPTURE_VAR      bd_RuptGTAr;   /*variable de gestion de la rupture sur
                                    le fichier GTArR*/
T_RUPTURE_SYNC_VAR bd_RuptGTrR;   /*variable de gestion de la synchro
                                    entre le fic GTAr et le fic GTrR*/

T_GTAr             ptb_GTAr[MAXLINGTAr];
T_GTrR             ptb_GTrR[MAXLINGTrR];


double             d_MrGTAr,
                   d_MrGTrR;

double             Kd_Seuil;

int                n_i,
                   n_j,
                   n_LgGTAr,
                   n_LgGTrR;

char               MsgAno[200];

int n_InitGTrR(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_IsR1GTAr(char **ptb_InRec,char **ptb_InRec_Cur);
int n_ActionFirstRuptGTAr(char **ptb_InRec_Cur);
int n_ActionLigneGTrR(char **ptb_InRecOwner,char **pbd_InRecChild);
int n_ActionLastRuptGTAr(char **ptb_InRec_Cur);
int n_ConditionSyncGTrR(char **ptb_InRecOwner,char **pbd_InRecChild);

int n_ActionPereSansFilsGTrR(char **ptb_InRec);
int n_ActionFilsSansPereGTrR(char **ptb_InRec);

int n_InitGTAr(T_RUPTURE_VAR  *pbd_Rupt);
int n_ActionLigneGTAr(char **pbd_InRec_Cur);

int n_ProcessingRuptureSyncVar (
  T_RUPTURE_SYNC_VAR  *pbd_Rupt,
  char  	      **ptb_InRecOwner);

int n_ProcessingRuptureVar(
  T_RUPTURE_VAR       *pbd_Rupt);

void o_ConstConvGTAr(char **ptb_L);
void o_ConstConvGTrR(char **ptb_L);
int  n_EcritLigGTArR(
  T_GTAr        *pdb_1,
  T_GTrR        *pdb_2,
  unsigned char c_TypEc,
  double        d_MtAcc,
  double        d_MtRetro);
/*=============================================================================
objet :
        cette fct alimente la n_ieme ligne du tableau GTAr avec chacun
        des champs de la ligne en cours de synchro du GTAr (ces champs
        sont convertis dans leur type d'origine)

==============================================================================*/
void o_ConstConvGTAr(
  char **ptb_L)     /* i- pointeur sur ligne GTAr en cours de traitement */

{
  ptb_GTAr[n_i].SSD_CF        = (unsigned char)
                                atoi(ptb_L[GT_SSD_CF]);
  ptb_GTAr[n_i].ESB_CF        = (unsigned char)
                                atoi(ptb_L[GT_ESB_CF]);
  ptb_GTAr[n_i].BALSHEY_NF    = (short)
                                atoi(ptb_L[GT_BALSHEY_NF]);
  ptb_GTAr[n_i].BALSHRMTH_NF  = (unsigned char)
                                atoi(ptb_L[GT_BALSHRMTH_NF]);
  ptb_GTAr[n_i].BALSHRDAY_NF  = (unsigned char)
                                atoi(ptb_L[GT_BALSHRDAY_NF]);

  strcpy(ptb_GTAr[n_i].TRNCOD_CF,ptb_L[GT_TRNCOD_CF]);
  strcpy(ptb_GTAr[n_i].DBLTRNCOD_CF,ptb_L[GT_DBLTRNCOD_CF]);
  strcpy(ptb_GTAr[n_i].CTR_NF,ptb_L[GT_CTR_NF]);
  strcpy(ptb_GTAr[n_i].KEY_NF,ptb_L[GT_KEY_NF]);

  ptb_GTAr[n_i].END_NT        = (unsigned char)
                                atoi(ptb_L[GT_END_NT]);
  ptb_GTAr[n_i].SEC_NF        = (unsigned char)
                                atoi(ptb_L[GT_SEC_NF]);
  ptb_GTAr[n_i].UWY_NF        = (short)
                                atoi(ptb_L[GT_UWY_NF]);
  ptb_GTAr[n_i].UW_NT         = (unsigned char)
                                atoi(ptb_L[GT_UW_NT]);
  ptb_GTAr[n_i].OCCYEA_NF     = (short)
                                atoi(ptb_L[GT_OCCYEA_NF]);
  ptb_GTAr[n_i].ACY_NF        = (short)
                                atoi(ptb_L[GT_ACY_NF]);
  ptb_GTAr[n_i].SCOSTRMTH_NF  = (unsigned char)
                                atoi(ptb_L[GT_SCOSTRMTH_NF]);
  ptb_GTAr[n_i].SCOENDMTH_NF  = (unsigned char)
                                atoi(ptb_L[GT_SCOENDMTH_NF]);
  ptb_GTAr[n_i].CLM_NF        = atoi(ptb_L[GT_CLM_NF]);

  strcpy(ptb_GTAr[n_i].CUR_CF,ptb_L[GT_CUR_CF]);

  ptb_GTAr[n_i].AMT_M         = (double)
                                atof(ptb_L[GT_AMT_M]);
  ptb_GTAr[n_i].CED_NF        = atoi(ptb_L[GT_CED_NF]);
  ptb_GTAr[n_i].BRK_NF        = atoi(ptb_L[GT_BRK_NF]);
  ptb_GTAr[n_i].PAY_NF        = atoi(ptb_L[GT_PAY_NF]);

  ptb_GTAr[n_i].RETAMT_M      = (double)
                                atof(ptb_L[GT_RETAMT_M]);
}


/*=============================================================================
objet :
        cette fct alimente la n_jeme ligne du tableau GTrR avec chacun
        des champs de la ligne en cours de synchro du GTrR (ces champs
        sont convertis dans leur type d'origine)

==============================================================================*/
void o_ConstConvGTrR(
  char **ptb_L)     /* i- pointeur sur ligne GTrR en cours de traitement */
{
  strcpy(ptb_GTrR[n_j].TRNCOD_CF,ptb_L[GT_TRNCOD_CF]);
  strcpy(ptb_GTrR[n_j].RETCTR_NF,ptb_L[GT_RETCTR_NF]);

  ptb_GTrR[n_j].RETEND_NT     = (unsigned char)
                                atoi(ptb_L[GT_RETEND_NT]);
  ptb_GTrR[n_j].RETSEC_NF     = (unsigned char)
                                atoi(ptb_L[GT_RETSEC_NF]);
  ptb_GTrR[n_j].RTY_NF        = (short)
                                atoi(ptb_L[GT_RTY_NF]);
  ptb_GTrR[n_j].RETUW_NT      = (unsigned char)
                                atoi(ptb_L[GT_RETUW_NT]);
  ptb_GTrR[n_j].RETOCCYEA_NF  = (short)
                                atoi(ptb_L[GT_RETOCCYEA_NF]);
  ptb_GTrR[n_j].RETACY_NF     = (short)
                                atoi(ptb_L[GT_RETACY_NF]);
  ptb_GTrR[n_j].RETSCOSTRMTH_NF  = (unsigned char)
                                atoi(ptb_L[GT_RETSCOSTRMTH_NF]);
  ptb_GTrR[n_j].RETSCOENDMTH_NF  = (unsigned char)
                                atoi(ptb_L[GT_RETSCOENDMTH_NF]);
  ptb_GTrR[n_j].RCL_NF        = atoi(ptb_L[GT_RCL_NF]);

  strcpy(ptb_GTrR[n_j].RETCUR_CF,ptb_L[GT_RETCUR_CF]);

  ptb_GTrR[n_j].RETAMT_M      = (double)
                                atof(ptb_L[GT_RETAMT_M]);
  ptb_GTrR[n_j].PLC_NT        = atoi(ptb_L[GT_PLC_NT]);
  ptb_GTrR[n_j].RTO_NF        = atoi(ptb_L[GT_RTO_NF]);
  ptb_GTrR[n_j].INT_NF        = atoi(ptb_L[GT_INT_NF]);
  ptb_GTrR[n_j].RETPAY_NF     = atoi(ptb_L[GT_RETPAY_NF]);
  ptb_GTrR[n_j].RETKEY_CF     = *(ptb_L[GT_RETKEY_CF]);
  ptb_GTrR[n_j].SSDRTO_B      = (unsigned char)
                                atoi(ptb_L[GT_SSDRTO_B]);
}

/*============================================================================
objet :
        dans cette fct on ecrit 1 ligne format GT dans le fic de sortie
        Suivant les valeurs de c_TypEc, la ligne a ecrire est differente
        (elle est composee de champs provenant du GTAr et du GTrR, les montants
        y figurant sont passes en parametres)

ctee fct renvoie   OK ---> pas de probleme
                   ERR --> probleme pour ecrire
=============================================================================*/
int n_EcritLigGTArR(
  T_GTAr        *pdb_1,   /* i - pointeur sur 1 ligne GTAr */
  T_GTrR        *pdb_2,   /* i - pointeur sur 1 ligne GTrR */
  unsigned char c_TypEc,  /* i - Type d'ecriture a effectuer */
  double        d_MtAcc,  /* i - Montant Acceptation */
  double        d_MtRetro)/* i - Montant Retrocession */

{
  switch (c_TypEc)
    {
      case 0 :
        if (fprintf(Kp_GTAno,
            "~~~~~%s~~~~~~~~~~~~~~~~~~",
            pdb_2->TRNCOD_CF) < 0) return ERR;

        if (fprintf(Kp_GTAno,
            "%s~%d~%d~%d~%d~~~~~~%s~%.3f~~~~~\n",
            pdb_2->RETCTR_NF,
            (int) pdb_2->RETEND_NT,
            (int) pdb_2->RETSEC_NF,
            (int) pdb_2->RTY_NF,
            (int) pdb_2->RETUW_NT,
            pdb_2->RETCUR_CF,
            d_MtRetro - d_MtAcc) < 0) return ERR;
        break;

       case 1 :
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
              pdb_1->KEY_NF) < 0) return ERR;

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
             "%d~%d~%d~%d~%c~%d\n",
             (int) pdb_2->PLC_NT,
             (int) pdb_2->RTO_NF,
             (int) pdb_2->INT_NF,
             (int) pdb_2->RETPAY_NF,
             pdb_2->RETKEY_CF,
             (int) pdb_2->SSDRTO_B) < 0) return ERR;
         break;

     case 2 :
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
             pdb_1->KEY_NF) < 0) return ERR;

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
             "~~~~~%d\n",
             (int) pdb_2->SSDRTO_B) < 0) return ERR;


         break;
      }
  return OK;
}

/*==============================================================================
objet :

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
  if (n_OpenFileAppl ("ESTC8932_O1","wt",&Kp_OutputFil) == ERR)
    ExitPgm(ERR_XX ,"");


				/* Ouverture du fichier de sortie anomalie:
                                   GTAno */
  if (n_OpenFileAppl ("ESTC8932_O2","wt",&Kp_GTAno) == ERR)
    ExitPgm(ERR_XX ,"");

				/* Initialisation var bd_RuptPlc */
  if (n_InitGTAr(&bd_RuptGTAr) == ERR)
    ExitPgm(ERR_XX ,"");

				/* Initialisation var bd_RuptGTrR */
  if (n_InitGTrR(&bd_RuptGTrR) == ERR)
    ExitPgm(ERR_XX ,"");


				/* Lancement traitement fic des GTAr */
  if (n_ProcessingRuptureVar(&bd_RuptGTAr) == ERR)
    ExitPgm(ERR_XX,"Too much lines in array\n");

				/* Fermeture des fichiers */
  if (n_CloseFileAppl("ESTC8932_I1",&(bd_RuptGTAr.pf_InputFil)) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_CloseFileAppl("ESTC8932_I2",&(bd_RuptGTrR.pf_InputFil)) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_CloseFileAppl("ESTC8932_O1",&Kp_OutputFil) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_CloseFileAppl("ESTC8932_O2",&Kp_GTAno) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_EndPgm() == ERR)
    ExitPgm ( ERR_XX , "" );

  exit(OK);
}


/*==============================================================================
objet :
	fonction d'initialisation de la variable de gestion de rupture
        du fichier GTAr.

retour :
	0K
==============================================================================*/
int n_InitGTAr(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

					/* Ouverture du fic GTAr */
  if (n_OpenFileAppl("ESTC8932_I1","rt",&(pbd_Rupt->pf_InputFil)) == ERR)
    return ERR;

  pbd_Rupt->n_NbRupture = 1;

  pbd_Rupt->n_ConditionRupture[0] = n_IsR1GTAr;
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
int n_IsR1GTAr(char **ptb_InRec,char **ptb_InRec_Cur)
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
                                                /* Annee de survenance */
  ret = strcmp(ptb_InRec[GT_RETOCCYEA_NF],ptb_InRec_Cur[GT_RETOCCYEA_NF]);
  if (ret != 0)
     return ret;

                                                /* Annee de compte */
  ret = strcmp(ptb_InRec[GT_RETACY_NF],ptb_InRec_Cur[GT_RETACY_NF]);
  if (ret != 0)
     return ret;

                                                /* Debut de periode de compte*/
  ret = strcmp(ptb_InRec[GT_RETSCOSTRMTH_NF],ptb_InRec_Cur[GT_RETSCOSTRMTH_NF]);
  if (ret != 0)
     return ret;

                                                /* Fin de periode de compte*/
  ret = strcmp(ptb_InRec[GT_RETSCOENDMTH_NF],ptb_InRec_Cur[GT_RETSCOENDMTH_NF]);
  if (ret != 0)
     return ret;

                                                /* Num de sinistre*/
  ret = strcmp(ptb_InRec[GT_RCL_NF],ptb_InRec_Cur[GT_RCL_NF]);
  if (ret != 0)
     return ret;

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
  d_MrGTAr = 0;
  d_MrGTrR = 0;

				/* Initialisation des indices de
                                   parcours des 2 tableaux a construire*/
  n_i = 0;
  n_j = 0;

                                /* Synchronisation avec le GTrR */
  if (n_ProcessingRuptureSyncVar(&bd_RuptGTrR,ptb_InRec_Cur) == ERR)
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
					/* Construction du tab ptb_GTAr
                                           Conversion des donnees exprimees
                                           sous forme de chaines de caracteres
                                           en donnees numeriques*/
  o_ConstConvGTAr(ptb_InRec_Cur);

					/* Cumul des montants retrocession
                                           de GTAr*/
  d_MrGTAr = d_MrGTAr + ptb_GTAr[n_i].RETAMT_M;

  n_i ++;                               /* Incrementation ind tab GTAr */

  if (n_i >= MAXLINGTAr) return ERR;    /* Depassement de capacite tab GTAr */
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
  static T_GTAr    *pdb_1;
  static T_GTrR    *pdb_2,*pdb_3;
  static char      c_AuMoins1Nul;

  static double    d_CumA,
                   d_CumR,
                   d_Acc,
                   d_Retro,
                   d_Taux;

                                       /* Lg des 2 tab GTAr et GTrR */
  n_LgGTAr = n_i;
  n_LgGTrR = n_j;

  if (n_LgGTrR == 0) return OK;        /* Fils sans pere
                                           -> pas de traitement */

  if (fabs(d_MrGTAr - d_MrGTrR) > Kd_Seuil)
                                       /* Les 2 cumuls ne coincident pas ?*/
    {                                  /* Generation d'erreur dans GTAno
                                              1 ligne format GT             */
      n_EcritLigGTArR(NULL,ptb_GTrR,0,d_MrGTAr,d_MrGTrR);

      return OK;                       /* Fin de traitement */
    }
				       /* Les 2 mts sont egaux a Kd_Seuil pres */
				       /* Pour chacun des ele du tab GTAr */
    for (n_i = 0 ; n_i < n_LgGTAr ; n_i++)
      {
        pdb_1 = ptb_GTAr + n_i;
                                       /* Initialisation des cumuls
                                          acceptation et retro de GTAr*/
        d_CumA = 0;
        d_CumR = 0;

        c_AuMoins1Nul = 0;             /* Pas de retrocessionnaire interne */

				       /* Pour chacun des ele du tab GTrR */
        for (n_j = 0 ; n_j < n_LgGTrR ; n_j++)
        {
          pdb_2 = ptb_GTrR + n_j;
                                       /* Calcul Taux */
          if ( fabs(d_MrGTrR) > Kd_Seuil )
            d_Taux = (pdb_2->RETAMT_M) / d_MrGTrR;
          else
            {
              d_Taux = (pdb_2->RETAMT_M) / n_LgGTrR;

              sprintf(MsgAno,"The retroceded accumulated amount is nul");
              n_WriteAno(MsgAno);
            }
                                       /* Reajustement des montants */
          d_Acc   = pdb_1->AMT_M * d_Taux;
          d_Retro = pdb_1->RETAMT_M * d_Taux;

          if (pdb_2->SSDRTO_B != 0)    /* Retrocessionnaire interne vrai ?*/
                                       /* Ecriture dans fic sortie */
            n_EcritLigGTArR(pdb_1,
                            pdb_2,
                            1,
                            d_Acc,
                            d_Retro);

          else                         /* Retrocessionnaire interne faux*/
            {
              if (c_AuMoins1Nul != 1)      /* Pas deja au moins un retro non
                                              interne ?*/
                {
                  c_AuMoins1Nul = 1;       /* Au moins 1 non interne */
                  pdb_3 = pdb_2;           /* Sauvegarde des lignes a afficher*/
                }
				       /* Cumul Mt accep et retro du GTArR */
              d_CumA = d_CumA + d_Acc;
              d_CumR = d_CumR + d_Retro;
            }

        }  /*fin boucle n_j*/

          if (c_AuMoins1Nul == 1)      /* Au moins 1 retrocessionnaire non
                                          interne ?*/
                                       /*   --->  1 ligne dans GTArR  */
              n_EcritLigGTArR(pdb_1,
                              pdb_3,
                              2,
                              d_CumA,
                              d_CumR);

      }  /*fin boucle n_i*/
  return OK;
}

int n_ActionPereSansFilsGTrR(
  char **ptb_InRecOwner)
{
  sprintf(MsgAno,"There is no row in GTrR corresponding to\
          %s %s %s %s %s %s %s from GTAr\n",
          ptb_InRecOwner[GT_RETCTR_NF],
          ptb_InRecOwner[GT_RETEND_NT],
          ptb_InRecOwner[GT_RETSEC_NF],
          ptb_InRecOwner[GT_RTY_NF],
          ptb_InRecOwner[GT_RETUW_NT],
          ptb_InRecOwner[GT_RETCUR_CF],
          ptb_InRecOwner[GT_TRNCOD_CF]);
  n_WriteAno(MsgAno);

return OK;
}

int n_ActionFilsSansPereGTrR(
  char **ptb_InRecOwner)
{
  sprintf(MsgAno,"There is no row in GTAr corresponding to\
          %s %s %s %s %s %s %s from GTrR\n",
          ptb_InRecOwner[GT_RETCTR_NF],
          ptb_InRecOwner[GT_RETEND_NT],
          ptb_InRecOwner[GT_RETSEC_NF],
          ptb_InRecOwner[GT_RTY_NF],
          ptb_InRecOwner[GT_RETUW_NT],
          ptb_InRecOwner[GT_RETCUR_CF],
          ptb_InRecOwner[GT_TRNCOD_CF]);
  n_WriteAno(MsgAno);

return OK;

}

/*==============================================================================
objet :
     Initialisation de la synchronisation du fic maitre (fic GTAr)
     avec l'esclave (fic GTRr)

retour :
	OK
==============================================================================*/
int n_InitGTrR(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR)) ;

				/* Ouverture du fichier esclave (GTRr) */
  if (n_OpenFileAppl ("ESTC8932_I2","rt",&(pbd_Rupt->pf_InputFil)) == ERR)
    ExitPgm(ERR_XX,"");

				/* Fonction de test de la ligne du maitre
 			       	   GTAr avec l'esclave GTRr */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncGTrR;

				/* Fonction d'action sur la ligne courante
                                   du fichier esclave GTRr */
  pbd_Rupt->n_ActionLigne = n_ActionLigneGTrR;

  pbd_Rupt->n_PereSansFils = n_ActionPereSansFilsGTrR;
  pbd_Rupt->n_FilsSansPere = n_ActionFilsSansPereGTrR;

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
int n_ConditionSyncGTrR(
  char **pbd_InRecOwner, /* adresse de la ligne du maitre fic GTAr */
  char **pbd_InRecChild) /* adresse de la ligne de l'esclave GTRr*/
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

                                                /* Annee de survenance */
  ret = strcmp(pbd_InRecOwner[GT_RETOCCYEA_NF],pbd_InRecChild[GT_RETOCCYEA_NF]);
  if (ret != 0)
     return ret;

                                                /* Annee de compte */
  ret = strcmp(pbd_InRecOwner[GT_RETACY_NF],pbd_InRecChild[GT_RETACY_NF]);
  if (ret != 0)
     return ret;

                                                /* Debut de periode de compte*/
  ret = strcmp(pbd_InRecOwner[GT_RETSCOSTRMTH_NF],
               pbd_InRecChild[GT_RETSCOSTRMTH_NF]);
  if (ret != 0)
     return ret;

                                                /* Fin de periode de compte*/
  ret = strcmp(pbd_InRecOwner[GT_RETSCOENDMTH_NF],
               pbd_InRecChild[GT_RETSCOENDMTH_NF]);
  if (ret != 0)
     return ret;

                                                /* Num de sinistre*/
  ret = strcmp(pbd_InRecOwner[GT_RCL_NF],pbd_InRecChild[GT_RCL_NF]);
  if (ret != 0)
     return ret;

  return 0;
}

/*============================================================================
objet :
	fonction lancee pour chaque ligne

retour :OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionLigneGTrR(
  char **ptb_InRecOwner, /* adresse de la ligne du maitre fic GTAr */
  char **ptb_InRecChild) /* adresse de la ligne de l'esclave GTRr */

{
					/* Construction du tab ptb_GTrR */
  o_ConstConvGTrR(ptb_InRecChild);
					/* Cumul des montants retrocession
                                           de GTrR*/
  d_MrGTrR = d_MrGTrR + ptb_GTrR[n_j].RETAMT_M;

  n_j ++;                               /* Incrementation ind tab GTrR */
  if (n_j >= MAXLINGTrR) return ERR;    /* Depassement de capacite tab GTrR */
  return OK;
}
