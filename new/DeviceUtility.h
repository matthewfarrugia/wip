//
//  GetDevice.h
//
//  Created by Matthew Farrugia on 18/02/2018.
//  Copyright © 2018 Matthew Farrugia. All rights reserved.
//

#ifndef DeviceUtility_h
#define DeviceUtility_h

#import <Foundation/Foundation.h>

@interface DeviceUtility : NSObject

@property AudioDeviceID defaultInputDeviceID;
@property AudioDeviceID defaultOutputDeviceID;

- (void)getDeviceInfo:(AudioDeviceID)deviceID;
- (AudioStreamBasicDescription)getDefaultStreamDescription;
- (Float32)getDefaultOutputDeviceVolume;
- (void)setDefaultOutputDeviceVolume:(Float32)newVolume;
- (UInt32)getBufferSizes:(AudioDeviceID)outputDeviceID;

@end

#endif /* DeviceUtility_h */
