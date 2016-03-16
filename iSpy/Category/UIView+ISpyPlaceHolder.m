//
//  UIView+ISpyPlaceHolder.m
//  iSpyDemo
//
//  Created by lslin on 15/11/ 2.07.
//  Copyright © 2015年 lessfun.com. All rights reserved.
//

#import "UIView+ISpyPlaceHolder.h"
#import "ISpyConfig.h"

#import <objc/runtime.h>

static void *kISpyViewKeyHighlight;

/**
 * Show view's frame border and size
 */
@interface ISpyPlaceHolderView : UIView

@end

@implementation ISpyPlaceHolderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.tag = kISpyPlaceHolderViewTag;
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                UIViewAutoresizingFlexibleWidth      |
                                UIViewAutoresizingFlexibleRightMargin|
                                UIViewAutoresizingFlexibleTopMargin  |
                                UIViewAutoresizingFlexibleHeight     |
                                UIViewAutoresizingFlexibleBottomMargin;
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeRedraw;
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    CGFloat centerX = width / 2.0;
    CGFloat centerY = height / 2.0;
    
    CGFloat fontSize = MIN(width, height) / 10.0;
    fontSize = MAX(6, fontSize);
    fontSize = MIN(fontSize, 30);
    CGFloat arrowSize = fontSize / 2.0;
    CGFloat lineWidth = [ISpyPlaceHolderConfig defaultConfig].lineSize;
    
    // Background
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [ISpyPlaceHolderConfig defaultConfig].backgroundColor.CGColor);
    CGContextSetLineJoin(ctx, kCGLineJoinMiter);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextFillRect(ctx, rect);
    
    // Frame
    if ([ISpyPlaceHolderConfig defaultConfig].showFrame) {
        CGContextSetLineWidth(ctx, lineWidth);
        CGContextSetStrokeColorWithColor(ctx, [ISpyPlaceHolderConfig defaultConfig].frameColor.CGColor);
        
        CGContextMoveToPoint(ctx, 0, 0);
        CGContextAddLineToPoint(ctx, 0, height);
        CGContextAddLineToPoint(ctx, width - lineWidth, height);
        CGContextAddLineToPoint(ctx, width - lineWidth, 0);
        CGContextAddLineToPoint(ctx, 0, 0);
        CGContextClosePath(ctx);
        
        CGContextStrokePath(ctx);
    }
    
    // Arrow
    if ([ISpyPlaceHolderConfig defaultConfig].showArrow) {
        CGContextSetLineWidth(ctx, lineWidth);
        CGContextSetStrokeColorWithColor(ctx, [ISpyPlaceHolderConfig defaultConfig].arrowColor.CGColor);
        
        CGFloat radius = lineWidth / 2.0 * 3;
        CGContextMoveToPoint(ctx, centerX, radius);
        CGContextAddLineToPoint(ctx, centerX, height-radius);
        CGContextMoveToPoint(ctx, centerX, radius);
        CGContextAddLineToPoint(ctx, centerX - arrowSize, arrowSize + radius);
        CGContextMoveToPoint(ctx, centerX, radius);
        CGContextAddLineToPoint(ctx, centerX + arrowSize, arrowSize + radius);
        CGContextMoveToPoint(ctx, centerX, height-radius);
        CGContextAddLineToPoint(ctx, centerX - arrowSize, height - arrowSize - radius);
        CGContextMoveToPoint(ctx, centerX, height-radius);
        CGContextAddLineToPoint(ctx, centerX + arrowSize, height - arrowSize - radius);
        
        CGContextMoveToPoint(ctx, radius, centerY);
        CGContextAddLineToPoint(ctx, width - radius, centerY);
        CGContextMoveToPoint(ctx, radius, centerY);
        CGContextAddLineToPoint(ctx, arrowSize + radius, centerY - arrowSize);
        CGContextMoveToPoint(ctx, radius, centerY);
        CGContextAddLineToPoint(ctx, arrowSize + radius, centerY + arrowSize);
        CGContextMoveToPoint(ctx, width - radius, centerY);
        CGContextAddLineToPoint(ctx, width - arrowSize - radius, centerY - arrowSize);
        CGContextMoveToPoint(ctx, width - radius, centerY);
        CGContextAddLineToPoint(ctx, width - arrowSize - radius, centerY + arrowSize);
        
        CGContextStrokePath(ctx);
    }
    
    // Text
    if ([ISpyPlaceHolderConfig defaultConfig].showSize) {
        // Calculate the text area
        NSString *text = [NSString stringWithFormat:@"%.0f X %.0f",width, height];
        
        UIColor *color = [ISpyPlaceHolderConfig defaultConfig].arrowColor;
//        if ([ISpyPlaceHolderConfig defaultConfig].useInverseArrowColor && self.superview) {
//            [self reverseColorOf:self.superview.backgroundColor];
//        }
        
        NSShadow *shadow = [[NSShadow alloc] init];
        [shadow setShadowColor:[self reverseColorOf:color]];
        [shadow setShadowOffset:CGSizeMake (0.5, 0.5)];
        [shadow setShadowBlurRadius:0.5];
        NSDictionary *textFontAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize],
                                             NSForegroundColorAttributeName: color,
                                             NSShadowAttributeName : shadow
                                             };
        
        CGSize textSize = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:textFontAttributes context:nil].size;
        
        CGFloat rectWidth = ceilf(textSize.width) + 4;
        CGFloat rectHeight = ceilf(textSize.height) + 4;
        
        // Clear the area behind the textz
        CGRect textRect = CGRectMake(centerX - rectWidth / 2.0, centerY - rectHeight / 2.0, rectWidth, rectHeight);
        CGContextClearRect(ctx, textRect);
        CGContextSetFillColorWithColor(ctx, [ISpyPlaceHolderConfig defaultConfig].backgroundColor.CGColor);
        CGContextFillRect(ctx, textRect);
        
        // Draw text
        CGContextSetFillColorWithColor(ctx, [ISpyPlaceHolderConfig defaultConfig].arrowColor.CGColor);
        [text drawInRect:CGRectInset(textRect, 0, 2) withAttributes:textFontAttributes];
    }
}

