/*  Copyright 2010, 2012 Lawrence Sebald

    This file is part of Yabause.

    Yabause is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    Yabause is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Yabause; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
*/

#import <Cocoa/Cocoa.h>
#include <dispatch/dispatch.h>

#include "yui.h"
#include "peripheral.h"
#include "m68kcore.h"
#include "m68kc68k.h"
#include "permacjoy.h"
#include "sndmac.h"
#include "vidogl.h"
#include "vidsoft.h"
#include "vidgcd.h"
#include "cs0.h"
#include "vdp2.h"
#ifdef HAVE_LIBAL
#include "sndal.h"
#endif
#if defined(DEBUG) && DEBUG
#include "debug.h"
#endif

#include "PerCocoa.h"
#include "YabauseController.h"
#include "YabauseGLView.h"

M68K_struct *M68KCoreList[] = {
    &M68KDummy,
#ifdef HAVE_MUSASHI
	&M68KMusashi,
#endif
#ifdef HAVE_C68K
    &M68KC68K,
#endif
    NULL
};

SH2Interface_struct *SH2CoreList[] = {
    &SH2Interpreter,
    &SH2DebugInterpreter,
    NULL
};

PerInterface_struct *PERCoreList[] = {
    &PERDummy,
    &PERCocoa,
    &PERMacJoy,
    NULL
};

CDInterface *CDCoreList[] = {
    &DummyCD,
    &ISOCD,
    &ArchCD,
    NULL
};

SoundInterface_struct *SNDCoreList[] = {
    &SNDDummy,
    &SNDMac,
#ifdef HAVE_LIBAL
    &SNDAL,
#endif
    NULL
};

VideoInterface_struct *VIDCoreList[] = {
    &VIDDummy,
    &VIDOGL,
    &VIDSoft,
    &VIDGCD,
    NULL
};

void YuiErrorMsg(const char *string) {
    NSString *str = [NSString stringWithUTF8String:string];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSRunAlertPanel(@"Yabause Error", @"%@", @"OK", NULL, NULL, str);
    });
}

void YuiSwapBuffers(void) {
    [[controller view] setNeedsDisplay:YES];
}

int main(int argc, char *argv[]) {
#if defined(DEBUG) && DEBUG
    LogStart();
#endif
    return NSApplicationMain(argc,  (const char **) argv);
}
