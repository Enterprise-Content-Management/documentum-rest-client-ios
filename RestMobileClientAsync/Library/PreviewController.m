//
//  PreviewController.m
//  CoreRestClient
//
//  Created by Derek Zasiewski on 13-04-30.
//

/**
 * This class fetches preview rendition. It went through few versions as contents resource wasn't supported
 * until n-th iteration, so I was using different results initially. Now some of these methods are no longer
 * used but I decided to leave them here in case they might provide some value for other features you may want to 
 * play with.
 * Not the prettiest class as it has lots of fallback rules depending on whether renditions are present, etc.
 *
 */

#import "PreviewController.h"
#import "ConnectionManager.h"
#import "MyConstants.h"

@implementation PreviewController

@synthesize assetName;
@synthesize previewUrl;
@synthesize thumbnailUrl;
@synthesize renditionsUrl;

NSURLConnection *connection;
UIActivityIndicatorView *spinner;

/**
 * Show preview rendition. Added methods to stretch, rotate, pinch, etc for the image
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.assetName;
    spinner = [[UIActivityIndicatorView alloc]
               initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    spinner.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0 - spinner.frame.size.height-20);
    spinner.hidesWhenStopped = YES;
    spinner.color = [UIColor blackColor];
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    // Don't flame me - different revisions of resources were going through changes, so I was flexible here.
    // Left currently not used branch below, and corresponding method, for potential reuse
    if(TRUE)
        [self fetchRenditionsLink];
    else
        [self fetchRenditionsInfo];
    
    //NSLog(@"renditions URL %@", self.renditionsUrl);
    
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateImage:)];
    [self.view addGestureRecognizer:rotationGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleImage:)];
    [self.view addGestureRecognizer:pinchGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveImage:)];
    [panGesture setMinimumNumberOfTouches:1];
	[panGesture setMaximumNumberOfTouches:1];
    [self.view addGestureRecognizer:panGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetImage:)];
    [self.view addGestureRecognizer:tapGesture];   
}

/**
 * Fetching content here - and fallback in case things go south. Not used presently.
 */
-(void)fetchRenditionsInfo
{
    [[ConnectionManager sharedManager] getPath:self.renditionsUrl parameters:nil
                                       success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         self.restArray = [responseObject objectForKey:ENTRIES];
         self.previewUrl = [self findRenditionInArray:self.restArray ofFormat:PREVIEW_FORMAT];
         if(!self.previewUrl)
             self.previewUrl = [self findRenditionInArray:self.restArray ofFormat:LOW_RES_PREVIEW];
         if(!self.previewUrl)
             self.previewUrl = self.thumbnailUrl;
         
         // Configure the view for the selected state
         UIImage * image;
         if(!self.previewUrl)
         {
             image = [UIImage imageNamed:NO_PREVIEW_IMAGE];
         }
         else
         {
             image = [UIImage imageWithData:[NSData dataWithContentsOfURL:
                                             [NSURL URLWithString:self.previewUrl]]];
         }
         imageView.image = image;
         imageView.contentMode = UIViewContentModeScaleToFill;
         imageView.clipsToBounds = YES;
         [spinner stopAnimating];
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Preview JSON req failed %@", [error description]);
         UIImage * image = [UIImage imageNamed:NO_PREVIEW_IMAGE];
         imageView.image = image;
         imageView.contentMode = UIViewContentModeScaleToFill;
         imageView.clipsToBounds = YES;
         [spinner stopAnimating];
     }];
}

/**
 * Fetching content rendition. Fallback rules - try to fetch preview rendition, if there isn't one
 * fetch low resolution rendition, if there isn't one then fetch thumbnail. Fallback to self contained image
 * if things go south.
 */
