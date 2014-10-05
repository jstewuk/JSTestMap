//
//  JSCircleView.h
//  JSTestMap
//
//  Created by Jim on 9/30/14.
//  Copyright (c) 2014 idev.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@protocol JSCircleViewDelegate

/**
 Pass the new radius to the delegate to take whatever action is needed
 */
- (void)updateGeofenceRadiusWithRadius:(CGFloat)radius;

/**
 Pass the panning radius to the delegate
 */
- (void)radiusChanged:(CGFloat)newRadius;

@end


/**
 Overlay with circle, and pan recognzier
 Uses view coordinates  (not geo coords)
 */
@interface JSCircleView : UIView

@property (nonatomic, weak) id <JSCircleViewDelegate> delegate;
@property (nonatomic, assign) CGPoint circleCenterPoint;
@property (nonatomic, assign) CGFloat radius;

- (id)initWithFrame:(CGRect)frame radius:(CGFloat)radius;

@end
