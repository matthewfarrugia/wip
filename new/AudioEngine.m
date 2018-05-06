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

