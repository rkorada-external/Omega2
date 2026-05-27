/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : SHERPA
nom du source                 : ESTC1033.c
revision                      : $Revision:   1.0  $
date de creation              : 07/1998
auteur                        : L.Capomazza
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
description :
	Mise en forme du fichier utilisateur Cumule par poste	

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	   ...           ...            ...              ...
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <ESTC1033.h>

#define NB_SSD_MAX      150	/*Nbre max de filiales*/
typedef struct {
                  unsigned char SSD;         /* filiale */
                  char          LAG;         /* Langue filiale */
	          char		LIBSSD[17];  /* Libelle Filiale */
		  char		LIBCUR[4];   /* Libelle monnaie */
	       } T_LIB_SSD; 
T_LIB_SSD Kbd_Lib[NB_SSD_MAX];
T_RUPTURE_VAR Kbd_Rupt;
FILE *Kp_GoelPeopOFil;
char nom_fic[90];
		
int line=1;
int n_InitPeop(T_RUPTURE_VAR  *pbd_Rupt);
int n_IsR1(char **pbd_InRec ,char **pbd_InRec_Cur);
int n_ActionLignePeop(char **ptb_InRec_Cur);
int n_ActionFirst(char **ptb_InRec_Cur);
int n_ActionLast(char **ptb_InRec_Cur);
int n_Write_out(char **ptb_InRec_Cur); 

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
	ExitPgm (ERR_XX , "erreur beginpgm");
       
	n_InitPeop(&Kbd_Rupt);
	  
  /*traitement*/

  if (n_ProcessingRuptureVar(&Kbd_Rupt)==ERR)
    ExitPgm (ERR_XX , "");
  
	
  if (n_CloseFileAppl("ESTC1043_I1",&(Kbd_Rupt.pf_InputFil)) == ERR)
    ExitPgm (ERR_XX ,"");
	
  exit(OK) ;
  }
/*=============================================================================
 objet: Initialisation Rupture : 0 rupture 
0=============================================================================*/
int n_InitPeop(T_RUPTURE_VAR  *pbd_Rupt)
{
  
  DEBUT_FCT("n_InitPeop");

  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

  /* Ouverture du fichier maitre */
  if (n_OpenFileAppl ("ESTC1043_I1","rt",&(pbd_Rupt->pf_InputFil)))
	RETURN_VAL (ERR); 


  /* Gestion de rupture */
  pbd_Rupt->n_NbRupture = 1;
  pbd_Rupt->c_Separ = '~';

	pbd_Rupt->n_ConditionRupture[0] = n_IsR1 ;
	
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirst ;
  
	pbd_Rupt->n_ActionLigne = n_ActionLignePeop; 

	pbd_Rupt->n_ActionLast[0] = n_ActionLast ;

RETURN_VAL (0);
}

/*==============================================================================
objet :	fonction de test de rupture de niveau 1

retour : 0	---> pas de rupture
	 sinon 	---> rupture
==============================================================================*/
int n_IsR1(char **pbd_InRec ,char **pbd_InRec_Cur  ) 
{
	int ret ;

	DEBUT_FCT( "n_IsR1" ) ;

	if ( ( ret = strcmp( pbd_InRec[TECLEDA_SSD_CF], pbd_InRec_Cur[TECLEDA_SSD_CF] ) ) != 0 ) return ret;
	
	RETURN_VAL( 0 ) ;
}

/*=======================================================================================

========================================================================================*/ 
int n_ActionLignePeop(char **ptb_InRec_Cur)
{
	n_Write_out(ptb_InRec_Cur);

	line++;
RETURN_VAL(0);
}        


/*==============================================================================
objet : fonction lancee en rupture premiere

retour : OK ---> traitement correctement effectue
==============================================================================*/
int n_ActionFirst(char **ptb_InRec_Cur) 
{
	
/*	if ( local_fil < 10 ) {
		c[0] = '0';
		c[1] = ptb_InRec_Cur[TECLEDA_SSD_CF][0];
		}
	else strcpy(c,ptb_InRec_Cur[TECLEDA_SSD_CF]);
*/
	sprintf(nom_fic,"%s_%02d_%s",psz_GetCharArgv(1),atoi(ptb_InRec_Cur[TECLEDA_SSD_CF]),psz_GetCharArgv(2));

	Kp_GoelPeopOFil = fopen(nom_fic,"w");
	RETURN_VAL(OK);
}

/*==============================================================================
objet : fonction lancee en rupture derniere

retour : OK ---> traitement correctement effectue
==============================================================================*/
int n_ActionLast(char **ptb_InRec_Cur) 
{
	fclose(Kp_GoelPeopOFil);
	RETURN_VAL(OK);
}

/*=============================================================================
 objet:  Procedure d'ecriture dans le fichier sortie

=============================================================================*/
int n_Write_out(char **ptb_InRec_Cur) 
{
	
	  char sz_montant[30];
	double montant = atof(ptb_InRec_Cur[TECLEDA_AMT_M]);
	int i=0;

	sprintf(sz_montant,"%.1lf",montant);
	
	while ( sz_montant[i] != '.' ) i++;
	sz_montant[i] = ',';	
	
	ptb_InRec_Cur[TECLEDA_AMT_M] = sz_montant;  

	fprintf(Kp_GoelPeopOFil,"%-3s%-15s%-10s%-15s%15s %s\n",
        	       		ptb_InRec_Cur[TECLEDA_SSD_CF],
				ptb_InRec_Cur[TECLEDA_INV_CF],
				ptb_InRec_Cur[TECLEDA_COD_CF],
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF],
				ptb_InRec_Cur[TECLEDA_AMT_M],
				ptb_InRec_Cur[TECLEDA_CUR_CF]);
RETURN_VAL(OK);
}
	
