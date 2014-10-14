//
//  MKMapView+Radius.h
//  JSTestMap
//
//  Created by Jim on 10/14/14.
//  Copyright (c) 2014 idev.com. All rights reserved.
//

@import MapKit;

@interface MKMapView (Radius)

- (CLLocationDistance)distanceFromRadius:(CGFloat)radius;

- (CGPoint)viewPointForRegionCenter:(CLLocationCoordinate2D)regionCenter;

- (void)scaleMapWithFactor:(CGFloat)factor radius:(CGFloat)radius;

@end
