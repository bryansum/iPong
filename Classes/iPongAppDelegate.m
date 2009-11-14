//
//  iPongAppDelegate.m
//  iPong
//
//  Created by Majd Taby on 11/13/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "iPongAppDelegate.h"
#define kGameIdentifier		@"iPong"

@interface iPongAppDelegate()
- (void) setup;
- (void) startSampling;
- (void) stopSampling;
- (void) playSound;
- (void) send:(double) velocity;
- (void) presentPicker:(NSString *)name;
- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration;
@end

@implementation iPongAppDelegate

@synthesize soundFileURLRef;
@synthesize soundFileObject;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	//Create a full-screen window
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[_window setBackgroundColor:[UIColor darkGrayColor]];
  
  labelView = [[UILabel alloc] init];
  [labelView setFrame:CGRectMake(10, 50, 200, 30)];
  [labelView setText:@"Value of b"];
  [_window addSubview:labelView]; 
  
  secondLabel = [[UILabel alloc] init];
  [secondLabel setFrame:CGRectMake(10, 100, 200, 30)];
  [secondLabel setText:@"value of len"];
  [_window addSubview:secondLabel]; 
  
  buttonView = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [buttonView setFrame:CGRectMake(10, 150, 290, 200)];
  [buttonView setTitle:@"Click me as you throw" forState:UIControlStateNormal];
  [buttonView addTarget:self action:@selector(startSampling) forControlEvents:UIControlEventTouchDown];
  [buttonView addTarget:self action:@selector(stopSampling) forControlEvents:UIControlEventTouchUpInside];
  [_window addSubview:buttonView];       
  
  soundButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [soundButton setFrame:CGRectMake(10, 370, 100, 70)];
  [soundButton setTitle:@"Play Sound" forState:UIControlStateNormal];
  [soundButton addTarget:self action:@selector(playSound) forControlEvents:UIControlEventTouchUpInside];
  [_window addSubview:soundButton];       
  
	//Show the window
	[_window makeKeyAndVisible];
  
  direction = 1.0;
  startTime = [[NSDate date] timeIntervalSince1970];  
  previousTimeInterval = startTime;
  partialVelocity = 0;
  
  accelerometer = [UIAccelerometer sharedAccelerometer];
  [accelerometer setDelegate:self];
  [accelerometer setUpdateInterval:0.05];	

  //Create and advertise a new game and discover other available games
  [self setup];
}
- (void) startSampling{
  partialVelocity = 0;
  numberOfSamples = 0;
  previousTimeInterval = [[NSDate date] timeIntervalSince1970];  
  isSampling = true;
}

- (void) stopSampling {
  partialVelocity = 0;
  numberOfSamples = 0;
  isSampling = false;
}

- (void) _showAlert:(NSString *)title
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:@"Check your networking configuration." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

- (void) send:(double)velocity
{
  NSString *s = [NSString stringWithFormat:@"%0.3f",velocity];
  NSLog(@"Sending %0.3f",s);
	if (_outStream && [_outStream hasSpaceAvailable])
		if([_outStream write:(const uint8_t *)&s maxLength:(sizeof(const uint8_t) * [s length] + 1)] == -1)
			[self _showAlert:@"Failed sending data to peer"];
}

-(void) playSound{
	//Get the filename of the sound file:
	NSString *path = [NSString stringWithFormat:@"%@%@",
                    [[NSBundle mainBundle] resourcePath],
                    @"/tap.aif"];
  
	//declare a system sound id
	SystemSoundID soundID;
  
	//Get a URL for the sound file
	NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
  
	//Use audio sevices to create the sound
	AudioServicesCreateSystemSoundID((CFURLRef)filePath, &soundID);
  
	//Use audio services to play the sound
	AudioServicesPlaySystemSound(soundID);
}


- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
  NSTimeInterval intervalDate = [[NSDate date] timeIntervalSince1970];
  CGFloat timeDifference = intervalDate - previousTimeInterval;
  previousTimeInterval = intervalDate;
  partialVelocity += (timeDifference * acceleration.x);
  if(!isSampling) return;
  
  
  //If the direction has changed
  if((direction < 0 && acceleration.x > 0) || (direction > 0 && acceleration.x < 0)){
    // Time threshold is 1 second (sampling accelerometer 20 times per second 
    if(numberOfSamples > 5){
      NSLog(@"Velocity: %f",partialVelocity);
      [self send:partialVelocity];
      [self playSound];
    }
    
    partialVelocity = 0;
    numberOfSamples = 0;
    
    if(acceleration.x == 0.0){
      direction = 1.0;
    } else {
      direction = -1.0;
    }
  }
  
  numberOfSamples++;
}


