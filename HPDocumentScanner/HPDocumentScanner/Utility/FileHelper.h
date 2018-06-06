//
//  FileHelper.h
//  KotakPOC
//
//  Created by Harish Pathak on 04/06/18.
//  Copyright © 2018 CRMNEXT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface FileHelper : NSObject

+(BOOL)deleteFileAtPath:(NSString *)filePath;
+(BOOL)createDirectoryAtPath:(NSString *)path;
+(NSMutableArray *)listFileAtPath:(NSString *)path;
+(void)saveImagesToDirectory:(NSMutableArray *)arrImages andPath:(NSString *)fileDirectoryPath;
+(NSString *)getUniqueName:(NSString *)prefix;

@end
