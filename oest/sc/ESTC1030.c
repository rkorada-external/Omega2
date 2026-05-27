/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : SHERPA
nom du source                 : ESTC1030.c
revision                      : $Revision:   1.3  $
date de creation              : 07/1998
auteur                        : L.Capomazza
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
description :
	Selection et codification des donnees Omega de la table ttecledr

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	22/7/99			ANB			Modification regle generale affectation 7/0 et 7/2 en ouverture au lieu de cloture 
	27/7/99			ANB			Modification affectation certains postes (vu avec consolidation)
	27/7/99			ANB			Modification prise en compte L0 et suffixe 5 pour ouverture
	28/1/00			ANB			Modification prise en compte L0 de Scor Italie
============================================================================== */

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <ESTC1030.h>

T_RUPTURE_VAR Kbd_Rupt;
FILE *Kp_GolIFil;
FILE *Kp_GoelPeopOFil;
FILE *ERROR;
char *TOP_RTO;
char contratR[10];
char categ_contratR[3];

int LINE_NBR=1;
/*--------------------------------------------------*/
/* Description des fonctions                        */
/*--------------------------------------------------*/

int n_InitPeop(T_RUPTURE_VAR  *pbd_Rupt);
int n_ActionLignePeop(char **ptb_InRec_Cur);
int n_ChgBrche(char **ptb_InRec_Cur);
int n_ChgPste(char **ptb_InRec_Cur);
int n_ChgNat(char **ptb_InRec_Cur);
int n_ChgTaf(char **ptb_InRec_Cur);
int n_ChgRetro(char **ptb_InRec_Cur);
int n_Write_out(char **ptb_InRec_Cur);
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
	
     
 /* ouverture du fichier goelette */
 /* if (n_OpenFileAppl("ESTC1030_I1","rt",&Kp_GolIFil) == ERR )
	 ExitPgm ( ERR_XX , "" ); */

 /* ouverture du fichier peoplesoft */
  if (n_OpenFileAppl("ESTC1030_O1","wt",&Kp_GoelPeopOFil) == ERR )
	ExitPgm ( ERR_XX , "" );