-(void)fetchRenditionsLink
{
    //NSLog(@"fetching %@", self.renditionsUrl);
    [[ConnectionManager sharedManager] getPath:self.renditionsUrl parameters:nil
                                       success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         self.restArray = [responseObject objectForKey:ENTRIES];
         
         NSString *url = nil;
         if(FETCH_CONTENTS_INLINE)
         {
             url = [self findRenditionLink:self.restArray ofFormat:PREVIEW_FORMAT];
             if(!url)
                 url = [self findRenditionLink:self.restArray ofFormat:LOW_RES_PREVIEW];
             if(!url)
                 url = [self findRenditionLink:self.restArray ofFormat:THUMBNAIL_FORMAT];
         }
         else
         {
             url = [self findRenditionLinkByTitle:self.restArray ofFormat:PREVIEW_FORMAT];
             if(!url)
                url = [self findRenditionLinkByTitle:self.restArray ofFormat:LOW_RES_PREVIEW];
             if(!url)
                 url = [self findRenditionLinkByTitle:self.restArray ofFormat:THUMBNAIL_FORMAT];
         }
         //NSLog(@"found url %@", url);
         //if(!url)
         //{
         //    url = [self findRenditionLink:self.restArray ofFormat:LOW_RES_PREVIEW];
             //NSLog(@"found url %@", url);
         //}
         self.previewUrl = url;
         
         if(!self.previewUrl)
         {
             UIImage * image = [UIImage imageNamed:NO_PREVIEW_IMAGE];
             imageView.image = image;
             imageView.contentMode = UIViewContentModeScaleToFill;
             imageView.clipsToBounds = YES;
             [spinner stopAnimating];
         }
         else
         {
             [self fetchPreviewURL];
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"JSON req failed %@", [error description]);
         UIImage * image = [UIImage imageNamed:NO_PREVIEW_IMAGE];
         imageView.image = image;
         imageView.contentMode = UIViewContentModeScaleToFill;
         imageView.clipsToBounds = YES;
         [spinner stopAnimating];
     }];
}

-(void)fetchPreviewURL
{
    //NSLog(@"preview %@", self.previewUrl);
    [[ConnectionManager sharedManager] getPath:self.previewUrl parameters:nil
                                       success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         self.restArray = [responseObject objectForKey:LINKS];
         NSString *url = [self findMediaUrl:self.restArray];
         //NSLog(@"found final url %@", url);
         self.previewUrl = url;
         //if(!self.previewUrl)
         //    self.previewUrl = [self findRenditionInArray:self.restArray ofFormat:LOW_RES_PREVIEW];
         UIImage * image;
         if(!self.previewUrl)
         {
             image = [UIImage imageNamed:NO_PREVIEW_IMAGE];
         }
         else
         {
             image = [UIImage imageWithData:[NSData dataWithContentsOfURL:
                                             [NSURL URLWithString:self.previewUrl]]];
         }
         imageView.image = image;
         imageView.contentMode = UIViewContentModeScaleToFill;
         imageView.clipsToBounds = YES;
         [spinner stopAnimating];
  
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"JSON req failed %@", [error description]);
         //[spinner stopAnimating];
     }];
}

/**
 * Go through array of links looking for enclousure link relation
 */
- (NSString *)findMediaUrl:(NSArray *)linksArray
{
    for (NSUInteger i = 0; i < [linksArray count]; i++)
    {
        NSDictionary * dict = [linksArray objectAtIndex:i];
        NSString * rel = [dict objectForKey:RELATION_KEY];
        if( [rel isEqualToString:ENCLOSURE_KEY])
        {
            NSString * uri = [dict objectForKey:HREF_KEY];
            return uri;
        }
    }
    return nil;
}

/**
 * Parsing title attribute to figure out page, format and page modifier, encoded there.
 * It expects following format: "Content(page: 0, format: tif, modifier: )"
 */
- (NSString *)findRenditionLinkByTitle:(NSArray *)restArray ofFormat:(NSString *)imageFormat
{
    NSString * resultingUri = nil;
    NSDictionary *entryDict;
    NSDictionary *contentDict;
    for (NSUInteger i = 0; i < [restArray count]; i++)
    {
        entryDict = [restArray objectAtIndex:i];
        NSString *title = [entryDict objectForKey:TITLE];
        // title": "Content(page: 0, format: tif, modifier: )"
        
        NSArray  *pieces = [title componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @"("]];
        NSString *formatInfoString = pieces[1];
        NSArray *components = [formatInfoString componentsSeparatedByString:@" "];
        //NSString *page = [self removeLastCharacter:components[1]];
        NSString *format = [self removeLastCharacter:components[3]];
        //NSString *modifier = [self removeLastCharacter:components[5]];
        if([format isEqualToString:imageFormat])
        {
            contentDict = [entryDict objectForKey:CONTENT];
            resultingUri = [contentDict objectForKey:SRC_KEY];
            return resultingUri;
        }
        //NSString *query = [components lastObject];
    }
    return resultingUri;
}

