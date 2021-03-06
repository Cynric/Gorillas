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
//  ExplosionsLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 04/11/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "ExplosionsLayer.h"
#import "GorillasAppDelegate.h"
#define flameVariantion 10

typedef enum {
    GorillasExplosionHitGorilla  = 2 << 0,
    GorillasExplosionHeavy       = 2 << 1,
} GorillasExplosion;


@interface ExplosionsLayer ()

- (void)gc:(ccTime)dt;
- (void)stop:(CCParticleSystem *)explosion;
- (CGFloat)size;
- (CCParticleSystem *)flameWithRadius:(CGFloat)radius heavy:(BOOL)heavy;

@end

static CCParticleSystem **flameTypes = nil;
static float flameRadius;

@implementation ExplosionsLayer

-(id) init {

    if(!(self = [super init]))
        return self;

    explosions      = [[NSMutableArray alloc] initWithCapacity:10];
    flames          = [[NSMutableArray alloc] initWithCapacity:10];
    positions       = nil;
    
    self.scale      = GorillasModelScale(1, [[CCTextureCache sharedTextureCache] addImage:@"hole.pvr"].pixelsWide);
    
    [self schedule:@selector(gc:) interval:0.5f];
    [self schedule:@selector(step:)];

    return self;
}


-(void) gc:(ccTime)dt {

    BOOL stuffToClean;
    do {
        stuffToClean = NO;
        
        if(explosions.count) {
            CCParticleSystem *explosion = [explosions objectAtIndex:0];
            
            if(!explosion.particleCount && !explosion.active) {
                [explosions removeObjectAtIndex:0];
                [self removeChild:explosion cleanup:YES];
                stuffToClean = YES;
            }
        }
    } while(stuffToClean);
}


-(void) step:(ccTime)dt {
    
    //for(CCNode *node = self; node; node = node.parent)
    //    dt *= node.timeScale;

    if(flameTypes) {
        for (NSUInteger type = 0; type < flameVariantion * 2; ++type)
            [(id)flameTypes[type] update:dt];
    }
}


-(CGFloat) size {
    
    return 32 * self.scale;
}


-(void) addExplosionAtWorld:(CGPoint)worldPos hitsGorilla:(BOOL) hitsGorilla {
    
    BOOL heavy = hitsGorilla || (gameRandomFor(GorillasGameRandomExplosions) % 100 > 90);

    if([[GorillasConfig get].soundFx boolValue])
        [GorillasAudioController playEffect:[ExplosionsLayer explosionEffect:heavy]];

    [[GorillasAppDelegate get].gameLayer shake];
    
    int explosionParticles = gameRandomFor(GorillasGameRandomExplosions) % 50 + 300;
    if(heavy)
        explosionParticles += 400;
    
    CCParticleSystem *explosion = [[CCParticleSun alloc] initWithTotalParticles:explosionParticles];
    [[GorillasAppDelegate get].gameLayer.windLayer registerSystem:explosion affectAngle:NO];
    
    explosion.positionType      = kCCPositionTypeGrouped;
    explosion.position          = CGPointZero;
    explosion.sourcePosition    = [self convertToNodeSpace:worldPos];
    explosion.startSize         = (heavy? 20: 15) * self.scale;
    explosion.startSizeVar      = 5 * self.scale;
    explosion.speed             = 10;
    explosion.posVar            = ccp([self size] * 0.2f,
                                      [self size] * 0.2f);
    explosion.tag               = (hitsGorilla? GorillasExplosionHitGorilla  : 0) |
                                  (heavy?       GorillasExplosionHeavy       : 0);
    [explosion runAction:[CCSequence actions:
                          [CCDelayTime actionWithDuration:heavy? 0.6f: 0.2f],
                          [CCCallFuncN actionWithTarget:self selector:@selector(stop:)],
                          nil]];
    
    [self addChild:explosion z:1];
    [explosions addObject:explosion];
    [explosion release];
}


-(void) draw {

    if(positions) {
        NSUInteger f = 0;
        CGPoint prevFlamePos = CGPointZero;
        for(CCParticleSystem *flame in flames) {
            CGPoint translate = ccpSub(positions[f], prevFlamePos);
            prevFlamePos = positions[f];
            
            glTranslatef(translate.x, translate.y, 0);
            [flame draw];
            
            ++f;
        }
        glTranslatef(-prevFlamePos.x, -prevFlamePos.y, 0);
    }
    
    [super draw];
}


