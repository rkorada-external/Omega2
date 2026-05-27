/*==============================================================================
 Nom de l'application          : ESTIMATION
 Nom du source                 : ESTC0010.c
 Revision                      : $Revision: 1.2 $
 Date de creation              : 24/10/2000
 Auteur                        : gensource v2.0 (auto)
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :
   Obtention des diff entre les resultats des inventaires Retro par retrocessionnaires internes et les resultats par contrat acceptation en lien avec ces retrocessionnaires
------------------------------------------------------------------------------
 Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    12/09/2003     J.Ribot     passe MAX_SSDACTR	de 12500 a 20000 (dans le .H)
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
       ...           ...            ...              ...
==============================================================================*/


/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include "struct.h"


/*---------------------------------------*/
/* Inclusion de l'interface du composant */
/*---------------------------------------*/
#include "ESTC0010.h"


/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*---------------------------------------------*/
  char Ksz_ACMTRS_CF[8];
  char **Kptsz_LigneFSSDACTR;		/* sauvegarde d une ligne du fichier FSSDACTR */
  char *Ksz_LibellesPoste[4][4];	/* Tableau contenant les valeurs des differents libelles de poste */

  short Kn_SsdActr_Nbp ;   			/* compteur du nombre de postes du tableau Ktbd_SsdActr */

  int Kn_FBOTRSLNK ;   				/* compteur du nombre ligne chargees dans Ktbd_FBOTRSLNK */
  int Kn_SsdActr_Indice ;			/* indice de la correspondance dans la table TSSDACTR */
  int FlagSync;


int n_ChargePoste();


  /* variables utilisees pour la generation des postes selon l'ancienne version */
  /* int Kn_TRSLNK;*/
  /* char Ksz_ACMTRS_OLD[8]; */


/*==============================================================================
 Objet :
   Point d'entree du programme

 Parametre(s) :
   int argc    : Nombre d'arguments sur la ligne de commande;
   char **argv : parametres

 Retour :
   En cas de probleme, sortie par ExitPgm(ERRCODE)
   sinon appel systeme exit(OK)
==============================================================================*/
int main(int argc, char **argv)
{
  /* Initialisation des signaux */
  InitSig () ;

  if (n_BeginPgm(argc, argv) == ERR) ExitPgm(ERR_XX, "");

  /* Initialisation des variables de gestion de ruptures */
  if (n_InitFCLEDR(&Kbd_ruptFCLEDR)) ExitPgm(ERR_XX, "");


  /* ouverture du fichier binaire en entree des correspondances retro vers acceptation */
  if ( n_OpenFileAppl ( "ESTC0010_I2","rb",&Kp_InputFilSsdActr ) == ERR )
     ExitPgm( ERR_XX , "" ) ;

  /* Ouverture des fichiers binaires et des fichiers de sortie */
  if (n_OpenFileAppl("ESTC0010_I3", "rb", &Kp_FBOTRSLNK) == ERR) ExitPgm(ERR_XX ,"");
  if (n_OpenFileAppl("ESTC0010_O1", "wt", &Kp_OutputFileOUT1) == ERR) ExitPgm(ERR_XX ,"");

  /* fichier utilise pour la generation des postes selon l'ancienne version */
  /* if (n_OpenFileAppl("ESTC0010_I4", "rb", &Kp_TRSLNK) == ERR) ExitPgm(ERR_XX ,""); */

  /* Chargement des type de poste */
  n_ChargePoste();

  /* Chargement de la table TSSDACTR en memoire */
  Kn_SsdActr_Nbp = n_ChargerSSDACTR( ) ;
  if ( Kn_SsdActr_Nbp == -1 )
		ExitPgm( ERR_XX , "Taille tableau TSSDACTR insuffisante " ) ;

  /* Chargement du tableau TRSLNK pour ls postes 750 */
  Kn_FBOTRSLNK = n_ChargerFBOTRSLNK();
  if ( Kn_FBOTRSLNK == -1 )
  		ExitPgm( ERR_XX , "Taille tableau FBOTRSLNK insuffisante " ) ;


  /* Chargement du tableau TRSLNK pour ls postes 750 ancienne version */
  /* Kn_TRSLNK = n_ChargerTRSLNK( 750 ); */

  /* Lancement du traitement du fichier Maitre */
  if (n_ProcessingRuptureVar(&Kbd_ruptFCLEDR) == ERR) ExitPgm(ERR_XX, "");

  /* Fermeture des fichiers ouverts */
  if (n_CloseFileAppl("ESTC0010_I1", &(Kbd_ruptFCLEDR.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl("ESTC0010_I2", &Kp_InputFilSsdActr) == ERR) ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl("ESTC0010_I3", &Kp_FBOTRSLNK) == ERR) ExitPgm(ERR_XX, "");

  /* Ancienne version */
  /* if (n_CloseFileAppl("ESTC0010_I4", &Kp_TRSLNK) == ERR) ExitPgm(ERR_XX, ""); */


  if (n_CloseFileAppl("ESTC0010_O1", &Kp_OutputFileOUT1)) ExitPgm(ERR_XX, "");

  if (n_EndPgm() == ERR) ExitPgm(ERR_XX, "");

  exit(OK);
}


/*==============================================================================
 Objet : mise en mémoire du libellé des postes 750
 	1ere colonne TRSTYP_NT
 	2de colonne ESTIM_NT

 Parametre(s) :

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_ChargePoste()
{
	 Ksz_LibellesPoste[0][0] = "XX" ; /* Autres */

	 Ksz_LibellesPoste[2][3] = "SO" ; /* Service ouverture */
	 Ksz_LibellesPoste[3][3] = "SC" ; /* Service cloture */
	 Ksz_LibellesPoste[3][2] = "EC" ; /* Estime cloture */
	 Ksz_LibellesPoste[2][2] = "EO" ; /* Estime ouverture */
	 Ksz_LibellesPoste[1][1] = " D" ; /* Definitif cedante */
	 Ksz_LibellesPoste[3][1] = "DC" ; /* Definitif cloture */
	 Ksz_LibellesPoste[2][1] = "DO" ; /* Definitif ouverture */

	 /* Gestion des erreurs */
	 Ksz_LibellesPoste[0][1] =  "ER" ;
	 Ksz_LibellesPoste[0][2] =  "ER" ;
	 Ksz_LibellesPoste[0][3] =  "ER" ;
	 Ksz_LibellesPoste[1][0] =  "ER" ;
	 Ksz_LibellesPoste[1][2] =  "ER" ;
	 Ksz_LibellesPoste[2][0] =  "ER" ;
     Ksz_LibellesPoste[3][0] =  "ER" ;


	return OK;
}

