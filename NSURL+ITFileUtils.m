//
//  NSURL+ITFileUtils.m
//  CloudReader
//
//  Created by Tuan Anh Nguyen on 3/21/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "NSURL+ITFileUtils.h"

static NSData *docBookmarkData = nil;
static NSData *tempBookmarkData = nil;

@implementation NSURL (ITFileUtils)

+(NSString *)pathForDocDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+(NSData *)bookmarkDataForFolder:(NSString *)path
{
    return [[NSURL fileURLWithPath:path isDirectory:YES] bookmarkDataWithOptions:NSURLBookmarkCreationMinimalBookmark includingResourceValuesForKeys:nil relativeToURL:nil error:nil];
}

+(NSData *)bookmarkDataForDocFolder
{
    if (docBookmarkData == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (docBookmarkData == nil) {
                docBookmarkData = [self bookmarkDataForFolder:[self pathForDocDirectory]];
            }
        });
    }
    return docBookmarkData;
}

+(NSData *)bookmarkDataForTempFolder
{
    if (tempBookmarkData == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (tempBookmarkData == nil) {
                tempBookmarkData = [self bookmarkDataForFolder:NSTemporaryDirectory()];
            }
        });
    }
    return tempBookmarkData;
}
+(NSURL *)urlForBookmarkData:(NSData *)data
{
    return [NSURL URLByResolvingBookmarkData:data options:NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:NULL error:nil];
}

+(NSURL *)urlForDocFolder
{
    return [self urlForBookmarkData:[self bookmarkDataForDocFolder]];
}

+(NSURL *)urlForTempFolder
{
    return [self urlForBookmarkData:[self bookmarkDataForTempFolder]];
}

@end
