/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : SHERPA
nom du source                 : ESTC1025.c
revision                      : $Revision:   1.1  $
date de creation              : 07/1998
auteur                        : L.Capomazza
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
description :
	Selection et codification des donnees Omega de la table ttecleda

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	22/7/99			ANB			Modification regle generale affectation 7/0 et 7/2 en ouverture au lieu de cloture 
	22/7/99			ANB			Modification affectation certains postes
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <ESTC1025.h>

T_RUPTURE_VAR Kbd_Rupt;
FILE *Kp_GolIFil;
FILE *Kp_GoelFilA;
FILE *ERRORA;
char contratA[10];


int LINE_NBR=1;
/*--------------------------------------------------*/
/* Description des fonctions                        */
/*--------------------------------------------------*/

int n_InitPeop(T_RUPTURE_VAR  *pbd_Rupt);
int n_ActionLignePeop(char **ptb_InRec_Cur);
int n_acc(char **ptb_InRec_Cur);
int n_ChgBrcheA(char **ptb_InRec_Cur);
int n_ChgPsteA(char **ptb_InRec_Cur);
int n_ChgNatA(char **ptb_InRec_Cur);
int n_ChgTafA(char **ptb_InRec_Cur);
int n_Write_outA(char **ptb_InRec_Cur);
int ouv(char *ptb_InRec_Cur);

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

 /* ouverture du fichier peoplesoft */
  if (n_OpenFileAppl("ESTC1025_O1","wt",&Kp_GoelFilA) == ERR )
	ExitPgm ( ERR_XX , "" );
    
/*  if (n_OpenFileAppl("ESTC1025_O2","wt",&ERRORA) == ERR )
	ExitPgm ( ERR_XX , "" );*/

	n_InitPeop(&Kbd_Rupt);
	  
  /*traitement*/

  if (n_ProcessingRuptureVar(&Kbd_Rupt)==ERR)
    ExitPgm (ERR_XX , "");
  
  if (n_CloseFileAppl("ESTC1025_I1",&(Kbd_Rupt.pf_InputFil)) == ERR)
    ExitPgm (ERR_XX ,"");
  
  if (n_CloseFileAppl("ESTC1025_O1",&Kp_GoelFilA) == ERR)
    ExitPgm (ERR_XX ,"");

  /*if (n_CloseFileAppl("ESTC1025_O2",&ERRORA) == ERR)
    ExitPgm (ERR_XX ,"");*/
    
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
  if (n_OpenFileAppl ("ESTC1025_I1","rt",&(pbd_Rupt->pf_InputFil))){
	printf("");
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
	strcpy(contratA,ptb_InRec_Cur[TECLEDA_CTR_NF]);

	if ( ( n_acc(ptb_InRec_Cur) == OK ) 
	&& ( n_ChgTafA(ptb_InRec_Cur) == OK ) 		
	&& ( n_ChgNatA(ptb_InRec_Cur) == OK )
	&& ( n_ChgBrcheA(ptb_InRec_Cur) == OK )
	&& ( n_ChgPsteA(ptb_InRec_Cur) == OK ) )
			n_Write_outA(ptb_InRec_Cur);

LINE_NBR++;
RETURN_VAL(0);
}        

/*=======================================================================================

========================================================================================*/ 
int n_acc(char **ptb_InRec_Cur)
{
	if ( strcmp(ptb_InRec_Cur[TECLEDA_BALSHEY_NF],"1999") != 0 ) 
	RETURN_VAL(ERR);

	if ( ( ptb_InRec_Cur[TECLEDA_TRNCOD_CF][0] == '1')
	|| ( ptb_InRec_Cur[TECLEDA_TRNCOD_CF][0] == '3') )
	RETURN_VAL(OK);
	RETURN_VAL(ERR);
}

