/*
 * makeweights.c
 *
 * by Gary Wong <gary@cs.arizona.edu>, 2000.
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
 * $Id: makeweights.c,v 1.4 2001/01/11 21:18:57 gtw Exp $
 */

#include "config.h"

#include <neuralnet.h>
#include <stdio.h>
#include <stdlib.h>
#if HAVE_UNISTD_H
#include <unistd.h>
#endif

#include "eval.h" /* for WEIGHTS_VERSION */

extern int main( int argc, char *argv[] ) {

    neuralnet nn;
    char szFileVersion[ 16 ];
    static float ar[ 2 ] = { WEIGHTS_MAGIC_BINARY, WEIGHTS_VERSION_BINARY };
    int c;
#ifdef STDOUT_FILENO 
    FILE *output;
#else
#define output stdout
#endif
    
    if( scanf( "GNU Backgammon %15s\n", szFileVersion ) != 1 ) {
	fprintf( stderr, "%s: invalid weights file\n", argv[ 0 ] );
	return EXIT_FAILURE;
    }

    if( strcmp( szFileVersion, WEIGHTS_VERSION ) ) {
	fprintf( stderr, "%s: incorrect weights version (version "
		 WEIGHTS_VERSION " is required,\nbut these weights are "
		 "%s)\n", argv[ 0 ], szFileVersion );
	return EXIT_FAILURE;
    }

#ifdef STDOUT_FILENO
    if( !( output = fdopen( STDOUT_FILENO, "wb" ) ) ) {
	perror( "(stdout)" );
	return EXIT_FAILURE;
    }
#endif
	
    fwrite( ar, sizeof( ar[ 0 ] ), 2, output );
    
    for( c = 0; !NeuralNetLoad( &nn, stdin ); c++ )
	if( NeuralNetSaveBinary( &nn, output ) )
	    return EXIT_FAILURE;

    fprintf( stderr, "%d nets converted\n", c );
    
    return EXIT_SUCCESS;
}
