//
//  JSCustomOverlayRenderer.m
//  JSTestMap
//
//  Created by Jim on 10/5/14.
//  Copyright (c) 2014 idev.com. All rights reserved.
//

#import "JSCustomOverlayRenderer.h"
#import "JSCustomOverlay.h"

@interface JSCustomOverlayRenderer ()

@property (nonatomic, strong) MKCircleRenderer *circleRenderer;
@property (nonatomic, strong) MKCircleRenderer *editCircleRenderer;
@property (nonatomic, strong) MKPolylineRenderer *radiusLineRenderer;
@property (nonatomic) MKMapRect circleBoundingMapRect;
@property (nonatomic) MKMapRect editCircleBoundingMapRect;
@property (nonatomic) MKMapRect radiusLineBoundingMapRect;

@property (nonatomic) MKMapRect lastCircleBoundingMapRect;

@end


@implementation JSCustomOverlayRenderer

- (instancetype)initWithCustomOverlay:(JSCustomOverlay *)overlay {
    self = [super initWithOverlay:overlay];
    if (self == nil) {
        return self;
    }
    
    _circleRenderer = [[MKCircleRenderer alloc] initWithOverlay:overlay.circle];
    _circleRenderer.lineWidth = 2.0;
    _circleRenderer.strokeColor = overlay.color;
    _circleBoundingMapRect = overlay.circle.boundingMapRect;
    CGFloat red, green, blue, alpha;
    [overlay.color getRed:&red green:&green blue:&blue alpha:&alpha];
    _circleRenderer.fillColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.2];
   
    /*
    _editCircleRenderer = [[MKCircleRenderer alloc] initWithOverlay:overlay.editCircle];
    _editCircleRenderer.fillColor = overlay.color;
    _editCircleBoundingMapRect = overlay.editCircle.boundingMapRect;
    
    _radiusLineRenderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay.radiusLine];
    _radiusLineRenderer.lineWidth = 1.5;
    _radiusLineRenderer.strokeColor = overlay.color;
    _radiusLineRenderer.lineDashPattern = @[@2.0, @2.0];
    _radiusLineBoundingMapRect = overlay.radiusLine.boundingMapRect;
    */

    return self;
}

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    CGPoint point;
    _circleBoundingMapRect = ((JSCustomOverlay *)self.overlay).circle.boundingMapRect;
    CGPoint scale = {1.1, 1.1};
//    if (MKMapRectEqualToMapRect(_circleBoundingMapRect, _lastCircleBoundingMapRect) == false ||
//        _lastCircleBoundingMapRect.size.width  == 0 ||
//        _lastCircleBoundingMapRect.size.height == 0 )
//    {
//        scale = (CGPoint){_circleBoundingMapRect.size.width / _lastCircleBoundingMapRect.size.width,
//            _circleBoundingMapRect.size.height / _lastCircleBoundingMapRect.size.height
//        };
//    }
//    _lastCircleBoundingMapRect = _circleBoundingMapRect;
    
    CGContextSaveGState(context);
    point = [self pointForMapPoint:_circleBoundingMapRect.origin];
    CGContextScaleCTM(context, scale.x, scale.y);
    [self.circleRenderer drawMapRect:_circleBoundingMapRect zoomScale:zoomScale inContext:context];
    CGContextRestoreGState(context);
}

bool MKMapRectEqualToMapRect(MKMapRect rect1, MKMapRect rect2) {
    return (rect1.origin.x == rect2.origin.x &&
            rect1.origin.y == rect2.origin.y &&
            rect1.size.width == rect2.size.width &&
            rect1.size.height == rect2.size.height);
}

@end
