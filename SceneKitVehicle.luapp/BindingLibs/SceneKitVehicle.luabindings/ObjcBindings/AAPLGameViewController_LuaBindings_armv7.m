// Lua to C bindings for /Volumes/Brume/Celedev CodeFlow/CodeFlow Sample Applications/SceneKitVehicle/SceneKitVehicle/AAPLGameViewController.h
// Generated by Celedev® LuaBindingsGenerator on 2015-05-20 16:12:10 +0000
// Target Architecture: armv7

#import "CIMLua/CIMLuaBindings.h"

#import "AAPLGameViewController.h"

// Register Objective C methods extended signatures

@implementation AAPLGameViewController (LuaModule_SceneKitVehicle_AAPLGameViewController)

+ (void) load
{

    CIMLuaObjcMethodAttributes instanceMethodsAttributes [] = {
        { @selector(isHighEndDevice), "c\"BOOL\"8@0:4" },
        { @selector(addTrainToScene:atPosition:), "v24@0:4@\"SCNScene\"8{SCNVector3=fff}12" }
    };
    [CIMLuaContext registerObjcInstanceMethodsAttributes:instanceMethodsAttributes withCount:2 forClass:[AAPLGameViewController class]];
}

@end

