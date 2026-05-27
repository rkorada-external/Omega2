/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Introduction des postes cumuls et conversion
                                en devise principale
nom du source                 : ESTM7621.c
revision                      : $Revision:   1.1  $
date de creation              : 08/09/2003
auteur                        : J. Ribot
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description :


------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
[001]    26/01/2015     S.Behague  EST48 - spot 28122
[002]    10/03/2015     P.Menant   :spot:28122 EST48, correction de la date dans n_ActionFilsSansPereGT()
[003]    04/01/2016     M.MECHRI   :spot:29695 AE(IFRS & Social)et multi-gaap dans SRV
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include "estserv.h"

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

#define Kn_MaxPostes 20000        /* Le nombre max de postes est fixe a 2000 (modif O.Arik:28/05/2001 1000->2000 suite au dep. de mem.) */

char Ksz_vide[1];               /* Chaine vide pour initialisation */

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/
int Kn_BALSHTYEA_NF;
char Ksz_BALSHTYEA_NF_1[10];
short Ks_acmtrs_nt;
T_TRSLNK Kbd_TRSLNK[Kn_MaxPostes];
int Kn_NbLigTrslnk;

FILE    *Kp_OutputFil,  /* pointeur sur le fichier de sortie */
        *Kp_CoursFil,   /* fichier des cours devise */
        *Kp_TrslnkFil,  /* fichier des postes */
        *Kp_OutGTB1;       /* fichier Bilan -1 en sortie */

T_RUPTURE_VAR bd_RuptPerim; /* gestion rupture sur perimetre */
T_RUPTURE_SYNC_VAR bd_RuptGT; /* gestion synchro GT-perimetre */
T_RUPTURE_SYNC_VAR bd_RuptTrslnk; /* gestion synchro trslnk-perimetre */

