/*  Copyright 2010 Lawrence Sebald

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

#include <ctype.h>

#include "YabausePrefsController.h"

#include "cs0.h"
#include "vidogl.h"
#include "vidsoft.h"
#include "scsp.h"
#include "smpc.h"
#include "sndmac.h"
#include "PerCocoa.h"

#define BiosPathPrefKey @"BIOS Path"
#define BiosEmulatePrefKey @"Emulate BIOS"
#define SH1RomPathPrefKey @"SH1 Rom Path"
#define CartTypePrefKey @"Cartridge Type"
#define RegionPrefKey @"Region"
#define CDBlockLLEOnPrefKey @"Enable CD Block LLE"
#define HQSoundPrefKey @"Enable Higher Quality Sound"
#define MultithreadingOnPrefKey @"Enable Multithreading"
#define MpegRomPrefKey @"MPEG ROM Path"
#define CartPathPrefKey @"Cartridge Path"
#define BramPathPrefKey @"BRAM Path"
#define SoundCorePrefKey @"Sound Core"
#define VideoCorePrefKey @"Video Core"

@implementation YabausePrefsController

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *defaultsDict = @{BiosPathPrefKey: @"",
                                       BiosEmulatePrefKey: @YES,
                                       SH1RomPathPrefKey: @"",
                                       CartTypePrefKey: @(CART_NONE),
                                       RegionPrefKey: @(REGION_AUTODETECT),
                                       CDBlockLLEOnPrefKey: @NO,
                                       HQSoundPrefKey: @YES,
                                       MultithreadingOnPrefKey: @YES,
                                       MpegRomPrefKey: @"",
                                       SoundCorePrefKey: @(SNDCORE_MAC),
                                       VideoCorePrefKey: @(VIDCORE_OGL),
                                       BramPathPrefKey: @"",
                                       CartPathPrefKey: @""
                                       };
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsDict];
    });
}

- (void)awakeFromNib
{
    _cartType = CART_NONE;
    _region = REGION_AUTODETECT;
    _soundCore = SNDCORE_MAC;
    _videoCore = VIDCORE_SOFT;

    _prefs = [[NSUserDefaults standardUserDefaults] retain];

    /* Fill in all the settings. */
    if([_prefs stringForKey:BiosPathPrefKey]) {
        [biosPath setStringValue:[_prefs stringForKey:BiosPathPrefKey]];
    }
    else {
        [_prefs setObject:@"" forKey:BiosPathPrefKey];
    }

    if([_prefs objectForKey:BiosEmulatePrefKey]) {
        [emulateBios setState:[_prefs boolForKey:BiosEmulatePrefKey] ?
            NSOnState : NSOffState];
    }
    else {
        [_prefs setBool:YES forKey:BiosEmulatePrefKey];
    }
	
	if([_prefs stringForKey:SH1RomPathPrefKey]) {
		[sh1Path setStringValue:[_prefs stringForKey:SH1RomPathPrefKey]];
	}
	else {
		[_prefs setObject:@"" forKey:SH1RomPathPrefKey];
	}
	
	if([_prefs objectForKey:CDBlockLLEOnPrefKey]) {
		[cdbLLE setState:[_prefs boolForKey:CDBlockLLEOnPrefKey] ?
				   NSOnState : NSOffState];
	}
	else {
		[_prefs setBool:NO forKey:CDBlockLLEOnPrefKey];
	}
	
	if([_prefs objectForKey:HQSoundPrefKey]) {
		[newScsp setState:[_prefs boolForKey:HQSoundPrefKey] ?
				   NSOnState : NSOffState];
	}
	else {
		[_prefs setBool:YES forKey:HQSoundPrefKey];
	}
	
	if([_prefs objectForKey:MultithreadingOnPrefKey]) {
		[enableThreads setState:[_prefs boolForKey:MultithreadingOnPrefKey] ?
				   NSOnState : NSOffState];
	}
	else {
		[_prefs setBool:YES forKey:MultithreadingOnPrefKey];
	}

    if([_prefs stringForKey:MpegRomPrefKey]) {
        [mpegPath setStringValue:[_prefs stringForKey:MpegRomPrefKey]];
    }
    else {
        [_prefs setObject:@"" forKey:MpegRomPrefKey];
    }

    if([_prefs stringForKey:BramPathPrefKey]) {
        [bramPath setStringValue:[_prefs stringForKey:BramPathPrefKey]];
    }
    else {
        [_prefs setObject:@"" forKey:BramPathPrefKey];
    }

    if([_prefs stringForKey:CartPathPrefKey]) {
        [cartPath setStringValue:[_prefs stringForKey:CartPathPrefKey]];
    }
    else {
        [_prefs setObject:@"" forKey:CartPathPrefKey];
    }

    if([_prefs objectForKey:CartTypePrefKey]) {
        _cartType = [_prefs integerForKey:CartTypePrefKey];

        if(_cartType != CART_NONE && _cartType != CART_DRAM8MBIT &&
           _cartType != CART_DRAM32MBIT) {
            [cartPath setEnabled:YES];
            [cartBrowse setEnabled:YES];
            [[cartPath cell] setPlaceholderString:@"Not Set"];
        }

        [cartType selectItemWithTag:_cartType];
    }
    else {
        [_prefs setInteger:CART_NONE forKey:CartTypePrefKey];
    }

    if([_prefs objectForKey:RegionPrefKey]) {
        _region = [_prefs integerForKey:RegionPrefKey];
        [region selectItemWithTag:_region];
    }
    else {
        [_prefs setInteger:REGION_AUTODETECT forKey:RegionPrefKey];
    }

    if([_prefs objectForKey:SoundCorePrefKey]) {
        _soundCore = [_prefs integerForKey:SoundCorePrefKey];
        [soundCore selectItemWithTag:_soundCore];
    }
    else {
        [_prefs setInteger:SNDCORE_MAC forKey:SoundCorePrefKey];
    }

    if([_prefs objectForKey:VideoCorePrefKey]) {
        _videoCore = [_prefs integerForKey:VideoCorePrefKey];
        [videoCore selectItemWithTag:_videoCore];
    }
    else {
        [_prefs setInteger:VIDCORE_OGL forKey:VideoCorePrefKey];
    }

    [_prefs synchronize];
}

