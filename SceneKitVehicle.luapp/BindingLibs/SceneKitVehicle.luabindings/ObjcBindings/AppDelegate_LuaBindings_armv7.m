// Lua to C bindings for /Volumes/Brume/Celedev CodeFlow/CodeFlow Sample Applications/SceneKitVehicle/SceneKitVehicle/AppDelegate.h
// Target Architecture: armv7
// Generated by Celedev® LuaBindingsGenerator on 2016-10-10 15:27:17 +0000

#import "CIMLua/CIMLuaBindings.h"

#import "AppDelegate.h"

// Register Objective C methods extended signatures

@implementation AppDelegate (LuaModule_SceneKitVehicle_AppDelegate)

+ (void) load
{
    CIMLuaObjcMethodAttributes instanceMethodsAttributes [] = {
        { @selector(window), "@\"UIWindow\"8@0:4" },
        { @selector(setWindow:), "v12@0:4@\"UIWindow\"8" }
    };
    [CIMLuaContext registerObjcInstanceMethodsAttributes:instanceMethodsAttributes withCount:2 forClass:[AppDelegate class]];
}

@end