/*=============================================================================
 objet: Fonction de traitement de la branche de la ligne en cours 

 retour: OK  --> Ecriture des changements sur sortie
	 ERR --> Affichage des messages d'erreurs sur stdin  
=============================================================================*/
int n_ChgBrcheA(char **ptb_InRec_Cur)
{
	int Local_lob;
	int Local_top;
	int Local_gar;
	int Local_nat;
	
	Local_lob = atoi(ptb_InRec_Cur[TECLEDA_LOBACC_CF]);
	Local_top = atoi(ptb_InRec_Cur[TECLEDA_TOPACC_CF]);
	Local_gar = atoi(ptb_InRec_Cur[TECLEDA_GARACC_CF]);
	

	switch(Local_lob) {
	case 0  : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "A";
		break;

	case 1  : {
		if ( ( strcmp(ptb_InRec_Cur[TECLEDA_WRKCAT_CT],"2") == 0 ) && ( strcmp(ptb_InRec_Cur[TECLEDA_NATACC_CF],"NP") == 0 ) )	
			ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "P.21";
		else ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "P.11";
		}	
		 break;
	
	case 2  : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "P.42";
		 break;

	case 3  : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "P.31";
		 break;

	case 4  : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "P.41";
		 break;

	case 5  : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "S.11"; 
		 break;

	case 6  : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "S.11";
		 break;

	case 7  : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "P.34";
		 break;

	case 8  : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "M.11"; 
		 break;

	case 9  : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "M.12";
		 break;

	case 10 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "A.11";
		 break;

	case 11 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "A.12";
		 break;

	case 12 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "C.12"; 
		 break;

	case 13 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "C.13";
		 break;

	case 14 : 
		switch(Local_top) 
		{
		case 470 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "P.33";
		 		break;
		case 485 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "P.33";
		 		break;
		case 465 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "C.11";
		 		break;
		case 472 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "C.11";
		 		break;
		case 475 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "C.11";
		 		break;
		case 480 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "C.11";
		 		break;
		case 487 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "C.11";
		 		break;
		case 490 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "C.11";
		 		break;
		case 495 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "C.11";
		 		break;
		case 500 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "C.11";
		 		break;
		default  : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "C.11";
				/*fprintf(ERRORA,"filiale %s contrat %s : Erreur LOB - TOP : %d - %d ligne %d\n",ptb_InRec_Cur[TECLEDA_SSD_CF],contratA,Local_lob,Local_top,LINE_NBR);*/
		}
		 break;

	case 15 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "P.32";
		 break;

	case 20 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "P.35";
		 break;

	case 21 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "O.11";
		 break;

	case 22 : 
		switch(Local_gar) 
		{
		case 905 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.41";
				 break;
		case 916 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.41";
				 break;
		case 920 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.41";
				 break;
		case 924 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.42";
				 break;
		case 928 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.42";
				 break;
		case 932 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.42";
				 break;
		case 936 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.43";
				 break;
		case 948 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.43";
				 break;
		case 940 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.44";
				 break;
		case 944 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.45";
				 break;
		default  : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.41";
				/*fprintf(ERRORA,"filiale %s contrat %s : Erreur LOB - GAR : %d - %d ligne %d\n",ptb_InRec_Cur[TECLEDA_SSD_CF],contratA,Local_lob,Local_gar,LINE_NBR);*/
		}
		break;

	case 30 : 
		switch(Local_gar) 
		{
		case 908 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.11"; 
				 break;
		case 912 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.11";
				 break;
		case 900 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.21";
				 break;
		case 904 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.21";
				 break;
		default  : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.21";
		}
		break;
	
	case 31 : 
		switch(Local_gar) 
		{
		case 905 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.41";
				 break;
		case 916 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.41";
				 break;
		case 920 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.41";
				 break;
		case 924 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.42";
				 break;
		case 928 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.42";
				 break;
		case 932 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.42";
				 break;
		case 936 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.43";
				 break;
		case 948 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.43";
				 break;
		case 940 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.44";
				 break;
		case 944 : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.45";
				 break;
		default  : ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.41";
		}
		break;
	default : {	
			ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "A";
			/*if ( ptb_InRec_Cur[TECLEDA_SSD_CF][0] == '4' )
					ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "L.41";
			else ptb_InRec_Cur[TECLEDA_LOBACC_CF] = "P.11";*/
			/*fprintf(ERRORA,"filiale %s contrat %s : Erreur LOB : %d - %s ligne %d\n",ptb_InRec_Cur[TECLEDA_SSD_CF],contratA,Local_lob,ptb_InRec_Cur[TECLEDA_LOBACC_CF],LINE_NBR);*/
			}
 	}

	RETURN_VAL(OK);
}