/*==============================================================================
 Objet :
   Initialisation de la variable de gestion de rupture (Maitre)

 Parametre(s) :
   Pointeur sur une structure T_RUPTURE_VAR

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_InitFCLEDR(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

  if (n_OpenFileAppl("ESTC0010_I1","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 1;
  pbd_Rupt->n_ConditionRupture[0] = n_IsR1FCLEDR;
  pbd_Rupt->n_ActionFirst[0] = n_ActionF1FCLEDR;
  pbd_Rupt->n_ActionLigne = n_ActionLigneFCLEDR;
  pbd_Rupt->c_Separ = '~';

  return OK;
}




/*==============================================================================
 Objet :
   Fonction de test de rupture de niveau 1 (Maitre)

 Parametre(s) :
   Pointeur sur la ligne courante
   Pointeur sur la ligne suivante

 Retour :
   0 --> Pas de rupture
   1--> Situation de rupture
==============================================================================*/
int n_IsR1FCLEDR(char **pbd_InRec, char **pbd_InRec_Cur)
{
  int ret ;

  DEBUT_FCT("n_IsR1FCLEDR");

  if ((ret = strcmp(pbd_InRec[FTECLEDR_RETCTR_NF], pbd_InRec_Cur[FTECLEDR_RETCTR_NF])) != 0 ) RETURN_VAL(ret);
  if ((ret = strcmp(pbd_InRec[FTECLEDR_RETSEC_NF], pbd_InRec_Cur[FTECLEDR_RETSEC_NF])) != 0 ) RETURN_VAL(ret);
  if ((ret = strcmp(pbd_InRec[FTECLEDR_RTY_NF], pbd_InRec_Cur[FTECLEDR_RTY_NF])) != 0 ) RETURN_VAL(ret);
  if ((ret = strcmp(pbd_InRec[FTECLEDR_PLC_NT], pbd_InRec_Cur[FTECLEDR_PLC_NT])) != 0 ) RETURN_VAL(ret);

  RETURN_VAL(0);
}



