//
//  ISpyStatsView.m
//  iSpyDemo
//
//  Created by lslin on 15/12/10.
//  Copyright © 2015年 lessfun.com. All rights reserved.
//

#import "ISpyStatsView.h"
#import "ISpyConfig.h"
#import "ISpySystemInfo.h"

#import "UIView+ISpyLayer.h"

@interface ISpyStatsView ()

@property (nonatomic, strong) UILabel *cpuLabel;
@property (nonatomic, strong) UILabel *memoryLabel;
@property (nonatomic, strong) UILabel *networkLabel;
@property (nonatomic, strong) NSTimer *updateTimer;

@end

@implementation ISpyStatsView

- (void)dealloc {
    [self stopUpdateTimer];
}

- (id)init {
    return [self initWithFrame:[ISpyViewConfig defaultConfig].statsViewFrame];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self defaultInit];
    }
    return self;
}

- (void)defaultInit {
    self.tag = kISpyViewTag;
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
                            | UIViewAutoresizingFlexibleBottomMargin;
                            self.backgroundColor = [UIColor clearColor];
    
    self.backgroundColor = [ISpyViewConfig defaultConfig].backgroundColor;
    [self is_setCornerRadius:4];
    
    CGRect labelFrame = CGRectMake(2, 2, CGRectGetWidth(self.bounds) - 2, 12);
    self.cpuLabel = [self addLabelWithFrame:labelFrame];
    labelFrame.origin.y += 12;
    self.memoryLabel = [self addLabelWithFrame:labelFrame];
    labelFrame.origin.y += 12;
    self.networkLabel = [self addLabelWithFrame:labelFrame];
    
    [self startUpdateTimer];
}

- (UILabel *)addLabelWithFrame:(CGRect)frame {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [ISpyViewConfig defaultConfig].textNormalColor;
    label.font = [UIFont systemFontOfSize:10];
    [self addSubview:label];
    return label;
}

- (void)startUpdateTimer {
    if (!self.updateTimer) {
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onUpdateTimeout) userInfo:nil repeats:YES];
        [self.updateTimer fire];
    }
}

- (void)stopUpdateTimer {
    if (self.updateTimer) {
        [self.updateTimer invalidate];
        self.updateTimer = nil;
    }
}

- (void)onUpdateTimeout {
    double cpu = [ISpySystemInfo cpuUsage];
    self.cpuLabel.text = [NSString stringWithFormat:@"Cpu: %.2f%%", cpu];
    
    ISpyMemoryInfo *memory = [ISpySystemInfo memoryInfo];
    self.memoryLabel.text = [NSString stringWithFormat:@"Mem: %@/%@", [ISpySystemInfo prettyFormatWithBytes:memory.used], [ISpySystemInfo prettyFormatWithBytes:memory.total]];
    
    ISpyNetworkInfo *network = [ISpySystemInfo networkInfo];
    self.networkLabel.text = [NSString stringWithFormat:@"Net: %@↑, %@↓", [ISpySystemInfo prettyFormatWithBytes:(network.wifiSent + network.wwanSent)], [ISpySystemInfo prettyFormatWithBytes:(network.wiFiReceived + network.wwanReceived)]];
}

@end
