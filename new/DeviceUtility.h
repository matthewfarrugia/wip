//
//  getDevice.h
//  getAudio
//
//  Created by Matthew Farrugia on 18/02/2018.
//  Copyright © 2018 Matthew Farrugia. All rights reserved.
//

#ifndef DeviceUtility_h
#define DeviceUtility_h

#import <Foundation/Foundation.h>

@interface DeviceUtility : NSObject

+ (void)getDeviceInfo:(AudioDeviceID)deviceID;
- (AudioStreamBasicDescription)getDefaultStreamDescription;
- (AudioDeviceID)getDefaultOutputDeviceID;
- (Float32)getDefaultOutputDeviceVolume;
- (void)setDefaultOutputDeviceVolume:(Float32)newVolume;
+ (UInt32)getBufferSizes:(AudioDeviceID)outputDeviceID;
//- (void)startAudio:(AudioDeviceID)outputDeviceID withInputID:(AudioDeviceID)InputDeviceID;
- (AudioDeviceID)getDefaultInputDeviceID;

@end

#endif /* DeviceUtility_h */
