local ScnTypes = require 'SceneKit.SceneKitTypes'
local ScnLight = require 'SceneKit.SCNLight'
local ScnMaterial = require 'SceneKit.SCNMaterialProperty'

local M_PI = math.pi
local rand = math.random
local UIColor = objc.UIColor
local UIView =objc.UIView
local SCNVector3 = struct.SCNVector3
local SCNVector4 = struct.SCNVector4

---------------------------------------------------------------------
-- Create a class extension of native class GameViewController

local GameViewController = class.extendClass(objc.GameViewController)

---------------------------------------------------------------------
-- View controller methods

function GameViewController:viewDidLoad()
    self[GameViewController.superclass]:viewDidLoad()
    self:setupSceneView()
    self:markLuaSetupDone()
end

function GameViewController:doLuaSetup()
    if self.isViewLoaded then
         self:setupSceneView()
    end
end

function GameViewController:setupSceneView()
    
    if self.loadingImageCenterConstraint ~= nil then
        UIView:animateWithDuration_animations (0.5,
                                               function()
                                                   self.loadingImageCenterConstraint.constant = self.view.bounds.size.height
                                                   self.view:layoutIfNeeded()
                                               end)
     end
    
    local scnView = self.view
    scnView.backgroundColor = UIColor.blackColor
    
    -- setup the scene
    local scene = self:setupScene()
    scnView.scene = scene
    
    -- tweak physics
    scnView.scene.physicsWorld.speed = 4.0
    
    -- setup overlays
    scnView.overlaySKScene = objc.OverlayScene:newWithSize(scnView.bounds.size)
    
    -- setup accelerometer
    self:setupAccelerometer()
    
    -- set initial point of view
    scnView.pointOfView = self.cameraNode
    
    -- plug game logic
    scnView.delegate = self
    
    -- subscribe to update message
    self:addMessageHandler("system.did_load_module", "refreshScene")
end

function GameViewController:refreshScene()
    -- Add code to this method if you need to do specific refresh actions when the code ius updated
end

---------------------------------------------------------------------
-- This is wher the game logic takes place

local vehicleMaxSpeed = 250
local defaultEngineForce = 250.0
local defaultBrakingForce = 2.0
local steeringClamp = 0.4
local cameraDamping = 0.8

