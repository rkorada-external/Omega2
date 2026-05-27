/*==============================================================================
nom de l'application          : Rafraichissement des traites fictifs et
				des segments d'analyse pour les contrats
				acceptation
nom du source                 : ESTC2032.c
revision                      : $Revision:   1.4  $
date de creation              : 29/05/1997
auteur                        : C. Chavatte (C.G.I.)
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
	
/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

#define TraiteParDefaut 1	/* 1er bit du numero d'anomalie */
#define SegmentParDefaut 2	/* 2eme bit de ce numero */
#define TraiteModifie 4		/* 3eme bit ... */
#define SegmentModifie 8
#define PasDeTraiteParDefaut 16
#define PasDeSegmentParDefaut 32

/*----------------------*/
/* variables de travail */
/*----------------------*/

/* Fichiers en entree, en sortie */
FILE	*Kp_FFsegparFil,*Kp_FFctrficFil,
	*Kp_pericaseFil,*Kp_evolFil,*Kp_anoFil;

/* Nombre de lignes dans les fichiers en entree */
int	Kn_NbLigCtrfic=0, Kn_NbLigSegpar=0;

/* Structures de stockage des fichiers SEGPAR et CTRFIC */
#define Kn_MaxLigCTRFIC 500
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



/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
void main(int argc ,char *argv[])
{
        /* alimentation du nom en clair du programme */
        Gbd_Tech.psz_PgmLabel = "Rafraichisssement traites fictifs et segments";

	/* Initialisation des signaux */
	InitSig ();

	if ( n_BeginPgm (argc  ,argv) == ERR )
		ExitPgm ( ERR_XX , "" );

	n_InitPerimetre(&Kbd_RuptPerimetre);

	/* ouverture des fichiers en entree */
	if (n_OpenFileAppl("ESTC2032_I2","rb",&Kp_FFsegparFil) == ERR )
		ExitPgm ( ERR_XX , "" );
	if (n_OpenFileAppl("ESTC2032_I3","rb",&Kp_FFctrficFil) == ERR )
		ExitPgm ( ERR_XX , "" );

	/* ouverture des fichiers en sortie */
	if (n_OpenFileAppl("ESTC2032_O1","wt",&Kp_pericaseFil) == ERR )
		ExitPgm ( ERR_XX , "" );
	if (n_OpenFileAppl("ESTC2032_O2","wt",&Kp_evolFil) == ERR )
		ExitPgm ( ERR_XX , "" );
	if (n_OpenFileAppl("ESTC2032_O3","wt",&Kp_anoFil) == ERR )
		ExitPgm ( ERR_XX , "" );

	/* Chargement en memoire du fichier SEGPAR.dat */
	if ( n_ChargerSegpar() == ERR )
		ExitPgm ( ERR_XX , "" );

	/* Chargement en memoire du fichier CTRFIC.dat */
	if ( n_ChargerCtrfic() == ERR )
		ExitPgm ( ERR_XX , "" );

	/* Traitement principal */
        if ( n_ProcessingRuptureVar (&Kbd_RuptPerimetre) == ERR )
                ExitPgm ( ERR_XX , "" );
 
	if ( n_CloseFileAppl ("ESTC2032_I1",&(Kbd_RuptPerimetre.pf_InputFil)))
		ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl ("ESTC2032_I2",&Kp_FFsegparFil))
		ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl ("ESTC2032_I3",&Kp_FFctrficFil))
		ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl ("ESTC2032_O1",&Kp_pericaseFil))
		ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl ("ESTC2032_O2",&Kp_evolFil))
		ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl ("ESTC2032_O3",&Kp_anoFil))
		ExitPgm ( ERR_XX , "" );

	if ( n_EndPgm () == ERR )
		ExitPgm ( ERR_XX , "" );

	exit(OK) ;

}

/**************************************************************************/
/***									***/
/*** Objet :	Copie le contenu du fichier en entree dans un tableau	***/
/***									***/
/*** Nom:	n_Charger[structure]					***/
/***									***/
/*** Parametres:							***/
/***		Le pointeur du fichier					***/
/***		Le tableau de structures				***/
/***									***/
/*** Retour:								***/
/***		0							***/
/***									***/
/**************************************************************************/

