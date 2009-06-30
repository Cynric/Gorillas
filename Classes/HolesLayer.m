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
//  HolesLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 04/01/09.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "HolesLayer.h"


@implementation HolesLayer


-(id) init {
    
    if(!(self = [super init]))
        return self;
    
	texture     = [[[TextureMgr sharedTextureMgr] addImage: @"hole.pvr"] retain];
    holes       = nil;
    holeCount   = 0;
    
    glGenBuffers(1, &holeVertexBuffer);
    
    return self;
}


-(BOOL) hitsHole: (CGPoint)pos {
    
    for(NSUInteger h = 0; h < holeCount; ++h)
        if(((holes[h].p.x - pos.x) * (holes[h].p.x - pos.x) +
            (holes[h].p.y - pos.y) * (holes[h].p.y - pos.y) ) < powf(texture.pixelsWide, 2) / 9)
            return YES;
    
    return NO;
}


-(void) addHoleAt:(CGPoint)pos {
    
    holes = realloc(holes, sizeof(glPoint) * ++holeCount);
    holes[holeCount - 1].p = pos;
    holes[holeCount - 1].c = ccc(0xffffffff);
    holes[holeCount - 1].s = texture.pixelsWide;
    
	glBindBuffer(GL_ARRAY_BUFFER, holeVertexBuffer);
	glBufferData(GL_ARRAY_BUFFER, sizeof(glPoint) * holeCount, holes, GL_DYNAMIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}


-(void) draw {
    
    // Blend our transarent white with DST.  If SRC, make DST transparent, hide original DST.
    glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_TRUE);
    glBlendFunc(GL_ZERO, GL_SRC_ALPHA);
    
	glEnable(GL_POINT_SPRITE_OES);
	glTexEnvx(GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE);
	
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, texture.name);
	
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_POINT_SIZE_ARRAY_OES);
    
	glBindBuffer(GL_ARRAY_BUFFER, holeVertexBuffer);
    glVertexPointer(2, GL_FLOAT, sizeof(glPoint), 0);
    glPointSizePointerOES(GL_FLOAT, sizeof(glPoint), (GLvoid *) sizeof(CGPoint));
    glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(glPoint), (GLvoid *) (sizeof(CGPoint) + sizeof(GLfloat)));

	glDrawArrays(GL_POINTS, 0, holeCount);
	
	// unbind VBO buffer
	glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    // Reset blend & data source.
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_POINT_SIZE_ARRAY_OES);
    
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_POINT_SPRITE_OES);
}


-(void) dealloc {
    
    glDeleteBuffers(1, &holeVertexBuffer);
    
    [super dealloc];
}


@end
