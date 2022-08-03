/*
 * show.c
 *
 * by Gary Wong <gtw@gnu.org>, 1999, 2000, 2001.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of version 2 of the GNU General Public License as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * $Id: show.c,v 1.52 2001/03/16 15:18:04 gtw Exp $
 */

#include "config.h"

#if HAVE_SYS_IOCTL_H
#include <sys/ioctl.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#if HAVE_UNISTD_H
#include <unistd.h>
#endif
#include <assert.h>

#include "backgammon.h"
#include "drawboard.h"
#include "eval.h"
#include "dice.h"
#include "matchequity.h"

#if USE_GTK
#include "gtkboard.h"
#include "gtkgame.h"
#elif USE_EXT
#include "xgame.h"
#endif

extern char *aszCopying[], *aszWarranty[]; /* from copying.c */

static void ShowEvaluation( evalcontext *pec ) {
    
    outputf( "    %d-ply evaluation.\n"
             "    %d move search candidate%s.\n"
             "    %0.3g cubeless search tolerance.\n"
             "    %.0f%% speed.\n"
             "    %s evaluations.\n\n",
             pec->nPlies, pec->nSearchCandidates, pec->nSearchCandidates == 1 ?
             "" : "s", pec->rSearchTolerance,
             (pec->nReduced) ? 100. * pec->nReduced / 21.0 : 100.,
             pec->fCubeful ? "Cubeful" : "Cubeless" );
}

static void ShowPaged( char **ppch ) {

    int i, nRows = 0;
    char *pchLines;
#ifdef TIOCGWINSZ
    struct winsize ws;
#endif

#if HAVE_ISATTY
    if( isatty( STDIN_FILENO ) ) {
#endif
#ifdef TIOCGWINSZ
	if( !( ioctl( STDIN_FILENO, TIOCGWINSZ, &ws ) ) )
	    nRows = ws.ws_row;
#endif
	if( !nRows && ( pchLines = getenv( "LINES" ) ) )
	    nRows = atoi( pchLines );

	/* FIXME we could try termcap-style tgetnum( "li" ) here, but it
	   hardly seems worth it */
	
	if( !nRows )
	    nRows = 24;

	i = 0;

	while( *ppch ) {
	    outputl( *ppch++ );
	    if( ++i >= nRows - 1 ) {
		GetInput( "-- Press <return> to continue --" );
		
		if( fInterrupt )
		    return;
		
		i = 0;
	    }
	}
#if HAVE_ISATTY
    } else
#endif
	while( *ppch )
	    outputl( *ppch++ );
}

extern void CommandShowAutomatic( char *sz ) {

    static char *szOn = "On", *szOff = "Off";
    
    outputf( "bearoff \t(Play certain non-contact bearoff moves):      \t%s\n"
	    "crawford\t(Enable the Crawford rule as appropriate):     \t%s\n"
	    "doubles \t(Turn the cube when opening roll is a double): \t%d\n"
	    "game    \t(Start a new game after each one is completed):\t%s\n"
	    "move    \t(Play the forced move when there is no choice):\t%s\n"
	    "roll    \t(Roll the dice if no double is possible):      \t%s\n",
	    fAutoBearoff ? szOn : szOff,
	    fAutoCrawford ? szOn : szOff,
	    cAutoDoubles,
	    fAutoGame ? szOn : szOff,
	    fAutoMove ? szOn : szOff,
	    fAutoRoll ? szOn : szOff );
}

extern void CommandShowBoard( char *sz ) {

    int an[ 2 ][ 25 ];
    char szOut[ 2048 ];
    char *ap[ 7 ] = { NULL, NULL, NULL, NULL, NULL, NULL, NULL };
    
    if( !*sz ) {
	if( gs == GAME_NONE )
	    outputl( "No position specified and no game in progress." );
	else
	    ShowBoard();
	
	return;
    }

    /* FIXME handle =n notation */
    if( ParsePosition( an, &sz, NULL ) < 0 )
	return;

#if USE_GUI
    if( fX )
#if USE_GTK
	game_set( BOARD( pwBoard ), an, TRUE, "", "", 0, 0, 0, -1, -1 );
#else
        GameSet( &ewnd, an, TRUE, "", "", 0, 0, 0, -1, -1 );    
#endif
    else
#endif
	outputl( DrawBoard( szOut, an, TRUE, ap ) );
}

