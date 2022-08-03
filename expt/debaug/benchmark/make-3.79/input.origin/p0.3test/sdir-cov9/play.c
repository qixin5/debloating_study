/*
 * play.c
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
 * $Id: play.c,v 1.60 2001/03/16 15:19:00 gtw Exp $
 */

#include "config.h"

#include <assert.h>
#include <ctype.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#if HAVE_SYS_TIME_H
#include <sys/time.h>
#endif
#if HAVE_UNISTD_H
#include <unistd.h>
#endif

#include "backgammon.h"
#include "dice.h"
#include "drawboard.h"
#include "external.h"
#include "eval.h"
#include "positionid.h"
#include "matchequity.h"

char *aszGameResult[] = { "single game", "gammon", "backgammon" };
list lMatch, *plGame, *plLastMove;
static int fComputerDecision = FALSE;

#if USE_GTK
#if HAVE_GDK_GDKX_H
#include <gdk/gdkx.h> /* for ConnectionNumber GTK_DISPLAY -- get rid of this */
#endif
#include "gtkgame.h"
#endif

static void PlayMove( int anMove[ 8 ], int fPlayer ) {

    int i, nSrc, nDest;
    
    if( fMove != -1 && fPlayer != fMove )
	SwapSides( anBoard );
    
    for( i = 0; i < 8; i += 2 ) {
	nSrc = anMove[ i ];
	nDest = anMove[ i | 1 ];

	if( nSrc < 0 )
	    /* move is finished */
	    break;
	
	if( !anBoard[ 1 ][ nSrc ] )
	    /* source point is empty; ignore */
	    continue;

	anBoard[ 1 ][ nSrc ]--;
	if( nDest >= 0 )
	    anBoard[ 1 ][ nDest ]++;

	if( nDest >= 0 && nDest <= 23 ) {
	    anBoard[ 0 ][ 24 ] += anBoard[ 0 ][ 23 - nDest ];
	    anBoard[ 0 ][ 23 - nDest ] = 0;
	}
    }

    fMove = fTurn = !fPlayer;
    SwapSides( anBoard );    
}

static void ApplyGameOver( void ) {

    movegameinfo *pmgi = plGame->plNext->p;

    assert( pmgi->mt == MOVE_GAMEINFO );

    if( pmgi->fWinner < 0 )
	return;
    
    anScore[ pmgi->fWinner ] += pmgi->nPoints;
}

static void ApplyMoveRecord( moverecord *pmr ) {

    int n;
    movegameinfo *pmgi = plGame->plNext->p;

    assert( pmr->mt == MOVE_GAMEINFO || pmgi->mt == MOVE_GAMEINFO );
    
    fResigned = FALSE;
    gs = GAME_PLAYING;
    
    switch( pmr->mt ) {
    case MOVE_GAMEINFO:
	InitBoard( anBoard );

	nMatchTo = pmr->g.nMatch;
	anScore[ 0 ] = pmr->g.anScore[ 0 ];
	anScore[ 1 ] = pmr->g.anScore[ 1 ];
	
	gs = GAME_NONE;
	fMove = fTurn = fCubeOwner = -1;
	anDice[ 0 ] = anDice[ 1 ] = 0;
	fResigned = fDoubled = FALSE;
	nCube = 1 << pmr->g.nAutoDoubles;
	fCrawford = pmr->g.fCrawfordGame;
	fPostCrawford = !fCrawford && ( anScore[ 0 ] == nMatchTo - 1 ||
					anScore[ 1 ] == nMatchTo - 1 );
	break;
	
    case MOVE_DOUBLE:
	if( nCube >= MAX_CUBE )
	    break;
	
	if( fDoubled ) {
	    nCube <<= 1;
	    fCubeOwner = !fMove;
	} else
	    fDoubled = TRUE;
	
	fTurn = !pmr->d.fPlayer;
	break;

    case MOVE_TAKE:
	if( !fDoubled )
	    break;
	
	nCube <<= 1;
	fDoubled = FALSE;
	fCubeOwner = !fMove;
	fTurn = fMove;
	break;

    case MOVE_DROP:
	if( !fDoubled )
	    break;
	
	fDoubled = FALSE;
	gs = GAME_DROP;
	pmgi->nPoints = nCube;
	pmgi->fWinner = !pmr->d.fPlayer;
	pmgi->fResigned = FALSE;
	
	ApplyGameOver();
	break;

    case MOVE_NORMAL:
	fDoubled = FALSE;
	PlayMove( pmr->n.anMove, pmr->n.fPlayer );
	anDice[ 0 ] = anDice[ 1 ] = 0;

	if( ( n = GameStatus( anBoard ) ) ) {
	    gs = GAME_OVER;
	    pmgi->nPoints = nCube * n;
	    pmgi->fWinner = pmr->n.fPlayer;
	    pmgi->fResigned = FALSE;
	    ApplyGameOver();
	}
	
	break;

    case MOVE_RESIGN:
	gs = GAME_RESIGNED;
	pmgi->nPoints = nCube * ( fResigned = pmr->r.nResigned );
	pmgi->fWinner = !pmr->r.fPlayer;
	pmgi->fResigned = TRUE;
	
	ApplyGameOver();
	break;
	
    case MOVE_SETBOARD:
	PositionFromKey( anBoard, pmr->sb.auchKey );

	if( fMove )
	    SwapSides( anBoard );

	break;
	
    case MOVE_SETDICE:
	anDice[ 0 ] = pmr->sd.anDice[ 0 ];
	anDice[ 1 ] = pmr->sd.anDice[ 1 ];
	fTurn = fMove = pmr->sd.fPlayer;
	fDoubled = FALSE;
	break;
	
    case MOVE_SETCUBEVAL:
	nCube = pmr->scv.nCube;
	fDoubled = FALSE;
	fTurn = fMove;
	break;
	
    case MOVE_SETCUBEPOS:
	fCubeOwner = pmr->scp.fCubeOwner;
	fDoubled = FALSE;
	fTurn = fMove;
	break;
    }
}

extern void CalculateBoard( void ) {

    list *pl;

    pl = plGame;
    do {
	pl = pl->plNext;

	assert( pl->p );

	ApplyMoveRecord( pl->p );
    } while( pl != plLastMove );
}

static void FreeGame( list *pl ) {

    while( pl->plNext != pl ) {
	free( pl->plNext->p );
	ListDelete( pl->plNext );
    }

    free( pl );
}

