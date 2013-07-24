//
//  SelectionTypeViewController.h
//  Staches and Glasses
//
//  Created by yueling zhang on 5/13/13.
//  Copyright (c) 2013 yueling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectionTypeViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationBarDelegate>

- (IBAction)selectFormPhoto:(id)sender;
- (IBAction)selectFromCamera:(id)sender;


@end
