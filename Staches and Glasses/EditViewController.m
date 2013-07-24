//
//  EditViewController.m
//  Staches and Glasses
//
//  Created by yueling zhang on 5/12/13.
//  Copyright (c) 2013 yueling. All rights reserved.
//


//***************ABOUT this class*****************************
//this class shows editing photos view page
//A user can add different filters to the photo,
//also draw on the photo
//Besides, there're fancy buttons,
//providing several functions, such as sharing, saving,
//staches&glasses(face detection), etc.
//************************************************************


#import "EditViewController.h"
#import "ViewController.h"

@interface EditViewController ()

@property (strong, nonatomic)UIImage *originSmallImage;
@property (strong, nonatomic)UIImage *sepiaToneSmallImage;
@property (strong, nonatomic)UIImage *blackWhiteSmallImage;
@property (strong, nonatomic)UIImage *exposureSmallImage;
@property (strong, nonatomic)UIImage *orignImage;
@property (strong, nonatomic)UIImage *sepiaToneImage;
@property (strong, nonatomic)UIImage *blackWhiteImage;
@property (strong, nonatomic)UIImage *exposureImage;

@property (strong, nonatomic)UIImageView *detectedImageView;
@property (strong, nonatomic)UIImage *savedImage;

@property BOOL shouldMerge;
@property BOOL isSaved;
@property BOOL isDetected;
@property (strong, nonatomic) PaintView *paintView;
@property (strong, nonatomic) UIImageView *backgroundView;

@property (strong, nonatomic) NSNumber *leftEyeX;
@property (strong, nonatomic) NSNumber *leftEyeY;
@property (strong, nonatomic) NSNumber *rightEyeX;
@property (strong, nonatomic) NSNumber *rightEyeY;
@property (strong, nonatomic) NSNumber *mouthX;
@property (strong, nonatomic) NSNumber *mouthY;
@property (strong, nonatomic) NSNumber *theRadius;
@property float width;
@property float height;

@end

@implementation EditViewController

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
    [[self navigationController] setNavigationBarHidden:YES];
    
    [self setMenuButtons];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self showEdditingImage];
    [self showScrollView];
}

- (IBAction)menuButton:(id)sender {
    if (self.myMenu.isOpen) {
        [self.myMenu close];
    }
    else{
        [self.myMenu open];
    }
}

#pragma mark show the big editing image
- (void)showEdditingImage
{
    self.editingImageView.frame = CGRectMake(10, 10, 300, 300);
    self.editingImageView.userInteractionEnabled = YES;
    self.resizedBigImage = [self resizeToBigImage:self.theEditingImage];
    self.editingImageView.image = self.resizedBigImage;
    NSLog(@"show editing image view 's image size : %f",self.editingImageView.image.size.width);
    NSLog(@"show resize big image : %f",self.resizedBigImage.size.width);
    
    //Add paint view to editing image view as a subview
    CGRect bounds = CGRectMake(0, 0, 300, 300);
    _paintView = [[PaintView alloc] initWithFrame:bounds];
    [self.editingImageView addSubview:self.paintView];
    self.paintView.userInteractionEnabled = NO;
}