extern void CommandShowDelay( char *sz ) {
#if USE_GUI
    if( nDelay )
	outputf( "The delay is set to %d ms.\n",nDelay);
    else
	outputl( "No delay is being used." );
#else
    outputl( "The `show delay' command applies only when using a window "
	  "system." );
#endif
}

extern void CommandShowCache( char *sz ) {

    int c, cLookup, cHit;

    EvalCacheStats( &c, &cLookup, &cHit );

    outputf( "%d cache entries have been used.  %d lookups, %d hits",
	    c, cLookup, cHit );

    if( cLookup > 0x01000000 ) /* calculate carefully to avoid overflow */
	outputf( " (%d%%).", ( cHit + ( cLookup / 200 ) ) /
		 ( cLookup / 100 ) );
    else if( cLookup )
	outputf( " (%d%%).", ( cHit * 100 + cLookup / 2 ) / cLookup );
    else
	outputc( '.' );

    outputc( '\n' );
}

static void ShowCommands( command *pc, char *szPrefix ) {

    char sz[ 64 ], *pch;

    strcpy( sz, szPrefix );
    pch = strchr( sz, 0 );

    for( ; pc->sz; pc++ ) {
	if( !pc->szHelp )
	    continue;

	strcpy( pch, pc->sz );

	if( pc->pc ) {
	    strcat( sz, " " );
	    ShowCommands( pc->pc, sz );
	} else
	    outputl( sz );
    }
}

extern void CommandShowCommands( char *sz ) {

    ShowCommands( acTop, "" );
}

extern void CommandShowConfirm( char *sz ) {

    if( fConfirm )
	outputl( "GNU Backgammon will ask for confirmation before "
	       "aborting games in progress." );
    else
	outputl( "GNU Backgammon will not ask for confirmation "
	       "before aborting games in progress." );
}

extern void CommandShowCopying( char *sz ) {

#if USE_GTK
    if( fX )
	ShowList( aszCopying, "Copying" );
    else
#endif
	ShowPaged( aszCopying );
}

extern void CommandShowCrawford( char *sz ) {

  if( nMatchTo > 0 ) 
    outputl( fCrawford ?
	  "This game is the Crawford game." :
	  "This game is not the Crawford game" );
  else if ( ! nMatchTo )
    outputl( "Crawford rule is not used in money sessions." );
  else
    outputl( "No match is being played." );

}

extern void CommandShowCube( char *sz ) {

    if( gs != GAME_PLAYING ) {
	outputl( "There is no game in progress." );
	return;
    }

    if( fCrawford ) {
	outputl( "The cube is disabled during the Crawford game." );
	return;
    }
    
    if( !fCubeUse ) {
	outputl( "The doubling cube is disabled." );
	return;
    }
	
    outputf( "The cube is at %d, ", nCube );

    if( fCubeOwner == -1 )
	outputl( "and is centred." );
    else
	outputf( "and is owned by %s.", ap[ fCubeOwner ].szName );
}

extern void CommandShowDice( char *sz ) {

    if( gs != GAME_PLAYING ) {
	outputl( "The dice will not be rolled until a game is started." );

	return;
    }

    if( anDice[ 0 ] < 1 )
	outputf( "%s has not yet rolled the dice.\n", ap[ fMove ].szName );
    else
	outputf( "%s has rolled %d and %d.\n", ap[ fMove ].szName, anDice[ 0 ],
		anDice[ 1 ] );
}

extern void CommandShowDisplay( char *sz ) {

    if( fDisplay )
	outputl( "GNU Backgammon will display boards for computer moves." );
    else
	outputl( "GNU Backgammon will not display boards for computer moves." );
}

extern void CommandShowEvaluation( char *sz ) {

    outputl( "`eval' and `hint' will use:" );
    ShowEvaluation( &ecEval );
}

extern void CommandShowJacoby( char *sz ) {

    if ( fJacoby ) 
      outputl( "Money sessions are played with the Jacoby rule." );
    else
      outputl( "Money sessions are played without the Jacoby rule." );

}