- (void)dealloc
{
    [_prefs release];
    [super dealloc];
}

- (void)controlTextDidEndEditing:(NSNotification *)notification
{
    id obj = [notification object];

	if(obj == sh1Path) {
		[_prefs setObject:[sh1Path stringValue] forKey:SH1RomPathPrefKey];
	}
    if(obj == biosPath) {
        [_prefs setObject:[biosPath stringValue] forKey:BiosPathPrefKey];
    }
    else if(obj == bramPath) {
        [_prefs setObject:[bramPath stringValue] forKey:BramPathPrefKey];
    }
    else if(obj == mpegPath) {
        [_prefs setObject:[mpegPath stringValue] forKey:MpegRomPrefKey];
    }
    else if(obj == cartPath) {
        [_prefs setObject:[cartPath stringValue] forKey:CartPathPrefKey];
    }

    [_prefs synchronize];
}

- (IBAction)cartSelected:(id)sender
{
    _cartType = [[sender selectedItem] tag];

    switch(_cartType) {
        case CART_NONE:
        case CART_DRAM8MBIT:
        case CART_DRAM32MBIT:
            [cartPath setEnabled:NO];
            [cartPath setStringValue:@""];
            [cartBrowse setEnabled:NO];
            [[cartPath cell] setPlaceholderString:
             @"No file required for the selected cartridge"];
            break;

        default:
            [cartPath setEnabled:YES];
            [cartBrowse setEnabled:YES];
            [[cartPath cell] setPlaceholderString:@"Not Set"];
            break;
    }

    /* Update the preferences file. */
    [_prefs setObject:[cartPath stringValue] forKey:CartPathPrefKey];
    [_prefs setInteger:_cartType forKey:CartTypePrefKey];
    [_prefs synchronize];
}

