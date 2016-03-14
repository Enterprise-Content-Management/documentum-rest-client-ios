//
//  PreviewController.h
//  CoreRestClient
//
//  Created by Derek Zasiewski on 13-04-30.
//

#import <UIKit/UIKit.h>

@interface PreviewController : UIViewController
{
    IBOutlet UIImageView *imageView;
    NSMutableData *responseData;
    CGFloat previousScale;
    CGFloat beginX;
    CGFloat beginY;
    CGFloat previousRotation;
}

@property NSString *previewUrl;
@property NSString *thumbnailUrl;
@property NSString *assetName;
@property NSString *renditionsUrl;
@property NSArray *restArray;

@end
