//
//  JSCustomOverlay.m
//  JSTestMap
//
//  Created by Jim on 10/5/14.
//  Copyright (c) 2014 idev.com. All rights reserved.
//

#import "JSCustomOverlay.h"

@implementation JSCustomOverlay
@synthesize boundingMapRect;  // silence compiler

#pragma mark Accessors
- (MKCircle *)circle {
    if (_circle == nil) {
        _circle = [MKCircle circleWithCenterCoordinate:self.region.center radius:self.radius]; // radius in m
    }
    return _circle;
}

- (CLLocationCoordinate2D)coordinates {
    return self.region.center;
}

- (MKMapRect)boundingMapRect {
    return self.circle.boundingMapRect;
}

- (void)setRadius:(CLLocationDistance)radius {
    if (_radius != radius) {
        _radius = radius;
        [self updateCircle];
    }
}

- (void)updateCircle {
    self.circle = nil;
    self.circle;
}
@end
