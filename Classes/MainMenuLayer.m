/*
 * This file is part of Gorillas.
 *
 *  Gorillas is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  Gorillas is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Gorillas in the file named 'COPYING'.
 *  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  MainMenuLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "MainMenuLayer.h"
#import "GorillasAppDelegate.h"
#import "MenuItemSpacer.h"


@implementation MainMenuLayer


-(id) init {

    if(!(self = [super init]))
        return self;
    
    return self;
}


-(void) onEnter {
    
    [self reset];

    [super onEnter];
}


-(void) reset {

    if(menu) {
        [menu removeAllChildrenWithCleanup:YES];
        [self removeChild:menu cleanup:YES];
        [menu release];
        menu = nil;
    }

    MenuItemFont *info              = [MenuItemFont itemFromString:NSLocalizedString(@"entries.information", @"Information")
                                                            target:self selector:@selector(information:)];
    MenuItemFont *config            = [MenuItemFont itemFromString:NSLocalizedString(@"entries.configuration", @"Configuration")
                                                            target:self selector:@selector(options:)];
    
    if([[[GorillasAppDelegate get] gameLayer] checkGameStillOn]) {
        MenuItemFont *continueGame  = [MenuItemFont itemFromString:NSLocalizedString(@"entries.continue.game", @"Continue Game")
                                                            target:self selector:@selector(continueGame:)];
        MenuItemFont *stopGame      = [MenuItemFont itemFromString:NSLocalizedString(@"entries.end", @"End Game")
                                                            target:self selector:@selector(stopGame:)];
        
        menu = [[Menu menuWithItems:
                 continueGame, stopGame, [MenuItemSpacer small],
                 info, config,
                 nil] retain];
    }
    else {
        MenuItemFont *newGame       = [MenuItemFont itemFromString:NSLocalizedString(@"entries.new", @"New Game")
                                                            target:self selector:@selector(newGame:)];
        
        menu = [[Menu menuWithItems:
                 newGame, [MenuItemSpacer small],
                 info, config,
                 nil] retain];
    }
    
    [menu alignItemsVertically];
    [self addChild:menu];
}


-(void) newGame: (id)sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get] showNewGame];
}


-(void) continueGame: (id)sender {
    
    [[GorillasAudioController get] clickEffect];
    [[[GorillasAppDelegate get] gameLayer] setPaused:NO];
}


-(void) stopGame: (id)sender {
    
    [[GorillasAudioController get] clickEffect];
    [[[GorillasAppDelegate get] gameLayer] stopGame];
}


-(void) information: (id)sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get] showInformation];
}


-(void) options: (id)sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get] showConfiguration];
}


-(void) dealloc {
    
    [menu release];
    menu = nil;

    [super dealloc];
}


@end
