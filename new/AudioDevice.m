//
//  AudioDevice.m
//
//  Created by Matthew Farrugia on 18/02/2018.
//  Copyright © 2018 Matthew Farrugia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Logger.h"
#import "AudioDevice.h"
#import "DeviceUtility.h"

@implementation AudioDevice

@synthesize deviceID;
@synthesize deviceName;
@synthesize isInput;
@synthesize safteyOffset;
@synthesize bufferFrameSize;
@synthesize streamFormat;

- (id)initWithDeviceID:(AudioDeviceID)inDeviceID withInput:(BOOL)inIsInput {
    
    deviceID = inDeviceID;
    isInput = inIsInput;
    
    deviceName = [DeviceUtility getDeviceName:deviceID withInput:isInput];
    safteyOffset = [DeviceUtility getSafteyOffset:deviceID withInput:isInput];
    bufferFrameSize = [DeviceUtility getBufferFrameSize:deviceID withInput:isInput];

    [self updateFormat];

    return self;
}

- (void)updateFormat {
    streamFormat = [DeviceUtility getStreamFormat:deviceID withInput:isInput];
}

@end
