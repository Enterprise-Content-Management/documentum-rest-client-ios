//
//  MTBookCoverViewController.m
//  Library
//
//  Created by Bart Jacobs on 19/12/12.
//  Copyright (c) 2012 Mobile Tuts. All rights reserved.
//

#import "AssetDetailsViewController.h"

@interface AssetDetailsViewController ()

@end

@implementation AssetDetailsViewController

#pragma mark -
#pragma mark Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
    }
    
    return self;
}

#pragma mark -
#pragma mark View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.bookCover) {
        [self.bookCoverView setImage:self.bookCover];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
