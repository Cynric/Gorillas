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
//  HUDLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 10/11/08.
//  Copyright 2008, lhunath (Maarten Billemont). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"


@interface HUDLayer : Layer {

    MenuItemFont *menuButton;
    Menu *menuMenu;
    Label *scoreLabel;
    ccTime progress;
    
    BOOL revealed;

    float width;
    float height;
}

-(void) reveal;
-(void) dismiss;

-(void) setMenuTitle: (NSString *)title;
-(void) updateScore: (int)nScore;

-(BOOL) hitsHud: (cpVect)pos;

@property (readwrite) ccTime progress;

@end
