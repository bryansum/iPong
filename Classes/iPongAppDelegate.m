//
//  iPongAppDelegate.m
//  iPong
//
//  Created by Majd Taby on 11/13/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "iPongAppDelegate.h"
#define kGameIdentifier		@"iPong"


@interface iPongAppDelegate ()
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
  
  
	UIImageView *backgroundPattern = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-pattern.png"]];
  [backgroundPattern setFrame:[[UIScreen mainScreen] bounds]];
  [_window addSubview:backgroundPattern];
  
	UIImageView *scoreboardBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scoreboard-bg.png"]];
  [scoreboardBg setFrame:CGRectMake(0, 0, 320, 480)];
  [_window addSubview:scoreboardBg];
  
	UIImageView *scoreboard = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scoreboard.png"]];
  [scoreboard setFrame:CGRectMake(0, 40, 320, 53)];
  [_window addSubview:scoreboard];
  
	UIImageView *divider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scoreboard-divider.png"]];
  [divider setFrame:CGRectMake(160, 41, 2, 51)];
  [_window addSubview:divider];
  
  UILabel *scoreLabel = [[UILabel alloc] init];
  [scoreLabel setFrame:CGRectMake(136, 20, 83, 18)];
  [scoreLabel setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.0]];
  [scoreLabel setText:@"SCORE"];
  [scoreLabel setShadowColor:[UIColor colorWithRed:221.0/255.0 green:230.0/255.0 blue:211.0/255.0 alpha:1.0]];
  [scoreLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
  [scoreLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
  [scoreLabel setTextColor:[UIColor colorWithRed:97.0/255.0 green:97.0/255.0 blue:97.0/255.0 alpha:1.0]];
  [_window addSubview:scoreLabel];
  
  myScoreValue = [[UILabel alloc] init];
  [myScoreValue setFrame:CGRectMake(10, 50, 153, 35)];
  [myScoreValue setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.0]];
  [myScoreValue setText:@"11"];
  [myScoreValue setTextAlignment:UITextAlignmentCenter];
  [myScoreValue setShadowColor:[UIColor colorWithRed:221.0/255.0 green:230.0/255.0 blue:211.0/255.0 alpha:1.0]];
  [myScoreValue setShadowOffset:CGSizeMake(0.0, 1.0)];
  [myScoreValue setFont:[UIFont boldSystemFontOfSize:40.0]];
  [myScoreValue setTextColor:[UIColor colorWithRed:74.0/255.0 green:96.0/255.0 blue:52.0/255.0 alpha:1.0]];
  [_window addSubview:myScoreValue];
  
  remoteScoreValue = [[UILabel alloc] init];
  [remoteScoreValue setFrame:CGRectMake(160, 50, 153, 35)];
  [remoteScoreValue setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.0]];
  [remoteScoreValue setText:@"5"];
  [remoteScoreValue setTextAlignment:UITextAlignmentCenter];
  [remoteScoreValue setShadowColor:[UIColor colorWithRed:221.0/255.0 green:230.0/255.0 blue:211.0/255.0 alpha:1.0]];
  [remoteScoreValue setShadowOffset:CGSizeMake(0.0, 1.0)];
  [remoteScoreValue setFont:[UIFont boldSystemFontOfSize:40.0]];
  [remoteScoreValue setTextColor:[UIColor colorWithRed:74.0/255.0 green:96.0/255.0 blue:52.0/255.0 alpha:1.0]];
  [_window addSubview:remoteScoreValue];
  
  buttonView = [UIButton buttonWithType:UIButtonTypeCustom];
  [buttonView setFrame:CGRectMake(70, 130, 186, 310)];
  [buttonView imageRectForContentRect:CGRectMake(100, 1300, 3200, 350)];
  [buttonView setBackgroundImage:[UIImage imageNamed:@"paddle.png"] forState:UIButtonTypeCustom];
  [buttonView addTarget:self action:@selector(startSampling) forControlEvents:UIControlEventTouchDown];
  [buttonView addTarget:self action:@selector(stopSampling) forControlEvents:UIControlEventTouchUpInside];
  [_window addSubview:buttonView];       
  
	firstDot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"empty-dot.png"]];
  [firstDot setFrame:CGRectMake(110, 440, 30, 30)];
  [_window addSubview:firstDot];
  
	secondDot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"empty-dot.png"]];
  [secondDot setFrame:CGRectMake(135, 440, 30, 30)];
  [_window addSubview:secondDot];
  
	thirdDot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"empty-dot.png"]];
  [thirdDot setFrame:CGRectMake(160, 440, 30, 30)];
  [_window addSubview:thirdDot];
  
	fourthDot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"empty-dot.png"]];
  [fourthDot setFrame:CGRectMake(185, 440, 30, 30)];
  [_window addSubview:fourthDot];
  
	//Show the window
	[_window makeKeyAndVisible];
  
  direction = 1.0;
  startTime = [[NSDate date] timeIntervalSince1970];  
  previousTimeInterval = startTime;
  partialVelocity = 0;
  
  accelerometer = [UIAccelerometer sharedAccelerometer];
  [accelerometer setDelegate:self];
  [accelerometer setUpdateInterval:0.05];	