static int PopGame( list *plDelete, int fInclusive ) {

    list *pl;
    int i;
    
    for( i = 0, pl = lMatch.plNext; pl != &lMatch && pl->p != plDelete;
	 pl = pl->plNext, i++ )
	;

    if( pl->p && !fInclusive ) {
	pl = pl->plNext;
	i++;
    }
    
    if( !pl->p )
	/* couldn't find node to delete to */
	return -1;

#if USE_GTK
    if( fX )
	GTKPopGame( i );
#endif

    do {
	pl = pl->plNext;
	FreeGame( pl->plPrev->p );
	ListDelete( pl->plPrev );
    } while( pl->p );

    return 0;
}

static int PopMoveRecord( list *plDelete ) {

    list *pl;
    
    for( pl = plGame->plNext; pl != plGame && pl != plDelete; pl = pl->plNext )
	;

    if( pl == plGame )
	/* couldn't find node to delete to */
	return -1;

#if USE_GTK
    if( fX ) {
	GTKPopMoveRecord( pl->p );
	GTKSetMoveRecord( pl->plPrev->p );
    }
#endif
    
    pl = pl->plPrev;

    while( pl->plNext->p ) {
	if( pl->plNext == plLastMove )
	    plLastMove = pl;
	free( pl->plNext->p );
	ListDelete( pl->plNext );
    }

    return 0;
}

extern void AddMoveRecord( void *pv ) {

    moverecord *pmr = pv, *pmrOld;

    /* Delete all games after plGame, and all records after plLastMove. */
    PopGame( plGame, FALSE );
    /* FIXME when we can handle variations, we should save the old moves
       as an alternate variation. */
    PopMoveRecord( plLastMove->plNext );

    if( pmr->mt == MOVE_NORMAL &&
	( pmrOld = plLastMove->p )->mt == MOVE_SETDICE &&
	pmrOld->sd.fPlayer == pmr->n.fPlayer )
	PopMoveRecord( plLastMove );
    
    /* FIXME perform other elision (e.g. consecutive "set" records) */

#if USE_GTK
    if( fX ) {
	GTKAddMoveRecord( pmr );
	GTKSetMoveRecord( pmr );
    }
#endif
    
    ApplyMoveRecord( pmr );
    
    plLastMove = ListInsert( plGame, pmr );
}

extern void SetMoveRecord( void *pv ) {

#if USE_GTK
    if( fX )
	GTKSetMoveRecord( pv );
#endif
}

extern void ClearMoveRecord( void ) {
    
#if USE_GTK
    if( fX )
	GTKClearMoveRecord();
#endif
    
    plLastMove = plGame = malloc( sizeof( *plGame ) );
    ListCreate( plGame );
}

#if USE_GUI && HAVE_SELECT
static struct timeval tvLast;

static void ResetDelayTimer( void ) {
    
    if( fX && nDelay && fDisplay )
	gettimeofday( &tvLast, NULL );
}
#else
#define ResetDelayTimer()
#endif

extern void AddGame( moverecord *pmr ) {
    
#if USE_GTK
    char sz[ 90 ]; /* "Game 999: [32] 99999, [32] 99999" */
    
    if( fX ) {
	sprintf( sz, "Game %d: %s %d, %s %d", pmr->g.i + 1, ap[ 0 ].szName,
		 pmr->g.anScore[ 0 ], ap[ 1 ].szName, pmr->g.anScore[ 1 ] );
	GTKAddGame( sz );
    }
#endif
    
    assert( pmr->mt == MOVE_GAMEINFO );
    
    cGames++;
}

static void NewGame( void ) {

    moverecord *pmr;
    
    InitBoard( anBoard );

    ClearMoveRecord();

    ListInsert( &lMatch, plGame );

    pmr = malloc( sizeof( movegameinfo ) );
    pmr->g.mt = MOVE_GAMEINFO;
    pmr->g.i = cGames;
    pmr->g.nMatch = nMatchTo;
    pmr->g.anScore[ 0 ] = anScore[ 0 ];
    pmr->g.anScore[ 1 ] = anScore[ 1 ];
    pmr->g.fCrawford = fAutoCrawford && nMatchTo > 1;
    pmr->g.fCrawfordGame = fCrawford;
    pmr->g.fJacoby = fJacoby && !nMatchTo;
    pmr->g.fWinner = -1;
    pmr->g.nPoints = 0;
    pmr->g.fResigned = FALSE;
    pmr->g.nAutoDoubles = 0;
    AddMoveRecord( pmr );
        
    UpdateSetting( &nCube );
    UpdateSetting( &fCubeOwner );
    UpdateSetting( &fTurn );
    
 reroll:
    RollDice( anDice );

    if( fInterrupt ) {
	PopMoveRecord( plGame->plNext );

	free( plGame );
	ListDelete( lMatch.plPrev );

	return;
    }
    
    if( fDisplay ) {
      outputnew();
      outputf( "%s rolls %d, %s rolls %d.\n", ap[ 0 ].szName, anDice[ 0 ],
               ap[ 1 ].szName, anDice[ 1 ] );
      outputx();
    }

    if( anDice[ 0 ] == anDice[ 1 ] && nCube < MAX_CUBE ) {
	if( !nMatchTo && nCube < ( 1 << cAutoDoubles ) && fCubeUse ) {
	    pmr->g.nAutoDoubles++;
	    outputf( "The cube is now at %d.\n", nCube <<= 1 );
	    UpdateSetting( &nCube );
	}
	
	goto reroll;
    }

    AddGame( pmr );
    
    pmr = malloc( sizeof( pmr->sd ) );
    pmr->mt = MOVE_SETDICE;
    pmr->sd.anDice[ 0 ] = anDice[ 0 ];
    pmr->sd.anDice[ 1 ] = anDice[ 1 ];
    pmr->sd.fPlayer = anDice[ 1 ] > anDice[ 0 ];
    AddMoveRecord( pmr );
    UpdateSetting( &fTurn );
    
#if USE_GUI
    if( fX && fDisplay )
	ShowBoard();

    ResetDelayTimer();
#endif
}

static void ShowAutoMove( int anBoard[ 2 ][ 25 ], int anMove[ 8 ] ) {

    char sz[ 40 ];

    if( anMove[ 0 ] == -1 )
	outputf( "%s cannot move.", ap[ fTurn ].szName );
    else
	outputf( "%s moves %s.\n", ap[ fTurn ].szName,
		 FormatMove( sz, anBoard, anMove ) );
}