/*=============================================================================
 objet: Fonction de traitement du poste de la ligne en cours 

 retour: OK si ok
	 ERR si erreur  
=============================================================================*/
int n_ChgPsteA(char **ptb_InRec_Cur)
{
	char CP_2[3];
	char CP_3[4];
	char CPTE[6];

	int cp_2;
	int cp_3;
	int cpte;

	int i;
	int modified = 0;

	for (i=0 ; i<2 ; i++) CP_2[i] = ptb_InRec_Cur[TECLEDA_TRNCOD_CF][i+2];
	for (i=0 ; i<3 ; i++) CP_3[i] = ptb_InRec_Cur[TECLEDA_TRNCOD_CF][i+2];
	for (i=0 ; i<5 ; i++) CPTE[i] = ptb_InRec_Cur[TECLEDA_TRNCOD_CF][i+2];

	CP_2[2] = '\0';
	CP_3[3] = '\0';
	CPTE[5] = '\0';
	
	cp_2 = atoi(CP_2);
	cp_3 = atoi(CP_3);
	cpte = atoi(CPTE);

	if ( ( ptb_InRec_Cur[TECLEDA_TRNCOD_CF][1] == 'C')
	|| ( ptb_InRec_Cur[TECLEDA_TRNCOD_CF][1] == 'I') 
	|| ( ptb_InRec_Cur[TECLEDA_TRNCOD_CF][1] == 'O') 
	|| ( ptb_InRec_Cur[TECLEDA_TRNCOD_CF][1] == 'R') 
	|| ( ptb_InRec_Cur[TECLEDA_TRNCOD_CF][1] == 'S') 
	|| ( ptb_InRec_Cur[TECLEDA_TRNCOD_CF][1] == 'T')) 
		RETURN_VAL(ERR);

	switch(cp_2) {

	case 10 :
		/*if ( strcmp(ptb_InRec_Cur[TECLEDA_TRNCOD_CF],"11100000") == 0) 
			printf("TEST 10000 filiale %s contrat %s poste %s ligne %d\n",ptb_InRec_Cur[TECLEDA_SSD_CF],contratA,ptb_InRec_Cur[TECLEDA_TRNCOD_CF],LINE_NBR);*/
        ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "1";
		modified = 1; 
		break;
	case 12 : {
		if ( cpte == 12110 ) ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "21";
		else ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "17";
		}
		modified = 1; 
		break;
	case 13 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "17";
		modified = 1; 
		break;
	case 14 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "17";
		modified = 1; 
		break;
	case 15 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "17";
		modified = 1; 
		break;
	case 20 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "7";
		modified = 1; 
		break;
	case 30 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "1";
		modified = 1; 
		break;
	case 31 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "17";
		modified = 1; 
		break;
	case 32 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "7";
		modified = 1; 
		break;
	case 40 : {
		if ( ouv(ptb_InRec_Cur[TECLEDA_TRNCOD_CF]) )
			ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "10";
		else 
			ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "11";
		modified = 1; 
				
		}
		break;
	case 41 : switch(cpte) {
		case 41101 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "4";
			modified = 1; 
			break;
		case 41901 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "4";
			modified = 1; 
			break;
		default : {
			if ( ouv(ptb_InRec_Cur[TECLEDA_TRNCOD_CF]) )
			/*|| (strcmp(ptb_InRec_Cur[TECLEDA_TRNCOD_CF],"11411002") == 0) 
			|| (strcmp(ptb_InRec_Cur[TECLEDA_TRNCOD_CF],"31411002") == 0) ) */
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "4";
			else
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "5";
			modified = 1; 
			}
		}
		break;
	case 42 : switch(cpte) {
		case 42101 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "10";
			modified = 1; 
			break;
		case 42111 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "10";
			modified = 1; 
			break;
		case 42141 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "10";
			modified = 1; 
			break;
		case 42151 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "10";
			modified = 1; 
			break;
		case 42161 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "10";
			modified = 1; 
			break;
		case 42191 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "10";
			modified = 1; 
			break;
		case 42401 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "10";
			modified = 1; 
			break;
		case 42801 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "10";
			modified = 1; 
			break;
		default : {
			if ( ouv(ptb_InRec_Cur[TECLEDA_TRNCOD_CF]) )
			/*|| (strcmp(ptb_InRec_Cur[TECLEDA_TRNCOD_CF],"11421002") ==0)
			|| (strcmp(ptb_InRec_Cur[TECLEDA_TRNCOD_CF],"31421002") ==0)
			|| (strcmp(ptb_InRec_Cur[TECLEDA_TRNCOD_CF],"11421502") ==0) 
			|| (strcmp(ptb_InRec_Cur[TECLEDA_TRNCOD_CF],"31421502") ==0) )*/
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "10";
			else 
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "11";
			modified = 1; 
			}
		}
		break;
	case 43 : switch(cpte) {
		case 43101 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "18";
			modified = 1; 
			break;
		case 43701 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "18";
			modified = 1; 
			break;
		default : {
			if ( ouv(ptb_InRec_Cur[TECLEDA_TRNCOD_CF]) )
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "18";
			else 
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "19";
			modified = 1; 
			}
		}
		break;
	case 44 : switch(cpte) {
		case 44101 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "10";
			modified = 1;
			break;
		default : {
			if ( ouv(ptb_InRec_Cur[TECLEDA_TRNCOD_CF]) )
			/*|| (strcmp(ptb_InRec_Cur[TECLEDA_TRNCOD_CF],"11441002") ==0) 
			|| (strcmp(ptb_InRec_Cur[TECLEDA_TRNCOD_CF],"31441002") ==0) )*/
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "10";
			else 
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "11";
			modified = 1; 
			}
		}
		break;
	case 45 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "17";
		modified = 1; 
		break;
	case 46 : switch(cpte){
		case 46010 : {
			if ( ouv(ptb_InRec_Cur[TECLEDA_TRNCOD_CF]) )
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "10";
			else 
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "11";
			modified = 1; 
			}
		break;
		case 46110 : {
			if ( ouv(ptb_InRec_Cur[TECLEDA_TRNCOD_CF]) )
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "10";
			else
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "11";
			modified = 1; 
			}
		break;
		case 46000 : {
			if ( ouv(ptb_InRec_Cur[TECLEDA_TRNCOD_CF]) )
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "14";
			else
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "15";
			modified = 1; 
			}
		break;
		case 46100 : {
			if ( ouv(ptb_InRec_Cur[TECLEDA_TRNCOD_CF]) )
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "14";
			else
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "15";
			modified = 1; 
			}
		break;
		case 46020 : {
			if ( ouv(ptb_InRec_Cur[TECLEDA_TRNCOD_CF]) )
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "4";
			else
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "5";
			modified = 1; 
			}
		break;
		case 46120 : {
			if ( ouv(ptb_InRec_Cur[TECLEDA_TRNCOD_CF]) )
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "4";
			else
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "5";
			modified = 1; 
			}
		break;
		default    : ;
		}
		break;
	case 48 : switch(cpte) {
		case 48101 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "10";
			modified = 1;
			break;
		case 48111 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "10";
			modified = 1;
			break;
		case 48801 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "10";
			modified = 1;
			break;
		default : {
			if ( ouv(ptb_InRec_Cur[TECLEDA_TRNCOD_CF]) )
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "10";
			else 
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "11";
			modified = 1; 
			}
		}
		break;
	case 49 : switch(cpte){
		case 49400 : {
			if ( ouv(ptb_InRec_Cur[TECLEDA_TRNCOD_CF]) )
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "10";
			else
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "11";
			modified = 1; 
			}	
		break;
		case 49405 : {
			if ( ouv(ptb_InRec_Cur[TECLEDA_TRNCOD_CF]) )
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "10";
			else
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "11";
			modified = 1; 
			}	
		break;
		case 49500 : {
			if ( ouv(ptb_InRec_Cur[TECLEDA_TRNCOD_CF]) )
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "10";
			else
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "11";
			modified = 1; 
			}
		break;
		case 49505 : {
			if ( ouv(ptb_InRec_Cur[TECLEDA_TRNCOD_CF]) )
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "10";
			else
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "11";
			modified = 1; 
			}	
		break;
		default    : {
			if ( ouv(ptb_InRec_Cur[TECLEDA_TRNCOD_CF]) )
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "12";
			else
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "13";
			modified = 1; 
			}
		}
		break;
	default : ; 
	}

	if ( modified ) n_Write_outA(ptb_InRec_Cur);
	
	switch(cp_3) {

	case 300 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "2";	
		RETURN_VAL(OK); 
		break;	
	case 301 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "3";
		RETURN_VAL(OK); 
		break;
	case 320 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "8";
		RETURN_VAL(OK); 
		break;
	case 321 : ptb_InRec_Cur[TECLEDA_TRNCOD_CF] = "9";
		RETURN_VAL(OK); 
		break;
	default  : {
		/*if ( modified == 0 ) 
		fprintf(ERRORA,"filiale %s contrat %s : Pas de poste correspondant au numero %d ligne %d\n",ptb_InRec_Cur[TECLEDA_SSD_CF],contratA,cpte,LINE_NBR);*/
		RETURN_VAL(ERR);
		}
	}

}

