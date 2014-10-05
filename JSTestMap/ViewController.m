//
//  ViewController.m
//  JSTestMap
//
//  Created by Jim on 9/30/14.
//  Copyright (c) 2014 idev.com. All rights reserved.
//

#import "ViewController.h"

#import <MapKit/MapKit.h>
#import "JSCircleView.h"

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

@property (nonatomic, strong) MKCircleRenderer *renderer;

@property (nonatomic, assign) CLLocationCoordinate2D dragCoordinates;

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
    [self zoomToLocation];
    self.circleView.circleCenterPoint = [self.mapView convertCoordinate:self.region.center toPointToView:self.circleView];
    [self updateLocation];
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)dealloc {
    self.mapView.delegate = nil;
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
//        CLLocation *testLocation = [[CLLocation alloc] initWithLatitude:30.25 longitude:97.75];
//        _region.center.latitude = testLocation.coordinate.latitude;
//        _region.center.longitude = - testLocation.coordinate.longitude;
        _region.center.latitude = self.location.coordinate.latitude;
        _region.center.longitude = self.location.coordinate.longitude;
        _region.span.latitudeDelta = 1.0/6.0;
        _region.span.longitudeDelta = 1.0/6.0 * cos(_region.center.latitude * M_PI / 180.0);
    }
    return _region;
}

- (MKCircle *)circle {
    if (_circle == nil) {
        _circle = [MKCircle circleWithCenterCoordinate:self.region.center radius:self.radiusDistance]; // radius in m
    }
    return _circle;
}

- (void)configureMapView {
    self.mapView.delegate = self;
    self.mapView.zoomEnabled = YES;
    self.mapView.scrollEnabled = NO;
}

- (void)zoomToLocation {
    [self.mapView setRegion:self.region animated:NO];
    [self.mapView setCenterCoordinate:self.region.center animated:NO];
}

- (void)addCircle {
    [self.mapView addOverlay:self.circle];
}

- (JSCircleView *)circleView {
    if (_circleView == nil) {
        _circleView = [[JSCircleView alloc] initWithFrame:self.view.frame radius:100];
        _circleView.delegate = self;
    }
    return _circleView;
}

- (void)updateLocation {
    [self.locationManager startUpdatingLocation];
}

#pragma mark - MKMapViewDelegate compliance

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
        circleRenderer.lineWidth = 1.0;
        circleRenderer.strokeColor = [UIColor redColor];
        self.renderer = circleRenderer;
        return circleRenderer;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (self.scalingInProgress) {
        NSLog(@"Region did change, animated: %@", animated ? @"YES" : @"NO");
        CGFloat radius = [self radiusFromCircleOverlay];
        self.circleView.radius = radius;
        self.circleView.circleHidden = NO;
//        [self.mapView removeOverlay:self.circle];
        self.circle = nil;
        self.scalingInProgress = NO;
    }
}

#pragma mark - JSCircleViewDelegate compliance

- (void)updateGeofenceRadiusWithRadius:(CGFloat)radius {
    NSLog(@"update geofence called");
    CGFloat minRadius = 25.0;
    
    self.radiusDistance = [self distanceFromRadius:radius];
    
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
    [self addCircle];
    self.circleView.circleHidden = YES;
    
    MKCoordinateRegion region = self.mapView.region;
    region.span.latitudeDelta *= factor;
    region.span.longitudeDelta *= factor;
    [self.circleView animateDashedLineToRadius:radius / factor];
    [self.mapView setRegion:region animated:YES];
}

- (void)updateGeofenceSettingsWithRadius:(CGFloat)radius {
    
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
