//
//  ViewController.h
//  Staches and Glasses
//
//  Created by yueling zhang on 5/12/13.
//  Copyright (c) 2013 yueling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "MBProgressHUD.h"
#include "stdlib.h"

@interface ViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UINavigationControllerDelegate,MBProgressHUDDelegate,PFLogInViewControllerDelegate,PFSignUpViewControllerDelegate,UIGestureRecognizerDelegate>

@property (strong, nonatomic)NSMutableArray *allImages;
@property (strong, nonatomic)NSMutableArray *storedImages;
@property (strong, nonatomic)MBProgressHUD *HUD;
@property (strong, nonatomic)MBProgressHUD *refreshHUD;



@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;

- (IBAction)refreshButton:(id)sender;


@end