/*=============================================================================
 objet: Fonction de traitement de la nature

 retour: OK  --> Ecriture des changements sur sortie
	 ERR --> Affichage des messages d'erreurs sur stdin  
=============================================================================*/
int n_ChgNatA(char **ptb_InRec_Cur)
{
	int Local_nat;

	Local_nat = atoi(ptb_InRec_Cur[TECLEDA_NATACC_CF]);

	if ( ( ( ptb_InRec_Cur[TECLEDA_CTR_NF][0] == 'T' ) || ( ptb_InRec_Cur[TECLEDA_CTR_NF][0] == 'F' ) )
	&& ( Local_nat == 0 ) ) {
		ptb_InRec_Cur[TECLEDA_NATACC_CF] = "PP";
		RETURN_VAL(OK);
		}
	
	if ( ( ( ptb_InRec_Cur[TECLEDA_CTR_NF][0] == 'T' ) || ( ptb_InRec_Cur[TECLEDA_CTR_NF][0] == 'F' ) )
	&& ( Local_nat >= 30 ) ) {
		ptb_InRec_Cur[TECLEDA_NATACC_CF] = "NP";
		RETURN_VAL(OK);
		}
	
	if ( ( ( ptb_InRec_Cur[TECLEDA_CTR_NF][0] == 'T' ) || ( ptb_InRec_Cur[TECLEDA_CTR_NF][0] == 'F' ) )
	&& ( Local_nat < 30 ) ) {
		ptb_InRec_Cur[TECLEDA_NATACC_CF] = "PP";
		RETURN_VAL(OK);
		}
	
	/*fprintf(ERRORA,"filiale %s contrat %s Erreur nat : local_nat == %d\n",ptb_InRec_Cur[TECLEDA_SSD_CF],contratA,Local_nat);*/
	RETURN_VAL(ERR);
	
}

