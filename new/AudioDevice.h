//
//  AudioDevice.h
//  Gettings things
//
//  Created by Matthew Farrugia on 18/02/2018.
//  Copyright © 2018 Matthew Farrugia. All rights reserved.
//

#ifndef AudioDevice_h
#define AudioDevice_h

#import <CoreAudio/CoreAudio.h>

@interface AudioDevice : NSObject

@property AudioDeviceID deviceID;
@property BOOL isInput;
@property UInt32 safteyOffset;
@property UInt32 bufferFrameSize;
@property AudioStreamBasicDescription streamFormat;

- (id) initWithDeviceID:(AudioDeviceID)deviceID withIsInput:(BOOL)isInput;
- (void) updateFormat;

@end
#endif /* AudioDevice_h */
