//
//  SearchResultsViewController.m
//  AsyncCoreRestClient
//
//  Created by Derek Zasiewski on 13-05-21.
//

/**
 * Search controller. When getChildren gets called it executes search for the criteria entered
 *
 */

#import "SearchResultsViewController.h"
#import "BasicAssetDetailsViewController.h"
#import "MyConstants.h"
#import "Utility.h"
#import "ConnectionManager.h"
#import "FolderViewController.h"

@implementation SearchResultsViewController

@synthesize searchCriteria;
@synthesize searchName;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableString *titleStr = [NSMutableString stringWithString:SEARCH_TITLE];
    [titleStr appendString:self.searchCriteria];
    self.title = titleStr;
}

- (void)getChildren
{
    NSRange lastSlashRange = [CABINETS_URI rangeOfString:@"/" options:NSBackwardsSearch];
    NSString * repoUrl;
    if(lastSlashRange.location != NSNotFound)
    {
        repoUrl = [CABINETS_URI substringWithRange:NSMakeRange(0, lastSlashRange.location)];
    }

    NSMutableString *mutString = [NSMutableString stringWithString:repoUrl];
    
    [mutString appendString:DQL_SEARCH_PARAM];
    [mutString appendString:EQUAL_SIGN];
    
    NSString *dqlSelect = @"SELECT * FROM dm_document SEARCH DOCUMENT CONTAINS ";
    NSString *escapedDqlSelect = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                            NULL,
                                                                                                            (CFStringRef)dqlSelect,
                                                                                                            NULL,
                                                                                                            CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                                            kCFStringEncodingUTF8));
    [mutString appendString:escapedDqlSelect];
    NSString *singleQuote = @"'";
    [mutString appendString:singleQuote];
    NSString *escapedSearchCriteria = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                  NULL,
                                                                                  (CFStringRef)self.searchCriteria,
                                                                                  NULL,
                                                                                  CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                  kCFStringEncodingUTF8));

    [mutString appendString:escapedSearchCriteria];
    [mutString appendString:singleQuote];

    //NSLog(@"search string: %@", mutString);
    
    [[ConnectionManager sharedManager] getPath:mutString parameters:nil
                                       success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         self.restArrayFromAFNetworking = [responseObject objectForKey:ENTRIES];
         NSArray * links = [responseObject objectForKey:LINKS];
         self.nextPageURI = [Utility findNextPageURI:links];

         [self.tableView reloadData];
         [spinner stopAnimating];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"JSON req failed %@", [error description]);
     }];

}

@end