/*==============================================================================
 Objet :
   Fonction lancee en rupture premiere de niveau 1 (Maitre)

 Parametre(s) :
   Pointeur sur la ligne courante

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_ActionF1FCLEDR(char **ptb_InRec_Cur)
{
  FlagSync = 0;

  /* recherche de la correspondance dans la table TSSDACTR */
     Kn_SsdActr_Indice = n_RechercheSSDACTR( ptb_InRec_Cur[FTECLEDR_RETCTR_NF],
                              atoi( ptb_InRec_Cur[FTECLEDR_RTY_NF] ),
                              atol( ptb_InRec_Cur[FTECLEDR_PLC_NT] ),
                              (char) atoi( ptb_InRec_Cur[FTECLEDR_RETSEC_NF] ) ) ;

  /* si la recherche dans TSSDACTR n'aboutit pas, pas d'ecriture en sortie */
     if ( Kn_SsdActr_Indice != -1 )
         FlagSync=1;


  return OK;
}




/*==============================================================================
 Objet :
   Fonction lancee pour chaque ligne du Maitre

 Parametre(s) :
   Pointeur sur la ligne courante

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_ActionLigneFCLEDR(char **ptb_InRec_Cur)
{
   char sz_buf1[9];
   char sz_SSD_CF_r[3];
   char sz_Poste[3];
   int n_ssd_cf;
   double montant;
   char sz_montant[20];
   int n_acmtrs_cf;
   char sz_message[200];
   int n_indice_trn;
   int i, j;
   /* char sz_PosteOld[3]; */

  /* initialisation du buffer */
  strcpy ( sz_Poste , "" ) ;


  if (FlagSync == 1)
  {
    /* recherche de la correspondance dans la table TRSLNK */

    /* recherche de l indice du trncod dans le tableau Ktbd_FBOTRSLNK */
	n_indice_trn = n_RechTrn(ptb_InRec_Cur[FTECLEDR_TRNCOD_CF]);

	/* recherche de l acmtrs */
	n_acmtrs_cf = Ktbd_FBOTRSLNK[n_indice_trn].ACMTRSL2_NT;
	sprintf( sz_buf1 , "%d", n_acmtrs_cf);
    strcpy(Ksz_ACMTRS_CF, sz_buf1);

	/* ancienne version */
	/* n_acmtrs_cf = n_RechTrnOld(ptb_InRec_Cur[FTECLEDR_TRNCOD_CF]);
	sprintf( sz_buf1 , "%d", n_acmtrs_cf);
	strcpy(Ksz_ACMTRS_OLD, sz_buf1); */


    /*if (n_acmtrs_cf != -1)*/
	if ( n_indice_trn != -1 )
    {
      /* recherche de la filiale du retrocessionnaire */
      strncpy(sz_SSD_CF_r, Ktbd_SsdActr[Kn_SsdActr_Indice].CTR_NF, 2);
      n_ssd_cf = atoi(sz_SSD_CF_r);
      sprintf(sz_SSD_CF_r, "%d", n_ssd_cf);

      /* recherche de la nature du poste ventile IO */
      i = Ktbd_FBOTRSLNK[n_indice_trn].TRSTYP_NT ;
      j = Ktbd_FBOTRSLNK[n_indice_trn].ESTIM_NT ;
      strcpy ( sz_Poste , Ksz_LibellesPoste[i][j] ) ;
      /* ancienne methode */
      /* sprintf(sz_PosteOld, "%s", rech_PcpTrs_cf(ptb_InRec_Cur[FTECLEDR_TRNCOD_CF]) ); */

      /* filtre des montants en decimal */
      montant=atof(ptb_InRec_Cur[FTECLEDR_RETAMT_M]);
      sprintf(sz_montant, "%.3lf", montant);

      /* ecriture de la ligne en sortie si le poste est valide */
      if ( strcmp( sz_Poste , "ER" ) && strcmp( sz_Poste , "XX" ))
      {
          fprintf (Kp_OutputFileOUT1, "%s~%s~%s~%s~%s~%s~%s~%u~%u~%d~%u~%s~%s~%s~%s\n",
                 ptb_InRec_Cur[FTECLEDR_SSD_CF],
                 sz_SSD_CF_r,
                 sz_montant,
                 Ksz_ACMTRS_CF,
                 sz_Poste,
                 ptb_InRec_Cur[FTECLEDR_RETCUR_CF],
                 Ktbd_SsdActr[Kn_SsdActr_Indice].CTR_NF,
                 Ktbd_SsdActr[Kn_SsdActr_Indice].END_NT,
                 Ktbd_SsdActr[Kn_SsdActr_Indice].SEC_NF,
                 Ktbd_SsdActr[Kn_SsdActr_Indice].UWY_NF,
                 Ktbd_SsdActr[Kn_SsdActr_Indice].UW_NT,
                 ptb_InRec_Cur[FTECLEDR_RETCTR_NF],
                 ptb_InRec_Cur[FTECLEDR_RETSEC_NF],
                 ptb_InRec_Cur[FTECLEDR_RTY_NF],
                 ptb_InRec_Cur[FTECLEDR_PLC_NT]
               );
      }
      else
      {
      	 /*sprintf(sz_message,"Probleme sur le poste: retctr=%s, trncod=%s, poste=%s, TRSTYP_NT=%d, ESTIM_NT=%d",ptb_InRec_Cur[FTECLEDR_RETCTR_NF],ptb_InRec_Cur[FTECLEDR_TRNCOD_CF], sz_Poste, i, j );
      	 n_WriteAno(sz_message);*/
      }
    }
    else
	{
	  sprintf(sz_message,"Pas de trncod correspondant dans Ktbd_FBOTRSLNK: retctr=%s, trncod=%s",ptb_InRec_Cur[FTECLEDR_RETCTR_NF],ptb_InRec_Cur[FTECLEDR_TRNCOD_CF]);
	  n_WriteAno(sz_message);
    }
  }
  return OK;
}


