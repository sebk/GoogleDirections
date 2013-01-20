//
//  Step.m
//  GoogleMapsDirections
//
//  Created by Sebastian Kruschwitz on 20.01.13.
//  Copyright (c) 2013 Gobas. All rights reserved.
//

#import "Step.h"

@implementation Step

-(NSString*)description {
    NSMutableString *mutableString = [NSMutableString string];
    [mutableString appendFormat:@"distance: %i \n", _distance];
    [mutableString appendFormat:@"duration: %i \n", _duration];
    [mutableString appendFormat:@"start: latitude %f, longitude %f \n", _startLocation.latitude, _startLocation.longitude];
    [mutableString appendFormat:@"end: latitude %f, longitude %f \n", _endLocation.latitude, _endLocation.longitude];
    [mutableString appendFormat:@"instruction: %@ \n", _instruction];
    [mutableString appendFormat:@"polyline points: %@ \n", _polylinePoint];
    
    return mutableString;
}

@end
