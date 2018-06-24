//
//  AudioEngine.h
//
//  Created by Matthew Farrugia on 24/02/2018.
//  Copyright © 2018 Matthew Farrugia. All rights reserved.
//

#ifndef AudioEngine_h
#define AudioEngine_h

#import <CoreAudio/CoreAudio.h>
#import "AudioDevice.h"

@interface AudioEngine : NSObject

- (id)init:(AudioDevice*)inDevice withOutputDevice:(AudioDevice*)outDevice;
- (OSStatus)startEngines;
- (void)setGain:(float)gain;
@end

#endif /* AudioEngine_h */
