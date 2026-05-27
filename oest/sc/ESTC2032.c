/*==============================================================================
nom de l'application          : Rafraichissement des traites fictifs et des
                                segments d'analyse pour les contrats acceptation
nom du source                 : ESTC2032.c
revision                      : $Revision: 1.4 $
date de creation              : 29/05/1997
auteur                        : C. Chavatte (C.G.I.)
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :
------------------------------------------------------------------------------
historique des modifications :
 <jj/mm/aaaa>  <auteur>    <description de la modification>
  27/01/00      Anb         Réinitialisation du traite de rattachement si le crible passe de N à R
  28/01/04      J Ribot     augmentation Kn_MaxLigCTRFIC de 500 a 1000
  17/06/10      T.RIPERT    Ajout le critère de CED_NF (Cédante) dans la recherche CTRFIC (n_RechCtrfic)
                            20201110 DGATIBELZA, correction syntaxe.
_________________
MODIFICATION    [004]
Auteur:         D.GATIBELZA
Date:           15/11/2010
Version:        10.1
Description:    Ajout d'un fichier de log.
[005] 15/03/2013 R. Cassis :spot:25099 On n'ajoute plus la filiale devant le contrat
[006] 22/07/2014 ABJ :spot:25773  correction de la fonction n_RechCtrfic
[007] D. Fillinger  03/06/2015 :spot28472 EST41 Automatic Calculation
[008] MMA           23/06/2016 :                   : Optimisation du code
                    28/12/2016 :SPIRA 57351 EST26b : Correction des champs PER_ESTSEC_NF et 
                                                    PER_SEG_NF inversés dans le Kp_evolFil
[009] 04/09/2020 BEL : 81547 : relivraison de cette version afin de corriger le programme de PROD.
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
/*
#define TRACE_1*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/
#define TraiteParDefaut          1  /* 1er bit du numero d'anomalie */
#define SegmentParDefaut         2  /* 2eme bit de ce numero */
#define TraiteModifie            4  /* 3eme bit ... */
#define SegmentModifie           8
#define PasDeTraiteParDefaut    16
#define PasDeSegmentParDefaut   32
#define CodeCribleModifie       64

/*----------------------*/
/* variables de travail */
/*----------------------*/
/* Fichiers en entree, en sortie */
FILE    *Kp_FFsegparFil,
        *Kp_FFctrficFil,
        *Kp_pericaseFil,
        *Kp_evolFil,
        *Kp_anoFil,
        *Kp_logFil;     //[004]

/* Nombre de lignes dans les fichiers en entree */
int Kn_NbLigCtrfic = 0, Kn_NbLigSegpar = 0;

/* Structures de stockage des fichiers SEGPAR et CTRFIC */
#define Kn_MaxLigCTRFIC 1000
#define Kn_MaxLigSEGPAR 500
T_SEGPAR Kbd_SEGPAR[Kn_MaxLigSEGPAR];
T_CTRFIC Kbd_CTRFIC[Kn_MaxLigCTRFIC];



/* Structure de lecture du perimetre */
T_RUPTURE_VAR Kbd_RuptPerimetre;

/*---------------------------*/
/* Declaration des fonctions */
/*---------------------------*/
int n_ChargerSegpar();
int n_ChargerCtrfic();
int n_RechSegpar(char **psz_peri);
int n_RechCtrfic(char **psz_peri);
int n_InitPerimetre(T_RUPTURE_VAR  *pbd_Rupt);
int n_ProcessingPerimetre(char **ptb_InRec_Cur);
int n_EcrireAno (int n_ano, char **ptb_InRec_Cur);

char sz_cre_d[20];
char sz_cre_date[11];