- (void) setup {
	[_server release];
	_server = nil;
	
	[_inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_inStream release];
	_inStream = nil;
	_inReady = NO;
  
	[_outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_outStream release];
	_outStream = nil;
	_outReady = NO;
	
	_server = [TCPServer new];
	[_server setDelegate:self];
	NSError *error;
	if(_server == nil || ![_server start:&error]) {
		NSLog(@"Failed creating server: %@", error);
		[self _showAlert:@"Failed creating server"];
		return;
	}
	
	//Start advertising to clients, passing nil for the name to tell Bonjour to pick use default name
	if(![_server enableBonjourWithDomain:@"local" applicationProtocol:[TCPServer bonjourTypeFromIdentifier:kGameIdentifier] name:nil]) {
		[self _showAlert:@"Failed advertising server"];
		return;
	}
  
	[self presentPicker:nil];
}

// Make sure to let the user know what name is being used for Bonjour advertisement.
// This way, other players can browse for and connect to this game.
// Note that this may be called while the alert is already being displayed, as
// Bonjour may detect a name conflict and rename dynamically.
- (void) presentPicker:(NSString *)name {
	if (!_picker) {
		_picker = [[Picker alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] type:[TCPServer bonjourTypeFromIdentifier:kGameIdentifier]];
		_picker.delegate = self;
	}
	
	_picker.gameName = name;
  
	if (!_picker.superview) {
		[_window addSubview:_picker];
	}
}

- (void) destroyPicker {
	[_picker removeFromSuperview];
	[_picker release];
	_picker = nil;
}

- (void) openStreams
{
	_inStream.delegate = self;
	[_inStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_inStream open];
	_outStream.delegate = self;
	[_outStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_outStream open];
}

- (void) browserViewController:(BrowserViewController *)bvc didResolveInstance:(NSNetService *)netService
{
	if (!netService) {
		[self setup];
		return;
	}
  
	// note the following method returns _inStream and _outStream with a retain count that the caller must eventually release
	if (![netService getInputStream:&_inStream outputStream:&_outStream]) {
		[self _showAlert:@"Failed connecting to server"];
		return;
	}
  
	[self openStreams];
}

@end


#pragma mark -
@implementation iPongAppDelegate (NSStreamDelegate)

- (void) stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
	UIAlertView *alertView;
	switch(eventCode) {
		case NSStreamEventOpenCompleted:
		{
			[self destroyPicker];
			
			[_server release];
			_server = nil;
      
			if (stream == _inStream)
				_inReady = YES;
			else
				_outReady = YES;
			
			if (_inReady && _outReady) {
				alertView = [[UIAlertView alloc] initWithTitle:@"Game started!" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Continue", nil];
				[alertView show];
				[alertView release];
			}
			break;
		}
		case NSStreamEventHasBytesAvailable:
		{
      NSString *velocity;
			if (stream == _inStream) {
				uint8_t b[1024];
				unsigned int len = 0;
				len = [_inStream read:b maxLength:1024];
				if(!len) {
					if ([stream streamStatus] != NSStreamStatusAtEnd)
						[self _showAlert:@"Failed reading data from peer"];
				} else {
					[labelView setText:@"Got a hit"];
				}
			}
			break;
		}
		case NSStreamEventErrorOccurred:
		{
			NSLog(@"%s", _cmd);
			[self _showAlert:@"Error encountered on stream!"];			
			break;
		}
			
		case NSStreamEventEndEncountered:
		{
			UIAlertView	*alertView;
			
			NSLog(@"%s", _cmd);
			
			alertView = [[UIAlertView alloc] initWithTitle:@"Peer Disconnected!" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Continue", nil];
			[alertView show];
			[alertView release];
      
			break;
		}
	}
}

@end



#pragma mark -
@implementation iPongAppDelegate (TCPServerDelegate)

- (void) serverDidEnableBonjour:(TCPServer *)server withName:(NSString *)string
{
	NSLog(@"%s", _cmd);
	[self presentPicker:string];
}

- (void)didAcceptConnectionForServer:(TCPServer *)server inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr
{
	if (_inStream || _outStream || server != _server)
		return;
	
	[_server release];
	_server = nil;
	
	_inStream = istr;
	[_inStream retain];
	_outStream = ostr;
	[_outStream retain];
	
	[self openStreams];
}


- (void)dealloc {
    [_window release];
    [super dealloc];
}


@end
