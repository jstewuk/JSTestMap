//
//  JSCustomOverlayRenderer.h
//  JSTestMap
//
//  Created by Jim on 10/5/14.
//  Copyright (c) 2014 idev.com. All rights reserved.
//

#import <MapKit/MapKit.h>
@class JSCustomOverlay;

@interface JSCustomOverlayRenderer : MKOverlayRenderer

- (instancetype)initWithCustomOverlay:(JSCustomOverlay *)overlay;

@end
