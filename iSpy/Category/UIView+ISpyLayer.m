//
//  UIView+ISpyLayer.m
//  iSpyDemo
//
//  Created by lslin on 15/11/27.
//  Copyright © 2015年 lessfun.com. All rights reserved.
//

#import "UIView+ISpyLayer.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (ISpyLayer)

- (void)is_setRoundCorner {
    [self is_setRoundCornerWithBorderWidth:0 borderColor:nil];
}

- (void)is_setRoundCornerWithBorderWidth:(CGFloat)width borderColor:(UIColor *)color {
    [self is_setCornerRadius:(self.frame.size.height / 2.0) borderWidth:width borderColor:color];
}

- (void)is_setCornerRadius:(CGFloat)radius {
    [self is_setCornerRadius:radius borderWidth:0 borderColor:nil];
}

- (void)is_setCornerRadius:(CGFloat)radius borderWidth:(CGFloat)width borderColor:(UIColor *)color {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = radius;
    
    if (width > 0 && color) {
        self.layer.borderColor = color.CGColor;
        self.layer.borderWidth = width;
    }
}

@end
