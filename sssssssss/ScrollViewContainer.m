//
//  ScrollViewContainer.m
//  Gallery
//
//  Created by Simon Anreiter on 30.08.13.
//  Copyright (c) 2013 Simon Anreiter. All rights reserved.
//


#import "ScrollViewContainer.h"

@implementation ScrollViewContainer

@synthesize scrollView = _scrollView;

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        return _scrollView;
    }
    return view;
}

@end
