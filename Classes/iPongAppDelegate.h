//
//  iPongAppDelegate.h
//  iPong
//
//  Created by Majd Taby on 11/13/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#include <AudioToolbox/AudioToolbox.h>
#import "BrowserViewController.h"
#import "Picker.h"
#import "TCPServer.h"


typedef struct AccelerationSample{
  NSTimeInterval elapsedTime;
  double x;
} AccelerationSample;

@interface iPongAppDelegate : NSObject <UIApplicationDelegate, UIActionSheetDelegate,
BrowserViewControllerDelegate, TCPServerDelegate, UIAccelerometerDelegate>
{
	UIWindow				  *_window;
	Picker					  *_picker;
	TCPServer				  *_server;
	NSInputStream		  *_inStream;
	NSOutputStream		*_outStream;
	BOOL				   	  _inReady;
	BOOL				      _outReady;
  
  UILabel           *labelView;
  UILabel           *secondLabel;
  
  UIButton          *buttonView;
  UIButton          *soundButton;
  
  UIAccelerometer   *accelerometer;
  
  BOOL              isSampling;
  NSTimeInterval    startTime;
  NSUInteger        previousTimeInterval;
  CGFloat           partialVelocity;
  NSInteger         direction;
  NSUInteger        numberOfSamples;
  
	CFURLRef		soundFileURLRef;
	SystemSoundID	soundFileObject;
  
}

@property (readwrite)	CFURLRef		soundFileURLRef;
@property (readonly)	SystemSoundID	soundFileObject;

@end

