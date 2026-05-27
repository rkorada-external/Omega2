#!/bin/ksh
#=============================================================================
# application name               : SEGMENTATION - CREATE MISSING INDEXES
# source name                    : ESEJ2040.cmd
# revision                       : $Revision:   1.0  $
# creation date                  : 31/03/2014
# author                         : P. AVISSEAU
# specifications references      : 
#-----------------------------------------------------------------------------
# description :
# Create indexes for completed Group Segmentations
#-----------------------------------------------------------------------------
# Modification history:
#   <dd/mm/yyyy>  <author>          <comment>
#===============================================================================

. ${DUTI}/fctgen.cmd

# Initialize the chain
CHAININIT $0 $1

NJOB=ESEJ2041
${DCMD}/ESEJ2041.cmd 2>&1 | ${TEE}

CHAINEND
