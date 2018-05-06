//
//  Logger.h
//
//  Created by Matthew Farrugia on 06/05/2018.
//  Copyright © 2018 Matthew Farrugia. All rights reserved.
//

#ifndef Logger_h
#define Logger_h

#import <Foundation/Foundation.h>

@interface Logger : NSObject

+ (void)logString:(NSString*)message;
+ (void)logAudioFailure:(NSString*)status withCode:(OSStatus*)result;
+ (void)logAudioSuccess:(NSString*)status;


@end

#endif /* Logger_h */
