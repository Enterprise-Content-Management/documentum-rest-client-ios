//
//  Utility.m
//  Library
//
//  Created by Derek Zasiewski on 13-04-24.
//

#import "Utility.h"
#import "MyConstants.h"

@implementation Utility

/**
 * Ok, bunch of utility methods here on accessing specific items in dictionary - I probably don't need all of them
 * anymore but left them here in case they may provide value for extending functionality later on. First three methods
 * are very much alike - pass dictionary and link relation name, and if found, return you corresponding URL contained
 * in HREF element. Here is the example of the expected JSON structure in Dictionary:
 
 {
 
 "rel": "self",
 "href": "http://127.0.0.1:8080/dctm-media-rest/repositories/IIG_MediaLibrary/cabinets/0c049fb980039fce.json"
 
 },
 {
 
 "rel": "edit",
 "href": "http://127.0.0.1:8080/dctm-media-rest/repositories/IIG_MediaLibrary/cabinets/0c049fb980039fce.json"
 
 },
 {
 
 "rel": "http://identifiers.emc.com/documentum/linkrel/delete",
 "href": "http://127.0.0.1:8080/dctm-media-rest/repositories/IIG_MediaLibrary/cabinets/0c049fb980039fce.json"
 
 },
 
 
 */

+ (NSString *)findInDictionary:(NSDictionary *)dict relation:(NSString *)linkRelation
{
    NSArray *linksArray = [dict objectForKey:LINKS];
    
    NSString *rel;
    NSString *url;
    NSDictionary *linksDict;
    NSURL *properURL;
    for (NSUInteger i = 0; i < [linksArray count]; i++)
    {
        linksDict = [linksArray objectAtIndex:i];
        rel = [linksDict objectForKey:RELATION_KEY];
        if ([rel isEqualToString:linkRelation]) {
            url = [linksDict objectForKey:HREF_KEY];
            properURL = [NSURL URLWithString:url];
            NSMutableString *myString = [NSMutableString stringWithString:[properURL path]];
            [myString appendString: INLINE_TRUE];
            url = myString;
            break;
        }
    }
    return url;
}

+ (NSString *)findInDictionary:(NSDictionary *)dict relation:(NSString *)linkRelation appendInline:(BOOL)shouldAppend
{
    NSArray *linksArray = [dict objectForKey:LINKS];
    
    NSString *rel;
    NSString *url;
    NSDictionary *linksDict;
    NSURL *properURL;
    for (NSUInteger i = 0; i < [linksArray count]; i++)
    {
        linksDict = [linksArray objectAtIndex:i];
        rel = [linksDict objectForKey:RELATION_KEY];
        if ([rel isEqualToString:linkRelation]) {
            url = [linksDict objectForKey:HREF_KEY];
            properURL = [NSURL URLWithString:url];
            
            NSMutableString *myString = [NSMutableString stringWithString:[properURL path]];
            if(shouldAppend)
            {
                [myString appendString: INLINE_TRUE];
            }
            url = myString;
            break;
        }
    }
    return url;
}

+ (NSString *)findInEntry:(NSDictionary *)dict relation:(NSString *)linkRelation
{
    NSArray *linksArray = [dict objectForKey:LINKS];
    
    NSString *rel;
    NSString *url;
    NSDictionary *linksDict;

    for (NSUInteger i = 0; i < [linksArray count]; i++)
    {
        linksDict = [linksArray objectAtIndex:i];
        rel = [linksDict objectForKey:RELATION_KEY];
        if ([rel isEqualToString:linkRelation])
        {
            url = [linksDict objectForKey:HREF_KEY];
            break;
        }
    }
    return url;
}

/**
 * This method scans links in the received JSON feed and looks for the "next" link relation, indicating link
 * to next page, such as in the example below:
 
 {
 
 "rel": "self",
 "href": "http://127.0.0.1:8080/dctm-media-rest/repositories/IIG_MediaLibrary/cabinets.json?inline=true"
 
 },
 {
 
 "rel": "next",
 "href": "http://127.0.0.1:8080/dctm-media-rest/repositories/IIG_MediaLibrary/cabinets.json?inline=true&items-per-page=100&page=2"
 
 },
 {
 
 "rel": "first",
 "href": "http://127.0.0.1:8080/dctm-media-rest/repositories/IIG_MediaLibrary/cabinets.json?inline=true&items-per-page=100&page=1"
 
 }
 
 */

+ (NSString *)findNextPageURI:(NSArray *)array
{
    NSDictionary *linksDictionary;
    NSString *rel = nil;
    NSString *uri = nil;;
    
    for (NSUInteger i = 0; i < [array count]; i++)
    {
        linksDictionary = [array objectAtIndex:i];
        rel = [linksDictionary objectForKey:RELATION_KEY];
        
        if([rel isEqualToString:NEXT_KEY])
        {
            uri = [linksDictionary objectForKey:HREF_KEY];
            break;
        }
    }
    return uri;
}


@end
