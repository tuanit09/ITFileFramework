//
//  NSURL+ITFileUtils.h
//  CloudReader
//
//  Created by Tuan Anh Nguyen on 3/21/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (ITFileUtils)
+(NSURL *)urlForDocFolder;
+(NSURL *)urlForTempFolder;
@end
