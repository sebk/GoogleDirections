//
//  Direction.h
//  GoogleMapsDirections
//
//  Created by Sebastian Kruschwitz on 20.01.13.
//  Copyright (c) 2013 Gobas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^DirectionBlock)(NSArray *steps, NSError *error);

@interface Direction : NSObject

@property(nonatomic, readwrite) CLLocationCoordinate2D startPoint;
@property(nonatomic, readwrite) CLLocationCoordinate2D endPoint;
@property(nonatomic, strong) NSString *travelMode;

@property(nonatomic, readonly) NSString *startAddress;
@property(nonatomic, readonly) NSString *endAddress;
@property(nonatomic, readonly) NSInteger distance; //in meter
@property(nonatomic, readonly) NSInteger duration; //in seconds

@property(nonatomic, strong, readonly) NSArray *steps;


-(void)requestWithStartPoint:(CLLocationCoordinate2D)start endPoint:(CLLocationCoordinate2D)end travelMode:(NSString*)travel result:(DirectionBlock)resultBlock;


@end