static int ComputerTurn( void ) {

  movenormal *pmn;
  cubeinfo ci;
  float arDouble[ 4 ], arOutput[ NUM_OUTPUTS ], rDoublePoint;
  char szBoard[ 256 ], szResponse[ 256 ];
  int i, c;
  
  SetCubeInfo ( &ci, nCube, fCubeOwner, fMove, nMatchTo, anScore,
		fCrawford, fJacoby, fBeavers );

  switch( ap[ fTurn ].pt ) {
  case PLAYER_GNU:
    if( fResigned ) {

      float rEqBefore, rEqAfter;

      if( EvaluatePosition( anBoard, arOutput, &ci, &ap[ fTurn ].ec ) )
        return -1;

      rEqBefore = -Utility ( arOutput, &ci );

      /* I win 100% if opponent resigns */
      arOutput[ 0 ] = 1.0; 
      arOutput[ 1 ] = arOutput[ 2 ] =
        arOutput[ 3 ] = arOutput[ 4 ] = 0.0;

      if( fResigned >= 2 )
	  /* resigned at least a gammon */
	  arOutput[ 1 ] = 1.0;

      if( fResigned == 3 )
	  /* resigned a backgammon */
	  arOutput[ 2 ] = 1.0;

      InvertEvaluation ( arOutput );
      
      rEqAfter = -Utility ( arOutput, &ci );

      /*
      printf ("equity before resignation: %7.3f\n"
              "equity after resignation : %7.3f\n",
              rEqBefore, rEqAfter );
      */

      fComputerDecision = TRUE;

      if( rEqAfter >= rEqBefore ) {
        CommandAgree( NULL );
        return 0;
      } else {
        CommandDecline( NULL );
        return 0;
      }

    } else if( fDoubled ) {

      /* Consider cube action */

      if ( EvaluatePositionCubeful ( anBoard, arDouble, arOutput, &ci,
                                     &ap [ fTurn ].ec,
                                     ap [ fTurn ].ec.nPlies ) < 0 )
        return -1;

      fComputerDecision = TRUE;
      
      if ( fBeavers && ! nMatchTo && arDouble[ 2 ] <= 0.0 &&
	  nCube < ( MAX_CUBE >> 1 ) ) {
        /* It's a beaver... beaver all night! */
        CommandRedouble ( NULL );
      }
      else if ( arDouble[ 2 ] <= arDouble[ 3 ] )
        CommandTake ( NULL );
      else
        CommandDrop ( NULL );

      return 0;

    } else {
      int anBoardMove[ 2 ][ 25 ];
	    

      /* Don't use the global board for this call, to avoid
	 race conditions with updating the board and aborting the
	 move with an interrupt. */
      memcpy( anBoardMove, anBoard, sizeof( anBoardMove ) );

      /* Consider doubling */

      if ( fCubeUse && ! anDice[ 0 ] && nCube < MAX_CUBE &&
	   GetDPEq ( NULL, NULL, &ci ) ) {

        static evalcontext ecDH = { 1, 8, 0.16, 0, FALSE }; 
        
        /* We have access to the cube */

        /* Determine market window */

        if ( EvaluatePosition ( anBoardMove, arOutput, &ci, &ecDH ) )
          return -1;

        rDoublePoint = 
          GetDoublePointDeadCube ( arOutput, &ci );

        if ( arOutput[ 0 ] >= rDoublePoint ) {

          /* We're in market window */

          if ( EvaluatePositionCubeful ( anBoard, arDouble, arOutput, &ci,
                                         &ap [ fTurn ].ec,
                                         ap [ fTurn ].ec.nPlies ) < 0 )
            return -1;

          if ( ( arDouble[ 3 ] >= arDouble[ 1 ] ) &&
               ( arDouble[ 2 ] >= arDouble[ 1 ] ) ) {
	      fComputerDecision = TRUE;
	      CommandDouble ( NULL );
	      return 0;
          }
        } /* market window */
      } /* access to cube */

      /* Roll dice and move */
      if ( ! anDice[ 0 ] ) {
	  if( RollDice ( anDice ) < 0 )
	      return -1;
	  
	  ResetDelayTimer(); /* Start the timer again -- otherwise the time
				we spent contemplating the cube could replace
				the delay. */
	
	  /* write line to status bar if using GTK */
#ifdef USE_GTK        
	  if ( fX ) {

	      outputnew ();
	      outputf ( "%s rolls %1i and %1i.\n",
			ap [ fTurn ].szName, anDice[ 0 ], anDice[ 1 ] );
	      outputx ();
	      
	  }
#endif
      }

      
      if ( fDisplay )
	  ShowBoard();

      pmn = malloc( sizeof( *pmn ) );
      pmn->mt = MOVE_NORMAL;
      pmn->anRoll[ 0 ] = anDice[ 0 ];
      pmn->anRoll[ 1 ] = anDice[ 1 ];
      pmn->fPlayer = fTurn;
      
      if( FindBestMove( pmn->anMove, anDice[ 0 ], anDice[ 1 ],
                        anBoardMove, &ci, &ap[ fTurn ].ec ) < 0 ) {
        free( pmn );
        return -1;
      }
      
      /* write move to status bar if using GTK */
#ifdef USE_GTK        
      if ( fX ) {
	  
	  outputnew ();
	  ShowAutoMove( anBoardMove, pmn->anMove );
	  outputx ();
      }
#endif
      
      AddMoveRecord( pmn );      
      
      return 0;
    }
    
  case PLAYER_PUBEVAL:
    if( fResigned == 3 ) {
      fComputerDecision = TRUE;
      CommandAgree( NULL );
      return 0;
    } else if( fResigned ) {
      fComputerDecision = TRUE;
      CommandDecline( NULL );
      return 0;
    } else if( fDoubled ) {
      fComputerDecision = TRUE;
      CommandTake( NULL );
      return 0;
    } else if( !anDice[ 0 ] ) {
      if( RollDice( anDice ) < 0 )
	    return -1;
      
      if( fDisplay )
        ShowBoard();
    }
    
    pmn = malloc( sizeof( *pmn ) );
    pmn->mt = MOVE_NORMAL;
    pmn->anRoll[ 0 ] = anDice[ 0 ];
    pmn->anRoll[ 1 ] = anDice[ 1 ];
    pmn->fPlayer = fTurn;
    
    FindPubevalMove( anDice[ 0 ], anDice[ 1 ], anBoard, pmn->anMove );
    
    AddMoveRecord( pmn );
    return 0;

  case PLAYER_EXTERNAL:
#if HAVE_SOCKETS
      if( fResigned == 3 ) {
	  /* FIXME get resignation decision */
	  fComputerDecision = TRUE;
	  CommandAgree( NULL );
	  return 0;
      } else if( fResigned ) {
	  /* FIXME get resignation decision */
	  fComputerDecision = TRUE;
	  CommandDecline( NULL );
	  return 0;
      } else if( fDoubled ) {
	  /* FIXME get take decision */
	  fComputerDecision = TRUE;
	  CommandTake( NULL );
	  return 0;
      } else if( !anDice[ 0 ] ) {
	  /* FIXME get double decision (check cube use on, cube access, and
	     Crawford) */
	  if( RollDice( anDice ) < 0 )
	      return -1;
	  
	  if( fDisplay )
	      ShowBoard();
      }

      FIBSBoard( szBoard, anBoard, fMove, ap[ 1 ].szName,
		 ap[ 0 ].szName, nMatchTo, anScore[ 1 ],
		 anScore[ 0 ], anDice[ 0 ], anDice[ 1 ], nCube,
		 fCubeOwner, fDoubled, fTurn, fCrawford );
      strcat( szBoard, "\n" );
      
      if( ExternalWrite( ap[ fTurn ].h, szBoard,
			 strlen( szBoard ) + 1 ) < 0 )
	  return -1;

      if( ExternalRead( ap[ fTurn ].h, szResponse,
			sizeof( szResponse ) ) < 0 )
	  return -1;
      
      pmn = malloc( sizeof( *pmn ) );
      pmn->mt = MOVE_NORMAL;
      pmn->anRoll[ 0 ] = anDice[ 0 ];
      pmn->anRoll[ 1 ] = anDice[ 1 ];
      pmn->fPlayer = fTurn;

      if( ( c = ParseMove( szResponse, pmn->anMove ) ) < 0 ) {
	  pmn->anMove[ 0 ] = 0;
	  outputl( "Warning: badly formed move from external player" );
      } else
	  for( i = 0; i < 4; i++ )
	      if( i < c ) {
		  pmn->anMove[ i << 1 ]--;
		  pmn->anMove[ ( i << 1 ) + 1 ]--;
	      } else {
		  pmn->anMove[ i << 1 ] = -1;
		  pmn->anMove[ ( i << 1 ) + 1 ] = -1;
	      }
      
      AddMoveRecord( pmn );
      return 0;
#else
      /* fall through */
#endif
      
  case PLAYER_HUMAN:
      /* fall through */
      ;
  }
  
  assert( FALSE );
  return -1;
}

