#import <GameController/GameController.h>
#import <simd/simd.h>
#import <sys/utsname.h>

#import "AAPLGameViewController.h"
#import "AAPLGameView.h"
#import "AAPLOverlayScene.h"

#define MAX_SPEED 250

@interface AAPLGameViewController()

@property CGFloat orientation;

@end

@implementation AAPLGameViewController {
    
    //accelerometer
    CMMotionManager *_motionManager;
    UIAccelerationValue	_accelerometer[3];
}

- (NSString *)deviceName
{
    static NSString *deviceName = nil;
    
    if (deviceName == nil) {
        struct utsname systemInfo;
        uname(&systemInfo);
        
        deviceName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    }
    return deviceName;
}

- (BOOL)isHighEndDevice
{
    //return YES for iPhone 5s and iPad air, NO otherwise
    if ([[self deviceName] hasPrefix:@"iPad4"]
       || [[self deviceName] hasPrefix:@"iPhone6"]) {
        return YES;
    }
    
    return NO;
}

- (void)addTrainToScene:(SCNScene *)scene atPosition:(SCNVector3)pos
{
    SCNScene *trainScene = [SCNScene sceneNamed:@"train_flat"];
    
    //physicalize the train with simple boxes
    [trainScene.rootNode.childNodes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SCNNode *node = (SCNNode *)obj;
        if (node.geometry != nil) {
            node.position = SCNVector3Make(node.position.x + pos.x, node.position.y + pos.y, node.position.z + pos.z);
            
            SCNVector3 min, max;
            [node getBoundingBoxMin:&min max:&max];
            
            SCNPhysicsBody *body = [SCNPhysicsBody dynamicBody];
            SCNBox *boxShape = [SCNBox boxWithWidth:max.x - min.x height:max.y - min.y length:max.z - min.z chamferRadius:0.0];
            body.physicsShape = [SCNPhysicsShape shapeWithGeometry:boxShape options:nil];
            
            node.pivot = SCNMatrix4MakeTranslation(0, -min.y, 0);
            node.physicsBody = body;
            [[scene rootNode] addChildNode:node];
        }
    }];
    
    //add smoke
    SCNNode *smokeHandle = [scene.rootNode childNodeWithName:@"Smoke" recursively:YES];
    [smokeHandle addParticleSystem:[SCNParticleSystem particleSystemNamed:@"smoke" inDirectory:nil]];
    
    //add physics constraints between engine and wagons
    SCNNode *engineCar = [scene.rootNode childNodeWithName:@"EngineCar" recursively:NO];
    SCNNode *wagon1 = [scene.rootNode childNodeWithName:@"Wagon1" recursively:NO];
    SCNNode *wagon2 = [scene.rootNode childNodeWithName:@"Wagon2" recursively:NO];
    
    SCNVector3 min, max;
    [engineCar getBoundingBoxMin:&min max:&max];
    
    SCNVector3 wmin, wmax;
    [wagon1 getBoundingBoxMin:&wmin max:&wmax];
    
    // Tie EngineCar & Wagon1
    SCNPhysicsBallSocketJoint *joint = [SCNPhysicsBallSocketJoint jointWithBodyA:engineCar.physicsBody anchorA:SCNVector3Make(max.x, min.y, 0)
                                                                           bodyB:wagon1.physicsBody anchorB:SCNVector3Make(wmin.x, wmin.y, 0)];
    [scene.physicsWorld addBehavior:joint];
    
    // Wagon1 & Wagon2
    joint = [SCNPhysicsBallSocketJoint jointWithBodyA:wagon1.physicsBody anchorA:SCNVector3Make(wmax.x + 0.1, wmin.y, 0)
                                                bodyB:wagon2.physicsBody anchorB:SCNVector3Make(wmin.x - 0.1, wmin.y, 0)];
    [scene.physicsWorld addBehavior:joint];
}

- (void)setupAccelerometer
{
    //event
    _motionManager = [[CMMotionManager alloc] init];
    AAPLGameViewController * __weak weakSelf = self;
    
    if ([[GCController controllers] count] == 0 && [_motionManager isAccelerometerAvailable] == YES) {
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
        _orientation = _accelerometer[1]*1.3;
    }
    else {
        _orientation = -_accelerometer[1]*1.3;
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