/*==============================================================================
objet :     point d'entree du programme
retour :    En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc , char *argv[])
{
    DEBUT_FCT("main_fct");
    /* alimentation du nom en clair du programme */
    Gbd_Tech.psz_PgmLabel = "Rafraichisssement traites fictifs et segments";

    /* Initialisation des signaux */
    InitSig ();

    if ( n_BeginPgm (argc  , argv) == ERR )
        ExitPgm ( ERR_XX , "" );

    /* Recuperation de la date de traitement */

    strcpy(sz_cre_date, psz_GetCharArgv(1));

    sprintf(sz_cre_d, "%s %s", sz_cre_date, "23:59:00");

    n_InitPerimetre(&Kbd_RuptPerimetre);

    /* ouverture des fichiers en entree */
    if (n_OpenFileAppl("ESTC2032_I2", "rb", &Kp_FFsegparFil) == ERR )         ExitPgm ( ERR_XX , "" );
    if (n_OpenFileAppl("ESTC2032_I3", "rb", &Kp_FFctrficFil) == ERR )         ExitPgm ( ERR_XX , "" );
    /* ouverture des fichiers en sortie */
    if (n_OpenFileAppl("ESTC2032_O1", "wt", &Kp_pericaseFil) == ERR )         ExitPgm ( ERR_XX , "" );
    if (n_OpenFileAppl("ESTC2032_O2", "wt", &Kp_evolFil) == ERR )             ExitPgm ( ERR_XX , "" );
    if (n_OpenFileAppl("ESTC2032_O3", "wt", &Kp_anoFil)      == ERR )         ExitPgm ( ERR_XX , "" );
    if (n_OpenFileAppl("ESTC2032_O4", "wt", &Kp_logFil)      == ERR )         ExitPgm ( ERR_XX , "" );  //[004]


    /* modif O.Arik:29/05/2001 on sort proprement en cas de dep. de memoire*/
    /* Chargement en memoire du fichier SEGPAR.dat */
    if ( n_ChargerSegpar() == ERR )         ExitPgm ( ERR_XX , "" );

    /* Chargement en memoire du fichier CTRFIC.dat */
    if ( n_ChargerCtrfic() == ERR )         ExitPgm ( ERR_XX , "" );

    /* Traitement principal */
    if ( n_ProcessingRuptureVar (&Kbd_RuptPerimetre) == ERR )               ExitPgm ( ERR_XX , "" );


    if ( n_CloseFileAppl ("ESTC2032_I1", &(Kbd_RuptPerimetre.pf_InputFil)))  ExitPgm ( ERR_XX , "" );
    if ( n_CloseFileAppl ("ESTC2032_I2", &Kp_FFsegparFil))                   ExitPgm ( ERR_XX , "" );
    if ( n_CloseFileAppl ("ESTC2032_I3", &Kp_FFctrficFil))                   ExitPgm ( ERR_XX , "" );
    if ( n_CloseFileAppl ("ESTC2032_O1", &Kp_pericaseFil))                   ExitPgm ( ERR_XX , "" );
    if ( n_CloseFileAppl ("ESTC2032_O2", &Kp_evolFil))                       ExitPgm ( ERR_XX , "" );
    if ( n_CloseFileAppl ("ESTC2032_O3", &Kp_anoFil))                        ExitPgm ( ERR_XX , "" );
    if ( n_CloseFileAppl ("ESTC2032_O4", &Kp_logFil))                        ExitPgm ( ERR_XX , "" );   //[004]

    if ( n_EndPgm () == ERR )               ExitPgm ( ERR_XX , "" );

    exit(OK) ;
}


/**************************************************************************/
/*** Objet :    Copie le contenu du fichier en entree dans un tableau   ***/
/*** Nom:       n_Charger[structure]                                    ***/
/*** Parametres:    Le pointeur du fichier                              ***/
/***                Le tableau de structures                            ***/
/*** Retour:        0                                                   ***/
/**************************************************************************/
int n_ChargerSegpar()
{
    int n_EOF = 0;
    T_SEGPAR bd_Lu;
    char MsgAno[300];

    DEBUT_FCT("n_ChargerSegpar");

    /* Tant que la fin de fichier n'est pas atteinte,... */
    while (n_EOF == 0)
    {
        /* ... lecture d'une ligne dans le fichier. */
        if (fread(&bd_Lu, sizeof(T_SEGPAR), 1, Kp_FFsegparFil) <= 0)
            n_EOF = 1;          /* Fin de fichier, mise a jour du flag */
        else
        {
            /* Elimination des espaces inutiles */
            StripSpaces(bd_Lu.ANLCTY_CF);
            StripSpaces(bd_Lu.CLINAT_CF);

            if ( Kn_NbLigSegpar + 1 >= Kn_MaxLigSEGPAR )
            {
                /* depassement tableau */
                sprintf(MsgAno, "SEGPAR:  overflows the program's storage capacity");
                n_WriteAno(MsgAno);
                RETURN_VAL(ERR);
            }

            /* Enregistrement ecrit dans le tableau */
            Kbd_SEGPAR[Kn_NbLigSegpar++] = bd_Lu;
        }
    }

    RETURN_VAL (0);
}