// Convenience method to strip last character
- (NSString *)removeLastCharacter:(NSString *)input
{
    if(!input)
        return nil;
    NSString *newString = [input substringToIndex:[input length]-1];
    return newString;
}

/**
 * Convoluted algorithm to find appropriate rendition, due to the fact that assets with storyboards
 * have a lot of renditions.
 */
- (NSString *)findRenditionLink:(NSArray *)restArray ofFormat:(NSString *)imageFormat
{
    NSString * resultingUri = nil;
    NSDictionary *entryDict;
    NSDictionary *contentDict;
    NSDictionary *attrDict;
    NSArray *linksArray;
    NSDictionary *linksDict;
    int maxContentSize = 0;
    for (NSUInteger i = 0; i < [restArray count]; i++)
    {
        entryDict = [restArray objectAtIndex:i];
        contentDict = [entryDict objectForKey:CONTENT];
        attrDict = [contentDict objectForKey:PROPERTIES];
        NSString * formatFound = [attrDict objectForKey:FULL_FORMAT];
        NSArray *pageModifierArray = [attrDict objectForKey:PAGE_MODIFIER];
        NSString *pageMod = [pageModifierArray objectAtIndex:0];
        int contentSize =  [[attrDict objectForKey:CONTENT_SIZE] intValue];
        
        if ([formatFound isEqualToString:imageFormat] )
        {
            if([pageMod isEqualToString:EMPTY_PAGE_MODIFIER ] || [pageMod hasSuffix:THUMBNAIL_FORMAT])
            {
                if(contentSize > maxContentSize)
                {
                    maxContentSize = contentSize;
                    linksArray = [contentDict objectForKey:LINKS];
                    for( NSUInteger j = 0; j < [linksArray count]; j++)
                    {
                        linksDict = [linksArray objectAtIndex:j];
                        NSString *rel = [linksDict objectForKey:RELATION_KEY];
                        if( [rel isEqualToString:SELF_KEY])
                        {
                            NSString *linkUri = [linksDict objectForKey:HREF_KEY];
                            resultingUri = linkUri;
                            break;
                        }//ends if
                    }//ends for linksArray
                }//ends if contentSize
            }//ends if pageMod
            else if([pageMod isEqualToString:ZEROS_PAGE_MODIFIER])
            {
                if(contentSize > maxContentSize)
                {
                    maxContentSize = contentSize;
                    linksArray = [contentDict objectForKey:LINKS];
                    for( NSUInteger j = 0; j < [linksArray count]; j++)
                    {
                        linksDict = [linksArray objectAtIndex:j];
                        NSString *rel = [linksDict objectForKey:RELATION_KEY];
                        if( [rel isEqualToString:SELF_KEY])
                        {
                            NSString *imUri = [linksDict objectForKey:HREF_KEY];
                            resultingUri = imUri;
                            break;
                        }//ends if
                    }//ends for linksArray
                }//ends if contentSize
            }//ends else if pageMod
        }//ends if formatFound
    }//ends for restArray
    return resultingUri;
}

/**
 * Convoluted algorithm to find appropriate rendition, due to the fact that assets with storyboards
 * have a lot of renditions. Not used anymore in favour of method above.
 */
