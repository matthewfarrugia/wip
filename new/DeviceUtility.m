//
//  DeviceUtility.m
//
//  Created by Matthew Farrugia on 18/02/2018.
//  Copyright © 2018 Matthew Farrugia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudio.h>
#import "Logger.h"
#import "DeviceUtility.h"

@implementation DeviceUtility

@synthesize defaultInputDeviceID;
@synthesize defaultOutputDeviceID;

- (id)init {
    [self fetchDefaultDeviceID:TRUE];
    [self fetchDefaultDeviceID:FALSE];
    return self;
}

- (void)logDeviceInfo:(AudioDeviceID)deviceID {
    
    char    deviceName[64];
    char    manufacturerName[64];
    UInt32 dataSize = sizeof(deviceName);
    
    AudioObjectPropertyAddress deviceAddress = {
        kAudioDevicePropertyDeviceName,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMaster
    };
    
    if (AudioObjectGetPropertyData(deviceID, &deviceAddress, 0, NULL, &dataSize, deviceName) == noErr) {
        
        dataSize = sizeof(manufacturerName);
        deviceAddress.mSelector = kAudioDevicePropertyDeviceManufacturer;
        
        if (AudioObjectGetPropertyData(deviceID, &deviceAddress, 0, NULL, &dataSize, manufacturerName) == noErr) {
            
            CFStringRef uidString;
            dataSize = sizeof(uidString);
            deviceAddress.mSelector = kAudioDevicePropertyDeviceUID;

            if (AudioObjectGetPropertyData(deviceID, &deviceAddress, 0, NULL, &dataSize, &uidString) == noErr) {
                
                [Logger logString:[NSString stringWithFormat:@"Device: %s by %s id: %@", deviceName, manufacturerName, uidString]];
                 
                CFRelease(uidString);

            }
        }
    }
}

- (void)fetchDefaultDeviceID:(BOOL)isInput {
    
    AudioObjectPropertyAddress defaultDevicePropertyAddress = {
        isInput ? kAudioHardwarePropertyDefaultInputDevice : kAudioHardwarePropertyDefaultOutputDevice,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMaster
    };
    
    AudioDeviceID defaultDeviceID;
    UInt32 dataSize = sizeof(defaultDeviceID);

    OSStatus result = AudioObjectGetPropertyData(kAudioObjectSystemObject,
                                                 &defaultDevicePropertyAddress,
                                                 0, NULL,
                                                 &dataSize, &defaultDeviceID);
    
    if (result != kAudioHardwareNoError) {
        [Logger logAudioFailure:@"Fetching Audio Device ID" withCode: &result];
    } else {
        [self logDeviceInfo:defaultDeviceID];
        if (isInput) {
            self.defaultInputDeviceID = defaultDeviceID;
        } else {
            self.defaultOutputDeviceID = defaultDeviceID;
        }
    }
}

+ (NSString*)getDeviceName:(AudioDeviceID)deviceID withInput:(BOOL)isInput {
    
    char deviceName[64];
    
    AudioObjectPropertyAddress propertyAddress = {
        kAudioDevicePropertyDeviceName,
        isInput ? kAudioDevicePropertyScopeInput : kAudioDevicePropertyScopeOutput,
        kAudioObjectPropertyElementMaster
    };
    
    UInt32 dataSize = sizeof(deviceName);
    OSStatus result = AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, NULL, &dataSize, &deviceName);
    
    if (result != kAudioHardwareNoError) {
        [Logger logAudioFailure:@"Getting Device Name" withCode:&result];
    } else {
        [Logger logString:[NSString stringWithFormat:@"%s", deviceName]];
    }
    
    return [NSString stringWithFormat:@"%s", deviceName];
}

+ (UInt32)getSafteyOffset:(AudioDeviceID)deviceID withInput:(BOOL)isInput {

    UInt32 safteyOffset;
    
    AudioObjectPropertyAddress propertyAddress = {
        kAudioDevicePropertySafetyOffset,
        isInput ? kAudioDevicePropertyScopeInput : kAudioDevicePropertyScopeOutput,
        kAudioObjectPropertyElementMaster
    };
    
    UInt32 dataSize = sizeof(safteyOffset);
    OSStatus result = AudioObjectGetPropertyData(deviceID,
                                                 &propertyAddress,
                                                 0, NULL,
                                                 &dataSize,
                                                 &safteyOffset);
    
    if (result != kAudioHardwareNoError) {
        [Logger logAudioFailure:@"Getting Saftey Offset" withCode:&result];
    } else {
        [Logger logString:[NSString stringWithFormat:@"    Saftey Offset: %i", safteyOffset]];
    }
    
    return safteyOffset;
}

+ (UInt32)getBufferFrameSize:(AudioDeviceID)deviceID withInput:(BOOL)isInput {
    
    UInt32 bufferFrameSize;
    
    AudioObjectPropertyAddress propertyAddress = {
        kAudioDevicePropertyBufferFrameSize,
        isInput ? kAudioDevicePropertyScopeInput : kAudioDevicePropertyScopeOutput,
        kAudioObjectPropertyElementMaster
    };
    
    UInt32 dataSize = sizeof(bufferFrameSize);
    OSStatus result = AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, NULL, &dataSize, &bufferFrameSize);
    
    if (result != kAudioHardwareNoError) {
        [Logger logAudioFailure:@"Getting Buffer Frame Size" withCode:&result];
    } else {
        [Logger logString:[NSString stringWithFormat:@"    Buffer Frame Size: %i", bufferFrameSize]];
    }
    
    return bufferFrameSize;
}