- (IBAction)regionSelected:(id)sender
{
    _region = [[sender selectedItem] tag];

    /* Update the preferences file. */
    [_prefs setInteger:_region forKey:RegionPrefKey];
    [_prefs synchronize];
}

- (IBAction)soundCoreSelected:(id)sender
{
    _soundCore = [[sender selectedItem] tag];

    /* Update the preferences file. */
    [_prefs setInteger:_soundCore forKey:SoundCorePrefKey];
    [_prefs synchronize];
}

- (IBAction)videoCoreSelected:(id)sender
{
    _videoCore = [[sender selectedItem] tag];

    /* Update the preferences file. */
    [_prefs setInteger:_videoCore forKey:VideoCorePrefKey];
    [_prefs synchronize];
}

- (IBAction)biosBrowse:(id)sender
{
    NSOpenPanel *p = [NSOpenPanel openPanel];

    [p setTitle:@"Select a Saturn BIOS ROM"];

    if([p runModal] == NSFileHandlingPanelOKButton) {
        [biosPath setStringValue:[[[p URLs] objectAtIndex:0] path]];

        /* Update the preferences file. */
        [_prefs setObject:[p URL].path forKey:BiosPathPrefKey];
        [_prefs synchronize];
    }
}

- (IBAction)sh1Browse:(id)sender
{
	NSOpenPanel *p = [NSOpenPanel openPanel];
	
	[p setTitle:@"Select a Saturn SH1 Rom"];
	
	if([p runModal] == NSFileHandlingPanelOKButton) {
		[sh1Path setStringValue:[[[p URLs] objectAtIndex:0] path]];
		
		/* Update the preferences file. */
		[_prefs setObject:[sh1Path stringValue] forKey:SH1RomPathPrefKey];
		[_prefs synchronize];
	}
}

- (IBAction)mpegBrowse:(id)sender
{
    NSOpenPanel *p = [NSOpenPanel openPanel];

    [p setTitle:@"Select a MPEG ROM"];

    if([p runModal] == NSFileHandlingPanelOKButton) {
        [mpegPath setStringValue:[[[p URLs] objectAtIndex:0] path]];

        /* Update the preferences file. */
        [_prefs setObject:[p URL].path forKey:MpegRomPrefKey];
        [_prefs synchronize];
    }
}

- (IBAction)bramBrowse:(id)sender
{
    NSOpenPanel *p = [NSOpenPanel openPanel];

    [p setTitle:@"Select a BRAM File"];

    if([p runModal] == NSFileHandlingPanelOKButton) {
        [bramPath setStringValue:[[[p URLs] objectAtIndex:0] path]];

        /* Update the preferences file. */
        [_prefs setObject:[bramPath stringValue] forKey:BramPathPrefKey];
        [_prefs synchronize];
    }
}

- (IBAction)cartBrowse:(id)sender
{
    NSOpenPanel *p = [NSOpenPanel openPanel];

    [p setTitle:@"Select the Cartridge File"];

    if([p runModal] == NSFileHandlingPanelOKButton) {
        [cartPath setStringValue:[[[p URLs] objectAtIndex:0] path]];

        /* Update the preferences file. */
        [_prefs setObject:p.URL.path forKey:CartPathPrefKey];
        [_prefs synchronize];
    }
}

- (IBAction)biosToggle:(id)sender
{
    /* Update the preferences file. */
    [_prefs setBool:([sender state] == NSOnState) forKey:BiosEmulatePrefKey];
    [_prefs synchronize];
}

- (IBAction)cdbToggle:(id)sender
{
	/* Update the preferences file. */
	[_prefs setBool:([sender state] == NSOnState) forKey:CDBlockLLEOnPrefKey];
	[_prefs synchronize];
}

- (IBAction)scspToggle:(id)sender
{
	/* Update the preferences file. */
	[_prefs setBool:([sender state] == NSOnState) forKey:HQSoundPrefKey];
	[_prefs synchronize];
}

- (IBAction)threadsToggle:(id)sender
{
	/* Update the preferences file. */
	[_prefs setBool:([sender state] == NSOnState) forKey:MultithreadingOnPrefKey];
	[_prefs synchronize];
}