/*  if (n_OpenFileAppl("ESTC1030_O2","wt",&ERROR) == ERR )
	ExitPgm ( ERR_XX , "" );*/
    
	n_InitPeop(&Kbd_Rupt);
	  
  /*traitement*/

  if (n_ProcessingRuptureVar(&Kbd_Rupt)==ERR)
    ExitPgm (ERR_XX , "");
  
  if (n_CloseFileAppl("ESTC1030_I1",&(Kbd_Rupt.pf_InputFil)) == ERR)
    ExitPgm (ERR_XX ,"");
  
  if (n_CloseFileAppl("ESTC1030_O1",&Kp_GoelPeopOFil) == ERR)
    ExitPgm (ERR_XX ,"");

  /*if (n_CloseFileAppl("ESTC1030_O2",&ERROR) == ERR)
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
  if (n_OpenFileAppl ("ESTC1030_I1","rt",&(pbd_Rupt->pf_InputFil))){
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
	strcpy(contratR,ptb_InRec_Cur[TECLEDR_RETCTR_NF]);
	strcpy(categ_contratR,ptb_InRec_Cur[TECLEDR_RETCTRCAT_CF]);

	if ( ( n_ChgTaf(ptb_InRec_Cur) == OK ) 		
	&& ( n_ChgNat(ptb_InRec_Cur) == OK )
	&& ( n_ChgBrche(ptb_InRec_Cur) == OK )
	&& ( n_ChgPste(ptb_InRec_Cur) == OK ) )
			n_Write_out(ptb_InRec_Cur); 
	
LINE_NBR++;
RETURN_VAL(0);
}        

/*=============================================================================
 objet: Fonction de traitement de la branche de la ligne en cours 

 retour: OK  --> Ecriture des changements sur sortie
	 ERR --> Affichage des messages d'erreurs sur ERROR  
=============================================================================*/
int n_ChgBrche(char **ptb_InRec_Cur)
{
	int Local_lob;
	int Local_top;
	int Local_gar;

	Local_lob = atoi(ptb_InRec_Cur[TECLEDR_LOBRET_CF]);
	Local_top = atoi(ptb_InRec_Cur[TECLEDR_TOPRET_CF]);
	Local_gar = atoi(ptb_InRec_Cur[TECLEDR_GARRET_CF]);
	

	/* Cas particuliers des contrats catastrophes en non-vie */

	/* EUROPE */

	if (( strcmp(contratR,"01N000012") == 0 )
	|| ( strcmp(contratR,"01N000013") == 0 )
	|| ( strcmp(contratR,"01N000015") == 0 )
	|| ( strcmp(contratR,"01N000017") == 0 )
	|| ( strcmp(contratR,"01N000018") == 0 )
	|| ( strcmp(contratR,"01Z0026RT") == 0 )
	|| ( strcmp(contratR,"01Z0027RT") == 0 )
	|| ( strcmp(contratR,"01Z0028RT") == 0 )
	|| ( strcmp(contratR,"01Z0042RT") == 0 )
	|| ( strcmp(contratR,"01Z0049RT") == 0 )
	|| ( strcmp(contratR,"01Z0059RT") == 0 )
	|| ( strcmp(contratR,"01Z0068RT") == 0 )
	|| ( strcmp(contratR,"01Z0072RT") == 0 )
	|| ( strcmp(contratR,"01Z0073RT") == 0 )
	|| ( strcmp(contratR,"01Z0079RT") == 0 )
	|| ( strcmp(contratR,"01Z0082RT") == 0 )
	|| ( strcmp(contratR,"01Z0084RT") == 0 )
	|| ( strcmp(contratR,"01Z0087RT") == 0 )
	|| ( strcmp(contratR,"01Z0090RT") == 0 )
	|| ( strcmp(contratR,"01Z0091RT") == 0 )
	|| ( strcmp(contratR,"01Z0092RT") == 0 )
	|| ( strcmp(contratR,"01Z0093RT") == 0 )
	|| ( strcmp(contratR,"01Z0101RT") == 0 )
	|| ( strcmp(contratR,"01Z0107RT") == 0 )
	|| ( strcmp(contratR,"01Z0110RT") == 0 )
	|| ( strcmp(contratR,"01Z0111RT") == 0 )
	|| ( strcmp(contratR,"01Z0112RT") == 0 )
	|| ( strcmp(contratR,"01Z0115RT") == 0 )
	|| ( strcmp(contratR,"01Z0116RT") == 0 )
	|| ( strcmp(contratR,"01Z0120RT") == 0 )
	|| ( strcmp(contratR,"01Z0121RT") == 0 )
	|| ( strcmp(contratR,"01Z0122RT") == 0 )
	|| ( strcmp(contratR,"01Z0123RT") == 0 )
	|| ( strcmp(contratR,"01Z0124RT") == 0 )
	|| ( strcmp(contratR,"01Z0125RT") == 0 )
	|| ( strcmp(contratR,"01Z0126RT") == 0 )
	|| ( strcmp(contratR,"01Z0132RT") == 0 )
	|| ( strcmp(contratR,"01Z0133RT") == 0 )
	|| ( strcmp(contratR,"01Z0136RT") == 0 )
	|| ( strcmp(contratR,"01Z0137RT") == 0 )
	|| ( strcmp(contratR,"01Z0138RT") == 0 )
	|| ( strcmp(contratR,"01Z0140RT") == 0 )
	|| ( strcmp(contratR,"01Z0147RT") == 0 )
	|| ( strcmp(contratR,"01Z0164RT") == 0 )
	|| ( strcmp(contratR,"01Z0165RT") == 0 )
	|| ( strcmp(contratR,"01Z0166RT") == 0 )
	|| ( strcmp(contratR,"01Z0167RT") == 0 )
	|| ( strcmp(contratR,"01Z0168RT") == 0 )
	|| ( strcmp(contratR,"01Z0169RT") == 0 )
	|| ( strcmp(contratR,"01Z0170RT") == 0 )
	|| ( strcmp(contratR,"01Z0173RT") == 0 )
	|| ( strcmp(contratR,"01Z0901RT") == 0 )
	|| ( strcmp(contratR,"01Z0902RT") == 0 )
	|| ( strcmp(contratR,"01Z0903RT") == 0 )
	|| ( strcmp(contratR,"01Z0904RT") == 0 )
	|| ( strcmp(contratR,"01Z0905RT") == 0 )
	|| ( strcmp(contratR,"01Z0906RT") == 0 )
	|| ( strcmp(contratR,"01Z0907RT") == 0 )
	|| ( strcmp(contratR,"01Z0908RT") == 0 )
	|| ( strcmp(contratR,"01Z0909RT") == 0 )
	|| ( strcmp(contratR,"01Z0910RT") == 0 )
	|| ( strcmp(contratR,"01Z0911RT") == 0 )
	|| ( strcmp(contratR,"01Z0912RT") == 0 )
	|| ( strcmp(contratR,"01Z0913RT") == 0 )
	|| ( strcmp(contratR,"01Z1049RT") == 0 )
	|| ( strcmp(contratR,"01Z1112RT") == 0 )
	|| ( strcmp(contratR,"01Z1123RT") == 0 )
	|| ( strcmp(contratR,"01Z1138RT") == 0 )
	|| ( strcmp(contratR,"01Z1166RT") == 0 )
	|| ( strcmp(contratR,"01Z1167RT") == 0 )
	|| ( strcmp(contratR,"01Z1168RT") == 0 )
	|| ( strcmp(contratR,"01Z1169RT") == 0 ))
		{
		ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "P.21";
		RETURN_VAL(OK);
		}

	if (( strcmp(contratR,"02N000006") == 0 )
	|| ( strcmp(contratR,"02N000010") == 0 )
	|| ( strcmp(contratR,"02N000011") == 0 )
	|| ( strcmp(contratR,"02N000012") == 0 )
	|| ( strcmp(contratR,"02N000013") == 0 )
	|| ( strcmp(contratR,"02N000014") == 0 )
	|| ( strcmp(contratR,"02N000015") == 0 )
	|| ( strcmp(contratR,"02N000016") == 0 )
	|| ( strcmp(contratR,"02N000017") == 0 )
	|| ( strcmp(contratR,"02N000019") == 0 )
	|| ( strcmp(contratR,"02N000020") == 0 )
	|| ( strcmp(contratR,"02N000021") == 0 )
	|| ( strcmp(contratR,"02N000022") == 0 )
	|| ( strcmp(contratR,"02N000023") == 0 )
	|| ( strcmp(contratR,"02N000024") == 0 )
	|| ( strcmp(contratR,"02N000034") == 0 )
	|| ( strcmp(contratR,"02N000035") == 0 )
	|| ( strcmp(contratR,"02N000036") == 0 )
	|| ( strcmp(contratR,"02Z000113") == 0 )
	|| ( strcmp(contratR,"02Z000114") == 0 )
	|| ( strcmp(contratR,"02Z000115") == 0 )
	|| ( strcmp(contratR,"02Z000116") == 0 )
	|| ( strcmp(contratR,"02Z000117") == 0 )
	|| ( strcmp(contratR,"02Z052263") == 0 )
	|| ( strcmp(contratR,"02Z052360") == 0 )
	|| ( strcmp(contratR,"02Z052361") == 0 )
	|| ( strcmp(contratR,"02Z052362") == 0 )
	|| ( strcmp(contratR,"02Z052384") == 0 )
	|| ( strcmp(contratR,"02Z052496") == 0 )
	|| ( strcmp(contratR,"02Z052607") == 0 )
	|| ( strcmp(contratR,"02Z052608") == 0 )
	|| ( strcmp(contratR,"02Z052643") == 0 )
	|| ( strcmp(contratR,"02Z052657") == 0 )
	|| ( strcmp(contratR,"02Z052658") == 0 )
	|| ( strcmp(contratR,"02Z052659") == 0 )
	|| ( strcmp(contratR,"02Z052665") == 0 )
	|| ( strcmp(contratR,"02Z052667") == 0 )
	|| ( strcmp(contratR,"02Z052668") == 0 )
	|| ( strcmp(contratR,"02Z052671") == 0 )
	|| ( strcmp(contratR,"02Z052672") == 0 )
	|| ( strcmp(contratR,"02Z052673") == 0 )
	|| ( strcmp(contratR,"02Z052679") == 0 )
	|| ( strcmp(contratR,"02Z052733") == 0 )
	|| ( strcmp(contratR,"02Z052741") == 0 )
	|| ( strcmp(contratR,"02Z052743") == 0 )
	|| ( strcmp(contratR,"02Z052752") == 0 )
	|| ( strcmp(contratR,"02Z052758") == 0 )
	|| ( strcmp(contratR,"02Z052768") == 0 )
	|| ( strcmp(contratR,"02Z052769") == 0 )
	|| ( strcmp(contratR,"02Z052770") == 0 )
	|| ( strcmp(contratR,"02Z052771") == 0 )
	|| ( strcmp(contratR,"02Z052772") == 0 )
	|| ( strcmp(contratR,"02Z052773") == 0 )
	|| ( strcmp(contratR,"02Z052774") == 0 )
	|| ( strcmp(contratR,"02Z052775") == 0 )
	|| ( strcmp(contratR,"02Z052776") == 0 )
	|| ( strcmp(contratR,"02Z052777") == 0 )
	|| ( strcmp(contratR,"02Z052778") == 0 )
	|| ( strcmp(contratR,"02Z052781") == 0 ))
		{
		ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "P.21";
		RETURN_VAL(OK);
		}

	if (( strcmp(contratR,"03Z052755") == 0 )
	|| ( strcmp(contratR,"03Z054002") == 0 )
	|| ( strcmp(contratR,"03Z054024") == 0 )
	|| ( strcmp(contratR,"03Z054025") == 0 )
	|| ( strcmp(contratR,"03Z054026") == 0 )
	|| ( strcmp(contratR,"03Z054027") == 0 )
	|| ( strcmp(contratR,"03Z054028") == 0 )
	|| ( strcmp(contratR,"03Z054030") == 0 )
	|| ( strcmp(contratR,"03Z054051") == 0 )
	|| ( strcmp(contratR,"03Z054052") == 0 )
	|| ( strcmp(contratR,"03Z054053") == 0 )
	|| ( strcmp(contratR,"03Z054063") == 0 ))
		{
		ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "P.21";
		RETURN_VAL(OK);
		}

	if (( strcmp(contratR,"05N000020") == 0 )
	|| ( strcmp(contratR,"05N000021") == 0 )
	|| ( strcmp(contratR,"05Z060000") == 0 )
	|| ( strcmp(contratR,"05Z062250") == 0 )
	|| ( strcmp(contratR,"05Z06225A") == 0 )
	|| ( strcmp(contratR,"05Z06225B") == 0 )
	|| ( strcmp(contratR,"05Z616400") == 0 )
	|| ( strcmp(contratR,"05Z616401") == 0 )
	|| ( strcmp(contratR,"05Z616402") == 0 )
	|| ( strcmp(contratR,"05Z616403") == 0 )
	|| ( strcmp(contratR,"05Z630650") == 0 )
	|| ( strcmp(contratR,"05Z63065A") == 0 )
	|| ( strcmp(contratR,"05Z63065B") == 0 )
	|| ( strcmp(contratR,"05Z63065C") == 0 )
	|| ( strcmp(contratR,"05Z63065D") == 0 )
	|| ( strcmp(contratR,"05Z631190") == 0 )
	|| ( strcmp(contratR,"05Z63119A") == 0 )
	|| ( strcmp(contratR,"05Z63119B") == 0 )
	|| ( strcmp(contratR,"05Z63119C") == 0 )
	|| ( strcmp(contratR,"05Z63119D") == 0 )
	|| ( strcmp(contratR,"05Z631220") == 0 )
	|| ( strcmp(contratR,"05Z63122A") == 0 )
	|| ( strcmp(contratR,"05Z63122B") == 0 )
	|| ( strcmp(contratR,"05Z63122C") == 0 )
	|| ( strcmp(contratR,"05Z63122D") == 0 )
	|| ( strcmp(contratR,"05Z631370") == 0 )
	|| ( strcmp(contratR,"05Z632150") == 0 ))
		{
		ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "P.21";
		RETURN_VAL(OK);
		}

	if (( strcmp(contratR,"06N000011") == 0 )
	|| ( strcmp(contratR,"06N000012") == 0 ))
		{
		ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "P.21";
		RETURN_VAL(OK);
		}

	/* A vérifier car surprenant ??? */

	if ( strcmp(contratR,"08N000001") == 0 )
		{
		ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "P.21";
		RETURN_VAL(OK);
		}

	/* Voir si utile ??? */
	
	if (( strcmp(contratR,"12N000001") == 0 )
	|| ( strcmp(contratR,"12Z055003") == 0 )
	|| ( strcmp(contratR,"12Z055004") == 0 )
	|| ( strcmp(contratR,"12Z055005") == 0 )
	|| ( strcmp(contratR,"12Z055006") == 0 )
	|| ( strcmp(contratR,"12Z055007") == 0 ))
		{
		ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "P.21";
		RETURN_VAL(OK);
		}


	/* USA */

	if (( strcmp(contratR,"10N000027") == 0 )
	|| ( strcmp(contratR,"10N000077") == 0 )
	|| ( strcmp(contratR,"10N000085") == 0 )
	|| ( strcmp(contratR,"10Z000024") == 0 )
	|| ( strcmp(contratR,"10Z000025") == 0 )
	|| ( strcmp(contratR,"10Z000026") == 0 )
	|| ( strcmp(contratR,"10ZRO9032") == 0 )
	|| ( strcmp(contratR,"10ZRO9033") == 0 )
	|| ( strcmp(contratR,"10ZRO9034") == 0 )
	|| ( strcmp(contratR,"10ZRO9035") == 0 )
	|| ( strcmp(contratR,"10ZRO9132") == 0 )
	|| ( strcmp(contratR,"10ZRO9133") == 0 )
	|| ( strcmp(contratR,"10ZRO9134") == 0 )
	|| ( strcmp(contratR,"10ZRO9135") == 0 )
	|| ( strcmp(contratR,"10ZRO9232") == 0 )
	|| ( strcmp(contratR,"10ZRO9233") == 0 )
	|| ( strcmp(contratR,"10ZRO9234") == 0 )
	|| ( strcmp(contratR,"10ZRO9235") == 0 )
	|| ( strcmp(contratR,"10ZRO9332") == 0 )
	|| ( strcmp(contratR,"10ZRT8624") == 0 )
	|| ( strcmp(contratR,"10ZRT8631") == 0 )
	|| ( strcmp(contratR,"10ZRT8632") == 0 )
	|| ( strcmp(contratR,"10ZRT8633") == 0 )
	|| ( strcmp(contratR,"10ZRT8634") == 0 )
	|| ( strcmp(contratR,"10ZRT8732") == 0 )
	|| ( strcmp(contratR,"10ZRT8733") == 0 )
	|| ( strcmp(contratR,"10ZRT8734") == 0 )
	|| ( strcmp(contratR,"10ZRT8735") == 0 )
	|| ( strcmp(contratR,"10ZRT8736") == 0 )
	|| ( strcmp(contratR,"10ZRT8737") == 0 )
	|| ( strcmp(contratR,"10ZRT8738") == 0 )
	|| ( strcmp(contratR,"10ZRT8832") == 0 )
	|| ( strcmp(contratR,"10ZRT8833") == 0 )
	|| ( strcmp(contratR,"10ZRT8834") == 0 )
	|| ( strcmp(contratR,"10ZRT8932") == 0 )
	|| ( strcmp(contratR,"10ZRT8933") == 0 )
	|| ( strcmp(contratR,"10ZRT8934") == 0 )
	|| ( strcmp(contratR,"10ZRT8935") == 0 )
	|| ( strcmp(contratR,"10ZRT8936") == 0 ))
		{
		ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "P.21";
		RETURN_VAL(OK);
		}

	if (( strcmp(contratR,"11Z001138") == 0 )
	|| ( strcmp(contratR,"11Z001431") == 0 )
	|| ( strcmp(contratR,"11Z001432") == 0 )
	|| ( strcmp(contratR,"11Z001503") == 0 )
	|| ( strcmp(contratR,"11Z001504") == 0 )
	|| ( strcmp(contratR,"11Z001505") == 0 )
	|| ( strcmp(contratR,"11Z001506") == 0 )
	|| ( strcmp(contratR,"11Z001507") == 0 )
	|| ( strcmp(contratR,"11Z001654") == 0 )
	|| ( strcmp(contratR,"11Z001655") == 0 )
	|| ( strcmp(contratR,"11Z001656") == 0 )
	|| ( strcmp(contratR,"11Z001790") == 0 )
	|| ( strcmp(contratR,"11Z001791") == 0 )
	|| ( strcmp(contratR,"11Z001792") == 0 )
	|| ( strcmp(contratR,"11Z002083") == 0 )
	|| ( strcmp(contratR,"11Z002085") == 0 )
	|| ( strcmp(contratR,"11Z002086") == 0 )
	|| ( strcmp(contratR,"11Z002243") == 0 )
	|| ( strcmp(contratR,"11Z002339") == 0 )
	|| ( strcmp(contratR,"11Z002340") == 0 )
	|| ( strcmp(contratR,"11Z002345") == 0 )
	|| ( strcmp(contratR,"11Z002346") == 0 )
	|| ( strcmp(contratR,"11Z002417") == 0 )
	|| ( strcmp(contratR,"11Z002418") == 0 )
	|| ( strcmp(contratR,"11Z002419") == 0 )
	|| ( strcmp(contratR,"11Z002420") == 0 ))
		{
		ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "P.21";
		RETURN_VAL(OK);
		}

	/* ASIE */

	if (( strcmp(contratR,"20N000011") == 0 )
	|| ( strcmp(contratR,"20N000012") == 0 )
	|| ( strcmp(contratR,"20N000013") == 0 )
	|| ( strcmp(contratR,"20N000017") == 0 )
	|| ( strcmp(contratR,"20N000018") == 0 )
	|| ( strcmp(contratR,"20N000023") == 0 )
	|| ( strcmp(contratR,"20N000024") == 0 )
	|| ( strcmp(contratR,"20N000025") == 0 )
	|| ( strcmp(contratR,"20N000026") == 0 )
	|| ( strcmp(contratR,"20N000027") == 0 )
	|| ( strcmp(contratR,"20N000028") == 0 )
	|| ( strcmp(contratR,"20N000035") == 0 )
	|| ( strcmp(contratR,"20N000036") == 0 ))
		{
		ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "P.21";
		RETURN_VAL(OK);
		}

	switch(Local_lob) {
	case 0  : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "A";
		 break;
	
	case 1  : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "P.11";
		 break;
	
	case 2  : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "P.42";
		 break;

	case 3  : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "P.31";
		 break;

	case 4  : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "P.41";
		 break;

	case 5  : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "S.11"; 
		 break;

	case 6  : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "S.11";
		 break;

	case 7  : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "P.34";
		 break;

	case 8  : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "M.11"; 
		 break;

	case 9  : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "M.12";
		 break;

	case 10 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "A.11";
		 break;

	case 11 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "A.12";
		 break;

	case 12 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "C.12"; 
		 break;

	case 13 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "C.13";
		 break;

	case 14 : 
		switch(Local_top) {
			
		case 470 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "P.33";
		 		break;
		case 485 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "P.33";
		 		break;
		case 465 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "C.11";
		 		break;
		case 472 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "C.11";
		 		break;
		case 475 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "C.11";
		 		break;
		case 480 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "C.11";
		 		break;
		case 487 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "C.11";
		 		break;
		case 490 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "C.11";
		 		break;
		case 495 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "C.11";
		 		break;
		case 500 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "C.11";
		 		break;
		default  : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "C.11";
				/*fprintf(ERROR,"filiale %s contrat %s : Erreur LOB - TOP : %d - %d ligne %d\n",ptb_InRec_Cur[TECLEDR_SSD_CF],contratR,Local_lob,Local_top,LINE_NBR);*/
		}
		 break;

	case 15 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "P.32";
		 break;

	case 20 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "P.35";
		 break;

	case 21 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "O.11";
		 break;

	case 22 : 
		switch(Local_gar) {
		
		case 905 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.41";
				 break;
		case 916 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.41";
				 break;
		case 920 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.41";
				 break;
		case 924 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.42";
				 break;
		case 928 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.42";
				 break;
		case 932 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.42";
				 break;
		case 936 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.43";
				 break;
		case 948 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.43";
				 break;
		case 940 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.44";
				 break;
		case 944 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.45";
				 break;
		default  : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.41";
				/*fprintf(ERROR,"filiale %s contrat %s : Erreur LOB - GAR : %d - %d ligne %d\n",ptb_InRec_Cur[TECLEDR_SSD_CF],contratR,Local_lob,Local_gar,LINE_NBR);*/
		}
		break;

	case 30 : 
		switch(Local_gar) {
		
		case 908 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.11"; 
				 break;
		case 912 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.11";
				 break;
		case 900 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.21";
				 break;
		case 904 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.21";
				 break;
		default  : {
			ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.21";
					}
		}
		break;
	
	case 31 : 
		switch(Local_gar) {
		
		case 905 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.41";
				 break;
		case 916 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.41";
				 break;
		case 920 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.41";
				 break;
		case 924 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.42";
				 break;
		case 928 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.42";
				 break;
		case 932 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.42";
				 break;
		case 936 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.43";
				 break;
		case 948 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.43";
				 break;
		case 940 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.44";
				 break;
		case 944 : ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.45";
				 break;
		default  : {
			ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.41";
					}
		}
		break;
	default : {	
			ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "A";
			/*if ( ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '4' )
					ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "L.41";
				else ptb_InRec_Cur[TECLEDR_LOBRET_CF] = "P.11";*/
				/*fprintf(ERROR,"filiale %s contrat %s : Erreur LOB : %d - ligne %d\n",ptb_InRec_Cur[TECLEDR_SSD_CF],contratR,Local_lob,LINE_NBR);*/
				}
 	}

	RETURN_VAL(OK);
}

