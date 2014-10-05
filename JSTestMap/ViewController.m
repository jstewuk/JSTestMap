//
//  ViewController.m
//  JSTestMap
//
//  Created by Jim on 9/30/14.
//  Copyright (c) 2014 idev.com. All rights reserved.
//

#import "ViewController.h"

@import MapKit;
#import "JSCustomOverlayRenderer.h"
#import "JSCustomOverlay.h"
#import "JSCircleView.h"

#import "JSCirclePath.h"
#import "JSCircleOverlayRenderer.h"

#import <CoreLocation/CoreLocation.h>

@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate, JSCircleViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) MKCircle *circle;
@property (nonatomic, assign) MKCoordinateRegion region;
@property (nonatomic, strong) JSCircleView *circleView;
@property (nonatomic, assign) CLLocationDistance radiusDistance;
@property (nonatomic, assign) BOOL scalingInProgress;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;

@property (nonatomic, assign) CLLocationCoordinate2D dragCoordinates;

@property (nonatomic, strong) JSCustomOverlay *customOverlay;
@property (nonatomic, strong) JSCustomOverlayRenderer *overlayRenderer;

@property (nonatomic, strong) MKCircle *circleOverlay;
@property (nonatomic, assign) CLLocationDistance circleOverlayRadius;

@property (nonatomic, strong) JSCirclePath *jsCircleOverlay;
@property (nonatomic, strong) JSCircleOverlayRenderer *circleRenderer;

@end

@implementation ViewController

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.circleView];
//    [self addCustomOverlay];
    [self addCustomCircleOverlay];
    [self zoomToLocation];
    [self updateLocation];
    [self.circleRenderer setNeedsDisplay];
}

- (void)dealloc {
    self.mapView.delegate = nil;
}

#pragma mark - Accessors

- (CLLocationManager *)locationManager {
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (MKMapView *)mapView {
    if (_mapView == nil) {
        _mapView = [[MKMapView alloc]initWithFrame:self.view.frame];
        [self configureMapView];
    }
    return _mapView;
}

- (MKCoordinateRegion)region {
    if (_region.center.latitude == 0.0) {
        CLLocation *testLocation = [[CLLocation alloc] initWithLatitude:30.25 longitude:-97.75];
        CLLocation *location = testLocation;
//        CLLocation *location = self.location;
        _region.center.latitude = location.coordinate.latitude;
        _region.center.longitude = location.coordinate.longitude;
        _region.span.latitudeDelta = 1.0/6.0;
        _region.span.longitudeDelta = 1.0/6.0 * cos(_region.center.latitude * M_PI / 180.0);
    }
    return _region;
}

- (JSCustomOverlay *)customOverlay {
    if (_customOverlay == nil) {
        _customOverlay = [[JSCustomOverlay alloc] init];
        _customOverlay.region = self.region;
        _customOverlay.radius = 5000;
//        _customOverlay.radius = self.radiusDistance;
        _customOverlay.color = [UIColor redColor];
    }
    return _customOverlay;
}

- (JSCircleView *)circleView {
    if (_circleView == nil) {
        _circleView = [[JSCircleView alloc] initWithFrame:self.view.frame radius:100];
        _circleView.delegate = self;
    }
    return _circleView;
}

- (MKCircle *)circleOverlay {
    if (_circleOverlay == nil) {
        _circleOverlay = [MKCircle circleWithCenterCoordinate:self.region.center radius:self.circleOverlayRadius];
    }
    return _circleOverlay;
}

- (JSCirclePath *)jsCircleOverlay {
    if (_jsCircleOverlay == nil) {
        _jsCircleOverlay = [[JSCirclePath alloc] initWithCenterCoordinate:self.region.center radius:5000];
    }
    return _jsCircleOverlay;
}

#pragma mark - Actors

- (void)configureMapView {
    self.mapView.delegate = self;
    self.mapView.zoomEnabled = YES;
    self.mapView.scrollEnabled = NO;
}

- (void)zoomToLocation {
    [self.mapView setRegion:self.region animated:NO];
    [self.mapView setCenterCoordinate:self.region.center animated:NO];
}

- (void)addCustomOverlay {
    [self.mapView addOverlay:self.customOverlay];
}

- (void)addCircleOverlay {
    [self.mapView addOverlay:self.circleOverlay];
}

- (void)addCustomCircleOverlay {
    [self.mapView addOverlay:self.jsCircleOverlay];
}

- (void)updateLocation {
    [self.locationManager startUpdatingLocation];
}

#pragma mark - Map stuff

- (CLLocationDistance)distanceFromRadius:(CGFloat)radius {
    CGPoint dragPoint = CGPointMake(self.circleView.circleCenterPoint.x + radius,
                                    self.circleView.circleCenterPoint.y);
    self.dragCoordinates = [self.mapView convertPoint:dragPoint toCoordinateFromView:self.circleView];
    CLLocation *dragLocation = [[CLLocation alloc] initWithLatitude:self.dragCoordinates.latitude longitude:self.dragCoordinates.longitude];
    CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:self.region.center.latitude longitude:self.region.center.longitude];
    CLLocationDistance distance = [dragLocation distanceFromLocation:centerLocation];
    return distance;
}

