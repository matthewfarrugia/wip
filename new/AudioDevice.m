//
//  audioDevice.m
//  Gettings things
//
//  Created by Matthew Farrugia on 18/02/2018.
//  Copyright © 2018 Matthew Farrugia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioDevice.h"
#import "DeviceUtility.h"

@implementation AudioDevice

@synthesize deviceID = _deviceID;
@synthesize isInput = _isInput;
@synthesize safteyOffset = _safteyOffset;
@synthesize bufferFrameSize = _bufferFrameSize;
@synthesize streamFormat = _streamFormat;
char deviceName[64];

- (id) initWithDeviceID:(AudioDeviceID)deviceID withIsInput:(BOOL)isInput {
    
    _deviceID = deviceID;
    _isInput = isInput;
    
    //******* Device Name
    AudioObjectPropertyAddress propertyAddress;
    propertyAddress.mSelector = kAudioDevicePropertyDeviceName;
    propertyAddress.mElement = kAudioObjectPropertyElementMaster;
    
    if (_isInput){
        propertyAddress.mScope = kAudioDevicePropertyScopeInput;
    } else {
        propertyAddress.mScope = kAudioDevicePropertyScopeOutput;
    }
    
    UInt32 dataSize = sizeof(deviceName);

    OSStatus result = AudioObjectGetPropertyData(_deviceID, &propertyAddress, 0, NULL, &dataSize, &deviceName);
    
    if (result == kAudioHardwareNoError){
        NSLog(@"Initialising Device: %s", deviceName);
    } else {
        NSLog(@"ERROR: %i", result);
    }
    
    //******* Safety Offset
    propertyAddress.mSelector = kAudioDevicePropertySafetyOffset;

    dataSize = sizeof(_safteyOffset);
    
    result = AudioObjectGetPropertyData(_deviceID, &propertyAddress, 0, NULL, &dataSize, &_safteyOffset);
    
    if (result == kAudioHardwareNoError){
        NSLog(@"    Saftey Offset: %i", _safteyOffset);
    } else {
        NSLog(@"ERROR: %i", result);
    }
    
    //******* Buffer Frame Size
    propertyAddress.mSelector = kAudioDevicePropertyBufferFrameSize;
    
    dataSize = sizeof(_bufferFrameSize);
    
    result = AudioObjectGetPropertyData(_deviceID, &propertyAddress, 0, NULL, &dataSize, &_bufferFrameSize);
    
    if (result == kAudioHardwareNoError){
        NSLog(@"    Buffer Frame Size: %i", _bufferFrameSize);
    } else {
        NSLog(@"ERROR: %i", result);
    }
    
    [self updateFormat];

    return self;
}

- (void) updateFormat {
    
    AudioObjectPropertyAddress propertyAddress;
    propertyAddress.mSelector = kAudioDevicePropertyStreamFormat;
    propertyAddress.mElement = kAudioObjectPropertyElementMaster;
    
    if (_isInput){
        propertyAddress.mScope = kAudioDevicePropertyScopeInput;
    } else {
        propertyAddress.mScope = kAudioDevicePropertyScopeOutput;
    }
    
    UInt32 dataSize = sizeof(_streamFormat);
    
    OSStatus result = AudioObjectGetPropertyData(_deviceID, &propertyAddress, 0, NULL, &dataSize, &_streamFormat);
    
    if (result == kAudioHardwareNoError) {
        NSLog(@"    Number of Channels: %i", _streamFormat.mChannelsPerFrame);
        NSLog(@"    Sample Rate: %f", _streamFormat.mSampleRate);
    } else {
        NSLog(@"ERROR receiving stream format: %i", result);
    }
}

@end
