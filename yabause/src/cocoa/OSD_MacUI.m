//
//  OSD_MacUI.m
//  Yabause
//
//  Created by C.W. Betts on 3/22/18.
//

#import <Cocoa/Cocoa.h>
#include <OpenGL/gl3.h>
#include "osdcore.h"
#import "YabauseMacOSD.h"

#ifdef USING_COCOA

static YabauseMacOSD *osdWindow;

static int OSDMacUIInit(void);
static void OSDMacUIDeInit(void);
static void OSDMacUIReset(void);
static void OSDMacUIDisplayMessage(OSDMessage_struct * message, pixel_t * buffer, int w, int h);
static int OSDMacUIUseBuffer(void);


OSD_struct OSDMacUI = {
    OSDCORE_MACUI,
    "Mac UI OSD Interface",
    OSDMacUIInit,
    OSDMacUIDeInit,
    OSDMacUIReset,
    OSDMacUIDisplayMessage,
    OSDMacUIUseBuffer,
};

int OSDMacUIInit(void)
{
    osdWindow = [[YabauseMacOSD alloc] initWithWindowNibName:@"MacOSD"];
    if (!osdWindow) {
        return 1;
    }
    return 0;
}

void OSDMacUIDeInit(void)
{
    [osdWindow close];
    osdWindow = nil;
}

void OSDMacUIReset(void)
{
    [osdWindow.messageTextView.textStorage beginEditing];
    [osdWindow.messageTextView.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:@""]];
    [osdWindow.messageTextView.textStorage endEditing];
}

void OSDMacUIDisplayMessage(OSDMessage_struct * message, pixel_t * buffer, int w, int h)
{
    NSString *str = message->message ? @(message->message) : nil;
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    switch (message->type) {
        case OSDMSG_STATUS:
            break;
            
        case OSDMSG_DEBUG:
            [attrStr setAttributes:@{NSForegroundColorAttributeName: NSColor.systemOrangeColor} range:NSMakeRange(0, attrStr.length)];
            break;
            
        case OSDMSG_FPS:
            osdWindow.fpsField.stringValue = str;
            return;
            break;
            
        default:
            break;
    }
    [osdWindow.messageTextView.textStorage beginEditing];
    [osdWindow.messageTextView.textStorage appendAttributedString:attrStr];
    [osdWindow.messageTextView.textStorage endEditing];
}

int OSDMacUIUseBuffer(void)
{
    return 0;
}


#endif
