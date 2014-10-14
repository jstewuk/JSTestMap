//
//  MKMapView+Radius.m
//  JSTestMap
//
//  Created by Jim on 10/14/14.
//  Copyright (c) 2014 idev.com. All rights reserved.
//

#import "MKMapView+Radius.h"

@implementation MKMapView (Radius)

- (CLLocationDistance)distanceFromRadius:(CGFloat)radius {
    return 0.0;
}

- (CGPoint)viewPointForRegionCenter:(CLLocationCoordinate2D)regionCenter {
    return [self convertCoordinate:regionCenter toPointView:nil];
}


@end