/*=============================================================================
 objet: Fonction de traitement du type d'affaires

 retour: OK  --> Ecriture des changements sur sortie
	 ERR --> Affichage des messages d'erreurs sur stdin  
=============================================================================*/
int n_ChgTafA(char **ptb_InRec_Cur)
{
	switch(ptb_InRec_Cur[TECLEDA_CTR_NF][2]) {

	case 'T' : ptb_InRec_Cur[TECLEDA_CTR_NF] = "T";
			break;
	case 'U' : ptb_InRec_Cur[TECLEDA_CTR_NF] = "T";
			break;
	case 'W' : ptb_InRec_Cur[TECLEDA_CTR_NF] = "T";
			break;
	case 'Z' : ptb_InRec_Cur[TECLEDA_CTR_NF] = "T";
			break;
	case 'F' : ptb_InRec_Cur[TECLEDA_CTR_NF] = "F";
			break;
	case 'G' : ptb_InRec_Cur[TECLEDA_CTR_NF] = "F";
			break;
	default  : {
		/* fprintf(ERRORA,"filiale %s contrat %s : Erreur TAF : %c ligne %d\n",ptb_InRec_Cur[TECLEDA_SSD_CF],contratA,ptb_InRec_Cur[TECLEDA_CTR_NF][2],LINE_NBR); */
		RETURN_VAL(ERR);
		}
	}
	/* cas particuliers des facs considerees comme des traites */
	
	if ( strcmp(ptb_InRec_Cur[TECLEDA_UWGRP_CF],"411") == 0 ) 
		ptb_InRec_Cur[TECLEDA_CTR_NF] = "F";
	
RETURN_VAL(OK);
}