#pragma mark - Private

- (UIColor *)reverseColorOf:(UIColor *)oldColor {
    if (!oldColor) {
        return [UIColor greenColor];
    }
    CGColorRef oldCGColor = oldColor.CGColor;
    
    int numberOfComponents = (int)CGColorGetNumberOfComponents(oldCGColor);
    // Can not invert - the only component is the alpha
    if (numberOfComponents == 1) {
        return [UIColor colorWithCGColor:oldCGColor];
    }
    
    const CGFloat *oldComponentColors = CGColorGetComponents(oldCGColor);
    CGFloat newComponentColors[numberOfComponents];
    
    int i = numberOfComponents - 1;
    newComponentColors[i] = oldComponentColors[i]; // alpha
    while (--i >= 0) {
        newComponentColors[i] = 1 - oldComponentColors[i];
    }
    
    CGColorRef newCGColor = CGColorCreate(CGColorGetColorSpace(oldCGColor), newComponentColors);
    UIColor *newColor = [UIColor colorWithCGColor:newCGColor];
    CGColorRelease(newCGColor);
    
    // For the GRAY colors 'Middle level colors'
    CGFloat white = 0;
    [oldColor getWhite:&white alpha:nil];
    
    if (white>0.45 && white < 0.55) {
        if (white >= 0.5) {
            newColor = [UIColor darkGrayColor];
        } else if (white < 0.5) {
            newColor = [UIColor blackColor];
        }
    }
    return newColor;
}

@end

#pragma mark - UIView (ISpyPlaceHolder)

@implementation UIView (ISpyPlaceHolder)

- (void)is_showPlaceHolder {
    if (CGRectGetWidth(self.bounds) < 5 || CGRectGetHeight(self.bounds) < 5) {
        //Too small, ignore
        return;
    }
    
    ISpyPlaceHolderView *placeHolder = [self placeHolderView];
    if (!placeHolder) {
        placeHolder = [[ISpyPlaceHolderView alloc] initWithFrame:self.bounds];
        [self addSubview:placeHolder];
    }
    placeHolder.hidden = NO;
}

- (void)is_showPlaceHolderWithAllSubviews {
    if (self.tag != kISpyViewTag && self.tag != kISpyPlaceHolderViewTag) {
        [self is_showPlaceHolder];
        if (![self isKindOfClass:[UIButton class]]) {
            for (UIView *view in self.subviews) {
                [view is_showPlaceHolderWithAllSubviews];
            }
        }
    }
}

- (void)is_hidePlaceHolder {
    ISpyPlaceHolderView *placeHolder = [self placeHolderView];
    if (placeHolder) {
        placeHolder.hidden = YES;
    }
}

- (void)is_hidePlaceHolderWithAllSubviews {
    [self is_hidePlaceHolder];
    for (UIView *view in self.subviews) {
        [view is_hidePlaceHolderWithAllSubviews];
    }
}

- (void)is_highlightBorder {
    if ([self isHighlighting]) {
        return;
    }
    [self setIsHighlighting:YES];
    
    CGColorRef oldColor = self.layer.borderColor;
    CGFloat oldWidth = self.layer.borderWidth;

    self.layer.borderColor = [UIColor redColor].CGColor;
    self.layer.borderWidth = 2;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.layer.borderColor = oldColor;
        self.layer.borderWidth = oldWidth;
        [self setIsHighlighting:NO];
    });
}

#pragma mark - Property

- (ISpyPlaceHolderView *)placeHolderView {
    return (ISpyPlaceHolderView *)[self viewWithTag:kISpyPlaceHolderViewTag];
}

- (BOOL)isHighlighting {
    NSNumber *result = objc_getAssociatedObject(self, &kISpyViewKeyHighlight);
    return [result boolValue];
}

- (void)setIsHighlighting:(BOOL)highlight {
    objc_setAssociatedObject(self, &kISpyViewKeyHighlight, @(highlight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Swizzled

- (void)is_setupSwizzled {
    Method original, swizzle;
    
    // Get the "- (id)initWithFrame:" method.
    original = class_getInstanceMethod([self class], @selector(initWithFrame:));
    // Get the "- (id)swizzled_initWithFrame:" method.
    swizzle = class_getInstanceMethod([self class], @selector(swizzledInitWithFrame:));
    // Swap their implementations.
    method_exchangeImplementations(original, swizzle);
    
    // Get the "- (id)initWithCoder:" method.
    original = class_getInstanceMethod([UIView class], @selector(initWithCoder:));
    // Get the "- (id)swizzled_initWithCoder:" method.
    swizzle = class_getInstanceMethod([UIView class], @selector(swizzledInitWithCoder:));
    // Swap their implementations.
    method_exchangeImplementations(original, swizzle);
}

- (void)is_undoSwizzled {
    [self is_setupSwizzled];//swizzle again
}

- (id)swizzledInitWithFrame:(CGRect)frame {
    id result = [self swizzledInitWithFrame:frame];
    
    [result is_showPlaceHolder];
    
    // Return the modified view.
    return result;
}

- (id)swizzledInitWithCoder:(NSCoder *)aDecoder {
    id result = [self swizzledInitWithCoder:aDecoder];
    
    [self is_showPlaceHolder];
    
    // Return the modified view.
    return result;
}

@end