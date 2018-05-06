//
//  AppDelegate.m
//
//  Created by Matthew Farrugia on 18/02/2018.
//  Copyright © 2018 Matthew Farrugia. All rights reserved.
//

#import "AppDelegate.h"
#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudio.h>
#import "Logger.h"
#import "DeviceUtility.h"
#import "AudioDevice.h"
#import "AudioEngine.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    DeviceUtility * audioDevicesUtility = [[DeviceUtility alloc] init];
    //Float32 currentOutputVol = [audioDevicesUtility getDefaultOutputDeviceVolume];
    AudioDeviceID audioOutputDeviceID = audioDevicesUtility.defaultOutputDeviceID;
    AudioDeviceID audioInputDeviceID = audioDevicesUtility.defaultInputDeviceID;
    
    AudioDevice * inputDevice = [[AudioDevice alloc] initWithDeviceID:audioInputDeviceID withInput:TRUE];
    AudioDevice * outputDevice = [[AudioDevice alloc] initWithDeviceID:audioOutputDeviceID withInput:FALSE];
    
    AudioEngine * kernel = [[AudioEngine alloc] init:inputDevice withOutputDevice:outputDevice];

    OSStatus result = [kernel startEngines];
        
    //NSLog(@"Output volume: %f", currentOutputVol);
    //[audioDevices setDefaultOutputDeviceVolume:0.333];
    //currentOutputVol = [audioDevices getDefaultOutputDeviceVolume];
    //NSLog(@"Output volume: %f", currentOutputVol);
    //[audioDevicesUtility startAudio:audioDeviceID withInputID:inputerAudioer];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