int n_ChargerCtrfic()
{
    int n_EOF = 0;
    T_CTRFIC bd_Lu;
    char sz_ctr[50];
    char MsgAno[300];

    DEBUT_FCT("n_ChargerCtrfic");

    /* Tant que la fin de fichier n'est pas atteinte,... */
    while (n_EOF == 0)
    {
        /* ... lecture d'une ligne dans le fichier. */
        if (fread(&bd_Lu, sizeof(T_CTRFIC), 1, Kp_FFctrficFil) <= 0)
            n_EOF = 1;          /* Fin de fichier, mise a jour du flag */
        else
        {
            /* Elimination des espaces inutiles */
            StripSpaces(bd_Lu.LIFTRTTYP_CF);

            /* Ajout de la filiale en tete du contrat   */
            if (sizeof(bd_Lu.ESTCTR_NF) < 9)  // [004]
            {
                sprintf(sz_ctr, "%02d%7.7s", bd_Lu.SSD_CF, bd_Lu.ESTCTR_NF);
#ifdef TRACE_2
//         1    2  3  4  5  6
                printf("%02d%7.7s~%s~%d~%s~%d\n",
                       bd_Lu.SSD_CF,       // 1
                       bd_Lu.ESTCTR_NF,    // 2
                       bd_Lu.LIFTRTTYP_CF, // 3
                       bd_Lu.UWGRP_CF,     // 4
                       bd_Lu.ANLCTY_CF,    // 5
                       bd_Lu.CED_NF);      // 6
#endif

                strcpy(bd_Lu.ESTCTR_NF, sz_ctr);
            }

            if ( Kn_NbLigCtrfic + 1 >= Kn_MaxLigCTRFIC )
            {
                /* depassement tableau */
                sprintf(MsgAno, "Ctrfic:  overflows the program's storage capacity");
                n_WriteAno(MsgAno);
                RETURN_VAL(ERR);
            }

            /* Enregistrement ecrit dans le tableau */
            Kbd_CTRFIC[Kn_NbLigCtrfic++] = bd_Lu;
        }
    }

    RETURN_VAL (0);
}


