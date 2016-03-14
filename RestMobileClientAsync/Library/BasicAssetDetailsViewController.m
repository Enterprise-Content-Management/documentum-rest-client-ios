//
//  BasicAssetDetailsViewController.m
//  Library
//
//  Created by Derek Zasiewski on 13-04-24.
//

/**
 * This class simply renders a thumbnail and some metadata to show how to use either one of these.
 * Note that depending on how CTS is configured on a server side, if there are multiple thumbnails being 
 * ripped, we randomly get reference to one of the available sizes, so if the small icon is returned, it may end
 * up being pixelated. Preview controller filters through all renditions but here we don't do that.
 *
 */

#import "BasicAssetDetailsViewController.h"
#import "ConnectionManager.h"
#import "PreviewController.h"
#import "AsyncImageView.h"
#import "MyConstants.h"

@implementation BasicAssetDetailsViewController

@synthesize repositorytNameLabel;
@synthesize repositoryImageView;
@synthesize repositoryTextView;
@synthesize renditionsURL;
@synthesize objectName;
@synthesize thumbnailUrl;
@synthesize itemDetail;

UIActivityIndicatorView *activityIndicator;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/**
 * This is asset detail view so we need to load up a thumbnail and some basic asset properties
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary * propertiesDictionary = [self.itemDetail objectForKey:PROPERTIES];
     
    AsyncImageView *imageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.repositoryImageView.frame.size.width, self.repositoryImageView.frame.size.height)];
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.clipsToBounds = YES;
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:self.repositoryImageView];
    
    NSURL * imageURL = [NSURL URLWithString:self.thumbnailUrl];
    UIImage *image;
    if(!self.thumbnailUrl)
    {
        NSString * objectType = [propertiesDictionary objectForKey:R_OBJECT_TYPE];
        if ([objectType isEqualToString:@"dm_document"])
        {
            image = [UIImage imageNamed:@"preview.jpg"];
            
        }
        else
        {
            image = [UIImage imageNamed:@"duketools.jpg"];
        }
        imageView.image = image;
    }
    else
    {
        imageView.imageURL = imageURL; 
    }

    [self.repositoryImageView addSubview:imageView];
    self.repositorytNameLabel.text = self.objectName;
    NSString *propStrings = [self gatherFormattedProperties:propertiesDictionary];
    self.repositoryTextView.text = propStrings;
    self.view.userInteractionEnabled = TRUE;
    
    
    // Tapping on the thumbnail will take us to preview controller
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
    [self.view addGestureRecognizer:tapGesture];
    //tapGesture.cancelsTouchesInView = YES;
    //tapGesture.numberOfTapsRequired = 1;
    
    //UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleImage:)];
    //[self.view addGestureRecognizer:pinchGesture];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:TRUE];
}

/**
 * These next few methods are not used anymore - I was using it to test performance of fetching 
 * thumbnail data, which ones was fixed, I simply stopped using. I left methods though for potential 
 * reuse.
 */
- (void)showReloadButton
{
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                    target:self
                                    action:@selector(reload:)];
    self.navigationItem.rightBarButtonItem = refreshItem;
}

- (IBAction) reload:(id)sender
{
    // Do your reload stuff
    [self showActivityIndicator];
    //[self fetchRenditionsInfo:propertiesDictionary];
}

- (void)showActivityIndicator
{
    activityIndicator =
    [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [activityIndicator startAnimating];
    UIBarButtonItem *activityItem =
    [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];

    self.navigationItem.rightBarButtonItem = activityItem;

}

/**
 * Get some basic asset properties
 */

- (NSMutableString *)gatherFormattedProperties:(NSDictionary *)propertiesDictionary
{
    NSMutableString *myString = [NSMutableString stringWithString:@"Creation Date: "];
    
    NSString *fullDateString = [propertiesDictionary objectForKey:R_CREATION_DATE];
    NSString *dateCutOff = @"T";
    NSRange range = [fullDateString rangeOfString:dateCutOff];
    int cutIndex = range.location;
    NSString *shortDateString = [fullDateString substringToIndex:cutIndex];
    
    [myString appendString: shortDateString];
    [myString appendString: @"\n"];
    
    [myString appendString: @"Object Name: "];
    [myString appendString: [propertiesDictionary objectForKey:OBJECT_NAME]];
    [myString appendString: @"\n"];
    
    [myString appendString: @"Object ID: "];
    [myString appendString: [propertiesDictionary objectForKey:R_OBJECT_ID]];
    [myString appendString: @"\n"];
    
    [myString appendString: @"Object Type: "];
    [myString appendString: [propertiesDictionary objectForKey:R_OBJECT_TYPE]];
    [myString appendString: @"\n"];
    
    [myString appendString: @"ACL : "];
    [myString appendString: [propertiesDictionary objectForKey:ACL_NAME]];
    [myString appendString: @"\n"];
    
    [myString appendString: @"Content Type : "];
    [myString appendString: [propertiesDictionary objectForKey:A_CONTENT_TYPE]];
    [myString appendString: @"\n"];
      
    return myString;
}

/**
 * Tapping on image will push preview controller onto the stack
 */
- (void) handleImageTap:(UITapGestureRecognizer *)gestureRecognizer
{
    PreviewController *previewController = [[PreviewController alloc] initWithNibName:@"PreviewView" bundle:[NSBundle mainBundle]];
    previewController.assetName = self.objectName;
    previewController.renditionsUrl = self.renditionsURL;
    
    [self.navigationController pushViewController:previewController animated:YES];
}

- (void)scaleImage:(UIPinchGestureRecognizer *)recognizer
{
	if([recognizer state] == UIGestureRecognizerStateEnded) {
        
		//previousScale = 1.0;
		return;
	}
	//CGFloat newScale = 1.0 - (previousScale - [recognizer scale]);
	//CGAffineTransform currentTransformation = productImageView.transform;
	//CGAffineTransform newTransform = CGAffineTransformScale(currentTransformation, newScale, newScale);
    //productImageView.transform = newTransform;
	//previousScale = [recognizer scale];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