extern void CancelCubeAction( void ) {
    
    if( fDoubled ) {
	outputf( "(%s's double has been cancelled.)\n", ap[ fMove ].szName );
	fDoubled = FALSE;

	if( fDisplay )
	    ShowBoard();

	/* FIXME should fTurn be set to fMove? */
	TurnDone(); /* FIXME is this right? */
	/* FIXME delete all MOVE_DOUBLE records */
    }
}

/* Try to automatically bear off as many chequers as possible.  Only do it
   if it's a non-contact position, and each die can be used to bear off
   a chequer. */
static int TryBearoff( void ) {

    movelist ml;
    int i, iMove, cMoves;
    movenormal *pmn;
    
    if( ClassifyPosition( anBoard ) > CLASS_RACE )
	/* It's a contact position; don't automatically bear off */
	return -1;
    
    GenerateMoves( &ml, anBoard, anDice[ 0 ], anDice[ 1 ], FALSE );

    cMoves = ( anDice[ 0 ] == anDice[ 1 ] ) ? 4 : 2;
    
    for( i = 0; i < ml.cMoves; i++ )
	for( iMove = 0; iMove < cMoves; iMove++ )
	    if( ( ml.amMoves[ i ].anMove[ iMove << 1 ] < 0 ) ||
		( ml.amMoves[ i ].anMove[ ( iMove << 1 ) + 1 ] != -1 ) )
		break;
	    else if( iMove == cMoves - 1 ) {
		/* All dice bear off */
		pmn = malloc( sizeof( *pmn ) );
		pmn->mt = MOVE_NORMAL;
		pmn->anRoll[ 0 ] = anDice[ 0 ];
		pmn->anRoll[ 1 ] = anDice[ 1 ];
		pmn->fPlayer = fTurn;
		memcpy( pmn->anMove, ml.amMoves[ i ].anMove,
			sizeof( pmn->anMove ) );
		
		ShowAutoMove( anBoard, pmn->anMove );
		
		AddMoveRecord( pmn );

		return 0;
	    }

    return -1;
}