/*=============================================================================
 objet: Fonction de traitement du poste de la ligne en cours 

 retour: OK si ok
	 ERR si erreur  
=============================================================================*/
int n_ChgPste(char **ptb_InRec_Cur)
{
	char CP_2[3];
	char CP_3[4];
	char CPTE[6];

	int cp_2;
	int cp_3;
	int cpte;

	int i;
	int modified = 0;

	for (i=0 ; i<2 ; i++) CP_2[i] = ptb_InRec_Cur[TECLEDR_TRNCOD_CF][i+2];
	for (i=0 ; i<3 ; i++) CP_3[i] = ptb_InRec_Cur[TECLEDR_TRNCOD_CF][i+2];
	for (i=0 ; i<5 ; i++) CPTE[i] = ptb_InRec_Cur[TECLEDR_TRNCOD_CF][i+2];

	CP_2[2] = '\0';
	CP_3[3] = '\0';
	CPTE[5] = '\0';
	
	cp_2 = atoi(CP_2);
	cp_3 = atoi(CP_3);
	cpte = atoi(CPTE);

	if ( strcmp(ptb_InRec_Cur[TECLEDR_BALSHEY_NF],"1999") != 0 ) 
		RETURN_VAL(ERR);

	if ( ( ptb_InRec_Cur[TECLEDR_TRNCOD_CF][1] == 'C')
	|| ( ptb_InRec_Cur[TECLEDR_TRNCOD_CF][1] == 'I') 
	|| ( ptb_InRec_Cur[TECLEDR_TRNCOD_CF][1] == 'O') 
	|| ( ptb_InRec_Cur[TECLEDR_TRNCOD_CF][1] == 'R') 
	|| ( ptb_InRec_Cur[TECLEDR_TRNCOD_CF][1] == 'S') 
	|| ( ptb_InRec_Cur[TECLEDR_TRNCOD_CF][1] == 'T')) 
		RETURN_VAL(ERR);

	/* Modif ANB le 28/1/00 */
	/* Il faut prendre les L0 pour l'Italie car elles ont été corrigées par ailleurs */

	/* Ne pas prendre les L0 pour l'ITALIE */
	/*if ( ( ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '6')
	&& ( (cpte == 41101) || (cpte == 42101) || (cpte == 43101) ) 
	&&   (ptb_InRec_Cur[TECLEDR_TRNCOD_CF][7] == '5') )
		RETURN_VAL(ERR);*/
    
	/* Ne pas prendre les provisions avec suffixe 5 pour les autres filiales (sauf les pools) */
	if ( (ptb_InRec_Cur[TECLEDR_SSD_CF][0] != '6')
        &&   (ptb_InRec_Cur[TECLEDR_SSD_CF][0] != '2')
	&&   (ptb_InRec_Cur[TECLEDR_SSD_CF][0] != '3')
	&&   (ptb_InRec_Cur[TECLEDR_TRNCOD_CF][2] == '4')
	&&   (ptb_InRec_Cur[TECLEDR_TRNCOD_CF][7] == '5') 
        && strcmp(categ_contratR,"01") != 0)
		RETURN_VAL(ERR);
    
    switch(cp_2) {

	case 10 : ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "1";
		modified = 1; 
		break;
	case 12 : {
		if ( cpte == 12110 ) ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "21";
		else ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "17";
		}
		modified = 1; 
		break;
	case 13 : ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "17";
		modified = 1; 
		break;
	case 14 : ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "17";
		modified = 1; 
		break;
	case 15 : ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "17";
		modified = 1; 
		break;
	case 20 : ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "7";
		modified = 1; 
		break;
	case 30 : ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "1";
		modified = 1; 
		break;
	case 31 : ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "17";
		modified = 1; 
		break;
	case 32 : ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "7";
		modified = 1; 
		break;
	case 40 : {
		if ( ouv(ptb_InRec_Cur[TECLEDR_TRNCOD_CF]) )
			ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "10";
		else ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "11";
		modified = 1; 
		}
		break;
	case 41 : switch(cpte) {
		case 41101 : {
			if ( (ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '2' || ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '3') 
                               && (ptb_InRec_Cur[TECLEDR_TRNCOD_CF][7] == '4') )
		    	ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "5";
			else
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "4";
			modified = 1;
			}
			break;
		case 41901 : { 
			if (  
                               (ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '2' || ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '3') 
                            && (ptb_InRec_Cur[TECLEDR_TRNCOD_CF][7] == '4') 
                           )
		    	ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "5";
                        else
                                ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "4";
			modified = 1; 
                        }
			break;
		default : {
			if ( ouv(ptb_InRec_Cur[TECLEDR_TRNCOD_CF]) )
			/*|| (strcmp(ptb_InRec_Cur[TECLEDR_TRNCOD_CF],"21411002") == 0)
			|| (strcmp(ptb_InRec_Cur[TECLEDR_TRNCOD_CF],"41411002") == 0) )*/
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "4";
			else
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "5";
			modified = 1; 
			}
		}
		break;
	case 42 : switch(cpte) {
		case 42101 : {
			if ( (ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '2' || ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '3') 
                               && (ptb_InRec_Cur[TECLEDR_TRNCOD_CF][7] == '4') )
		    	ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "11";
			else
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "10";
			modified = 1;
			}
			break;
		case 42111 : {
			if (  
                             (ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '2' || ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '3') 
                          && (ptb_InRec_Cur[TECLEDR_TRNCOD_CF][7] == '4') 
                           )
		    	ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "11";
                        else
                                ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "10";
			modified = 1; 
                        }
			break;
		case 42141 : {
			if (  
                             (ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '2' || ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '3') 
                          && (ptb_InRec_Cur[TECLEDR_TRNCOD_CF][7] == '4') 
                           )
		    	ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "11";
                        else
                                ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "10";
			modified = 1; 
                        }
			break;
		case 42151 : {
			if (  
                             (ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '2' || ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '3') 
                          && (ptb_InRec_Cur[TECLEDR_TRNCOD_CF][7] == '4') 
                           )
		    	ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "11";
                        else
                                ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "10";
			modified = 1; 
                        }
			break;
		case 42161 : {
			if (  
                             (ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '2' || ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '3') 
                          && (ptb_InRec_Cur[TECLEDR_TRNCOD_CF][7] == '4') 
                           )
		    	ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "11";
                        else
                                ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "10";
			modified = 1; 
                        }
			break;
		case 42191 : {
			if (  
                             (ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '2' || ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '3') 
                          && (ptb_InRec_Cur[TECLEDR_TRNCOD_CF][7] == '4') 
                           )
		    	ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "11";
                        else
                                ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "10";
			modified = 1; 
                        }
			break;
		case 42401 : {
			if (  
                             (ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '2' || ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '3') 
                          && (ptb_InRec_Cur[TECLEDR_TRNCOD_CF][7] == '4') 
                           )
		    	ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "11";
                        else
                                ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "10";
			modified = 1; 
                        }
			break;
		case 42801 : {
			if (  
                             (ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '2' || ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '3') 
                          && (ptb_InRec_Cur[TECLEDR_TRNCOD_CF][7] == '4') 
                           )
		    	ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "11";
                        else
                                ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "10";
			modified = 1; 
                        }
			break;
		default : {
			if ( ouv(ptb_InRec_Cur[TECLEDR_TRNCOD_CF]) )
			/*|| (strcmp(ptb_InRec_Cur[TECLEDR_TRNCOD_CF],"21421002") == 0)
			|| (strcmp(ptb_InRec_Cur[TECLEDR_TRNCOD_CF],"41421002") == 0)
			|| (strcmp(ptb_InRec_Cur[TECLEDR_TRNCOD_CF],"21421502") == 0) )*/
			   	ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "10";
			else
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "11";
			modified = 1; 
			}
		}
		break;
	case 43 : switch(cpte) {
		case 43101 : {
			if ( (ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '2' || ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '3') 
                               && (ptb_InRec_Cur[TECLEDR_TRNCOD_CF][7] == '4') )
		    	ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "19";
			else
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "18";
			modified = 1;
			}
			break;
		case 43701 : {
			if (  
                             (ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '2' || ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '3') 
                          && (ptb_InRec_Cur[TECLEDR_TRNCOD_CF][7] == '4') 
                           )
		    	ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "19";
                        else
                                ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "18";
			modified = 1; 
                        }
			break;
		default : {
			if ( ouv(ptb_InRec_Cur[TECLEDR_TRNCOD_CF]) )
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "18";
			else
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "19";
			modified = 1; 
			}
		}
		break;
	case 44 : switch(cpte) {
		case 44101 : {
			if (  
                             (ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '2' || ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '3') 
                          && (ptb_InRec_Cur[TECLEDR_TRNCOD_CF][7] == '4') 
                           )
		    	ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "11";
                        else
                                ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "10";
			modified = 1; 
                        }
			break;
		default : {
			if ( ouv(ptb_InRec_Cur[TECLEDR_TRNCOD_CF]) ) 
			/*|| (strcmp(ptb_InRec_Cur[TECLEDR_TRNCOD_CF],"21441002") == 0) )*/
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "10";
			else
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "11";
			modified = 1; 
			}
		}
		break;
	case 45 : ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "17";
		modified = 1; 
		break;
	case 46 : switch(cpte){
		case 46010 : {
			if ( ouv(ptb_InRec_Cur[TECLEDR_TRNCOD_CF]) )
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "10";
			else
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "11";
			modified = 1; 
			}
			break;
		case 46110 : {
			if ( ouv(ptb_InRec_Cur[TECLEDR_TRNCOD_CF]) )
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "10";
			else
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "11";
			modified = 1; 
			}
			break;
		case 46000 : {
			if ( ouv(ptb_InRec_Cur[TECLEDR_TRNCOD_CF]) )
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "14";
			else
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "15";
			modified = 1; 
			}
			break;
		case 46100 : {
			if ( ouv(ptb_InRec_Cur[TECLEDR_TRNCOD_CF]) )
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "14";
			else
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "15";
			modified = 1; 
			}
			break;
		case 46020 : {
			if ( ouv(ptb_InRec_Cur[TECLEDR_TRNCOD_CF]) )
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "10";
			else
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "11";
			modified = 1; 
			}
			break;
		case 46120 : {
			if ( ouv(ptb_InRec_Cur[TECLEDR_TRNCOD_CF]) )
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "4";
			else
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "5";
			modified = 1; 
			}
			break;
		default    : ;
		}
		break;
	case 48 : switch(cpte) {
		case 48101 : {
			if (  
                             (ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '2' || ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '3') 
                          && (ptb_InRec_Cur[TECLEDR_TRNCOD_CF][7] == '4') 
                           )
		    	ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "11";
                        else
                                ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "10";
			modified = 1; 
                        }
			break;
		case 48111 : {
			if (  
                             (ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '2' || ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '3') 
                          && (ptb_InRec_Cur[TECLEDR_TRNCOD_CF][7] == '4') 
                           )
		    	ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "11";
                        else
                                ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "10";
			modified = 1; 
                        }
			break;
		case 48801 : {
			if (  
                             (ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '2' || ptb_InRec_Cur[TECLEDR_SSD_CF][0] == '3') 
                          && (ptb_InRec_Cur[TECLEDR_TRNCOD_CF][7] == '4') 
                           )
		    	ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "11";
                        else
                                ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "10";
			modified = 1; 
                        }
			break;
		default : {
			if ( ouv(ptb_InRec_Cur[TECLEDR_TRNCOD_CF]) )
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "10";
			else
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "11";
			modified = 1; 
			}
		}
		break;
	case 49 : switch(cpte){
		case 49400 : {
			if ( ouv(ptb_InRec_Cur[TECLEDR_TRNCOD_CF]) )
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "10";
			else
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "11";
			modified = 1; 
			}	
			break;
		case 49405 : {
			if ( ouv(ptb_InRec_Cur[TECLEDR_TRNCOD_CF]) )
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "10";
			else
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "11";
			modified = 1; 
			}	
			break;
		case 49500 : {
			if ( ouv(ptb_InRec_Cur[TECLEDR_TRNCOD_CF]) )
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "10";
			else
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "11";
			modified = 1; 
			}
			break;
		case 49505 : {
			if ( ouv(ptb_InRec_Cur[TECLEDR_TRNCOD_CF]) )
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "10";
			else
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "11";
			modified = 1; 
			}
			break;
		default    : {
			if ( ouv(ptb_InRec_Cur[TECLEDR_TRNCOD_CF]) )
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "12";
			else
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "13";
			modified = 1; 
			}
		}
		break;
	default : ; 
	}

	/* if ( ( cp_2 > 39 ) && (cp_2 < 50 ) )
		printf("poste %d ---> %s\n",cpte,ptb_InRec_Cur[TECLEDR_TRNCOD_CF]); */

	if ( modified ) {
		n_ChgRetro(ptb_InRec_Cur);
		n_Write_out(ptb_InRec_Cur);
		}
	
	switch(cp_3) {

	case 300 : ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "2";	
		n_ChgRetro(ptb_InRec_Cur);
		RETURN_VAL(OK); 
		break;	
	case 301 : ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "3";
		n_ChgRetro(ptb_InRec_Cur);
		RETURN_VAL(OK); 
		break;
	case 320 : ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "8";
		n_ChgRetro(ptb_InRec_Cur);
		RETURN_VAL(OK); 
		break;
	case 321 : ptb_InRec_Cur[TECLEDR_TRNCOD_CF] = "9";
		n_ChgRetro(ptb_InRec_Cur);
		RETURN_VAL(OK); 
		break;
	default  : {
		/*if ( modified == 0 ) 
		fprintf(ERROR,"filiale %s contrat %s : Pas de poste correspondant au numero %d ligne %d\n",ptb_InRec_Cur[TECLEDR_SSD_CF],contratR,cpte,LINE_NBR);*/
		RETURN_VAL(ERR);
		}
	}


}