extern void CommandShowNackgammon( char *sz ) {

    if( fNackgammon )
	outputl( "New games will use the Nackgammon starting position." );
    else
	outputl( "New games will use the standard backgammon starting "
	      "position." );
}

extern void CommandShowPipCount( char *sz ) {

    int anPips[ 2 ], an[ 2 ][ 25 ];

    if( !*sz && gs == GAME_NONE ) {
	outputl( "No position specified and no game in progress." );
	return;
    }
    
    if( ParsePosition( an, &sz, NULL ) < 0 )
	return;
    
    PipCount( an, anPips );
    
    outputf( "The pip counts are: %s %d, %s %d.\n", ap[ fMove ].szName,
	    anPips[ 1 ], ap[ !fMove ].szName, anPips[ 0 ] );
}

extern void CommandShowPlayer( char *sz ) {

    int i;

    for( i = 0; i < 2; i++ ) {
	outputf( "Player %d:\n"
		"  Name: %s\n"
		"  Type: ", i, ap[ i ].szName );

	switch( ap[ i ].pt ) {
	case PLAYER_EXTERNAL:
	    outputl( "external\n" );
	    break;
	case PLAYER_GNU:
	    outputf( "gnubg:\n" );
	    ShowEvaluation( &ap[ i ].ec );
	    break;
	case PLAYER_PUBEVAL:
	    outputl( "pubeval\n" );
	    break;
	case PLAYER_HUMAN:
	    outputl( "human\n" );
	    break;
	}
    }
}

extern void CommandShowPostCrawford( char *sz ) {

  if( nMatchTo > 0 ) 
    outputl( fPostCrawford ?
	  "This is post-Crawford play." :
	  "This is not post-Crawford play." );
  else if ( ! nMatchTo )
    outputl( "Crawford rule is not used in money sessions." );
  else
    outputl( "No match is being played." );

}

extern void CommandShowPrompt( char *sz ) {

    outputf( "The prompt is set to `%s'.\n", szPrompt );
}

extern void CommandShowRNG( char *sz ) {

  static char *aszRNG[] = {
    "ANSI", "BSD", "ISAAC", "manual", "MD5", "Mersenne Twister",
    "user supplied"
  };

  outputf( "You are using the %s generator.\n",
	  aszRNG[ rngCurrent ] );
    
}

extern void CommandShowRollout( char *sz ) {

    outputl( "Rollouts will use:" );
    ShowEvaluation( &ecRollout );

    outputf( "%d game%s will be played per rollout, truncating after %d "
	    "pl%s.\nLookahead variance reduction is %sabled.\n",
	    nRollouts, nRollouts == 1 ? "" : "s", nRolloutTruncate,
	    nRolloutTruncate == 1 ? "y" : "ies", fVarRedn ? "en" : "dis" );
}

extern void CommandShowScore( char *sz ) {

    /* FIXME this display will be wrong if the current game is not the
       last one */
    outputf( "The score (after %d game%s) is: %s %d, %s %d",
	    cGames, cGames == 1 ? "" : "s",
	    ap[ 0 ].szName, anScore[ 0 ],
	    ap[ 1 ].szName, anScore[ 1 ] );

    if ( nMatchTo > 0 ) {
        outputf ( nMatchTo == 1 ? 
	         " (match to %d point%s).\n" :
	         " (match to %d points%s).\n",
                 nMatchTo,
		 fCrawford ? 
		 ", Crawford game" : ( fPostCrawford ?
					 ", post-Crawford play" : ""));
    } 
    else {
        if ( fJacoby )
	    outputl ( " (money session,\nwith Jacoby rule).\n" );
        else
	    outputl ( " (money session,\nwithout Jacoby rule).\n" );
    }

}

extern void CommandShowSeed( char *sz ) {

    PrintRNGSeed();
}

extern void CommandShowTurn( char *sz ) {

    if( gs != GAME_PLAYING ) {
	outputl( "No game is being played." );

	return;
    }
    
    outputf( "%s is on %s.\n", ap[ fMove ].szName,
	    anDice[ 0 ] ? "move" : "roll" );

    if( fResigned )
	outputf( "%s has offered to resign a %s.\n", ap[ fMove ].szName,
		aszGameResult[ fResigned - 1 ] );
}

