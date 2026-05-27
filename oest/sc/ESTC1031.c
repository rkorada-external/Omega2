/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : SHERPA
nom du source                 : ESTC1031.c
revision                      : $Revision:   1.1  $
date de creation              : 07/1998
auteur                        : L.Capomazza
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
description :
	Traitement des codifications SHERPA
	Conversions des monnaies

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	19/7/1999		ANB			Modification temporaire : suppression utilisation fichier SUBSID
	19/7/1999		ANB			Modification conversion en EURO au lieu de ITL
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <ESTC1031.h>
#include <estserv.h>

#define NB_SSD_MAX      150	/*Nbre max de filiales*/

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

typedef struct {
                  unsigned char SSD;         /* filiale */
                  char          LAG;         /* Langue filiale */
	          char		LIBSSD[17];  /* Libelle Filiale */
		  char		LIBCUR[4];   /* Libelle monnaie */
	       } T_LIB_SSD;


T_RUPTURE_VAR Kbd_Rupt;
FILE *Kp_GolIFil;
FILE *Kp_GoelPeopOFil;
FILE *Kp_Cours;
FILE *Kp_Libelle;
char sz_montant[30];
		
T_LIB_SSD Kbd_Lib[NB_SSD_MAX];

int Kpn_ind[NB_SSD_MAX];

/*---------------------------*/
/* Declaration des fonctions */
/*---------------------------*/

int n_InitPeop(T_RUPTURE_VAR  *pbd_Rupt);
int n_ActionLignePeop(char **ptb_InRec_Cur);
int n_DecodBrche(char **ptb_InRec_Cur);
int n_DecodNat(char **ptb_InRec_Cur);
int n_DecodRetro(char **ptb_InRec_Cur);
int n_DecodPste(char **ptb_InRec_Cur);
int n_ChgTaf(char **ptb_InRec_Cur);
/*static int n_ChargLib(FILE *p_Libelle) ;*/
int n_conversion(char **ptb_InRec_Cur);
int n_Write_out(char **ptb_InRec_Cur);
int n_sensnorm(char **ptb_InRec_Cur, char c);

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
	ExitPgm (ERR_XX , "");
	
  if (n_OpenFileAppl("ESTC1031_I1","rt",&Kp_GolIFil) == ERR )
	 ExitPgm ( ERR_XX , "" ); 

  /* Modification temporaire ANB le 19/7/99 */
  /* Suppression utilisation du fichier SUBSID */       
	
  /*if (n_OpenFileAppl ("ESTC1031_I2","rb",&Kp_Libelle) == ERR)
    exit(ERR);*/

  if (n_OpenFileAppl("ESTC1031_I3","rb",&Kp_Cours) == ERR )
	ExitPgm ( ERR_XX , "" ); 

  /*if (n_ChargLib(Kp_Libelle) == ERR) 
    exit(ERR); */

  if (n_OpenFileAppl("ESTC1031_O1","wt",&Kp_GoelPeopOFil) == ERR )
	ExitPgm ( ERR_XX , "" );
    
	n_InitPeop(&Kbd_Rupt);
	  
  /*traitement*/

  if (n_ProcessingRuptureVar(&Kbd_Rupt)==ERR)
    ExitPgm (ERR_XX , "erreur rupture");
  
  if (n_CloseFileAppl("ESTC1031_I1",&(Kbd_Rupt.pf_InputFil)) == ERR)
    ExitPgm (ERR_XX ,"erreur ESTC_I1");
    
  /*if (n_CloseFileAppl("ESTC1031_I2",&Kp_Libelle) == ERR)
    ExitPgm (ERR_XX ,"");*/

  if (n_CloseFileAppl("ESTC1031_O1",&Kp_GoelPeopOFil) == ERR)
    ExitPgm (ERR_XX ,"erreur fermeture ESTC_O1");
    
  if (n_CloseFileAppl("ESTC1031_I3",&Kp_Cours) == ERR)
    ExitPgm (ERR_XX ,""); 
   
  if (n_EndPgm() == ERR)
    ExitPgm (ERR_XX , "");
  
  exit(OK) ;
  }