#pragma mark show scroll view
- (void)showScrollView
{
    self.scrollViewForFilters.contentSize = CGSizeMake(370,70);
    self.scrollViewForFilters.frame = CGRectMake(10, 320, 300, 70);
    self.scrollViewForFilters.bounces = NO;
    
    UIButton *button;
    UIImageView *imageView = [[UIImageView alloc] init];
    
    self.resizedSmallImage = [self resizeToSmallImage:self.resizedBigImage];
    
    for (int i = 0; i < 4; i++) {
        
        button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setFrame:CGRectMake(70*i+(i*5), 0, 70, 70)];
        [button setTag:i];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchDown];
        
        if (i == 0) {
            self.originSmallImage = self.resizedSmallImage;
            imageView = [[UIImageView alloc] initWithImage:self.originSmallImage]; 
        }
        else if (i == 1){
            
            self.sepiaToneSmallImage = [self sepiaToneFilter:self.resizedSmallImage];
            imageView = [[UIImageView alloc] initWithImage:self.sepiaToneSmallImage];
        }
        else if (i == 2){
            self.blackWhiteSmallImage = [self blackWhiteFilter:self.resizedSmallImage];
            imageView = [[UIImageView alloc] initWithImage:self.blackWhiteSmallImage];
        }
        else if (i == 3){
            self.exposureSmallImage = [self exposureFilter:self.resizedSmallImage];
            imageView = [[UIImageView alloc] initWithImage:self.exposureSmallImage];
        }
        
        imageView.frame = CGRectMake(0, 0, 70, 70);
        [button addSubview:imageView];
        
        [self.scrollViewForFilters addSubview:button];
        
    }//end for
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFilterEffect:)];
    [self.scrollViewForFilters addGestureRecognizer:tapRecognizer];

}

#pragma mark filter effect
- (UIImage *)sepiaToneFilter:(UIImage *)imageBeforeFilter
{
    CIImage *beginImage = [CIImage imageWithCGImage:[imageBeforeFilter CGImage]];
    CIContext *context = [CIContext contextWithOptions:nil];
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"
                                  keysAndValues: kCIInputImageKey, beginImage,
                        @"inputIntensity", [NSNumber numberWithFloat:0.8], nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];

    UIImage *imageAfterFilter = [UIImage imageWithCGImage:cgimg];
    return imageAfterFilter;
}

- (UIImage *)blackWhiteFilter:(UIImage *)imageBeforeFilter
{
    CIImage *beginImage = [CIImage imageWithCGImage:[imageBeforeFilter CGImage]];
    CIContext *context = [CIContext contextWithOptions:nil];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorMonochrome" keysAndValues:kCIInputImageKey, beginImage, @"inputIntensity", [NSNumber numberWithFloat:1.0], @"inputColor", [[CIColor alloc] initWithColor:[UIColor whiteColor]], nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *imageAfterFilter = [UIImage imageWithCGImage:cgimg];
    return imageAfterFilter;
}

