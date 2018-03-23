/*  Copyright 2010-2011 Lawrence Sebald

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

#ifndef YabausePrefsController_h
#define YabausePrefsController_h

#import <Cocoa/Cocoa.h>

@interface YabausePrefsController : NSObject <NSTextFieldDelegate> {
    IBOutlet NSTextField *biosPath;
    IBOutlet NSTextField *sh1Path;
    IBOutlet NSTextField *bramPath;
    IBOutlet NSButton *cartBrowse;
    IBOutlet NSTextField *cartPath;
    IBOutlet NSPopUpButton *cartType;
    IBOutlet NSButton *emulateBios;
    IBOutlet NSButton *cdbLLE;
    IBOutlet NSButton *newScsp;
    IBOutlet NSButton *enableThreads;
    IBOutlet NSTextField *mpegPath;
    IBOutlet NSPopUpButton *region;
    IBOutlet NSPopUpButton *soundCore;
    IBOutlet NSPopUpButton *videoCore;
    IBOutlet NSPanel *prefsPane;
    IBOutlet NSPanel *buttonAssignment;
    IBOutlet NSTextField *buttonBox;

    int _cartType;
    int _region;
    int _soundCore;
    int _videoCore;

    NSUserDefaults *_prefs;
}

- (IBAction)cartSelected:(id)sender;
- (IBAction)regionSelected:(id)sender;
- (IBAction)soundCoreSelected:(id)sender;
- (IBAction)videoCoreSelected:(id)sender;
- (IBAction)biosBrowse:(id)sender;
- (IBAction)sh1Browse:(id)sender;
- (IBAction)mpegBrowse:(id)sender;
- (IBAction)bramBrowse:(id)sender;
- (IBAction)cartBrowse:(id)sender;
- (IBAction)biosToggle:(id)sender;
- (IBAction)scspToggle:(id)sender;
- (IBAction)cdbToggle:(id)sender;
- (IBAction)threadsToggle:(id)sender;
- (IBAction)buttonSelect:(id)sender;

- (IBAction)buttonSetOk:(id)sender;
- (IBAction)buttonSetCancel:(id)sender;

@property (readonly) int cartType;
@property (readonly) int region;
@property (readonly) int soundCore;
@property (readonly) int videoCore;
@property (readonly, strong) NSString *biosPath;
@property (readonly, strong) NSString *sh1Path;
@property (readonly) BOOL cdbLLE;
@property (readonly) BOOL emulateBios;
@property (readonly) BOOL newScsp;
@property (readonly) BOOL enableThreads;
@property (readonly, strong) NSString *mpegPath;
@property (readonly, strong) NSString *bramPath;
@property (readonly, strong) NSString *cartPath;

@end

#endif /* !YabausePrefsController_h */