//    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(firePacket) 
//                          userInfo:nil repeats:YES];
    
  //Create and advertise a new game and discover other available games
  //[self setup];
}

//-(void)firePacket
//{
//    NSLog(@"Fire packet called");
//    PongPacket packet;
//    packet.velocity = 1.5;
//    packet.swingType = kSlice;
//    packet.typeIntensity = 1;
//    
//    SwingTimer *swingTimer = [[SwingTimer alloc] initWithEnemyPacket:packet];
//    swingTimer.delegate = self;
//    [swingTimer start];
//}

- (void) startSampling{
  partialVelocity = 0;
  numberOfSamples = 0;
  previousTimeInterval = [[NSDate date] timeIntervalSince1970];  
  isSampling = true;
  
  [firstDot setImage:[UIImage imageNamed: @"glowing-dot.png"]];
  [secondDot setImage:[UIImage imageNamed:@"glowing-dot.png"]];
  [thirdDot setImage:[UIImage imageNamed: @"glowing-dot.png"]];
  [fourthDot setImage:[UIImage imageNamed:@"glowing-dot.png"]];
}

- (void) stopSampling {
  partialVelocity = 0;
  numberOfSamples = 0;
  isSampling = false;
  
  [firstDot setImage:[UIImage imageNamed: @"empty-dot.png"]];
  [secondDot setImage:[UIImage imageNamed:@"empty-dot.png"]];
  [thirdDot setImage:[UIImage imageNamed: @"empty-dot.png"]];
  [fourthDot setImage:[UIImage imageNamed:@"empty-dot.png"]];
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

-(void) playSound {
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
  CGFloat x = acceleration.x;
  CGFloat z = acceleration.z;
  CGFloat accel = x + z;
  
  NSTimeInterval intervalDate = [[NSDate date] timeIntervalSince1970];
  CGFloat timeDifference = intervalDate - previousTimeInterval;
  previousTimeInterval = intervalDate;
  partialVelocity += (timeDifference * accel);
  if(!isSampling) return;
  
  
  //If the direction has changed
  if((direction < 0 && accel > 0) || (direction > 0 && accel < 0)){
    // Time threshold is 1 second (sampling accelerometer 20 times per second 
    if(numberOfSamples > 5){
      NSLog(@"Velocity: %f",partialVelocity);
      [self send:partialVelocity];
    }
    
    partialVelocity = 0;
    numberOfSamples = 0;
    
    if(accel == 0.0){
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
			if (stream == _inStream) {
				uint8_t b[1024];
				unsigned int len = 0;
				len = [_inStream read:b maxLength:1024];
				if(!len) {
					if ([stream streamStatus] != NSStreamStatusAtEnd)
						[self _showAlert:@"Failed reading data from peer"];
				} else {
          [self playSound];
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

#pragma mark SwingTimer delegate functions
@implementation iPongAppDelegate (SwingTimerDelegate)

-(void)intervalDidOccur:(int)interval
{
    [self playSound];
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
