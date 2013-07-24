//
//  ViewController.m
//  Staches and Glasses
//
//  Created by yueling zhang on 5/12/13.
//  Copyright (c) 2013 yueling. All rights reserved.
//


//***************ABOUT this class*******************************
//this class is the default view page
//It shows all the pictures that stored in user's Parse account
//PS:For the first time, user should login Parse first
//**************************************************************


#import "ViewController.h"
#import "MyCustomCell.h"
#import "EditViewController.h"

@interface ViewController ()
@property (nonatomic, strong)UIButton *bigImageButton;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _storedImages = [[NSMutableArray alloc] init];
    self.allImages = [[NSMutableArray alloc] init];
    
    [self.myCollectionView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"back1.png"]]];
}

- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    
    if(![PFUser currentUser]){//NO user logged in
        PFLogInViewController *login = [[PFLogInViewController alloc] init];
        [login setDelegate:self];
        
        //create the sign up view controller
        PFSignUpViewController *signup = [[PFSignUpViewController alloc] init];
        [signup setDelegate:self];
        
        //Assign our sign up to be displayed from the login
        [login setSignUpController:signup];
        
        //present the login
        [self presentViewController:login animated:YES completion:nil];
    }else{
        [self downloadAllImages];
    }

    
}

- (IBAction)refreshButton:(id)sender {
    [self downloadAllImages];
    NSLog(@"refresh button was tapped.");
}

- (void)downloadAllImages
{
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhotos"];
    PFUser *user = [PFUser currentUser];
    
    [query whereKey:@"user" equalTo:user];
    [query orderByAscending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            // The find succeeded.
            if (_refreshHUD) {
                [_refreshHUD hide:YES];
                
                _refreshHUD = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:_refreshHUD];
                
                // The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
                // Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
                _refreshHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                
                // Set custom view mode
                _refreshHUD.mode = MBProgressHUDModeCustomView;
                
                _refreshHUD.delegate = self;
            }
            NSLog(@"Successfully retrieved %d photos.", objects.count);
     
            _allImages = [[NSMutableArray alloc] initWithArray:objects];
            
            // Remove and add from objects before this
            [self.myCollectionView reloadData];
        }else {
            [_refreshHUD hide:YES];
            
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }     
    }];
    
}


#pragma mark - UICollectionView Datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _allImages.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Returning cell %@", indexPath);
    MyCustomCell *myCustomCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"myCell" forIndexPath: indexPath];
    
    PFObject *eachObject = [_allImages objectAtIndex:indexPath.row];
    PFFile *theImage = [eachObject objectForKey:@"imageFile"];
    NSData *imageData = [theImage getData];
    UIImage *image = [UIImage imageWithData:imageData];
    
    myCustomCell.myImageView.image = image;
    myCustomCell.myImageView.userInteractionEnabled = YES;
    myCustomCell.userInteractionEnabled = YES;

    return myCustomCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"the %ith celled is selected!",indexPath.row);
    
    PFObject *eachObject = [_allImages objectAtIndex:indexPath.row];
    PFFile *theImage = [eachObject objectForKey:@"imageFile"];
    NSData *imageData = [theImage getData];
    UIImage *bigImage = [UIImage imageWithData:imageData];

    self.bigImageButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 60, 290, 290)];
    [self.bigImageButton setBackgroundImage:bigImage forState:UIControlStateNormal];
    [self.bigImageButton addTarget:self action:@selector(tapHandled:) forControlEvents:UIControlEventAllTouchEvents];
    
    [self.view addSubview: self.bigImageButton];
    self.myCollectionView.alpha = 0.2;
    self.myCollectionView.userInteractionEnabled = NO;
    
}

-(void)tapHandled:
(UITapGestureRecognizer *)tapRecognizer
{
    NSLog(@"The big image was tapped, so it need disappear!");
    self.bigImageButton.alpha = 0;
    self.myCollectionView.alpha = 1;
    self.myCollectionView.userInteractionEnabled = YES;
    
}


#pragma mark MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD hides
    [_HUD removeFromSuperview];
	_HUD = nil;
}

#pragma parse login delegate methods
// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma parse signup delegate methods
// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil]; // Dismiss the PFSignUpViewController
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}



@end
