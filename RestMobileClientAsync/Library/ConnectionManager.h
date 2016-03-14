//
//  ConnectionManager.h
//  Library
//
//  Created by Derek Zasiewski on 13-04-24.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@interface ConnectionManager : AFHTTPClient

+ (ConnectionManager *)sharedManager;

@end
