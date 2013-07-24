//
//  EditViewController.h
//  Staches and Glasses
//
//  Created by yueling zhang on 5/12/13.
//  Copyright (c) 2013 yueling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "MBProgressHUD.h"
#import "PaintView.h"
#import "CoreImage/CoreImage.h"
#import "QuartzCore/QuartzCore.h"
#import "Social/Social.h"
#import "HMSideMenu.h"

@interface EditViewController : UIViewController<UIGestureRecognizerDelegate,MBProgressHUDDelegate>

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, assign) BOOL menuIsVisible;
@property (nonatomic, strong) HMSideMenu *myMenu;

@property (nonatomic, strong)UIImage *theEditingImage;
@property (nonatomic, strong)UIImage *resizedBigImage;
@property (nonatomic, strong)UIImage *resizedSmallImage;

@property (weak, nonatomic) IBOutlet UIImageView *editingImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewForFilters;


- (IBAction)menuButton:(id)sender;
- (IBAction)drawOnTheImage:(id)sender;
- (IBAction)saveToCameraRoll:(id)sender;
- (IBAction)detectFace:(id)sender;
- (IBAction)shareToFaceBook:(id)sender;
- (IBAction)shareToTwitter:(id)sender;
- (IBAction)backToHomeScreen:(id)sender;


//- (void)paintView:(PaintView*)paintView finishedTrackingPath:(CGPathRef)path inRect:(CGRect)painted;


@end