int n_ProcessingPerimetre(char **ptb_InRec_Cur)
{
    int n_ligneT,     /* Numero de la ligne Traite trouvee, -1 sinon */
        n_ligneS = -1,       /* Numero de la ligne Segment trouvee, -1 sinon */
        n_ano = 0,        /* Numero de l'anomalie eventuelle a ecrire */
        b_evol = 0;       /* Indique s'il faut ecrire une evolution */
    char sz_ctr[50] = "", /* Traite a ecrire dans les evolutions */
                      sz_ord[50] = "";  /* Segment a ecrire dans les evolutions */

    DEBUT_FCT("n_ProcessingPerimetre");

#ifdef TRACE_1
    printf("n_ProcessingPerimetre %s~%s~%s~%s~%s\n",
           ptb_InRec_Cur[PER_CTR_NF],
           ptb_InRec_Cur[PER_SEC_NF],
           ptb_InRec_Cur[PER_UWY_NF],
           ptb_InRec_Cur[PER_SECSTS_CT],
           ptb_InRec_Cur[PER_ESTCRB_CT]);
#endif


    /* Si la section est acceptee/definitive/renouvelee/resiliee    */
    if ( (strstr("14 16 17 18 19 23", ptb_InRec_Cur[PER_SECSTS_CT]) != NULL))
    {
#ifdef TRACE_1
        printf("n_ProcessingPerimetre %s~ ~ ~ ~%s\n", ptb_InRec_Cur[PER_CTR_NF], ptb_InRec_Cur[PER_ESTCRB_CT]);
#endif
        /* Si le traite est non crible, recherche du traite rattache */
        if (ptb_InRec_Cur[PER_ESTCRB_CT][0] == 'N')
        {

#ifdef TRACE_1
            printf("Recherche %s\n", ptb_InRec_Cur[PER_CTR_NF]);
#endif
            // Recherche d'une ligne dans les traites fictifs ou [filiale, [unite et pays, [type de traite vie]]] correspondent.
            n_ligneT = n_RechCtrfic(ptb_InRec_Cur);

            // Si aucune ligne ne correspond, avertir que le traite par defaut n'a pas ete cree
            if (n_ligneT == -1)
                n_ano += PasDeTraiteParDefaut;
            else
                // Si une ligne est trouvee
            {
                // Si seule la filiale est renseignee, anomalie "Traite par defaut"
                if ( (strcmp(Kbd_CTRFIC[n_ligneT].ANLCTY_CF, "AAA") == 0)  ||  (Kbd_CTRFIC[n_ligneT].UWGRP_CF == 0) )
                    n_ano += TraiteParDefaut;

                // Si le traite a change, le signaler
                if  (  strcmp(ptb_InRec_Cur[PER_ESTCTR_NF], Kbd_CTRFIC[n_ligneT].ESTCTR_NF) != 0 )
                    n_ano += TraiteModifie;
            }


            // [004] Ajout d'une log
            //                       1  2  3  4  5  6  7 8                9 10 11 12 13
            fprintf(Kp_logFil, "PER:~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~RATTACHEMENT~%d~%s~%s~%d~%s\n",
                    ptb_InRec_Cur[PER_CTR_NF],                                  // 01
                    ptb_InRec_Cur[PER_UWY_NF],                                  // 02
                    ptb_InRec_Cur[PER_UW_NT],                                                                       ////////////
                    ptb_InRec_Cur[PER_SEC_NF],                                  // 03
                    ptb_InRec_Cur[PER_END_NT],                                  ////////////
                    ptb_InRec_Cur[PER_ESTSEC_NF],                                                               ////////////
                    ptb_InRec_Cur[PER_SEG_NF],                                                                  ////////////
                    ptb_InRec_Cur[PER_SSD_CF],                                  // 04
                    ptb_InRec_Cur[PER_UWGRP_CF],                                // 05
                    ptb_InRec_Cur[PER_ANLCTY_CF],                               // 06
                    ptb_InRec_Cur[PER_LIFTRTTYP_CF],                            // 07
                    ptb_InRec_Cur[PER_CED_NF],                                  // 08
                    sz_cre_d, //ptb_InRec_Cur[PRE_CRE_D],                                                                       ////////////
                    "dbo", //ptb_InRec_Cur[PRE_CREUSR_CF],                               ////////////
                    sz_cre_d, //ptb_InRec_Cur[PRE_LSTUPD_D],                                ////////////
                    "dbo", //ptb_InRec_Cur[PRE_LSTUPDUSR_CF],                            ////////////
                    n_ligneT == -1 ? -1 : Kbd_CTRFIC[n_ligneT].UWGRP_CF,        // 09
                    n_ligneT == -1 ? "-1" : Kbd_CTRFIC[n_ligneT].ANLCTY_CF,     // 10
                    n_ligneT == -1 ? "-1" : Kbd_CTRFIC[n_ligneT].LIFTRTTYP_CF,  // 11
                    n_ligneT == -1 ? -1 : Kbd_CTRFIC[n_ligneT].CED_NF,          // 12
                    n_ligneT == -1 ? "-1" : Kbd_CTRFIC[n_ligneT].ESTCTR_NF);    // 13

        }

        /************************************************************************/
        /* Modifs du 30/03/98 - M.HA-THUC                                       */
        /* Si l'affaire passe de non criblee -> criblee alors on reinitialise   */
        /* le traite de rattachement et on ecrit une evolution                  */
        /************************************************************************/
        sprintf(sz_ctr, "%s", Kbd_CTRFIC[n_ligneT].ESTCTR_NF);

        /* Modif Anb le 27/01/00 */
        /* Extension de la modification précédente au cas où l'affaire passe */
        /* de non criblee -> criblee */
        if ( ( ptb_InRec_Cur[PER_ESTCRB_CT][0] == 'O' && ptb_InRec_Cur[PER_ESTCTR_NF][0] == '0' ) ||
                ( ptb_InRec_Cur[PER_ESTCRB_CT][0] == 'A' && ptb_InRec_Cur[PER_ESTCTR_NF][0] == '0' ) ||   //[007]
                ( ptb_InRec_Cur[PER_ESTCRB_CT][0] == 'E' && ptb_InRec_Cur[PER_ESTCTR_NF][0] == '0' ) ||   //[007]
                ( ptb_InRec_Cur[PER_ESTCRB_CT][0] == 'R' && ptb_InRec_Cur[PER_ESTCTR_NF][0] == '0' ) )
            n_ano += CodeCribleModifie;

        /* Si le traite a change:                       */
        /* - le traite du perimetre doit etre rafraichi */
        /* - une evolution doit etre ecrite             */
        if ((n_ano & TraiteModifie) != 0)
        {
            strcpy(sz_ctr, Kbd_CTRFIC[n_ligneT].ESTCTR_NF);
            StripSpaces(sz_ctr);
            ptb_InRec_Cur[PER_ESTCTR_NF] = sz_ctr;
            b_evol = 1;
        }

        /* Si le segment a change:                      */
        /* - le segment du perimetre doit etre rafraichi*/
        /* - une evolution doit etre ecrite             */
        if ((n_ano & SegmentModifie) != 0)
        {
            strcpy(sz_ord, Kbd_SEGPAR[n_ligneS].SEG_NF);
            StripSpaces(sz_ord);
            ptb_InRec_Cur[PER_SEG_NF] = sz_ord;
            b_evol = 2;
        }

        if ( ( n_ano & CodeCribleModifie ) != 0 )
        {
            ptb_InRec_Cur[PER_ESTCTR_NF] = ""  ;
            strcpy( sz_ctr, "" ) ;
            b_evol = 3 ;
        }

        // Reconduction ou rafraichissement du perimetre
        n_WriteCols(Kp_pericaseFil, ptb_InRec_Cur, '~', 0);

        // Ecriture des anomalies rencontrees
        if (strcmp( ptb_InRec_Cur[PER_SSD_CF], "2" ) != 0)
            n_EcrireAno(n_ano, ptb_InRec_Cur);

        /* Ecriture d'une evolution */
        /*  fprintf(Kp_evolFil,"%s~%s~%s~%s~%s~%s~%s~%d\n",
            ptb_InRec_Cur[PER_CTR_NF],ptb_InRec_Cur[PER_END_NT],ptb_InRec_Cur[PER_SEC_NF],
            ptb_InRec_Cur[PER_UWY_NF],ptb_InRec_Cur[PER_UW_NT],sz_ctr,sz_ord,b_evol );
        }*/
        fprintf(Kp_evolFil, "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",
                ptb_InRec_Cur[PER_SSD_CF],
                ptb_InRec_Cur[PER_CTR_NF],
                ptb_InRec_Cur[PER_UWY_NF],
                ptb_InRec_Cur[PER_UW_NT],
                ptb_InRec_Cur[PER_SEC_NF],
                ptb_InRec_Cur[PER_END_NT],
                sz_ctr,
                ptb_InRec_Cur[PER_ESTSEC_NF],
                ptb_InRec_Cur[PER_SEG_NF],
                sz_cre_d,
                "dbo",
                sz_cre_d,
                "dbo"
               );
    }
    RETURN_VAL (0);
}


