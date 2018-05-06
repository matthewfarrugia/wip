//
//  Logger.m
//
//  Created by Matthew Farrugia on 06/05/2018.
//  Copyright © 2018 Matthew Farrugia. All rights reserved.
//


#import "Logger.h"
#import <Foundation/Foundation.h>

@implementation Logger

+ (void)logString:(NSString*)message {
    NSLog(@"LOUDER: %@", message);
}

+ (void)logAudioFailure:(NSString*)status withCode:(OSStatus*)result {
    [self logString:[NSString stringWithFormat:@"audioDeviceFailure: (!%@!): withCode: %li", status, (long)result]];
}

+ (void)logAudioSuccess:(NSString *)status {
    [self logString:[NSString stringWithFormat:@"audioDeviceSuccess: (%@)", status]];
}

@end
