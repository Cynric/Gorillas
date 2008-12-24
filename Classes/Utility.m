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
//  Utility.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/11/08.
//  Copyright 2008, lhunath (Maarten Billemont). All rights reserved.
//

#import "Utility.h"


@implementation Utility


+(NSString *) rpad:(NSString *)string to:(int)l {
    
    NSMutableString *newString = [NSMutableString stringWithCapacity:l];
    [newString setString:string];
    while ([newString length] < l)
        [newString appendString:@" "];
    
    return newString;
}


+(NSString *) lpad:(NSString *)string to:(int)l {
    
    NSMutableString *newString = [NSMutableString stringWithCapacity:l];
    while ([newString length] + [string length] < l)
        [newString appendString:@" "];
    [newString appendString:string];
    
    return newString;
}


+(NSString *) appendOrdinalPrefixFor:(int)number to:(NSString *)prefix {
    
    NSString *suffix = @"th";
    if(number % 10 == 1 && number != 11)
        suffix = @"st";
    else if(number % 10 == 2 && number != 12)
        suffix = @"nd";
    else if(number % 10 == 3 && number != 13)
        suffix = @"rd";
    
    return [NSString stringWithFormat:@"%@%@", prefix, suffix];
}


+(void) drawPointAt:(cpVect)point {
    
    [self drawPointAt:point.x :point.y];
}


+(void) drawPointAt:(GLfloat)x :(GLfloat)y {
    
    [self drawPointAt:x :y color:0xffffffff];
}


+(void) drawPointAt:(cpVect)point color:(long) color {

    [self drawPointAt:point.x :point.y color:color];
}


+(void) drawPointAt:(GLfloat)x :(GLfloat)y color:(long) color {
    
    const GLfloat point[1 * 2] = { x, y };
    const GLubyte *colorBytes = (GLubyte *)&color;
    
    glVertexPointer(2, GL_FLOAT, 0, point);
    glEnableClientState(GL_VERTEX_ARRAY);
    glColor4f(colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0]);
    
    glDrawArrays(GL_POINTS, 0, 1);
    
    glDisableClientState(GL_VERTEX_ARRAY);
}


+(void) drawLineFrom:(cpVect)from by:(cpVect)by {
    
    const cpVect byAll[] = { by };
    [Utility drawLineFrom:from byAll:byAll count:1];
}


+(void) drawLineFrom:(cpVect)from byAll:(const cpVect *)byAll count:(int)count {

    [Utility drawLineFrom:from byAll:byAll count:count color:0xffffffff];
}


+(void) drawLineFrom:(cpVect)from to:(cpVect)to {
    
    const cpVect toAll[] = { to };
    [Utility drawLineFrom:from toAll:toAll count:1];
}


+(void) drawLineFrom:(cpVect)from toAll:(const cpVect *)toAll count:(int)count {
    
    [Utility drawLineFrom:from toAll:toAll count:count color:0xffffffff];
}


+(void) drawLineFrom:(cpVect)from by:(cpVect)by color:(long)color {
    
    const cpVect byAll[] = { by };
    [Utility drawLineFrom:from byAll:byAll count:1 color:color];
}


+(void) drawLineFrom:(cpVect)from byAll:(const cpVect *)byAll count:(int)count color:(long)color {
    
    [Utility drawLineFrom:from byAll:byAll count:count color:color width:1];
}


+(void) drawLineFrom:(cpVect)from to:(cpVect)to color:(long)color {

    const cpVect toAll[] = { to };
    [Utility drawLineFrom:from toAll:toAll count:1 color:color];
}


+(void) drawLineFrom:(cpVect)from toAll:(const cpVect *)toAll count:(int)count color:(long)color {
    
    [Utility drawLineFrom:from toAll:toAll count:count color:color width:1];
}


+(void) drawLineFrom:(cpVect)from by:(cpVect)by color:(long)color width:(float)width {

    const cpVect byAll[] = { by };
    [Utility drawLineFrom:from byAll:byAll count:1 color:color width:width];
}


+(void) drawLineFrom:(cpVect)from byAll:(const cpVect *)byAll count:(int)n color:(long)color width:(float)width {

    cpVect *to = malloc(sizeof(cpVect) * n);
    cpFloat fx = from.x, fy = from.y;
    for(int i = 0; i < n; ++i) {
        fx += byAll[i].x;
        fy += byAll[i].y;
        
        to[i] = cpv(fx, fy);
    }
    
    [Utility drawLineFrom:from toAll:to count:n color:color width:width];
}


+(void) drawLineFrom:(cpVect)from to:(cpVect)to color:(long)color width:(float)width {

    const cpVect toAll[] = { to };
    [Utility drawLineFrom:from toAll:toAll count:1 color:color width:width];
}