- (UIImage *)exposureFilter:(UIImage *)imageBeforeFilter
{
    CIImage *beginImage = [CIImage imageWithCGImage:[imageBeforeFilter CGImage]];
    CIContext *context = [CIContext contextWithOptions:nil];
    CIFilter *filter = [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues: kCIInputImageKey, beginImage, @"inputEV", [NSNumber numberWithFloat:1.0], nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *imageAfterFilter = [UIImage imageWithCGImage:cgimg];
    return imageAfterFilter;
}

#pragma mark filter button tapped
- (IBAction)buttonTapped:(UIButton *)sender {
    
    NSLog(@"The Button was Tapped.");
    UIButton *button = (UIButton *)sender;
    NSUInteger tag = button.tag;
    
    if (tag == 0) {
        self.editingImageView.image = self.resizedBigImage;
    }
    else if (tag == 1){
        self.editingImageView.image = [self sepiaToneFilter:self.resizedBigImage];
    }else if (tag == 2){
        self.editingImageView.image = [self blackWhiteFilter:self.resizedBigImage];
    }else if (tag == 3){
        self.editingImageView.image = [self exposureFilter:self.resizedBigImage];
    }
    
}

#pragma mark show filter effect
- (void)showFilterEffect:(UITapGestureRecognizer *)recognizer
{
    
    if (self.detectedImageView.tag == 0) {
        self.editingImageView.image = self.orignImage;
        NSLog(@"did show origin image.");
    }
    else if(self.detectedImageView.tag == 1){
        self.editingImageView.image = self.sepiaToneImage;
        NSLog(@"did show sepia image.");
    }
    else if(self.detectedImageView.tag == 2){
        self.editingImageView.image = self.blackWhiteImage;
        NSLog(@"did show black white image.");
    }
}

#pragma mark resize images
- (UIImage *)resizeToBigImage:(UIImage *)originImage
{
    UIGraphicsBeginImageContext(CGSizeMake(300, 300));
    [originImage drawInRect: CGRectMake(0, 0, 300, 300)];
    UIImage *bigImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return bigImage;
}

- (UIImage *)resizeToSmallImage:(UIImage *)originImage
{
    UIGraphicsBeginImageContext(CGSizeMake(70, 70));
    [originImage drawInRect: CGRectMake(0, 0, 70, 70)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return smallImage;
}

#pragma mark - set menu buttons
- (void)setMenuButtons
{
    UIButton *drawButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [drawButton addTarget:self action:@selector(drawOnTheImage:) forControlEvents:UIControlEventTouchDown];
    UIImageView *drawIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [drawIcon setImage:[UIImage imageNamed:@"draw"]];
    [drawButton addSubview:drawIcon];
    
    UIButton *stachesButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [stachesButton addTarget:self action:@selector(detectFace:) forControlEvents:UIControlEventTouchDown];
    UIImageView *stachesIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [stachesIcon setImage:[UIImage imageNamed:@"staches"]];
    [stachesButton addSubview:stachesIcon];
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [saveButton addTarget:self action:@selector(saveToCameraRoll:) forControlEvents:UIControlEventTouchDown];
    UIImageView *saveIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [saveIcon setImage:[UIImage imageNamed:@"save"]];
    [saveButton addSubview:saveIcon];
    
    UIButton *facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [facebookButton addTarget:self action:@selector(shareToFaceBook:) forControlEvents:UIControlEventTouchDown];
    UIImageView *facebookIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [facebookIcon setImage:[UIImage imageNamed:@"facebook"]];
    [facebookButton addSubview:facebookIcon];
    
    UIButton *twitterButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [twitterButton addTarget:self action:@selector(shareToTwitter:) forControlEvents:UIControlEventTouchDown];
    UIImageView *twitterIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [twitterIcon setImage:[UIImage imageNamed:@"twitter"]];
    [twitterButton addSubview:twitterIcon];
    
    UIButton *homeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [homeButton addTarget:self action:@selector(backToHomeScreen:) forControlEvents:UIControlEventTouchDown];
    UIImageView *homeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [homeIcon setImage:[UIImage imageNamed:@"home"]];
    [homeButton addSubview:homeIcon];
    
    self.myMenu = [[HMSideMenu alloc] initWithItems:@[homeButton,drawButton,stachesButton,facebookButton,twitterButton,saveButton]];
    [self.myMenu setItemSpacing:5.0f];
    [self.view addSubview:self.myMenu];
    
}

#pragma mark - save to camera roll
- (IBAction)saveToCameraRoll:(id)sender {
    self.isSaved = YES;
    self.paintView.userInteractionEnabled = NO;

    // Save the image to the photolibrary in the background
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIGraphicsBeginImageContext(self.editingImageView.bounds.size);
        [self.editingImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
        self.savedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageWriteToSavedPhotosAlbum(self.savedImage, nil, nil, nil);

        NSData *data = UIImagePNGRepresentation(self.savedImage);

        dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"\n>>>>> Done saving in background...");//update UI here
        UIAlertView *screenAlert = [[UIAlertView alloc] initWithTitle:@"Image Saved!" message:@"The cute image is saved to your photo library and uploading to Parse." delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
            [screenAlert show];
           
            [self uploadImage:data];
        });
    });
}

- (void)uploadImage:(NSData *)imageData
{
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
    
    _HUD = [[MBProgressHUD alloc] init];
    [self.scrollViewForFilters addSubview:_HUD];

    // Set determinate mode
    _HUD.mode = MBProgressHUDModeDeterminate;
    _HUD.delegate = self;
    _HUD.labelText = @"Uploading to Parse.";
    [_HUD show:YES];
    
    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            //Hide determinate HUD
            [_HUD hide:YES];
            
            // Show checkmark
            _HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.editingImageView addSubview:_HUD];
            
            // The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
            // Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
            _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            
            // Set custom view mode
            _HUD.mode = MBProgressHUDModeCustomView;
            _HUD.delegate = self;
            
            // Create a PFObject around a PFFile and associate it with the current user
            PFObject *userPhoto = [PFObject objectWithClassName:@"UserPhotos"];
            [userPhoto setObject:imageFile forKey:@"imageFile"];

            // Set the access control list to current user for security purposes
