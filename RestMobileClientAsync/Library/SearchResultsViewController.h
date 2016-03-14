//
//  SearchResultsViewController.h
//  AsyncCoreRestClient
//
//  Created by Derek Zasiewski on 13-05-21.
//

#import <UIKit/UIKit.h>
#import "FolderViewController.h"

@interface SearchResultsViewController : FolderViewController

@property (nonatomic) NSString * searchCriteria;
@property (nonatomic) NSString * searchName;

@end