/*=============================================================================
 objet: Initialisation Rupture : 0 rupture 
=============================================================================*/
int n_InitPeop(T_RUPTURE_VAR  *pbd_Rupt)
{
  
  DEBUT_FCT("n_InitPeop");

  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

  /* Ouverture du fichier maitre */
  if (n_OpenFileAppl ("ESTC1031_I1","rt",&(pbd_Rupt->pf_InputFil))){
	printf("Erreur ouverture ESTC1031_I1_n");
  	RETURN_VAL (ERR); 
}

  /* Gestion de rupture */
  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->c_Separ = '~';

  /* Fonction executee pour chaque ligne : */
  pbd_Rupt->n_ActionLigne = n_ActionLignePeop;

  

  RETURN_VAL (0);
}

/*=======================================================================================

========================================================================================*/ 
int n_ActionLignePeop(char **ptb_InRec_Cur)
{	
	char c;

	if ( ( ptb_InRec_Cur[TECLEDA_SSD_CF][0] == '4' ) && ( strcmp(psz_GetCharArgv(1),"19980630") == 0 ) ) 
		c = 'A'; /* pour ce bilan et pour la filiale 4 le sens normal est celui de l'acceptation */
	else c = 'R';	

	if ( ( n_DecodBrche(ptb_InRec_Cur) == OK ) 
	&& ( n_DecodNat(ptb_InRec_Cur) == OK ) 
	&& ( n_sensnorm(ptb_InRec_Cur,c) == OK )
	&& ( n_DecodPste(ptb_InRec_Cur) == OK ) 
	&& ( n_ChgTaf(ptb_InRec_Cur) == OK ) 
	&& ( n_DecodRetro(ptb_InRec_Cur) == OK ) 
	&& ( n_conversion(ptb_InRec_Cur) == OK ) ) 
 			n_Write_out(ptb_InRec_Cur); 

/* && ( n_sensnorm(ptb_InRec_Cur,c) == OK ) */
RETURN_VAL(0);
}        

/*=============================================================================
 objet: Decodification de la branche

 retour: OK  si aucun probleme
	 ERR sinon  
=============================================================================*/
int n_DecodBrche(char **ptb_InRec_Cur)
{
	char lob[2];

	int i;
	int Local_lob;
	
	for ( i=0 ; i<2 ; i++ ) lob[i] = ptb_InRec_Cur[TECLEDA_LOBACC_CF][i+2];
	lob[i] = '\0';
	Local_lob = atoi(lob);
	
	switch(ptb_InRec_Cur[TECLEDA_LOBACC_CF][0]) {

	case 'P' : {
		switch(Local_lob) {
			case 11 :  ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "incendie";
				break;
			case 21 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "catastrophe";
				break;	
			case 31 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "bris.machine";
				break;	
			case 32 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "risq.agricol";
				break;	
			case 33 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "auto.ct";
				break;	
			case 34 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "accident.div";
				break;	
			case 35 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "risq.specia";
				break;	
			case 30 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "accident";
				break;	
			case 41 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "decennale";
				break;	
			case 42 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "trc.trm";
				break;	
			case 40 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "construction";
				break;	
			case 00 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "dommages";
				break;	
			default : RETURN_VAL(ERR) ;
			}
		}
		break;
	case 'C' : {
		switch(Local_lob) {
			case 11 :  ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "auto.lt";
				break;
			case 12 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "resp.civile";
				break;	
			case 13 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "accd.travail";
				break;	
			case 00 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "responsab";
				break;	
			default : RETURN_VAL(ERR) ;
			}
		}
		break;
	case 'S' : {
		if ( Local_lob != 11 ) RETURN_VAL(ERR);
		ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "cdt.caution";
		}	
		break;
	case 'M' : {
		switch(Local_lob) {
			case 11 :  ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "ass.transp";
				break;
			case 12 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "offshore";
				break;	
			case 00 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "transport";
				break;	
			default : RETURN_VAL(ERR) ;
			}
		}
		break;
	case 'L' : {
		switch(Local_lob) {
			case 11 :  ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "vie.epargne";
				break;
			case 21 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "vie.deces";
				break;	
			case 31 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "vie.financmt";
				break;	
			case 32 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "vie.lissage";
				break;	
			case 33 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "vie.fronting";
				break;	
			case 34 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "vie.affparti";
				break;	
			case 30 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "vie.speciale";
				break;	
			case 41 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "vie.accident";
				break;	
			case 42 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "vie.invalide";
				break;	
			case 43 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "vie.maladie";
				break;	
			case 44 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "vie.chomage";
				break;	
			case 45 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "vie.depend";
				break;	
			case 40 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "vie.autre";
				break;	
			case 00 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "vie";
				break;	
			default : ;
			}
		}
		break;
	case 'A' : {
		switch(Local_lob) {
			case 11 :  ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "ass.aviation";
				break;
			case 12 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "espace";
				break;	
			case 00 : {
				if ( ptb_InRec_Cur[TECLEDA_SSD_CF][0] == '4' )
				ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "vie.deces";
				else ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "incendie"; 
				}
				break;	
			default : RETURN_VAL(ERR);
			}
		}
		break;
	case 'O' : {
		if ( Local_lob != 11 ) RETURN_VAL(ERR);
		ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "ass.autres";
		}
		break;
	default : RETURN_VAL(ERR) ;
	}
RETURN_VAL(OK);
}

