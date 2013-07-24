//
//  PaintView.h
//  Staches and Glasses
//
//  Created by yueling zhang on 5/13/13.
//  Copyright (c) 2013 yueling. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PaintView;

////////////////////////////////////////////////////////////////////////////////
@protocol PaintViewDelegate <NSObject>
@required
- (void)paintView:(PaintView*)paintView finishedTrackingPath:(CGPathRef)path inRect:(CGRect)painted;
@end

////////////////////////////////////////////////////////////////////////////////
@interface PaintView : UIView
@property (nonatomic, assign) id <PaintViewDelegate> delegate;
@property (strong, nonatomic) UIColor *lineColor;

- (void)erase;
@end