//
//  ISpyView.m
//  iSpyDemo
//
//  Created by lslin on 15/11/27.
//  Copyright © 2015年 lessfun.com. All rights reserved.
//

#import "ISpyView.h"
#import "ISpyConfig.h"
#import "ISpyStatsView.h"
#import "ISpyMoreView.h"

#import "UIView+ISpyPlaceHolder.h"
#import "UIView+ISpyLayer.h"

static const CGFloat kISpyMenuHeight = 32;
static const CGFloat kISpyLineHeight = 0.5;

@interface ISpyView ()

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) ISpyStatsView *statsView;
@property (nonatomic, strong) ISpyMoreView *moreView;

@end

@implementation ISpyView

- (id)init {
    return [self initWithFrame:[ISpyViewConfig defaultConfig].entryViewFrame];
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
                            | UIViewAutoresizingFlexibleRightMargin
                            | UIViewAutoresizingFlexibleTopMargin
                            | UIViewAutoresizingFlexibleBottomMargin;
    self.backgroundColor = [UIColor clearColor];
    
    self.topView = [[UIView alloc] initWithFrame:self.bounds];
    self.topView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.topView];
    
    UIButton *entryButton = [[UIButton alloc] initWithFrame:self.topView.bounds];
    entryButton.backgroundColor = [UIColor clearColor];
    entryButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [entryButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [entryButton setTitle:@"iSpy" forState:UIControlStateNormal];
    [entryButton is_setCornerRadius:4 borderWidth:1 / [UIScreen mainScreen].scale borderColor:[UIColor darkGrayColor]];
    [entryButton addTarget:self action:@selector(onEntryButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:entryButton];
    
    NSArray *menus = @[@"Frame", @"Stats", @"More"];
    CGFloat entryWidth = CGRectGetWidth(self.bounds);
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds), entryWidth, menus.count * kISpyMenuHeight + (menus.count - 1) * kISpyLineHeight)];
    self.bottomView.backgroundColor = [ISpyViewConfig defaultConfig].backgroundColor;
    [self.bottomView is_setCornerRadius:2];
    self.bottomView.hidden = YES;
    [self addSubview:self.bottomView];
    
    // Add menu buttons
    CGRect frame = CGRectMake(0, 0, entryWidth, kISpyMenuHeight);
    for (int i = 0; i < menus.count; ++ i) {
        UIButton *btn = [[UIButton alloc] initWithFrame:frame];
        btn.tag = i;
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[ISpyViewConfig defaultConfig].textNormalColor forState:UIControlStateHighlighted];
        [btn setTitleColor:[ISpyViewConfig defaultConfig].textHighlightColor forState:UIControlStateSelected];
        [btn setTitle:menus[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onMenuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:btn];
        
        frame.origin.y += kISpyMenuHeight;
        if (i < menus.count - 1) {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, frame.origin.y, entryWidth, kISpyLineHeight)];
            line.backgroundColor = ISpyColorRGBA(245, 245, 245, 0.8);
            [self.bottomView addSubview:line];
        }
        frame.origin.y += kISpyLineHeight;
    }
}

#pragma mark - Action

- (void)onEntryButtonClicked:(UIButton *)sender {
    [self setBottomViewHidden:!self.bottomView.hidden];
}

- (void)onMenuButtonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case 0: {
            sender.selected = !sender.selected;
            if (sender.selected) {
                [self is_setupSwizzled];
                [[UIApplication sharedApplication].delegate.window is_showPlaceHolderWithAllSubviews];
            } else {
                [self is_undoSwizzled];
                [[UIApplication sharedApplication].delegate.window is_hidePlaceHolderWithAllSubviews];
            }
            break;
        }
        case 1: {
            sender.selected = !sender.selected;
            if (sender.selected) {
                self.statsView = [ISpyStatsView new];
                [[UIApplication sharedApplication].delegate.window addSubview:self.statsView];
            } else {
                [self.statsView removeFromSuperview];
            }
            break;
        }
        case 2: {
            sender.selected = !sender.selected;
            if (sender.selected) {
                self.moreView = [ISpyMoreView new];
                [[UIApplication sharedApplication].delegate.window insertSubview:self.moreView belowSubview:self];
            } else {
                [self.moreView removeFromSuperview];
            }
            break;
        }
        default:
            break;
    }
    [self setBottomViewHidden:!self.bottomView.hidden];
}

#pragma mark - Private

- (void)setBottomViewHidden:(BOOL)hidden {
    CGRect newFrame = self.frame;
    
    CGFloat bottomHeight = self.bottomView.frame.size.height;
    newFrame.size.height += hidden ? (- bottomHeight) : (bottomHeight);
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = newFrame;
    } completion:^(BOOL finished) {
        self.bottomView.hidden = hidden;
    }];
}

@end
