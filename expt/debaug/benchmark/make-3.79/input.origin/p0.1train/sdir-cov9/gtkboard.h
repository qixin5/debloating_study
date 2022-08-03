/*
 * gtkboard.h
 *
 * by Gary Wong <gtw@gnu.org>, 1997-2000.
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
 * $Id: gtkboard.h,v 1.7 2001/01/30 15:52:10 gtw Exp $
 */

#ifndef _GTKBOARD_H_
#define _GTKBOARD_H_

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */
    
#define TYPE_BOARD ( board_get_type() )
#define BOARD( obj ) ( GTK_CHECK_CAST( (obj), TYPE_BOARD, Board ) )
#define BOARD_CLASS( c ) ( GTK_CHECK_CLASS_CAST( (c), TYPE_BOARD, \
	BoardClass ) )
#define IS_BOARD( obj ) ( GTK_CHECK_TYPE( (obj), TYPE_BOARD ) )
#define IS_BOARD_CLASS( c ) ( GTK_CHECK_CLASS_TYPE( (c), TYPE_BOARD ) )

typedef struct _Board {
    GtkVBox vbox;
    gpointer board_data;
} Board;
    
typedef struct _BoardClass {
    GtkVBoxClass parent_class;
} BoardClass;

extern GtkType board_get_type( void );    
extern GtkWidget *board_new( void );
extern GtkWidget *board_dice_widget( Board *board );
extern gint game_set( Board *board, gint points[ 2 ][ 25 ], int roll,
		      gchar *name, gchar *opp_name, gint match,
		      gint score, gint opp_score, gint die0, gint die1 );
extern gint game_set_old_dice( Board *board, gint die0, gint die1 );
    
/* private data */
typedef struct _BoardData {
    GtkWidget *drawing_area, *dice_area, *hbox_pos, *table, *hbox_match, *move,
	*position_id, *reset, *edit, *name0, *name1, *score0, *score1, *match,
	*crawford, *widget, *key0, *key1, *stop;
    GdkGC *gc_and, *gc_or, *gc_copy, *gc_cube;
    GdkPixmap *pm_board, *pm_x, *pm_o, *pm_x_dice, *pm_o_dice, *pm_x_pip,
	*pm_o_pip, *pm_cube, *pm_saved, *pm_temp, *pm_temp_saved, *pm_point,
	*pm_x_key, *pm_o_key;
    GdkBitmap *bm_mask, *bm_dice_mask, *bm_cube_mask, *bm_key_mask;
    guchar *rgba_x, *rgba_o, *rgba_x_key, *rgba_o_key, *rgb_points, *rgb_empty,
	*rgb_saved, *rgb_temp, *rgb_temp_saved, *rgb_bar;
    short *ai_refract[ 2 ];
    GdkFont *cube_font;
    gboolean translucent;
    gdouble aarColour[ 2 ][ 4 ]; /* RGBA for each player */
    guchar aanBoardColour[ 4 ][ 4 ]; /* RGB(A) for background, border, pts */
    int aSpeckle[ 4 ]; /* speckle for background, border, pts */
    gfloat arRefraction[ 2 ], arCoefficient[ 2 ], arExponent[ 2 ],
	arLight[ 3 ];
    gint board_size; /* basic unit of board size, in pixels -- a chequer's
			diameter is 6 of these units (and is 2 units thick) */
    gint drag_point, drag_colour, x_drag, y_drag, x_dice[ 2 ], y_dice[ 2 ],
	dice_colour[ 2 ], cube_font_rotated, old_board[ 2 ][ 25 ],
	dice_roll[ 2 ]; /* roll showing on the off-board dice */
    gint cube_owner; /* -1 = bottom, 0 = centred, 1 = top */
    move *all_moves, *valid_move;
    movelist move_list;
    
    /* remainder is from FIBS board: data */
    char name[ 32 ], name_opponent[ 32 ];
    gint match_to, score, score_opponent;
    gint points[ 28 ]; /* 0 and 25 are the bars */
    gint turn; /* -1 is X, 1 is O, 0 if game over */
    gint dice[ 2 ], dice_opponent[ 2 ]; /* 0, 0 if not rolled */
    gint cube;
    gint can_double, opponent_can_double; /* allowed to double */
    gint doubled; /* -1 if X is doubling, 1 if O is doubling */
    gint colour; /* -1 for player X, 1 for player O */
    gint direction; /* -1 playing from 24 to 1, 1 playing from 1 to 24 */
    gint home, bar; /* 0 or 25 depending on fDirection */
    gint off, off_opponent; /* number of men borne off */
    gint on_bar, on_bar_opponent; /* number of men on bar */
    gint to_move; /* 0 to 4 -- number of pieces to move */
    gint forced, crawford_game; /* unused, Crawford game flag */
    gint redoubles; /* number of instant redoubles allowed */
} BoardData;
    
extern void board_create_pixmaps( GtkWidget *board, BoardData *bd );
extern void board_free_pixmaps( BoardData *bd );
  
#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif
