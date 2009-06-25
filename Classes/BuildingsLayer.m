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
//  BuildingsLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "BuildingsLayer.h"
#import "BuildingLayer.h"
#import "ExplosionLayer.h"
#import "GorillasAppDelegate.h"
#import "Utility.h"

@implementation BuildingsLayer


-(id) init {
    
    if (!(self = [super init]))
		return self;

#ifdef _DEBUG_
    dbgTraceStep    = 2;
    dbgPathMaxInd   = 50;
    dbgPathCurInd   = 0;
    dbgPath         = malloc(sizeof(cpVect) * dbgPathMaxInd);
    dbgAIMaxInd   = 1;
    dbgAICurInd   = 0;
    dbgAI           = malloc(sizeof(GorillaLayer *) * dbgAIMaxInd);
    dbgAIVect       = malloc(sizeof(cpVect) * dbgAIMaxInd);
#endif
    
    throwHints      = [[NSMutableArray alloc] initWithCapacity:2];
    
    isTouchEnabled  = true;

    aim             = cpv(-1, -1);
    buildings       = [[NSMutableArray alloc] init];
    explosions      = [[NSMutableArray alloc] init];
    
    [self reset];
    
    return self;
}


-(void) onEnter {
    
    [super onEnter];
    
    [self startPanning];
}


-(void) onExit {
    
    [super onExit];
    
    [self stopPanning];
}


-(void) reset {
    
    BOOL wasPanning = panAction != nil;
    [self stopAction:panAction];
    [panAction release];
    panAction = nil;
    
    for(ExplosionLayer *explosion in explosions) {
        [self removeAndStop:explosion];
        [self removeAndStop:[explosion hole]];
    }
    [explosions removeAllObjects];
    for (BuildingLayer *building in buildings)
        [self removeAndStop:building];
    [buildings removeAllObjects];
    
    [self stopAllActions];
    [self setPosition:cpvzero];
    
    for (int i = 0; i < [[GorillasConfig get] buildingAmount] * 2; ++i) {
        float x = i * ([[GorillasConfig get] buildingWidth] + 1)
                - ([[GorillasConfig get] buildingWidth] + 1) * [[GorillasConfig get] buildingAmount] / 2;
        
        BuildingLayer *building = [[BuildingLayer alloc] init];
        [buildings addObject: building];
        
        [building setPosition: cpv(x, 0)];
        [self add:building z:1];

        [building release];
    }
    
    if(wasPanning)
        [self startPanning];
}


-(void) message:(NSString *)msg on:(CocosNode<CocosNodeSize> *)node {
    
    if(msgLabel)
        [msgLabel stopAllActions];

    else {
        msgLabel = [[Label alloc] initWithString:@""
                                      dimensions:CGSizeMake(1000, [[GorillasConfig get] fontSize] + 5)
                                       alignment:UITextAlignmentCenter
                                        fontName:[[GorillasConfig get] fixedFontName]
                                        fontSize:[[GorillasConfig get] fontSize]];
    
        [self add:msgLabel z:9];
    }
    
    [msgLabel setString:msg];
    [msgLabel setPosition:cpv([node position].x,
                              [node position].y + [node contentSize].height)];
    
    // Make sure label remains on screen.
    CGSize winSize = [[Director sharedDirector] winSize];
    if(![[GorillasConfig get] followThrow]) {
        if([msgLabel position].x < [[GorillasConfig get] fontSize] / 2)                 // Left edge
            [msgLabel setPosition:cpv([[GorillasConfig get] fontSize] / 2, [msgLabel position].y)];
        if([msgLabel position].x > winSize.width - [[GorillasConfig get] fontSize] / 2) // Right edge
            [msgLabel setPosition:cpv(winSize.width - [[GorillasConfig get] fontSize] / 2, [msgLabel position].y)];
        if([msgLabel position].y < [[GorillasConfig get] fontSize] / 2)                 // Bottom edge
            [msgLabel setPosition:cpv([msgLabel position].x, [[GorillasConfig get] fontSize] / 2)];
        if([msgLabel position].y > winSize.width - [[GorillasConfig get] fontSize] * 2) // Top edge
            [msgLabel setPosition:cpv([msgLabel position].x, winSize.height - [[GorillasConfig get] fontSize] * 2)];
    }
    
    // Color depending on whether message starts with -, + or neither.
    if([msg hasPrefix:@"+"])
        [msgLabel setRGB:0x66 :0xCC :0x66];
    else if([msg hasPrefix:@"-"])
        [msgLabel setRGB:0xCC :0x66 :0x66];
    else
        [msgLabel setRGB:0xFF :0xFF :0xFF];
    
    // Animate the label to fade out.
    [msgLabel do:[Spawn actions:
                  [FadeOut actionWithDuration:3],
                  [Sequence actions:
                   [DelayTime actionWithDuration:1],
                   [MoveBy actionWithDuration:2 position:cpv(0, [[GorillasConfig get] fontSize] * 2)],
                   nil],
                  nil]];
}


-(void) draw {

#ifdef _DEBUG_
    BuildingLayer *fb = [buildings objectAtIndex:0], *lb = [buildings lastObject];
    int pCount = (([lb position].x - [fb position].x) / dbgTraceStep + 1)
                * ([[Director sharedDirector] winSize].size.height / dbgTraceStep + 1);
    cpVect *hgp = malloc(sizeof(cpVect) * pCount);
    cpVect *hep = malloc(sizeof(cpVect) * pCount);
    int hgc = 0, hec = 0;
    
    for(float x = [fb position].x; x < [lb position].x; x += dbgTraceStep)
        for(float y = 0; y < [[Director sharedDirector] winSize].size.height; y += dbgTraceStep) {
            cpVect pos = cpv(x, y);

            BOOL hg = false, he = false;
            for(ExplosionLayer *explosion in explosions)
                if((he = [explosion hitsExplosion:pos]))
                    break;

            for(GorillaLayer *gorilla in gorillas)
                if((hg = [gorilla hitsGorilla:pos]))
                    break;
            
            if(hg)
                hgp[hgc++] = pos;
            else if(he)
                hep[hec++] = pos;
        }
    
    drawPointsAt(hgp, hgc, 0x00FF00FF);
    drawPointsAt(hep, hec, 0xFF0000FF);
    drawPointsAt(dbgPath, dbgPathMaxInd, 0xFFFF00FF);
    free(hgp);
    free(hep);
#endif

    if([[GorillasConfig get] training]) {
        for(NSUInteger i = 0; i < [[GorillasAppDelegate get].gameLayer.gorillas count]; ++i) {
            if([[GorillasConfig get] throwHistory]) {
                cpVect from = [(GorillaLayer *) [[GorillasAppDelegate get].gameLayer.gorillas objectAtIndex:i] position];
                cpVect to   = cpvadd(from, throwHistory[i]);
                
                drawLinesTo(from, &to, 1, [[GorillasConfig get] windowColorOff] & 0xffffff33, 3);
            }
        }
    }
    
    if([GorillasAppDelegate get].gameLayer.activeGorilla && aim.x > 0) {
        // Only draw aim when aiming and gorillas are set.

        const cpVect points[] = {
            [[GorillasAppDelegate get].gameLayer.activeGorilla position],
            aim,
        };
        const long colors[] = {
            [[GorillasConfig get] windowColorOff]   & 0xffffff00,
            [[GorillasConfig get] windowColorOn]    | 0x000000ff,
        };
        
        drawLines(points, colors, 2, 3);
    }
}


-(BOOL) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if([[event allTouches] count] != 1)
        return [self ccTouchesCancelled:touches withEvent:event];
    
    if(![self mayThrow])
        // State doesn't allow throwing right now.
        return kEventIgnored;
    
    UITouch *touch = [[event allTouches] anyObject];
	CGPoint location = [touch locationInView: [touch view]];
    CGSize winSize = [[Director sharedDirector] winSize];
    cpVect halfWin = cpv(winSize.width / 2, winSize.height / 2);
    cpVect p = cpv(location.y, location.x);
    cpFloat rot = (cpFloat)DEGREES_TO_RADIANS([[[GorillasAppDelegate get] gameLayer] rotation]);
    p = cpvadd(cpvrotate(cpvsub(p, halfWin), cpv(cosf(rot), sinf(rot))), halfWin);
    for(CocosNode *n = self; n; n = [n parent])
        p = cpvmult(p, 1 / [n scale]);
    
    if([[[GorillasAppDelegate get] hudLayer] hitsHud:p])
        // Ignore when moving/clicking over/on HUD.
        return kEventIgnored;
    
    if(aim.x != -1 || aim.y != -1)
        // Has already began.
        return kEventIgnored;
        
    aim = cpvsub(p, [self position]);
    return kEventHandled;
}


-(BOOL) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if([[event allTouches] count] != 1)
        return [self ccTouchesCancelled:touches withEvent:event];
    
    if(aim.x == -1 && aim.y == -1)
        // Hasn't yet began.
        return kEventIgnored;
    
    UITouch *touch = [[event allTouches] anyObject];
	CGPoint location = [touch locationInView: [touch view]];
    CGSize winSize = [[Director sharedDirector] winSize];
    cpVect halfWin = cpv(winSize.width / 2, winSize.height / 2);
    cpVect p = cpv(location.y, location.x);
    cpFloat rot = (cpFloat)DEGREES_TO_RADIANS([[[GorillasAppDelegate get] gameLayer] rotation]);
    p = cpvadd(cpvrotate(cpvsub(p, halfWin), cpv(cosf(rot), sinf(rot))), halfWin);
    for(CocosNode *n = self; n; n = [n parent])
        p = cpvmult(p, 1 / [n scale]);
    
    if([[[GorillasAppDelegate get] hudLayer] hitsHud:p])
        // Ignore when moving/clicking over/on HUD.
        return kEventIgnored;
        
    aim = cpvsub(p, [self position]);
    return kEventHandled;
}


-(BOOL) ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(aim.x == -1 && aim.y == -1)
        return kEventIgnored;
    
    aim = cpv(-1, -1);
    return kEventHandled;
}


-(BOOL) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    if([[event allTouches] count] != 1)
        return [self ccTouchesCancelled:touches withEvent:event];
    
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint location = [touch locationInView: [touch view]];
    CGSize winSize = [[Director sharedDirector] winSize];
    cpVect halfWin = cpv(winSize.width / 2, winSize.height / 2);
    cpVect p = cpv(location.y, location.x);
    cpFloat rot = (cpFloat)DEGREES_TO_RADIANS([[[GorillasAppDelegate get] gameLayer] rotation]);
    p = cpvadd(cpvrotate(cpvsub(p, halfWin), cpv(cosf(rot), sinf(rot))), halfWin);
    for(CocosNode *n = self; n; n = [n parent])
        p = cpvmult(p, 1 / [n scale]);
    
    if([[[GorillasAppDelegate get] hudLayer] hitsHud:p]
        || aim.x <= 0
        || ![self mayThrow])
        // Cancel when: released over HUD, no aim vector, state doesn't allow throwing.
        return [self ccTouchesCancelled:touches withEvent:event];
    
    cpVect r0 = [[GorillasAppDelegate get].gameLayer.activeGorilla position];
    cpVect v = cpvsub(aim, r0);
    
    aim = cpv(-1.0f, -1.0f);
    [self throwFrom:[GorillasAppDelegate get].gameLayer.activeGorilla withVelocity:v];
    
    return kEventHandled;
}
    

-(BOOL) mayThrow {

    return ![bananaLayer throwing] && [[GorillasAppDelegate get].gameLayer.activeGorilla alive] && [[GorillasAppDelegate get].gameLayer.activeGorilla human]
            && ![GorillasAppDelegate get].gameLayer.paused;
}


-(void) nextGorilla {
    
    if(![[[GorillasAppDelegate get] gameLayer] running])
        [[[GorillasAppDelegate get] gameLayer] stopGame];
    
    // Active gorilla's turn is over.
    ++[GorillasAppDelegate get].gameLayer.activeGorilla.turns;
    
    // Activate the next gorilla.
    // Look for the next live gorilla; first try the next gorilla AFTER the current.
    // If none there is alive, try the first one from the beginning UNTIL the current.
    BOOL foundNextGorilla = false;
    for(BOOL startFromAfterCurrent = true; true; startFromAfterCurrent = false) {
        BOOL reachedCurrent = false;
        
        for(GorillaLayer *gorilla in [GorillasAppDelegate get].gameLayer.gorillas) {
        
            if(gorilla == [GorillasAppDelegate get].gameLayer.activeGorilla)
                reachedCurrent = true;
            
            else
                if(startFromAfterCurrent) {
                    
                    // First run.
                    if(reachedCurrent && [gorilla alive]) {
                        [GorillasAppDelegate get].gameLayer.activeGorilla = gorilla;
                        foundNextGorilla = true;
                        break;
                    }
                } else {
                    
                    // Second run.
                    if(reachedCurrent)
                        // (don't bother looking past the current in the second try)
                        break;
                    
                    else if([gorilla alive]) {
                        [GorillasAppDelegate get].gameLayer.activeGorilla = gorilla;
                        foundNextGorilla = true;
                        break;
                    }
                }
        }
        
        if(foundNextGorilla)
            break;
        
        if(!startFromAfterCurrent) {
            // Second run didn't find any gorillas -> no gorillas available.
            [[[GorillasAppDelegate get] gameLayer] stopGame];
            return;
        }
    }

    if([GorillasAppDelegate get].gameLayer.activeGorilla.alive && ![GorillasAppDelegate get].gameLayer.activeGorilla.human) {
        // Active gorilla is a live AI.
        NSMutableArray *enemies = [[GorillasAppDelegate get].gameLayer.gorillas mutableCopy];
        [enemies removeObject:[GorillasAppDelegate get].gameLayer.activeGorilla];
        
        GorillaLayer *target = [[enemies objectAtIndex:random() % [enemies count]] retain];
        [enemies release];
        
        cpVect r0 = [GorillasAppDelegate get].gameLayer.activeGorilla.position;
        cpVect v = [self calculateThrowFrom:r0
                                         to:[target position]
                                 errorLevel:[[GorillasConfig get] level]];
        [target release];

        [self throwFrom:[GorillasAppDelegate get].gameLayer.activeGorilla withVelocity:v];
        
#ifdef _DEBUG_
        dbgAI[dbgAICurInd] = activeGorilla;
        dbgAIVect[dbgAICurInd] = v;
        dbgAICurInd = (dbgAICurInd + 1) % dbgAIMaxInd;
#endif
    }
    
    // Throw hints.
    for(NSUInteger i = 0; i < [[GorillasAppDelegate get].gameLayer.gorillas count]; ++i) {
        GorillaLayer *gorilla = [[GorillasAppDelegate get].gameLayer.gorillas objectAtIndex:i];

        BOOL hintGorilla = [[GorillasConfig get] training] && [[GorillasConfig get] throwHint]
                        && [GorillasAppDelegate get].gameLayer.activeGorilla.human
                        && gorilla != [GorillasAppDelegate get].gameLayer.activeGorilla && [gorilla alive];
        Sprite *hint = [throwHints objectAtIndex:i];
        [hint setVisible:hintGorilla];
        [hint stopAllActions];
        
        if(hintGorilla) {
            cpVect v = [self calculateThrowFrom:[[GorillasAppDelegate get].gameLayer.activeGorilla position]
                                             to:[gorilla position] errorLevel:0.9f];

            [hint setOpacity:0];
            [hint setPosition:cpvadd([GorillasAppDelegate get].gameLayer.activeGorilla.position, v)];
            [hint do:[RepeatForever actionWithAction:[Sequence actions:
                                                      [DelayTime actionWithDuration:10],
                                                      [FadeTo actionWithDuration:2 opacity:0x55],
                                                      [FadeTo actionWithDuration:2 opacity:0x00],
                                                      nil]]];
        }
    }
}


-(void) throwFrom:(GorillaLayer *)gorilla withVelocity:(cpVect)v {
    
    // Hide all hints.
    for(Sprite *hint in throwHints)
        if([hint visible]) {
            [hint stopAllActions];
            [hint do:[FadeTo actionWithDuration:[[GorillasConfig get] transitionDuration] opacity:0x00]];
        }
    
    // Record throw history & start the actual throw.
    throwHistory[[[GorillasAppDelegate get].gameLayer.gorillas indexOfObject:gorilla]] = v;
    [bananaLayer throwFrom:[gorilla position] withVelocity:v];
}


-(cpVect) calculateThrowFrom:(cpVect)r0 to:(cpVect)rt errorLevel:(cpFloat)l {
    
    float g = [[GorillasConfig get] gravity];
    float w = [[[[GorillasAppDelegate get] gameLayer] windLayer] wind];
    ccTime t = 5 * 100 / g;
    
    // Level-based error.
    rt = cpv(rt.x + random() % (int) ((1 - l) * 200), rt.y + random() % (int) (200 * (1 - l)));
    t = (random() % (int) ((t / 2) * l * 10)) / 10.0f + (t / 2);
    
    // Velocity vector to hit rt in t seconds.
    cpVect v = cpv((rt.x - r0.x) / t,
                   (g * t * t - 2 * r0.y + 2 * rt.y) / (2 * t));
    
    // Wind-based modifier.
    v.x -= w * t * [[GorillasConfig get] windModifier];
    
    return v;
}


-(void) miss {
    
    if(!([GorillasAppDelegate get].gameLayer.singlePlayer && [GorillasAppDelegate get].gameLayer.activeGorilla.human && ![[GorillasConfig get] training]))
        // Only deduct points when single player game & throw was by human & not in training mode.
        return;
    
    int nScore = [[GorillasConfig get] level] * [[GorillasConfig get] missScore];
    
    [[GorillasConfig get] setScore:[[GorillasConfig get] score] + nScore];
    [[[GorillasAppDelegate get] hudLayer] updateScore:nScore skill:0];

    if(nScore)
        [self message:[NSString stringWithFormat:@"%+d", nScore] on:[bananaLayer banana]];
}


-(BOOL) hitsGorilla: (cpVect)pos  throwSkill:(float)throwSkill {

#ifdef _DEBUG_
    dbgPath[dbgPathCurInd] = pos;
    dbgPathCurInd = (dbgPathCurInd + 1) % dbgPathMaxInd;
#endif

    GameLayer *gameLayer = [[GorillasAppDelegate get] gameLayer];
    
    // Figure out if a gorilla was hit.
    for(GorillaLayer *gorilla in [GorillasAppDelegate get].gameLayer.gorillas)
        if([gorilla hitsGorilla:pos]) {

            if(gorilla == [GorillasAppDelegate get].gameLayer.activeGorilla && ![bananaLayer clearedGorilla])
                // Disregard this hit on active gorilla because the banana didn't clear him yet.
                continue;
            
            // A gorilla was hit.
            hitGorilla = [gorilla retain];
            [hitGorilla setAlive:false];
            
            // Check whether any gorillas are left.
            int liveGorillaCount = 0;
            GorillaLayer *liveGorilla;
            for(GorillaLayer *gorillaState in [GorillasAppDelegate get].gameLayer.gorillas)
                if([gorillaState alive]) {
                    liveGorillaCount++;
                    liveGorilla = gorillaState;
                }
            
            // If 0 or 1 gorillas left; show who won and stop the game.
            if(liveGorillaCount < 2) {
                if(liveGorillaCount == 1) {
                    [[[GorillasAppDelegate get] hudLayer] setInfoString:[NSString stringWithFormat:@"%@ wins!", [liveGorilla name]]];
                    
                    if([gameLayer singlePlayer] && ! [[GorillasConfig get] training]) {
                        // One gorilla left in single player: modify the level depending on who survived.
                        
                        NSString *oldLevel = [[GorillasConfig get] levelName];
                        if([liveGorilla human]) {
                            
                            // Modify difficulty level & update score.
                            int nScore = [[GorillasConfig get] killScore];
                            
                            // Skill modifier.
                            if([GorillasAppDelegate get].gameLayer.activeGorilla.turns == 0) {
                                [gameLayer message:@"Oneshot!"];
                                nScore *= [[GorillasConfig get] bonusOneShot];
                            }
                            
                            // Oneshot bonus modifier.
                            if([GorillasAppDelegate get].gameLayer.activeGorilla.turns == 0) {
                                [gameLayer message:@"Oneshot!"];
                                nScore *= [[GorillasConfig get] bonusOneShot];
                            }
                            
                            // Level modifier.
                            nScore *= [[GorillasConfig get] level];
                            
                            [[GorillasConfig get] setSkill:fminf(0.99f, [[GorillasConfig get] skill] + throwSkill)];
                            [[GorillasConfig get] setScore:[[GorillasConfig get] score] + nScore];
                            [[[GorillasAppDelegate get] hudLayer] updateScore: nScore skill:0];
                            if(nScore)
                                [self message:[NSString stringWithFormat:@"%+d", nScore] on:hitGorilla];
                            [[GorillasConfig get] levelUp];

                            // Message in case we level up.
                            if(oldLevel != [[GorillasConfig get] levelName])
                                [gameLayer message:@"Level Up!"];
                        }
                        
                        else {
                            // Decrease difficulty level & update score.
                            int nScore = [[GorillasConfig get] level] * [[GorillasConfig get] deathScore];
                            
                            [[GorillasConfig get] setScore:[[GorillasConfig get] score] + nScore];
                            [[[GorillasAppDelegate get] hudLayer] updateScore: nScore skill:0];
                            if(nScore)
                                [self message:[NSString stringWithFormat:@"%+d", nScore] on:hitGorilla];
                            [[GorillasConfig get] levelDown];
                            
                            // Message in case we level down.
                            if(oldLevel != [[GorillasConfig get] levelName])
                                [gameLayer message:@"Level Down"];
                        }
                        
                        [[[GorillasAppDelegate get] gameLayer] setRunning:NO];
                    }
                } else
                    [[[GorillasAppDelegate get] hudLayer] setInfoString:@"Tie!"];
            }
            
            // Fade out the killed gorilla.
            [hitGorilla do:[Sequence actions:
                            [FadeOut actionWithDuration:1],
                            [CallFunc actionWithTarget:self selector:@selector(hitGorillaCallback:)],
                            nil]];

            return true;
        }
        
        else if(gorilla == [GorillasAppDelegate get].gameLayer.activeGorilla)
            // Active gorilla was not hit -> banana cleared him.
            [bananaLayer setClearedGorilla:true];
    
    // No hit.
    return false;
}


-(BOOL) hitsBuilding:(cpVect)pos {
    
    // Figure out if a building was hit.
    for(BuildingLayer *building in buildings)
        if( pos.x >= [building position].x &&
            pos.y >= [building position].y &&
            pos.x <= [building position].x + [building contentSize].width &&
            pos.y <= [building position].y + [building contentSize].height) {

            // A building was hit, but if it's in an explosion crater we
            // need to let the banana continue flying.
            BOOL hitsExplosion = false;
            
            for(ExplosionLayer *explosion in explosions)
                if([explosion hitsExplosion: pos])
                    hitsExplosion = true;
            
            if(!hitsExplosion)
                // Hit was not in an explosion.
                return true;
        }
    
    // No hit.
    return false;
}


-(void) hitGorillaCallback: (id) sender {

    [self removeGorilla:hitGorilla];
}


-(void) startGame {
    
    [self stopPanning];
    
    // Create enough throw hint sprites / remove needless ones.
    while([throwHints count] != [[GorillasAppDelegate get].gameLayer.gorillas count]) {
        if([throwHints count] < [[GorillasAppDelegate get].gameLayer.gorillas count]) {
            Sprite *hint = [Sprite spriteWithFile:@"fire.png"];
            [throwHints addObject:hint];
            [self add:hint];
        }
        
        else
            [throwHints removeLastObject];
    }

    // Reset throw history & throw hints.
    free(throwHistory);
    throwHistory = malloc(sizeof(cpVect) * [[GorillasAppDelegate get].gameLayer.gorillas count]);
    for(NSUInteger i = 0; i < [[GorillasAppDelegate get].gameLayer.gorillas count]; ++i) {
        throwHistory[i] = cpv(-1, -1);
        [[throwHints objectAtIndex:i] setVisible:NO];
    }
    
    // Position our gorillas.
    int indexA = 0;
    for(BuildingLayer *building in buildings)
        if(position.x + [building position].x >= 0) {
            indexA = [buildings indexOfObject:building] + 1;
            break;
        }
    int indexB = indexA + [[GorillasConfig get] buildingAmount] - 3;
    
    GorillaLayer *gorillaA = [[GorillasAppDelegate get].gameLayer.gorillas objectAtIndex:0];
    GorillaLayer *gorillaB = [[GorillasAppDelegate get].gameLayer.gorillas objectAtIndex:1];
    
    BuildingLayer *buildingA = (BuildingLayer *) [buildings objectAtIndex:indexA];
    [gorillaA setPosition:cpv([buildingA position].x + [buildingA contentSize].width / 2, [buildingA contentSize].height + [gorillaA contentSize].height / 2)];
    
    BuildingLayer *buildingB = (BuildingLayer *) [buildings objectAtIndex:indexB];
    [gorillaB setPosition:cpv([buildingB position].x + [buildingB contentSize].width / 2, [buildingB contentSize].height + [gorillaB contentSize].height / 2)];
    
    [gorillaA do:[FadeIn actionWithDuration:1]];
    [gorillaB do:[FadeIn actionWithDuration:1]];
    [self add:gorillaA z:3];
    [self add:gorillaB z:3];
    
    // Add a banana to the scene.
    if(bananaLayer) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Tried to start a game while a(n old?) banana still existed."
                                     userInfo:nil];
    }
    bananaLayer = [[BananaLayer alloc] init];
    [self add:bananaLayer z:2];
    
    [self do:[Sequence actions:
              /*[DelayTime actionWithDuration:1],*/
              [CallFunc actionWithTarget:self selector:@selector(startedCallback:)],
              nil]];
    
    [self nextGorilla];
}


