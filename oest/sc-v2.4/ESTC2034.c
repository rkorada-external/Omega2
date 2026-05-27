/*==============================================================================
nom de l'application          : Introduction des postes cumuls et conversion
                                en devise principale
nom du source                 : ESTC2034.c
revision                      : $Revision:   1.4  $
date de creation              : 04/06/1997
auteur                        : C. Chavatte
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :


------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
           ...           ...            ...              ...
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

#define Kn_MaxPostes 600        /* Le nombre max de postes est fixe a 600 */

char Ksz_vide[1];               /* Chaine vide pour initialisation */

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

short Ks_acmtrs_nt;
T_TRSLNK Kbd_TRSLNK[Kn_MaxPostes];
int Kn_NbLigTrslnk;

FILE    *Kp_OutputFil,  /* pointeur sur le fichier de sortie */
        *Kp_AnoFil,     /* fichier des anomalies en sortie */
        *Kp_CoursFil,   /* fichier des cours devise */
        *Kp_TrslnkFil;  /* fichier des postes */

T_RUPTURE_VAR bd_RuptPerim; /* gestion rupture sur perimetre */
T_RUPTURE_SYNC_VAR bd_RuptGT; /* gestion synchro GT-perimetre */
T_RUPTURE_SYNC_VAR bd_RuptTrslnk; /* gestion synchro trslnk-perimetre */

