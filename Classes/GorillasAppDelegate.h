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
//  GorillasAppDelegate.h
//  Gorillas
//
//  Created by Maarten Billemont on 18/10/08.
//  Copyright, lhunath (Maarten Billemont) 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameLayer.h"
#import "MainMenuLayer.h"
#import "ContinueMenuLayer.h"
#import "ConfigurationSectionLayer.h"
#import "GameConfigurationLayer.h"
#import "AVConfigurationLayer.h"
#import "TrainingConfigurationLayer.h"
#import "InformationLayer.h"
#import "GuideLayer.h"
#import "StatisticsLayer.h"
#import "HUDLayer.h"
#import "AudioController.h"
#import "AudioControllerDelegate.h"


@interface GorillasAppDelegate : NSObject <UIApplicationDelegate, AudioControllerDelegate> {
    
    UIWindow                    *window;
    
    Layer                       *uiLayer;
    GameLayer                   *gameLayer;
    ShadeLayer                  *currentLayer;
    ContinueMenuLayer           *continueMenuLayer;
    MainMenuLayer               *mainMenuLayer;
    ConfigurationSectionLayer   *configLayer;
    GameConfigurationLayer      *gameConfigLayer;
    AVConfigurationLayer        *avConfigLayer;
    TrainingConfigurationLayer  *trainingLayer;
    InformationLayer            *infoLayer;
    GuideLayer                  *guideLayer;
    StatisticsLayer             *statsLayer;
    HUDLayer                    *hudLayer;
    AudioController             *audioController;
    NSString                    *nextTrack;
}

@property (readonly) Layer                      *uiLayer;
@property (readonly) GameLayer                  *gameLayer;
@property (readonly) HUDLayer                   *hudLayer;

-(void) updateConfig;
-(void) clickEffect;
-(void) dismissLayer;
-(void) cleanup;

-(void) showMainMenu;
-(void) showContinueMenu;
-(void) showConfiguration;
-(void) showGameConfiguration;
-(void) showAVConfiguration;
-(void) showTraining;
-(void) showInformation;
-(void) showGuide;
-(void) showStatistics;
-(void) revealHud;
-(void) hideHud;

-(void) playTrack:(NSString *)track;
-(void) startNextTrack;

+(GorillasAppDelegate *) get;


@end

