//
//  ISpyViewTreeScanner.h
//  iSpyDemo
//
//  Created by lslin on 16/3/10.
//  Copyright © 2016年 lessfun.com. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kISpyViewDescKeyView;
extern NSString * const kISpyViewDescKeyClass;
extern NSString * const kISpyViewDescKeyID;
extern NSString * const kISpyViewDescKeyProps;
extern NSString * const kISpyViewDescKeySubviews;

extern NSString * const kISpyViewPropKeyName;
extern NSString * const kISpyViewPropKeyProps;

extern NSString * const kISpyViewPropValueKeyName;
extern NSString * const kISpyViewPropValueKeyType;
extern NSString * const kISpyViewPropValueKeyValue;

@interface ISpyViewTreeScanner : NSObject

/**
 *  Get all views and properties
 *
 *  @return NSArray<Dict<obj : ISpyViewDummy, class : NSString, id : NSString, views : NSArray, props : NSArray>, ...>
 */
+ (NSArray *)allWindowViewProperties;

/**
 *  Get properties of view
 *
 *  @param view
 *
 *  @return Dict<obj : ISpyViewDummy, class : NSString, id : NSString, views : NSArray, props : NSArray>
 */
+ (NSDictionary *)propertiesWithView:(UIView *)view;

/**
 *  Find view by pointer value
 *
 *  @param Id pointer value
 *
 *  @return view
 */
+ (UIView *)viewWithId:(long)Id;

/**
 *  Get view in dummy obj from properties
 *
 *  @param properties
 *
 *  @return view
 */
+ (UIView *)viewForProperties:(NSDictionary *)properties;

/**
 *  Get class name from properties
 *
 *  @param properties
 *
 *  @return name
 */
+ (NSString *)classNameForProperties:(NSDictionary *)properties;

+ (long)idForProperties:(NSDictionary *)properties;

/**
 *  Get props from properties
 *
 *  @param properties
 *
 *  @return NSArray<Dict<name : string, props : array<Dict<name, type, value>, Dict<name, type, value>>>, Dict<key, array>, ...>
 */
+ (NSArray *)propsForProperties:(NSDictionary *)properties;

/**
 *  Get subviews from properties
 *
 *  @param properties
 *
 *  @return NSArray<Dict<obj : ISpyViewDummy, class : NSString, id : NSString, views : NSArray, props : NSArray>, ...>
 */
+ (NSArray *)subviewsForProperties:(NSDictionary *)properties;

+ (id)valueWithType:(NSString *)type valueString:(NSString *)valueStr;

@end
