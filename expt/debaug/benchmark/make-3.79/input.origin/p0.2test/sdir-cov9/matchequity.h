/*
 * FIXME: insert description of the constants below
 * MAXSCORE    : The maximum match score
 * MAXCUBELEVEL: 1 + ceil(ln(MAXSCORE)/ln(2)), 
 *               ie the maximum level the cube goes to.
 */

#ifndef _MATCHEQUITY_H_
#define _MATCHEQUITY_H_

#include "eval.h"

#define MAXSCORE      64
#define MAXCUBELEVEL  7
#define DELTA         0.08
#define DELTABAR      0.06
#define G1            0.25
#define G2            0.15
#define GAMMONRATE    0.25

#define GET_MET(i,j,aafMET) ( ( (i) < 0 ) ? 1.0 : ( ( (j) < 0 ) ? 0.0 : \
						 (aafMET [ i ][ j ]) ) )
#define GET_METPostCrawford(i,afBtilde) ( (i) < 0 ? 1.0 : afBtilde [ i ] )


typedef enum _met {
  MET_ZADEH, MET_SNOWIE, MET_WOOLSEY, MET_JACOBS
} met;

extern char *szMET[ MET_JACOBS + 1 ];

extern float aafMET [ MAXSCORE ][ MAXSCORE ];

extern float afMETPostCrawford [ MAXSCORE ];

extern met metCurrent;
extern int nMaxScore;

void
InitMatchEquity ( met metInit );

extern int
GetPoints ( float arOutput [ 5 ], cubeinfo *pci, float arCP[ 2 ] );

extern float
GetDoublePointDeadCube ( float arOutput [ 5 ], cubeinfo *pci );

#endif