/*****************************************************************************/
/*** Objet: Recherche une ligne du tableau de structures ou les            ***/
/***        champs correspondent aux parametres en entree.                 ***/
/*** Nom:   n_Rech[structure]                                              ***/
/*** Parametres: La ligne du tableau contenant les valeurs recherchees     ***/
/***             Le nombre de lignes du tableau ou s'effectue la recherche ***/
/*** Retour:        Le numero de la ligne du tableau si trouve             ***/
/***                -1 si non trouve                                       ***/
/*****************************************************************************/
int n_RechCtrfic (char **psz_peri)
{
    int n_indice = 0,
        rupT_SSD  = 0,
        rupT_UWGRP    = 0,    // indiquent si le champ
        rupT_ANLCTY    = 0,   // a deja ete trouve
        n_defaut  = -1,       // traite par defaut
        rupT_LIFTRTTYP    = 0;
    char clefR[17] = "" ,         // clef recherchee
         clefV[17] = "",          // clef en cours de verification
         sz_ssd[3] = "",          // Filiale
         sz_ced_nf[6] = "",       // Cedante
         sz_uwgrp[5] = "",        // Unite
         sz_anlcty_cf[4] = "",    // Analytic Country
         sz_liftrttyp_cf[3] = "";

    //int limit_test = 10;

    DEBUT_FCT("n_RechCtrfic");

    /* SPOT 19101 : TRIPERT 23/06/2010 */
    /* Ajout la colonne CED_NF */
    sprintf(clefR, "%s%s%s%s%s",
            psz_peri[PER_SSD_CF],
            psz_peri[PER_UWGRP_CF],
            psz_peri[PER_ANLCTY_CF],
            psz_peri[PER_LIFTRTTYP_CF],
            psz_peri[PER_CED_NF]);


    for ( n_indice=0 ; n_indice < Kn_NbLigCtrfic; n_indice++ )
    {
        // Formatage de la clef en cours de verification
        sprintf(sz_ssd, "%d", Kbd_CTRFIC[n_indice].SSD_CF);
        sz_ssd[2] = 0;
        sprintf(sz_uwgrp, "%d", Kbd_CTRFIC[n_indice].UWGRP_CF);
        sz_uwgrp[4] = 0;
        sprintf(sz_ced_nf, "%d", Kbd_CTRFIC[n_indice].CED_NF);
        sz_ced_nf[5] = 0;          // SPOT 19101 TRIPERT
        sprintf(sz_anlcty_cf, "%s", Kbd_CTRFIC[n_indice].ANLCTY_CF);
        sz_anlcty_cf[3] = 0;
        sprintf(sz_liftrttyp_cf, "%s", Kbd_CTRFIC[n_indice].LIFTRTTYP_CF);
        sz_liftrttyp_cf[2] = 0;
        // SPOT 19101 : TRIPERT
        // sprintf(clefV,"%+2.2s%+4.4s%+3.3s%+2.2s\0", sz_ssd,sz_uwgrp, Kbd_CTRFIC[n_indice].ANLCTY_CF, Kbd_CTRFIC[n_indice].LIFTRTTYP_CF); */
        sprintf(clefV, "%s%s%s%s%s",
                sz_ssd, sz_uwgrp,
                sz_anlcty_cf,
                sz_liftrttyp_cf,
                sz_ced_nf);
        // FIN TRIPERT


        // Si les champs correspondent, on a trouve le debut du bloc.
        // Sinon, et si on etait precedemment sur ce bloc, alors on ne peut plus trouver la ligne.
        //SSD
        //[006]
        if (strcmp(psz_peri[PER_SSD_CF], sz_ssd) == 0)
        {
            // 1er champ trouve SSD
            rupT_SSD = 1;

            // SSD + UWGRP
            //[006]
            if (strcmp(psz_peri[PER_UWGRP_CF], sz_uwgrp) == 0)
            {
                // 2eme champ trouve
                // SSD + UWGRP (SSD + Unite de souscription)
                rupT_UWGRP = 1;

                // SSD + UWGRP + ANLCTY_CF
                //[006]
                if (strcmp(psz_peri[PER_ANLCTY_CF], sz_anlcty_cf) == 0)
                {
                    // 3eme champ trouve SSD + UWGRP + ANLCTY_CF
                    // (SSD + Unite de souscription + Pays d analyse)
                    rupT_ANLCTY = 1;

                    // SSD + UWGRP + ANLCTY_CF + LIFTRTTYP_CF
                    if (strcmp(psz_peri[PER_LIFTRTTYP_CF], sz_liftrttyp_cf) == 0)
                    {
                        // 4eme champ trouve SSD + UWGRP + ANLCTY_CF + LIFTRTTYP_CF
                        // (SSD + Unite de souscription + Pays d analyse + Caracterisation de l affaire)
                        rupT_LIFTRTTYP = 1;

                        // Si le 5eme champ correspond, retour de l'indice
                        // (SSD + Unite de souscription + Pays d analyse + Caracterisation de l affaire + Cédante)
                        if (strcmp(clefR, clefV) == 0)
                        {
                            RETURN_VAL (n_indice);
                        }
                    } /* SINON SSD + UWGRP + ANLCTY_CF + LIFTRTTYP_CF */
                    else if (rupT_LIFTRTTYP == 1)
                    {
                        RETURN_VAL (n_defaut);
                    }
                } /* SINON SSD + UWGRP + ANLCTY_CF */
                else if (rupT_ANLCTY == 1)
                {
                    RETURN_VAL (n_defaut);
                }
            } /* SINON SSD + UWGRP */
            else if (rupT_UWGRP == 1)
            {
                RETURN_VAL (n_defaut);
            }
            // On mémorise l'indice de CTRFIC
            if ( ((rupT_LIFTRTTYP == 1)  &&  (Kbd_CTRFIC[n_indice].CED_NF == 0))                                                                                                        ||
                 ((rupT_ANLCTY == 1)  &&  (Kbd_CTRFIC[n_indice].LIFTRTTYP_CF[0] == 0)   && (Kbd_CTRFIC[n_indice].CED_NF == 0))                                                          ||
                 ((rupT_UWGRP == 1)  &&  (strcmp(Kbd_CTRFIC[n_indice].ANLCTY_CF, "AAA") == 0) && (Kbd_CTRFIC[n_indice].LIFTRTTYP_CF[0] == 0)  && (Kbd_CTRFIC[n_indice].CED_NF == 0))    ||
                 ((rupT_SSD == 1)  &&  (Kbd_CTRFIC[n_indice].UWGRP_CF == 0)  && (strcmp(Kbd_CTRFIC[n_indice].ANLCTY_CF, "AAA") == 0)    && (Kbd_CTRFIC[n_indice].LIFTRTTYP_CF[0] == 0) && (Kbd_CTRFIC[n_indice].CED_NF == 0)) )
            {
                n_defaut = n_indice;
            }
        }
        else /* SINON SSD */
        {
            if (rupT_SSD == 1)
            {
                RETURN_VAL (n_defaut);
            }
        }

        // Si la ligne a ete depassee, retour de la ligne par defaut
        if (strcmp(clefR, clefV) < 0)
            RETURN_VAL(n_defaut);
    } /*end for*/

    RETURN_VAL (n_defaut);
}


