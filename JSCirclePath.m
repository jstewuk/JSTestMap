//
//  JSCirclePath.m
//  JSTestMap
//
//  Created by Jim on 10/5/14.
//  Copyright (c) 2014 idev.com. All rights reserved.
//

#import "JSCirclePath.h"
#import <pthread.h>

@interface JSCirclePath () {
    pthread_rwlock_t rwLock;
}

@property (nonatomic, readwrite) CLLocationDistance radius;
@property (nonatomic) MKMapPoint mapPoint;
@end

@implementation JSCirclePath
@synthesize boundingMapRect;


#pragma mark - Public methods

- (instancetype)initWithCenterCoordinate:(CLLocationCoordinate2D)coordinate radius:(CLLocationDistance)radius {
    self = [super init];
    if (self == nil) {
        return self;
    }
    _mapPoint = MKMapPointForCoordinate(coordinate);
    _radius = radius;
    
    pthread_rwlock_init(&rwLock, NULL);
    
    return self;
}

- (void)changeRadius:(CLLocationDistance)radius {
    pthread_rwlock_wrlock(&rwLock);
    self.radius = radius;
    pthread_rwlock_unlock(&rwLock);
}

- (void)lockForReading {
    pthread_rwlock_rdlock(&rwLock);
}

- (void)unlockForReading {
    pthread_rwlock_unlock(&rwLock);
}

#pragma mark -

- (void)dealloc {
    pthread_rwlock_destroy(&rwLock);
}

- (CLLocationCoordinate2D)coordinate {
    return MKCoordinateForMapPoint(self.mapPoint);
}

- (MKMapRect)boundingMapRect {
    MKMapSize size;
    size.width = 2 * self.radius;
    size.height = 2 * self.radius;
//    return (MKMapRect){{0,0}, size};
    return MKMapRectWorld;
}


@end
