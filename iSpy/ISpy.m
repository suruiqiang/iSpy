//
//  ISpy.m
//  iSpyDemo
//
//  Created by lslin on 15/11/25.
//  Copyright © 2015年 lessfun.com. All rights reserved.
//

#import "ISpy.h"
#import "ISpyView.h"

@interface ISpy ()

@property (nonatomic, strong) ISpyView *spyView;

@end

@implementation ISpy

+ (instancetype)sharedObject {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (id)init {
    if (self = [super init]) {

    }
    return self;
}

- (void)show {
    if (!self.spyView) {
        self.spyView = [ISpyView new];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[[UIApplication sharedApplication].delegate window] addSubview:self.spyView];
        });
    }
    self.spyView.hidden = NO;
}

- (void)hide {
    self.spyView.hidden = YES;
}

@end