/*=============================================================================
 objet: Decodification de la nature

 retour: OK  si aucun probleme
	 ERR sinon
=============================================================================*/
int n_DecodNat(char **ptb_InRec_Cur)
{
	switch(ptb_InRec_Cur[TECLEDA_NATACC_CF][0]) {
	
	case 'N' : ptb_InRec_Cur[TECLEDA_NATACC_CF] = "nprop";
		break;
	case 'P' : ptb_InRec_Cur[TECLEDA_NATACC_CF] = "prop";
		break;
	default  : RETURN_VAL(ERR) ;
	}
RETURN_VAL(OK);
}

/*=============================================================================
 objet: Decodification du poste

 retour: OK  si aucun probleme
	 ERR sinon
=============================================================================*/
int n_DecodPste(char **ptb_InRec_Cur)
{
	int Local_pst;

	Local_pst = atoi(ptb_InRec_Cur[TECLEDA_TRNCOD_CF]);

	switch(Local_pst) {

	case 1  : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "prime.emise";	
		break;
	case 2  : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "Ent.portf.pr";
		break;
	case 3  : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "Ret.portf.pr";
		break;
	case 4  : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "rec.ouvertur";
		break;
	case 5  : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "rec.cloture";
		break;
	case 6  : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "prime.acquis";
		break;
	case 7  : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "sinist.payes";
		break;
	case 8  : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "E.portf.sin";
		break;
	case 9  : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "R.portf.sin";
		break;
	case 10 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "sap.ouvertur";
		break;
	case 11 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "sap.cloture";
		break;
	case 12 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "IBNR.ouvert";
		break;
	case 13 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "IBNR.cloture";
		break;
	case 14 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "prov.cpl.ouv";
		break;
	case 15 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "prov.cpl.clo";
		break;
	case 16 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "sin.encourue";
		break;
	case 17 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "com.payees";
		break;
	case 18 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "dac.ouvertur";
		break;
	case 19 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "dac.cloture";
		break;
	case 20 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "com.encourue";
		break;
	case 21 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "surcommiss";
		break;
	case 22 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "result.techn";
		break;
	default : RETURN_VAL(ERR);
	}
RETURN_VAL(OK);
}

/*=============================================================================
 objet: Fonction de traitement du type d'affaires

 retour: OK  --> Ecriture des changements sur sortie
	 ERR --> Affichage des messages d'erreurs sur stdin  
=============================================================================*/
int n_ChgTaf(char **ptb_InRec_Cur)
{
	switch(ptb_InRec_Cur[TECLEDA_CTRNAT_CF][0]) {

	case 'T' : ptb_InRec_Cur[TECLEDA_CTRNAT_CF] = "traite";
			break;
	case 'Z' : ptb_InRec_Cur[TECLEDA_CTRNAT_CF] = "traite";
			break;
	case 'W' : ptb_InRec_Cur[TECLEDA_CTRNAT_CF] = "traite";
			break;
	case 'F' : ptb_InRec_Cur[TECLEDA_CTRNAT_CF] = "fac";
			break;
	default  : RETURN_VAL(ERR);
	}
RETURN_VAL(OK);
}

