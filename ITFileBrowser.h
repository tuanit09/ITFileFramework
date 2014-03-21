//
//  ITFileBrowser.h
//  CloudReader
//
//  Created by Tuan Anh Nguyen on 3/20/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


// content types
static NSString *kContentType_folder = @"folder";
static NSString *kContentType_pdf = @"pdf";
static NSString *kContentType_epub = @"epub";
static NSString *kContentType_uknown = @"unknown";

// content access keys
static NSString *kContentNameKey = @"contentName"; // string
static NSString *kContentTypeKey = @"contentType"; // string
static NSString *kContentSizeKey = @"contentSize"; // number
static NSString *kContentCreatedDateKey = @"contentCreatedDate"; // date
static NSString *kContentModifiedDateKey = @"contentModifiedDate"; // date
static NSString *kContentRevKey = @"contentRev"; // string

@interface NSString (ITFileBrowserUtils)
-(NSString *const)contentType;
@end

@protocol ITFileBrowserDelegate <NSObject>
@optional
-(void)ITFileBrowser:(id)fileBrowser loadedPath:(NSString *)path withContents:(NSArray *)contents error:(NSError *)error;
-(void)ITFileBrowserFinishedLoadingContent:(id)fileBrowser;
-(void)ITFileBrowserDidCancelAllOperations:(id)fileBrowser;
@end

@interface ITFileBrowser : NSObject<ITFileBrowserDelegate>
{
    BOOL recusive;
    NSString *path;
}
@property (weak, nonatomic) id<ITFileBrowserDelegate>delegate;
@property (strong, nonatomic, readonly) NSString *userId;

// class method
+(id)fileBrowserForUserId:(NSString *)userId;
// browsing methods
-(void)loadRecursiveContentAtPath:(NSString *)path;
-(void)loadContentAtPath:(NSString *)path;
-(void)cancelAllOperations;
@end