int n_RechSegpar (char **psz_peri)
{
    int n_indice = 0,       /* indice dans le tableau parcouru */
        b_chp1 = 0, b_chp2 = 0, /* indiquent si le champ */
        b_chp3 = 0, b_chp4 = 0, /* a deja ete trouve     */
        n_defaut = -1;      /* segment par defaut */
    char    clefR[15],      /* clef recherchee */
            clefV[15],      /* clef en cours de verification */
            sz_ssd[3],
            sz_uwgrp[5],
            sz_ordnbr[3];

    DEBUT_FCT("n_RechSegpar");

    /* Formatage de la clef recherchee */
    sprintf(clefR, "%s%s%s%s%s", psz_peri[PER_SSD_CF],
            psz_peri[PER_UWGRP_CF], psz_peri[PER_ANLCTY_CF],
            psz_peri[PER_CLINAT_CF], psz_peri[PER_ORDNBR_NT]);

    while (1 == 1)
    {
        /* Formatage de la clef a verifier */
        sprintf(sz_ssd, "%d", Kbd_SEGPAR[n_indice].SSD_CF);
        sprintf(sz_uwgrp, "%d", Kbd_SEGPAR[n_indice].UWGRP_CF);
        sprintf(sz_ordnbr, "%d", Kbd_SEGPAR[n_indice].ORDNBR_NT);
        sprintf(clefV, "%s%s%s%s%s",
                sz_ssd, sz_uwgrp,
                Kbd_SEGPAR[n_indice].ANLCTY_CF,
                Kbd_SEGPAR[n_indice].CLINAT_CF, sz_ordnbr);

        /* Si les champs correspondent, on a trouve le debut */
        /* du bloc. Sinon, et si on etait precedemment sur ce */
        /* bloc, alors on ne peut plus trouver la ligne. */
        if (strncmp(clefR, clefV, 2) == 0)
        {
            /* 1er champ trouve */
            b_chp1 = 1;
            if (strncmp(clefR, clefV, 6) == 0)
            {
                /* 2eme champ trouve */
                b_chp2 = 1;
                if (strncmp(clefR, clefV, 9) == 0)
                {
                    /* 3eme champ trouve */
                    b_chp3 = 1;
                    if (strncmp(clefR, clefV, 12) == 0)
                    {
                        /* 4eme champ trouve */
                        b_chp4 = 1;
                        /* Si tout correspond, retour de l'indice */
                        if (strcmp(clefR, clefV) == 0)
                        {
                            RETURN_VAL ( n_indice);
                        }
                    } else if (b_chp4 == 1) RETURN_VAL ( n_defaut);
                } else if (b_chp3 == 1) RETURN_VAL ( n_defaut);
            } else if (b_chp2 == 1) RETURN_VAL ( n_defaut);

            /* Si au moins la filiale est trouvee et que les autres */
            /* sont trouves ou non-renseignes, memoriser la ligne   */
            if ( ((b_chp4 == 1) && (Kbd_SEGPAR[n_indice].ORDNBR_NT == 0))
                    || ((b_chp3 == 1)
                        && (atoi(Kbd_SEGPAR[n_indice].CLINAT_CF) == 0)
                        && (Kbd_SEGPAR[n_indice].ORDNBR_NT == 0))
                    || ((b_chp2 == 1)
                        && (strcmp(Kbd_SEGPAR[n_indice].ANLCTY_CF, "AAA") == 0)
                        && (atoi(Kbd_SEGPAR[n_indice].CLINAT_CF) == 0)
                        && (Kbd_SEGPAR[n_indice].ORDNBR_NT == 0))
                    || ((b_chp1 == 1) && (Kbd_SEGPAR[n_indice].UWGRP_CF == 0)
                        && (strcmp(Kbd_SEGPAR[n_indice].ANLCTY_CF, "AAA") == 0)
                        && (atoi(Kbd_SEGPAR[n_indice].CLINAT_CF) == 0)
                        && (Kbd_SEGPAR[n_indice].ORDNBR_NT == 0)) )
            {
                n_defaut = n_indice;
            }

        } else if (b_chp1 == 1) RETURN_VAL ( n_defaut);

        /* Si la ligne a ete depassee, retour de la ligne par defaut */
        if (strcmp(clefR, clefV) < 0) RETURN_VAL(n_defaut);

        /* Ligne suivante */
        n_indice++;

        /* Si on a depasse la fin du tableau, ligne non trouvee */
        if (n_indice >= Kn_NbLigSegpar) RETURN_VAL ( n_defaut);
    }
}

