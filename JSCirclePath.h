//
//  JSCirclePath.h
//  JSTestMap
//
//  Created by Jim on 10/5/14.
//  Copyright (c) 2014 idev.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface JSCirclePath : NSObject <MKOverlay>

- (instancetype)initWithCenterCoordinate:(CLLocationCoordinate2D)coordinate radius:(CLLocationDistance)radius;

- (void)changeRadius:(CLLocationDistance)radius;

- (void)lockForReading;

- (void)unlockForReading;

@property (nonatomic, readonly) CLLocationDistance radius;

@end
