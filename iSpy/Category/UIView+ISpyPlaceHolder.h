//
//  UIView+ISpyPlaceHolder.h
//  iSpyDemo
//
//  Created by lslin on 15/11/27.
//  Copyright © 2015年 lessfun.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - ISpyPlaceHolder

@interface UIView (ISpyPlaceHolder)

- (void)is_showPlaceHolder;
- (void)is_showPlaceHolderWithAllSubviews;

- (void)is_hidePlaceHolder;
- (void)is_hidePlaceHolderWithAllSubviews;

- (void)is_highlightBorder;

- (void)is_setupSwizzled;
- (void)is_undoSwizzled;

@end