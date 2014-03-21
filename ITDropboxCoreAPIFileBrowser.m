//
//  ITDropboxCoreAPIFileBrowser.m
//  CloudReader
//
//  Created by Tuan Anh Nguyen on 3/20/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "ITDropboxCoreAPIFileBrowser.h"
#import <DropboxSDK/DropboxSDK.h>
#import "DBSession+ITFileUtils.h"

@interface ITRestClient : DBRestClient
@end
@implementation ITRestClient
-(NSString *)userId
{
    return userId;
}
@end

@interface ITDropboxCoreAPIFileBrowser()<DBRestClientDelegate>
@property (strong, nonatomic) ITRestClient *restClient;
@end


@implementation ITDropboxCoreAPIFileBrowser

// setters / getters
-(NSString *)userId
{
    return [self.restClient userId];
}

// classs methods

+(id)fileBrowserForUserId:(NSString *)userId
{
    ITDropboxCoreAPIFileBrowser *fileBrowser = nil;
    if ([DBSession isUserLinked:userId]) {
        fileBrowser = [ITDropboxCoreAPIFileBrowser new];
        fileBrowser.restClient = [[ITRestClient alloc] initWithSession:[DBSession sharedSession] userId:userId];
        fileBrowser.restClient.delegate = fileBrowser;
    }
    return fileBrowser;
}

// browsing file
-(void)loadRecursiveContentAtPath:(NSString *)_path
{
    recusive = YES;
    [self loadContentAtPath:_path];
}
-(void)loadContentAtPath:(NSString *)_path
{
    path = _path;
    [self.restClient loadMetadata:_path];
}

-(void)cancelAllOperations
{
    [self.restClient cancelAllRequests];
    [super cancelAllOperations];
}


// instant methods
-(void)dealloc
{
    self.restClient.delegate = nil;
    [self.restClient cancelAllRequests];
    self.restClient = nil;
}

#pragma -mark Rest Client Delegate
-(void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata
{
    NSMutableArray *contents = nil;
    if ([metadata.contents count]) {
        contents = [NSMutableArray arrayWithCapacity:[metadata.contents count]];
        for (DBMetadata *meta in metadata.contents) {
            id info = @{
                        kContentNameKey : meta.filename,
                        kContentTypeKey : meta.isDirectory ? kContentType_folder : [meta.filename contentType],
                        kContentSizeKey : [NSNumber numberWithLongLong:meta.totalBytes],
                        kContentCreatedDateKey : [NSNull null],
                        kContentModifiedDateKey : meta.lastModifiedDate,
                        kContentRevKey : meta.rev
                        };
            [contents addObject:info];
        }
    }
    [super ITFileBrowser:self loadedPath:path withContents:contents error:nil];
}

-(void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error
{
    [super ITFileBrowser:self loadedPath:path withContents:nil error:error];
}
@end
