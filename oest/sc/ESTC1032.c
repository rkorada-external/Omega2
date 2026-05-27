/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : 
nom du source                 : ESTC1032.c
revision                      : $Revision:   1.0  $
date de creation              : 07/1998
auteur                        : L.Capomazza
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
description :
	Selection des retros totales pour le calcul du net

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	   ...           ...            ...              ...
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <ESTC1032.h>


T_RUPTURE_VAR Kbd_Rupt;
FILE *Kp_GolIFil;
FILE *Kp_GoelPeopOFil;
		
int n_InitPeop(T_RUPTURE_VAR  *pbd_Rupt);
int n_ActionLignePeop(char **ptb_InRec_Cur);
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
	
     
 
 
       
 /* ouverture du fichier peoplesoft */
  if (n_OpenFileAppl("ESTC1032_O1","wt",&Kp_GoelPeopOFil) == ERR )
	ExitPgm ( ERR_XX , "" );
    
	n_InitPeop(&Kbd_Rupt);
	  
  /*traitement*/

  if (n_ProcessingRuptureVar(&Kbd_Rupt)==ERR)
    ExitPgm (ERR_XX , "");
  
  if (n_CloseFileAppl("ESTC1032_I1",&(Kbd_Rupt.pf_InputFil)) == ERR)
    ExitPgm (ERR_XX ,"");
    
  if (n_CloseFileAppl("ESTC1032_O1",&Kp_GoelPeopOFil) == ERR)
    ExitPgm (ERR_XX ,"");
    
 
  if (n_EndPgm() == ERR)
    ExitPgm (ERR_XX , "erreur fin pgm");
  
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
  if (n_OpenFileAppl ("ESTC1032_I1","rt",&(pbd_Rupt->pf_InputFil)))
	RETURN_VAL (ERR); 


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
 	 		n_Write_out(ptb_InRec_Cur);
RETURN_VAL(0);
}        


/*=============================================================================
 objet:  Procedure d'ecriture dans le fichier sortie

=============================================================================*/
int n_Write_out(char **ptb_InRec_Cur) 
{
	if ( strcmp(ptb_InRec_Cur[TECLEDA_COD_CF],"retro") == 0 ) {

	char sz_montant[30];
	double montant = atof(ptb_InRec_Cur[TECLEDA_AMT_M]);

		montant *= -1;
		sprintf(sz_montant,"%.3lf",montant);
		ptb_InRec_Cur[TECLEDA_AMT_M] = sz_montant;  

		fprintf(Kp_GoelPeopOFil,"%s~%s~%s~%s~%s~%s~%s~%s\n",
        	       		ptb_InRec_Cur[TECLEDA_INV_CF],
				ptb_InRec_Cur[TECLEDA_SSD_CF],
				ptb_InRec_Cur[TECLEDA_CTR_NF],
				ptb_InRec_Cur[TECLEDA_COD_CF],
				ptb_InRec_Cur[TECLEDA_LOBACC_CF],
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF],
				ptb_InRec_Cur[TECLEDA_AMT_M],
				ptb_InRec_Cur[TECLEDA_CUR_CF]);
		}
  RETURN_VAL (0);
}
	
