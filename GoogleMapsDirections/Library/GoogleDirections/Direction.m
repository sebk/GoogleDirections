//
//  Direction.m
//  GoogleMapsDirections
//
//  Created by Sebastian Kruschwitz on 20.01.13.
//  Copyright (c) 2013 Gobas. All rights reserved.
//

#import "Direction.h"
#import "Step.h"
#import "AFJSONRequestOperation.h"


@implementation Direction

-(void)requestWithStartPoint:(CLLocationCoordinate2D)start endPoint:(CLLocationCoordinate2D)end travelMode:(NSString*)travel result:(DirectionBlock)resultBlock {

    _startPoint = start;
    _endPoint = end;
    _travelMode = travel;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=true&mode=%@", start.latitude, start.longitude, end.latitude, end.longitude, travel] ];
    
    NSLog(@"URL for Request: %@", [url absoluteString]);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSDictionary *jsonDict = (NSDictionary*)JSON;
                
        NSArray *legs = ((NSArray*)jsonDict[@"routes"])[0][@"legs"];
        [legs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSDictionary *legsChild = (NSDictionary*)obj;
            _distance = [legsChild[@"distance"][@"value"] integerValue];
            _duration = [legsChild[@"duration"][@"value"] integerValue];
            _endAddress = legsChild[@"end_address"];
            _startAddress = legsChild[@"start_address"];
            
            _steps = [self processSteps:legsChild[@"steps"]];
            
        }];
        
        resultBlock(_steps, nil);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error requesting direction. HTTP statuscode: %i, Error: %@", response.statusCode, error.localizedDescription);
        resultBlock(nil, error);
    }];
    
    [operation start];
}

-(NSArray*)processSteps:(NSArray*)steps {
    NSMutableArray *stepsArray = [NSMutableArray array];
    
    [steps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSDictionary *stepChild = (NSDictionary*)obj;
        Step *step = [[Step alloc] init];
        step.distance = [stepChild[@"distance"][@"value"] integerValue];
        step.duration = [stepChild[@"duration"][@"value"] integerValue];
        step.instruction = stepChild[@"html_instructions"];
        step.polylinePoint = stepChild[@"polyline"][@"points"];
        step.startLocation = CLLocationCoordinate2DMake([stepChild[@"start_location"][@"lat"] floatValue], [stepChild[@"start_location"][@"lng"] floatValue]);
        step.endLocation = CLLocationCoordinate2DMake([stepChild[@"end_location"][@"lat"] floatValue], [stepChild[@"end_location"][@"lng"] floatValue]);
        
        
        [stepsArray addObject:step];
    }];
    
    return stepsArray;
}

@end