extern void NextTurn( void ) {

    int n;
#if USE_GUI && HAVE_SELECT
    struct timeval tv;
    fd_set fds;
#endif
    
#if USE_GUI
    if( fX ) {
#if USE_GTK
	if( nNextTurn ) {
	    gtk_idle_remove( nNextTurn );
	    nNextTurn = 0;
	}
#else
        EventPending( &evNextTurn, FALSE );	
#endif
    } else
#endif
	fNextTurn = FALSE;
    
#if USE_GUI && HAVE_SELECT
    if( fX && nDelay && fDisplay ) {
	if( tvLast.tv_sec ) {
	    if( ( tvLast.tv_usec += 1000 * nDelay ) >= 1000000 ) {
		tvLast.tv_sec += tvLast.tv_usec / 1000000;
		tvLast.tv_usec %= 1000000;
	    }
	
	restart:
	    gettimeofday( &tv, NULL );
		
	    if( tvLast.tv_sec > tv.tv_sec ||
		( tvLast.tv_sec == tv.tv_sec &&
		  tvLast.tv_usec > tv.tv_usec ) ) {
		tv.tv_sec = tvLast.tv_sec - tv.tv_sec;
		if( ( tv.tv_usec = tvLast.tv_usec - tv.tv_usec ) < 0 ) {
		    tv.tv_usec += 1000000;
		    tv.tv_sec--;
		}

#ifdef ConnectionNumber /* FIXME use configure for this */
		FD_ZERO( &fds );
		FD_SET( ConnectionNumber( DISPLAY ), &fds );
		/* GTK-FIXME: use timeout */
		if( select( ConnectionNumber( DISPLAY ) + 1, &fds, NULL,
			    NULL, &tv ) > 0 ) {
		    HandleXAction();
		    if( !fInterrupt )
			goto restart;
		}
#else
		if( select( 0, NULL, NULL, NULL, &tv ) > 0 && !fInterrupt )
		    goto restart;
#endif
		 
	    }
	}
	ResetDelayTimer();
    }
#endif
    
    if( ( n = GameStatus( anBoard ) ) ||
	( gs == GAME_DROP && ( ( n = 1 ) ) ) ||
	( gs == GAME_RESIGNED && ( ( n = fResigned ) ) ) ) {
	movegameinfo *pmgi = plGame->plNext->p;
	
	if( fJacoby && fCubeOwner == -1 && !nMatchTo )
	    /* gammons do not count on a centred cube during money
	       sessions under the Jacoby rule */
	    n = 1;
	
	outputf( "%s wins a %s and %d point%s.\n", ap[ pmgi->fWinner ].szName,
		 aszGameResult[ n - 1 ], pmgi->nPoints,
		 pmgi->nPoints > 1 ? "s" : "" );
	
#if USE_GUI
	if( fX && fDisplay )
	    ShowBoard();
#endif
	
	if( nMatchTo && fAutoCrawford ) {
	    fPostCrawford |= fCrawford && anScore[ pmgi->fWinner ] < nMatchTo;
	    fCrawford = !fPostCrawford && !fCrawford &&
		anScore[ pmgi->fWinner ] == nMatchTo - 1 &&
		anScore[ !pmgi->fWinner ] != nMatchTo - 1;
	}
	
	CommandShowScore( NULL );
	
	if( nMatchTo && anScore[ pmgi->fWinner ] >= nMatchTo ) {
	    outputf( "%s has won the match.\n", ap[ pmgi->fWinner ].szName );
	    outputx();
	    return;
	}

	outputx();
	
	if( fAutoGame ) {
	    NewGame();
	    
	    if( ap[ fTurn ].pt == PLAYER_HUMAN )
		ShowBoard();
	} else
	    return;
    }
    
    if( fDisplay || ap[ fTurn ].pt == PLAYER_HUMAN )
	ShowBoard();

    /* We have reached a safe point to check for interrupts.  Until now,
       the board could have been in an inconsistent state. */
    if( fAction )
	fnAction();
	
    if( fInterrupt )
	return;
    
    if( ap[ fTurn ].pt == PLAYER_HUMAN ) {
	/* Roll for them, if:

	   * "auto roll" is on;
	   * they haven't already rolled;
	   * they haven't just been doubled;
	   * at least one of the following:
	     - cube use is disabled;
	     - it's the Crawford game;
	     - the cube is dead. */
	if( fAutoRoll && !anDice[ 0 ] && !fDoubled &&
	    ( !fCubeUse || fCrawford ||
	      ( fCubeOwner >= 0 && fCubeOwner != fTurn ) ||
	      ( nMatchTo > 0 && anScore[ fTurn ] + nCube >= nMatchTo ) ) )
	    CommandRoll( NULL );
	return;
    } else
#if USE_GUI
	if( fX ) {
#if USE_GTK
	    if( !ComputerTurn() )
		nNextTurn = gtk_idle_add( NextTurnNotify, NULL );
#else
            EventPending( &evNextTurn, !ComputerTurn() );	    
#endif
	} else
#endif
	    fNextTurn = !ComputerTurn();
}

extern void TurnDone( void ) {

    fComputerDecision = FALSE;
    
#if USE_GUI
    if( fX )
#if USE_GTK
	nNextTurn = gtk_idle_add( NextTurnNotify, NULL );
#else
        EventPending( &evNextTurn, TRUE );    
#endif
    else
#endif
	fNextTurn = TRUE;

    outputx();
}

extern void CommandAccept( char *sz ) {

    if( fResigned )
	CommandAgree( sz );
    else if( fDoubled )
	CommandTake( sz );
    else
	outputl( "You can only accept if the cube or a resignation has been "
		 "offered." );
}

extern void CommandAgree( char *sz ) {

    moveresign *pmr;
    
    if( gs != GAME_PLAYING ) {
	outputl( "No game in progress (type `new game' to start one)." );

	return;
    }

    if( ap[ fTurn ].pt != PLAYER_HUMAN && !fComputerDecision ) {
	outputl( "It is the computer's turn -- type `play' to force it to "
		 "move immediately." );
	return;
    }

    if( !fResigned ) {
	outputl( "No resignation was offered." );

	return;
    }

    if( fDisplay )
	outputf( "%s accepts and wins a %s.\n", ap[ fTurn ].szName,
		aszGameResult[ fResigned - 1 ] );

    pmr = malloc( sizeof( *pmr ) );
    pmr->mt = MOVE_RESIGN;
    pmr->fPlayer = !fTurn;
    pmr->nResigned = fResigned;
    AddMoveRecord( pmr );

    TurnDone();
}

extern void CommandDecline( char *sz ) {

    if( gs != GAME_PLAYING ) {
	outputl( "No game in progress (type `new game' to start one)." );

	return;
    }

    if( ap[ fTurn ].pt != PLAYER_HUMAN && !fComputerDecision ) {
	outputl( "It is the computer's turn -- type `play' to force it to "
		 "move immediately." );
	return;
    }

    if( !fResigned ) {
	outputl( "No resignation was offered." );

	return;
    }

    if( fDisplay )
	outputf( "%s declines the %s.\n", ap[ fTurn ].szName,
		aszGameResult[ fResigned - 1 ] );

    fResigned = FALSE;
    fTurn = !fTurn;
    
    TurnDone();
}

extern void CommandDouble( char *sz ) {

    moverecord *pmr;
    
    if( gs != GAME_PLAYING ) {
	outputl( "No game in progress (type `new game' to start one)." );

	return;
    }

    if( ap[ fTurn ].pt != PLAYER_HUMAN && !fComputerDecision ) {
	outputl( "It is the computer's turn -- type `play' to force it to "
		 "move immediately." );
	return;
    }

    if( fCrawford ) {
	outputl( "Doubling is forbidden by the Crawford rule (see `help set "
	      "crawford')." );

	return;
    }

    if( !fCubeUse ) {
	outputl( "The doubling cube has been disabled (see `help set cube "
	      "use')." );

	return;
    }

    if( fDoubled ) {
	outputl( "The `double' command is for offering the cube, not "
		 "accepting it.  Use\n`redouble' to immediately offer the "
		 "cube back at a higher value." );

	return;
    }
    
    if( fTurn != fMove ) {
	outputl( "You are only allowed to double if you are on roll." );

	return;
    }
    
    if( anDice[ 0 ] ) {
	outputl( "You can't double after rolling the dice -- wait until your "
	      "next turn." );

	return;
    }

    if( fCubeOwner >= 0 && fCubeOwner != fTurn ) {
	outputl( "You do not own the cube." );

	return;
    }

    if( nCube >= MAX_CUBE ) {
	outputl( "The cube is already at " MAX_CUBE_STR "; you can't double "
		 "any more." );
	return;
    }
    
    if( fDisplay )
	outputf( "%s doubles.\n", ap[ fTurn ].szName );
    
    pmr = malloc( sizeof( pmr->d ) );
    pmr->d.mt = MOVE_DOUBLE;
    pmr->d.fPlayer = fTurn;
    AddMoveRecord( pmr );
    
    TurnDone();
}

