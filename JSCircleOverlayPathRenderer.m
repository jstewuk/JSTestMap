//
//  JSCircleOverlayRenderer.m
//  JSTestMap
//
//  Created by Jim on 10/5/14.
//  Copyright (c) 2014 idev.com. All rights reserved.
//

#import "JSCircleOverlayPathRenderer.h"
#import "JSCirclePath.h"

@implementation JSCircleOverlayPathRenderer

- (instancetype)initWithOverlay:(id<MKOverlay>)overlay {
    self = [super initWithOverlay:overlay];
    if (self == nil) {
        return nil;
    }
    
    self.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.2];
    self.strokeColor = [UIColor blueColor];
    self.lineWidth = 2.0;
    JSCirclePath *circle = (JSCirclePath *)self.overlay;
    [circle addObserver:self forKeyPath:@"radius" options:NSKeyValueObservingOptionNew context:NULL];
    
    return self;
}

- (void)dealloc {
    JSCirclePath *circle = (JSCirclePath *)self.overlay;
    [circle removeObserver:self forKeyPath:@"radius"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    [self invalidatePath];
}

- (void)createPath {
    JSCirclePath *circle = (JSCirclePath *)self.overlay;

    //calculate CG values from circle coordinate and radius...
    CLLocationCoordinate2D center = circle.coordinate;
    CGFloat radius = MKMapPointsPerMeterAtLatitude(center.latitude) * circle.radius;
    
    CGPoint centerPoint = [self pointForMapPoint:MKMapPointForCoordinate(circle.coordinate)];

    CGMutablePathRef path = CGPathCreateMutable();
    CGRect circleRect = CGRectMake(centerPoint.x - radius,
                             centerPoint.y - radius,
                             2 * radius,
                             2 * radius);

    CGPathAddEllipseInRect(path, &CGAffineTransformIdentity, circleRect);
    self.path = path;
}


- (BOOL)canDrawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale {
    return YES;
}

@end
