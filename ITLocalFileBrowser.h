//
//  ITLocalFileBrowser.h
//  CloudReader
//
//  Created by Tuan Anh Nguyen on 3/21/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "ITFileBrowser.h"

@interface ITLocalFileBrowser : ITFileBrowser
@property (strong, nonatomic, readonly) NSURL *userHomeURL;
@end
