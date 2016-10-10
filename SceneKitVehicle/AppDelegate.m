//
//  AppDelegate.m
//  SceneKitVehicle
//
//

#import "AppDelegate.h"

#import "CIMLua/CIMLua.h"
#import "CIMLua/CIMLuaContextMonitor.h"

@implementation AppDelegate
{
    CIMLuaContext* _luaContext;
    CIMLuaContextMonitor* _luaContextMonitor;
}

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIViewController* gameViewController = self.window.rootViewController;
    
    _luaContext = [[CIMLuaContext alloc] initWithName:@"SceneKitLuaContext"];
    _luaContextMonitor = [[CIMLuaContextMonitor alloc] initWithLuaContext:_luaContext connectionTimeout:10.0 showWaitingMessage:YES];
    
    [_luaContext loadLuaModuleNamed:@"GameViewController" withCompletionBlock:^(id result) {
        
        if (result != nil) {
             // Configure the gameViewController in Lua
            [(id<CIMLuaObject>)gameViewController doLuaSetupIfNeeded];
        }
    }];

    return YES;
}

@end
