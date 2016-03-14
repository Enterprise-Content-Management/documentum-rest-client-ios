//
//  BasicAssetDetailsViewController.h
//  Library
//
//  Created by Derek Zasiewski on 13-04-24.
//

#import <UIKit/UIKit.h>

@interface BasicAssetDetailsViewController : UIViewController

@property (strong, nonatomic) NSDictionary *itemDetail;
@property (strong, nonatomic) NSString *objectName;
@property (strong, nonatomic) NSString *renditionsURL;
@property (strong, nonatomic) NSString *thumbnailUrl;

@property (strong, nonatomic) IBOutlet UILabel      *repositorytNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView  *repositoryImageView;
@property (strong, nonatomic) IBOutlet UITextView   *repositoryTextView;
@property (strong, nonatomic) NSArray *restArray;

@end
