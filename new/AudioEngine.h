//
//  AudioEngine.h
//  Gettings things
//
//  Created by Matthew Farrugia on 24/02/2018.
//  Copyright © 2018 Matthew Farrugia. All rights reserved.
//

#ifndef AudioEngine_h
#define AudioEngine_h

#import <CoreAudio/CoreAudio.h>
#import "AudioDevice.h"

@interface AudioEngine : NSObject

@property AudioDevice * inputAudioDevice;
@property AudioDevice * outputAudioDevice;

@property AudioBufferList * mWorkBuf;
@property Float32 * buffer;

- (id) init: (AudioDevice*) inputAudioDevice withOutputDevice: (AudioDevice*) outputAudioDevice;
- (OSStatus) startEngines;

@end

#endif /* AudioEngine_h */