/*==============================================================================
objet :
 fonction de recherche du trncod
retour :
 0---> Pas de rupture
 < 0     ---> On n'est pas arrive au bloc synchrone
 > 0     ---> On a depasse le bloc synchrone
==============================================================================*/
/* int n_RechTrnOld(char *sz_trn)
{
        int i;

        DEBUT_FCT("n_RechTrnOld");


        for ( i = 0; i <  Kn_TRSLNK ; i++ )
        {
                if ( strcmp( sz_trn, Ktbd_TRSLNK[i].DETTRS_CF ) == 0 )
                   return Ktbd_TRSLNK[i].ACMTRS_NT;
        }

        RETURN_VAL(-1);
} */


/*==============================================================================
objet :
 fonction de recherche du trncod
retour :
 0---> Pas de rupture
 < 0     ---> On n'est pas arrive au bloc synchrone
 > 0     ---> On a depasse le bloc synchrone
==============================================================================*/
int n_RechTrn(char *sz_trn)
{
        int i;

        DEBUT_FCT("n_RechTrn");


        for ( i = 0; i <  Kn_FBOTRSLNK ; i++ )
        {
                if ( strcmp( sz_trn, Ktbd_FBOTRSLNK[i].DETTRS_CF ) == 0 )
                   RETURN_VAL(i);
        }

        RETURN_VAL(-1);
}

/*==============================================================================
objet :
  Chargement du tableau FBOTRSLNK
retour :
  Taille du tableau
==============================================================================*/
int n_ChargerFBOTRSLNK()
{
  int i = 0 ;

  DEBUT_FCT("n_ChargerFBOTRSLNK");

  while (fread(&Ktbd_FBOTRSLNK[i], sizeof(T_FBOTRSLNK), 1, Kp_FBOTRSLNK) == 1)
    {
       i += 1 ;
       if ( i > Kn_MaxLigFBOTRSLNK )
         {
            n_WriteAno("Depassement de capacite du tableau");
            RETURN_VAL(-1);
         }

    }
  if ( i == 0 )
  {
     n_WriteAno("Fichier FBOTRSLNK vide");
     RETURN_VAL(-1);
  }
  RETURN_VAL(i);
}

/*==============================================================================
objet :
  Chargement du tableau TRSLNK ancienne version
retour :
  Taille du tableau
==============================================================================*/
/*int n_ChargerTRSLNK(short s_TrtCod)
{
  int i = 0 ;

  DEBUT_FCT("n_ChargerTRSLNK");

  while (fread(&Ktbd_TRSLNK[i], sizeof(T_TRSLNK), 1, Kp_TRSLNK) == 1)
    {
       if (Ktbd_TRSLNK[i].PRS_CF == s_TrtCod)
          i += 1 ;
       if ( i > Kn_MaxLigTRSLNK )
         {
            n_WriteAno("Depassement de capacite du tableau");
            RETURN_VAL(-1);
         }

    }
  if ( i == 0 )
  {
     n_WriteAno("Pas de poste 750 dans le fichier FTRSLNK");
     RETURN_VAL(-1);
  }
  RETURN_VAL(i);
}*/