+(void) drawLineFrom:(cpVect)from toAll:(const cpVect *)toAll count:(int)n color:(long)color width:(float)width {
    
    GLfloat *vertices = malloc(sizeof(GLfloat) * 2 * (n + 1));
    vertices[0] = from.x;
    vertices[1] = from.y;
    for(int i = 0; i < n; ++i) {
        vertices[(i + 1) * 2 + 0] = toAll[i].x;
        vertices[(i + 1) * 2 + 1] = toAll[i].y;
    }
    
    const GLubyte *colorBytes = (GLubyte *)&color;
    GLubyte *colors = malloc(sizeof(GLubyte) * 4 * (n + 1));
    for(int i = 0; i < n + 1; ++i) {
        colors[i * 4 + 0] = colorBytes[3];
        colors[i * 4 + 1] = colorBytes[2];
        colors[i * 4 + 2] = colorBytes[1];
        colors[i * 4 + 3] = colorBytes[0];
    }
    
    // Tell OpenGL about our data.
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
	glEnableClientState(GL_COLOR_ARRAY);
	
    glLineWidth(width);
	glDrawArrays(GL_LINE_STRIP, 0, n + 1);
    glLineWidth(1.0f);
    
    // Reset data source.
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
}


+(void) drawBoxFrom:(cpVect)from to:(cpVect)to {
    
    [self drawBoxFrom:from.x :from.y to:to.x :to.y];
}


+(void) drawBoxFrom:(cpVect)from size:(cpVect)size {
    
    [self drawBoxFrom:from to:cpv(from.x + size.x, from.y + size.y)];
}


+(void) drawBoxFrom:(GLfloat)x0 :(GLfloat)y0 to:(GLfloat)x1 :(GLfloat)y1 {
    
    [self drawBoxFrom:x0 :y0 to:x1 :y1 color:0xffffffff];
}


+(void) drawBoxFrom:(cpVect)from size:(cpVect)size color:(long)color {

    [self drawBoxFrom:from to:cpv(from.x + size.x, from.y + size.y) color:color];
}


+(void) drawBoxFrom:(cpVect)from to:(cpVect)to color:(long)color {
    
    [self drawBoxFrom:from.x :from.y to:to.x :to.y color:color];
}


+(void) drawBoxFrom:(GLfloat)x0 :(GLfloat)y0 to:(GLfloat)x1 :(GLfloat)y1 color:(long)color {
    
    const GLfloat vertices[4 * 2] = {
        x0, y0,
        x1, y0,
        x0, y1,
        x1, y1,
    };
    const GLubyte *colorBytes = (GLubyte *)&color;
    const GLubyte colors[4 * 4] = {
        colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0],
        colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0],
        colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0],
        colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0],
    };
    
    // Tell OpenGL about our data.
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
	glEnableClientState(GL_COLOR_ARRAY);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    // Reset data source.
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
}


+(void) drawBorderFrom:(cpVect)from to:(cpVect)to {
    
    [self drawBorderFrom:from.x :from.y to:to.x :to.y];
}


+(void) drawBorderFrom:(cpVect)from size:(cpVect)size {
    
    [self drawBorderFrom:from to:cpv(from.x + size.x, from.y + size.y)];
}


+(void) drawBorderFrom:(GLfloat)x0 :(GLfloat)y0 to:(GLfloat)x1 :(GLfloat)y1 {
    
    [self drawBorderFrom:x0 :y0 to:x1 :y1 color:0xffffffff width:1.0f];
}


+(void) drawBorderFrom:(cpVect)from size:(cpVect)size color:(long)color width:(float)width {
    
    [self drawBorderFrom:from to:cpv(from.x + size.x, from.y + size.y) color:color width:width];
}


+(void) drawBorderFrom:(cpVect)from to:(cpVect)to color:(long)color width:(float)width {
    
    [self drawBorderFrom:from.x :from.y to:to.x :to.y color:color width:width];
}


+(void) drawBorderFrom:(GLfloat)x0 :(GLfloat)y0 to:(GLfloat)x1 :(GLfloat)y1 color:(long)color width:(float)width {
    
    const GLfloat vertices[4 * 2] = {
        x0, y0,
        x1, y0,
        x1, y1,
        x0, y1,
    };
    const GLubyte *colorBytes = (GLubyte *)&color;
    const GLubyte colors[4 * 4] = {
        colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0],
        colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0],
        colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0],
        colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0],
    };
    
    // Tell OpenGL about our data.
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
	glEnableClientState(GL_COLOR_ARRAY);
	
    glLineWidth(width);
	glDrawArrays(GL_LINE_LOOP, 0, 4);
    glLineWidth(1.0f);
    
    // Reset data source.
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
}


@end