/*=============================================================================
 objet: Fonction de traitement de la nature

 retour: OK  --> Ecriture des changements sur sortie
	 ERR --> Affichage des messages d'erreurs sur stdin  
=============================================================================*/
int n_ChgNat(char **ptb_InRec_Cur)
{
	if ( strcmp(ptb_InRec_Cur[TECLEDR_RETCTRCAT_CF],"02") == 0 ) {
		ptb_InRec_Cur[TECLEDR_RETCTRCAT_CF] = "NP";
		RETURN_VAL(OK);
		}
	else {
		ptb_InRec_Cur[TECLEDR_RETCTRCAT_CF] = "PP";
		RETURN_VAL(OK);
	}
}

/*=============================================================================
 objet: Fonction de traitement du type d'affaires

 retour: OK  --> Ecriture des changements sur sortie
	 ERR --> Affichage des messages d'erreurs sur stdin  
=============================================================================*/
int n_ChgTaf(char **ptb_InRec_Cur)

{
	/* Cas particuliers des facs consideres comme des traites */

	/* EUROPE */

	if (( strcmp(contratR,"01N000001") == 0 )
	|| ( strcmp(contratR,"01N000002") == 0 )
	|| ( strcmp(contratR,"01N000003") == 0 )
	|| ( strcmp(contratR,"01N000004") == 0 )
	|| ( strcmp(contratR,"01N000005") == 0 )
	|| ( strcmp(contratR,"01N000008") == 0 )
	|| ( strcmp(contratR,"01N000009") == 0 )
	|| ( strcmp(contratR,"01N000010") == 0 )
	|| ( strcmp(contratR,"01N000011") == 0 )
	|| ( strcmp(contratR,"01N000014") == 0 )
	|| ( strcmp(contratR,"01N000020") == 0 )
	|| ( (strcmp(contratR,"01P000001") >= 0 ) && (strcmp(contratR,"01P000039") <= 0 ))
	|| ( strcmp(contratR,"01P000055") == 0 )
	|| ( strcmp(contratR,"01P000056") == 0 )
	|| ( strcmp(contratR,"01P000059") == 0 )
	|| ( (strcmp(contratR,"01P000062") >= 0 ) && (strcmp(contratR,"01P000074") <= 0 ))
	|| ( strcmp(contratR,"01P000087") == 0 )
	|| ( strcmp(contratR,"01P000088") == 0 )
	|| ( strcmp(contratR,"01P000089") == 0 )
	|| ( strcmp(contratR,"01P000090") == 0 )
	|| ( strcmp(contratR,"01Z0017RT") == 0 )
	|| ( strcmp(contratR,"01Z0018RT") == 0 )
	|| ( strcmp(contratR,"01Z0019RT") == 0 )
	|| ( strcmp(contratR,"01Z0021RT") == 0 )
	|| ( strcmp(contratR,"01Z0030RT") == 0 )
	|| ( strcmp(contratR,"01Z0032RT") == 0 )
	|| ( strcmp(contratR,"01Z0033RT") == 0 )
	|| ( strcmp(contratR,"01Z0036RT") == 0 )
	|| ( strcmp(contratR,"01Z0039RT") == 0 )
	|| ( strcmp(contratR,"01Z0040RT") == 0 )
	|| ( strcmp(contratR,"01Z0060RT") == 0 )
	|| ( strcmp(contratR,"01Z0062RT") == 0 )
	|| ( strcmp(contratR,"01Z0064RT") == 0 )
	|| ( strcmp(contratR,"01Z0065RT") == 0 )
	|| ( strcmp(contratR,"01Z0078RT") == 0 )
	|| ( strcmp(contratR,"01Z0106RT") == 0 )
	|| ( strcmp(contratR,"01Z0131RT") == 0 )
	|| ( strcmp(contratR,"01Z0141RT") == 0 )
	|| ( strcmp(contratR,"01Z0144RT") == 0 )
	|| ( strcmp(contratR,"01Z0160RT") == 0 )
	|| ( strcmp(contratR,"01Z0200RT") == 0 )
	|| ( strcmp(contratR,"01Z0201RT") == 0 )
	|| ( (strcmp(contratR,"01Z029000") >= 0 ) && (strcmp(contratR,"01Z029022") <= 0 ))
	|| ( strcmp(contratR,"01Z1021RT") == 0 )
	|| ( strcmp(contratR,"01Z1049RT") == 0 )
	|| ( (strcmp(contratR,"01Z129000") >= 0 ) && (strcmp(contratR,"01Z129022") <= 0 ))
	|| ( strcmp(contratR,"01Z2021RT") == 0 )
	|| ( (strcmp(contratR,"01Z229000") >= 0 ) && (strcmp(contratR,"01Z229022") <= 0 ))
	|| ( strcmp(contratR,"01Z3021RT") == 0 )
	|| ( (strcmp(contratR,"01Z329000") >= 0 ) && (strcmp(contratR,"01Z329022") <= 0 ))
	|| ( strcmp(contratR,"01Z4021RT") == 0 )
	|| ( (strcmp(contratR,"01Z429000") >= 0 ) && (strcmp(contratR,"01Z429022") <= 0 ))
	|| ( (strcmp(contratR,"01Z529000") >= 0 ) && (strcmp(contratR,"01Z529018") <= 0 ))
	|| ( strcmp(contratR,"01Z529021") == 0 )
	|| ( strcmp(contratR,"01Z529022") == 0 )
    || ( (strcmp(contratR,"01Z629000") >= 0 ) && (strcmp(contratR,"01Z629018") <= 0 ))
	|| ( strcmp(contratR,"01Z629021") == 0 )
	|| ( strcmp(contratR,"01Z629022") == 0 )
	|| ( (strcmp(contratR,"01Z729000") >= 0 ) && (strcmp(contratR,"01Z729017") <= 0 ))
	|| ( strcmp(contratR,"01Z729021") == 0 )
	|| ( strcmp(contratR,"01Z729022") == 0 )
	|| ( (strcmp(contratR,"01Z829000") >= 0 ) && (strcmp(contratR,"01Z829016") <= 0 ))
	|| ( strcmp(contratR,"01Z829022") == 0 )
	|| ( (strcmp(contratR,"01Z929000") >= 0 ) && (strcmp(contratR,"01Z929016") <= 0 ))
	|| ( strcmp(contratR,"01Z929022") == 0 )
	|| ( (strcmp(contratR,"01ZA29000") >= 0 ) && (strcmp(contratR,"01ZA29014") <= 0 ))
	|| ( strcmp(contratR,"01ZA29022") == 0 )
	|| ( (strcmp(contratR,"01ZB29000") >= 0 ) && (strcmp(contratR,"01ZB29013") <= 0 ))
	|| ( strcmp(contratR,"01ZB29022") == 0 )
	|| ( (strcmp(contratR,"01ZC29000") >= 0 ) && (strcmp(contratR,"01ZC29013") <= 0 ))
	|| ( strcmp(contratR,"01ZC29022") == 0 )
	|| ( (strcmp(contratR,"01ZD29000") >= 0 ) && (strcmp(contratR,"01ZD29013") <= 0 ))
	|| ( strcmp(contratR,"01ZD29022") == 0 )
	|| ( (strcmp(contratR,"01ZE29000") >= 0 ) && (strcmp(contratR,"01ZE29007") <= 0 ))
	|| ( strcmp(contratR,"01ZE29011") == 0 )
	|| ( strcmp(contratR,"01ZE29022") == 0 )
	|| ( (strcmp(contratR,"01ZF29000") >= 0 ) && (strcmp(contratR,"01ZF29007") <= 0 ))
	|| ( strcmp(contratR,"01ZF29022") == 0 )
	|| ( (strcmp(contratR,"01ZG29000") >= 0 ) && (strcmp(contratR,"01ZG29006") <= 0 ))
	|| ( strcmp(contratR,"01ZG29022") == 0 )
    || ( (strcmp(contratR,"01ZH29000") >= 0 ) && (strcmp(contratR,"01ZH29006") <= 0 ))
	|| ( strcmp(contratR,"01ZH29022") == 0 )
    || ( strcmp(contratR,"01ZI29000") == 0 )
	|| ( strcmp(contratR,"01ZI29001") == 0 )
	|| ( strcmp(contratR,"01ZI29002") == 0 )
	|| ( strcmp(contratR,"01ZI29022") == 0 )
	|| ( strcmp(contratR,"01ZJ29000") == 0 )
	|| ( strcmp(contratR,"01ZJ29001") == 0 )
	|| ( strcmp(contratR,"01ZJ29002") == 0 )
	|| ( strcmp(contratR,"01ZJ29022") == 0 )
	|| ( strcmp(contratR,"01ZK29000") == 0 )
	|| ( strcmp(contratR,"01ZK29001") == 0 )
	|| ( strcmp(contratR,"01ZK29022") == 0 )
	|| ( strcmp(contratR,"01ZL29000") == 0 )
	|| ( strcmp(contratR,"01ZL29001") == 0 )
	|| ( strcmp(contratR,"01ZL29022") == 0 )
	|| ( strcmp(contratR,"01ZM29000") == 0 )
	|| ( strcmp(contratR,"01ZM29001") == 0 )
	|| ( strcmp(contratR,"01ZM29022") == 0 )
	|| ( strcmp(contratR,"01ZN29000") == 0 )
	|| ( strcmp(contratR,"01ZN29022") == 0 )
	|| ( strcmp(contratR,"01ZO29000") == 0 )
	|| ( strcmp(contratR,"01ZO29022") == 0 )
	|| ( strcmp(contratR,"01ZP29000") == 0 )
	|| ( strcmp(contratR,"01ZP29022") == 0 )
	|| ( strcmp(contratR,"01ZQ29000") == 0 )
	|| ( strcmp(contratR,"01ZQ29022") == 0 )
	|| ( strcmp(contratR,"01ZR29022") == 0 ))
		{
		/*printf("Pb TF filiale %s contrat %s poste %s ligne %d\n",ptb_InRec_Cur[TECLEDR_SSD_CF],contratR,ptb_InRec_Cur[TECLEDR_TRNCOD_CF],LINE_NBR);*/
		ptb_InRec_Cur[TECLEDR_RETCTR_NF] = "F";
		RETURN_VAL(OK);
		}
    	
	if (( strcmp(contratR,"02N000004") == 0 )
	|| ( strcmp(contratR,"02N000005") == 0 )
	|| ( strcmp(contratR,"02N000025") == 0 )
	|| ( strcmp(contratR,"02N000026") == 0 )
	|| ( strcmp(contratR,"02N000027") == 0 )
	|| ( strcmp(contratR,"02N000028") == 0 )
	|| ( strcmp(contratR,"02N000031") == 0 )
	|| ( strcmp(contratR,"02N000032") == 0 )
	|| ( strcmp(contratR,"02N000033") == 0 )
	|| ( strcmp(contratR,"02P000002") == 0 )
	|| ( strcmp(contratR,"02P000003") == 0 )
	|| ( strcmp(contratR,"02P000010") == 0 )
	|| ( strcmp(contratR,"02Z000045") == 0 )
	|| ( strcmp(contratR,"02Z000047") == 0 )
	|| ( strcmp(contratR,"02Z000049") == 0 )
	|| ( strcmp(contratR,"02Z005049") == 0 )
	|| ( strcmp(contratR,"02Z005333") == 0 )
	|| ( strcmp(contratR,"02Z009268") == 0 )
	|| ( strcmp(contratR,"02Z050118") == 0 )
	|| ( strcmp(contratR,"02Z052033") == 0 )
	|| ( strcmp(contratR,"02Z052220") == 0 )
	|| ( strcmp(contratR,"02Z052222") == 0 )
	|| ( strcmp(contratR,"02Z052333") == 0 )
	|| ( strcmp(contratR,"02Z052361") == 0 )
	|| ( strcmp(contratR,"02Z052365") == 0 )
	|| ( strcmp(contratR,"02Z052384") == 0 )
	|| ( strcmp(contratR,"02Z052432") == 0 )
	|| ( strcmp(contratR,"02Z052435") == 0 )
	|| ( strcmp(contratR,"02Z052491") == 0 )
	|| ( strcmp(contratR,"02Z052503") == 0 )
	|| ( strcmp(contratR,"02Z052523") == 0 )
	|| ( strcmp(contratR,"02Z052524") == 0 )
	|| ( strcmp(contratR,"02Z052525") == 0 )
	|| ( strcmp(contratR,"02Z052535") == 0 )
	|| ( strcmp(contratR,"02Z052565") == 0 )
	|| ( strcmp(contratR,"02Z052566") == 0 )
	|| ( strcmp(contratR,"02Z052625") == 0 )
	|| ( strcmp(contratR,"02Z052626") == 0 )
	|| ( strcmp(contratR,"02Z052627") == 0 )
	|| ( strcmp(contratR,"02Z052628") == 0 )
	|| ( strcmp(contratR,"02Z052630") == 0 )
	|| ( strcmp(contratR,"02Z052633") == 0 )
	|| ( strcmp(contratR,"02Z052660") == 0 )
	|| ( strcmp(contratR,"02Z052667") == 0 )
	|| ( strcmp(contratR,"02Z052672") == 0 )
	|| ( strcmp(contratR,"02Z052673") == 0 )
	|| ( strcmp(contratR,"02Z052674") == 0 )
	|| ( strcmp(contratR,"02Z052675") == 0 )
	|| ( strcmp(contratR,"02Z052676") == 0 )
	|| ( strcmp(contratR,"02Z052679") == 0 )
	|| ( strcmp(contratR,"02Z052681") == 0 )
	|| ( strcmp(contratR,"02Z052732") == 0 )
	|| ( strcmp(contratR,"02Z052737") == 0 )
	|| ( strcmp(contratR,"02Z052756") == 0 )
	|| ( strcmp(contratR,"02Z052768") == 0 )
	|| ( strcmp(contratR,"02Z052778") == 0 )
	|| ( strcmp(contratR,"02Z052779") == 0 ))
		{
		/*printf("Pb TF filiale %s contrat %s poste %s ligne %d\n",ptb_InRec_Cur[TECLEDR_SSD_CF],contratR,ptb_InRec_Cur[TECLEDR_TRNCOD_CF],LINE_NBR);*/
		ptb_InRec_Cur[TECLEDR_RETCTR_NF] = "F";
		RETURN_VAL(OK);
		}

	if ( strcmp(contratR,"04W059074") == 0 )
		{
		/*printf("Pb TF filiale %s contrat %s poste %s ligne %d\n",ptb_InRec_Cur[TECLEDR_SSD_CF],contratR,ptb_InRec_Cur[TECLEDR_TRNCOD_CF],LINE_NBR);*/
		ptb_InRec_Cur[TECLEDR_RETCTR_NF] = "F";
		RETURN_VAL(OK);
		}

	if (( strcmp(contratR,"05C000001") == 0 )
	|| ( strcmp(contratR,"05N000001") == 0 )
	|| ( strcmp(contratR,"05N000002") == 0 )
	|| ( strcmp(contratR,"05N000003") == 0 )
	|| ( strcmp(contratR,"05N000004") == 0 )
	|| ( strcmp(contratR,"05N000005") == 0 )
	|| ( strcmp(contratR,"05N000015") == 0 )
	|| ( strcmp(contratR,"05N000016") == 0 )
	|| ( strcmp(contratR,"05N000017") == 0 )
	|| ( strcmp(contratR,"05N000018") == 0 )
	|| ( strcmp(contratR,"05N000019") == 0 )
	|| ( strcmp(contratR,"05P000001") == 0 )
	|| ( strcmp(contratR,"05P000002") == 0 )
	|| ( strcmp(contratR,"05P000003") == 0 )
	|| ( strcmp(contratR,"05P000004") == 0 )
	|| ( strcmp(contratR,"05P000005") == 0 )
	|| ( strcmp(contratR,"05P000018") == 0 )
	|| ( strcmp(contratR,"05Z085770") == 0 )
	|| ( strcmp(contratR,"05Z085780") == 0 )
	|| ( strcmp(contratR,"05Z085800") == 0 )
	|| ( strcmp(contratR,"05Z08580D") == 0 )
	|| ( strcmp(contratR,"05Z085980") == 0 )
	|| ( strcmp(contratR,"05Z859810") == 0 ))
		{
		/*printf("Pb TF filiale %s contrat %s poste %s ligne %d\n",ptb_InRec_Cur[TECLEDR_SSD_CF],contratR,ptb_InRec_Cur[TECLEDR_TRNCOD_CF],LINE_NBR);*/
		ptb_InRec_Cur[TECLEDR_RETCTR_NF] = "F";
		RETURN_VAL(OK);
		}

	if (( strcmp(contratR,"06C000001") == 0 )
	|| ( strcmp(contratR,"06N000014") == 0 )
	|| ( strcmp(contratR,"06N000018") == 0 )
	|| ( strcmp(contratR,"06N000019") == 0 )
	|| ( strcmp(contratR,"06N000020") == 0 )
	|| ( strcmp(contratR,"06N000021") == 0 )
	|| ( strcmp(contratR,"06N000022") == 0 )
	|| ( strcmp(contratR,"06N000023") == 0 )
	|| ( strcmp(contratR,"06N000024") == 0 )
	|| ( strcmp(contratR,"06N000025") == 0 )
	|| ( strcmp(contratR,"06N000026") == 0 )
	|| ( strcmp(contratR,"06P000019") == 0 )
	|| ( strcmp(contratR,"06P000024") == 0 )
	|| ( strcmp(contratR,"06P000037") == 0 )
	|| ( strcmp(contratR,"06P000038") == 0 )
	|| ( strcmp(contratR,"06P000043") == 0 )
	|| ( strcmp(contratR,"06P000044") == 0 )
	|| ( strcmp(contratR,"06P000048") == 0 )
	|| ( strcmp(contratR,"06P000069") == 0 )
	|| ( strcmp(contratR,"06P000077") == 0 )
	|| ( strcmp(contratR,"06P000078") == 0 )
	|| ( strcmp(contratR,"06P000079") == 0 )
	|| ( strcmp(contratR,"06P000080") == 0 )
	|| ( strcmp(contratR,"06P000081") == 0 )
	|| ( strcmp(contratR,"06P000084") == 0 )
	|| ( strcmp(contratR,"06P000085") == 0 )
	|| ( strcmp(contratR,"06P000086") == 0 )
	|| ( strcmp(contratR,"06P000087") == 0 )
	|| ( strcmp(contratR,"06P000088") == 0 )
	|| ( strcmp(contratR,"06P000090") == 0 ))
    	{
		/*printf("Pb TF filiale %s contrat %s poste %s ligne %d\n",ptb_InRec_Cur[TECLEDR_SSD_CF],contratR,ptb_InRec_Cur[TECLEDR_TRNCOD_CF],LINE_NBR);*/
		ptb_InRec_Cur[TECLEDR_RETCTR_NF] = "F";
		RETURN_VAL(OK);
		}

	/* USA */

	if (( strcmp(contratR,"10N000001") == 0 )
	|| ( strcmp(contratR,"10N000002") == 0 )
	|| ( strcmp(contratR,"10N000003") == 0 )
	|| ( strcmp(contratR,"10N000004") == 0 )
	|| ( strcmp(contratR,"10N000005") == 0 )
	|| ( strcmp(contratR,"10N000016") == 0 )
	|| ( strcmp(contratR,"10N000017") == 0 )
	|| ( strcmp(contratR,"10N000018") == 0 )
	|| ( strcmp(contratR,"10N000019") == 0 )
	|| ( strcmp(contratR,"10N000047") == 0 )
	|| ( strcmp(contratR,"10N000049") == 0 )
	|| ( strcmp(contratR,"10N000052") == 0 )
	|| ( strcmp(contratR,"10N000060") == 0 )
	|| ( strcmp(contratR,"10N000063") == 0 )
	|| ( strcmp(contratR,"10N000079") == 0 )
	|| ( strcmp(contratR,"10N000085") == 0 )
	|| ( strcmp(contratR,"10N000089") == 0 )
	|| ( strcmp(contratR,"10N000090") == 0 )
	|| ( strcmp(contratR,"10N000091") == 0 )
	|| ( strcmp(contratR,"10N000114") == 0 )
	|| ( strcmp(contratR,"10N000126") == 0 )
	|| ( strcmp(contratR,"10N000130") == 0 )
	|| ( strcmp(contratR,"10N000141") == 0 )
	|| ( strcmp(contratR,"10N000142") == 0 )
	|| ( strcmp(contratR,"10N000143") == 0 )
	|| ( strcmp(contratR,"10N000144") == 0 )
	|| ( strcmp(contratR,"10P000001") == 0 )
	|| ( strcmp(contratR,"10P000002") == 0 )
	|| ( strcmp(contratR,"10P000003") == 0 )
	|| ( strcmp(contratR,"10P000004") == 0 )
	|| ( strcmp(contratR,"10P000005") == 0 )
	|| ( strcmp(contratR,"10P000006") == 0 )
	|| ( strcmp(contratR,"10P000008") == 0 )
	|| ( strcmp(contratR,"10P000015") == 0 )
	|| ( strcmp(contratR,"10P000016") == 0 )
	|| ( strcmp(contratR,"10P000017") == 0 )
	|| ( strcmp(contratR,"10P000018") == 0 )
	|| ( strcmp(contratR,"10P000019") == 0 )
	|| ( strcmp(contratR,"10P000020") == 0 )
	|| ( strcmp(contratR,"10P000021") == 0 )
	|| ( strcmp(contratR,"10P000069") == 0 )
	|| ( strcmp(contratR,"10P000070") == 0 )
	|| ( strcmp(contratR,"10P000071") == 0 )
	|| ( strcmp(contratR,"10P000072") == 0 )
	|| ( strcmp(contratR,"10P000073") == 0 )
	|| ( strcmp(contratR,"10P000074") == 0 )
	|| ( strcmp(contratR,"10P000075") == 0 )
	|| ( strcmp(contratR,"10P000076") == 0 )
	|| ( strcmp(contratR,"10P000077") == 0 )
	|| ( strcmp(contratR,"10P000078") == 0 )
	|| ( strcmp(contratR,"10P000079") == 0 )
	|| ( strcmp(contratR,"10P000080") == 0 )
	|| ( strcmp(contratR,"10P000081") == 0 )
	|| ( strcmp(contratR,"10P000082") == 0 )
	|| ( strcmp(contratR,"10P000083") == 0 )
	|| ( strcmp(contratR,"10P000084") == 0 )
	|| ( strcmp(contratR,"10P000097") == 0 )
	|| ( strcmp(contratR,"10P000098") == 0 )
	|| ( strcmp(contratR,"10P000099") == 0 )
	|| ( strcmp(contratR,"10P000100") == 0 )
	|| ( strcmp(contratR,"10P000101") == 0 )
	|| ( strcmp(contratR,"10P000102") == 0 )
	|| ( strcmp(contratR,"10P000103") == 0 )
	|| ( strcmp(contratR,"10P000104") == 0 )
	|| ( strcmp(contratR,"10P000105") == 0 )
	|| ( strcmp(contratR,"10P000106") == 0 )
	|| ( strcmp(contratR,"10P000107") == 0 )
	|| ( strcmp(contratR,"10P000108") == 0 )
	|| ( strcmp(contratR,"10P000109") == 0 )
	|| ( strcmp(contratR,"10ZAltRis") == 0 )
	|| ( strcmp(contratR,"10ZCASXS1") == 0 )
	|| ( strcmp(contratR,"10ZCASXS2") == 0 )
	|| ( strcmp(contratR,"10ZDT0001") == 0 )
	|| ( strcmp(contratR,"10ZDT0002") == 0 )
	|| ( strcmp(contratR,"10ZFacEst") == 0 )
	|| ( strcmp(contratR,"10ZNonRec") == 0 )
	|| ( strcmp(contratR,"10ZO9450A") == 0 )
	|| ( strcmp(contratR,"10ZO9521A") == 0 )
	|| ( strcmp(contratR,"10ZO9521B") == 0 )
	|| ( strcmp(contratR,"10ZO9550A") == 0 )
	|| ( strcmp(contratR,"10ZO9650A") == 0 )
	|| ( strcmp(contratR,"10ZO9650B") == 0 )
	|| ( strcmp(contratR,"10ZO9750A") == 0 )
	|| ( strcmp(contratR,"10ZO9750B") == 0 )
	|| ( strcmp(contratR,"10ZO9850A") == 0 )
	|| ( strcmp(contratR,"10ZO9850B") == 0 )
	|| ( strcmp(contratR,"10ZPR0001") == 0 )
	|| ( strcmp(contratR,"10ZR52033") == 0 )
	|| ( strcmp(contratR,"10ZR52222") == 0 )
	|| ( strcmp(contratR,"10ZRO9021") == 0 )
	|| ( strcmp(contratR,"10ZRO9030") == 0 )
	|| ( strcmp(contratR,"10ZRO9032") == 0 )
	|| ( strcmp(contratR,"10ZRO9033") == 0 )
	|| ( strcmp(contratR,"10ZRO9034") == 0 )
	|| ( strcmp(contratR,"10ZRO9035") == 0 )
	|| ( strcmp(contratR,"10ZRO9036") == 0 )
	|| ( strcmp(contratR,"10ZRO9040") == 0 )
	|| ( strcmp(contratR,"10ZRO9044") == 0 )
	|| ( strcmp(contratR,"10ZRO9050") == 0 )
	|| ( strcmp(contratR,"10ZRO9121") == 0 )
	|| ( strcmp(contratR,"10ZRO9130") == 0 )
	|| ( strcmp(contratR,"10ZRO9132") == 0 )
	|| ( strcmp(contratR,"10ZRO9133") == 0 )
	|| ( strcmp(contratR,"10ZRO9134") == 0 )
	|| ( strcmp(contratR,"10ZRO9135") == 0 )
	|| ( strcmp(contratR,"10ZRO9136") == 0 )
	|| ( strcmp(contratR,"10ZRO9140") == 0 )
	|| ( strcmp(contratR,"10ZRO9144") == 0 )
	|| ( strcmp(contratR,"10ZRO9150") == 0 )
	|| ( strcmp(contratR,"10ZRO9221") == 0 )
	|| ( strcmp(contratR,"10ZRO9230") == 0 )
	|| ( strcmp(contratR,"10ZRO9232") == 0 )
	|| ( strcmp(contratR,"10ZRO9233") == 0 )
	|| ( strcmp(contratR,"10ZRO9234") == 0 )
	|| ( strcmp(contratR,"10ZRO9235") == 0 )
	|| ( strcmp(contratR,"10ZRO9236") == 0 )
	|| ( strcmp(contratR,"10ZRO9240") == 0 )
	|| ( strcmp(contratR,"10ZRO9250") == 0 )
	|| ( strcmp(contratR,"10ZRO9255") == 0 )
	|| ( strcmp(contratR,"10ZRO9256") == 0 )
	|| ( strcmp(contratR,"10ZRO9321") == 0 )
	|| ( strcmp(contratR,"10ZRO9332") == 0 )
	|| ( strcmp(contratR,"10ZRO9336") == 0 )
	|| ( strcmp(contratR,"10ZRO9340") == 0 )
	|| ( strcmp(contratR,"10ZRO9350") == 0 )
	|| ( strcmp(contratR,"10ZRO9355") == 0 )
	|| ( strcmp(contratR,"10ZRO9356") == 0 )
	|| ( strcmp(contratR,"10ZRO9380") == 0 )
	|| ( strcmp(contratR,"10ZRO9421") == 0 )
	|| ( strcmp(contratR,"10ZRO9436") == 0 )
	|| ( strcmp(contratR,"10ZRO9450") == 0 )
	|| ( strcmp(contratR,"10ZRO9455") == 0 )
	|| ( strcmp(contratR,"10ZRO9536") == 0 )
	|| ( strcmp(contratR,"10ZRO9537") == 0 )
	|| ( strcmp(contratR,"10ZRO9555") == 0 )
	|| ( strcmp(contratR,"10ZRO9621") == 0 )
	|| ( strcmp(contratR,"10ZRO9636") == 0 )
	|| ( strcmp(contratR,"10ZRO9637") == 0 )
	|| ( strcmp(contratR,"10ZRO9711") == 0 )
	|| ( strcmp(contratR,"10ZRO9721") == 0 )
	|| ( strcmp(contratR,"10ZRO9821") == 0 )
	|| ( strcmp(contratR,"10ZRO9891") == 0 )
	|| ( strcmp(contratR,"10ZRT0001") == 0 )
	|| ( strcmp(contratR,"10ZRT8621") == 0 )
	|| ( strcmp(contratR,"10ZRT8623") == 0 )
	|| ( strcmp(contratR,"10ZRT8624") == 0 )
	|| ( strcmp(contratR,"10ZRT8631") == 0 )
	|| ( strcmp(contratR,"10ZRT8632") == 0 )
	|| ( strcmp(contratR,"10ZRT8633") == 0 )
	|| ( strcmp(contratR,"10ZRT8634") == 0 )
	|| ( strcmp(contratR,"10ZRT8721") == 0 )
	|| ( strcmp(contratR,"10ZRT8732") == 0 )
	|| ( strcmp(contratR,"10ZRT8733") == 0 )
	|| ( strcmp(contratR,"10ZRT8734") == 0 )
	|| ( strcmp(contratR,"10ZRT8735") == 0 )
	|| ( strcmp(contratR,"10ZRT8736") == 0 )
	|| ( strcmp(contratR,"10ZRT8737") == 0 )
	|| ( strcmp(contratR,"10ZRT8738") == 0 )
	|| ( strcmp(contratR,"10ZRT8821") == 0 )
	|| ( strcmp(contratR,"10ZRT8830") == 0 )
	|| ( strcmp(contratR,"10ZRT8832") == 0 )
	|| ( strcmp(contratR,"10ZRT8833") == 0 )
	|| ( strcmp(contratR,"10ZRT8834") == 0 )
	|| ( strcmp(contratR,"10ZRT8840") == 0 )
	|| ( strcmp(contratR,"10ZRT8921") == 0 )
	|| ( strcmp(contratR,"10ZRT8926") == 0 )
	|| ( strcmp(contratR,"10ZRT8930") == 0 )
	|| ( strcmp(contratR,"10ZRT8932") == 0 )
	|| ( strcmp(contratR,"10ZRT8933") == 0 )
	|| ( strcmp(contratR,"10ZRT8934") == 0 )
	|| ( strcmp(contratR,"10ZRT8935") == 0 )
	|| ( strcmp(contratR,"10ZRT8936") == 0 )
	|| ( strcmp(contratR,"10ZRT8940") == 0 )
	|| ( strcmp(contratR,"10ZRT9012") == 0 )
	|| ( strcmp(contratR,"10ZRT9019") == 0 )
	|| ( strcmp(contratR,"10ZRT9021") == 0 )
	|| ( strcmp(contratR,"10ZU5323A") == 0 )
	|| ( strcmp(contratR,"10ZUT5322") == 0 )
	|| ( strcmp(contratR,"10ZUT5323") == 0 )
	|| ( strcmp(contratR,"10ZUT5324") == 0 )
	|| ( strcmp(contratR,"10ZUT5481") == 0 )
	|| ( strcmp(contratR,"10ZUT5519") == 0 )
	|| ( strcmp(contratR,"10ZUT5699") == 0 )
	|| ( strcmp(contratR,"10ZUT5801") == 0 )
	|| ( strcmp(contratR,"10ZUT5844") == 0 )
	|| ( strcmp(contratR,"10ZUT5856") == 0 )
	|| ( strcmp(contratR,"10ZUT5858") == 0 )
	|| ( strcmp(contratR,"10ZUT5869") == 0 )
	|| ( strcmp(contratR,"10ZUT5870") == 0 )
	|| ( strcmp(contratR,"10ZUT5888") == 0 )
	|| ( strcmp(contratR,"10ZUT5906") == 0 )
	|| ( strcmp(contratR,"10ZUT5918") == 0 )
	|| ( strcmp(contratR,"10ZUT5921") == 0 )
	|| ( strcmp(contratR,"10ZUT5929") == 0 )
	|| ( strcmp(contratR,"10ZW00001") == 0 )
	|| ( strcmp(contratR,"10ZW00002") == 0 ))
		{
		/*printf("Pb TF filiale %s contrat %s poste %s ligne %d\n",ptb_InRec_Cur[TECLEDR_SSD_CF],contratR,ptb_InRec_Cur[TECLEDR_TRNCOD_CF],LINE_NBR);*/
		ptb_InRec_Cur[TECLEDR_RETCTR_NF] = "F";
		RETURN_VAL(OK);
		}

	if (( strcmp(contratR,"11N000002") == 0 )
	|| ( strcmp(contratR,"11N000003") == 0 )
	|| ( strcmp(contratR,"11N000004") == 0 )
	|| ( strcmp(contratR,"11N000005") == 0 )
	|| ( strcmp(contratR,"11N000006") == 0 )
	|| ( strcmp(contratR,"11N000007") == 0 )
	|| ( strcmp(contratR,"11N000008") == 0 )
	|| ( strcmp(contratR,"11N000009") == 0 )
	|| ( strcmp(contratR,"11N000010") == 0 )
	|| ( strcmp(contratR,"11P000001") == 0 )
	|| ( strcmp(contratR,"11P000002") == 0 )
	|| ( strcmp(contratR,"11P000003") == 0 )
	|| ( strcmp(contratR,"11P000004") == 0 )
	|| ( strcmp(contratR,"11P000005") == 0 )
	|| ( strcmp(contratR,"11P000006") == 0 )
	|| ( strcmp(contratR,"11Z000704") == 0 )
	|| ( strcmp(contratR,"11Z000705") == 0 )
	|| ( strcmp(contratR,"11Z000706") == 0 )
	|| ( strcmp(contratR,"11Z000707") == 0 )
	|| ( strcmp(contratR,"11Z000710") == 0 )
	|| ( strcmp(contratR,"11Z000711") == 0 )
	|| ( strcmp(contratR,"11Z000712") == 0 )
	|| ( strcmp(contratR,"11Z000713") == 0 )
	|| ( strcmp(contratR,"11Z000800") == 0 )
	|| ( strcmp(contratR,"11Z000801") == 0 )
	|| ( strcmp(contratR,"11Z000802") == 0 )
	|| ( strcmp(contratR,"11Z000803") == 0 )
	|| ( strcmp(contratR,"11Z000804") == 0 )
	|| ( strcmp(contratR,"11Z000805") == 0 )
	|| ( strcmp(contratR,"11Z000806") == 0 )
	|| ( strcmp(contratR,"11Z000807") == 0 )
	|| ( strcmp(contratR,"11Z000809") == 0 )
	|| ( strcmp(contratR,"11Z000810") == 0 )
	|| ( strcmp(contratR,"11Z000812") == 0 )
	|| ( strcmp(contratR,"11Z000813") == 0 )
	|| ( strcmp(contratR,"11Z000814") == 0 )
	|| ( strcmp(contratR,"11Z000816") == 0 )
	|| ( strcmp(contratR,"11Z000817") == 0 )
	|| ( strcmp(contratR,"11Z000818") == 0 )
	|| ( strcmp(contratR,"11Z000819") == 0 )
	|| ( strcmp(contratR,"11Z000821") == 0 )
	|| ( strcmp(contratR,"11Z000822") == 0 )
	|| ( strcmp(contratR,"11Z000850") == 0 )
	|| ( strcmp(contratR,"11Z000851") == 0 )
	|| ( strcmp(contratR,"11Z000852") == 0 )
	|| ( strcmp(contratR,"11Z000853") == 0 )
	|| ( strcmp(contratR,"11Z000854") == 0 )
	|| ( strcmp(contratR,"11Z000920") == 0 )
	|| ( strcmp(contratR,"11Z000922") == 0 )
	|| ( strcmp(contratR,"11Z000964") == 0 )
	|| ( strcmp(contratR,"11Z000965") == 0 )
	|| ( strcmp(contratR,"11Z001035") == 0 )
	|| ( strcmp(contratR,"11Z001036") == 0 )
	|| ( strcmp(contratR,"11Z001065") == 0 )
	|| ( strcmp(contratR,"11Z001137") == 0 )
	|| ( strcmp(contratR,"11Z001356") == 0 )
	|| ( strcmp(contratR,"11Z001437") == 0 )
	|| ( strcmp(contratR,"11Z001438") == 0 )
	|| ( strcmp(contratR,"11Z001457") == 0 )
	|| ( strcmp(contratR,"11Z001458") == 0 )
	|| ( strcmp(contratR,"11Z001459") == 0 )
	|| ( strcmp(contratR,"11Z001508") == 0 )
	|| ( strcmp(contratR,"11Z001509") == 0 )
	|| ( strcmp(contratR,"11Z001510") == 0 )
	|| ( strcmp(contratR,"11Z001511") == 0 )
	|| ( strcmp(contratR,"11Z001562") == 0 )
	|| ( strcmp(contratR,"11Z001563") == 0 )
	|| ( strcmp(contratR,"11Z001571") == 0 )
	|| ( strcmp(contratR,"11Z001575") == 0 )
	|| ( strcmp(contratR,"11Z001614") == 0 )
	|| ( strcmp(contratR,"11Z001657") == 0 )
	|| ( strcmp(contratR,"11Z001793") == 0 )
	|| ( strcmp(contratR,"11Z001932") == 0 )
	|| ( strcmp(contratR,"11Z002244") == 0 )
	|| ( strcmp(contratR,"11Z002245") == 0 )
	|| ( strcmp(contratR,"11Z002339") == 0 )
	|| ( strcmp(contratR,"11Z002340") == 0 )
	|| ( strcmp(contratR,"11Z002341") == 0 )
	|| ( strcmp(contratR,"11Z002342") == 0 )
	|| ( strcmp(contratR,"11Z002343") == 0 )
	|| ( strcmp(contratR,"11Z002346") == 0 )
	|| ( strcmp(contratR,"11Z002422") == 0 )
	|| ( strcmp(contratR,"11Z002501") == 0 )
	|| ( strcmp(contratR,"11Z002505") == 0 )
	|| ( strcmp(contratR,"11Z002506") == 0 )
	|| ( strcmp(contratR,"11Z002507") == 0 )
	|| ( strcmp(contratR,"11Z002508") == 0 )
	|| ( strcmp(contratR,"11Z002509") == 0 ))
		{
		/*printf("Pb TF filiale %s contrat %s poste %s ligne %d\n",ptb_InRec_Cur[TECLEDR_SSD_CF],contratR,ptb_InRec_Cur[TECLEDR_TRNCOD_CF],LINE_NBR);*/
		ptb_InRec_Cur[TECLEDR_RETCTR_NF] = "F";
		RETURN_VAL(OK);
		}

	/* ASIE */
	
	if (( strcmp(contratR,"20N000001") == 0 )
	|| ( strcmp(contratR,"20N000002") == 0 )
	|| ( strcmp(contratR,"20N000003") == 0 )
	|| ( strcmp(contratR,"20N000004") == 0 )
	|| ( strcmp(contratR,"20N000005") == 0 )
	|| ( strcmp(contratR,"20N000006") == 0 )
	|| ( strcmp(contratR,"20N000007") == 0 )
	|| ( strcmp(contratR,"20N000014") == 0 )
	|| ( strcmp(contratR,"20N000019") == 0 )
	|| ( strcmp(contratR,"20N000020") == 0 )
	|| ( strcmp(contratR,"20N000021") == 0 )
	|| ( strcmp(contratR,"20N000022") == 0 )
	|| ( strcmp(contratR,"20N000029") == 0 )
	|| ( strcmp(contratR,"20N000030") == 0 )
	|| ( strcmp(contratR,"20N000031") == 0 )
	|| ( strcmp(contratR,"20P000001") == 0 )
	|| ( strcmp(contratR,"20P000002") == 0 )
	|| ( strcmp(contratR,"20P000003") == 0 )
	|| ( strcmp(contratR,"20P000004") == 0 )
	|| ( strcmp(contratR,"20P000005") == 0 )
	|| ( strcmp(contratR,"20P000007") == 0 )
	|| ( strcmp(contratR,"20P000011") == 0 )
	|| ( strcmp(contratR,"20P000014") == 0 )
	|| ( strcmp(contratR,"20P000015") == 0 )
	|| ( strcmp(contratR,"20Z302171") == 0 )
	|| ( strcmp(contratR,"20Z302172") == 0 )
	|| ( strcmp(contratR,"20Z302181") == 0 )
	|| ( strcmp(contratR,"20Z302321") == 0 )
	|| ( strcmp(contratR,"20Z302322") == 0 )
	|| ( strcmp(contratR,"20Z302331") == 0 )
	|| ( strcmp(contratR,"20Z302341") == 0 )
	|| ( strcmp(contratR,"20Z302351") == 0 )
	|| ( strcmp(contratR,"20Z302361") == 0 )
	|| ( strcmp(contratR,"20Z302371") == 0 )
	|| ( strcmp(contratR,"20Z302381") == 0 )
	|| ( strcmp(contratR,"20Z302391") == 0 )
	|| ( strcmp(contratR,"20Z302393") == 0 )
	|| ( strcmp(contratR,"20Z302394") == 0 )
	|| ( strcmp(contratR,"20Z302412") == 0 )
	|| ( strcmp(contratR,"20Z302441") == 0 )
	|| ( strcmp(contratR,"20Z302461") == 0 )
	|| ( strcmp(contratR,"20Z302561") == 0 )
	|| ( strcmp(contratR,"20Z302562") == 0 )
	|| ( strcmp(contratR,"20Z302581") == 0 )
	|| ( strcmp(contratR,"20Z302582") == 0 )
	|| ( strcmp(contratR,"20Z302591") == 0 )
	|| ( strcmp(contratR,"20Z302601") == 0 )
	|| ( strcmp(contratR,"20Z302791") == 0 )
	|| ( strcmp(contratR,"20Z302801") == 0 )
	|| ( strcmp(contratR,"20Z302811") == 0 )
	|| ( strcmp(contratR,"20Z302821") == 0 )
	|| ( strcmp(contratR,"20Z302822") == 0 )
	|| ( strcmp(contratR,"20Z302825") == 0 )
	|| ( strcmp(contratR,"20Z302826") == 0 )
	|| ( strcmp(contratR,"20Z302827") == 0 )
	|| ( strcmp(contratR,"20Z302828") == 0 )
	|| ( strcmp(contratR,"20Z302831") == 0 )
	|| ( strcmp(contratR,"20Z302832") == 0 )
	|| ( strcmp(contratR,"20Z302833") == 0 )
	|| ( strcmp(contratR,"20Z302837") == 0 )
	|| ( strcmp(contratR,"20Z600011") == 0 )
	|| ( strcmp(contratR,"20Z600021") == 0 )
	|| ( strcmp(contratR,"20Z600022") == 0 )
	|| ( strcmp(contratR,"20Z600023") == 0 )
	|| ( strcmp(contratR,"20Z600031") == 0 )
	|| ( strcmp(contratR,"20Z600032") == 0 )
	|| ( strcmp(contratR,"20Z600041") == 0 )
	|| ( strcmp(contratR,"20Z600051") == 0 )
	|| ( strcmp(contratR,"20Z600052") == 0 )
	|| ( strcmp(contratR,"20Z601581") == 0 )
	|| ( strcmp(contratR,"20Z601591") == 0 )
	|| ( strcmp(contratR,"20Z601601") == 0 )
	|| ( strcmp(contratR,"20Z601611") == 0 )
	|| ( strcmp(contratR,"20Z601711") == 0 )
	|| ( strcmp(contratR,"20Z601721") == 0 )
	|| ( strcmp(contratR,"20Z601731") == 0 )
	|| ( strcmp(contratR,"20Z601751") == 0 )
	|| ( strcmp(contratR,"20Z601761") == 0 )
	|| ( strcmp(contratR,"20Z601771") == 0 )
	|| ( strcmp(contratR,"20Z601801") == 0 )
	|| ( strcmp(contratR,"20Z601811") == 0 )
	|| ( strcmp(contratR,"20Z601841") == 0 )
	|| ( strcmp(contratR,"20Z601851") == 0 )
	|| ( strcmp(contratR,"20Z601881") == 0 )
	|| ( strcmp(contratR,"20Z601891") == 0 )
	|| ( strcmp(contratR,"20Z601901") == 0 )
	|| ( strcmp(contratR,"20Z601921") == 0 )
	|| ( strcmp(contratR,"20Z601931") == 0 )
	|| ( strcmp(contratR,"20Z601941") == 0 )
	|| ( strcmp(contratR,"20Z601951") == 0 )
	|| ( strcmp(contratR,"20Z610080") == 0 )
	|| ( strcmp(contratR,"20Z610081") == 0 )
	|| ( strcmp(contratR,"20Z610111") == 0 )
	|| ( strcmp(contratR,"20Z610112") == 0 )
	|| ( strcmp(contratR,"20Z610113") == 0 )
	|| ( strcmp(contratR,"20Z610114") == 0 )
	|| ( strcmp(contratR,"20Z610115") == 0 )
	|| ( strcmp(contratR,"20Z610116") == 0 )
	|| ( strcmp(contratR,"20Z611752") == 0 )
	|| ( strcmp(contratR,"20Z611753") == 0 ))
		{
		/*printf("Pb TF filiale %s contrat %s poste %s ligne %d\n",ptb_InRec_Cur[TECLEDR_SSD_CF],contratR,ptb_InRec_Cur[TECLEDR_TRNCOD_CF],LINE_NBR);*/
		ptb_InRec_Cur[TECLEDR_RETCTR_NF] = "F";
		RETURN_VAL(OK);
		}

	/* Cas general */

	if ( ( strcmp(ptb_InRec_Cur[TECLEDR_RETCTRCAT_CF],"05") == 0 ) 
	|| ( strcmp(ptb_InRec_Cur[TECLEDR_RETCTRCAT_CF],"07") == 0 ) 
	|| ( strcmp(ptb_InRec_Cur[TECLEDR_RETCTRCAT_CF],"08") == 0 ) )
		ptb_InRec_Cur[TECLEDR_RETCTR_NF] = "F";
	else
		ptb_InRec_Cur[TECLEDR_RETCTR_NF] = "T";
	RETURN_VAL(OK);
}


