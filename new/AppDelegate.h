//
//  AppDelegate.h
//
//  Created by Matthew Farrugia on 18/02/2018.
//  Copyright © 2018 Matthew Farrugia. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (readwrite, assign) IBOutlet NSSlider* slider;

- (IBAction)sliderValueChanged:(id)sender;


@end