-(void) startedCallback: (id) sender {
 
    [[[GorillasAppDelegate get] gameLayer] started];
}


-(void) stopGame {
    
    [hitGorilla release];
    hitGorilla = nil;
    
    for(GorillaLayer *gorilla in [GorillasAppDelegate get].gameLayer.gorillas) {
        [gorilla setAlive:false];
        [gorilla do:[FadeOut actionWithDuration:1]];
    }
    
    if(bananaLayer) {
        [self removeAndStop:bananaLayer];
        [bananaLayer release];
        bananaLayer = nil;
    }
    
    [self do:[Sequence actions:
              [DelayTime actionWithDuration:1],
              [CallFunc actionWithTarget:self selector:@selector(stopGameCallback:)],
              nil]];
}

-(void) stopGameCallback:(id)sender {
    
    for(GorillaLayer *gorilla in [GorillasAppDelegate get].gameLayer.gorillas)
        [self removeAndStop:gorilla];
    [[GorillasAppDelegate get].gameLayer.gorillas removeAllObjects];
    
    [self startPanning];
    
    [[GorillasAppDelegate get].gameLayer stopped];
}


-(void) removeGorilla: (GorillaLayer *)gorilla {

    [self removeAndStop:gorilla];
    [[GorillasAppDelegate get].gameLayer.gorillas removeObject:gorilla];
}
 

-(void) startPanning {
    
    if(panAction)
        // If already panning, stop first.
        [self stopPanning];
    
    panAction = [[PanAction alloc] initWithSubNodes:buildings duration:[[GorillasConfig get] buildingSpeed] padding:1];
    [self do: panAction];
}


-(void) stopPanning {
    
    [panAction cancel];
    [panAction release];
    panAction = nil;
}


-(void) explodeAt: (cpVect)point isGorilla:(BOOL)isGorilla {
    
    ExplosionLayer *explosion = [[ExplosionLayer alloc] initHitsGorilla:isGorilla];
    [explosions addObject:explosion];

    [explosion setPosition:point];
    [self add:explosion z:3];
    [self add:[explosion hole] z:-1];
    [explosion release];
}


-(cpFloat) left {
    
    BuildingLayer *firstBuilding = [buildings objectAtIndex:1];
    return [firstBuilding position].x;
}


-(cpFloat) right {
    
    BuildingLayer *lastBuilding = [buildings lastObject];
    return [lastBuilding position].x + [lastBuilding contentSize].width;
}


-(void) dealloc {
    
    [panAction release];
    panAction = nil;
    
    [msgLabel release];
    msgLabel = nil;
    
    [buildings release];
    buildings = nil;
    
    [explosions release];
    explosions = nil;
    
    [bananaLayer release];
    bananaLayer = nil;
    
    [hitGorilla release];
    hitGorilla = nil;
    
    [throwHints release];
    throwHints = nil;
    
    free(throwHistory);
    throwHistory = nil;
    
#ifdef _DEBUG_
    free(dbgPath);
    free(dbgAI);
    free(dbgAIVect);
#endif
    
    [super dealloc];
}


@end
