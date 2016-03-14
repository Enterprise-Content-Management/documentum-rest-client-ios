//
//  CabinetViewController.m
//  Library
//
//  Created by Derek Zasiewski on 13-04-24.
//

/**
 * This simplest of the controllers - just renders cabinets
 */

#import "CabinetViewController.h"
#import "FolderViewController.h"
#import "SearchResultsViewController.h"
#import "AFNetworking.h"
#import "Utility.h"
#import "ConnectionManager.h"
#import "MyConstants.h"

@implementation CabinetViewController

#pragma mark -
#pragma mark Initialization
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    if (self)
    {   
    }    
    return self;
}

#pragma mark -
#pragma mark View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = ROOT;
    [self showSearchButton];
}

/**
 * Just fetching cabinets collection. 
 * Error handling is rather minimalistic - this is in general throughout this app - focus here is on 
 * getting the working example up and running quickly.
 */

-(void)getChildren
{
    NSMutableString *mutString = [NSMutableString stringWithString:CABINETS_URI];
    [mutString appendString:INLINE_TRUE];
    [[ConnectionManager sharedManager] getPath:mutString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

/**
 * We're dealing with only cabinets here, so any selected cabinet will push FolderViewController onto the stack.
 */

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FolderViewController *folderViewController = [[FolderViewController alloc] init];
    NSDictionary *entry = [self.restArrayFromAFNetworking objectAtIndex:[indexPath row]];
    NSString *selectedRowEntryName = [entry objectForKey:TITLE];
    NSDictionary *contentDict = [entry objectForKey:CONTENT];
    NSString *url = [Utility findInDictionary:contentDict relation:LINK_RELATION_OBJECTS];
    [folderViewController setFoldersURI:url];
    [folderViewController setFolderName:selectedRowEntryName];
    // Push View Controller onto Navigation Stack
    [self.navigationController pushViewController:folderViewController animated:YES];
}

@end
