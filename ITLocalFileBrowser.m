//
//  ITLocalFileBrowser.m
//  CloudReader
//
//  Created by Tuan Anh Nguyen on 3/21/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "ITLocalFileBrowser.h"
#import "NSURL+ITFileUtils.h"

static NSArray *propertyKeys = nil;

@interface ITLocalFileBrowser()
{
    NSString *userId;
}
@end

@implementation ITLocalFileBrowser
@synthesize userId;

-(id)initWithUserId:(NSString *)_userId
{
    if (self = [super init]) {
        userId = _userId;
        if (propertyKeys == nil) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                if (propertyKeys == nil) {
                    propertyKeys = @[
                                     NSURLNameKey,
                                     NSURLIsDirectoryKey,
                                     NSURLTotalFileSizeKey,
                                     NSURLCreationDateKey,
                                     NSURLContentModificationDateKey
                                     ];
                }
            });
        }
    }
    return self;
}

-(NSURL *)userHomeURL
{
    return [[NSURL urlForDocFolder] URLByAppendingPathComponent:userId? userId : @""];
}

+(id)fileBrowserForUserId:(NSString *)_userId
{
    ITLocalFileBrowser *fileBrowser = [[ITLocalFileBrowser alloc] initWithUserId:_userId];
    [[NSFileManager defaultManager] createDirectoryAtURL:fileBrowser.userHomeURL withIntermediateDirectories:YES attributes:nil error:nil];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileBrowser.userHomeURL.path]) {
        fileBrowser = nil;
    }
    return fileBrowser;
}


// browsing file
-(void)loadRecursiveContentAtPath:(NSString *)_path
{
    recusive = YES;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self loadContentAtPath:_path];
    });
}
-(void)loadContentAtPath:(NSString *)_path
{
    path = _path;

    __block void(^loadContent)(void) = ^{
        NSURL *pathURL = [self.userHomeURL URLByAppendingPathComponent:path];
        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:pathURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:^BOOL(NSURL *url, NSError *error) {
            return YES;
        }];
        NSArray *allObjects = [enumerator allObjects];
        NSMutableArray *contents = nil;
        if ([allObjects count]) {
            contents = [NSMutableArray arrayWithCapacity:[allObjects count]];
        }
        for (NSURL *contentURL in allObjects) {
            NSDictionary *contentInfo = [contentURL resourceValuesForKeys:propertyKeys error:nil];
            BOOL isDirectory = [[contentInfo objectForKey:NSURLIsDirectoryKey] boolValue];
            NSString *contentName = [contentInfo objectForKey:NSURLNameKey];
            NSString *const contentType = [contentName contentType];
            if (isDirectory || contentType != kContentType_uknown) {
                id info = @{
                            kContentNameKey : contentName,
                            kContentTypeKey : isDirectory ? kContentType_folder : contentType,
                            kContentSizeKey : isDirectory ? [NSNumber numberWithLongLong:0] : [contentInfo objectForKey:NSURLTotalFileSizeKey],
                            kContentCreatedDateKey : [contentInfo objectForKey:NSURLCreationDateKey],
                            kContentModifiedDateKey : [contentInfo objectForKey:NSURLContentModificationDateKey],
                            kContentRevKey : [NSNull null]
                            };
                [contents addObject:info];
            }
        };
        if (![contents count]) {
            contents = nil;
        }
        [super ITFileBrowser:self loadedPath:path withContents:contents error:nil];
    };

    if (!recusive) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            loadContent();
        });
    }
    else
    {
        loadContent();
    }
}

-(void)cancelAllOperations
{
    [super cancelAllOperations];
}


// instant methods
-(void)dealloc
{
    userId = nil;
}

@end