int n_ChargerSegpar()
{
	int n_EOF = 0;
	T_SEGPAR bd_Lu;

	DEBUT_FCT("n_ChargerSegpar");

	/* Tant que la fin de fichier n'est pas atteinte,... */
	while (n_EOF == 0)
	{
		/* ... lecture d'une ligne dans le fichier. */
		if (fread(&bd_Lu,sizeof(T_SEGPAR),1,Kp_FFsegparFil)<=0)
			/* Fin de fichier, mise a jour du flag */
			n_EOF = 1;
		else
		{
			/* Elimination des espaces inutiles */
			StripSpaces(bd_Lu.ANLCTY_CF);
			StripSpaces(bd_Lu.CLINAT_CF);

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
	char sz_ctr[10];

	DEBUT_FCT("n_ChargerCtrfic");

	/* Tant que la fin de fichier n'est pas atteinte,... */
	while (n_EOF == 0)
	{
		/* ... lecture d'une ligne dans le fichier. */
		if (fread(&bd_Lu,sizeof(T_CTRFIC),1,Kp_FFctrficFil)<=0)
			/* Fin de fichier, mise a jour du flag */
			n_EOF = 1;
		else
		{
			/* Elimination des espaces inutiles */
			StripSpaces(bd_Lu.LIFTRTTYP_CF);

			/* Ajout de la filiale en tete du contrat	*/
			/* Petite securite: si le contrat fait		*/
			/* plus de 7 caracteres, on tronque a 7.	*/
			sprintf(sz_ctr,"%02d%7.7s",
				bd_Lu.SSD_CF, bd_Lu.ESTCTR_NF);
			strcpy(bd_Lu.ESTCTR_NF,sz_ctr);

			/* Enregistrement ecrit dans le tableau */
			Kbd_CTRFIC[Kn_NbLigCtrfic++] = bd_Lu;
		}
	}

	RETURN_VAL (0);
}

int n_ProcessingPerimetre(char **ptb_InRec_Cur)
{
	int n_ligneT,	/* Numero de la ligne Traite trouvee, -1 sinon */
	n_ligneS,	/* Numero de la ligne Segment trouvee, -1 sinon */
	n_ano=0,	/* Numero de l'anomalie eventuelle a ecrire */
	b_evol=0;	/* Indique s'il faut ecrire une evolution */
	char sz_ctr[50]="",/* Traite a ecrire dans les evolutions */
	sz_ord[50]="";	/* Segment a ecrire dans les evolutions */

	DEBUT_FCT("n_ProcessingPerimetre");

/*printf("Crible: %s, unite: %s, pays: %s.\n",
ptb_InRec_Cur[PER_ESTCRB_CT],
ptb_InRec_Cur[PER_UWGRP_CF],
ptb_InRec_Cur[PER_ANLCTY_CF]);*/
	/* Si la section est acceptee/definitive/renouvelee/resiliee	*/
	/* et que le contrat est non termine comptablement,		*/
	if ( (strstr("14 16 17 19",ptb_InRec_Cur[PER_SECSTS_CT])!=NULL) &&
	     (atoi(ptb_InRec_Cur[PER_SECACCSTS_CT])!=9) )
	{
		/* Si le traite est non crible, recherche du traite rattache */
		if (ptb_InRec_Cur[PER_ESTCRB_CT][0]=='N')
		{
			/* Recherche d'une ligne dans les traites fictifs ou
			   [filiale, [unite et pays, [type de traite vie]]]
			   correspondent. */
			n_ligneT=n_RechCtrfic(ptb_InRec_Cur);
/*printf("La recherche retourne la ligne %d\n",n_ligneT);*/

			/* Si aucune ligne ne correspond, avertir que */
			/* le traite par defaut n'a pas ete cree      */
			if (n_ligneT==-1) n_ano+=PasDeTraiteParDefaut;
			else
			/* Si une ligne est trouvee */
			{
				/* Si seule la filiale est renseignee,	*/
				/* anomalie "Traite par defaut"		*/
				if (
				(strcmp(Kbd_CTRFIC[n_ligneT].ANLCTY_CF,"AAA"))
				|| (Kbd_CTRFIC[n_ligneT].UWGRP_CF==0)
				   )
					n_ano+=TraiteParDefaut;

				/* Si le traite a change, le signaler */
				if (strcmp(ptb_InRec_Cur[PER_ESTCTR_NF],
				Kbd_CTRFIC[n_ligneT].ESTCTR_NF) != 0)
					n_ano+=TraiteModifie;
			}
		}

		/* Recherche du segment d'analyse */
		n_ligneS=n_RechSegpar(ptb_InRec_Cur);
/*printf("La recherche retourne la ligne %d\n",n_ligneS);*/

		/* Si aucune ligne ne correspond, avertir que */
		/* le segment par defaut n'a pas ete cree     */
		if (n_ligneS==-1) n_ano+=PasDeSegmentParDefaut;
		else
		/* Si une ligne est trouvee */
		{
			/* Si seule la filiale est renseignee,	*/
			/* anomalie "Segment par defaut"	*/
			if ( (strcmp(Kbd_SEGPAR[n_ligneS].ANLCTY_CF,"AAA")==0)
			|| (Kbd_SEGPAR[n_ligneS].UWGRP_CF==0) )
				n_ano+=SegmentParDefaut;

			/* Si le segment a change, le signaler */
			if (strcmp(ptb_InRec_Cur[PER_SEG_NF],
			Kbd_SEGPAR[n_ligneS].SEG_NF)!=0)
				n_ano+=SegmentModifie;
		}


		/* Si le traite a change, */
		/* - le traite du perimetre doit etre rafraichi */
		/* - une evolution doit etre ecrite */
		if ((n_ano&TraiteModifie)!=0)
		{
			strcpy(sz_ctr,Kbd_CTRFIC[n_ligneT].ESTCTR_NF);
			StripSpaces(sz_ctr);
			ptb_InRec_Cur[PER_ESTCTR_NF]=sz_ctr;
			b_evol=1;
		}
		/* Si le segment a change, */
		/* - le segment du perimetre doit etre rafraichi */
		/* - une evolution doit etre ecrite */
		if ((n_ano&SegmentModifie)!=0)
		{
			strcpy(sz_ord,Kbd_SEGPAR[n_ligneS].SEG_NF);
			StripSpaces(sz_ord);
			ptb_InRec_Cur[PER_SEG_NF]=sz_ord;
			b_evol=1;
		}
		/* Reconduction ou rafraichissement du perimetre */
		n_WriteCols(Kp_pericaseFil,ptb_InRec_Cur,'~',0);

		/* Ecriture des anomalies rencontrees */
		n_EcrireAno(n_ano,ptb_InRec_Cur);

		/* Ecriture d'une evolution */
		if (b_evol==1)
		fprintf(Kp_evolFil,"%s~%s~%s~%s~%s~%s~%s\n",
		ptb_InRec_Cur[PER_CTR_NF],ptb_InRec_Cur[PER_UWY_NF],
		ptb_InRec_Cur[PER_UW_NT],ptb_InRec_Cur[PER_END_NT],
		ptb_InRec_Cur[PER_SEC_NF],sz_ctr,sz_ord);
	}
	RETURN_VAL (0);
}


/**************************************************************************/
/*** Objet:	Recherche une ligne du tableau de structures ou les	***/
/***		champs correspondent aux parametres en entree.		***/
/***									***/
/*** Nom:	n_Rech[structure]					***/
/***									***/
/*** Parametres:							***/
/***		La ligne du tableau contenant les valeurs recherchees	***/
/***		Le nombre de lignes du tableau ou s'effectue la		***/
/***		recherche						***/
/***									***/
/*** Retour:								***/
/***		Le numero de la ligne du tableau si trouve		***/
/***		-1 si non trouve					***/
/***									***/
/**************************************************************************/

int n_RechCtrfic (char **psz_peri)
{
	int	n_indice = 0,		/* indice dans le tableau parcouru */
		b_chp1=0,b_chp2=0,	/* indiquent si le champ */
		b_chp3=0,		/* a deja ete trouve */
		n_defaut = -1;		/* traite par defaut */
	char	clefR[15],		/* clef recherchee */
		clefV[15],		/* clef en cours de verification */
		sz_ssd[3],		/* Filiale */
		sz_uwgrp[5];		/* Unite */

	DEBUT_FCT("n_RechCtrfic");

	/* Formatage de la clef recherchee */
	sprintf(clefR,"%+2.2s%+4.4s%+3.3s%+2.2s\0",
	psz_peri[PER_SSD_CF],psz_peri[PER_UWGRP_CF],
	psz_peri[PER_ANLCTY_CF],psz_peri[PER_LIFTRTTYP_CF]);

/*printf("\nLigne a trouver dans les traites:\n  SSD=%s, UWGRP=%s, Pays=%s, LIFTRTTYP=%s, CTR=%s\n  (clef: '%s')\n",psz_peri[PER_SSD_CF],psz_peri[PER_UWGRP_CF],psz_peri[PER_ANLCTY_CF],psz_peri[PER_LIFTRTTYP_CF],psz_peri[PER_CTR_NF],clefR);*/
	while (1==1)
	{
		/* Formatage de la clef en cours de verification */
		sprintf(sz_ssd,"%d",Kbd_CTRFIC[n_indice].SSD_CF);
		sprintf(sz_uwgrp,"%d",Kbd_CTRFIC[n_indice].UWGRP_CF);
		sprintf(clefV,"%+2.2s%+4.4s%+3.3s%+2.2s\0",
		sz_ssd,sz_uwgrp,
		Kbd_CTRFIC[n_indice].ANLCTY_CF,
		Kbd_CTRFIC[n_indice].LIFTRTTYP_CF);

		/* Si les champs correspondent, on a trouve le debut */
		/* du bloc. Sinon, et si on etait precedemment sur ce */
		/* bloc, alors on ne peut plus trouver la ligne. */
/*printf("Ligne verifiee no %d: SSD=%d, UWGRP=%d, Pays=%s, LIFTRTTYP=%s, CTR=%s\n  (clef: '%s')\n",n_indice,Kbd_CTRFIC[n_indice].SSD_CF,Kbd_CTRFIC[n_indice].UWGRP_CF,Kbd_CTRFIC[n_indice].ANLCTY_CF,Kbd_CTRFIC[n_indice].LIFTRTTYP_CF,Kbd_CTRFIC[n_indice].ESTCTR_NF,clefV);*/
		if (strncmp(clefR,clefV,2)==0)
		{
		  /* 1er champ trouve */
		  b_chp1=1;
/*printf("  Filiale OK.\n");*/
		  if (strncmp(clefR,clefV,6)==0)
		  {
		    /* 2eme champ trouve */
		    b_chp2=1;
/*printf("  UWGRP OK.\n");*/
		    if (strncmp(clefR,clefV,9)==0)
		    {
		      /* 3eme champ trouve */
		      b_chp3=1;
/*printf("  Pays OK.\n");*/
		      /* Si le 4eme champ correspond, retour de l'indice */
		      if (strcmp(clefR,clefV)==0)
{
/*printf("  LIFTRTTYP OK.\n");*/
			RETURN_VAL (n_indice);
}
		    } else if (b_chp3==1) RETURN_VAL (n_defaut);
		  } else if (b_chp2==1) RETURN_VAL (n_defaut);

		  /* Si au moins la filiale est trouvee et que les autres */
		  /* sont trouves ou non-renseignes, memoriser la ligne   */
		  if ( ((b_chp3==1)&&(Kbd_CTRFIC[n_indice].LIFTRTTYP_CF[0]==0))
		  || ((b_chp2==1)&&
			(strcmp(Kbd_CTRFIC[n_indice].ANLCTY_CF,"AAA")==0)&&
			(Kbd_CTRFIC[n_indice].LIFTRTTYP_CF[0]==0))
		  || ((b_chp1==1)&&(Kbd_CTRFIC[n_indice].UWGRP_CF==0)&&
			(strcmp(Kbd_CTRFIC[n_indice].ANLCTY_CF,"AAA")==0)&&
			(Kbd_CTRFIC[n_indice].LIFTRTTYP_CF[0]==0)) )
{
/*printf("  Ligne par defaut.\n");*/
		  n_defaut=n_indice;
}

		} else if (b_chp1==1) RETURN_VAL (n_defaut);

		/* Si la ligne a ete depassee, retour de la ligne par defaut */
		if (strcmp(clefR,clefV)<0) RETURN_VAL(n_defaut);

		/* Ligne suivante */
		n_indice++;

		/* Si on a depasse la fin du tableau, ligne non trouvee */
/*if (n_indice>=Kn_NbLigCtrfic) printf("Fin du tableau atteinte.\n");*/
		if (n_indice>=Kn_NbLigCtrfic) RETURN_VAL (n_defaut);
	}
}

int n_RechSegpar (char **psz_peri)
{
	int	n_indice = 0,		/* indice dans le tableau parcouru */
		b_chp1=0,b_chp2=0,	/* indiquent si le champ */
		b_chp3=0,b_chp4=0,	/* a deja ete trouve	 */
		n_defaut = -1;		/* segment par defaut */
	char	clefR[15],		/* clef recherchee */
		clefV[15],		/* clef en cours de verification */
		sz_ssd[3],
		sz_uwgrp[5],
		sz_ordnbr[3];

	DEBUT_FCT("n_RechSegpar");

	/* Formatage de la clef recherchee */
	sprintf(clefR,"%+2.2s%+4.4s%+3.3s%+3.3s%+2.2s\0",psz_peri[PER_SSD_CF],
	psz_peri[PER_UWGRP_CF],psz_peri[PER_ANLCTY_CF],
	psz_peri[PER_CLINAT_CF],psz_peri[PER_ORDNBR_NT]);

/*printf("\nLigne a trouver dans les segments:\n  SSD=%s, UWGRP=%s, Pays=%s, CLINAT=%s, ORDNBR=%s, SEG=%s \n  (clef: %s)\n",psz_peri[PER_SSD_CF],psz_peri[PER_UWGRP_CF],psz_peri[PER_ANLCTY_CF],psz_peri[PER_CLINAT_CF],psz_peri[PER_ORDNBR_NT],psz_peri[PER_SEG_NF],clefR);*/
	while (1==1)
	{
		/* Formatage de la clef a verifier */
		sprintf(sz_ssd,"%d",Kbd_SEGPAR[n_indice].SSD_CF);
		sprintf(sz_uwgrp,"%d",Kbd_SEGPAR[n_indice].UWGRP_CF);
		sprintf(sz_ordnbr,"%d",Kbd_SEGPAR[n_indice].ORDNBR_NT);
		sprintf(clefV,"%+2.2s%+4.4s%+3.3s%+3.3s%+2.2s\0",
		sz_ssd,sz_uwgrp,
		Kbd_SEGPAR[n_indice].ANLCTY_CF,
		Kbd_SEGPAR[n_indice].CLINAT_CF,sz_ordnbr);

/*printf("\nLigne verifiee no %d: SSD=%d, UWGRP=%d, Pays=%s, CLINAT=%s, ORDNBR=%d, SEG=%s\n  (clef recherchee: %s)\n  (clef verifiee:   %s)\n",n_indice,Kbd_SEGPAR[n_indice].SSD_CF,Kbd_SEGPAR[n_indice].UWGRP_CF,Kbd_SEGPAR[n_indice].ANLCTY_CF,Kbd_SEGPAR[n_indice].CLINAT_CF,Kbd_SEGPAR[n_indice].ORDNBR_NT,Kbd_SEGPAR[n_indice].SEG_NF,clefR,clefV);*/
		/* Si les champs correspondent, on a trouve le debut */
		/* du bloc. Sinon, et si on etait precedemment sur ce */
		/* bloc, alors on ne peut plus trouver la ligne. */
		if (strncmp(clefR,clefV,2)==0)
		{
		  /* 1er champ trouve */
		  b_chp1=1;
/*printf("  Filiale OK.\n");*/
		  if (strncmp(clefR,clefV,6)==0)
		  {
		    /* 2eme champ trouve */
		    b_chp2=1;
/*printf("  UWGRP OK.\n");*/
		    if (strncmp(clefR,clefV,9)==0)
		    {
		      /* 3eme champ trouve */
		      b_chp3=1;
/*printf("  Pays OK.\n");*/
		      if (strncmp(clefR,clefV,12)==0)
		      {
			/* 4eme champ trouve */
			b_chp4=1;
/*printf("  CLINAT OK.\n");*/
			/* Si tout correspond, retour de l'indice */
			if (strcmp(clefR,clefV)==0)
{
/*printf("  ORDNBR OK.\n");*/
			RETURN_VAL ( n_indice);
}
		      } else if (b_chp4==1) RETURN_VAL ( n_defaut);
		    } else if (b_chp3==1) RETURN_VAL ( n_defaut);
		  } else if (b_chp2==1) RETURN_VAL ( n_defaut);

		  /* Si au moins la filiale est trouvee et que les autres */
		  /* sont trouves ou non-renseignes, memoriser la ligne   */
		  if ( ((b_chp4==1)&&(Kbd_SEGPAR[n_indice].ORDNBR_NT==0)) 
		  || ((b_chp3==1)
			&&(atoi(Kbd_SEGPAR[n_indice].CLINAT_CF)==0)
		  	&&(Kbd_SEGPAR[n_indice].ORDNBR_NT==0))
		  || ((b_chp2==1)
			&&(strcmp(Kbd_SEGPAR[n_indice].ANLCTY_CF,"AAA")==0)
			&&(atoi(Kbd_SEGPAR[n_indice].CLINAT_CF)==0)
		  	&&(Kbd_SEGPAR[n_indice].ORDNBR_NT==0))
		  || ((b_chp1==1)&&(Kbd_SEGPAR[n_indice].UWGRP_CF==0)
			&&(strcmp(Kbd_SEGPAR[n_indice].ANLCTY_CF,"AAA")==0)
			&&(atoi(Kbd_SEGPAR[n_indice].CLINAT_CF)==0)
		  	&&(Kbd_SEGPAR[n_indice].ORDNBR_NT==0)) )
{
/*printf("  Ligne par defaut.\n");*/
		  n_defaut=n_indice;
}

		} else if (b_chp1==1) RETURN_VAL ( n_defaut);

		/* Si la ligne a ete depassee, retour de la ligne par defaut */
		if (strcmp(clefR,clefV)<0) RETURN_VAL(n_defaut);

		/* Ligne suivante */
		n_indice++;

		/* Si on a depasse la fin du tableau, ligne non trouvee */
/*if (n_indice>=Kn_NbLigSegpar) printf("Fin du tableau atteinte.\n");*/
		if (n_indice>=Kn_NbLigSegpar) RETURN_VAL ( n_defaut);
	}
}

int n_InitPerimetre(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_InitPerimetre");

	memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

	/* Ouverture du fichier maitre */
	if (n_OpenFileAppl ("ESTC2032_I1","rt",&(pbd_Rupt->pf_InputFil)))
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

	if (n_ano==0) RETURN_VAL (0);
	if ((n_ano&TraiteParDefaut) != 0)
		fprintf(Kp_anoFil,"%d~%s~%s~%s~%s~~~%s~%s\n",
		A_TraiteParDefaut,
		ptb_InRec_Cur[PER_UWGRP_CF],
		ptb_InRec_Cur[PER_CTR_NF],
		ptb_InRec_Cur[PER_SEC_NF],
		ptb_InRec_Cur[PER_UWY_NF],
		ptb_InRec_Cur[PER_PCPCUR_CF],
		ptb_InRec_Cur[PER_SSD_CF]
		);
	if ((n_ano&SegmentParDefaut) != 0)
		fprintf(Kp_anoFil,"%d~%s~%s~%s~%s~~~%s~%s\n",
		A_SegmentParDefaut,
		ptb_InRec_Cur[PER_UWGRP_CF],
		ptb_InRec_Cur[PER_CTR_NF],
		ptb_InRec_Cur[PER_SEC_NF],
		ptb_InRec_Cur[PER_UWY_NF],
		ptb_InRec_Cur[PER_PCPCUR_CF],
                ptb_InRec_Cur[PER_SSD_CF]
		);
	if ((n_ano&TraiteModifie) != 0)
		fprintf(Kp_anoFil,"%d~%s~%s~%s~%s~~~%s~%s\n",
		A_TraiteModifie,
		ptb_InRec_Cur[PER_UWGRP_CF],
		ptb_InRec_Cur[PER_CTR_NF],
		ptb_InRec_Cur[PER_SEC_NF],
		ptb_InRec_Cur[PER_UWY_NF],
		ptb_InRec_Cur[PER_PCPCUR_CF],
                ptb_InRec_Cur[PER_SSD_CF]
		);
	if ((n_ano&SegmentModifie) != 0)
		fprintf(Kp_anoFil,"%d~%s~%s~%s~%s~~~%s~%s\n",
		A_SegmentModifie,
		ptb_InRec_Cur[PER_UWGRP_CF],
		ptb_InRec_Cur[PER_CTR_NF],
		ptb_InRec_Cur[PER_SEC_NF],
		ptb_InRec_Cur[PER_UWY_NF],
		ptb_InRec_Cur[PER_PCPCUR_CF],
                ptb_InRec_Cur[PER_SSD_CF]
		);
	if ((n_ano&PasDeTraiteParDefaut) != 0)
		fprintf(Kp_anoFil,"%d~%s~%s~%s~%s~~~%s~%s\n",
		A_PasDeTraiteParDefaut,
		ptb_InRec_Cur[PER_UWGRP_CF],
		ptb_InRec_Cur[PER_CTR_NF],
		ptb_InRec_Cur[PER_SEC_NF],
		ptb_InRec_Cur[PER_UWY_NF],
		ptb_InRec_Cur[PER_PCPCUR_CF],
                ptb_InRec_Cur[PER_SSD_CF]
		);
	if ((n_ano&PasDeSegmentParDefaut) != 0)
		fprintf(Kp_anoFil,"%d~%s~%s~%s~%s~~~%s~%s\n",
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