function GameViewController:renderer_didSimulatePhysicsAtTime(renderer, time)
    
    local scnView = self.view
    
    local engineForce = 0
    local brakingForce = 0
    
    -- drive: 1 touch = accelerate, 2 touches = backward, 3 touches = brake
    if scnView.touchCount == 1 then
        engineForce = defaultEngineForce
        self.reactor.birthRate = math.min (self.reactor.birthRate + self.reactorDefaultBirthRate / 60,
                                           self.reactorDefaultBirthRate)
    elseif scnView.touchCount == 2 then
        engineForce = -defaultEngineForce
        self.reactor.birthRate = 0
    elseif scnView.touchCount == 3 then
        brakingForce = 10
        self.reactor.birthRate = 0
    else
        brakingForce = defaultBrakingForce
        self.reactor.birthRate = 0
    end
    
    -- Steering is done by inclining the device
    local steeringAngle = - self.yAcceleration * .5
    if steeringAngle > steeringClamp then
        self.vehicleSteering = steeringClamp
    elseif steeringAngle < -steeringClamp then
        self.vehicleSteering = -steeringClamp
    else
        self.vehicleSteering = steeringAngle
    end
    
    -- update the vehicle steering and acceleration
   local vehicle = self.vehicle
    
    vehicle:setSteeringAngle_forWheelAtIndex(self.vehicleSteering, 0)
    vehicle:setSteeringAngle_forWheelAtIndex(self.vehicleSteering, 1)
    
    vehicle:applyEngineForce_forWheelAtIndex(engineForce, 3)
    vehicle:applyEngineForce_forWheelAtIndex(engineForce, 2)
    
    vehicle:applyBrakingForce_forWheelAtIndex(brakingForce, 2)
    vehicle:applyBrakingForce_forWheelAtIndex(brakingForce, 3)
    
    -- check if the car is upside down
    self:reorientCarIfNeeded()
    
    -- spotlight and camera positions
    if scnView.pointOfView == self.cameraNode then
        -- make the camera follow the car node
        local carNode = self.vehicleNode.presentationNode
        local carPosition = carNode.position
        local cameraPosition = self.cameraNode.position
        local cameraTargetPosition = {x = carPosition.x, y = 28.0, z = carPosition.z + 30.0}
        self.cameraNode.position = cameraTargetPosition
        self.cameraNode.position = { x = cameraTargetPosition.x + cameraDamping * (cameraPosition.x - cameraTargetPosition.x),
                                     y = cameraTargetPosition.y + cameraDamping * (cameraPosition.y - cameraTargetPosition.y),
                                     z = cameraTargetPosition.z + cameraDamping * (cameraPosition.z - cameraTargetPosition.z)}
        
        -- move the spollight on top of the car
        self.spotLightNode.position = SCNVector3(carPosition.x, 40., carPosition.z + 30)
        self.spotLightNode.rotation = SCNVector4(1,0,0,-M_PI/4.5)
        self.spotLightNode.light.spotInnerAngle = 20
        self.spotLightNode.light.spotOuterAngle = 70
        
    else
        local cameraNode = scnView.pointOfView
            
        if cameraNode == self.backCameraNode then
            local cameraPosition = self.backCameraNode.position
            local cameraTargetPosition = SCNVector3(0, 12, -18  --[[ - vehicle.speedInKilometersPerHour / 10]])
            cameraNode.position = { x = cameraTargetPosition.x + cameraDamping * (cameraPosition.x - cameraTargetPosition.x),
                                        y = cameraTargetPosition.y + cameraDamping * (cameraPosition.y - cameraTargetPosition.y),
                                        z = cameraTargetPosition.z + cameraDamping * (cameraPosition.z - cameraTargetPosition.z)}
        end
        
        -- Compensate the device inclination by rotating the camera
        local filteringFactor = 0.05
        self.filteredOrientation = (-self.yAcceleration * .6) * filteringFactor + (self.filteredOrientation or 0) * (1 - filteringFactor)
        cameraNode.rotation = SCNVector4(self.filteredOrientation, 1, 0, M_PI)
            
        -- move the spotlight in front of the camera
        local frontPosition = scnView.pointOfView.presentationNode:convertPosition_toNode(SCNVector3(0, 0, -30), nil)
        self.spotLightNode.position = SCNVector3(frontPosition.x, 50, frontPosition.z)
        self.spotLightNode.rotation = SCNVector4(1,0,0,-M_PI/2)
        self.spotLightNode.light.spotInnerAngle = 30
        self.spotLightNode.light.spotOuterAngle = 90
    end
    
    -- update speed gauge
    scnView.overlaySKScene.speedNeedle.zRotation = -(vehicle.speedInKilometersPerHour * M_PI / vehicleMaxSpeed)
end

function GameViewController:reorientCarIfNeeded()
    
    local carNode = self.vehicleNode.presentationNode
    local carPosition = carNode.position
    
    local ticks = (self.ticks or 0) + 1
    
    if ticks == 30 then
        local carTransform = carNode.worldTransform
        if carTransform.m22 <= 00 then
            -- the car is upside down
            self.checks = (self.checks or 0) + 1
            if self.checks == 3 then
                -- try to upturn the car with a random impulse
                local forcePos = SCNVector3(rand(10)-5, 0, rand(10)-5)
                self.vehicleNode.physicsBody:applyForce_atPosition_impulse(SCNVector3(0,400,0), forcePos, true)
                
                self.checks = 0
            end
        else
            self.checks = 0
        end
        
        ticks = 0
    end
    
    self.ticks = ticks
end

---------------------------------------------------------------------
-- load the setup methods if needed
require "GameViewController-Setup" 



return GameViewController
