/*==============================================================================
 Nom de l'application          : Loader programs V2
 Nom du source                 : ESTC3001.c
 Revision                      : $Revision: 1.0 $
 Date de creation              : 11/10/2018
 Auteur                        : Quentin DESMETTRE
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
     Historique des modifications :
[01]  11/10/2018  Q. DEMETTRE  : Creation of program
==============================================================================*/
#ifndef __ESTC2060
#define __ESTC2060

#include <utctlib.h>
#include <struct.h>

#ifndef __STRUCT
static const char SEPARATEUR = '~';
#endif

#define PAT_RATEINDEX_CT 82
#define RETRO_BUF 150

enum ENUM_FWH_NOTBOOKED
{
  FWH_CTR_NF = 0,	/* contract number */
  FWH_SSD_CF,
  FWH_SEC_NF,		/* section */
  FWH_UWY_NF,		/* UWY */
  FWH_UW_NT,	
  FWH_END_NT,		/* endorsement */
  FWH_CMLFUN_R,
  FWH_CLMFUNINT_R,
  FWH_CLMFUNVARINT_R,
  FWH_CLMFUNVARINT_B,
  FWH_CLMFUNVARBASE_CT,
  FWH_CTRTYP_NF,
  FWH_CLMFUNCAS_R,
  FWH_PLC_NT,
  FWH_PLCVER_NT,
  FWH_RTO_NT,
  FWH_ESB_CF
};

/*
typedef struct {
  //char               CTR_NF[10];
  //unsigned char      END_NT;
  //unsigned char      SEC_NF;
  //short              UWY_NF;
  //unsigned char      UW_NT;
  short              BOOL_EXIST;
  short              BOOL_ISCSF;
  double             OSL[PATTERNSII_ANNEES];
  double             IBNR[PATTERNSII_ANNEES];
  double             INCPAT[PATTERNSII_ANNEES];
  char **            CURRENT_LINE;
} T_CSUOE_RETRO;
*/


typedef struct {
  char   CUR_CF[4];
  char   PATTERN_ID[30];
  double AN[PATTERNSII_ANNEES];
  short  RATEINDEX_CT;
} T_FPATTERNSII_FWH;

#endif /* __ESTC2060 */

typedef struct {
  char      CTR_NF[10];
  short      END_NT;
  short      SEC_NF;
  int      UWY_NF;
  short      UW_NT;
  char		CUR_CF[4];

} T_CSUOE_RETRO;

/*
typedef struct
{
  char CTR_NF[10]; 
  short SSD_CF;
  short SEC_NF;		 
  int UWY_NF;	 
  short UW_NT;	
  short END_NT;
  double CMLFUN_R;
  double CLMFUNINT_R;
  double CLMFUNVARINT_R;
  int CLMFUNVARINT_B;
  char CLMFUNVARBASE_CT[32];
  char CTRTYP_NF[2];
  double CLMFUNCAS_R;
  int PLC_NT;
  int PLCVER_NT;
  int RTO_NT;
  short ESB_CF;
  
} T_FUNDHELD;
*/

typedef struct {
	char ** row;
} T_FUNDHELD;
