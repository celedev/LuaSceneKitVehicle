//
//  GameViewController.h
//  SceneKitVehicle
//
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>

@interface GameViewController : UIViewController <SCNSceneRendererDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loadingImageCenterConstraint;

@property CGFloat yAcceleration;

- (BOOL)isHighEndDevice;

@end