int n_InitGT (T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_ActionLigneGT(char **ptb_InRecOwner,char **pbd_InRecChild) ;
int n_ConditionSyncGT(char **ptb_InRecOwner,char **pbd_InRecChild);

int n_InitPerim(T_RUPTURE_VAR *pbd_Rupt) ;
int n_ActionLignePerim(char **pbd_InRec_Cur);
int n_ActionPereSansFilsGT(char **ptb_InRecOwner );

int n_ChargerTRSLNK ();

/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
void main(int argc ,char *argv[])
{

        /* Initialisation des signaux */
        InitSig () ;

        if ( n_BeginPgm (argc  ,argv) == ERR )
                ExitPgm ( ERR_XX , "" );

        /* ouverture des fichiers */

        if ( n_OpenFileAppl ("ESTC2034_O1","wt",&Kp_OutputFil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2034_O2","at",&Kp_AnoFil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2034_I4","rb",&Kp_CoursFil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2034_I3","rb",&Kp_TrslnkFil) == ERR )
                ExitPgm ( ERR_XX , "" );


        /* Initialisation de la varible bd_RuptPerim */
        if ( n_InitPerim(&bd_RuptPerim) )
                ExitPgm ( ERR_XX , "" );

        /* Initialisation de la varible bd_RuptGT */
        if ( n_InitGT(&bd_RuptGT) )
                ExitPgm ( ERR_XX , "" );

        /* Chargement des postes en memoire */
        n_ChargerTRSLNK ();

        /* lancement du traitement du fichier */
        if ( n_ProcessingRuptureVar (&bd_RuptPerim) == ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2034_O1",&Kp_OutputFil)== ERR)
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2034_O2",&Kp_AnoFil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl("ESTC2034_I1",&(bd_RuptPerim.pf_InputFil))== ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2034_I2",&(bd_RuptGT.pf_InputFil))== ERR)
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2034_I3",&Kp_TrslnkFil)== ERR)
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2034_I4",&Kp_CoursFil)== ERR)
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

        if ( n_OpenFileAppl ("ESTC2034_I1","rt",&(pbd_Rupt->pf_InputFil)))
                ExitPgm ( ERR_XX , "" );

        pbd_Rupt->n_NbRupture = 0  ;

        pbd_Rupt->n_ActionLigne = n_ActionLignePerim ;

        pbd_Rupt->c_Separ = SEPARATEUR ;

        RETURN_VAL(OK);
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
        n_OpenFileAppl ("ESTC2034_I2","rt",&(pbd_Rupt->pf_InputFil));

        pbd_Rupt->n_NbRupture = 0  ;

        /* fonction du test de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync      = n_ConditionSyncGT ;

        /* fonction d'action sur la ligne courante du fichier esclave */
        pbd_Rupt->n_ActionLigne         = n_ActionLigneGT ;

        /* fonction d'action quand le maitre n'a pas de fils GT */
        pbd_Rupt->n_PereSansFils = n_ActionPereSansFilsGT;

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

        RETURN_VAL(ret);
}

/*==============================================================================
objet:
        Lit le fichier binaire des postes et les met en memoire

==============================================================================*/
int n_ChargerTRSLNK ()
{
        int n_EOF = 0;
        T_TRSLNK bd_Lu;

        DEBUT_FCT("n_ChargerTRSLNK");

/*        Kn_NbLigTrslnk=fread(Kbd_TRSLNK,sizeof(T_TRSLNK),Kn_MaxPostes,Kp_TrslnkFil); */

        Kn_NbLigTrslnk=0;
        
        /* Tant que la fin de fichier n'est pas atteinte,... */
        while (n_EOF == 0)
        {
                if (fread(&bd_Lu,sizeof(T_TRSLNK),1,Kp_TrslnkFil)<=0)
                        n_EOF = 1;
                else {
                   
                    if ( (Kn_NbLigTrslnk < Kn_MaxPostes) && (bd_Lu.PRS_CF == 500) )
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
        char    sz_devise[4],sz_GT[500], sz_acmtrs[10]="";
        int i;

        DEBUT_FCT("n_ActionLigneGT");

    for(i=GT_ESTCUR_CF;i<GT_NBCOL;i++) ptb_InRecChild[i]="" ;
                ptb_InRecChild[GT_NBCOL] = 0 ;

        /* Synchronisation du fichier trslnk afin de recuperer ACMTRS_NT */
        i = n_RechPoste(ptb_InRecChild[GT_TRNCOD_CF]);
        if (i==-1)
        {
/* MODIF LOUVEAU 21/10 : si pas de poste, pas d'ecriture du mouvement */
          RETURN_VAL(OK);
                    
          /* Mise a zero du poste pour mettre en evidence l'anomalie */
/*  AVANT :  Ks_acmtrs_nt=0; */
          /* Sortie de l'anomalie "Poste non trouve" */
          /*
          fprintf(Kp_AnoFil,"%d~~%s~%s~%s~%s~%s~%s~%s\n",
          A_PosteAbsent,
          ptb_InRecChild[GT_CTR_NF],
          ptb_InRecChild[GT_SEC_NF],
          ptb_InRecChild[GT_UWY_NF],
          ptb_InRecChild[GT_ACY_NF],
          ptb_InRecChild[GT_TRNCOD_CF],
          ptb_InRecOwner[PER_PCPCUR_CF],
          ptb_InRecChild[GT_SSD_CF]);
          */
        }
        else {
            Ks_acmtrs_nt=Kbd_TRSLNK[i].ACMTRS_NT;
        }

        sprintf(sz_acmtrs,"%d",Ks_acmtrs_nt);

        /* Calcul du taux de conversion */

        /* Pour tous les traites (sauf non cribles),            */
        /* si devise<>devise principale, conversion du montant  */
        ptb_InRecChild[GT_ESTAMT_M]=ptb_InRecChild[GT_AMT_M];
        ptb_InRecChild[GT_ESTCUR_CF]=ptb_InRecChild[GT_CUR_CF];
        if ( (ptb_InRecOwner[PER_ESTCRB_CT][0]!='N') &&
        (strcmp(ptb_InRecOwner[PER_PCPCUR_CF],ptb_InRecChild[GT_CUR_CF])!=0) )
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
                  /* Conversion */
                  d_montant *= d_taux;
                }
                /* Sinon, montant mis a -1 */
                else d_montant = -1;

                /* Remplacement du montant et de la devise */
                sprintf(sz_montant,"%18.3lf",d_montant);
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
          /* Conversion */
          d_aliment *= d_taux;
        }
        else d_aliment=-1;

        sprintf(sz_aliment,"%18.3lf",d_aliment);
        ptb_InRecChild[GT_ESTCUR_CF]=ptb_InRecOwner[PER_PCPCUR_CF];

        /****************************************************************/
        /* A chaque contrat different correspond une derniere periode   */
        /* d'envoi et une periodicite des provisions, lesquelles ont    */
        /* ete chargees dans le perimetre en amont du lot 21. On les    */
        /* recupere ici dans le GT enrichi.                             */
        /****************************************************************/


        ptb_InRecChild[GT_NAT_CF]       = ptb_InRecOwner[PER_NAT_CF];
        ptb_InRecChild[GT_ACMTRS_NT]    = sz_acmtrs;
        ptb_InRecChild[GT_ESTCTR_NF]    = ptb_InRecOwner[PER_ESTCTR_NF];
        ptb_InRecChild[GT_ESTSEC_NF]    = ptb_InRecOwner[PER_ESTSEC_NF];
        ptb_InRecChild[GT_LOB_CF]       = ptb_InRecOwner[PER_LOB_CF];
        ptb_InRecChild[GT_SCOEGP_M]     = sz_aliment;
        ptb_InRecChild[GT_ESTCRB_CT]    = ptb_InRecOwner[PER_ESTCRB_CT];
        ptb_InRecChild[GT_LIFTRTTYP_CF] = ptb_InRecOwner[PER_LIFTRTTYP_CF];
        ptb_InRecChild[GT_ACCADMTYP_CT] = ptb_InRecOwner[PER_ACCADMTYP_CT];
        ptb_InRecChild[GT_SECSTS_CT]    = ptb_InRecOwner[PER_SECSTS_CT];
        ptb_InRecChild[GT_PRD_NF]       = ptb_InRecOwner[PER_PRD_NF];
        ptb_InRecChild[GT_SEG_NF]       = ptb_InRecOwner[PER_SEG_NF];
        ptb_InRecChild[GT_COMACC_B]     = "0";
        
        ptb_InRecChild[GT_ADJCOD_CT]    = "0";
        ptb_InRecChild[GT_RETCOD_CT]    = "0";
        ptb_InRecChild[GT_DETTRS_CF]    = "";

        ptb_InRecChild[GT_ADJSIG_B]     = "0";
        ptb_InRecChild[GT_ESTUWY_NF]    = "";

        ptb_InRecChild[GT_PROPER_N]     = ptb_InRecOwner[PER_ACCFRQ_CT];

        ptb_InRecChild[GT_RTOCTY_CF]    = "";
        n_WriteCols(Kp_OutputFil,ptb_InRecChild,SEPARATEUR,0);

        RETURN_VAL(OK);
}


/*==============================================================================
objet :
        fonction lancee quand le pere n'a pas de fils GT
retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre

==============================================================================*/
int n_ActionPereSansFilsGT(
        char **ptb_InRecOwner   /* adresse de la ligne du maitre */
        )
{
      int i;
      double    d_aliment,d_taux;
      char      sz_aliment[20];
      char sz_GT[900];
      char *tb[GT_NBCOL] ;

      DEBUT_FCT("n_ActionPereSansFilsGT");

          for(i=0;i<GT_NBCOL;i++) tb[i]="" ;
                tb[GT_NBCOL] = 0 ;

      if ( (ptb_InRecOwner[PER_ESTCRB_CT][0]=='R') ||
                   (ptb_InRecOwner[PER_ESTCRB_CT][0]=='N') )
      {

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
          /* Conversion */
          d_aliment *= d_taux;
        }
        else d_aliment=-1;

        sprintf(sz_aliment,"%18.3lf",d_aliment);

        /****************************************************************/
        /* A chaque contrat different correspond une derniere periode   */
        /* d'envoi et une periodicite des provisions, lesquelles ont    */
        /* ete chargees dans le perimetre en amont du lot 21. On les    */
        /* recupere ici dans le GT enrichi.                             */
        /****************************************************************/

                tb[GT_SSD_CF]=                  ptb_InRecOwner[PER_SSD_CF];
                tb[GT_ESB_CF]=                  ptb_InRecOwner[PER_ACCESB_CF];
        
/*              tb[GT_BALSHEY_NF]=              sz_BALSHEY_NF   ;
                tb[GT_BALSHRMTH_NF]=            sz_BALSHRMTH_NF;
                tb[GT_BALSHRDAY_NF]=            sz_BALSHRDAY_NF;
*/              
                tb[GT_CTR_NF]=                  ptb_InRecOwner[PER_CTR_NF]; 
                tb[GT_END_NT]=                  ptb_InRecOwner[PER_END_NT];
                tb[GT_SEC_NF]=                  ptb_InRecOwner[PER_SEC_NF];
                tb[GT_UWY_NF]=                  ptb_InRecOwner[PER_UWY_NF];
                tb[GT_UW_NT]=                   ptb_InRecOwner[PER_UW_NT];
                tb[GT_ACY_NF]=                  ptb_InRecOwner[PER_UWY_NF];
        
                tb[GT_CED_NF]=                  ptb_InRecOwner[PER_CED_NF];
                tb[GT_BRK_NF]=                  ptb_InRecOwner[PER_GENPRMSEN_NF];
                tb[GT_PAY_NF]=                  ptb_InRecOwner[PER_GENPRMPAY_NF];

                /**** GT enrichi */

                tb[GT_ESTCUR_CF]=               ptb_InRecOwner[PER_PCPCUR_CF];
                tb[GT_NAT_CF]=                  ptb_InRecOwner[PER_NAT_CF];
                tb[GT_ACMTRS_NT]=               "";
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
                tb[GT_ADJCOD_CT]                = "0";
                tb[GT_RETCOD_CT]                = "0";
                tb[GT_DETTRS_CF]                = "";
                tb[GT_ADJSIG_B]=                "0";
                tb[GT_ESTUWY_NF]=               "";
                tb[GT_PROPER_N]=                ptb_InRecOwner[PER_ACCFRQ_CT];
                tb[GT_RTOCTY_CF]=               "";

                n_WriteCols(Kp_OutputFil,tb,SEPARATEUR,0);
        }

        RETURN_VAL(OK);
}
