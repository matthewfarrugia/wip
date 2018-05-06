//
//  AudioDevice.m
//
//  Created by Matthew Farrugia on 18/02/2018.
//  Copyright © 2018 Matthew Farrugia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioDevice.h"
#import "DeviceUtility.h"

@implementation AudioDevice

@synthesize deviceID;
@synthesize isInput;
@synthesize safteyOffset;
@synthesize bufferFrameSize;
@synthesize streamFormat;

char deviceName[64];

- (id)initWithDeviceID:(AudioDeviceID)inDeviceID withIsInput:(BOOL)inIsInput {
    
    deviceID = inDeviceID;
    isInput = inIsInput;
    
    //******* Device Name
    AudioObjectPropertyAddress propertyAddress;
    propertyAddress.mSelector = kAudioDevicePropertyDeviceName;
    propertyAddress.mElement = kAudioObjectPropertyElementMaster;
    
    if (isInput){
        propertyAddress.mScope = kAudioDevicePropertyScopeInput;
    } else {
        propertyAddress.mScope = kAudioDevicePropertyScopeOutput;
    }
    
    UInt32 dataSize = sizeof(deviceName);

    OSStatus result = AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, NULL, &dataSize, &deviceName);
    
    if (result == kAudioHardwareNoError){
        NSLog(@"Initialising Device: %s", deviceName);
    } else {
        NSLog(@"ERROR: %i", result);
    }
    
    //******* Safety Offset
    propertyAddress.mSelector = kAudioDevicePropertySafetyOffset;

    dataSize = sizeof(safteyOffset);
    
    result = AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, NULL, &dataSize, &safteyOffset);
    
    if (result == kAudioHardwareNoError){
        NSLog(@"    Saftey Offset: %i", safteyOffset);
    } else {
        NSLog(@"ERROR: %i", result);
    }
    
    //******* Buffer Frame Size
    propertyAddress.mSelector = kAudioDevicePropertyBufferFrameSize;
    
    dataSize = sizeof(bufferFrameSize);
    
    result = AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, NULL, &dataSize, &bufferFrameSize);
    
    if (result == kAudioHardwareNoError){
        NSLog(@"    Buffer Frame Size: %i", bufferFrameSize);
    } else {
        NSLog(@"ERROR: %i", result);
    }
    
    [self updateFormat];

    return self;
}

- (void)updateFormat {
    
    AudioObjectPropertyAddress propertyAddress;
    propertyAddress.mSelector = kAudioDevicePropertyStreamFormat;
    propertyAddress.mElement = kAudioObjectPropertyElementMaster;
    
    if (isInput){
        propertyAddress.mScope = kAudioDevicePropertyScopeInput;
    } else {
        propertyAddress.mScope = kAudioDevicePropertyScopeOutput;
    }
    
    UInt32 dataSize = sizeof(streamFormat);
    
    OSStatus result = AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, NULL, &dataSize, &streamFormat);
    
    if (result == kAudioHardwareNoError) {
        NSLog(@"    Number of Channels: %i", streamFormat.mChannelsPerFrame);
        NSLog(@"    Sample Rate: %f", streamFormat.mSampleRate);
    } else {
        NSLog(@"ERROR receiving stream format: %i", result);
    }
}

@end
