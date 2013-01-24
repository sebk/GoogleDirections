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
        
        if (jsonDict[@"status"] && [jsonDict[@"status"] isEqualToString:@"ZERO_RESULTS"]) {
            NSLog(@"Error requesting direction. No results");
            
            NSString *domain = @"de.gobas.GoogleDirections.Error";
            NSString *desc = @"No results for route";
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
            NSError *error = [NSError errorWithDomain:domain
                                                 code:-101
                                             userInfo:userInfo];
            
            resultBlock(nil, error);
            return;
        }
        
        [self parsePolyLine:jsonDict];
                
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

- (void)parsePolyLine:(NSDictionary *)response {
    NSArray *routes = [response objectForKey:@"routes"];
    NSDictionary *route = [routes lastObject];
    if (route) {
        NSString *overviewPolyline = [[route objectForKey:
                                       @"overview_polyline"] objectForKey:@"points"];
        _polyline = [NSArray arrayWithArray:[Direction decodePolyLine:[overviewPolyline mutableCopy]]];
    }
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

//Thanks to Ankit Srivastava (http://stackoverflow.com/questions/8426592/drawing-path-between-two-locations-using-mkpolyline)
+(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded {
	[encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, [encoded length])];
	NSInteger len = [encoded length];
	NSInteger index = 0;
	NSMutableArray *array = [[NSMutableArray alloc] init];
	NSInteger lat=0;
	NSInteger lng=0;
	while (index < len) {
		NSInteger b;
		NSInteger shift = 0;
		NSInteger result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lat += dlat;
		shift = 0;
		result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lng += dlng;
		NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
		NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
		CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
		[array addObject:loc];
	}
	
	return array;
}

@end
