/*==============================================================================
 Nom de l'application          : ESTIMATION
 Nom du source                 : ESTC0012.c
 Revision                      : $Revision: 1.1.1.1 $
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
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
[002] 29/05/2012  Roger Cassis  :spot:23816 incrementation du nb de postes Kn_MaxLigTCLIENT a 1000
[003] 22/11/2018  L.ELFAHIM     :spot:73341 Ajout valeur SC dans le tableau
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include "struct.h"


/*---------------------------------------*/
/* Inclusion de l'interface du composant */
/*---------------------------------------*/
#include "ESTC0012.h"


/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*---------------------------------------------*/
  char Ksz_ACMTRS_CF[8];
  char *Ksz_LibellesPoste[4][4];	/* Tableau contenant les valeurs des differents libelles de poste */

  int Kn_FBOTRSLNK ;   		/* compteur du nombre ligne chargees dans Ktbd_FBOTRSLNK */
  int Kn_TCLIENT ;   		/* compteur du nombre ligne chargees dans Ktbd_TCLIENT */
  int Kn_old_ced_nf = 0; 	/* stocke le ced_nf precedent */
  int Kn_PrevPos = 0; 		/* index précédent du clissd dans le tableau Ktbd_TCLIENT */


int n_ChargePoste();

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
  if (n_InitFCLEDA(&Kbd_ruptFCLEDA)) ExitPgm(ERR_XX, "");

  /* Ouverture des fichiers binaires et des fichiers de sortie */
  if (n_OpenFileAppl("ESTC0012_I2", "rb", &Kp_FBOTRSLNK) == ERR) ExitPgm(ERR_XX ,"");
  if (n_OpenFileAppl("ESTC0012_I3", "rb", &Kp_TCLIENT) == ERR) ExitPgm(ERR_XX ,"");

  if (n_OpenFileAppl("ESTC0012_O1", "wt", &Kp_OutputFileOUT1) == ERR) ExitPgm(ERR_XX ,"");

  /* Chargement du tableau TRSLNK pour les postes 750 */
  Kn_FBOTRSLNK = n_ChargerFBOTRSLNK();
    if ( Kn_FBOTRSLNK == -1 )
    		ExitPgm( ERR_XX , "Taille tableau FBOTRSLNK insuffisante " ) ;


  /* Chargement des type de poste */
  n_ChargePoste();

  /* Chargement du tableau TRSLNK pour les postes 750 */
  Kn_TCLIENT = n_ChargerTCLIENT();
  if ( Kn_TCLIENT == -1 ) ExitPgm(ERR_XX ,"");

  /* Lancement du traitement du fichier Maitre */
  if (n_ProcessingRuptureVar(&Kbd_ruptFCLEDA) == ERR) ExitPgm(ERR_XX, "");

  /* Fermeture des fichiers ouverts */
  if (n_CloseFileAppl("ESTC0012_I1", &(Kbd_ruptFCLEDA.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl("ESTC0012_I2", &Kp_FBOTRSLNK) == ERR) ExitPgm(ERR_XX, "");

  if (n_CloseFileAppl("ESTC0012_O1", &Kp_OutputFileOUT1)) ExitPgm(ERR_XX, "");

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
	 Ksz_LibellesPoste[1][3] = "SC" ; /* Service cloture [003] */
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
int n_InitFCLEDA(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

  if (n_OpenFileAppl("ESTC0012_I1","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 1;
  pbd_Rupt->n_ConditionRupture[0] = n_IsR1FCLEDA;
  pbd_Rupt->n_ActionLigne = n_ActionLigneFCLEDA;
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
int n_IsR1FCLEDA(char **pbd_InRec, char **pbd_InRec_Cur)
{
  int ret ;

  DEBUT_FCT("n_IsR1FCLEDA");

  if ((ret = strcmp(pbd_InRec[FTECLEDA_CTR_NF], pbd_InRec_Cur[FTECLEDA_CTR_NF])) != 0 ) RETURN_VAL(ret);
  if ((ret = strcmp(pbd_InRec[FTECLEDA_END_NT], pbd_InRec_Cur[FTECLEDA_END_NT])) != 0 ) RETURN_VAL(ret);
  if ((ret = strcmp(pbd_InRec[FTECLEDA_SEC_NF], pbd_InRec_Cur[FTECLEDA_SEC_NF])) != 0 ) RETURN_VAL(ret);
  if ((ret = strcmp(pbd_InRec[FTECLEDA_UWY_NF], pbd_InRec_Cur[FTECLEDA_UWY_NF])) != 0 ) RETURN_VAL(ret);
  if ((ret = strcmp(pbd_InRec[FTECLEDA_UW_NT], pbd_InRec_Cur[FTECLEDA_UW_NT])) != 0 ) RETURN_VAL(ret);
  if ((ret = strcmp(pbd_InRec[FTECLEDA_CUR_CF], pbd_InRec_Cur[FTECLEDA_CUR_CF])) != 0 ) RETURN_VAL(ret);
  if ((ret = strcmp(pbd_InRec[FTECLEDA_TRNCOD_CF], pbd_InRec_Cur[FTECLEDA_TRNCOD_CF])) != 0 ) RETURN_VAL(ret);




  RETURN_VAL(0);
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
int n_ActionLigneFCLEDA(char **ptb_InRec_Cur)
{
   char sz_buf1[8];
   char sz_Poste[3];
   char sz_Clissd[10];
   int n_acmtrs_cf;
   char sz_message[200];
   int n_indice_trn;
   int i, j;

  /* initialisation du buffer */
   strcpy ( sz_Poste , "" ) ;

  /* recherche de la correspondance dans la table TRSLNK */

  /* recherche de l indice du trncod dans le tableau Ktbd_FBOTRSLNK */
	n_indice_trn = n_RechTrn(ptb_InRec_Cur[FTECLEDA_TRNCOD_CF]);

  /* recherche de l acmtrs */
	n_acmtrs_cf = Ktbd_FBOTRSLNK[n_indice_trn].ACMTRSL2_NT;
	sprintf( sz_buf1 , "%d", n_acmtrs_cf);
    strcpy(Ksz_ACMTRS_CF, sz_buf1);


  /* recherche de la nature du poste ventile IO */
  if ( n_indice_trn != -1 )
  {
		  i = Ktbd_FBOTRSLNK[n_indice_trn].TRSTYP_NT ;
		  j = Ktbd_FBOTRSLNK[n_indice_trn].ESTIM_NT ;
		  strcpy ( sz_Poste , Ksz_LibellesPoste[i][j] ) ;

	  /* recherche de la filiale emettrice */
	  sprintf(sz_Clissd, "%d", n_RechSsds( atoi(ptb_InRec_Cur[FTECLEDA_CED_NF]) )  );

	  /* ecriture dans le fichier de sortie */
	   if ( strcmp( sz_Poste , "ER" ) && strcmp( sz_Poste , "XX" ) && strcmp( sz_Clissd, "-1" ) )
	   {
					fprintf (Kp_OutputFileOUT1, "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",
					ptb_InRec_Cur[FTECLEDA_SSD_CF],
					ptb_InRec_Cur[FTECLEDA_AMT_M],
					Ksz_ACMTRS_CF ,
					sz_Poste,
					ptb_InRec_Cur[FTECLEDA_CUR_CF],
					ptb_InRec_Cur[FTECLEDA_CTR_NF],
					ptb_InRec_Cur[FTECLEDA_END_NT],
					ptb_InRec_Cur[FTECLEDA_SEC_NF],
					ptb_InRec_Cur[FTECLEDA_UWY_NF],
					ptb_InRec_Cur[FTECLEDA_UW_NT],
					sz_Clissd
			   				);
		}
	    else
	    {
	       /* if ( strcmp( sz_Poste , "ER" ) && strcmp( sz_Poste , "XX" )  ) */
		   /*{
		   		sprintf(sz_message,"Probleme sur le poste: ctr=%s, trncod=%s, poste=%s, TRSTYP_NT=%d, ESTIM_NT=%d",ptb_InRec_Cur[FTECLEDA_CTR_NF],ptb_InRec_Cur[FTECLEDR_TRNCOD_CF], sz_Poste, i, j );
		   		n_WriteAno(sz_message);
		   	  }*/

		    if ( !strcmp( sz_Clissd, "-1" ) )
		    {
		    	sprintf(sz_message,"Emetteur non trouve: CTR_NF=%s, CED_NF=%s",ptb_InRec_Cur[FTECLEDA_CTR_NF],ptb_InRec_Cur[FTECLEDA_CED_NF]);
		    	n_WriteAno(sz_message);
		    }
        }
    }
    else
    {
  	  sprintf(sz_message,"Pas de trncod correspondant dans Ktbd_FBOTRSLNK: ctr=%s, trncod=%s",ptb_InRec_Cur[FTECLEDA_CTR_NF],ptb_InRec_Cur[FTECLEDA_TRNCOD_CF]);
  	  n_WriteAno(sz_message);
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
  Chargement du tableau TCLIENT
retour :
  Taille du tableau
==============================================================================*/
int n_ChargerTCLIENT()
{
	int i = 0;
	char sz_message[300];

	DEBUT_FCT("n_ChargerTCLIENT");

	memset(&Ktbd_TCLIENT, 0, sizeof(T_TCLIENT) );

	while (fread(&Ktbd_TCLIENT[i], sizeof(T_TCLIENT), 1, Kp_TCLIENT) == 1)
	{
		if (i > Kn_MaxLigTCLIENT)
		{
			sprintf(sz_message, "Depassement de capacite du tableau Ktbd_TCLIENT[%d]", Kn_MaxLigTCLIENT);
			n_WriteAno(sz_message);
			RETURN_VAL(-1);
		}

		i += 1 ;
	}

	if ( i == 0 )
	{
		n_WriteAno("Aucune ligne Chargee dans le tableau TCLIENT");
		/* RETURN_VAL(-1);  OG 11/06/2001, on ne stoppe plus la chaine lorsque le fichier est vide */
	}

	RETURN_VAL(i);
}


/*==============================================================================
objet :
       Determination du code filiale emettrice

retour :
		String[6];
		"" si pas de correspondance

==============================================================================*/
int n_RechSsds(int n_ced_nf)
{
	int n_CurPos;

	DEBUT_FCT("n_RechSsds");

	if ((Kn_old_ced_nf == n_ced_nf) && (Kn_PrevPos > 0))
		return Ktbd_TCLIENT[Kn_PrevPos].CLISSD_NF;

	for ( n_CurPos = 0; n_CurPos <  Kn_TCLIENT ; n_CurPos++ )
	{
		if ( Ktbd_TCLIENT[n_CurPos].CLI_NF == n_ced_nf )
		{
		   Kn_old_ced_nf = n_ced_nf;
		   Kn_PrevPos = n_CurPos;
		   return Ktbd_TCLIENT[n_CurPos].CLISSD_NF;
		}
	}

	RETURN_VAL(-1);
}



