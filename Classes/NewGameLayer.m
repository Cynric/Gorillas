/*
 * This file is part of Gorillas.
 *
 *  Gorillas is open software: you can use or modify it under the
 *  terms of the Java Research License or optionally a more
 *  permissive Commercial License.
 *
 *  Gorillas is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 *  You should have received a copy of the Java Research License
 *  along with Gorillas in the file named 'COPYING'.
 *  If not, see <http://stuff.lhunath.com/COPYING>.
 */

//
//  NewGameLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 28/02/09.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "NewGameLayer.h"
#import "GorillasAppDelegate.h"
#import "MenuItemSpacer.h"


@implementation NewGameLayer


-(void) reset {
    
    if(menu) {
        [self removeChild:menu cleanup:YES];
        [menu release];
        menu = nil;
        
        [self removeChild:backMenu cleanup:YES];
        [backMenu release];
        backMenu = nil;
    }
    
    
    // Game Configuration.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *styleT    = [MenuItemFont itemFromString:NSLocalizedString(@"entries.choose.style", @"Choose a game style:")];
    [styleT setIsEnabled:NO];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *configurationI    = [MenuItemFont itemFromString:[[GorillasConfig get] gameConfiguration].name
                                                   target:self
                                                 selector:@selector(gameConfiguration:)];
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *descriptionT    = [MenuItemFont itemFromString:[[GorillasConfig get] gameConfiguration].description];
    [descriptionT setIsEnabled:NO];
    
    
    // Type (Single / Multi).
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *singlePlayerI    = [MenuItemFont itemFromString:NSLocalizedString(@"entries.player.single", @"Single Player")
                                                    target:self
                                                  selector:@selector(startSingle:)];
    [singlePlayerI setIsEnabled:[[GorillasConfig get] gameConfiguration].sHumans + [[GorillasConfig get] gameConfiguration].sAis > 0];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *multiPlayerI    = [MenuItemFont itemFromString:NSLocalizedString(@"entries.player.multi", @"Multi Player")
                                                       target:self
                                                     selector:@selector(startMulti:)];
    [multiPlayerI setIsEnabled:[[GorillasConfig get] gameConfiguration].mHumans + [[GorillasConfig get] gameConfiguration].mAis > 0];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *customI    = [MenuItemFont itemFromString:NSLocalizedString(@"entries.choose.custom", @"Custom Game...")
                                                      target:self
                                                    selector:@selector(custom:)];
    
    
    menu = [[Menu menuWithItems:
             styleT, configurationI, descriptionT, [MenuItemSpacer small],
             singlePlayerI, multiPlayerI, [MenuItemSpacer small],
             customI,
             nil] retain];
    [menu alignItemsVertically];
    [self addChild:menu];
    
    
    // Back.
    [MenuItemFont setFontSize:[[GorillasConfig get] largeFontSize]];
    MenuItem *back     = [MenuItemFont itemFromString:@"   <   "
                                               target: self
                                             selector: @selector(back:)];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    
    backMenu = [[Menu menuWithItems:back, nil] retain];
    [backMenu setPosition:cpv([[GorillasConfig get] fontSize], [[GorillasConfig get] fontSize])];
    [backMenu alignItemsHorizontally];
    [self addChild:backMenu];
}


-(void) onEnter {
    
    [self reset];
    
    [super onEnter];
}


-(void) gameConfiguration:(id) sender {
    
    [[GorillasAudioController get] clickEffect];

    ++[GorillasConfig get].activeGameConfigurationIndex;
}


-(void) startSingle: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    
    [[[GorillasAppDelegate get] gameLayer] configureGameWithMode:[GorillasConfig get].gameConfiguration.mode
                                                          humans:[GorillasConfig get].gameConfiguration.sHumans
                                                             ais:[GorillasConfig get].gameConfiguration.sAis];
    [[[GorillasAppDelegate get] gameLayer] startGame];
}


-(void) startMulti: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    
    [[[GorillasAppDelegate get] gameLayer] configureGameWithMode:[GorillasConfig get].gameConfiguration.mode
                                                          humans:[GorillasConfig get].gameConfiguration.mHumans
                                                             ais:[GorillasConfig get].gameConfiguration.mAis];
    [[[GorillasAppDelegate get] gameLayer] startGame];
}


-(void) custom: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get] showCustomGame];
}


-(void) back: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get] popLayer];
}


-(void) dealloc {
    
    [menu release];
    menu = nil;
    
    [backMenu release];
    backMenu = nil;
    
    [super dealloc];
}


@end
