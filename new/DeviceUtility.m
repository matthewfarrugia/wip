//
//  deviceUtility.m
//  getAudio
//
//  Created by Matthew Farrugia on 18/02/2018.
//  Copyright © 2018 Matthew Farrugia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudio.h>
#import "DeviceUtility.h"

@implementation DeviceUtility

//Byte mWorkBuf;

+ (void) initialize {
}

+ (void) getDeviceInfo:(AudioDeviceID)deviceID {
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
OSStatus MyIOProc(AudioDeviceID           inDevice,
                  const AudioTimeStamp*   inNow,
                  const AudioBufferList*  inInputData,
                  const AudioTimeStamp*   inInputTime,
                  AudioBufferList*        outOutputData,
                  const AudioTimeStamp*   inOutputTime,
                  void*                   inClientData)
{
    return 0;
}


- (AudioDeviceID)getDefaultOutputDeviceID
{
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
        return result;
    } else {
        [DeviceUtility getDeviceInfo:defaultOutputDeviceID];
        return defaultOutputDeviceID;
    }
}

- (AudioDeviceID)getDefaultInputDeviceID
{
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
        return result;
    } else {
        [DeviceUtility getDeviceInfo:defaultInputDeviceID];
        return defaultInputDeviceID;
    }
}

- (Float32) getDefaultOutputDeviceVolume
{
    AudioDeviceID defaultOutputDeviceID = [self getDefaultOutputDeviceID];
    
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

- (void) setDefaultOutputDeviceVolume:(Float32)newVolume
{
    AudioDeviceID defaultOutputDeviceID = [self getDefaultOutputDeviceID];

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

- (AudioStreamBasicDescription) getDefaultStreamDescription
{
    AudioDeviceID defaultOutputDeviceID = [self getDefaultOutputDeviceID];
    
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
+ (UInt32)getBufferSizes:(AudioDeviceID)outputDeviceID
{
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
//- (void)startAudio:(AudioDeviceID)outputDeviceID withInputID:(AudioDeviceID)InputDeviceID
//{
//    NSLog(@"WE START");
//    
//    AudioObjectPropertyAddress channelPropertyAddress;
//    channelPropertyAddress.mSelector = kAudioDevicePropertyBufferFrameSize;
//    channelPropertyAddress.mScope = kAudioDevicePropertyScopeOutput;
//    channelPropertyAddress.mElement = kAudioObjectPropertyElementMaster;
//    
//    UInt32 bufferFrameSize;
//    UInt32 dataSize = sizeof(bufferFrameSize);
//    
//    OSStatus result = AudioObjectGetPropertyData(outputDeviceID, &channelPropertyAddress, 0, NULL, &dataSize, &bufferFrameSize);
//    
//    channelPropertyAddress.mSelector = kAudioDevicePropertyStreamFormat;
//    
//    AudioStreamBasicDescription format;
//    dataSize = sizeof(format);
//    
//    result = AudioObjectGetPropertyData(outputDeviceID, &channelPropertyAddress, 0, NULL, &dataSize, &format);
//    
////
////    mWorkBuf = bufferFrameSize * format.mBytesPerFrame;
////    NSLog(@"print");
////    memset(mWorkBuf, 0, bufferFrameSize * format.mBytesPerFrame);
//
//    AudioDeviceIOProc mOutputIOProc = OutputIOProc;
//    AudioDeviceIOProcID mOutputIOProcID = NULL;
//    AudioDeviceCreateIOProcID(outputDeviceID, mOutputIOProc, NULL, &mOutputIOProcID);
//    AudioDeviceStart(outputDeviceID, mOutputIOProcID);
//    
//    AudioDeviceIOProc mInputIOProc = InputIOProc;
//    AudioDeviceIOProcID mInputIOProcID = NULL;
//    AudioDeviceCreateIOProcID(InputDeviceID, mInputIOProc, NULL, &mInputIOProcID);
//    AudioDeviceStart(InputDeviceID, mInputIOProcID);
//    
//}
//OSStatus OutputIOProc(AudioDeviceID inDevice, const AudioTimeStamp *inNow, const AudioBufferList *inInputData, const AudioTimeStamp *inInputTime, AudioBufferList *outOutputData, const AudioTimeStamp *inOutputTime, void *inClientData) {
//    for(UInt32 i=0; i<outOutputData->mNumberBuffers; i++){
//        UInt32 bytesToCopy = inInputData->mBuffers[i].mDataByteSize;
//        memcpy(outOutputData->mBuffers[i].mData, inInputData->mBuffers[i].mData, bytesToCopy);
//    }
//    return noErr;
//}

//OSStatus InputIOProc(AudioDeviceID inDevice, const AudioTimeStamp *inNow, const AudioBufferList *inInputData, const AudioTimeStamp *inInputTime, AudioBufferList *outOutputData, const AudioTimeStamp *inOutputTime, void *inClientData) {
////    for(UInt32 i=0; i<outOutputData->mNumberBuffers; i++){
////        UInt32 bytesToCopy = inInputData->mBuffers[i].mDataByteSize;
////        memcpy(outOutputData->mBuffers[i].mData, inInputData->mBuffers[i].mData, bytesToCopy);
////    }
//    return noErr;
//}

//AudioTee::AudioTee(AudioDeviceID inputDeviceID, AudioDeviceID outputDeviceID) : mInputDevice(inputDeviceID, true), mOutputDevice(outputDeviceID, false), mSecondsInHistoryBuffer(20), mWorkBuf(NULL), mHistBuf(), mHistoryBufferMaxByteSize(0), mBufferSize(1024), mHistoryBufferByteSize(0), mHistoryBufferHeadOffsetFrameNumber(0) {
//    mInputDevice.SetBufferSize(mBufferSize);
//    mOutputDevice.SetBufferSize(mBufferSize);
//}
//
//void AudioTee::start() {
//    if (mInputDevice.mID == kAudioDeviceUnknown || mOutputDevice.mID == kAudioDeviceUnknown) return;
//    if (mInputDevice.mFormat.mSampleRate != mOutputDevice.mFormat.mSampleRate) {
//        printf("Error in AudioTee::Start() - sample rate mismatch: %f / %f\n", mInputDevice.mFormat.mSampleRate, mOutputDevice.mFormat.mSampleRate);
//        return;
//    }
//    mWorkBuf = new Byte[mInputDevice.mBufferSizeFrames * mInputDevice.mFormat.mBytesPerFrame];
//    memset(mWorkBuf, 0, mInputDevice.mBufferSizeFrames * mInputDevice.mFormat.mBytesPerFrame);
//    UInt32 framesInHistoryBuffer = NextPowerOfTwo(mInputDevice.mFormat.mSampleRate * mSecondsInHistoryBuffer);
//    mHistoryBufferMaxByteSize = mInputDevice.mFormat.mBytesPerFrame * framesInHistoryBuffer;
//    mHistBuf = new CARingBuffer();
//    mHistBuf->Allocate(2, mInputDevice.mFormat.mBytesPerFrame, framesInHistoryBuffer);
//    printf("Initializing history buffer with byte capacity %u — %f seconds at %f kHz", mHistoryBufferMaxByteSize, (mHistoryBufferMaxByteSize / mInputDevice.mFormat.mSampleRate / (4 * 2)), mInputDevice.mFormat.mSampleRate);
//    printf("Initializing work buffer with mBufferSizeFrames:%u and mBytesPerFrame %u\n", mInputDevice.mBufferSizeFrames, mInputDevice.mFormat.mBytesPerFrame);
//    mInputIOProcID = NULL;
//    AudioDeviceCreateIOProcID(mInputDevice.mID, InputIOProc, this, &mInputIOProcID);
//    AudioDeviceStart(mInputDevice.mID, mInputIOProcID);
//    mOutputIOProc = OutputIOProc;
//    mOutputIOProcID = NULL;
//    AudioDeviceCreateIOProcID(mOutputDevice.mID, mOutputIOProc, this, &mOutputIOProcID);
//    AudioDeviceStart(mOutputDevice.mID, mOutputIOProcID);
//}
//
//void AudioTee::stop() {
//    AudioDeviceStop(mInputDevice.mID, mInputIOProcID);
//    AudioDeviceDestroyIOProcID(mInputDevice.mID, mInputIOProcID);
//    AudioDeviceStop(mOutputDevice.mID, mOutputIOProcID);
//    AudioDeviceDestroyIOProcID(mOutputDevice.mID, mOutputIOProcID);
//    if (mWorkBuf) {
//        delete[] mWorkBuf;
//        mWorkBuf = NULL;
//    }
//}

@end