/*=============================================================================
 objet: Fonction de traitement du type de retro

 retour: OK  --> Ecriture des changements sur sortie
	 ERR --> Affichage des messages d'erreurs sur stdin  
=============================================================================*/
int n_DecodRetro(char **ptb_InRec_Cur)
{
	switch(ptb_InRec_Cur[TECLEDA_TOP_RTO][0]) {
	
	case 'T' : ptb_InRec_Cur[TECLEDA_TOP_RTO] = "retro";
			break;
	case 'S' : {
		if ( ptb_InRec_Cur[TECLEDA_TOP_RTO][4] == 'P' )
		ptb_InRec_Cur[TECLEDA_TOP_RTO] = "ret.sa";
		else 
		ptb_InRec_Cur[TECLEDA_TOP_RTO] = "ret";
		}
			break;
	default : RETURN_VAL(ERR);
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
/*=======================================================================================
objet  : conversion en monnaies des filiales

retour : OK
========================================================================================*/ 
int n_conversion(char **ptb_InRec_Cur)
{
	double  d_montant,d_taux;

        d_montant=atof(ptb_InRec_Cur[TECLEDA_AMT_M]);

	/* Modification ANB le 19/7/99 */
	/* Conversion systématique */

	/*if ( strcmp(ptb_InRec_Cur[TECLEDA_CUR_CF],Kbd_Lib[local_fil].LIBCUR) != 0 ) */
	/*{*/

	d_taux=d_GetTaux(Kp_Cours,
			(char) atoi(ptb_InRec_Cur[TECLEDA_SSD_CF]),
			(short) atoi(ptb_InRec_Cur[TECLEDA_BALSHEY_NF]),
			ptb_InRec_Cur[TECLEDA_CUR_CF],
			0);
	
	        /* Si le taux est trouve, conversion*/
                if (d_taux>0) 
				{
					d_montant *= d_taux;
	        	}	
		/* Sinon, montant mis a -1 */
                else d_montant = -1;
	/*}*/
	
	/* Modification ANB le 19/7/99 */
	/* Plus de conversion en ITL mais en EURO */

	/*if ( ptb_InRec_Cur[TECLEDA_SSD_CF][0] == '6' )
				d_montant /= 1000;*/

	sprintf(sz_montant,"%.3lf",d_montant);
	ptb_InRec_Cur[TECLEDA_AMT_M] = sz_montant;
	RETURN_VAL(OK);
}

/*=============================================================================
 objet:  Procedure d'ecriture dans le fichier sortie

=============================================================================*/
int n_Write_out(char **ptb_InRec_Cur) 
{
	fprintf(Kp_GoelPeopOFil,"%s~%s.%s~%s~%s~%s~%s~%s\n",
        	       		ptb_InRec_Cur[TECLEDA_SSD_CF],
				ptb_InRec_Cur[TECLEDA_CTRNAT_CF],
				ptb_InRec_Cur[TECLEDA_NATACC_CF],
                		ptb_InRec_Cur[TECLEDA_TOP_RTO],
				ptb_InRec_Cur[TECLEDA_LOBACC_CF],
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF],
				ptb_InRec_Cur[TECLEDA_AMT_M],
				"");
	RETURN_VAL(OK);
}

/*=============================================================================
objet  : affectation du sens normal sur les postes
retour : OK  --> Acceptation et Retrocession
	 ERR --> Net
=============================================================================*/
int n_sensnorm(char **ptb_InRec_Cur, char c)
{
	int poste = atoi(ptb_InRec_Cur[TECLEDA_TRNCOD_CF]);
	double montant = atof(ptb_InRec_Cur[TECLEDA_AMT_M]);

	switch(c) {

	case 'A' : if ( ( poste == 3 )
		   || ( poste == 5 )
		   || ( poste == 7 )
		   || ( poste == 9 )
		   || ( poste == 11 )
		   || ( poste == 13 )
		   || ( poste == 15 )
		   || ( poste == 17 )
		   || ( poste == 18 ) 
		   || ( poste == 21 ) )
		   montant *= -1;
		break;
	case 'R' : if ( ( poste == 1 )
		   || ( poste == 2 )
		   || ( poste == 4 )
		   || ( poste == 8 )
		   || ( poste == 10 )
		   || ( poste == 12 )
		   || ( poste == 14 )
		   || ( poste == 19 ))
			   montant *= -1;
		break;
	default  : RETURN_VAL(ERR);
	}
	sprintf(sz_montant,"%.3lf",montant);
	ptb_InRec_Cur[TECLEDA_AMT_M] = sz_montant;
	RETURN_VAL(OK);	
}