extern void CommandShowWarranty( char *sz ) {

#if USE_GTK
    if( fX )
	ShowList( aszWarranty, "Warranty" );
    else
#endif
	ShowPaged( aszWarranty );
}

extern void CommandShowKleinman( char *sz ) {

    int anPips[ 2 ], an[ 2 ][ 25 ];
    float fKC;

    if( !*sz && gs == GAME_NONE ) {
        outputl( "No position specified and no game in progress." );
        return;
    }
 
    if( ParsePosition( an, &sz, NULL ) < 0 )
	return;
     
    PipCount( an, anPips );
 
    fKC = KleinmanCount (anPips[1], anPips[0]);
    if (fKC == -1.0)
        outputf ("Pipcount unsuitable for Kleinman Count.\n");
    else
        outputf ("Cubeless Winning Chance: %.4f\n", fKC);
 }

extern void CommandShowThorp( char *sz ) {

    int anPips[ 2 ], an[ 2 ][ 25 ];
    int nLeader, nTrailer, nDiff, anCovered[2], anMenLeft[2];
    int x;

    if( !*sz && gs == GAME_NONE ) {
        outputl( "No position specified and no game in progress." );
        return;
    }

    if( ParsePosition( an, &sz, NULL ) < 0 )
	return;

    PipCount( an, anPips );

  anMenLeft[0] = 0;
  anMenLeft[1] = 0;
  for (x = 0; x < 25; x++)
    {
      anMenLeft[0] += an[0][x];
      anMenLeft[1] += an[1][x];
    }

  anCovered[0] = 0;
  anCovered[1] = 0;
  for (x = 0; x < 6; x++)
    {
      if (an[0][x])
        anCovered[0]++;
      if (an[1][x])
        anCovered[1]++;
    }

        nLeader = anPips[1];
        nLeader += 2*anMenLeft[1];
        nLeader += an[1][0];
        nLeader -= anCovered[1];

        if (nLeader > 30) {
         if ((nLeader % 10) > 5)
        {
           nLeader *= 1.1;
           nLeader += 1;
        }
         else
          nLeader *= 1.1;
        }
        nTrailer = anPips[0];
        nTrailer += 2*anMenLeft[0];
        nTrailer += an[0][0];
        nTrailer -= anCovered[0];

        outputf("L = %d  T = %d  -> ", nLeader, nTrailer);
        if (nTrailer >= (nLeader - 1))
          output("re");
        if (nTrailer >= (nLeader - 2))
          output("double/");
        if (nTrailer < (nLeader - 2))
          output("no double/");
        if (nTrailer >= (nLeader + 2))
          outputl("drop");
        else
          outputl("take");

	if( ( nDiff = nTrailer - nLeader ) > 13 )
	    nDiff = 13;
	else if( nDiff < -37 )
	    nDiff = -37;
	
        outputf("Bower's interpolation: %d%% cubeless winning "
                "chance\n", 74 + 2 * nDiff );
}

extern void CommandShowBeavers( char *sz ) {

    if ( fBeavers )
	outputl( "Beavers, racoons, and other critters are allowed in"
		 " money sessions." );
    else
	outputl( "Beavers, racoons, and other critters are not allowed in"
		 " money sessions." );
}

extern void CommandShowGammonPrice ( char *sz ) {

  cubeinfo ci;
  int i;

  if( gs != GAME_PLAYING ) {
    outputl( "No game in progress (type `new game' to start one)." );

    return;
  }
      
  SetCubeInfo ( &ci, nCube, fCubeOwner, fMove, nMatchTo, anScore,
		fCrawford, fJacoby, fBeavers );

  output ( "Player        Gammon price    Backgammon price\n" );

  for ( i = 0; i < 2; i++ ) {

    outputf ("%-12s     %7.5f         %7.5f\n",
	     ap[ i ].szName,
	     ci.arGammonPrice[ i ], ci.arGammonPrice[ 2 + i ] );
  }

}


