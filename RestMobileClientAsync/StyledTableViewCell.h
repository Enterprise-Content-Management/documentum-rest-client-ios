//
//  StyledTableViewCell.h
//  Library
//
//  Created by Derek Zasiewski on 13-04-24.
//  Copyright (c) 2013 Mobile Tuts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StyledTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel      *repositorytNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView  *repositoryImageView;
@property (strong, nonatomic) IBOutlet UITextView   *repositoryTextView;
@property (strong, nonatomic) IBOutlet UIView *view;

@end