//            userPhoto.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
           
            PFUser *user = [PFUser currentUser];
            [userPhoto setObject:user forKey:@"user"];

            [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
            
        }
        else{
            [_HUD hide:YES];
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    
    } progressBlock:^(int percentDone) {
        // Update your progress spinner here. percentDone will be between 0 and 100.
        _HUD.progress = (float)percentDone/100;
    }];
     
}

#pragma mark - Face Detection
- (IBAction)detectFace:(id)sender {
    if (self.isDetected == YES) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Already add glasses and staches!" message:@"" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
        [alertView show];
    }else{
        self.isDetected = YES;
        [self findFaces:self.editingImageView];
    }
}

/*******************************************************************************
 * @method          drawOnFaces:
 * @abstract
 * @description
 ******************************************************************************/
-(void)findFaces:(UIImageView *)imageView
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        CIImage *image = [[CIImage alloc] initWithImage:imageView.image];
        
        NSString *accuracy = CIDetectorAccuracyHigh;
        NSDictionary *options = [NSDictionary dictionaryWithObject:accuracy forKey:CIDetectorAccuracy];
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:options];
        NSArray *features = [detector featuresInImage:image];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self drawImageAnnotatedWithFeatures:features];

            if (self.leftEyeX.floatValue - 50 < 0) {
                UIAlertView *notDetected = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Can not detect faces!" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
                [notDetected show];
            } else {
                self.width = 2*(self.rightEyeX.floatValue-self.leftEyeX.floatValue + 30);
                NSLog(@"show width : %f",self.width);
                self.height = 50;
                NSLog(@"show height : %f",self.height);
                UIImageView *glassesImageView = [[UIImageView alloc] init];
                UIImage *glasses = [UIImage imageNamed:@"glasses"];
                glassesImageView.image = glasses;
                glassesImageView.frame = CGRectMake(self.leftEyeX.floatValue-50,300-self.leftEyeY.floatValue-15, self.width, self.height);
        
                [self.editingImageView addSubview:glassesImageView];
                
                UIImageView *stachesView = [[UIImageView alloc] init];
                UIImage *staches = [UIImage imageNamed:@"staches"];
                //resize image
                UIGraphicsBeginImageContext(CGSizeMake(40, 40));
                [staches drawInRect: CGRectMake(0, 0, 40, 40)];
                UIImage *stachesImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                stachesView.frame = CGRectMake(self.mouthX.floatValue, 300-self.mouthY.floatValue-20, 30, 30);
                stachesView.image = stachesImage;
                [self.editingImageView addSubview:stachesView];

            }
        });
        
    });
}

/*******************************************************************************
 * @method          drawImageAnnotatedWithFeatures
 * @abstract
 * @description
 ******************************************************************************/
