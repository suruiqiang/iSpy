//
//  ISpyMoreView.m
//  iSpyDemo
//
//  Created by lslin on 15/12/24.
//  Copyright © 2015年 lessfun.com. All rights reserved.
//

#import "ISpyMoreView.h"
#import "ISpyConfig.h"
#import "ISpyTreeView.h"

#import "UIView+ISpyLayer.h"

@interface ISpyMoreView ()

@property (strong, nonatomic) ISpyTreeView *treeView;

@end

@implementation ISpyMoreView

- (id)init {
    return [self initWithFrame:[ISpyViewConfig defaultConfig].moreViewFrame];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self defaultInit];
    }
    return self;
}

- (void)defaultInit {
    self.tag = kISpyViewTag;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth
                            | UIViewAutoresizingFlexibleHeight;
    
    self.backgroundColor = [ISpyViewConfig defaultConfig].backgroundColor;
    [self is_setCornerRadius:4];
    
    [self addSegmentControl];
    [self addTabViews];
}

- (void)addSegmentControl {
    UISegmentedControl *segmented = [[UISegmentedControl alloc] initWithItems:@[@"Views", @"Hosts(TODO)", @"Command(TODO)"]];
    segmented.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    segmented.frame = CGRectMake(0, 0, self.frame.size.width, 30);
    segmented.tintColor = [UIColor whiteColor];
    segmented.selectedSegmentIndex = 0;
    [segmented addTarget:self action:@selector(onSegmentControlChanged:) forControlEvents: UIControlEventValueChanged];
    [self addSubview:segmented];
}

- (void)addTabViews {
    [self addTreeView];
    //TODO:
}

#pragma mark - Action

- (void)onSegmentControlChanged:(UISegmentedControl *)segmented {
    switch (segmented.selectedSegmentIndex) {
        case 0:
            break;
            
        default:
            break;
    }
}

#pragma mark - Private 

- (void)addTreeView {
    if (!self.treeView) {
        self.treeView = [[ISpyTreeView alloc] initWithFrame:CGRectMake(0, 30, self.frame.size.width, self.frame.size.height - 30)];
        [self addSubview:self.treeView];
    }
}

@end
