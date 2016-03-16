//
//  ISpyConfig.m
//  iSpyDemo
//
//  Created by lslin on 15/11/27.
//  Copyright © 2015年 lessfun.com. All rights reserved.
//

#import "ISpyConfig.h"

@implementation ISpyViewConfig

+ (instancetype)defaultConfig {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        _entryViewFrame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 56) / 2.0, 20, 56, 24);
        _statsViewFrame = CGRectMake([UIScreen mainScreen].bounds.size.width - 128 - 2, 20, 128, 40);
        _moreViewFrame = CGRectMake(10, 64, [UIScreen mainScreen].bounds.size.width - 10 * 2, [UIScreen mainScreen].bounds.size.height - 64 * 2);
        
        _backgroundColor = ISpyColorRGBA(0, 0, 0, 0.5);
        _textNormalColor = ISpyColorRGB(245, 245, 245);
        _textDisableColor = ISpyColorRGB(221, 221, 221);
        _textHighlightColor = ISpyColorRGB(81, 205, 91);
    }
    return self;
}

@end

@implementation ISpyPlaceHolderConfig

+ (instancetype)defaultConfig {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        _backgroundColor = ISpyColorRGBA(0, 0, 0, 0.0);
        _frameColor = ISpyColorRGB(255, 0, 0);
        _arrowColor = ISpyColorRGB(204, 0, 143);
        _lineSize = MIN(0.5, 1 / [UIScreen mainScreen].scale);
        
        _visible = YES;
        _showFrame = YES;
        _showArrow = YES;
        _showSize = YES;
    }
    return self;
}

@end
