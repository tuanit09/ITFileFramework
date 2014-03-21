//
//  ITFileBrowser.m
//  CloudReader
//
//  Created by Tuan Anh Nguyen on 3/20/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "ITFileBrowser.h"

#define kDefaultContentLoadingInfoBufferSize 50

@implementation NSString (ITFileBrowserUtils)

-(NSString *const)contentType
{
    NSString *extension = [[self pathExtension] lowercaseString];
    if (extension) {
        if ([extension isEqualToString:kContentType_pdf]) {
            return kContentType_pdf;
        }
        if ([extension isEqualToString:kContentType_epub]) {
            return kContentType_epub;
        }
    }
    return kContentType_uknown;
}
@end

@interface ITFileBrowser()
@property (assign, nonatomic) BOOL canceled;
@property (strong, nonatomic) NSMutableArray *contentLoadingInfos;
@property (assign, nonatomic) NSInteger folderContentIndex;
@end

@implementation ITFileBrowser
@dynamic userId;

// abstract methods
+(id)fileBrowserForUserId:(NSString *)userId
{
    return nil;
}
-(NSString *)userId
{
    return nil;
}
-(void)loadContentAtPath:(NSString *)path
{
    
}
-(void)loadRecursiveContentAtPath:(NSString *)path
{
    
}
-(void)cancelingTimer:(id)timer
{
    if (self.canceled) {
        [self didCancelAllOperations];
    }
}
-(void)cancelAllOperations
{
    if (recusive) {
        self.canceled = YES;
        [NSTimer scheduledTimerWithTimeInterval:2. target:self selector:@selector(cancelingTimer:) userInfo:nil repeats:NO];
    }
    else
    {
        [self didCancelAllOperations];
    }
}

-(void)didCancelAllOperations
{
    recusive = NO;
    if ([self.delegate respondsToSelector:@selector(ITFileBrowserDidCancelAllOperations:)]) {
        [self.delegate ITFileBrowserDidCancelAllOperations:self];
    }
}

-(void)addContents:(NSArray *)contents forPath:(NSString *)_path
{
    if (contents) {
        if (self.contentLoadingInfos == nil) {
            self.contentLoadingInfos = [NSMutableArray arrayWithCapacity:kDefaultContentLoadingInfoBufferSize];
        }
        NSMutableArray *folders = [NSMutableArray arrayWithCapacity:[contents count] + 1];
        for (NSDictionary *content in contents) { // add child folder name
            if ([content objectForKey:kContentTypeKey] == kContentType_folder) {
                [folders addObject:[content objectForKey:kContentNameKey]];
            }
        }
        if ([folders count]) { // this parent has child folders
            [folders addObject:_path]; // add parent path to last
            NSInteger insertIndex = [self.contentLoadingInfos count]? [self.contentLoadingInfos count] - 1 : 0;
            [self.contentLoadingInfos insertObject:folders atIndex:insertIndex];
        }
    }

    NSArray *loadingFolders = [self.contentLoadingInfos lastObject];
    if (loadingFolders) {
        if (self.folderContentIndex == [loadingFolders count] - 1) {
            self.folderContentIndex = 0;
            [self.contentLoadingInfos removeLastObject];
            [self addContents:nil forPath:nil];
        }
        else
        {
            NSString *newPath = [[loadingFolders lastObject] stringByAppendingPathComponent:[loadingFolders objectAtIndex:self.folderContentIndex]];
            self.folderContentIndex++;
            [self loadRecursiveContentAtPath:newPath];
        }
    }
    else
    {
        [self ITFileBrowserFinishedLoadingContent:self];
    }
}

#pragma -mark File bowser delegate
-(void)ITFileBrowser:(id)fileBrowser loadedPath:(NSString *)_path withContents:(NSArray *)contents error:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(ITFileBrowser:loadedPath:withContents:error:)]) {
        [self.delegate ITFileBrowser:self loadedPath:_path withContents:contents error:error];
    }
    if (self.canceled) {
        [self didCancelAllOperations];
    }
    else if (recusive)
    {
        [self addContents:contents forPath:_path];
    }
    else
    {
        [self ITFileBrowserFinishedLoadingContent:self];
    }
}
-(void)ITFileBrowserFinishedLoadingContent:(id)fileBrowser
{
    recusive = NO;
    if ([self.delegate respondsToSelector:@selector(ITFileBrowserFinishedLoadingContent:)]) {
        [self.delegate ITFileBrowserFinishedLoadingContent:self];
    }
}
@end
