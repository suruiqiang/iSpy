//
//  ISpySystemInfo.h
//  iSpyDemo
//
//  Created by lslin on 15/11/30.
//  Copyright © 2015年 lessfun.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISpyMemoryInfo : NSObject

@property (nonatomic, assign) unsigned long long total;/**< B */
@property (nonatomic, assign) unsigned long long free;/**< B */
@property (nonatomic, assign) unsigned long long used;/**< B */
@property (nonatomic, assign) unsigned long long active;/**< B */
@property (nonatomic, assign) unsigned long long inactive;/**< B */
@property (nonatomic, assign) unsigned long long wired;/**< B */
@property (nonatomic, assign) unsigned long long purgable;/**< B */

@end

@interface ISpyNetworkInfo : NSObject

@property (nonatomic, assign) unsigned long long wifiSent;/**< B */
@property (nonatomic, assign) unsigned long long wiFiReceived;/**< B */
@property (nonatomic, assign) unsigned long long wwanSent;/**< B */
@property (nonatomic, assign) unsigned long long wwanReceived;/**< B */

- (void)reset;
- (void)updateWithNetworkInfo:(ISpyNetworkInfo *)netInfo;

@end

@interface ISpySystemInfo : NSObject

#pragma mark - CPU (%)

+ (double)cpuUsage;

#pragma mark - Memory (B)

+ (ISpyMemoryInfo *)memoryInfo;

#pragma mark - Network (B)

+ (ISpyNetworkInfo *)networkInfo;

#pragma mark - Helper

+ (NSString *)prettyFormatWithBytes:(unsigned long long)bytes;

@end
