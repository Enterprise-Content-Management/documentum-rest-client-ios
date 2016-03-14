//
//  CollectionViewController.m
//  AsyncCoreRestClient
//
//  Created by Derek Zasiewski on 13-05-23.
//

/**
 * Base class for my various controllers representing collections
 *
 */

#import "CollectionViewController.h"
#import "SearchResultsViewController.h"
#import "AFNetworking.h"
#import "Utility.h"
#import "ConnectionManager.h"
#import "AsyncImageView.h"
#import "MyConstants.h"

@implementation CollectionViewController

@synthesize nextPageURI;
@synthesize restArrayFromAFNetworking;
@synthesize isCurrentlyReloading;

static NSString *CellIdentifier = @"Cell Identifier";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    self.restArrayFromAFNetworking = [[NSArray alloc] init];
    
    spinner = [[UIActivityIndicatorView alloc]
               initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0 - spinner.frame.size.height );
    
    spinner.hidesWhenStopped = YES;
    spinner.color = [UIColor blackColor];
    [self.view addSubview:spinner];
    [spinner startAnimating];
        
    [self getChildren];
}

- (void)getChildren
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.restArrayFromAFNetworking count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
#define IMAGE_VIEW_TAG 99
    
    AsyncImageView *asyncImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 44.0f, 44.0f)];
    asyncImageView.contentMode = UIViewContentModeScaleAspectFill;
    asyncImageView.clipsToBounds = YES;
    asyncImageView.tag = IMAGE_VIEW_TAG;
    [cell addSubview:asyncImageView];
    [asyncImageView release];
    
    //common settings
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.indentationWidth = 44.0f;
    cell.indentationLevel = 1;
    
    NSDictionary *entryDictionary= [self.restArrayFromAFNetworking objectAtIndex:indexPath.row];
    NSString *iconURL;
    
    // Don't flame me - old check as this code went through several revisions
    // and the representation of the feed was changing drastically and since I was
    // testing against multiple deployments I wanted to ensure code is flexible enough
    // to fetch thumbnails based on different specs. Eventually we settled on providing an
    // "icon" but I never removed alternative condition but I did ensure that
    // code alwasy goes through the first branch of this "if" statement
    if(TRUE)
    {
        iconURL = [Utility findInEntry:entryDictionary relation:ICON_KEY];
    }
    else
    {
        NSDictionary *thumbnailDictionary = [entryDictionary objectForKey:THUMBNAIL];
        iconURL = [thumbnailDictionary objectForKey:URL];
    }
    
    NSString *objectType = [self getObjectType:entryDictionary];
    if ([objectType isEqualToString:DM_FOLDER_TYPE] || [objectType isEqualToString:DM_CABINET_TYPE])
    {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
        
    AsyncImageView *imageView = (AsyncImageView *)[cell viewWithTag:IMAGE_VIEW_TAG];	
    //cancel loading previous image for cell
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:imageView];
    UIImage *localImage;
    // Fallback if we don't have renditions, assign embedded images to assets
    if(!iconURL)
    {
        if ([objectType isEqualToString:DM_FOLDER_TYPE] || [objectType isEqualToString:DM_CABINET_TYPE])
            localImage = [UIImage imageNamed:@"folder.jpg"];
        else if([objectType isEqualToString:DM_DOCUMENT_TYPE])
            localImage = [UIImage imageNamed:@"media.jpg"];
        else
            localImage = [UIImage imageNamed:@"system.jpg"];
        imageView.image = localImage;
    }
    else
    {
        NSString *escapedString = [iconURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL * imageURL = [NSURL URLWithString:escapedString];
        imageView.imageURL = imageURL; 
    }
    
    cell.textLabel.text = [entryDictionary objectForKey:TITLE];
    cell.detailTextLabel.text = objectType;
    
    // Check for last row
    NSUInteger row = indexPath.row +1;
    if(row  == [self.restArrayFromAFNetworking count] && self.nextPageURI != nil && !self.isCurrentlyReloading)
    {
        self.isCurrentlyReloading = TRUE;
        [self fetchNextPage];
    }
    
    return cell;
}


- (NSString *)getObjectType:(NSDictionary *)entry
{
    NSDictionary *contentDictionary = [entry objectForKey:CONTENT];
    return [contentDictionary objectForKey:TYPE_KEY];
}

/**
 * I moved this method to utility class but somehow this one is left here...
 */
- (void)fetchNextPage
{
    [[ConnectionManager sharedManager] getPath:self.nextPageURI parameters:nil
                                       success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray * newArray = [responseObject objectForKey:ENTRIES];
         NSArray * old = self.restArrayFromAFNetworking;
         self.restArrayFromAFNetworking = [old arrayByAddingObjectsFromArray:newArray ];
         NSArray * links = [responseObject objectForKey:LINKS];
         self.nextPageURI = [Utility findNextPageURI:links];
         
         [self.tableView reloadData];
         [spinner stopAnimating];
         self.isCurrentlyReloading = FALSE;
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"JSON req failed %@", [error description]);
     }];
}

- (void)showSearchButton
{
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Search"
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(search:)];
    self.navigationItem.rightBarButtonItem = refreshItem;
}

- (IBAction) search:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Search" message:@"Let's do some search\n\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Search", nil];
    
    textField = [[UITextField alloc] init];
    [textField setBackgroundColor:[UIColor whiteColor]];
    textField.delegate = (id)self;
    textField.borderStyle = UITextBorderStyleLine;
    textField.frame = CGRectMake(15, 75, 255, 30);
    textField.font = [UIFont fontWithName:@"ArialMT" size:20];
    textField.placeholder = @"Enter search text";
    textField.textAlignment = NSTextAlignmentCenter;
    textField.keyboardAppearance = UIKeyboardAppearanceAlert;
    [textField becomeFirstResponder];
    [alert addSubview:textField];
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* detailString = textField.text;
   
    SearchResultsViewController *searchViewController = [[SearchResultsViewController alloc] init];
    [searchViewController setSearchCriteria:detailString];
    [searchViewController setSearchName:@"Search Results"];
    // Push View Controller onto Navigation Stack
    [self.navigationController pushViewController:searchViewController animated:YES];
    
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];}

@end
