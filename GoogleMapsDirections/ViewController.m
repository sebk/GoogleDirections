//
//  ViewController.m
//  GoogleMapsDirections
//
//  Created by Sebastian Kruschwitz on 20.01.13.
//  Copyright (c) 2013 Gobas. All rights reserved.
//

#import "ViewController.h"
#import "Direction.h"
#import "Step.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    CLLocationCoordinate2D startPoint = CLLocationCoordinate2DMake(52.27585999999999, 10.53162999999995);
    CLLocationCoordinate2D endPoint = CLLocationCoordinate2DMake(52.2792904, 10.51886000000001);
    
    Direction *direction = [[Direction alloc] init];
    [direction requestWithStartPoint:startPoint endPoint:endPoint travelMode:@"driving" language:@"en" result:^(NSArray *steps, NSError *error) {
        if (!error) {
            NSLog(@"RESULT: %@", [steps[0] description]);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
