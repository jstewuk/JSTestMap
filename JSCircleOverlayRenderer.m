//
//  JSCircleOverlayRenderer.m
//  JSTestMap
//
//  Created by Jim on 10/5/14.
//  Copyright (c) 2014 idev.com. All rights reserved.
//

#import "JSCircleOverlayRenderer.h"
#import "JSCirclePath.h"

@implementation JSCircleOverlayRenderer

- (instancetype)initWithOverlay:(id<MKOverlay>)overlay {
    self = [super initWithOverlay:overlay];
    if (self == nil) {
        return nil;
    }
    
    return self;
}

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)context
{
    JSCirclePath *circle = (JSCirclePath *)self.overlay;
    [circle lockForReading];
    
    //calculate CG values from circle coordinate and radius...
    CLLocationCoordinate2D center = circle.coordinate;
    CGFloat radius = MKMapPointsPerMeterAtLatitude(center.latitude) * circle.radius;

    [circle unlockForReading];
    
    CGPoint centerPoint = [self pointForMapPoint:MKMapPointForCoordinate(circle.coordinate)];
    
    CGContextSetFillColorWithColor(context, [[UIColor blueColor] colorWithAlphaComponent:0.2].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    CGContextAddArc(context, centerPoint.x, centerPoint.y, radius, 0, 2 * M_PI, true);
    CGContextDrawPath(context, kCGPathFillStroke);
//    CGContextStrokePath(context);
}

- (BOOL)canDrawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale {
    return YES;
}

@end