/*=============================================================================
 objet: Procedure d'ecriture dans le fichier sortie

 retour:   
=============================================================================*/
int n_Write_outA(char **ptb_InRec_Cur) 
{
	fprintf(Kp_GoelFilA,"%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",
        	       		ptb_InRec_Cur[TECLEDA_SSD_CF],
                		ptb_InRec_Cur[TECLEDA_BALSHEY_NF],
				ptb_InRec_Cur[TECLEDA_TRNCOD_CF],
				ptb_InRec_Cur[TECLEDA_CTR_NF],
				ptb_InRec_Cur[TECLEDA_CUR_CF],
        			ptb_InRec_Cur[TECLEDA_AMT_M],
				ptb_InRec_Cur[TECLEDA_LOBACC_CF],
				ptb_InRec_Cur[TECLEDA_NATACC_CF],
				ptb_InRec_Cur[TECLEDA_SOBACC_CF],
				ptb_InRec_Cur[TECLEDA_TOPACC_CF],
				ptb_InRec_Cur[TECLEDA_GARACC_CF],
				ptb_InRec_Cur[TECLEDA_WRKCAT_CT],
				contratA,
				ptb_InRec_Cur[TECLEDA_SEC_NF],
				ptb_InRec_Cur[TECLEDA_UWY_NF]);
}

/*=============================================================================
 objet: teste si ouverture ou cloture.

 retour: 1 si ouverture
	 0 si cloture  
	-1 si rien	
=============================================================================*/
int ouv(char *ptb_InRec_Cur)
{

/* Modif ANB le 22/7/99 */
/* Ventilation des postes 7 0 et 7 2 en ouverture au lieu de cloture */

	if ( ( ( ptb_InRec_Cur[1] == '1' )
	/*|| ( ptb_InRec_Cur[1] == '7' )*/
	|| ( ptb_InRec_Cur[1] == '9' ) ) 
	&& ( ( ptb_InRec_Cur[7] == '1' )
	|| ( ptb_InRec_Cur[7] == '3' )
	|| ( ptb_InRec_Cur[7] == '5' )
	|| ( ptb_InRec_Cur[7] == '7' ) ) )
		RETURN_VAL(1);
	else 
	if ( ( ( ptb_InRec_Cur[1] == '1' )
	|| ( ptb_InRec_Cur[1] == '3' ) 
	|| ( ptb_InRec_Cur[1] == '4' ) 
	/*|| ( ptb_InRec_Cur[1] == '7' )*/ 
	|| ( ptb_InRec_Cur[1] == '6' ))
	&& ( ( ptb_InRec_Cur[7] == '0' )
	|| ( ptb_InRec_Cur[7] == '2' )
	|| ( ptb_InRec_Cur[7] == '4' )
	|| ( ptb_InRec_Cur[7] == '6' ) ) )
		RETURN_VAL(0);
	else 
	if ( ( ptb_InRec_Cur[1] == '7' )
	&& ( ( ptb_InRec_Cur[7] == '0' )
	|| ( ptb_InRec_Cur[7] == '2' ) ) )
		RETURN_VAL(1);

	/*if ( ouv(ptb_InRec_Cur[TECLEDA_TRNCOD_CF]) == -1 )
			fprintf(ERRORA,"Erreur Rg provision : Filiale %s Contrat %s Poste %s Ligne %d\n",ptb_InRec_Cur[TECLEDA_SSD_CF],contratA,ptb_InRec_Cur[TECLEDA_TRNCOD_CF],LINE_NBR);*/

RETURN_VAL(-1);

}