extern void CommandDrop( char *sz ) {

    moverecord *pmr;
    
    if( gs != GAME_PLAYING || !fDoubled ) {
	outputl( "The cube must have been offered before you can drop it." );

	return;
    }

    if( ap[ fTurn ].pt != PLAYER_HUMAN && !fComputerDecision ) {
	outputl( "It is the computer's turn -- type `play' to force it to "
		 "move immediately." );
	return;
    }

    if( fDisplay )
	outputf( "%s refuses the cube and gives up %d point%s.\n",
		ap[ fTurn ].szName, nCube, nCube == 1 ? "" : "s" );
    
    pmr = malloc( sizeof( pmr->t ) );
    pmr->mt = MOVE_DROP;
    pmr->t.fPlayer = fTurn;
    AddMoveRecord( pmr );
    
    TurnDone();
}

extern void CommandListGame( char *sz ) {
#if USE_GTK
    if( fX ) {
	ShowGameWindow();
	return;
    }
#endif

    /* FIXME */
}

extern void CommandListMatch( char *sz ) {
#if USE_GTK
    if( fX ) {
	ShowGameWindow();
	return;
    }
#endif

    /* FIXME */
}

extern void 
CommandMove( char *sz ) {

  int c, i, j, anBoardNew[ 2 ][ 25 ], anBoardTest[ 2 ][ 25 ],
    an[ 8 ];
  movelist ml;
  movenormal *pmn;
    
  if( gs != GAME_PLAYING ) {
    outputl( "No game in progress (type `new game' to start one)." );

    return;
  }

  if( ap[ fTurn ].pt != PLAYER_HUMAN ) {
    outputl( "It is the computer's turn -- type `play' to force it to "
             "move immediately." );
    return;
  }

  if( !anDice[ 0 ] ) {
    outputl( "You must roll the dice before you can move." );

    return;
  }

  if( fResigned ) {
    outputf( "Please wait for %s to consider the resignation before "
             "moving.\n", ap[ fTurn ].szName );

    return;
  }

  if( fDoubled ) {
    outputf( "Please wait for %s to consider the cube before "
             "moving.\n", ap[ fTurn ].szName );

    return;
  }
    
  if( !*sz ) {
    GenerateMoves( &ml, anBoard, anDice[ 0 ], anDice[ 1 ], FALSE );

    if( ml.cMoves <= 1 ) {
	    pmn = malloc( sizeof( *pmn ) );
	    pmn->mt = MOVE_NORMAL;
	    pmn->anRoll[ 0 ] = anDice[ 0 ];
	    pmn->anRoll[ 1 ] = anDice[ 1 ];
	    pmn->fPlayer = fTurn;
	    if( ml.cMoves )
		memcpy( pmn->anMove, ml.amMoves[ 0 ].anMove,
			sizeof( pmn->anMove ) );
	    else
		pmn->anMove[ 0 ] = -1;
	    
	    ShowAutoMove( anBoard, pmn->anMove );

	    AddMoveRecord( pmn );

	    TurnDone();

	    return;
    }

    if( fAutoBearoff && !TryBearoff() ) {
	    TurnDone();

	    return;
    }
	
    outputl( "You must specify a move (type `help move' for "
             "instructions)." );

    return;
  }
    
  if( ( c = ParseMove( sz, an ) ) > 0 ) {
    for( i = 0; i < 25; i++ ) {
	    anBoardNew[ 0 ][ i ] = anBoard[ 0 ][ i ];
	    anBoardNew[ 1 ][ i ] = anBoard[ 1 ][ i ];
    }
	
    for( i = 0; i < c; i++ ) {
	    anBoardNew[ 1 ][ an[ i << 1 ] - 1 ]--;
	    if( an[ ( i << 1 ) | 1 ] > 0 ) {
        anBoardNew[ 1 ][ an[ ( i << 1 ) | 1 ] - 1 ]++;
		
        anBoardNew[ 0 ][ 24 ] +=
          anBoardNew[ 0 ][ 24 - an[ ( i << 1 ) | 1 ] ];
		
        anBoardNew[ 0 ][ 24 - an[ ( i << 1 ) | 1 ] ] = 0;
	    }
    }
	
    GenerateMoves( &ml, anBoard, anDice[ 0 ], anDice[ 1 ], FALSE );
	
    for( i = 0; i < ml.cMoves; i++ ) {
	    PositionFromKey( anBoardTest, ml.amMoves[ i ].auch );
	    
	    for( j = 0; j < 25; j++ )
        if( anBoardTest[ 0 ][ j ] != anBoardNew[ 0 ][ j ] ||
            anBoardTest[ 1 ][ j ] != anBoardNew[ 1 ][ j ] )
          break;
	    
	    if( j == 25 ) {
        /* we have a legal move! */
        pmn = malloc( sizeof( *pmn ) );
        pmn->mt = MOVE_NORMAL;
        pmn->anRoll[ 0 ] = anDice[ 0 ];
        pmn->anRoll[ 1 ] = anDice[ 1 ];
        pmn->fPlayer = fTurn;
        memcpy( pmn->anMove, ml.amMoves[ i ].anMove,
                sizeof( pmn->anMove ) );
		
#ifdef USE_GTK        
        if ( fX ) {

          outputnew ();
	  ShowAutoMove( anBoard, pmn->anMove );
          outputx ();
	}
#endif

        AddMoveRecord( pmn );
        TurnDone();
		
        return;
	    }
    }
  }

  outputl( "Illegal move." );
}

extern void CommandNewGame( char *sz ) {

    list *pl;
    
    if( nMatchTo && ( anScore[ 0 ] >= nMatchTo ||
		      anScore[ 1 ] >= nMatchTo ) ) {
	outputl( "The match is already over." );

	return;
    }

    if( gs == GAME_PLAYING ) {
	if( fConfirm ) {
	    if( fInterrupt )
		return;
	    
	    if( !GetInputYN( "Are you sure you want to start a new game, "
			     "and discard the one in progress? " ) )
		return;
	}

	/* Delete all games at the _end_ of the match, back to and including
	   the current one. */
	do {
	    pl = lMatch.plPrev->p;
	    ListDelete( lMatch.plPrev );
	    FreeGame( pl );
	    cGames--;
	} while( pl != plGame );
    }
    
    NewGame();

    if( fInterrupt )
	return;
    
    if( ap[ fTurn ].pt == PLAYER_HUMAN )
	ShowBoard();
    else
	if( !ComputerTurn() )
	    TurnDone();
}