-(void) onExit {
    
    [super onExit];
    
    for (CCParticleSystem *explosion in explosions) {
        [[GorillasAppDelegate get].gameLayer.windLayer unregisterSystem:explosion];
        [self removeChild:explosion cleanup:YES];
    }
    [explosions removeAllObjects];
    
    for (CCParticleSystem *flame in flames) {
        [[GorillasAppDelegate get].gameLayer.windLayer unregisterSystem:flame];
        [self removeChild:flame cleanup:YES];
    }
    [flames removeAllObjects];
}


-(void) stop:(CCParticleSystem *)explosion {
    
    BOOL hitsGorilla    = [explosion tag] & GorillasExplosionHitGorilla;
    BOOL heavy          = [explosion tag] & GorillasExplosionHeavy;
    
    if(!hitsGorilla && [GorillasConfig get].visualFx) {
        CCParticleSystem *flame = [self flameWithRadius:[self size] / 2 heavy:heavy];

        positions = realloc(positions, sizeof(CGPoint) * (flames.count + 1));
        positions[flames.count] = explosion.sourcePosition;
        [flames addObject:flame];
    }
    
    [explosion stopSystem];
}


-(CCParticleSystem *) flameWithRadius:(CGFloat)radius heavy:(BOOL)heavy {
    
    if (flameTypes && flameRadius != radius) {
        [flames removeAllObjects];
        for (NSUInteger type = 0; type < flameVariantion * 2; ++type) {
            [[GorillasAppDelegate get].gameLayer.windLayer unregisterSystem:flameTypes[type]];
            [flameTypes[type] release];
        }
        free(flameTypes);
        flameTypes = nil;
    }
    
    if(!flameTypes) {
        flameTypes  = malloc(sizeof(CCParticleSystem *) * 2 * flameVariantion);
        flameRadius = radius;
        
        for (NSUInteger type = 0; type < flameVariantion * 2; ++type) {
            BOOL typeIsHeavy = !(type < flameVariantion);
            int flameParticles = typeIsHeavy? 80: 60;
            
            CCParticleSystem *flame   = [[CCParticleFire alloc] initWithTotalParticles:flameParticles];
            
            flame.position          = CGPointZero;
            //flames.angleVar       = 90;
            flame.startSize         = typeIsHeavy? 10: 4;
            flame.startSizeVar      = 4;
            flame.posVar            = ccp(radius / 2, radius / 2);
            flame.speed             = 8;
            flame.speedVar          = 10;
            flame.life              = typeIsHeavy? 2: 1;
            ccColor4F startColor     = { 0.9f, 0.5f, 0.0f, 1.0f };
            flame.startColor        = startColor;
            ccColor4F startColorVar  = { 0.1f, 0.2f, 0.0f, 0.1f };
            flame.startColorVar     = startColorVar;
            flame.emissionRate     *= 1.5f;
            
            [[GorillasAppDelegate get].gameLayer.windLayer registerSystem:flame affectAngle:NO];
            flameTypes[type]        = flame;
        }
    }
    
    NSUInteger t = (gameRandomFor(GorillasGameRandomExplosions) % flameVariantion) + (heavy? 1: 0) * flameVariantion;
    dbg(@"flame: %d", t);
    return flameTypes[t];
}


+(SystemSoundID) explosionEffect: (BOOL)heavy {
    
    static NSUInteger lastEffect = -1;
    static NSUInteger explosionEffects = 0;
    static SystemSoundID* explosionEffect = nil;
    
    if(explosionEffect == nil) {
        explosionEffects = 4;
        explosionEffect = malloc(sizeof(SystemSoundID) * explosionEffects);
        
        for(NSUInteger i = 0; i < explosionEffects; ++i)
            explosionEffect[i] = [GorillasAudioController loadEffectWithName:[NSString stringWithFormat:@"explosion%d.caf", i]];
    }

    // Pick a random effect.
    NSUInteger chosenEffect;
    if(heavy) 
        // Effect 0 is reserved for heavy explosions.
        chosenEffect = 0;
    
    else
        // Pick an effect that is not 0 (see above) and not the same as the last effect.
        do {
            chosenEffect = gameRandomFor(GorillasGameRandomExplosions) % explosionEffects;
        } while(chosenEffect == lastEffect || chosenEffect == 0);
    
    lastEffect = chosenEffect;
    return explosionEffect[chosenEffect];
}


-(void) dealloc {
    
    [explosions release];
    explosions = nil;
    
    [flames release];
    flames = nil;
    
    [super dealloc];
}


@end
