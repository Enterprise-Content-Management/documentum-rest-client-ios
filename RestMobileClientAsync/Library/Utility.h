//
//  Utility.h
//  Library
//
//  Created by Derek Zasiewski on 13-04-24.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject

+ (NSString *)findInDictionary:(NSDictionary *)dict relation:(NSString *)linkRelation;
+ (NSString *)findInDictionary:(NSDictionary *)dict relation:(NSString *)linkRelation appendInline:(BOOL)shouldAppend;
+ (NSString *)findInEntry:(NSDictionary *)dict relation:(NSString *)linkRelation;
+ (NSString *)findNextPageURI:(NSArray *)array;

@end
