//
//  SelectionTypeViewController.m
//  Staches and Glasses
//
//  Created by yueling zhang on 5/13/13.
//  Copyright (c) 2013 yueling. All rights reserved.


//***************ABOUT this class*****************************
//this class provides two options to select photos
//--take a picture from camera or
//--choose a photo from camera roll
//************************************************************


#import "SelectionTypeViewController.h"
#import "EditViewController.h"

@interface SelectionTypeViewController ()

@end

@implementation SelectionTypeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)selectFormPhoto:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    // This line of code will generate 2 warnings right now, ignore them
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

- (IBAction)selectFromCamera:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No camera!" message:@"" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
        [alertView show];
    }
    
}

#pragma mark UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Access the uncropped image from info dictionary
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    // Dismiss controller
    [picker dismissViewControllerAnimated:YES completion:^{
        EditViewController *evc = [[self storyboard] instantiateViewControllerWithIdentifier:@"editViewController"];
        evc.theEditingImage = image;
        [self.navigationController pushViewController:evc animated:YES];
    }];

}

@end
