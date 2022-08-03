/*
 * event.h
 *
 * by Gary Wong, 1996-2000
 *
 * $Id: event.h,v 1.4 2000/07/31 20:29:29 gtw Exp $
 */

#ifndef _EVENT_H_
#define _EVENT_H_

#include "config.h"

#include <list.h>
#if defined HAVE_SYS_TIME_H || !defined HAVE_CONFIG_H
#include <sys/time.h>
#endif

#if HAVE_SELECT
#define HAVE_EVENT 1

typedef struct _event event;
typedef struct _eventhandler eventhandler;

typedef int ( *eventhandlerfunc )( event *pev, void *pv );

struct _eventhandler {
    eventhandlerfunc fnEvent, fnTimeout;
};

struct _event {
    eventhandler *peh; /* who handles it */
    int fPending; /* has it happened */
    int fHandlerReady; /* is the handler ready */
    list *pl; /* only valid if fPending; sorted in order of timeouts */
    struct timeval tv; /* when does it have to happen by */
    void *pvData; /* user-defined */
    int h; /* activity on which file handle will make it happen (-1 if none) */
    int fWrite; /* readable or writable on h makes it happen */
};

extern int EventCreate( event *pev, eventhandler *peh, void *pvData );
extern int EventDestroy( event *pev );

extern int EventProcess( event *pev );
extern int EventTimeout( event *pev );

extern int EventHandlerReady( event *pev, int fReady, long nTimeout );
extern int EventPending( event *pev, int fPending );

extern int InitEvents( void );
extern int HandleEvents( void );
extern int StopEvents( void );
#endif

#endif
