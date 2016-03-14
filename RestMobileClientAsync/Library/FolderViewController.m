//
//  FolderViewController.m
//  Library
//
//  Created by Derek Zasiewski on 13-04-24.
//

/**
 * This class renders folder and takes care of navigation to either subfolder or jumps into the object selected
 *
 */ 

#import "FolderViewController.h"
#import "AssetDetailsViewController.h"
#import "BasicAssetDetailsViewController.h"
#import "AFNetworking.h"
#import "ConnectionManager.h"
#import "Utility.h"
#import "MyConstants.h"

@implementation FolderViewController

@synthesize foldersURI;
@synthesize folderName;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.folderName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 * Fetching objects contained in the folder
 */

- (void)getChildren
{
    [[ConnectionManager sharedManager] getPath:self.foldersURI parameters:nil
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

/**
 * Detecting object type in given entry in the collection
 */

- (NSString *)getObjectType:(NSDictionary *)entry
{
    NSDictionary *contentDict = [entry objectForKey:CONTENT];
    NSDictionary *attrDict = [contentDict objectForKey:PROPERTIES];
    NSString *typeKey = R_OBJECT_TYPE;
    return [attrDict objectForKey:typeKey];
}

/**
 * Contents of folder are a mixture of documents and folders, so we'll need to detect what was 
 * selected and push appropriate controller onto the stack.
 */

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *entry = [self.restArrayFromAFNetworking objectAtIndex:[indexPath row]];
    NSDictionary *contentDict = [entry objectForKey:CONTENT];
    NSDictionary *attrDict = [contentDict objectForKey:PROPERTIES];
    NSString *typeKey = R_OBJECT_TYPE;
    NSString *type = [attrDict objectForKey:typeKey];
    
    NSString *iconURL;
    
    // Don't flame me - old check as this code went through several revisions
    // and the representation of the feed was changing drastically and since I was
    // testing against multiple deployments I wanted to ensure code is flexible enough
    // to fetch thumbnails based on different specs. Eventually we settled on providing an
    // "icon" but I never removed alternative condition but I did ensure that
    // code alwasy goes through the first branch of this "if" statement
    if(TRUE)
    {
        iconURL = [Utility findInEntry:entry relation:ICON_KEY];
    }
    else
    {
        NSDictionary *thumbnailDictionary = [entry objectForKey:THUMBNAIL];
        iconURL = [thumbnailDictionary objectForKey:URL];
    }

    // Need to properly encode the icon URL as otherwise iOS will not fetch it.
    NSString *escapedString = [iconURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    // Push either folder/cabinet controller or the asset details onto the stack
    if ([type isEqualToString:DM_FOLDER_TYPE] || [type isEqualToString:DM_CABINET_TYPE])
    {
        NSString *url = [Utility findInDictionary:contentDict relation:LINK_RELATION_OBJECTS];
        NSString *selectedRowEntryName = [entry objectForKey:TITLE];
        FolderViewController *folderViewController = [[FolderViewController alloc] init];
        [folderViewController setFoldersURI:url];
        [folderViewController setFolderName:selectedRowEntryName];
        [self.navigationController pushViewController:folderViewController animated:YES];

    }
    else
    {
        [spinner startAnimating];
        BasicAssetDetailsViewController *basicAssetDetailsViewController = [[BasicAssetDetailsViewController alloc] initWithNibName:@"DetailView" bundle:[NSBundle mainBundle]];
        
        [basicAssetDetailsViewController setItemDetail:contentDict];
        [basicAssetDetailsViewController setObjectName:[entry objectForKey:TITLE]];
        [basicAssetDetailsViewController setThumbnailUrl:escapedString];
        
        NSString *renditionsURL = [Utility findInDictionary:contentDict relation:LINK_RELATION_RENDITIONS appendInline:FETCH_CONTENTS_INLINE];
        [basicAssetDetailsViewController setRenditionsURL:renditionsURL];
        [spinner stopAnimating];
        [self.navigationController pushViewController:basicAssetDetailsViewController animated:YES];
    } 
}

@end