/*=============================================================================
 objet: Fonction de traitement de la retro

 retour: OK  --> Ecriture des changements sur sortie
	 ERR --> Affichage des messages d'erreurs sur stdin  
=============================================================================*/
int n_ChgRetro(char **ptb_InRec_Cur)
{
	int modified = 0;
	int Local_rto = atoi(ptb_InRec_Cur[TECLEDR_RTO_NF]); 

	switch(Local_rto) {

	case 22072 : {
		TOP_RTO = "SCORPARIS"; /* filiale 12 */
		n_Write_out(ptb_InRec_Cur);
		TOP_RTO = "SCORAUTRE";
		modified = 1;
		}
		break;
	case 21115 : {
		TOP_RTO = "SCORPARIS"; /* filiale 2 */
		n_Write_out(ptb_InRec_Cur);
		TOP_RTO = "SCORAUTRE";
		modified = 1;
		}
		break;
	case 22231 : {
		TOP_RTO = "SCORPARIS"; /* filiale 3 */
		n_Write_out(ptb_InRec_Cur);
		TOP_RTO = "SCORAUTRE";
		modified = 1;
		}
		break;
	case 40237 : {
		TOP_RTO = "SCORPARIS"; /* filiale 4 */
		n_Write_out(ptb_InRec_Cur);
		TOP_RTO = "SCORAUTRE";
		modified = 1;
		}
		break;
	case 70204 : {
		TOP_RTO = "SCORPARIS"; /* filiale 12 */
		n_Write_out(ptb_InRec_Cur);
		TOP_RTO = "SCORAUTRE";
		modified = 1;
		}
		break;
	case 12040 : TOP_RTO = "SCORAUTRE"; /* filiale 1 */
		modified = 1;
		break;
	/* modif Anb du 7/7/99 */ 
	/* modif Anb du 14/1/00 */ 
	case 30132 : TOP_RTO = "SCORAUTRE";
		modified = 1;
		break;
	/* modif Anb du 7/7/99 */ 
	/* modif Anb du 14/1/00 */ 
	case 40608 : TOP_RTO = "SCORAUTRE";
		modified = 1;
		break;
	case 50157 : TOP_RTO = "SCORAUTRE"; /* filiale 5 */
		modified = 1;
		break;
	case 60018 : TOP_RTO = "SCORAUTRE"; /* filiale 6 */
		modified = 1;
		break;
	case 70130 : TOP_RTO = "SCORAUTRE"; /* filiale 10 */
		modified = 1;
		break;
	case 70131 : TOP_RTO = "SCORAUTRE"; /* filiale 10 */
		modified = 1;
		break;
	case 70147 : TOP_RTO = "SCORAUTRE"; /* filiale 10 */
		modified = 1;
		break;
	/* modif Anb du 7/7/99 */ 
	/* modif Anb du 14/1/00 */ 
	case 70210 : TOP_RTO = "SCORAUTRE";
		modified = 1;
		break;
	/* modif Anb du 7/7/99 */ 
	/* modif Anb du 14/1/00 */ 
	case 70466 : TOP_RTO = "SCORAUTRE";
		modified = 1;
		break;
	case 71080 : TOP_RTO = "SCORAUTRE"; /* filiale 99 */
		modified = 1;
		break;
	case 71851 : TOP_RTO = "SCORAUTRE"; /* filiale 10 */
		modified = 1;
		break;
	/* modif Anb du 7/7/99 */ 
	case 74916 : TOP_RTO = "SCORAUTRE"; /* filiale 10 */
		modified = 1;
		break;
    case 80077 : TOP_RTO = "SCORAUTRE"; /* filiale 11 */
		modified = 1;
		break;
	case 90696 : TOP_RTO = "SCORAUTRE"; /* filiale 20 */
		modified = 1;
		break;
	case 91126 : TOP_RTO = "SCORAUTRE"; /* filiale 20 */
		modified = 1;
		break;
	case 91190 : TOP_RTO = "SCORAUTRE"; /* filiale 20 */
		modified = 1;
		break;
	case 91670 : TOP_RTO = "SCORAUTRE"; /* filiale 20 */
		modified = 1;
		break;
	default : ;
	}
	if ( modified ) n_Write_out(ptb_InRec_Cur);

	TOP_RTO = "TOUT"; /* dans tous les cas */
	RETURN_VAL(OK);
}