- (NSString *)findRenditionInArray:(NSArray *)restArray ofFormat:(NSString *)imageFormat
{
    NSString * resultingUri = nil;
    NSDictionary *entryDict;
    NSDictionary *contentDict;
    NSDictionary *attrDict;
    NSArray *linksArray;
    NSDictionary *linksDict;
    int maxContentSize = 0;
    for (NSUInteger i = 0; i < [restArray count]; i++)
    {
        entryDict = [restArray objectAtIndex:i];
        contentDict = [entryDict objectForKey:CONTENT];
        attrDict = [contentDict objectForKey:PROPERTIES];
        NSString * formatFound = [attrDict objectForKey:FULL_FORMAT];
        NSArray *pageModifierArray = [attrDict objectForKey:PAGE_MODIFIER];
        NSString *pageMod = [pageModifierArray objectAtIndex:0];
        int contentSize =  [[attrDict objectForKey:CONTENT_SIZE] intValue];
        
        if ([formatFound isEqualToString:imageFormat] )
        {
            if([pageMod isEqualToString:EMPTY_PAGE_MODIFIER ] || [pageMod hasSuffix:THUMBNAIL_FORMAT])
            {
                if(contentSize > maxContentSize)
                {
                    maxContentSize = contentSize;
                    linksArray = [contentDict objectForKey:LINKS];
                    for( NSUInteger j = 0; j < [linksArray count]; j++)
                    {
                        linksDict = [linksArray objectAtIndex:j];
                        NSString *rel = [linksDict objectForKey:RELATION_KEY];
                        if( [rel isEqualToString:ENCLOSURE_KEY])
                        {
                            NSString *imUri = [linksDict objectForKey:HREF_KEY];
                            resultingUri = imUri;
                            break;
                        }//ends if
                    }//ends for linksArray
                }//ends if contentSize
            }//ends if pageMod
            else if([pageMod isEqualToString:ZEROS_PAGE_MODIFIER])
            {
                if(contentSize > maxContentSize)
                {
                    maxContentSize = contentSize;
                    linksArray = [contentDict objectForKey:LINKS];
                    for( NSUInteger j = 0; j < [linksArray count]; j++)
                    {
                        linksDict = [linksArray objectAtIndex:j];
                        NSString *rel = [linksDict objectForKey:RELATION_KEY];
                        if( [rel isEqualToString:ENCLOSURE_KEY])
                        {
                            NSString *imUri = [linksDict objectForKey:HREF_KEY];
                            resultingUri = imUri;
                            break;
                        }//ends if
                    }//ends for linksArray
                }//ends if contentSize  
            }//ends else if pageMod
        }//ends if formatFound
    }//ends for restArray
    return resultingUri;
}

- (void)scaleImage:(UIPinchGestureRecognizer *)recognizer
{
	if([recognizer state] == UIGestureRecognizerStateEnded) {
        
		previousScale = 1.0;
		return;
	}
	CGFloat newScale = 1.0 - (previousScale - [recognizer scale]);
	CGAffineTransform currentTransformation = imageView.transform;
	CGAffineTransform newTransform = CGAffineTransformScale(currentTransformation, newScale, newScale);
    imageView.transform = newTransform;
	previousScale = [recognizer scale];
}

- (void)moveImage:(UIPanGestureRecognizer *)recognizer
{
    CGPoint newCenter = [recognizer translationInView:self.view];
    
	if([recognizer state] == UIGestureRecognizerStateBegan) {
        
		beginX = imageView.center.x;
		beginY = imageView.center.y;
	}
    
	newCenter = CGPointMake(beginX + newCenter.x, beginY + newCenter.y);
    
	[imageView setCenter:newCenter];
    
}

- (void)rotateImage:(UIRotationGestureRecognizer *)recognizer
{
    
	if([recognizer state] == UIGestureRecognizerStateEnded) {
        
		previousRotation = 0.0;
		return;
	}
    
	CGFloat newRotation = 0.0 - (previousRotation - [recognizer rotation]);
    
	CGAffineTransform currentTransformation = imageView.transform;
	CGAffineTransform newTransform = CGAffineTransformRotate(currentTransformation, newRotation);
    
    imageView.transform = newTransform;
    
	previousRotation = [recognizer rotation];
}

- (void)resetImage:(UITapGestureRecognizer *)recognizer
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    imageView.transform = CGAffineTransformIdentity;
    
    [imageView setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    
    [UIView commitAnimations];
}






@end
