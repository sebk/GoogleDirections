//
//  Step.h
//  GoogleMapsDirections
//
//  Created by Sebastian Kruschwitz on 20.01.13.
//  Copyright (c) 2013 Gobas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Step : NSObject

@property(nonatomic, readwrite) NSInteger distance; //in meter
@property(nonatomic, readwrite) NSInteger duration; //in seconds
@property(nonatomic, readwrite) CLLocationCoordinate2D startLocation;
@property(nonatomic, readwrite) CLLocationCoordinate2D endLocation;
@property(nonatomic, strong) NSString *instruction; //HTML syntax
@property(nonatomic, strong) NSString *polylinePoint;

-(NSString*)description;

@end
