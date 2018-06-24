//
//  AudioEngine.m
//
//  Created by Matthew Farrugia on 24/02/2018.
//  Copyright © 2018 Matthew Farrugia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Logger.h"
#import "AudioEngine.h"

@implementation AudioEngine

AudioDevice * inputAudioDevice;
AudioDevice * outputAudioDevice;

UInt32 bitsPerChannel;
UInt32 bytesPerFrame;
UInt32 bytesPerPacket;
UInt32 channelsPerFrame;
UInt32 framesPerPacket;

float mGain = 1.0;

AudioBufferList * mWorkBuf;

AudioDeviceIOProc mInputIOProc;
AudioDeviceIOProcID mInputIOProcID;
AudioDeviceIOProc mOutputIOProc;
AudioDeviceIOProcID mOutputIOProcID;


- (id)init:(AudioDevice*)inDevice withOutputDevice:(AudioDevice*)outDevice {
    
    inputAudioDevice = inDevice;
    outputAudioDevice = outDevice;
    
    bitsPerChannel = inputAudioDevice.streamFormat.mBitsPerChannel;
    bytesPerFrame = inputAudioDevice.streamFormat.mBytesPerFrame;
    bytesPerPacket = inputAudioDevice.streamFormat.mBytesPerPacket;
    channelsPerFrame = inputAudioDevice.streamFormat.mChannelsPerFrame;
    framesPerPacket = inputAudioDevice.streamFormat.mFramesPerPacket;
    
    return self;
}
- (void)setGain:(float)gain {
    mGain = gain;
}

- (OSStatus)startEngines {
    
    AudioBufferList buffer;
    
    mWorkBuf = malloc(sizeof(buffer));
    
    mWorkBuf->mBuffers->mDataByteSize = (bitsPerChannel * bytesPerFrame * bytesPerPacket * channelsPerFrame * framesPerPacket);
    mWorkBuf->mBuffers->mNumberChannels = channelsPerFrame;
    mWorkBuf->mBuffers[0].mData = malloc(mWorkBuf->mBuffers[0].mDataByteSize);

    //******* Input Proc *******//
    mInputIOProc = InputIOProc;
    mInputIOProcID = NULL;
    OSStatus result = AudioDeviceCreateIOProcID(inputAudioDevice.deviceID, mInputIOProc, mWorkBuf, &mInputIOProcID);
    
    if (result != kAudioHardwareNoError){
        [Logger logAudioFailure:@"Starting input Proc" withCode:&result];
        return result;
    } else {
        [Logger logAudioSuccess:@"|Input Proc started|"];
    }
    
    result = AudioDeviceStart(inputAudioDevice.deviceID, mInputIOProcID);
    
    if (result != kAudioHardwareNoError){
        [Logger logAudioFailure:@"Starting input device" withCode:&result];
        return result;
    } else {
        [Logger logAudioSuccess:@"|Input device started|"];
    }
    
    //******* Output Proc *******//
    mOutputIOProc = OutputIOProc;
    mOutputIOProcID = NULL;
    result = AudioDeviceCreateIOProcID(outputAudioDevice.deviceID, mOutputIOProc, mWorkBuf, &mOutputIOProcID);
    
    if (result != kAudioHardwareNoError){
        [Logger logAudioFailure:@"Starting output Proc" withCode:&result];
        return result;
    } else {
        [Logger logAudioSuccess:@"|Output Proc started|"];
    }
    
    result = AudioDeviceStart(outputAudioDevice.deviceID, mOutputIOProcID);
    
    if (result != kAudioHardwareNoError){
        [Logger logAudioFailure:@"Starting output device" withCode:&result];
        return result;
    } else {
        [Logger logAudioSuccess:@"|Output device started|"];
    }
    
    return kAudioHardwareNoError;
}

- (OSStatus)stopEngines {

    //******* Stop Input Proc  *******//
    OSStatus result = AudioDeviceStop(inputAudioDevice.deviceID, mInputIOProcID);
    
    if (result != kAudioHardwareNoError){
        [Logger logAudioFailure:@"Stopping input device" withCode:&result];
        return result;
    } else {
        [Logger logAudioSuccess:@"|Input device stopped|"];
    }
    
    result = AudioDeviceDestroyIOProcID(inputAudioDevice.deviceID, mInputIOProcID);
    
    if (result != kAudioHardwareNoError){
        [Logger logAudioFailure:@"Destorying input device" withCode:&result];
        return result;
    } else {
        [Logger logAudioSuccess:@"|Input device destroyed|"];
    }
    
    //******* Stop Output Proc
    result = AudioDeviceStop(outputAudioDevice.deviceID, mOutputIOProcID);
    
    if (result != kAudioHardwareNoError){
        [Logger logAudioFailure:@"Stopping output device" withCode:&result];
        return result;
    } else {
        [Logger logAudioSuccess:@"|Output device stopped|"];
    }
    
    result = AudioDeviceDestroyIOProcID(outputAudioDevice.deviceID, mOutputIOProcID);
    
    if (result != kAudioHardwareNoError){
        [Logger logAudioFailure:@"Destorying output device" withCode:&result];
        return result;
    } else {
        [Logger logAudioSuccess:@"|Output device destroyed|"];
    }
    
    return kAudioHardwareNoError;
}

OSStatus InputIOProc(AudioDeviceID inDevice,
                     const AudioTimeStamp *inNow,
                     const AudioBufferList *inInputData,
                     const AudioTimeStamp *inInputTime,
                     AudioBufferList *outOutputData,
                     const AudioTimeStamp *inOutputTime,
                     void * inClientData)
{
    AudioBufferList * clientBuffer = (AudioBufferList *) inClientData;
    
    for (UInt32 i=0; i<inInputData->mNumberBuffers; i++) {
        float * input = inInputData->mBuffers[i].mData;
        float * output;

        output = input;
        clientBuffer->mBuffers[i].mData = output;
    }
    return noErr;
}

OSStatus OutputIOProc(AudioDeviceID inDevice,
                      const AudioTimeStamp *inNow,
                      const AudioBufferList *inInputData,
                      const AudioTimeStamp *inInputTime,
                      AudioBufferList *outOutputData,
                      const AudioTimeStamp *inOutputTime,
                      void *inClientData)
{
    AudioBufferList * clientBuffer = (AudioBufferList *) inClientData;
    
    float x0 = mGain;
    
    for(UInt32 i = 0; i < outOutputData->mNumberBuffers; i++){
        for (UInt32 e = 0; e < (outOutputData->mBuffers->mDataByteSize / sizeof(float)); e++) {
            for(UInt32 channel = 0; channel < outOutputData->mBuffers->mNumberChannels; channel++) {
                float * input = (float *)clientBuffer->mBuffers[i].mData + e;
                float * output = (float*)outOutputData->mBuffers[i].mData + e;

                float i0 = *input;
                *output = i0 * x0;
            }
        }
    }
    return noErr;
}

@end

