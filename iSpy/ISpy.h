//
//  ISpy.h
//  iSpyDemo
//
//  Created by lslin on 15/11/25.
//  Copyright © 2015年 lessfun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISpyConfig.h"

#pragma - mark - 

@interface ISpy : NSObject

+ (instancetype)sharedObject;

/**
 *  Show iSpy button.
 */
- (void)show;

- (void)hide;

@end