extern void FreeMatch( void ) {

    list *plMatch;

    while( ( plMatch = lMatch.plNext ) != &lMatch ) {
	FreeGame( plMatch->p );
	ListDelete( plMatch );
    }
}

extern void CommandNewMatch( char *sz ) {

    int n = ParseNumber( &sz );

    if( n < 1 ) {
	outputl( "You must specify a valid match length (1 or longer)." );

	return;
    }

    /* Check that match equity table is large enough */

    if ( n > nMaxScore ) {

      outputf ( "The current match equity table does not support "
                "matches of length %i\n"
                "(see `help set matchequitytable')\n", n );
      return;
    }

    if( gs == GAME_PLAYING && fConfirm ) {
	if( fInterrupt )
	    return;
	    
	if( !GetInputYN( "Are you sure you want to start a new match, "
			 "and discard the game in progress? " ) )
	    return;
    }
    
    FreeMatch();

    nMatchTo = n;

    cGames = anScore[ 0 ] = anScore[ 1 ] = 0;
    fTurn = -1;
    gs = GAME_NONE;
    fCrawford = FALSE;
    fPostCrawford = FALSE;

    UpdateSetting( &nMatchTo );
    UpdateSetting( &fTurn );
    UpdateSetting( &fCrawford );
    
    outputf( "A new %d point match has been started.\n", n );

#if USE_GUI
    if( fX )
	ShowBoard();
#endif

    if( fAutoGame )
	CommandNewGame( NULL );
}

extern void CommandNewSession( char *sz ) {

    if( gs == GAME_PLAYING && fConfirm ) {
	if( fInterrupt )
	    return;
	    
	if( !GetInputYN( "Are you sure you want to start a new session, "
			 "and discard the game in progress? " ) )
	    return;
    }
    
    FreeMatch();

    cGames = nMatchTo = anScore[ 0 ] = anScore[ 1 ] = 0;
    fTurn = -1;
    gs = GAME_NONE;
    fCrawford = 0;
    fPostCrawford = 0;

    UpdateSetting( &nMatchTo );
    UpdateSetting( &fTurn );
    UpdateSetting( &fCrawford );
    
    outputl( "A new session has been started." );
    
#if USE_GUI
    if( fX )
	ShowBoard();
#endif
    
    if( fAutoGame )
	CommandNewGame( NULL );
}

static void UpdateGame( void ) {
    
    UpdateSetting( &nCube );
    UpdateSetting( &fCubeOwner );
    UpdateSetting( &fTurn );

    ShowBoard();
}

extern void ChangeGame( list *plGameNew ) {

    list *pl;
    
    plLastMove = ( plGame = plGameNew )->plNext;
    
#if USE_GTK
    if( fX ) {
	GTKClearMoveRecord();

	for( pl = plGame->plNext; pl->p; pl = pl->plNext ) {
	    GTKAddMoveRecord( pl->p );
	    ApplyMoveRecord( pl->p );
	}

	GTKSetGame( ( (moverecord *) plGame->plNext->p )->g.i );
    }
#endif
    
    SetMoveRecord( plLastMove->p );

    CalculateBoard();
    
    UpdateGame();
}

static void CommandNextGame( char *sz ) {

    int n;
    char *pch;
    list *pl;
    
    if( ( pch = NextToken( &sz ) ) )
	n = ParseNumber( &pch );
    else
	n = 1;

    if( n < 1 ) {
	outputl( "If you specify a parameter to the `next game' command, it "
		 "must be a positive number (the count of games to step "
		 "ahead)." );
	return;
    }

    for( pl = lMatch.plNext; pl->p != plGame; pl = pl->plNext )
	;
    
    for( ; n && pl->plNext->p; n--, pl = pl->plNext )
	;

    if( pl->p == plGame )
	return;

    ChangeGame( pl->p );
}

extern void CommandNext( char *sz ) {

    int n;
    char *pch;
    
    if( !plGame ) {
	outputl( "No game in progress (type `new game' to start one)." );
	return;
    }
    
    if( ( pch = NextToken( &sz ) ) ) {
	if( !strncasecmp( pch, "game", strlen( pch ) ) )
	    return CommandNextGame( sz );
	else
	    n = ParseNumber( &pch );
    } else
	n = 1;
    
    if( n < 1 ) {
	outputl( "If you specify a parameter to the `next' command, it must "
		 "be a positive number (the count of moves to step ahead)." );
	return;
    }
    
    while( n-- && plLastMove->plNext->p ) {
	plLastMove = plLastMove->plNext;
	ApplyMoveRecord( plLastMove->p );
    }

    SetMoveRecord( plLastMove->p );
    
    UpdateGame();
}

extern void CommandPlay( char *sz ) {

    if( gs != GAME_PLAYING ) {
	outputl( "No game in progress (type `new game' to start one)." );

	return;
    }

    if( ap[ fTurn ].pt == PLAYER_HUMAN ) {
	outputl( "It's not the computer's turn to play." );

	return;
    }

    if( !ComputerTurn() )
	TurnDone();
}

static void CommandPreviousGame( char *sz ) {

    int n;
    char *pch;
    list *pl;
    
    if( ( pch = NextToken( &sz ) ) )
	n = ParseNumber( &pch );
    else
	n = 1;

    if( n < 1 ) {
	outputl( "If you specify a parameter to the `previous game' command, "
		 "it must be a positive number (the count of games to step "
		 "back)." );
	return;
    }
    
    for( pl = lMatch.plNext; pl->p != plGame; pl = pl->plNext )
	;
    
    for( ; n && pl->plPrev->p; n--, pl = pl->plPrev )
	;

    if( pl->p == plGame )
	return;

    ChangeGame( pl->p );
}

extern void CommandPrevious( char *sz ) {

    int n;
    char *pch;
    
    if( !plGame ) {
	outputl( "No game in progress (type `new game' to start one)." );
	return;
    }
    
    if( ( pch = NextToken( &sz ) ) ) {
	if( !strncasecmp( pch, "game", strlen( pch ) ) )
	    return CommandPreviousGame( sz );
	else
	    n = ParseNumber( &pch );
    } else
	n = 1;
    
    if( n < 1 ) {
	outputl( "If you specify a parameter to the `previous' command, it "
		 "must be a positive number (the count of moves to step "
		 "back)." );
	return;
    }

    while( n-- && plLastMove->plPrev->p )
	plLastMove = plLastMove->plPrev;

    SetMoveRecord( plLastMove->p );
    
    CalculateBoard();

    UpdateGame();
}

