//
//  DeviceUtility.m
//
//  Created by Matthew Farrugia on 18/02/2018.
//  Copyright © 2018 Matthew Farrugia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudio.h>
#import "DeviceUtility.h"

@implementation DeviceUtility

@synthesize defaultInputDeviceID;
@synthesize defaultOutputDeviceID;

- (id)init {
    [self fetchDefaultInputDeviceID];
    [self fetchDefaultOutputDeviceID];
    return self;
}

- (void)getDeviceInfo:(AudioDeviceID)deviceID {
    AudioObjectPropertyAddress deviceAddress;
    char    deviceName[64];
    char    manufacturerName[64];
    
    UInt32 dataSize = sizeof(deviceName);
    deviceAddress.mSelector = kAudioDevicePropertyDeviceName;
    deviceAddress.mScope = kAudioObjectPropertyScopeGlobal;
    deviceAddress.mElement = kAudioObjectPropertyElementMaster;
    
    if (AudioObjectGetPropertyData(deviceID, &deviceAddress, 0, NULL, &dataSize, deviceName) == noErr) {
        dataSize = sizeof(manufacturerName);
        deviceAddress.mSelector = kAudioDevicePropertyDeviceManufacturer;
        
        if (AudioObjectGetPropertyData(deviceID, &deviceAddress, 0, NULL, &dataSize, manufacturerName) == noErr) {
            CFStringRef uidString;
            
            dataSize = sizeof(uidString);
            deviceAddress.mSelector = kAudioDevicePropertyDeviceUID;

            if (AudioObjectGetPropertyData(deviceID, &deviceAddress, 0, NULL, &dataSize, &uidString) == noErr) {
                NSLog(@"Output Device: %s by %s id: %@", deviceName, manufacturerName, uidString);
                CFRelease(uidString);
//              OSStatus theError = AudioDeviceCreateIOProcID(deviceIDs[number], MyIOProc, NULL, &theIOProcID);
//                    //  start IO
//                    theError = AudioDeviceStart(deviceIDs[number], theIOProcID);
//
//                    Float32 output = NewGetVolumeScalar(deviceIDs[number], FALSE, 0);
//
//                    NSLog(@"%f", output);
//                    //  stop IO
//                    theError = AudioDeviceStop(deviceIDs[number], theIOProcID);
//
//                    //  unregister the IOProc
//                    theError = AudioDeviceDestroyIOProcID(deviceIDs[number], theIOProcID);
            }
        }
    }
}

- (void)fetchDefaultOutputDeviceID {
    AudioObjectPropertyAddress getDefaultOutputDevicePropertyAddress = {
        kAudioHardwarePropertyDefaultOutputDevice,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMaster
    };
    
    AudioDeviceID defaultOutputDeviceID;
    UInt32 dataSize = sizeof(defaultOutputDeviceID);

    OSStatus result = AudioObjectGetPropertyData(kAudioObjectSystemObject,
                                                 &getDefaultOutputDevicePropertyAddress,
                                                 0, NULL,
                                                 &dataSize, &defaultOutputDeviceID);
    if(kAudioHardwareNoError != result)
    {

    } else {
        [self getDeviceInfo:defaultOutputDeviceID];
        self.defaultOutputDeviceID = defaultOutputDeviceID;
    }
}

- (void)fetchDefaultInputDeviceID {
    AudioObjectPropertyAddress getDefaultOutputDevicePropertyAddress = {
        kAudioHardwarePropertyDefaultInputDevice,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMaster
    };
    
    AudioDeviceID defaultInputDeviceID;
    UInt32 dataSize = sizeof(defaultInputDeviceID);
    
    OSStatus result = AudioObjectGetPropertyData(kAudioObjectSystemObject,
                                                 &getDefaultOutputDevicePropertyAddress,
                                                 0, NULL,
                                                 &dataSize, &defaultInputDeviceID);
    if(kAudioHardwareNoError != result)
    {
        
    } else {
        [self getDeviceInfo:defaultInputDeviceID];
        self.defaultInputDeviceID = defaultInputDeviceID;
    }
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
    
    for(int i = 1; i<=numOfChannels; i++)
    {
        volumePropertyAddress.mElement = i;

        OSStatus result = AudioObjectSetPropertyData(defaultOutputDeviceID, &volumePropertyAddress, 0, NULL, dataSize, &volume);

        if (result != kAudioHardwareNoError) {
            NSLog(@"%i", result);
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
        NSLog(@"%i", result);
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
        NSLog(@"%i", result);
        return 0;
    } else {
        NSLog(@"%i", bufferSize);
        return bufferSize;
    }
}

@end