+ (AudioStreamBasicDescription)getStreamFormat:(AudioDeviceID)deviceID withInput:(BOOL)isInput {
    
    AudioStreamBasicDescription streamFormat;
    
    AudioObjectPropertyAddress propertyAddress = {
        kAudioDevicePropertyStreamFormat,
        isInput ? kAudioDevicePropertyScopeInput : kAudioDevicePropertyScopeOutput,
        kAudioObjectPropertyElementMaster
    };
    
    UInt32 dataSize = sizeof(streamFormat);
    OSStatus result = AudioObjectGetPropertyData(deviceID,
                                                 &propertyAddress,
                                                 0, NULL,
                                                 &dataSize,
                                                 &streamFormat);
    
    if (result != kAudioHardwareNoError) {
        [Logger logAudioFailure:@"Getting Stream Format" withCode:&result];
    } else {
        [Logger logString:[NSString stringWithFormat:@"    Number of Channels: %i", streamFormat.mChannelsPerFrame]];
        [Logger logString:[NSString stringWithFormat:@"    Sample Rate: %f", streamFormat.mSampleRate]];
    }
    
    return streamFormat;
}

- (Float32)getDefaultOutputDeviceVolume {
    AudioDeviceID defaultOutputDeviceID = self.defaultOutputDeviceID;
    
    AudioObjectPropertyAddress volumePropertyAddress = {
        kAudioDevicePropertyVolumeScalar,
        kAudioDevicePropertyScopeOutput,
        1
    };
    
    Float32 volume;
    UInt32 dataSize = sizeof(volume);

    OSStatus result = AudioObjectGetPropertyData(defaultOutputDeviceID,
                                        &volumePropertyAddress,
                                        0, NULL,
                                        &dataSize, &volume);
    
    if (result != kAudioHardwareNoError) {
        return result;
    } else {
        return volume;
    }
}

- (void)setDefaultOutputDeviceVolume:(Float32)newVolume {
    AudioDeviceID defaultOutputDeviceID = self.defaultOutputDeviceID;

    AudioStreamBasicDescription audioFormat = [self getDefaultStreamDescription];
    UInt32 numOfChannels = audioFormat.mChannelsPerFrame;
    
    Float32 volume = newVolume;
    UInt32 dataSize = sizeof(volume);
    
    AudioObjectPropertyAddress volumePropertyAddress;
    volumePropertyAddress.mSelector = kAudioDevicePropertyVolumeScalar;
    volumePropertyAddress.mScope = kAudioDevicePropertyScopeOutput;
    
    for (int i = 1; i<=numOfChannels; i++) {
        volumePropertyAddress.mElement = i;

        OSStatus result = AudioObjectSetPropertyData(defaultOutputDeviceID, &volumePropertyAddress, 0, NULL, dataSize, &volume);

        if (result != kAudioHardwareNoError) {
            [Logger logAudioFailure:@"Setting Default Device Volume" withCode:&result];
        }
    }
}

- (AudioStreamBasicDescription)getDefaultStreamDescription {
    AudioDeviceID defaultOutputDeviceID = self.defaultOutputDeviceID;
    
    AudioObjectPropertyAddress channelPropertyAddress;
    channelPropertyAddress.mSelector = kAudioDevicePropertyStreamFormat;
    channelPropertyAddress.mScope = kAudioDevicePropertyScopeOutput;
    channelPropertyAddress.mElement = kAudioObjectPropertyElementMaster;
    
    AudioStreamBasicDescription format;
    UInt32 dataSize = sizeof(format);
    
    OSStatus result = AudioObjectGetPropertyData(defaultOutputDeviceID, &channelPropertyAddress, 0, NULL, &dataSize, &format);
    
    if (result != kAudioHardwareNoError) {
        [Logger logAudioFailure:@"Getting Default Stream Description" withCode:&result];
        return format;
    } else {
        return format;
    }
}

- (UInt32)getBufferSizes:(AudioDeviceID)outputDeviceID {
    AudioObjectPropertyAddress channelPropertyAddress;
    channelPropertyAddress.mSelector = kAudioDevicePropertyBufferSize;
    channelPropertyAddress.mScope = kAudioDevicePropertyScopeOutput;
    channelPropertyAddress.mElement = kAudioObjectPropertyElementMaster;
    
    UInt32 bufferSize;
    UInt32 dataSize = sizeof(bufferSize);
    
    OSStatus result = AudioObjectGetPropertyData(outputDeviceID, &channelPropertyAddress, 0, NULL, &dataSize, &bufferSize);
    
    if (result != kAudioHardwareNoError) {
        [Logger logAudioFailure:@"Getting Output Device ID" withCode:&result];
        return 0;
    } else {
        NSLog(@"%i", bufferSize);
        return bufferSize;
    }
}

@end