- (void)drawImageAnnotatedWithFeatures:(NSArray *)features {
    
	UIImage *faceImage = self.editingImageView.image;
    UIGraphicsBeginImageContextWithOptions(faceImage.size, YES, 0);
    [faceImage drawInRect:self.editingImageView.bounds];
    
    // Get image context reference
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Flip Context
    CGContextTranslateCTM(context, 0, self.editingImageView.bounds.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    
    CGFloat scale = [UIScreen mainScreen].scale;
    NSLog(@"show scale : %f",scale);
    
    if (scale > 1.0) {
        // Loaded 2x image, scale context to 50%
        CGContextScaleCTM(context, 0.5, 0.5);
    }
    
    for (CIFaceFeature *feature in features) {
        
//        CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 0.5f);
//        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
//        CGContextSetLineWidth(context, 2.0f * scale);
//        CGContextAddRect(context, feature.bounds);
//        CGContextDrawPath(context, kCGPathFillStroke);
        
        // Set red feature color
        CGContextSetRGBFillColor(context, 1.0f, 0.0f, 0.0f, 0.4f);
        
        if (feature.hasLeftEyePosition) {
//            [self drawFeatureInContext:context atPoint:feature.leftEyePosition];
            self.leftEyeX = [[NSNumber alloc] initWithFloat:feature.leftEyePosition.x];
           self.leftEyeY = [[NSNumber alloc] initWithFloat:feature.leftEyePosition.y];
            NSLog(@"show left eye position : %@",NSStringFromCGPoint(feature.leftEyePosition));
        }
        
        if (feature.hasRightEyePosition) {
//            [self drawFeatureInContext:context atPoint:feature.rightEyePosition];
            self.rightEyeX = [[NSNumber alloc] initWithFloat:feature.rightEyePosition.x];
            self.rightEyeY = [[NSNumber alloc] initWithFloat:feature.rightEyePosition.y];
            NSLog(@"show right eye position : %@",NSStringFromCGPoint(feature.rightEyePosition));
        }
        
        if (feature.hasMouthPosition) {
//            [self drawFeatureInContext:context atPoint:feature.mouthPosition];
            self.mouthX = [[NSNumber alloc] initWithFloat:feature.mouthPosition.x];
            self.mouthY = [[NSNumber alloc] initWithFloat:feature.mouthPosition.y];
            NSLog(@"show mouth position : %@",NSStringFromCGPoint(feature.mouthPosition));
        }
    }
    
    self.editingImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

/*******************************************************************************
 * @method          drawFeatureInContext
 * @abstract
 * @description
 ******************************************************************************/
- (void)drawFeatureInContext:(CGContextRef)context atPoint:(CGPoint)featurePoint {
    CGFloat radius = 15.0f * [UIScreen mainScreen].scale;
    self.theRadius = [[NSNumber alloc] initWithFloat:radius];
    NSLog(@"show radius : %f",radius);
    CGContextAddArc(context, featurePoint.x, featurePoint.y, radius, 0, M_PI * 2, 1);
    CGContextDrawPath(context, kCGPathFillStroke);
}

#pragma mark - Paint View Delegagte Protocol Methods
/*******************************************************************************
 * @method          paintView:
 * @abstract
 * @description
 *******************************************************************************/
- (IBAction)drawOnTheImage:(id)sender {
    self.paintView.userInteractionEnabled = YES;
}

#pragma mark -- share through facebook or twitter
/*******************************************************************************
 * @method          share through facebook or twitter
 * @abstract        
 * @description
 *******************************************************************************/
- (IBAction)shareToFaceBook:(id)sender {
    if (self.isSaved) {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
        {
            SLComposeViewController *facebookSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            [facebookSheet setInitialText:@"Just want to share the cute picture!"];
            [facebookSheet addImage:self.savedImage];
            [self presentViewController:facebookSheet animated:YES completion:nil];
        }
    }else{
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Not Saved!" message:@"Please save before share!" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
        [errorAlert show];
    }
    
}

- (IBAction)shareToTwitter:(id)sender {
    if (self.isSaved) {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        {
            SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetSheet setInitialText:@"Just want to share the cute picture!"];
            [tweetSheet addImage:self.savedImage];
            [self presentViewController:tweetSheet animated:YES completion:nil];
        }
    }else{
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Not Saved!" message:@"Please save before share!" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
        [errorAlert show];
    }
    
}

#pragma mark -- back to home screen
- (IBAction)backToHomeScreen:(id)sender {

    //    NSLog(@"Navigation Controller %@",self.navigationController);
    ViewController *vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"homeScreen"];
    [self.navigationController pushViewController:vc animated:YES];
    [[vc navigationController] setNavigationBarHidden:NO];
    //    [self presentViewController:evc animated:YES completion:nil];
    
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }
    
}


@end