/*==============================================================================
objet :
       Determination du poste 750 ventile

retour :
		String[3]; poste ventile, "  " si pas de correspondance

==============================================================================*/
/*const char* rech_PcpTrs_cf(char *dettrs_cf)
{
  char sz_tmp[3];
  int suffixe;
  int prefixe;
  int fin_poste1;
  int fin_poste2;
  int pos;


   determination du suffixe
  sz_tmp[0]='\0';
  strncpy(sz_tmp, dettrs_cf+7, 1);
  sz_tmp[1]='\0';
  suffixe = atoi(sz_tmp);

   determination du type de poste
  sz_tmp[0]='\0';
  pos = strlen(Ksz_ACMTRS_CF) -1;
  strncpy(sz_tmp, Ksz_ACMTRS_CF + pos, 1);
  sz_tmp[1]='\0';
  fin_poste1 = atoi(sz_tmp);
  sz_tmp[0]='\0';
  strncpy(sz_tmp, Ksz_ACMTRS_CF + pos-1, 2);
  sz_tmp[2]='\0';
  fin_poste2 = atoi(sz_tmp);

   determination du prefixe
  sz_tmp[0]='\0';
  strncpy(sz_tmp, dettrs_cf+1, 1);
  sz_tmp[1]='\0';
  prefixe = atoi(sz_tmp);

  switch (prefixe)  types selectionnes 1 4 7
  {
     case 7: return "SO";  Service ouverture
             break;

     case 4: return "SC";  Service cloture
             break;

     case 1: if ( (suffixe==2) || (suffixe==4) || (suffixe==6) )
               return "EC";   Estimes cloture
             if ( (suffixe==3) || (suffixe==5) || (suffixe==7) )
               return "EO";   Estimes ouverture
             if (suffixe == 0)
             {
                if (fin_poste2 == 1)
                  return " D";   Definitif cedante
                if ( (fin_poste1==3) || (fin_poste1==5) ||(fin_poste1==7) || (fin_poste1==9) || (fin_poste2==11) )
                  return "DC";   Definitif cloture
             }
              if ( (suffixe == 0) || (suffixe == 1) )
              {
                  if ( (fin_poste1==2) || (fin_poste1==4) ||(fin_poste1==6) || (fin_poste1==8) || (fin_poste2==10) )
                      return "DO";   Definitif ouverture
		      }
              break;

   }

    si pas de correspondance trouvee, retour d'une chaine vide
   return "  ";

}*/





/*==============================================================================
objet :
        fonction de chargement du fichier binaire des correspondances retro vers
acceptation

retour :        le nombre d'enregistrements charges dans le tableau

==============================================================================*/
int n_ChargerSSDACTR( void )
{
	int i = 0;

        DEBUT_FCT( "n_ChargerSSDACTR" ) ;
		/* i=fread( Ktbd_SsdActr, sizeof( T_SSDACTR ), MAX_SSDACTR, Kp_InputFilSsdActr ); */

		 while (fread(&Ktbd_SsdActr[i], sizeof(T_SSDACTR), 1, Kp_InputFilSsdActr) == 1)
		    {
		       i += 1 ;
		       if ( i > MAX_SSDACTR )
		         {
		            n_WriteAno("Depassement de capacite du tableau SSDACTR");
		            RETURN_VAL(-1);
		         }

		    }


		 if ( i == 0 )
		 {
		     n_WriteAno("Pas d'enregistrement dans le fichier FSSDACTR");
		     RETURN_VAL(-1);
         }
        RETURN_VAL( i ) ;
}




/*==============================================================================
objet :
        fonction de recherche des correspondances retro vers acceptation

retour :        le numero de poste dans le tableau si la fonction a trouve
                sinon -1
==============================================================================*/
int n_RechercheSSDACTR( char *RetCtr, short Rty, long Plc, unsigned char RetSec )
{
        int i, ret1, ret2, ret3, ret4;

        for ( i = 0; i < Kn_SsdActr_Nbp; i++ )
        {
                ret1 = strcmp( RetCtr, Ktbd_SsdActr[i].RETCTR_NF ) ;
                if ( ret1 == 0 )
                {
                        ret2 = Rty - Ktbd_SsdActr[i].RTY_NF ;
                        if ( ret2 == 0 )
                        {
                            ret3 = Plc - Ktbd_SsdActr[i].PLC_NT ;
                            if ( ret3 == 0 )
                                {
                                ret4 = RetSec - Ktbd_SsdActr[i].RETSEC_NF ;
                                   if ( ret4 == 0 )
                                                return ( i ) ;
                                       else if ( ret4 < 0 ) return( -1 ) ;
                                }
                                else if ( ret3 < 0 ) return( -1 ) ;
                        }
                        else if ( ret2 < 0 ) return( -1 ) ;
                }
                else if ( ret1 < 0 ) return( -1 ) ;
        }

        return( -1 ) ;
}

