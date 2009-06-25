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
//  WindLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 25/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "Resettable.h"


@interface WindLayer : Layer <CocosNodeOpacity, Resettable> {

    long            color;
    float           wind, bar;
    float           windIncrement;
    ccTime          elapsed, incrementDuration;
    
    NSMutableArray  *systems, *affectAngles;
    Sprite          *head, *body, *tail;
}

-(void) registerSystem:(ParticleSystem *)system affectAngle:(BOOL)affectAngle;
-(void) unregisterSystem:(ParticleSystem *)system;

@property (nonatomic, readonly) float wind;
@property (nonatomic, readwrite) long color;
@property (nonatomic, readwrite) GLubyte opacity;

@end