int n_InitGT (T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_ActionLigneGT(char **ptb_InRecOwner,char **pbd_InRecChild) ;
int n_ConditionSyncGT(char **ptb_InRecOwner,char **pbd_InRecChild);

int n_InitPerim(T_RUPTURE_VAR *pbd_Rupt) ;
int n_ActionLignePerim(char **pbd_InRec_Cur);
/*int n_ActionPereSansFilsGT(char **ptb_InRecOwner );     jr 11 09 2003 */
int n_ActionFilsSansPereGT(char **ptb_InRecOwner );     /*jr 11 09 2003 */
int n_ChargerTRSLNK ();

// Ajout de repture de fichier pericase
int n_IsR1Perim(char **ptb_InRec,char **ptb_InRec_Cur);
int n_ActionLastRuptPerim(char **ptb_InRec_Cur);
/* variabmle globales de pericase*/
char sz_PCPCUR_CF[4];
char sz_LOB_CF [3];
char sz_ESTCRB_CT[2];
char sz_LIFTRTTYP_CF[4];
char sz_ACCADMTYP_CT [2];
char sz_SECSTS_CT[3];
char sz_PRD_NF[4];
char sz_SEG_NF[4];
char sz_SCOEGP_M[30];
char sz_NAT_CF[4];
char sz_ESTCTR_NF[10];
char sz_ESTSEC_NF[3];
char sz_SECACCSTS_CT[2];
char sz_ACCFRQ_CT[3];
char sz_UWGRP_CF[5];

char sz_CLODAT[9];

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
        InitSig () ;

        if ( n_BeginPgm (argc  ,argv) == ERR )
                ExitPgm ( ERR_XX , "" );

        strcpy(sz_CLODAT, psz_GetCharArgv(1));
        Kn_BALSHTYEA_NF = n_GetIntArgv(2);
        sprintf(Ksz_BALSHTYEA_NF_1, "%d", Kn_BALSHTYEA_NF - 1);

        /* ouverture des fichiers */

        if ( n_OpenFileAppl ("ESTM7621_O1","wt",&Kp_OutputFil) == ERR )
                  ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTM7621_O2","wt",&Kp_OutGTB1) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTM7621_I4","rb",&Kp_CoursFil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTM7621_I3","rb",&Kp_TrslnkFil) == ERR )
                ExitPgm ( ERR_XX , "" );


        /* Initialisation de la varible bd_RuptPerim */
        if ( n_InitPerim(&bd_RuptPerim) )
                ExitPgm ( ERR_XX , "" );

        /* Initialisation de la varible bd_RuptGT */
        if ( n_InitGT(&bd_RuptGT) )
                ExitPgm ( ERR_XX , "" );

        /* Chargement des postes en memoire (PRS_CF ==500 )*/
        /* modif O.Arik:29/05/2001 on sort en cas de dep. de memoire*/
        if(n_ChargerTRSLNK () == ERR )
                        ExitPgm( ERR_XX , "" ) ;


        /* lancement du traitement du fichier */
        if ( n_ProcessingRuptureVar (&bd_RuptPerim) == ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTM7621_O1",&Kp_OutputFil)== ERR)
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTM7621_O2",&Kp_OutGTB1)== ERR)
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl("ESTM7621_I1",&(bd_RuptPerim.pf_InputFil))== ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTM7621_I2",&(bd_RuptGT.pf_InputFil))== ERR)
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTM7621_I3",&Kp_TrslnkFil)== ERR)
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTM7621_I4",&Kp_CoursFil)== ERR)
                ExitPgm ( ERR_XX , "" );

        if ( n_EndPgm () == ERR )
                ExitPgm ( ERR_XX , "" );

        exit(OK) ;

}



/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du
        fichier maitre.

retour :
        OK
==============================================================================*/
int n_InitPerim(T_RUPTURE_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitPerim");

        memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

        if ( n_OpenFileAppl ("ESTM7621_I1","rt",&(pbd_Rupt->pf_InputFil)))
                ExitPgm ( ERR_XX , "" );

        pbd_Rupt->n_NbRupture = 1  ;
        pbd_Rupt->n_ConditionRupture[0] = n_IsR1Perim;                   // Rupture sur CTR_NF/SEC_NF/UWY_NF
        
        pbd_Rupt->n_ActionLast[0]       = n_ActionLastRuptPerim;
        
        pbd_Rupt->n_ActionLigne = n_ActionLignePerim ;

        pbd_Rupt->c_Separ = SEPARATEUR ;

        RETURN_VAL(OK);
}

/*==============================================================================
objet : fonction de test de rupture du niveau 1
retour :    0   ---> Pas de rupture
            1   ---> rupture
==============================================================================*/
int n_IsR1Perim(char **ptb_InRec,char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_IsR1Perim");

    if (strcmp(ptb_InRec[PER_CTR_NF],ptb_InRec_Cur[PER_CTR_NF])!=0)
        RETURN_VAL(1);
    if (strcmp(ptb_InRec[PER_SEC_NF],ptb_InRec_Cur[PER_SEC_NF])!=0)
        RETURN_VAL(1);
    if (strcmp(ptb_InRec[PER_UWY_NF],ptb_InRec_Cur[PER_UWY_NF])!=0)
        RETURN_VAL(1);
    RETURN_VAL (0);
}

/*==============================================================================
objet : fonction lancee pour chaque ligne du maitre
retour :    0 ----> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptPerim(char **ptb_InRec_Cur)
{
   double  d_aliment,d_taux;
   char  sz_aliment[30];
    DEBUT_FCT("n_ActionLastRuptPerim");
     /* Calcul du taux de conversion (cours: 31/12/exercice precedent) */
        d_taux=d_GetTaux(Kp_CoursFil,
                        (char)atoi(ptb_InRec_Cur[PER_SSD_CF]),
                        (short)atoi(ptb_InRec_Cur[PER_UWY_NF])-1,
                        ptb_InRec_Cur[PER_EGPCUR_CF],
                        ptb_InRec_Cur[PER_PCPCUR_CF]);

        if (d_taux>0)
        {
          /* Conversion de l'aliment brut SCOR */
          d_aliment=atof(ptb_InRec_Cur[PER_SCOEGP_M]);
          /* Conversion */
          d_aliment *= d_taux;
        }
        else d_aliment=-1;
        memset(sz_aliment, 0, sizeof(sz_aliment));
        memset(sz_PCPCUR_CF, 0, sizeof(sz_PCPCUR_CF));
        memset(sz_NAT_CF, 0, sizeof(sz_NAT_CF));
        memset(sz_ESTCTR_NF, 0, sizeof(sz_ESTCTR_NF));
        memset(sz_ESTSEC_NF, 0, sizeof(sz_ESTSEC_NF));
        memset(sz_LOB_CF, 0, sizeof(sz_LOB_CF));
        memset(sz_SCOEGP_M, 0, sizeof(sz_SCOEGP_M));
        memset(sz_LIFTRTTYP_CF, 0, sizeof(sz_LIFTRTTYP_CF));
        memset(sz_ACCADMTYP_CT, 0, sizeof(sz_ACCADMTYP_CT));
        memset(sz_SECSTS_CT, 0, sizeof(sz_SECSTS_CT));
        memset(sz_PRD_NF, 0, sizeof(sz_PRD_NF));
        memset(sz_SEG_NF, 0, sizeof(sz_SEG_NF));
        memset(sz_SECACCSTS_CT, 0, sizeof(sz_SECACCSTS_CT));
        memset(sz_ACCFRQ_CT, 0, sizeof(sz_ACCFRQ_CT));
        memset(sz_UWGRP_CF, 0, sizeof(sz_UWGRP_CF));
        
        sprintf(sz_aliment,"%.3lf",d_aliment);
        //strcpy(sz_PCPCUR_CF,  ptb_InRec_Cur[PER_PCPCUR_CF]);
        sprintf(sz_PCPCUR_CF,"%s",ptb_InRec_Cur[PER_PCPCUR_CF]);
        strcpy (sz_NAT_CF, ptb_InRec_Cur[PER_NAT_CF]);
        strcpy(sz_ESTCTR_NF, ptb_InRec_Cur[PER_ESTCTR_NF]);
        strcpy(sz_ESTSEC_NF, ptb_InRec_Cur[PER_ESTSEC_NF]);
        strcpy(sz_LOB_CF, ptb_InRec_Cur[PER_LOB_CF]);
        strcpy(sz_SCOEGP_M,sz_aliment);
        strcpy(sz_ESTCRB_CT, ptb_InRec_Cur[PER_ESTCRB_CT]);
        strcpy(sz_LIFTRTTYP_CF,ptb_InRec_Cur[PER_LIFTRTTYP_CF]);
        strcpy(sz_ACCADMTYP_CT,ptb_InRec_Cur[PER_ACCADMTYP_CT]);
        strcpy(sz_SECSTS_CT,ptb_InRec_Cur[PER_SECSTS_CT]);
        strcpy(sz_PRD_NF,ptb_InRec_Cur[PER_PRD_NF]);
        strcpy(sz_SEG_NF,ptb_InRec_Cur[PER_SEG_NF]);
        strcpy(sz_SECACCSTS_CT,ptb_InRec_Cur[PER_SECACCSTS_CT]);
        strcpy(sz_ACCFRQ_CT, ptb_InRec_Cur[PER_ACCFRQ_CT]);
        strcpy(sz_UWGRP_CF,ptb_InRec_Cur[PER_UWGRP_CF]);
    RETURN_VAL (0);
}
/*==============================================================================
objet :
        fonction lancee pour chaque ligne du maitre

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerim( char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_ActionLignePerim");

        /* synchronisation du fichier GT pour chaque ligne */
        n_ProcessingRuptureSyncVar (&bd_RuptGT, ptb_InRec_Cur) ;

        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        Initialisation de la synchronisation du maitre avec l'esclave GT

