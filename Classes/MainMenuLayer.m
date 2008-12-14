/*
 * This file is part of Gorillas.
 *
 *  Gorillas is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
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
//  Copyright 2008, lhunath (Maarten Billemont). All rights reserved.
//

#import "MainMenuLayer.h"
#import "GorillasConfig.h"
#import "GorillasAppDelegate.h"


@implementation MainMenuLayer


-(id) init {

    if(!(self = [super init]))
        return self;
    
    newSingle = [[MenuItemFont itemFromString:@"Single Player" target:self selector:@selector(newGameSingle:)] retain];
    newMulti = [[MenuItemFont itemFromString:@"Multiplayer" target:self selector:@selector(newGameMulti:)] retain];

    continueGame = [[MenuItemFont itemFromString:@"Continue Game" target:self selector:@selector(continueGame:)] retain];
    stopGame = [[MenuItemFont itemFromString:@"End Game" target:self selector:@selector(stopGame:)] retain];
    
    config = [[MenuItemFont itemFromString:@"Configuration" target:self selector:@selector(options:)] retain];
    info = [[MenuItemFont itemFromString:@"Information" target:self selector:@selector(information:)] retain];
    
    return self;
}


-(void) reveal {
    
    [super reveal];
    
    if(menu) {
        [self remove:menu];
        [menu release];
        menu = nil;
    }
    
    if([[[GorillasAppDelegate get] gameLayer] running])
        menu = [[Menu menuWithItems:continueGame, stopGame, config, info, nil] retain];
    else
        menu = [[Menu menuWithItems:newSingle, newMulti, config, info, nil] retain];

    [menu alignItemsVertically];
    [menu do:[FadeIn actionWithDuration:[[GorillasConfig get] transitionDuration]]];
    [self add:menu];
}


-(void) newGameSingle: (id)sender {
    
    [[[GorillasAppDelegate get] gameLayer] startSinglePlayer];
}


-(void) newGameMulti: (id)sender {

    [[[GorillasAppDelegate get] gameLayer] startMultiplayer];
}


-(void) continueGame: (id)sender {
    
    [[[GorillasAppDelegate get] gameLayer] unpause];
}


-(void) stopGame: (id)sender {
    
    [[[GorillasAppDelegate get] gameLayer] stopGame];
}


-(void) information: (id)sender {
    
    [[GorillasAppDelegate get] showInformation];
}


-(void) options: (id)sender {
    
    [[GorillasAppDelegate get] showConfiguration];
}


-(void) dealloc {
    
    [menu release];
    [newSingle release];
    [newMulti release];
    [continueGame release];
    [stopGame release];
    [config release];
    [info release];
    
    [super dealloc];
}


@end
