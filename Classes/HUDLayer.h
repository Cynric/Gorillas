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
//  HUDLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 10/11/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"


@interface HUDLayer : Layer {

    MenuItemFont *menuButton;
    Menu *menuMenu;
    LabelAtlas *infoLabel;
    Layer *livesLayer;
    Sprite *infiniteLives;
    
    float width;
    float height;
}

-(void) dismiss;

-(void) setInfoString: (NSString *)string;
-(void) updateHudWithScore:(int)score skill: (float)throwSkill;

-(BOOL) hitsHud: (cpVect)pos;

@end
