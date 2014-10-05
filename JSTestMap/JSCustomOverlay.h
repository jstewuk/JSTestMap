//
//  JSCustomOverlay.h
//  JSTestMap
//
//  Created by Jim on 10/5/14.
//  Copyright (c) 2014 idev.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

@interface JSCustomOverlay : MKShape <MKOverlay>

@property (nonatomic, strong) MKCircle *circle;
@property (nonatomic, strong) MKCircle *editCircle;
@property (nonatomic, strong) MKPolyline *radiusLine;
@property (nonatomic, strong) UIColor *color;

@property (nonatomic) MKCoordinateRegion region;
@property (nonatomic) CLLocationDistance radius;

@end
