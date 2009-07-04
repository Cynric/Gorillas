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
//  CityLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "PanAction.h"
#import "GorillaLayer.h"
#import "BananaLayer.h"
#import "Resettable.h"
#import "ExplosionsLayer.h"
#import "HolesLayer.h"
#import "BarSprite.h"
//#define _DEBUG_

@interface CityLayer : Layer <Resettable> {

    PanAction           *panAction;
    LabelAtlas          *angleLabel, *strengthLabel;
    Label               *msgLabel, *infoLabel;
    BarSprite           *aimSprite;
    
    NSMutableArray      *buildings;
    HolesLayer          *holes;
    ExplosionsLayer     *explosions;

    CGPoint             aim;
    BananaLayer         *bananaLayer;
    GorillaLayer        *hitGorilla;
    
    CGPoint             *throwHistory;
    NSMutableArray      *throwHints;
    
    SystemSoundID       goEffect;
    
#ifdef _DEBUG_
    NSUInteger          dbgTraceStep;
    NSUInteger          dbgPathMaxInd;
    NSUInteger          dbgPathCurInd;
    CGPoint              *dbgPath;
    NSUInteger          dbgAIMaxInd;
    NSUInteger          dbgAICurInd;
    GorillaLayer        **dbgAI;
    CGPoint              *dbgAIVect;
#endif
}

-(void) startGame;
-(void) stopGame;

-(void) startPanning;
-(void) stopPanning;

-(BOOL) mayThrow;

-(void) miss;
-(BOOL) hitsGorilla: (CGPoint)pos;
-(BOOL) hitsBuilding: (CGPoint)pos;
-(void) explodeAt: (CGPoint)point isGorilla:(BOOL)isGorilla;
-(void) throwFrom:(GorillaLayer *)gorilla withVelocity:(CGPoint)v;
-(void) nextGorilla;

-(void) message: (NSString *)msg on: (CocosNode *)node;
-(CGPoint) calculateThrowFrom:(CGPoint)r0 to:(CGPoint)rt errorLevel:(CGFloat)l;

-(CGFloat) left;
-(CGFloat) right;

@property (nonatomic, readwrite) CGPoint aim;
@property (nonatomic, readonly) BananaLayer *bananaLayer;
@property (nonatomic, readonly) GorillaLayer *hitGorilla;

@end