extern void CommandRedouble( char *sz ) {

    moverecord *pmr;

    if( nMatchTo > 0 ) {
	outputl( "Redoubles are not permitted during match play." );

	return;
    }
    
    if( gs != GAME_PLAYING || !fDoubled ) {
	outputl( "The cube must have been offered before you can redouble "
		 "it." );

	return;
    }
    
    if( ap[ fTurn ].pt != PLAYER_HUMAN && !fComputerDecision ) {
	outputl( "It is the computer's turn -- type `play' to force it to "
		 "move immediately." );
	return;
    }

    if( nCube >= ( MAX_CUBE >> 1 ) ) {
	outputl( "The cube is already at " MAX_CUBE_STR "; you can't double "
		 "any more." );
	return;
    }
    
    if( fDisplay )
	outputf( "%s accepts and immediately redoubles to %d.\n",
		ap[ fTurn ].szName, nCube << 2 );
    
    fCubeOwner = !fMove;
    UpdateSetting( &fCubeOwner );
    
    pmr = malloc( sizeof( pmr->d ) );
    pmr->mt = MOVE_DOUBLE;
    pmr->d.fPlayer = fTurn;
    AddMoveRecord( pmr );
    
    TurnDone();
}

extern void CommandReject( char *sz ) {

    if( fResigned )
	CommandDecline( sz );
    else if( fDoubled )
	CommandDrop( sz );
    else
	outputl( "You can only reject if the cube or a resignation has been "
	      "offered." );
}

extern void CommandResign( char *sz ) {

    char *pch;
    int cch;
    
    if( gs != GAME_PLAYING ) {
	outputl( "You must be playing a game if you want to resign it." );

	return;
    }

    if( ap[ fTurn ].pt != PLAYER_HUMAN && !fComputerDecision ) {
	outputl( "It is the computer's turn -- type `play' to force it to "
		 "move immediately." );
	return;
    }

    /* FIXME cancel cube action?  or refuse resignations while doubled?
     or treat resignations while doubled as drops? */
    
    if( ( pch = NextToken( &sz ) ) ) {
	cch = strlen( pch );

	if( !strncasecmp( "single", pch, cch ) ||
	    !strncasecmp( "normal", pch, cch ) )
	    fResigned = 1;
	else if( !strncasecmp( "gammon", pch, cch ) )
	    fResigned = 2;
	else if( !strncasecmp( "backgammon", pch, cch ) )
	    fResigned = 3;
	else
	    fResigned = atoi( pch );
    } else
	fResigned = 1;

    if( fResigned < 1 || fResigned > 3 ) {
	fResigned = 0;

	outputf( "Unknown keyword `%s' -- try `help resign'.\n", pch );
	
	return;
    }
    
    if( fDisplay )
	outputf( "%s offers to resign a %s.\n", ap[ fTurn ].szName,
		aszGameResult[ fResigned - 1 ] );

    fTurn = !fTurn;
    
    TurnDone();
}


extern void 
CommandRoll( char *sz ) {

  movelist ml;
  movenormal *pmn;
  moverecord *pmr;
  
  if( gs != GAME_PLAYING ) {
    outputl( "No game in progress (type `new game' to start one)." );

    return;
  }
    
  if( ap[ fTurn ].pt != PLAYER_HUMAN ) {
    outputl( "It is the computer's turn -- type `play' to force it to "
             "move immediately." );
    return;
  }

  if( fDoubled ) {
    outputf( "Please wait for %s to consider the cube before "
             "moving.\n", ap[ fTurn ].szName );

    return;
  }    

  if( fResigned ) {
    outputl( "Please resolve the resignation first." );

    return;
  }

  if( anDice[ 0 ] ) {
    outputl( "You already did roll the dice." );

    return;
  }
    
  if( RollDice( anDice ) < 0 )
    return;

  pmr = malloc( sizeof( pmr->sd ) );
  pmr->mt = MOVE_SETDICE;
  pmr->sd.anDice[ 0 ] = anDice[ 0 ];
  pmr->sd.anDice[ 1 ] = anDice[ 1 ];
  pmr->sd.fPlayer = fTurn;
  AddMoveRecord( pmr );
  
  ShowBoard();

#ifdef USE_GTK        
  if ( fX ) {

    outputnew ();
    outputf ( "%s rolls %1i and %1i.\n",
              ap [ fTurn ].szName, anDice[ 0 ], anDice[ 1 ] );
    outputx ();

  }
#endif

  ResetDelayTimer();
    
  if( !GenerateMoves( &ml, anBoard, anDice[ 0 ], anDice[ 1 ], FALSE ) ) {
    pmn = malloc( sizeof( *pmn ) );
    pmn->mt = MOVE_NORMAL;
    pmn->anRoll[ 0 ] = anDice[ 0 ];
    pmn->anRoll[ 1 ] = anDice[ 1 ];
    pmn->fPlayer = fTurn;
    pmn->anMove[ 0 ] = -1;
	
    ShowAutoMove( anBoard, pmn->anMove );

    AddMoveRecord( pmn );
    TurnDone();
  } else if( ml.cMoves == 1 && ( fAutoMove || ( ClassifyPosition( anBoard )
                                                <= CLASS_BEAROFF1 &&
                                                fAutoBearoff ) ) ) {
    pmn = malloc( sizeof( *pmn ) );
    pmn->mt = MOVE_NORMAL;
    pmn->anRoll[ 0 ] = anDice[ 0 ];
    pmn->anRoll[ 1 ] = anDice[ 1 ];
    pmn->fPlayer = fTurn;
    memcpy( pmn->anMove, ml.amMoves[ 0 ].anMove, sizeof( pmn->anMove ) );

    ShowAutoMove( anBoard, pmn->anMove );
	
    AddMoveRecord( pmn );
    TurnDone();
  } else
    if( fAutoBearoff && !TryBearoff() )
	    TurnDone();
}


extern void CommandTake( char *sz ) {

    moverecord *pmr;
    
    if( gs != GAME_PLAYING || !fDoubled ) {
	outputl( "The cube must have been offered before you can take it." );

	return;
    }

    if( ap[ fTurn ].pt != PLAYER_HUMAN && !fComputerDecision ) {
	outputl( "It is the computer's turn -- type `play' to force it to "
		 "move immediately." );
	return;
    }

    if( fDisplay )
	outputf( "%s accepts the cube at %d.\n", ap[ fTurn ].szName,
		 nCube << 1 );
    
    pmr = malloc( sizeof( pmr->t ) );
    pmr->mt = MOVE_TAKE;
    pmr->t.fPlayer = fTurn;
    AddMoveRecord( pmr );

    UpdateSetting( &nCube );
    UpdateSetting( &fCubeOwner );
    
    TurnDone();
}