- (IBAction)buttonSelect:(id)sender
{
    NSInteger rv;
    NSInteger tag = [sender tag];
    int port = tag > 12 ? 1 : 0;
    u8 num = tag > 12 ? tag - 13 : tag;
    u32 value = PERCocoaGetKey(num, port);
    unichar ch;

    /* Fill in current setting from prefs */
    if(value != (u32)-1) {
        switch(value) {
            case '\r':
                ch = 0x23CE;
                break;

            case '\t':
                ch = 0x21E5;
                break;

            case 27:
                ch = 0x241B;
                break;

            case 127:
                ch = 0x232B;
                break;

            case NSLeftArrowFunctionKey:
                ch = 0x2190;
                break;

            case NSUpArrowFunctionKey:
                ch = 0x2191;
                break;

            case NSRightArrowFunctionKey:
                ch = 0x2192;
                break;

            case NSDownArrowFunctionKey:
                ch = 0x2193;
                break;

            default:
                ch = toupper(((int)value));
        }

        [buttonBox setStringValue:[NSString stringWithCharacters:&ch length:1]];
    }
    else {
        [buttonBox setStringValue:@""];
    }

    /* Open up the sheet and ask for the user's input */
    [NSApp beginSheet:buttonAssignment
       modalForWindow:prefsPane
        modalDelegate:self
       didEndSelector:nil
          contextInfo:NULL];

    rv = [NSApp runModalForWindow:buttonAssignment];
    [NSApp endSheet:buttonAssignment];
    [buttonAssignment orderOut:nil];

    /* Did the user accept what they put in? */
    if(rv == NSOKButton) {
        NSString *s = [buttonBox stringValue];
        u32 val;

        /* This shouldn't happen... */
        if([s length] < 1) {
            return;
        }

        switch([s characterAtIndex:0]) {
            case 0x23CE:    /* Return */
                val = '\r';
                break;

            case 0x21E5:    /* Tab */
                val = '\t';
                break;

            case 0x241B:    /* Escape */
                val = 27;
                break;

            case 0x232B:    /* Backspace */
                val = 127;
                break;

            case 0x2190:    /* Left */
                val = NSLeftArrowFunctionKey;
                break;

            case 0x2191:    /* Up */
                val = NSUpArrowFunctionKey;
                break;

            case 0x2192:    /* Right */
                val = NSRightArrowFunctionKey;
                break;

            case 0x2193:    /* Down */
                val = NSDownArrowFunctionKey;
                break;

            default:
                val = tolower([s characterAtIndex:0]);
        }

        /* Update the key mapping, if we're already running. This will also save
           the key to the preferences. */
        if(tag > 12) {
            PERCocoaSetKey(val, tag - 13, 1);
        }
        else {
            PERCocoaSetKey(val, tag, 0);
        }
    }
}

- (IBAction)buttonSetOk:(id)sender
{
    [NSApp stopModalWithCode:NSOKButton];
}

- (IBAction)buttonSetCancel:(id)sender
{
    [NSApp stopModalWithCode:NSCancelButton];
}

@synthesize cartType=_cartType;
@synthesize region=_region;
@synthesize soundCore=_soundCore;
@synthesize videoCore=_videoCore;

- (NSString *)biosPath
{
    return [biosPath stringValue];
}

- (NSString *)sh1Path
{
	return [sh1Path stringValue];
}

- (BOOL)emulateBios
{
    return [emulateBios state] == NSOnState;
}

- (BOOL)cdbLLE
{
	return [cdbLLE state] == NSOnState;
}

- (BOOL)newScsp
{
	return [newScsp state] == NSOnState;
}

- (BOOL)enableThreads
{
	return [enableThreads state] == NSOnState;
}

- (NSString *)mpegPath
{
    return [mpegPath stringValue];
}

- (NSString *)bramPath
{
    return [bramPath stringValue];
}

- (NSString *)cartPath
{
    return [cartPath stringValue];
}

@end /* @implementation YabausePrefsController */