extern void CommandShowMatchEquityTable ( char *sz ) {

  /* Read a number n. */

  int n = ParseNumber ( &sz );
  int i, j;

  /* If n > 0 write n x n match equity table,
     else if match write nMatchTo x nMatchTo table,
     else write full table (may be HUGE!) */

  if ( ( n <= 0 ) || ( n > nMaxScore ) ) {
    if ( nMatchTo )
      n = nMatchTo;
    else
      n = nMaxScore;
  }

#if USE_GTK
  if( fX ) {
      GTKShowMatchEquityTable( n );
      return;
  }
#endif

  output ( "Match equity table: " );
  outputl( szMET[ metCurrent ] );
  outputl( "" );
  
  /* Write column headers */

  output ( "          " );
  for ( j = 0; j < n; j++ )
    outputf ( " %3i-away ", j + 1 );
  output ( "\n" );

  for ( i = 0; i < n; i++ ) {
    
    outputf ( " %3i-away ", i + 1 );
    
    for ( j = 0; j < n; j++ )
      outputf ( " %8.4f ", GET_MET ( i, j, aafMET ) * 100.0 );
    output ( "\n" );
  }
  output ( "\n" );

}

extern void CommandShowOutput( char *sz ) {

    outputf( "Match equities will be shown as %s.\n", fOutputMatchPC ?
	    "percentages" : "probabilities" );

    if ( fOutputMWC )
	outputl( "Output shown in MWC (match winning chance) "
	      "(match play only)." ); 
    else
	outputl( "Output shown in EMG (normalized money game equity) "
	      "(match play only)." ); 

    outputf( "Winning chances will be shown as %s.\n", fOutputWinPC ?
	    "percentages" : "probabilities" );

#if USE_GUI
    if( !fX )
#endif
	outputf( "Boards will be shown in %s.\n", fOutputRawboard ?
		 "raw format" : "ASCII" );
}

extern void CommandShowTraining( char *sz ) {

    outputf( "Learning rate (alpha) %f,\n", rAlpha );

    if( rAnneal )
	outputf( "Annealing rate %f,\n", rAnneal );
    else
	outputl( "Annealing disabled," );

    if( rThreshold )
	outputf( "Error threshold %f.\n", rThreshold );
    else
	outputl( "Error threshold disabled." );
}

