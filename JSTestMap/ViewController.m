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

@interface ViewController () <MKMapViewDelegate, JSCircleViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) MKCircle *circle;
@property (nonatomic, assign) MKCoordinateRegion region;
@property (nonatomic, strong) JSCircleView *circleView;
@property (nonatomic, assign) CLLocationDistance radiusDistance;
@property (nonatomic, assign) BOOL scalingInProgress;

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
    CLLocationCoordinate2D dragCoords = [self.mapView convertPoint:dragPoint toCoordinateFromView:self.circleView];
    CLLocation *dragLocation = [[CLLocation alloc] initWithLatitude:dragCoords.latitude longitude:dragCoords.longitude];
    CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:self.region.center.latitude longitude:self.region.center.longitude];
    CLLocationDistance distance = [dragLocation distanceFromLocation:centerLocation];
    return distance;
}

#pragma mark - Accessors

- (MKMapView *)mapView {
    if (_mapView == nil) {
        _mapView = [[MKMapView alloc]initWithFrame:self.view.frame];
        [self configureMapView];
    }
    return _mapView;
}

- (MKCoordinateRegion)region {
    if (_region.center.latitude == 0.0) {
        CLLocation *testLocation = [[CLLocation alloc] initWithLatitude:30.25 longitude:97.75];
        _region.center.latitude = testLocation.coordinate.latitude;
        _region.center.longitude = - testLocation.coordinate.longitude;
        _region.span.latitudeDelta = 1.0/6.0;
        _region.span.longitudeDelta = 1.0/6.0 * cos(testLocation.coordinate.latitude * M_PI / 180.0);
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

#pragma mark - MKMapViewDelegate compliance

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
        circleRenderer.lineWidth = 1.0;
        circleRenderer.strokeColor = [UIColor blueColor];
        return circleRenderer;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (self.scalingInProgress) {
        NSLog(@"Region did change, animated: %@", animated ? @"YES" : @"NO");
        self.circleView.radius = 103;
        [self.view addSubview:self.circleView];
        [self.mapView removeOverlay:self.circle];
        self.circle = nil;
        self.scalingInProgress = NO;
    }
}

#pragma mark - JSCircleViewDelegate compliance

- (void)updateGeofenceRadiusWithRadius:(CGFloat)radius {
    NSLog(@"update geofence called");
    
    if (2 * radius > [self shortestSideLength] - 20) {
        self.scalingInProgress = YES;
        self.radiusDistance = [self distanceFromRadius:radius];
        NSLog(@"distance: %f", self.radiusDistance);
        [self addCircle];
        [self.circleView removeFromSuperview];
        
        MKCoordinateRegion region = self.mapView.region;
        region.span.latitudeDelta *= 1.5;
        region.span.longitudeDelta *= 1.5;
        [self.mapView setRegion:region animated:YES];
    }
 }

- (CGFloat)shortestSideLength {
    return MIN(self.view.frame.size.width, self.view.frame.size.height);
}


@end
