//
//  CollectionViewController.h
//  AsyncCoreRestClient
//
//  Created by Derek Zasiewski on 13-05-23.
//

#import <UIKit/UIKit.h>

@interface CollectionViewController : UITableViewController <UITextViewDelegate>
{
    UIActivityIndicatorView *spinner;
    UITextField *textField;
}

@property (strong, nonatomic) NSArray *restArrayFromAFNetworking;
@property (nonatomic) NSString * nextPageURI;
@property (nonatomic) BOOL isCurrentlyReloading;

- (void)getChildren;
- (void)fetchNextPage;
- (NSString *)getObjectType:(NSDictionary *)entry;
- (void)showSearchButton;
- (IBAction) search:(id)sender;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