- (CGFloat)radiusFromCircleOverlay {
    CGPoint dragPoint = [self.mapView convertCoordinate:self.dragCoordinates toPointToView:self.circleView];
    CGPoint centerPoint = [self.mapView convertCoordinate:self.region.center toPointToView:self.circleView];
    return dragPoint.x - centerPoint.x;
}


#pragma mark - MKMapViewDelegate compliance

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[JSCustomOverlay class]]) {
        self.overlayRenderer = [[JSCustomOverlayRenderer alloc] initWithCustomOverlay:overlay];
        return self.overlayRenderer;
    } else if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleRenderer *renderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
        renderer.strokeColor = [UIColor blueColor];
        renderer.lineWidth = 1.5;
        return renderer;
    } else if ([overlay isKindOfClass:[JSCirclePath class]]) {
        self.circleRenderer = [[JSCircleOverlayRenderer alloc] initWithOverlay:overlay];
        return self.circleRenderer;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (self.scalingInProgress) {
        NSLog(@"Region did change, animated: %@", animated ? @"YES" : @"NO");
        self.circle = nil;
        self.scalingInProgress = NO;
    }
}

#pragma mark - JSCircleViewDelegate compliance
- (void)radiusChanged:(CGFloat)newRadius {
    CLLocationDistance distance = [self distanceFromRadius:newRadius];
//    self.customOverlay.radius = distance;
//    self.circleOverlayRadius = distance;
    [self.jsCircleOverlay changeRadius:distance];
    [self.circleRenderer setNeedsDisplay];
}

- (void)updateGeofenceRadiusWithRadius:(CGFloat)radius {
    NSLog(@"update geofence called");
    CGFloat minRadius = 25.0;
    
    if (2 * radius > [self shortestSideLength] - 20) {
        [self scaleMapWithFactor:1.5 radius:radius];
    } else if (radius < minRadius + 3) {
        [self scaleMapWithFactor:1.0/3.0 radius:radius];
    } else {
        [self updateGeofenceSettingsWithRadius:radius];
    }
 }

- (void)scaleMapWithFactor:(CGFloat)factor radius:(CGFloat)radius {
    self.scalingInProgress = YES;
    
    MKCoordinateRegion region = self.mapView.region;
    region.span.latitudeDelta *= factor;
    region.span.longitudeDelta *= factor;
    [self.mapView setRegion:region animated:YES];
}

- (void)updateGeofenceSettingsWithRadius:(CGFloat)radius {
    NSLog(@"Time to reset the geofence!");
}

- (CGFloat)shortestSideLength {
    return MIN(self.view.frame.size.width, self.view.frame.size.height);
}

#pragma mark - CLLocationManagerDelegate 

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.location = [locations lastObject];
    [self zoomToLocation];
    
    [self.locationManager stopUpdatingLocation];
}
@end