/*=============================================================================
 objet: Procedure d'ecriture dans le fichier sortie

 retour:   
=============================================================================*/
int n_Write_out(char **ptb_InRec_Cur) 
{
	fprintf(Kp_GoelPeopOFil,"%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",
        	    ptb_InRec_Cur[TECLEDR_SSD_CF],
                ptb_InRec_Cur[TECLEDR_BALSHEY_NF],
				ptb_InRec_Cur[TECLEDR_TRNCOD_CF],
				ptb_InRec_Cur[TECLEDR_RETCTR_NF],
				ptb_InRec_Cur[TECLEDR_RETCUR_CF],
        		ptb_InRec_Cur[TECLEDR_RETAMT_M],
				ptb_InRec_Cur[TECLEDR_LOBRET_CF],
				ptb_InRec_Cur[TECLEDR_RETCTRCAT_CF],
				TOP_RTO,
				ptb_InRec_Cur[TECLEDR_SOBRET_CF],
				ptb_InRec_Cur[TECLEDR_TOPRET_CF],
				ptb_InRec_Cur[TECLEDR_GARRET_CF],
				contratR,
				ptb_InRec_Cur[TECLEDR_RETSEC_NF],
				ptb_InRec_Cur[TECLEDR_RTY_NF]);
	RETURN_VAL(OK);
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
	|| ( ptb_InRec_Cur[1] == '7' )
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

	/*if ( ouv(ptb_InRec_Cur[TECLEDR_TRNCOD_CF]) == -1 )
			fprintf(ERRORR,"Erreur Rg provision : Filiale %s Contrat %s Poste %s Ligne %d\n",ptb_InRec_Cur[TECLEDR_SSD_CF],contratR,ptb_InRec_Cur[TECLEDR_TRNCOD_CF],LINE_NBR);*/

RETURN_VAL(-1);
}
	
