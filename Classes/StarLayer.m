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
//  SkyLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "StarLayer.h"
#import "GorillasAppDelegate.h"
#define maxStarSize 2


@implementation StarLayer


-(id) initWidthDepth:(float)aDepth {
    
	if (!(self = [super init]))
        return self;
    
    starVertexBuffer    = 0;
    starCount           = -1;
    depth               = aDepth;
    
    return self;
}


- (void)onEnter {
    
    [self reset];
    
    [self schedule:@selector(update:)];

    [super onEnter];
}


-(void) reset {
    
    if (starCount == [GorillasConfig get].starAmount)
        return;

    CGRect field        = [[GorillasAppDelegate get].gameLayer.cityLayer fieldInSpaceOf:self];
    starCount           = [GorillasConfig get].starAmount;
    ccColor4B starColor = ccc([GorillasConfig get].starColor);
    starColor.r         *= depth;
    starColor.g         *= depth;
    starColor.b         *= depth;
    CGFloat starSize    = fmaxf(1.0f, maxStarSize * depth);
    
    free(starVertices);
    starVertices = malloc(sizeof(glPoint) * starCount);
    
    for (NSUInteger s = 0; s < starCount; ++s) {
        starVertices[s].p   = ccp(random() % (long) field.size.width + field.origin.x,
                                  random() % (long) field.size.height + field.origin.y);
        starVertices[s].c   = starColor;
        starVertices[s].s   = starSize;
    }
    
    // Push our window data into the VBO.
    glDeleteBuffers(1, &starVertexBuffer);
    glGenBuffers(1, &starVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, starVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(glPoint) * starCount, starVertices, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}


-(void) update:(ccTime)dt {

    CGRect field        = [[GorillasAppDelegate get].gameLayer.cityLayer fieldInSpaceOf:self];
    NSInteger speed     = [GorillasConfig get].starSpeed;
    
    for (NSUInteger s = 0; s < starCount; ++s)
        if (starVertices[s].p.x < field.origin.x)
            starVertices[s].p.x = field.size.width + field.origin.x
                                - ((int)(10000 * speed * dt) % random()) / 10000.0f;
        else
            starVertices[s].p.x -= dt * speed;

    glBindBuffer(GL_ARRAY_BUFFER, starVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(glPoint) * starCount, starVertices, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}


-(void) draw {

    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_POINT_SIZE_ARRAY_OES);
    
    // Stars.
    glBindBuffer(GL_ARRAY_BUFFER, starVertexBuffer);
    glVertexPointer(2, GL_FLOAT, sizeof(glPoint), 0);
    glPointSizePointerOES(GL_FLOAT, sizeof(glPoint), (GLvoid *) sizeof(CGPoint));
    glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(glPoint), (GLvoid *) (sizeof(CGPoint) + sizeof(GLfloat)));
    
    glDrawArrays(GL_POINTS, 0, starCount);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glDisableClientState(GL_POINT_SIZE_ARRAY_OES);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
}


-(void) dealloc {

    glDeleteBuffers(1, &starVertexBuffer);
    starVertexBuffer = 0;
    
    free(starVertices);
    starVertices = nil;

    [super dealloc];
}


@end
