// Lua to C bindings for /Volumes/Brume/Celedev CodeFlow/CodeFlow Sample Applications/SceneKitVehicle/SceneKitVehicle/GameViewController.h
// Target Architecture: arm64
// Generated by Celedev® LuaBindingsGenerator on 2016-10-10 15:27:19 +0000

#import "CIMLua/CIMLuaBindings.h"

#import "GameViewController.h"

// Register Objective C methods extended signatures

@implementation GameViewController (LuaModule_SceneKitVehicle_GameViewController)

+ (void) load
{
    CIMLuaObjcMethodAttributes instanceMethodsAttributes [] = {
        { @selector(loadingImageCenterConstraint), "@\"NSLayoutConstraint\"16@0:8" },
        { @selector(setLoadingImageCenterConstraint:), "v24@0:8@\"NSLayoutConstraint\"16" }
    };
    [CIMLuaContext registerObjcInstanceMethodsAttributes:instanceMethodsAttributes withCount:2 forClass:[GameViewController class]];
}

@end

