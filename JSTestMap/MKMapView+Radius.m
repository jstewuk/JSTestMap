//
//  MKMapView+Radius.m
//  JSTestMap
//
//  Created by Jim on 10/14/14.
//  Copyright (c) 2014 idev.com. All rights reserved.
//

#import "MKMapView+Radius.h"

#import "JSCircleView.h"

static const CLLocationDistance kMinDistanceRadius = 500; // meters
static const CLLocationDistance kMaxDistanceRadius = 1500 * 1609.34; // 1500 miles
//static const CLLocationDistance kDefaultDistanceRadius = 2 * 1609.34; //2 miles
static const CLLocationDegrees  kMetersPerDegreeLatitude = 111319.0;

@implementation MKMapView (Radius)

- (CLLocationDistance)distanceFromRadius:(CGFloat)radius {
    return 0.0;
}

- (CGPoint)viewPointForRegionCenter:(CLLocationCoordinate2D)regionCenter {
    return [self convertCoordinate:regionCenter toPointToView:nil];
}

- (void)scaleMapWithFactor:(CGFloat)factor radius:(CGFloat)radius {
//    self.scalingInProgress = YES;
    MKCoordinateRegion region = self.region;
    region.span.latitudeDelta *= factor;
    region.span.longitudeDelta *= factor;
    region = [self regionClampedToLimits:region];
    region = [self regionThatFits:region];
//    region.center = self.location.coordinate;
    [self setRegion:region animated:YES];
//    [self.circleView setCircleCenterPoint:[self circleViewCenterPointForRegion:self.mapView.region]];
}

- (MKCoordinateRegion)regionClampedToLimits:(MKCoordinateRegion)region {
    if (region.span.latitudeDelta < [self minimumSpan].latitudeDelta) {
        return MKCoordinateRegionMake(self.region.center, [self minimumSpan]);
    } else if (region.span.latitudeDelta > [self maximumSpan].latitudeDelta) {
        return MKCoordinateRegionMake(self.region.center, [self maximumSpan]);
    } else {
        return region;
    }
}

- (MKCoordinateSpan)minimumSpan {
    CLLocationCoordinate2D centerCoordinate = self.region.center;
    CLLocationDegrees lattitudeDelta = kMinDistanceRadius * 1.5 * 2 / kMetersPerDegreeLatitude;
    CLLocationDegrees longitudeDelta = lattitudeDelta * cos(centerCoordinate.latitude * M_PI/180.);
    return  MKCoordinateSpanMake(lattitudeDelta, longitudeDelta);
}

- (MKCoordinateSpan)maximumSpan {
    CLLocationCoordinate2D centerCoordinate = self.region.center;
    CLLocationDegrees lattitudeDelta = kMaxDistanceRadius * 1.5 * 2 / kMetersPerDegreeLatitude;
    CLLocationDegrees longitudeDelta = lattitudeDelta * cos(centerCoordinate.latitude * M_PI/180.);
    return MKCoordinateSpanMake(lattitudeDelta, longitudeDelta);
}


@end
