//
//  AudioEngine.m
//  Gettings things
//
//  Created by Matthew Farrugia on 24/02/2018.
//  Copyright © 2018 Matthew Farrugia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioEngine.h"

@implementation AudioEngine

@synthesize inputAudioDevice = _inputAudioDevice;
@synthesize outputAudioDevice = _outputAudioDevice;
@synthesize mWorkBuf = _mWorkBuf;

AudioDeviceIOProc mInputIOProc;
AudioDeviceIOProcID mInputIOProcID;
AudioDeviceIOProc mOutputIOProc;
AudioDeviceIOProcID mOutputIOProcID;


- (id) init: (AudioDevice*) inputAudioDevice withOutputDevice: (AudioDevice*) outputAudioDevice {
    _inputAudioDevice = inputAudioDevice;
    _outputAudioDevice = outputAudioDevice;
    return self;
}

- (OSStatus) startEngines {
    
    AudioDeviceID inputDeviceID = _inputAudioDevice.deviceID;
    AudioDeviceID outputDeviceID = _outputAudioDevice.deviceID;

    OSStatus result;
    
    UInt32 bitsPerChannel = _inputAudioDevice.streamFormat.mBitsPerChannel;
    UInt32 bytesPerFrame = _inputAudioDevice.streamFormat.mBytesPerFrame;
    UInt32 bytesPerPacket = _inputAudioDevice.streamFormat.mBytesPerPacket;
    UInt32 channelsPerFrame = _inputAudioDevice.streamFormat.mChannelsPerFrame;
    UInt32 framesPerPacket = _inputAudioDevice.streamFormat.mFramesPerPacket;
    
    AudioBufferList buffer;
    
    _mWorkBuf = malloc(sizeof(buffer));
    
    _mWorkBuf->mBuffers->mDataByteSize = (bitsPerChannel * bytesPerFrame * bytesPerPacket * channelsPerFrame * framesPerPacket);
    _mWorkBuf->mBuffers->mNumberChannels = channelsPerFrame;
    _mWorkBuf->mBuffers[0].mData = malloc(_mWorkBuf->mBuffers[0].mDataByteSize);

    //******* Input Proc
    mInputIOProc = InputIOProc;
    mInputIOProcID = NULL;
    
    result = AudioDeviceCreateIOProcID(inputDeviceID, mInputIOProc, _mWorkBuf, &mInputIOProcID);
    
    if (result == kAudioHardwareNoError){
        NSLog(@"|Input Proc started|");
    } else {
        NSLog(@"ERROR starting Input Proc: %i", result);
        return result;
    }
    
    result = AudioDeviceStart(inputDeviceID, mInputIOProcID);

    if (result == kAudioHardwareNoError){
        NSLog(@"|Input device started|");
    } else {
        NSLog(@"ERROR starting Input device: %i", result);
        return result;
    }
    
    //******* Output Proc
    mOutputIOProc = OutputIOProc;
    mOutputIOProcID = NULL;
    
    result = AudioDeviceCreateIOProcID(outputDeviceID, mOutputIOProc, _mWorkBuf, &mOutputIOProcID);
    
    if (result == kAudioHardwareNoError){
        NSLog(@"|Output Proc started|");
    } else {
        NSLog(@"ERROR starting Output Proc: %i", result);
        return result;
    }
    
    result = AudioDeviceStart(outputDeviceID, mOutputIOProcID);
    
    if (result == kAudioHardwareNoError){
        NSLog(@"|Output device started|");
    } else {
        NSLog(@"ERROR starting Output device: %i", result);
        return result;
    }
    
    return kAudioHardwareNoError;
}

- (OSStatus) stopEngines {
    
    AudioDeviceID inputDeviceID = _inputAudioDevice.deviceID;
    AudioDeviceID outputDeviceID = _outputAudioDevice.deviceID;
    
    OSStatus result;

    //******* Stop Input Proc
    result = AudioDeviceStop(inputDeviceID, mInputIOProcID);
    
    if (result == kAudioHardwareNoError){
        NSLog(@"|Input device stopped|");
    } else {
        NSLog(@"ERROR stopping Input device: %i", result);
        return result;
    }
    
    result = AudioDeviceDestroyIOProcID(inputDeviceID, mInputIOProcID);
    
    if (result == kAudioHardwareNoError){
        NSLog(@"|Input device destroyed|");
    } else {
        NSLog(@"ERROR destorying Input device: %i", result);
        return result;
    }
    
    //******* Stop Output Proc
    result = AudioDeviceStop(outputDeviceID, mOutputIOProcID);
    
    if (result == kAudioHardwareNoError){
        NSLog(@"|Output device stopped|");
    } else {
        NSLog(@"ERROR stopping Output device: %i", result);
        return result;
    }
    
    result = AudioDeviceDestroyIOProcID(outputDeviceID, mOutputIOProcID);
    
    if (result == kAudioHardwareNoError){
        NSLog(@"|Output device destroyed|");
    } else {
        NSLog(@"ERROR destorying Output device: %i", result);
        return result;
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
    AudioBufferList * buff = (AudioBufferList *) inClientData;
    //UInt32 chunks = sizeof(inInputData->mBuffers->mData)/inInputData->mBuffers->mDataByteSize;
    for(UInt32 i=0; i<inInputData->mNumberBuffers; i++) {
        //UInt32 bytesToCopy = inInputData->mBuffers[i].mDataByteSize;
        //memcpy(buff->mData, inInputData->mBuffers[i].mData, bytesToCopy);
        float * input = inInputData->mBuffers[i].mData;
        float * output;
        output = input;
        buff->mBuffers[i].mData = output;
        //Float32 * input = (Float32 *) inInputData->mBuffers[i].mData;
        //buff->mData = input;
        //NSLog(@"INPUT: %f", *input);
//            buff->mData = inInputData->mBuffers->mData;
//            NSLog(@"%d", (int)buff->mData);
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
    float x0 = 0.0;
    
    AudioBufferList * buff = (AudioBufferList *) inClientData;
    
    for(UInt32 i = 0; i < outOutputData->mNumberBuffers; i++){
        for(UInt32 channel = 0; channel < outOutputData->mBuffers->mNumberChannels; channel++) {
            float * input = (float *) buff->mBuffers[i].mData;
            float * output = (float *) outOutputData->mBuffers[i].mData + channel;
            UInt32 outnchnls = outOutputData->mBuffers[i].mNumberChannels;
            long framesize = outnchnls * sizeof(float);
            //for(UInt32 x = 0; x < 16; x++){
//            for (UInt32 frame = 0; frame < outOutputData->mBuffers[i].mDataByteSize; frame += framesize ){
//                if (input == NULL) {
//
//                } else {
//                    x0 = *input;
//                }
//
//            *output = x0 * 1.0;
//            }
            NSLog(@"%lu", sizeof(*output));
            memcpy(outOutputData->mBuffers[i].mData, buff->mBuffers[i].mData, buff->mBuffers->mDataByteSize);
            //}
            //NSLog(@"OUTPUT: %f", *output);
            //UInt32 bytesToCopy = outOutputData->mBuffers[i].mDataByteSize;
            //memcpy(outOutputData->mBuffers[i].mData, buff->mData, bytesToCopy);
            }
    }
    return noErr;
}

@end

