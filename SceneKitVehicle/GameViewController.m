//
//  GameViewController.m
//  SceneKitVehicle
//
//

#import "GameViewController.h"

#import <CoreMotion/CoreMotion.h>
#import <sys/utsname.h>

@implementation GameViewController 
{    
    //accelerometer
    CMMotionManager *_motionManager;
    UIAccelerationValue	_accelerometer[3];
}

- (BOOL)isHighEndDevice
{
    //return YES for iPhone 5s and iPad air, and higher NO otherwise
    static BOOL isHighEndDevice = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // Read the device model name
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString* deviceModelName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        
        if ([deviceModelName hasPrefix:@"iPad"]) {
            unichar iPadVersion = [deviceModelName characterAtIndex:4]; // suppose single digit version
            isHighEndDevice = (iPadVersion >= '4');
        }
        else if ([deviceModelName hasPrefix:@"iPhone"]) {
            unichar iPhoneVersion = [deviceModelName characterAtIndex:6]; // suppose single digit version
            isHighEndDevice = (iPhoneVersion >= '6');
        }

    });
    
    return isHighEndDevice;
}

- (void)setupAccelerometer
{
    //event
    _motionManager = [[CMMotionManager alloc] init];
    GameViewController * __weak weakSelf = self;
    
    if ([_motionManager isAccelerometerAvailable] == YES) {
        [_motionManager setAccelerometerUpdateInterval:1/60.0];
        [_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            [weakSelf accelerometerDidChange:accelerometerData.acceleration];
        }];
    }
}

- (void)accelerometerDidChange:(CMAcceleration)acceleration
{
#define kFilteringFactor			0.5
    
    //Use a basic low-pass filter to only keep the gravity in the accelerometer values
    _accelerometer[0] = acceleration.x * kFilteringFactor + _accelerometer[0] * (1.0 - kFilteringFactor);
    _accelerometer[1] = acceleration.y * kFilteringFactor + _accelerometer[1] * (1.0 - kFilteringFactor);
    _accelerometer[2] = acceleration.z * kFilteringFactor + _accelerometer[2] * (1.0 - kFilteringFactor);
    
    if (_accelerometer[0] > 0) {
        _yAcceleration = _accelerometer[1];
    }
    else {
        _yAcceleration = -_accelerometer[1];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_motionManager stopAccelerometerUpdates];
    _motionManager = nil;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
