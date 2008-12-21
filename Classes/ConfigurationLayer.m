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
//  ConfigurationLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008, lhunath (Maarten Billemont). All rights reserved.
//

#import "ConfigurationLayer.h"
#import "GorillasAppDelegate.h"
#import "CityTheme.h"


@implementation ConfigurationLayer


-(id) init {
    
    if(!(self = [super init]))
        return self;
    
    return self;
}


-(void) reset {
    
    BOOL readd = false;
    
    if(menu) {
        readd = [menu parent] != nil;
        [self remove:menu];
        [menu release];
        menu = nil;
    }
    
    MenuItem *audio     = [MenuItemFont itemFromString:
                           [NSString stringWithFormat:@"%@ : %@", @"Audio Track", [[GorillasConfig get] currentTrackName]]
                                                target: self
                                              selector: @selector(audioTrack:)];
    MenuItem *theme     = [MenuItemFont itemFromString:
                           [NSString stringWithFormat:@"%@ : %@", @"City Theme", [[GorillasConfig get] cityTheme]]
                                                target: self
                                              selector: @selector(cityTheme:)];
    MenuItem *level     = [MenuItemFont itemFromString:
                           [NSString stringWithFormat:@"%@ : %@", @"Level", [[GorillasConfig get] levelName]]
                                                target: self
                                              selector: @selector(level:)];
    MenuItem *gravity   = [MenuItemFont itemFromString:
                           [NSString stringWithFormat:@"%@ : %d", @"Gravity", [[GorillasConfig get] gravity]]
                                                target: self
                                              selector: @selector(gravity:)];
    MenuItem *back      = [MenuItemFont itemFromString:@"Back"
                                                target: self
                                              selector: @selector(mainMenu:)];
    
    if([[[GorillasAppDelegate get] gameLayer] running])
        [theme setIsEnabled:false];
    
    menu = [[Menu menuWithItems:audio, theme, level, gravity, back, nil] retain];
    [menu alignItemsVertically];

    if(readd)
        [self add:menu];
}


-(void) reveal {
    
    [super reveal];
    
    [self reset];
    
    [menu do:[FadeIn actionWithDuration:[[GorillasConfig get] transitionDuration]]];
    [self add:menu];
}


-(void) level: (id) sender {
    
    NSString *curLevelName = [[GorillasConfig get] levelName];
    int curLevelInd;
    
    for(curLevelInd = 0; curLevelInd < [[GorillasConfig get] levelNameCount]; ++curLevelInd) {
        if([[[GorillasConfig get] levelNames] objectAtIndex:curLevelInd] == curLevelName)
            break;
    }

    [[GorillasConfig get] setLevel:(float) ((curLevelInd + 1) % [[GorillasConfig get] levelNameCount]) / [[GorillasConfig get] levelNameCount]];
}


-(void) gravity: (id) sender {
    
    [[GorillasConfig get] setGravity:([[GorillasConfig get] gravity] + 10) % ([[GorillasConfig get] maxGravity] + 1)];
}


-(void) cityTheme: (id) sender {
    
    NSArray *themes = [[CityTheme getThemes] allKeys];
    NSString *newTheme = [themes objectAtIndex:0];
    
    BOOL found = false;
    for(NSString *theme in themes) {
        if(found) {
            newTheme = theme;
            break;
        }
        
        if([[[GorillasConfig get] cityTheme] isEqualToString:theme])
            found = true;
    }
    
    [[[CityTheme getThemes] objectForKey:newTheme] apply];
    [[GorillasConfig get] setCityTheme:newTheme];
    
    [[[GorillasAppDelegate get] gameLayer] reset];
}


-(void) audioTrack: (id) sender {
    
    NSArray *tracks = [[[GorillasConfig get] tracks] allKeys];
    NSString *newTrack = [tracks objectAtIndex:0];
    
    BOOL found = false;
    for(NSString *track in tracks) {
        if(found) {
            newTrack = track;
            break;
        }
        
        if([[[GorillasConfig get] currentTrack] isEqualToString:track])
            found = true;
    }

    if(![newTrack length])
        newTrack = nil;
    
    [[GorillasAppDelegate get] playTrack:newTrack];
}


-(void) mainMenu: (id) sender {
    
    [[GorillasAppDelegate get] showMainMenu];
}


-(void) dealloc {
    
    [menu release];
    [super dealloc];
}


@end