int n_InitPerimetre(T_RUPTURE_VAR  *pbd_Rupt)
{
    DEBUT_FCT("n_InitPerimetre");

    memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

    /* Ouverture du fichier maitre */
    if (n_OpenFileAppl ("ESTC2032_I1", "rt", &(pbd_Rupt->pf_InputFil)))
        RETURN_VAL (ERR);

    /* Pas de gestion de rupture */
    pbd_Rupt->n_NbRupture = 0;

    /* Fonction executee pour chaque ligne du perimetre: */
    pbd_Rupt->n_ActionLigne     = n_ProcessingPerimetre;

    /* Separateur utilise dans le fichier en entree */
    pbd_Rupt->c_Separ               = '~' ;

    RETURN_VAL (0);
}

int n_EcrireAno (int n_ano, char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_EcrireAno");

    if (n_ano == 0) RETURN_VAL (0);
    if ((n_ano & TraiteParDefaut) != 0)
        fprintf(Kp_anoFil, "%d~%s~%s~%s~%s~~~%s~%s\n",
                A_TraiteParDefaut,
                ptb_InRec_Cur[PER_UWGRP_CF],
                ptb_InRec_Cur[PER_CTR_NF],
                ptb_InRec_Cur[PER_SEC_NF],
                ptb_InRec_Cur[PER_UWY_NF],
                ptb_InRec_Cur[PER_PCPCUR_CF],
                ptb_InRec_Cur[PER_SSD_CF]
               );
    if ((n_ano & SegmentParDefaut) != 0)
        fprintf(Kp_anoFil, "%d~%s~%s~%s~%s~~~%s~%s\n",
                A_SegmentParDefaut,
                ptb_InRec_Cur[PER_UWGRP_CF],
                ptb_InRec_Cur[PER_CTR_NF],
                ptb_InRec_Cur[PER_SEC_NF],
                ptb_InRec_Cur[PER_UWY_NF],
                ptb_InRec_Cur[PER_PCPCUR_CF],
                ptb_InRec_Cur[PER_SSD_CF]
               );
    if ((n_ano & TraiteModifie) != 0)
        fprintf(Kp_anoFil, "%d~%s~%s~%s~%s~~~%s~%s\n",
                A_TraiteModifie,
                ptb_InRec_Cur[PER_UWGRP_CF],
                ptb_InRec_Cur[PER_CTR_NF],
                ptb_InRec_Cur[PER_SEC_NF],
                ptb_InRec_Cur[PER_UWY_NF],
                ptb_InRec_Cur[PER_PCPCUR_CF],
                ptb_InRec_Cur[PER_SSD_CF]
               );
    if ((n_ano & SegmentModifie) != 0)
        fprintf(Kp_anoFil, "%d~%s~%s~%s~%s~~~%s~%s\n",
                A_SegmentModifie,
                ptb_InRec_Cur[PER_UWGRP_CF],
                ptb_InRec_Cur[PER_CTR_NF],
                ptb_InRec_Cur[PER_SEC_NF],
                ptb_InRec_Cur[PER_UWY_NF],
                ptb_InRec_Cur[PER_PCPCUR_CF],
                ptb_InRec_Cur[PER_SSD_CF]
               );
    if ((n_ano & PasDeTraiteParDefaut) != 0)
        fprintf(Kp_anoFil, "%d~%s~%s~%s~%s~~~%s~%s\n",
                A_PasDeTraiteParDefaut,
                ptb_InRec_Cur[PER_UWGRP_CF],
                ptb_InRec_Cur[PER_CTR_NF],
                ptb_InRec_Cur[PER_SEC_NF],
                ptb_InRec_Cur[PER_UWY_NF],
                ptb_InRec_Cur[PER_PCPCUR_CF],
                ptb_InRec_Cur[PER_SSD_CF]
               );
    if ((n_ano & PasDeSegmentParDefaut) != 0)
        fprintf(Kp_anoFil, "%d~%s~%s~%s~%s~~~%s~%s\n",
                A_PasDeSegmentParDefaut,
                ptb_InRec_Cur[PER_UWGRP_CF],
                ptb_InRec_Cur[PER_CTR_NF],
                ptb_InRec_Cur[PER_SEC_NF],
                ptb_InRec_Cur[PER_UWY_NF],
                ptb_InRec_Cur[PER_PCPCUR_CF],
                ptb_InRec_Cur[PER_SSD_CF]
               );

    RETURN_VAL (0);
}
