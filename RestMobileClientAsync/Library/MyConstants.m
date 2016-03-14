//
//  MyConstants.m
//  AsyncCoreRestClient
//
//  Created by Derek Zasiewski on 13-05-14.
//

#import "MyConstants.h"

@implementation MyConstants
@end

BOOL const FETCH_CONTENTS_INLINE = TRUE;

/**
 * Please update the following hardcoded constants to your environment
 * SERVER_URL - pointing to your running app server where you deployed Documentum REST war
 * USERNAME & PASSWORD - those are necessary here, using Basic Authentication
 * CABINETS_URI - I cheated here a bit. Normally you'd want to point to "services" resource
 * and from there perform link discovery to find "repositories", etc, but I wanted to minimize
 * number of UI and hence controllers so I go straight into top level cabinets
 */
NSString * const SERVER_URL = @"http://127.0.0.1:8080";
NSString * const USERNAME = @"documentum";
NSString * const PASSWORD = @"Yellow1";
// find cabinets URI, it is of this format: <deployed name>/repositories/<your repo name>/cabinets.json
NSString * const CABINETS_URI =  @"/emc-rest-ga/repositories/IIG_MediaLibrary/cabinets.json";

/**
 * These constants should not be movidifed
 */
NSString * const LINK_RELATION_RENDITIONS = @"contents";
NSString * const LINK_RELATION_OBJECTS = @"http://identifiers.emc.com/linkrel/objects";

NSString * const ACCEPT_HEADER = @"Accept";
NSString * const MEDIA_TYPE = @"application/json";
NSString * const INLINE_TRUE = @"?inline=true";

NSString * const NO_PREVIEW_IMAGE = @"no_photo.jpg";
NSString * const SEARCH_TITLE = @"Search for: ";

NSString * const ROOT = @"Cabinets";
NSString * const ENTRIES = @"entries";
NSString * const THUMBNAIL = @"thumbnail";
NSString * const CONTENT = @"content";
NSString * const TITLE = @"title";
NSString * const URL = @"url";
NSString * const SRC_KEY = @"src";
NSString * const PROPERTIES = @"properties";
NSString * const LINKS = @"links";
NSString * const RELATION_KEY = @"rel";
NSString * const ICON_KEY = @"icon";
NSString * const HREF_KEY = @"href";
NSString * const ENCLOSURE_KEY = @"enclosure";
NSString * const SELF_KEY = @"self";
NSString * const TYPE_KEY = @"type";
NSString * const NEXT_KEY = @"next";
NSString * const AMPERSAND = @"&";
NSString * const SIMPLE_SEARCH_PARAM = @"q";
NSString * const DQL_SEARCH_PARAM = @"?dql";
NSString * const EQUAL_SIGN = @"=";

NSString * const R_OBJECT_TYPE = @"r_object_type";
NSString * const DM_FOLDER_TYPE = @"dm_folder";
NSString * const DM_CABINET_TYPE = @"dm_cabinet";
NSString * const DM_DOCUMENT_TYPE = @"dm_document";
NSString * const OBJECT_NAME = @"object_name";
NSString * const R_CREATION_DATE = @"r_creation_date";
NSString * const R_OBJECT_ID = @"r_object_id";
NSString * const ACL_NAME = @"acl_name";
NSString * const A_CONTENT_TYPE = @"a_content_type";
NSString * const AUTHORS = @"authors";
NSString * const PREVIEW_FORMAT = @"jpeg_preview";
NSString * const LOW_RES_PREVIEW = @"jpeg_lres";
NSString * const FULL_FORMAT = @"full_format";
NSString * const PAGE_MODIFIER = @"page_modifier";
NSString * const CONTENT_SIZE = @"full_content_size";
NSString * const THUMBNAIL_FORMAT = @"jpeg_th";
NSString * const EMPTY_PAGE_MODIFIER = @"";
NSString * const ZEROS_PAGE_MODIFIER = @"000000000";


