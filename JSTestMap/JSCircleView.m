//
//  JSCircleView.m
//  JSTestMap
//
//  Created by Jim on 9/30/14.
//  Copyright (c) 2014 idev.com. All rights reserved.
//

#import "JSCircleView.h"

#import "JSCircleView.h"

//
//  HDYCustomGeofenceRadiusView.m
//  Arena
//
//  Created by Siyana Slavova on 9/18/14.
//  Copyright (c) 2014 Honeywell. All rights reserved.
//
#define CENTER_POINT_RADIUS 4
#define DRAG_POINT_RADIUS 4
#define VIEW_INSET 2.5

const CGFloat kMinRadius = 25; // points

// This needs to move to the View controller, it is in geo coords vice screen coords
// - Min value = ~500m, default = 2 miles, max value = ~1500 miles
const CGFloat kMinRadiusInMeters = 500.0;
const CGFloat kMaxRadiusInMiles = 1500.0;
const CGFloat kDefaultRadiusInMiles = 2.0;

@interface JSCircleView ()

@property (weak, nonatomic) UIView *point;
@property (weak, nonatomic) UIView *centerPoint;
@property (assign) CGFloat currentRadius;

@end

@implementation JSCircleView

- (id)initWithFrame:(CGRect)frame radius:(CGFloat)radius
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        _currentRadius = radius;
        [self addCenterPoint];
        [self addDraggablePoint];
        _circleCenterPoint = self.center;
    }
    return self;
}

// handle basic view initialization, set radius to 60% of smaller of height or width
- (instancetype)initWithFrame:(CGRect)frame {
    CGFloat longEdge = MIN(frame.size.height, frame.size.width);
    CGFloat radius = longEdge / 2 * 0.6;
    
    return [self initWithFrame:frame radius:radius];
}

#pragma mark - Accessors

- (void)setCircleCenterPoint:(CGPoint)circleCenterPoint {
    if (_circleCenterPoint.x != circleCenterPoint.x || _circleCenterPoint.y != circleCenterPoint.y) {
        _circleCenterPoint = circleCenterPoint;
    }
}

- (void)setRadius:(CGFloat)radius {
    self.currentRadius = radius;
    [self setNeedsDisplay];
}

#pragma mark -

- (void)layoutSubviews
{
    [self.centerPoint setCenter:self.circleCenterPoint];
    [self.point setCenter:CGPointMake(self.circleCenterPoint.x + self.currentRadius, self.circleCenterPoint.y)];
}

- (void) resizeCircle:(UIPanGestureRecognizer*)panRecognizer
{
    CGPoint translation = [panRecognizer translationInView:self];
    
    CGFloat unClampedRadius = self.currentRadius + translation.x;
    self.currentRadius = [self clampedRadius:unClampedRadius];
    
    if (self.currentRadius > kMinRadius) {
        [panRecognizer setTranslation:CGPointZero inView:self];
    }
    
    [self setNeedsLayout];
    [self setNeedsDisplay];
    
    [self panStateDispatcher:panRecognizer];
}

- (void)panStateDispatcher:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"pan ended");
        [self.delegate updateGeofenceRadiusWithRadius:self.currentRadius];
//        CGFloat maxRadius = MIN(self.frame.size.height / 2, self.frame.size.width / 2);
        
//        [UIView animateWithDuration:0.5 animations:^{
//            self.currentRadius = 0.65 * maxRadius;
//        }];
    }
}

- (CGFloat)clampedRadius:(CGFloat)radius {
    CGFloat clampedRadius = MAX(radius, kMinRadius);
    //Limit to frame size
    CGFloat maxRadius = MIN(self.frame.size.height / 2, self.frame.size.width / 2);
    if (clampedRadius >= maxRadius) {
        [self expandedToViewHeight];
    }
    return MIN(clampedRadius, maxRadius);
}

// Not sure we need this
- (void)expandedToViewHeight {
    //	HBALogDebug(@"at ViewHeight");
}

- (void)addCenterPoint
{
    UIView *centerPoint = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2 * CENTER_POINT_RADIUS, 2 * CENTER_POINT_RADIUS)];
    centerPoint.backgroundColor = [UIColor blueColor];
    
    centerPoint.layer.cornerRadius = (centerPoint.bounds.size.height - 0.1)/2;
    centerPoint.layer.masksToBounds = YES;
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.duration = 1;
    scaleAnimation.repeatCount = HUGE_VAL;
    scaleAnimation.autoreverses = YES;
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.2];
    scaleAnimation.toValue = [NSNumber numberWithFloat:0.8];
    
    [centerPoint.layer addAnimation:scaleAnimation forKey:@"scale"];
    
    [self addSubview:centerPoint];
    self.centerPoint = centerPoint;
}

- (void)addDraggablePoint
{
    UIView *point = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2 * DRAG_POINT_RADIUS, 2 * DRAG_POINT_RADIUS)];
    point.backgroundColor = [UIColor blackColor];
    
    point.layer.cornerRadius = (point.bounds.size.height - 0.1)/2;
    point.layer.masksToBounds = YES;
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(resizeCircle:)];
    [point addGestureRecognizer:panRecognizer];
    [self addSubview:point];
    self.point = point;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat effectiveScaleFactor = [self contentScaleFactor];
    
    CGFloat lineWidth = 2 * (1.0 / effectiveScaleFactor);
    
    CGRect circleRect = CGRectMake(self.circleCenterPoint.x - self.currentRadius,
                                   self.circleCenterPoint.y - self.currentRadius,
                                   self.currentRadius * 2,
                                   self.currentRadius * 2);
    
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:circleRect];
    
    [[UIColor blueColor] setStroke];
    
    circlePath.lineWidth = lineWidth;
    
    [circlePath stroke];
    
    UIBezierPath *line = [UIBezierPath bezierPath];
    [line moveToPoint:CGPointMake(self.circleCenterPoint.x, self.circleCenterPoint.y)];
    [line addLineToPoint:CGPointMake(self.point.center.x, self.point.center.y)];
    [[UIColor blackColor] setStroke];
    CGFloat dashPattern[] = {2,2,2,2}; //make your pattern here
    [line setLineDash:dashPattern count:4 phase:3];
    [line stroke];
    [line closePath];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    // Huge hit area is good
    if (CGRectContainsPoint(CGRectInset(self.point.frame, -100 * VIEW_INSET, -100 * VIEW_INSET), point)) {
        return self.point;
    }
    return nil;
}

//- (void)setDirectedRadius:(CGFloat)directedRadius {
//    if (directedRadius != _directedRadius) {
//        _directedRadius = directedRadius;
//        self.currentRadius = directedRadius;
//    }
//}

@end
