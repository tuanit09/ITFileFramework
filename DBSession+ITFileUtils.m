//
//  DBSession+ITFileUtils.m
//  CloudReader
//
//  Created by Tuan Anh Nguyen on 3/20/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "DBSession+ITFileUtils.h"
#import <DropboxSDK/DropboxSDK.h>

static NSString *urlScheme;

@implementation DBSession (ITFileUtils)

// classs methods
+(BOOL)createSharedSessionWithAppKey:(NSString *)appKey appSecrete:(NSString *)appSecrete root:(NSString *) root
{
    urlScheme = [NSString stringWithFormat:@"db-%@", appKey];
    DBSession *session = [[DBSession alloc] initWithAppKey:appKey appSecret:appSecrete root:root];
    [DBSession setSharedSession:session];
    return (session != nil);
}

+(BOOL)isUserLinked:(NSString *)userID
{
    DBSession *session = [DBSession sharedSession];
    if (session) {
        for (NSString *linkedUserID in session.userIds) {
            if ([linkedUserID isEqualToString:userID]) {
                return YES;
            }
        }
    }
    return NO;
}

+(BOOL)isDropboxURLScheme:(NSURL *)url
{
    return [url.absoluteString hasPrefix:urlScheme];
}

+(BOOL)handleOpenURL:(NSURL *)url
{
    return [[DBSession sharedSession] handleOpenURL:url];
}
@end
