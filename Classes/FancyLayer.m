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
//  FancyLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 18/12/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "FancyLayer.h"


@implementation FancyLayer

@synthesize opacity, contentSize, outerPadding, padding, innerRatio, color;


- (id)init {
    if(!(self = [super init]))
        return self;
    
    int barHeight   = 0;
    if(![[UIApplication sharedApplication] isStatusBarHidden]) {
        if([[Director sharedDirector] landscape])
            barHeight   = [[UIApplication sharedApplication] statusBarFrame].size.width;
        else
            barHeight   = [[UIApplication sharedApplication] statusBarFrame].size.height;
    }
    
    CGSize winSize  = [[Director sharedDirector] winSize].size;
    contentSize     = CGSizeMake(winSize.width, winSize.height - barHeight);
    outerPadding    = 5.0f;
    padding         = 50.0f;
    color           = 0x000000dd;
    opacity         = color & 0x000000ff;
    innerRatio      = 1.0f / padding;
    
    vertexBuffer    = 0;
    colorBuffer     = 0;
    
    [self update];
    
    return self;
}


-(void) update {
    
    int inner = contentSize.height * innerRatio;
    
    /*
           pos.x + pad                                pos.x + width - pad - inner
           |                                             |
           v                                             v
           2+10--------------------------------------9         <- pos.y + pad
          /                                           \
         /                                             \
        /                                               \
       3                                                 8     <- pos.y + pad + inner
       |                                                 |
       |                        1                        |
       |                                                 |
       4                                                 7     <- pos.y + height - pad - inner
        \                                               /
         \                                             /
          \                                           /
           5-----------------------------------------6         <- pos.y + height - pad
           ^                                             ^
           |                                             |
           pos.x + pad + inner                           pos.x + width - pad
     */
    
    GLfloat *vertices = malloc(sizeof(GLfloat) * 10 * 2);
    vertices[0]     = contentSize.width / 2;                                    // 1
    vertices[1]     = contentSize.height / 2;
    vertices[2]     = position.x + outerPadding + inner;                        // 2
    vertices[3]     = position.y + outerPadding;
    vertices[4]     = position.x + outerPadding;                                // 3
    vertices[5]     = position.y + outerPadding + inner;
    vertices[6]     = position.x + outerPadding;                                // 4
    vertices[7]     = position.y + contentSize.height - outerPadding - inner;
    vertices[8]     = position.x + outerPadding + inner;                        // 5
    vertices[9]     = position.y + contentSize.height - outerPadding;
    vertices[10]    = position.x + contentSize.width - outerPadding - inner;    // 6
    vertices[11]    = position.y + contentSize.height - outerPadding;
    vertices[12]    = position.x + contentSize.width - outerPadding;            // 7
    vertices[13]    = position.y + contentSize.height - outerPadding - inner;
    vertices[14]    = position.x + contentSize.width - outerPadding;            // 8
    vertices[15]    = position.y + outerPadding + inner;
    vertices[16]    = position.x + contentSize.width - outerPadding - inner;    // 9
    vertices[17]    = position.y + outerPadding;
    vertices[18]    = position.x + outerPadding + inner;                        // 10
    vertices[19]    = position.y + outerPadding;

    const GLubyte *colorBytes = (GLubyte *)&color;
    GLubyte *colors = malloc(sizeof(GLubyte) * 10 * 4);
    for(int i = 0; i < 10; ++i) {
        colors[i * 4 + 0] = colorBytes[3];
        colors[i * 4 + 1] = colorBytes[2];
        colors[i * 4 + 2] = colorBytes[1];
        colors[i * 4 + 3] = colorBytes[0];
    }
    
    // Push our window data into VBOs.
    glDeleteBuffers(1, &vertexBuffer);
    glDeleteBuffers(1, &colorBuffer);
    glGenBuffers(1, &vertexBuffer);
    glGenBuffers(1, &colorBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat *) * 10 * 2, vertices, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, colorBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLubyte *) * 10 * 4, colors, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    // Free the clientside window data.
    free(vertices);
    free(colors);
}


- (void)draw {
    
    // Tell OpenGL about our data.
	glEnableClientState(GL_VERTEX_ARRAY);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
	glVertexPointer(2, GL_FLOAT, 0, 0);

	glEnableClientState(GL_COLOR_ARRAY);
    glBindBuffer(GL_ARRAY_BUFFER, colorBuffer);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, 0);
	
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    // Draw our background.
	glDrawArrays(GL_TRIANGLE_FAN, 0, 10);
    
    // Reset data source.
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
}


- (void)setColor: (long)c {
    
    color = c;
    
    const GLubyte *colorBytes = (GLubyte *)&color;
    opacity = colorBytes[0];

    [self update];
}


- (void)setOpacity: (GLubyte)o {
    
    opacity = o;
    color = (color & 0xffffff00) | opacity;
    
    [self update];
}


-(void) dealloc {
    
    [super dealloc];
}


@end