extern void CommandShowMarketWindow ( char * sz ) {

  cubeinfo ci;

  float arOutput[ NUM_OUTPUTS ];
  float rG[ 2 ], rBG[ 2 ];
  float arDP1[ 2 ], arDP2[ 2 ],arCP1[ 2 ], arCP2[ 2 ];
  float rDTW, rDTL, rNDW, rNDL, rDP, rRisk, rGain, r;

  int i, fAutoRedouble[ 2 ], afDead[ 2 ], anNormScore[ 2 ];

  if( gs != GAME_PLAYING ) {
    outputl( "No game in progress (type `new game' to start one)." );

    return;
  }
      
  /* Show market window */

  /* First, get gammon and backgammon percentages */

  SetCubeInfo ( &ci, nCube, fCubeOwner, fMove, nMatchTo, anScore,
		fCrawford, fJacoby, fBeavers );

  /* see if ratios are given on command line */

  rG[ 0 ] = ParseReal ( &sz );

  if ( rG[ 0 ] >= 0 ) {

    /* read the others */

    rG[ 1 ]  = ( (r = ParseReal ( &sz ) ) > 0.0) ? r : 0.0;
    rBG[ 0 ] = ( (r = ParseReal ( &sz ) ) > 0.0) ? r : 0.0;
    rBG[ 1 ] = ( (r = ParseReal ( &sz ) ) > 0.0) ? r : 0.0;

    /* If one of the ratios are larger than 1 we assume the user
       has entered 25.1 instead of 0.251 */

    if ( rG[ 0 ] > 1.0 || rG[ 1 ] > 1.0 ||
         rBG[ 1 ] > 1.0 || rBG[ 1 ] > 1.0 ) {
      rG[ 0 ]  /= 100.0;
      rG[ 1 ]  /= 100.0;
      rBG[ 0 ] /= 100.0;
      rBG[ 1 ] /= 100.0;
    }

    /* Check that ratios are 0 <= ratio <= 1 */

    for ( i = 0; i < 2; i++ ) {
      if ( rG[ i ] > 1.0 ) {
        outputf ( "illegal gammon ratio for player %i: %f\n",
                  i, rG[ i ] );
        return ;
      }
      if ( rBG[ i ] > 1.0 ) {
        outputf ( "illegal backgammon ratio for player %i: %f\n",
                  i, rBG[ i ] );
        return ;
      }
    }

    /* Transfer rations to arOutput
       (used in call to GetPoints below)*/ 

    arOutput[ OUTPUT_WIN ] = 0.5;
    arOutput[ OUTPUT_WINGAMMON ] =
      ( rG[ fMove ] + rBG[ fMove ] ) * 0.5;
    arOutput[ OUTPUT_LOSEGAMMON ] =
      ( rG[ ! fMove ] + rBG[ ! fMove ] ) * 0.5;
    arOutput[ OUTPUT_WINBACKGAMMON ] = rBG[ fMove ] * 0.5;
    arOutput[ OUTPUT_LOSEBACKGAMMON ] = rBG[ ! fMove ] * 0.5;

  } else {

    /* calculate them based on current position */

    if( EvaluatePosition( anBoard, arOutput, &ci, &ecEval ) < 0 )
      return;

    if ( arOutput[ OUTPUT_WIN ] > 0.0 ) {
      rG[ fMove ] = ( arOutput[ OUTPUT_WINGAMMON ] -
                      arOutput[ OUTPUT_WINBACKGAMMON ] ) /
        arOutput[ OUTPUT_WIN ];
      rBG[ fMove ] = arOutput[ OUTPUT_WINBACKGAMMON ] /
        arOutput[ OUTPUT_WIN ];
    }
    else {
      rG[ fMove ] = 0.0;
      rBG[ fMove ] = 0.0;
    }

    if ( arOutput[ OUTPUT_WIN ] < 1.0 ) {
      rG[ ! fMove ] = ( arOutput[ OUTPUT_LOSEGAMMON ] -
                        arOutput[ OUTPUT_LOSEBACKGAMMON ] ) /
        ( 1.0 - arOutput[ OUTPUT_WIN ] );
      rBG[ ! fMove ] = arOutput[ OUTPUT_LOSEBACKGAMMON ] /
        ( 1.0 - arOutput[ OUTPUT_WIN ] );
    }
    else {
      rG[ ! fMove ] = 0.0;
      rBG[ ! fMove ] = 0.0;
    }

  }

  for ( i = 0; i < 2; i++ ) 
    outputf ( "Player %-25s: gammon rate %6.2f%%, bg rate %6.2f%%\n",
              ap[ i ].szName, rG[ i ] * 100.0, rBG[ i ] * 100.0);


  if ( ! nMatchTo ) return; /* FIXME */

  if ( nMatchTo ) {

    for ( i = 0; i < 2; i++ )
      anNormScore[ i ] = nMatchTo - anScore[ i ];

    GetPoints ( arOutput, &ci, arCP2 );

    for ( i = 0; i < 2; i++ ) {

      fAutoRedouble [ i ] =
        ( anNormScore[ i ] - 2 * nCube <= 0 ) &&
        ( anNormScore[ ! i ] - 2 * nCube > 0 );

      afDead[ i ] =
        ( anNormScore[ ! i ] - 2 * nCube <=0 );

      /* MWC for "double, take; win" */

      rDTW =
        (1.0 - rG[ i ] - rBG[ i ]) *
        GET_MET ( anNormScore[ i ] - 2 * nCube - 1,
                  anNormScore[ !i ] - 1, aafMET )
        + rG[ i ] * GET_MET ( anNormScore[ i ] - 4 * nCube - 1,
                              anNormScore[ ! i ] - 1, aafMET )
        + rBG[ i ] * GET_MET ( anNormScore[ i ] - 6 * nCube - 1,
                               anNormScore[ ! i ] - 1, aafMET );

      /* MWC for "no double, take; win" */

      rNDW =
        (1.0 - rG[ i ] - rBG[ i ]) *
        GET_MET ( anNormScore[ i ] - nCube - 1,
                  anNormScore[ !i ] - 1, aafMET )
        + rG[ i ] * GET_MET ( anNormScore[ i ] - 2 * nCube - 1,
                              anNormScore[ ! i ] - 1, aafMET )
        + rBG[ i ] * GET_MET ( anNormScore[ i ] - 3 * nCube - 1,
                               anNormScore[ ! i ] - 1, aafMET );

      /* MWC for "Double, take; lose" */

      rDTL =
        (1.0 - rG[ ! i ] - rBG[ ! i ]) *
        GET_MET ( anNormScore[ i ] - 1,
                  anNormScore[ !i ] - 2 * nCube - 1, aafMET )
        + rG[ ! i ] * GET_MET ( anNormScore[ i ] - 1,
                              anNormScore[ ! i ] - 4 * nCube - 1, aafMET )
        + rBG[ ! i ] * GET_MET ( anNormScore[ i ] - 1,
                               anNormScore[ ! i ] - 6 * nCube - 1, aafMET );

      /* MWC for "No double; lose" */

      rNDL =
        (1.0 - rG[ ! i ] - rBG[ ! i ]) *
        GET_MET ( anNormScore[ i ] - 1,
                  anNormScore[ !i ] - 1 * nCube - 1, aafMET )
        + rG[ ! i ] * GET_MET ( anNormScore[ i ] - 1,
                              anNormScore[ ! i ] - 2 * nCube - 1, aafMET )
        + rBG[ ! i ] * GET_MET ( anNormScore[ i ] - 1,
                               anNormScore[ ! i ] - 3 * nCube - 1, aafMET );

      /* MWC for "Double, pass" */

      rDP = GET_MET( anNormScore[ i ] - nCube - 1,
                     anNormScore[ ! i ] - 1, aafMET );

      /* Double point */

      rRisk = rNDL - rDTL;
      rGain = rDTW - rNDW;

      arDP1 [ i ] = rRisk / ( rRisk + rGain );
      arDP2 [ i ] = arDP1 [ i ];

      /* Dead cube take point without redouble */

      rRisk = rDTW - rDP;
      rGain = rDP - rDTL;

      arCP1 [ i ] = 1.0 - rRisk / ( rRisk + rGain );

      if ( fAutoRedouble[ i ] ) {

        /* With redouble */

        rDTW =
          (1.0 - rG[ i ] - rBG[ i ]) *
          GET_MET ( anNormScore[ i ] - 4 * nCube - 1,
                    anNormScore[ !i ] - 1, aafMET )
          + rG[ i ] * GET_MET ( anNormScore[ i ] - 8 * nCube - 1,
                                anNormScore[ ! i ] - 1, aafMET )
          + rBG[ i ] * GET_MET ( anNormScore[ i ] - 12 * nCube - 1,
                                 anNormScore[ ! i ] - 1, aafMET );

        rDTL =
          (1.0 - rG[ ! i ] - rBG[ ! i ]) *
          GET_MET ( anNormScore[ i ] - 1,
                    anNormScore[ !i ] - 4 * nCube - 1, aafMET )
          + rG[ ! i ] * GET_MET ( anNormScore[ i ] - 1,
                                  anNormScore[ ! i ] - 8 * nCube - 1, aafMET )
          + rBG[ ! i ] * GET_MET ( anNormScore[ i ] - 1,
                                   anNormScore[ ! i ] - 12 * nCube - 1, aafMET );

        rRisk = rDTW - rDP;
        rGain = rDP - rDTL;

        arCP2 [ i ] = 1.0 - rRisk / ( rRisk + rGain );

        /* Double point */

        rRisk = rNDL - rDTL;
        rGain = rDTW - rNDW;
      
        arDP2 [ i ] = rRisk / ( rRisk + rGain );

      }
    }

    /* output */

    output ( "\n\n" );

    for ( i = 0; i < 2; i++ ) {

      outputf ("Player %s market window:\n\n", ap[ i ].szName );

      if ( fAutoRedouble[ i ] )
        output ("Dead cube (opponent doesn't redouble): ");
      else
        output ("Dead cube: ");

      outputf ("%6.2f%% - %6.2f%%\n", 100. * arDP1[ i ], 100. * arCP1[
                                                                      i ] );

      if ( fAutoRedouble[ i ] ) 
        outputf ("Dead cube (opponent redoubles):"
                 "%6.2f%% - %6.2f%%\n\n",
                 100. * arDP2[ i ], 100. * arCP2[ i ] );
      else if ( ! afDead[ i ] )
        outputf ("Live cube:"
                 "%6.2f%% - %6.2f%%\n\n",
                 100. * arDP2[ i ], 100. * arCP2[ i ] );

    }

  }

}

