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
//  CityTheme.m
//  Gorillas
//
//  Created by Maarten Billemont on 05/12/08.
//  Copyright 2008, lhunath (Maarten Billemont). All rights reserved.
//

#import "CityTheme.h"
#import "GorillasConfig.h"


@implementation CityTheme

@synthesize fixedFloors, buildingMax, buildingAmount, buildingColors;
@synthesize windowAmount, windowColorOn, windowColorOff;
@synthesize skyColor, starColor, starAmount;
@synthesize gravity;


-(id) initWithFixedFloors: (int) nFixedFloors
              BuildingMax: (float) nBuildingMax
           BuildingAmount: (int) nBuildingAmount
           BuildingColors: (NSArray *) nBuildingColors

             WindowAmount: (int) nWindowAmount
            WindowColorOn: (long) nWindowColorOn
           WindowColorOff: (long) nWindowColorOff

                 SkyColor: (long) nSkyColor
                StarColor: (long) nStarColor
               StarAmount: (int) nStarAmount

                  Gravity: (int)nGravity {
    
    if(!(self = [super init]))
        return self;
    
    fixedFloors     = nFixedFloors;
    buildingMax     = nBuildingMax;
    buildingAmount  = nBuildingAmount;
    buildingColors  = nBuildingColors;
    
    windowAmount    = nWindowAmount;
    windowColorOn   = nWindowColorOn;
    windowColorOff  = nWindowColorOff;
    
    skyColor        = nSkyColor;
    starColor       = nStarColor;
    starAmount      = nStarAmount;
    
    gravity         = nGravity;
    
    return self;
}


-(void) apply {
    
    GorillasConfig *config = [GorillasConfig get];
    
    [config setFixedFloors:fixedFloors];
    [config setBuildingMax:buildingMax];
    [config setBuildingAmount:buildingAmount];
    [config setBuildingColors:buildingColors];
    
    [config setWindowAmount:windowAmount];
    [config setWindowColorOn:windowColorOn];
    [config setWindowColorOff:windowColorOff];
    
    [config setSkyColor:skyColor];
    [config setStarColor:starColor];
    [config setStarAmount:starAmount];
    
    [config setGravity:gravity];
}


+(NSDictionary *) getThemes {
    
    static NSDictionary *themes = nil;
    if(!themes) {
        themes = [[NSDictionary dictionaryWithObjectsAndKeys:
                   [[CityTheme alloc] initWithFixedFloors:4
                                              BuildingMax:0.7f
                                           BuildingAmount:10
                                           BuildingColors:[[NSArray arrayWithObjects:
                                                           [NSNumber numberWithLong:0xb70000ff],
                                                           [NSNumber numberWithLong:0x00b7b7ff],
                                                           [NSNumber numberWithLong:0xb7b7b7ff],
                                                           nil] retain]
                    
                                             WindowAmount:6
                                            WindowColorOn:0xffffb7ff
                                           WindowColorOff:0x676767ff
                    
                                                 SkyColor:0x0000b7ff
                                                StarColor:0xb7b700ff
                                               StarAmount:30
                    
                                                  Gravity:100
                   ], @"Classic",

                   [[CityTheme alloc] initWithFixedFloors:4
                                              BuildingMax:0.5f
                                           BuildingAmount:12
                                           BuildingColors:[[NSArray arrayWithObjects:
                                                            [NSNumber numberWithLong:0x6EA665ff],
                                                            [NSNumber numberWithLong:0xD9961Aff],
                                                            [NSNumber numberWithLong:0x1DB6F2ff],
                                                            nil] retain]
                    
                                             WindowAmount:6
                                            WindowColorOn:0xF2D129ff
                                           WindowColorOff:0xD98723ff
                    
                                                 SkyColor:0x1E3615ff
                                                StarColor:0xF2D129ff
                                               StarAmount:100
                    
                                                  Gravity:60
                    ], @"Alien Retro",
                   
                   [[CityTheme alloc] initWithFixedFloors:6
                                              BuildingMax:0.8f
                                           BuildingAmount:14
                                           BuildingColors:[[NSArray arrayWithObjects:
                                                            [NSNumber numberWithLong:0x1B1F1Eff],
                                                            [NSNumber numberWithLong:0xCFB370ff],
                                                            [NSNumber numberWithLong:0xC4C7BCff],
                                                            nil] retain]
                    
                                             WindowAmount:6
                                            WindowColorOn:0xFFF1BFff
                                           WindowColorOff:0x39464Aff
                    
                                                 SkyColor:0x0B0F0Eff
                                                StarColor:0xFFF1BFff
                                               StarAmount:200
                    
                                                  Gravity:40
                    ], @"Alien Skies",
                   
                   [[CityTheme alloc] initWithFixedFloors:3
                                              BuildingMax:0.6f
                                           BuildingAmount:10
                                           BuildingColors:[[NSArray arrayWithObjects:
                                                            [NSNumber numberWithLong:0x465902ff],
                                                            [NSNumber numberWithLong:0xA9BF04ff],
                                                            [NSNumber numberWithLong:0xF29F05ff],
                                                            nil] retain]
                    
                                             WindowAmount:6
                                            WindowColorOn:0xF2E3B3ff
                                           WindowColorOff:0xBF4904ff
                    
                                                 SkyColor:0x021343ff
                                                StarColor:0xF2E3B3ff
                                               StarAmount:50
                    
                                                  Gravity:80
                    ], @"Summer",
                   
                   nil
                   ] retain];
    }
    
    return themes;
}


+(NSString *) defaultThemeName {
    
    return @"Classic";
}


@end
