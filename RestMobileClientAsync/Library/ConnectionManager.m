//
//  ConnectionManager.m
//  Library
//
//  Created by Derek Zasiewski on 13-04-24.
//

#import "ConnectionManager.h"
#import "AFJSONRequestOperation.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "MyConstants.h"

@implementation ConnectionManager

#pragma mark - Methods

#pragma mark - Initialization

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if(!self)
        return nil;
    
    [self clearAuthorizationHeader];
    [self setAuthorizationHeaderWithUsername:USERNAME password:PASSWORD];
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:ACCEPT_HEADER value:MEDIA_TYPE];
    [self setParameterEncoding:AFJSONParameterEncoding];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    return self;
}

#pragma mark - Singleton Methods

+ (ConnectionManager *)sharedManager
{
    static dispatch_once_t pred;
    static ConnectionManager *_sharedManager = nil;
    
    dispatch_once(&pred, ^{ _sharedManager = [[self alloc] initWithBaseURL:[NSURL URLWithString:SERVER_URL]]; });     return _sharedManager;
}

@end