retour :
        OK
==============================================================================*/
int n_InitGT(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitGT");

        memset( pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

        /* ouverture du fichier esclave */
        n_OpenFileAppl ("ESTM7621_I2","rt",&(pbd_Rupt->pf_InputFil));

        pbd_Rupt->n_NbRupture = 0  ;

        /* fonction du test de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync      = n_ConditionSyncGT ;

        /* fonction d'action sur la ligne courante du fichier esclave */
        pbd_Rupt->n_ActionLigne         = n_ActionLigneGT ;

        /* fonction d'action quand le maitre n'a pas de fils GT */
  /*      pbd_Rupt->n_PereSansFils = n_ActionPereSansFilsGT;  jr 11 09 2003  */

	/* fonction d'action quand le maitre n'a pas de fils GT */
         pbd_Rupt->n_FilsSansPere = n_ActionFilsSansPereGT;


        pbd_Rupt->c_Separ               = SEPARATEUR ;

        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction de test de rupture du niveau 1

retour :
        0       ---> pbd_InRecOwner = pbd_InRecChild
                        ( egalite de rubriques a synchroniser)
        > 0     ---> pbd_InRecOwne> > pbd_InRecChild
        < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncGT(
        char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
        char **pbd_InRecChild  /* adresse de la ligne de l'esclave */
        )
{
        int ret;

        DEBUT_FCT("n_ConditionSyncGT");

        if ( (ret = strcmp(pbd_InRecOwner[PER_CTR_NF],pbd_InRecChild[GT_CTR_NF])) != 0 )
                RETURN_VAL(ret);
        if ( (ret = strcmp(pbd_InRecOwner[PER_SEC_NF],pbd_InRecChild[GT_SEC_NF])) != 0 )
                RETURN_VAL(ret);
        if ( (ret = strcmp(pbd_InRecOwner[PER_UWY_NF],pbd_InRecChild[GT_UWY_NF])) != 0 )
                RETURN_VAL(ret);

        RETURN_VAL(0);
}

/*==============================================================================
objet:
        Lit le fichier binaire des postes et les met en memoire

==============================================================================*/
int n_ChargerTRSLNK ()
{
        int n_EOF = 0;
        T_TRSLNK bd_Lu;
        char MsgAno[300];

        DEBUT_FCT("n_ChargerTRSLNK");

        Kn_NbLigTrslnk=0;

        /* Tant que la fin de fichier n'est pas atteinte,... */
        while (n_EOF == 0)
        {
                if (fread(&bd_Lu,sizeof(T_TRSLNK),1,Kp_TrslnkFil)<=0)
                        n_EOF = 1;
                else {

                        if ( Kn_NbLigTrslnk + 1 >= Kn_MaxPostes ) {
                                /* depassement tableau */
                                sprintf(MsgAno,"The number of link (/PRS %d /ACMTRS %d /DETTRS %s) overflows the program's storage capacity",
                                                bd_Lu.PRS_CF,
                                                bd_Lu.ACMTRS_NT,
                                                bd_Lu.DETTRS_CF);
                                n_WriteAno(MsgAno);
                                RETURN_VAL(ERR);
                        }

                        else if (bd_Lu.PRS_CF == 500)
                                /* Enregistrement ecrit dans le tableau */
                                Kbd_TRSLNK[Kn_NbLigTrslnk++] = bd_Lu;
                }
        }
        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction de recherche du poste
retour :
        0               ---> Pas de rupture
        < 0     ---> On n'est pas arrive au bloc synchrone
        > 0     ---> On a depasse le bloc synchrone
==============================================================================*/
int n_RechPoste(char *sz_poste)
{
        int n_indice, ret;

        DEBUT_FCT("n_RechPoste");

        Ksz_vide[0]=0;
        n_indice=0;
        while (1==1)
        {
                /* Comparaison des codes */
                ret=strcmp(sz_poste,Kbd_TRSLNK[n_indice].DETTRS_CF);

                /* S'ils sont egaux, retourner l'indice */
                if (ret==0) RETURN_VAL(n_indice);

                /* Si la ligne est passee, retourner -1 (echec) */
                if (ret<0) RETURN_VAL(-1);

                /* Ligne suivante */
                n_indice++;

                /* Si on est a la fin du tableau, echec */
                if (n_indice>=Kn_NbLigTrslnk) RETURN_VAL(-1);
        }
}


/*==============================================================================
objet :
        fonction lancee pour chaque ligne du GT synchronisee avec le perimetre

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGT(
        char **ptb_InRecOwner ,/* adresse de la ligne du maitre */
        char **ptb_InRecChild  /* adresse de la ligne de l'esclave */
)
{
    double  d_montant,d_aliment,d_taux;
    char    sz_montant[30],sz_aliment[30];
    char    sz_acmtrs[10]="", sz_trncod[10]="", sz_acmtrs2[10]="" ;
    int i;
	int flag_B1 =0 ;
	char * PostBpc = "0";
	char * RetAutGen = "0";
    char * AccTyp    = "0";
    char * ActivePlan_b = "0";

    DEBUT_FCT("n_ActionLigneGT");

		/* Récupération prévision pour calcul situation bilan - 1 */

/* jr 17/09/2003
    	if ( ptb_InRecChild[GT_TRNCOD_CF][7] == '3' ||  ptb_InRecChild[GT_TRNCOD_CF][7] == '4' )
		    	{
*/
/*			ptb_InRecChild[GT_TRNCOD_CF][7] = '0' ;  */
	   			if ( ptb_InRecChild[GT_TRNCOD_CF][1] == '7' )
				    {
         			flag_B1 =1 ;
              ptb_InRecChild[GT_BALSHEY_NF] = Ksz_BALSHTYEA_NF_1  ;
				      ptb_InRecChild[GT_BALSHRMTH_NF] = "12" ;
		      		ptb_InRecChild[GT_BALSHRDAY_NF] = "31" ;
              d_montant=atof(ptb_InRecChild[GT_AMT_M]);
              d_montant *= -1;
      				sprintf(sz_montant,"%.3lf",d_montant);
              ptb_InRecChild[GT_AMT_M]=sz_montant;
            }

			/*else
				{
				d_montant=atof(ptb_InRecChild[GT_AMT_M]);
                d_montant *= -1;
				sprintf(sz_montant,"%.3lf",d_montant);
                ptb_InRecChild[GT_AMT_M]=sz_montant;
                }*/
/* jr 11 09 2003			}      */
     // récupérer le champ PostBpc

     PostBpc = ptb_InRecChild [GT_PostBpc_B];
     RetAutGen = ptb_InRecChild [GT_RETAUTGEN_B];
     AccTyp    = ptb_InRecChild [GT_ACCTYP_NF];
     ActivePlan_b = ptb_InRecChild [GT_ActivePlan_b];
     
     for(i=GT_ESTCUR_CF;i<GT_NBCOL;i++) ptb_InRecChild[i]="" ;
                ptb_InRecChild[GT_NBCOL] = 0 ;

        /* Synchronisation du fichier trslnk afin de recuperer ACMTRS_NT */

      strcpy( sz_trncod, ptb_InRecChild[GT_TRNCOD_CF]);

      sz_trncod[1] = '1';
      sz_trncod[7] = '0';

/*		  ptb_InRecChild[GT_TRNCOD_CF][1] = '1' ;
		  	ptb_InRecChild[GT_TRNCOD_CF][7] = '0' ;

        i = n_RechPoste(ptb_InRecChild[GT_TRNCOD_CF]);
*/
        i = n_RechPoste(sz_trncod);
        if (i==-1)
        {
          RETURN_VAL(OK);
        }
        else
		    {
            Ks_acmtrs_nt=Kbd_TRSLNK[i].ACMTRS_NT;
        }

        sprintf(sz_acmtrs,"%d",Ks_acmtrs_nt);

 	/* Calcul du taux de conversion */

        /* Pour tous les traites           */
        /* si devise<>devise principale, conversion du montant  */
        ptb_InRecChild[GT_ESTAMT_M]=ptb_InRecChild[GT_AMT_M];
        ptb_InRecChild[GT_ESTCUR_CF]=ptb_InRecChild[GT_CUR_CF];

        if (strcmp(ptb_InRecOwner[PER_PCPCUR_CF],ptb_InRecChild[GT_CUR_CF])!=0)
        {
                d_taux=d_GetTaux(Kp_CoursFil,
                                (char)atoi(ptb_InRecOwner[PER_SSD_CF]),
                                (short)atoi(ptb_InRecChild[GT_BALSHEY_NF]),
                                ptb_InRecChild[GT_CUR_CF],
                                ptb_InRecOwner[PER_PCPCUR_CF]);
                /* Si le taux est trouve, conversion*/
                if (d_taux>0)
                {
                  d_montant=atof(ptb_InRecChild[GT_AMT_M]);
                  d_montant *= d_taux;
                }
                /* Sinon, montant mis a -1 */
                else d_montant = -1;

                /* Remplacement du montant */
                sprintf(sz_montant,"%.3lf",d_montant);
                ptb_InRecChild[GT_ESTAMT_M]=sz_montant;
        }

        /* Calcul du taux de conversion (cours: 31/12/exercice precedent) */

		d_taux=d_GetTaux(Kp_CoursFil,
                        (char)atoi(ptb_InRecOwner[PER_SSD_CF]),
                        (short)atoi(ptb_InRecOwner[PER_UWY_NF])-1,
                        ptb_InRecOwner[PER_EGPCUR_CF],
                        ptb_InRecOwner[PER_PCPCUR_CF]);

        if (d_taux>0)
        {
          /* Conversion de l'aliment brut SCOR */
          d_aliment=atof(ptb_InRecOwner[PER_SCOEGP_M]);
          d_aliment *= d_taux;
        }
        /* Sinon, montant mis a -1 */
		else d_aliment=-1;

		/* Remplacement de l'aliment */
        sprintf(sz_aliment,"%.3lf",d_aliment);

        sprintf (sz_acmtrs2,sz_acmtrs);

//     if (sz_acmtrs[3]=='3')
//             {
//               if (sz_acmtrs[1]=='5')
//                    {
//  /*                    sprintf (sz_acmtrs,sz_acmtrs6);   */
//                      sprintf(sz_acmtrs2,"%c063",sz_acmtrs[0]);
//                    }
//                    else if (sz_acmtrs[1]=='6')
//                    {
//                      sprintf(sz_acmtrs2,"%c083",sz_acmtrs[0]);
//                    }
//              }

        ptb_InRecChild[GT_ESTCUR_CF]=ptb_InRecOwner[PER_PCPCUR_CF];

        ptb_InRecChild[GT_NAT_CF]       = ptb_InRecOwner[PER_NAT_CF];
        ptb_InRecChild[GT_ACMTRS_NT]    = sz_acmtrs2;
        ptb_InRecChild[GT_ESTCTR_NF]    = ptb_InRecOwner[PER_ESTCTR_NF];
        ptb_InRecChild[GT_ESTSEC_NF]    = ptb_InRecOwner[PER_ESTSEC_NF];
        ptb_InRecChild[GT_LOB_CF]       = ptb_InRecOwner[PER_LOB_CF];
        ptb_InRecChild[GT_SCOEGP_M]     = sz_aliment;
        ptb_InRecChild[GT_ESTCRB_CT]    = ptb_InRecOwner[PER_ESTCRB_CT];
        ptb_InRecChild[GT_LIFTRTTYP_CF] = ptb_InRecOwner[PER_LIFTRTTYP_CF];
        ptb_InRecChild[GT_ACCADMTYP_CT] = ptb_InRecOwner[PER_ACCADMTYP_CT];
        ptb_InRecChild[GT_SECSTS_CT]    = ptb_InRecOwner[PER_SECSTS_CT];
        ptb_InRecChild[GT_BRK_NF]       = ptb_InRecOwner[PER_PRD_NF];
	    	ptb_InRecChild[GT_PRD_NF]       = ptb_InRecOwner[PER_PRD_NF];
        ptb_InRecChild[GT_SEG_NF]       = ptb_InRecOwner[PER_SEG_NF];
        ptb_InRecChild[GT_COMACC_B]     = "0";

        ptb_InRecChild[GT_ADJCOD_CT]    = "0";
        //ptb_InRecChild[GT_RETCOD_CT]    = "0";
        ptb_InRecChild[GT_ORICOD_LS]    = "0";
        ptb_InRecChild[GT_DETTRS_CF]    = "0";

        //ptb_InRecChild[GT_ADJSIG_B]     = "0";
        //ptb_InRecChild[GT_ACCRET_B]     = "0";
        if(ptb_InRecChild[GT_TRNCOD_CF][0] == '1' || ptb_InRecChild[GT_TRNCOD_CF][0] == '3')
           ptb_InRecChild[GT_ACCRET_B]     = "A";
        else
           ptb_InRecChild[GT_ACCRET_B]     = "R";
           
        ptb_InRecChild[GT_ESTUWY_NF]    = "";

        ptb_InRecChild[GT_PROPER_N]     = ptb_InRecOwner[PER_ACCFRQ_CT];
        ptb_InRecChild[GT_UWGRP_CF]     = ptb_InRecOwner[PER_UWGRP_CF];
        ptb_InRecChild[GT_RTOCTY_CF]    = "";

	if  ( atoi( ptb_InRecOwner[PER_SECACCSTS_CT] ) == 9 )
	{
		ptb_InRecChild[GT_ADJCOD_CT] = "9" ;
	}

/*   	if ( atoi( ptb_InRecChild[GT_BALSHEY_NF] ) <=  Kn_BALSHTYEA_NF - 1 &&
	     atoi( ptb_InRecChild[GT_ACY_NF] ) <=  Kn_BALSHTYEA_NF -1  )
*/
    /*Ajout de GAAP */
    //[003]
 	     ptb_InRecChild[GT_GAAP_NF]="1";
    if((ptb_InRecChild[GT_TRNCOD_CF][7]== 'A')|| (ptb_InRecChild[GT_TRNCOD_CF][7]== 'B'))
    	   ptb_InRecChild[GT_GAAP_NF]="2";
    if((ptb_InRecChild[GT_TRNCOD_CF][7]== 'C')|| (ptb_InRecChild[GT_TRNCOD_CF][7]== 'D'))
    	   ptb_InRecChild[GT_GAAP_NF]="3";
    if((ptb_InRecChild[GT_TRNCOD_CF][7]== 'E')|| (ptb_InRecChild[GT_TRNCOD_CF][7]== 'F'))
    	   ptb_InRecChild[GT_GAAP_NF]="4";
    if((ptb_InRecChild[GT_TRNCOD_CF][7]== 'G')|| (ptb_InRecChild[GT_TRNCOD_CF][7]== 'H'))
           ptb_InRecChild[GT_GAAP_NF]="5";
    	// EST84 
      ptb_InRecChild [GT_PostBpc_B] = PostBpc;
      ptb_InRecChild [GT_RETAUTGEN_B] = RetAutGen ;
      ptb_InRecChild [GT_ACCTYP_NF] = AccTyp;
      ptb_InRecChild [GT_ActivePlan_b] = ActivePlan_b;
      
     if (flag_B1==1)
		    	{
       			n_WriteCols(Kp_OutGTB1,ptb_InRecChild,SEPARATEUR,0);
	        }
		 else
          {
		       n_WriteCols(Kp_OutputFil,ptb_InRecChild,SEPARATEUR,0);
          }
        RETURN_VAL(OK);
}


/*==============================================================================
objet :
        fonction lancee quand le pere n'a pas de fils GT
retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre

==============================================================================*/
/*   jr 11 09 2003

int n_ActionPereSansFilsGT(
        char **ptb_InRecOwner   adresse de la ligne du maitre */
/*        )
{
      int i;
      double    d_aliment,d_taux;
      char      sz_aliment[22];
      char sz_GT[900];
      char *tb[GT_NBCOL] ;

      DEBUT_FCT("n_ActionPereSansFilsGT");

        for(i=0;i<GT_NBCOL;i++) tb[i]="" ;
              tb[GT_NBCOL] = 0 ;

        Calcul du taux de conversion (cours: 31/12/exercice precedent) */
/*   jr 11 09 2003           d_taux=d_GetTaux(Kp_CoursFil,
                        (char)atoi(ptb_InRecOwner[PER_SSD_CF]),
                        (short)atoi(ptb_InRecOwner[PER_UWY_NF])-1,
                        ptb_InRecOwner[PER_EGPCUR_CF],
                        ptb_InRecOwner[PER_PCPCUR_CF]);

        if (d_taux>0)
        {
          Conversion de l'aliment brut SCOR */
/*   jr 11 09 2003             d_aliment=atof(ptb_InRecOwner[PER_SCOEGP_M]);
          Conversion */
/*   jr 11 09 2003             d_aliment *= d_taux;
        }
        else d_aliment=-1;

        sprintf(sz_aliment,"%.3lf",d_aliment);


        tb[GT_SSD_CF]=                  ptb_InRecOwner[PER_SSD_CF];
        tb[GT_ESB_CF]=                  ptb_InRecOwner[PER_ACCESB_CF];

        tb[GT_CTR_NF]=                  ptb_InRecOwner[PER_CTR_NF];
        tb[GT_END_NT]=                  ptb_InRecOwner[PER_END_NT];
        tb[GT_SEC_NF]=                  ptb_InRecOwner[PER_SEC_NF];
        tb[GT_UWY_NF]=                  ptb_InRecOwner[PER_UWY_NF];
        tb[GT_UW_NT]=                   ptb_InRecOwner[PER_UW_NT];
        tb[GT_ACY_NF]=                  ptb_InRecOwner[PER_UWY_NF];

		Modif ANB du 16/10/98   */
		/* Ajout de la monnaie principale pour la conversion de l'aliment */
		/* lors du traitement de ventilation */

/*   jr 11 09 2003   		tb[GT_CUR_CF]=                  ptb_InRecOwner[PER_PCPCUR_CF];

        tb[GT_CED_NF]=                  ptb_InRecOwner[PER_CED_NF];
        tb[GT_BRK_NF]=                  ptb_InRecOwner[PER_PRD_NF];
        tb[GT_PAY_NF]=                  ptb_InRecOwner[PER_GENPRMPAY_NF];
        tb[GT_KEY_NF]=                  ptb_InRecOwner[PER_GANPAYORD_NT];

        *** GT enrichi */

/*   jr 11 09 2003   		tb[GT_ESTCUR_CF]=               ptb_InRecOwner[PER_PCPCUR_CF];
        tb[GT_NAT_CF]=                  ptb_InRecOwner[PER_NAT_CF];
        tb[GT_ACMTRS_NT]=               "0";
        tb[GT_ESTCTR_NF]=               ptb_InRecOwner[PER_ESTCTR_NF];
        tb[GT_ESTSEC_NF]=               ptb_InRecOwner[PER_ESTSEC_NF];
        tb[GT_LOB_CF]=                  ptb_InRecOwner[PER_LOB_CF];
        tb[GT_SCOEGP_M]=                sz_aliment;
        tb[GT_ESTCRB_CT]=               ptb_InRecOwner[PER_ESTCRB_CT];
        tb[GT_LIFTRTTYP_CF]=            ptb_InRecOwner[PER_LIFTRTTYP_CF];
        tb[GT_ACCADMTYP_CT]=            ptb_InRecOwner[PER_ACCADMTYP_CT];
        tb[GT_SECSTS_CT]=               ptb_InRecOwner[PER_SECSTS_CT];
        tb[GT_PRD_NF]=                  ptb_InRecOwner[PER_PRD_NF];
        tb[GT_SEG_NF]=                  ptb_InRecOwner[PER_SEG_NF];
        tb[GT_COMACC_B]=                "0";

		Modif Anb le 5/11/1999 */
		/* Report modification adjcod_ct si affaire sans mouvement terminée */

/*   jr 11 09 2003   		if  ( atoi( ptb_InRecOwner[PER_SECACCSTS_CT] ) == 9 )
		{
			tb[GT_ADJCOD_CT] = "9" ;
		};
		tb[GT_ADJCOD_CT]                = "0";*/

/*   jr 11 09 2003           tb[GT_RETCOD_CT]                = "0";
        tb[GT_DETTRS_CF]                = "";
        tb[GT_ADJSIG_B]=                "0";
        tb[GT_ESTUWY_NF]=               "";
        tb[GT_PROPER_N]=                ptb_InRecOwner[PER_ACCFRQ_CT];
        tb[GT_UWGRP_CF]=                ptb_InRecOwner[PER_UWGRP_CF];
        tb[GT_RTOCTY_CF]=               "";

        n_WriteCols(Kp_OutGTB1,tb,SEPARATEUR,0);

		n_WriteCols(Kp_OutputFil,tb,SEPARATEUR,0);

        RETURN_VAL(OK);
}*/

/*==============================================================================
objet :
        fonction lancee quand le pere n'a pas de fils GT
retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre

==============================================================================*/

int n_ActionFilsSansPereGT(
        char **ptb_InRecChild   /* adresse de la ligne de l'esclave */
   )
{
      int i;
      char sz_CloDatYear[5], sz_CloDatMonth[3], sz_CloDatDay[3];
      char  sz_acmtrs[10]="", sz_trncod[10]="" ;
      char * PostBpc = "0";
      char * RetAutGen = "0";
      char * AccTyp    = "0";
      char * ActivePlan_b = "0";

      DEBUT_FCT("n_ActionPereSansFilsGT");
      
      // récupérer le champ PostBpc
      
       PostBpc = ptb_InRecChild [GT_PostBpc_B];
       RetAutGen = ptb_InRecChild [GT_RETAUTGEN_B];
       AccTyp    = ptb_InRecChild [GT_ACCTYP_NF];
       ActivePlan_b = ptb_InRecChild [GT_ActivePlan_b];
       for(i=GT_ESTCUR_CF;i<GT_NBCOL;i++) ptb_InRecChild[i]="" ;
       ptb_InRecChild[GT_NBCOL] = 0 ;

       /*** Debut modification [002] ***/
       strncpy(sz_CloDatYear, &(sz_CLODAT[0]), 4);
       sz_CloDatYear[4] = '\0';
       ptb_InRecChild[GT_BALSHEY_NF] = sz_CloDatYear;
       strncpy(sz_CloDatMonth, &(sz_CLODAT[4]), 2);
       sz_CloDatMonth[2] = '\0';
       ptb_InRecChild[GT_BALSHRMTH_NF] = sz_CloDatMonth;
       strncpy(sz_CloDatDay, &(sz_CLODAT[6]), 2);
       sz_CloDatDay[2] = '\0';
       ptb_InRecChild[GT_BALSHRDAY_NF] = sz_CloDatDay;
       /*** Fin modification [002] ***/

       /* Synchronisation du fichier trslnk afin de recuperer ACMTRS_NT */
       ptb_InRecChild [GT_PostBpc_B] = PostBpc;
       ptb_InRecChild [GT_RETAUTGEN_B] = RetAutGen;
       ptb_InRecChild [GT_ACCTYP_NF] = AccTyp;
       ptb_InRecChild [GT_ActivePlan_b] = ActivePlan_b;
       
      strcpy( sz_trncod, ptb_InRecChild[GT_TRNCOD_CF]);

      sz_trncod[1] = '1';
      sz_trncod[7] = '0';

/*		  ptb_InRecChild[GT_TRNCOD_CF][1] = '1' ;
        ptb_InRecChild[GT_TRNCOD_CF][7] = '0' ;

        i = n_RechPoste(ptb_InRecChild[GT_TRNCOD_CF]);
*/
        i = n_RechPoste(sz_trncod);
        if (i==-1)
        {
          RETURN_VAL(OK);
        }
        else
		    {
            Ks_acmtrs_nt=Kbd_TRSLNK[i].ACMTRS_NT;
        }

        sprintf(sz_acmtrs,"%d",Ks_acmtrs_nt);
        ptb_InRecChild[GT_ACMTRS_NT]=               sz_acmtrs;
		/* Modif ANB du 16/10/98   */
		/* Ajout de la monnaie principale pour la conversion de l'aliment */
		/* lors du traitement de ventilation */

        /**** GT enrichi */
        ptb_InRecChild[GT_ESTAMT_M]=ptb_InRecChild[GT_AMT_M];
        ptb_InRecChild[GT_ESTCUR_CF]=sz_PCPCUR_CF; // a verifier
        ptb_InRecChild[GT_NAT_CF]=sz_NAT_CF;
        ptb_InRecChild[GT_ESTCTR_NF]=sz_ESTCTR_NF;
        ptb_InRecChild[GT_ESTSEC_NF]=sz_ESTSEC_NF;
        ptb_InRecChild[GT_LOB_CF]=sz_LOB_CF;
        ptb_InRecChild[GT_SCOEGP_M]= sz_SCOEGP_M;
        ptb_InRecChild[GT_ESTCRB_CT]=sz_ESTCRB_CT;
        ptb_InRecChild[GT_LIFTRTTYP_CF]= sz_LIFTRTTYP_CF;
        ptb_InRecChild[GT_ACCADMTYP_CT]= sz_ACCADMTYP_CT;
        ptb_InRecChild[GT_SECSTS_CT]= sz_SECSTS_CT;
        ptb_InRecChild[GT_PRD_NF]=sz_PRD_NF;
        ptb_InRecChild[GT_SEG_NF]=sz_SEG_NF;
        ptb_InRecChild[GT_COMACC_B]="0";

		/* Modif Anb le 5/11/1999 */
		/* Report modification adjcod_ct si affaire sans mouvement terminée */

	if  ( atoi(sz_SECACCSTS_CT) == 9 )
		{
			ptb_InRecChild[GT_ADJCOD_CT] = "9" ;
		}
		ptb_InRecChild[GT_ADJCOD_CT] = "0";
		
		//tb[GT_RETCOD_CT]                = "0";
		ptb_InRecChild[GT_ORICOD_LS]    = "0";
		ptb_InRecChild[GT_DETTRS_CF]    = "0";
		ptb_InRecChild[GT_ESTUWY_NF]= "";
		ptb_InRecChild[GT_PROPER_N]= sz_ACCFRQ_CT;              
		ptb_InRecChild[GT_UWGRP_CF]= sz_UWGRP_CF;
		ptb_InRecChild[GT_RTOCTY_CF]="";
		
		if(ptb_InRecChild[GT_TRNCOD_CF][0] == '1' || ptb_InRecChild[GT_TRNCOD_CF][0] == '3')
		    ptb_InRecChild[GT_ACCRET_B]     = "A";
		else
        ptb_InRecChild[GT_ACCRET_B]     = "R";
    /*Ajout de GAAP */
    //[003]
 	     ptb_InRecChild[GT_GAAP_NF]="1";
    if((ptb_InRecChild[GT_TRNCOD_CF][7]== 'A')|| (ptb_InRecChild[GT_TRNCOD_CF][7]== 'B'))
    	   ptb_InRecChild[GT_GAAP_NF]="2";
    if((ptb_InRecChild[GT_TRNCOD_CF][7]== 'C')|| (ptb_InRecChild[GT_TRNCOD_CF][7]== 'D'))
    	   ptb_InRecChild[GT_GAAP_NF]="3";
    if((ptb_InRecChild[GT_TRNCOD_CF][7]== 'E')|| (ptb_InRecChild[GT_TRNCOD_CF][7]== 'F'))
    	   ptb_InRecChild[GT_GAAP_NF]="4";
    if((ptb_InRecChild[GT_TRNCOD_CF][7]== 'G')|| (ptb_InRecChild[GT_TRNCOD_CF][7]== 'H'))
    	   ptb_InRecChild[GT_GAAP_NF]="5";	
    	   
    n_WriteCols(Kp_OutGTB1,ptb_InRecChild,SEPARATEUR,0);
    
		n_WriteCols(Kp_OutputFil,ptb_InRecChild,SEPARATEUR,0);

        RETURN_VAL(OK);
}


