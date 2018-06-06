//
//  FileHelper.m
//  KotakPOC
//
//  Created by Harish Pathak on 04/06/18.
//  Copyright © 2018 CRMNEXT. All rights reserved.
//

#import "FileHelper.h"
#import <UIKit/UIKit.h>


@implementation FileHelper

+(BOOL)deleteFileAtPath:(NSString *)filePath{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    return success;
}

+(BOOL)createDirectoryAtPath:(NSString *)path{
    BOOL isDir;
    NSFileManager *fileManager= [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:path isDirectory:&isDir]){
        if(![fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL]){
            NSLog(@"Error: Create folder failed at %@", path);
            return NO;
        }else return YES;
    }else{
        NSLog(@"Directory already exists at %@", path);
        return YES;
    }
}

+(NSMutableArray *)listFileAtPath:(NSString *)path
{
    
    int count;
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    for (count = 0; count < (int)[directoryContent count]; count++)
    {
        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
    }
    
    NSLog(@"Content count at path: %@ : %d", path, count);
    
    return [NSMutableArray arrayWithArray:directoryContent];
}

+(void)saveImagesToDirectory:(NSMutableArray *)arrImages andPath:(NSString *)fileDirectoryPath{
    if (arrImages.count) {
        
        if([FileHelper createDirectoryAtPath:fileDirectoryPath]){
            for (UIImage *image in arrImages) {
                
                NSString *timestamp = [FileHelper getUniqueName:@"img_"];
                NSString *fileName = [NSString stringWithFormat:@"%@.jpg",timestamp];
                NSData *jpgData = UIImageJPEGRepresentation(image, 0.9);
                NSString *filePath = [fileDirectoryPath stringByAppendingPathComponent:fileName]; //Add the file name
                [jpgData writeToFile:filePath atomically:YES]; //Write the file
                
            }
        }
        
    }
    
}

+(NSString *)getUniqueName:(NSString *)prefix{
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDateFormatter *dateFormatter = delegate.dateFormatter;
    [dateFormatter setDateFormat:@"yymmddhhmmssSSS"];
    
    NSString *uuid = [dateFormatter stringFromDate:[NSDate date]];//[[NSUUID UUID] UUIDString];
    return [prefix stringByAppendingString:uuid];
}


@end
