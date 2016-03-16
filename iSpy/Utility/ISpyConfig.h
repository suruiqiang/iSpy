//
//  ISpyConfig.h
//  iSpyDemo
//
//  Created by lslin on 15/11/27.
//  Copyright © 2015年 lessfun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISpyMacros.h"

static const NSInteger kISpyViewTag = 99990000;
static const NSInteger kISpyPlaceHolderViewTag = 99990001;

#pragma - mark -
@interface ISpyViewConfig : NSObject

@property (nonatomic, assign) CGRect entryViewFrame;
@property (nonatomic, assign) CGRect statsViewFrame;
@property (nonatomic, assign) CGRect moreViewFrame;

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *textNormalColor;
@property (nonatomic, strong) UIColor *textDisableColor;
@property (nonatomic, strong) UIColor *textHighlightColor;

+ (instancetype)defaultConfig;

@end

#pragma - mark -

@interface ISpyPlaceHolderConfig : NSObject

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *frameColor;
@property (nonatomic, strong) UIColor *arrowColor;
@property (nonatomic, assign) CGFloat lineSize;

@property (nonatomic, assign) BOOL visible;
@property (nonatomic, assign) BOOL showArrow;
@property (nonatomic, assign) BOOL showFrame;
@property (nonatomic, assign) BOOL showSize;
//@property (nonatomic, assign) BOOL useInverseArrowColor;

+ (instancetype)defaultConfig;

@end