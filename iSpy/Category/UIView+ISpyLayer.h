//
//  UIView+ISpyLayer.h
//  iSpyDemo
//
//  Created by lslin on 15/11/27.
//  Copyright © 2015年 lessfun.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ISpyLayer)

- (void)is_setRoundCorner;
- (void)is_setRoundCornerWithBorderWidth:(CGFloat)width borderColor:(UIColor *)color;
- (void)is_setCornerRadius:(CGFloat)radius;
- (void)is_setCornerRadius:(CGFloat)radius borderWidth:(CGFloat)width borderColor:(UIColor *)color;

@end
