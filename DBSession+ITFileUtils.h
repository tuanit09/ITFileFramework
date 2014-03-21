//
//  DBSession+ITFileUtils.h
//  CloudReader
//
//  Created by Tuan Anh Nguyen on 3/20/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <DropboxSDK/DropboxSDK.h>

@interface DBSession (ITFileUtils)

+(BOOL)createSharedSessionWithAppKey:(NSString *)appKey appSecrete:(NSString *)appSecrete root:(NSString *) root;
+(BOOL)isUserLinked:(NSString *)userId;
+(BOOL)isDropboxURLScheme:(NSURL *)url;
+(BOOL)handleOpenURL:(NSURL *)url;
@end
