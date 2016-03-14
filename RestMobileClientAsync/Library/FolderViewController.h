//
//  FolderViewController.h
//  Library
//
//  Created by Derek Zasiewski on 13-04-24.
//

#import <UIKit/UIKit.h>
#import "CollectionViewController.h"

@interface FolderViewController : CollectionViewController <UITextViewDelegate>

@property (nonatomic) NSString * foldersURI;
@property (nonatomic) NSString * folderName;

@end

