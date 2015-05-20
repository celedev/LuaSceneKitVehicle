local ScnTypes = require 'SceneKit.SceneKitTypes'
local ScnLight = require 'SceneKit.SCNLight'
local ScnMaterial = require 'SceneKit.SCNMaterialProperty'

local GameViewController = class.extendClass(objc.AAPLGameViewController)

local SCNScene = objc.SCNScene
local SCNNode = objc.SCNNode
local SCNLight = objc.SCNLight
local SCNBox = objc.SCNBox
local SCNPhysicsBody = objc.SCNPhysicsBody
local SCNMaterial = objc.SCNMaterial
local SCNShape = objc.SCNShape
local SCNPhysicsVehicle = objc.SCNPhysicsVehicle

local SCNVector3 = struct.SCNVector3
local SCNVector4 = struct.SCNVector4
local SCNVector3Zero = ScnTypes.SCNVector3Zero

local UIColor = objc.UIColor

local M_PI = math.pi
local rand = math.random

function GameViewController:setupEnvironment (scene)
    -- floor
    local floor = SCNNode:node()
    floor.geometry = objc.SCNFloor:floor()
    -- floor.geometry.firstMaterial.diffuse.contents = "wood.png"
    getResource("floor", 'public.image', floor.geometry.firstMaterial.diffuse, "contents")
    floor.geometry.firstMaterial.diffuse.contentsTransform = ScnTypes.SCNMatrix4MakeScale(2, 2, 1) --scale the floor texture
    floor.geometry.firstMaterial.locksAmbientWithDiffuse = true
    if self.isHighEndDevice then
        floor.geometry.reflectionFalloffEnd = 10
    end
    floor.physicsBody = SCNPhysicsBody:staticBody()
    scene.rootNode:addChildNode(floor)
    
        -- add walls
    local wall = SCNNode:nodeWithGeometry(SCNBox:boxWithWidth_height_length_chamferRadius(400, 100, 4, 0))
    getResource("wall", 'public.image', wall.geometry.firstMaterial.diffuse, 'contents')
    wall.geometry.firstMaterial.diffuse.contentsTransform = ScnTypes.SCNMatrix4Mult(ScnTypes.SCNMatrix4MakeScale(24, 2, 1), 
                                                                                    ScnTypes.SCNMatrix4MakeTranslation(0, 1, 0))
    wall.geometry.firstMaterial.diffuse.wrapS = ScnMaterial.SCNWrapMode.Repeat
    wall.geometry.firstMaterial.diffuse.wrapT = ScnMaterial.SCNWrapMode.Mirror
    wall.geometry.firstMaterial.doubleSided = false
    wall.castsShadow = false
    wall.geometry.firstMaterial.locksAmbientWithDiffuse = true
        
    wall.position = SCNVector3(0, 50, -92)
    wall.physicsBody = SCNPhysicsBody:staticBody()
    scene.rootNode:addChildNode(wall)
    
    wall = wall:clone()
    getResource("wall", 'public.image', wall.geometry.firstMaterial.diffuse, 'contents')
    wall.position = SCNVector3(-202, 50, 0)
    wall.rotation = SCNVector4(0, 1, 0, M_PI/2)
    wall.physicsBody = SCNPhysicsBody:staticBody()
    scene.rootNode:addChildNode(wall)
        
    wall = wall:clone()
    getResource("wall", 'public.image', wall.geometry.firstMaterial.diffuse, 'contents')
    wall.position = SCNVector3(202, 50, 0)
    wall.rotation = SCNVector4(0, 1, 0, -M_PI/2)
    wall.physicsBody = SCNPhysicsBody:staticBody()
    scene.rootNode:addChildNode(wall)
    
    local backWall = SCNNode:nodeWithGeometry(objc.SCNPlane:planeWithWidth_height(400, 100))
    backWall.geometry.firstMaterial = wall.geometry.firstMaterial
    getResource("wall", 'public.image', wall.geometry.firstMaterial.diffuse, 'contents')
    backWall.position = SCNVector3(0, 50, 200)
    backWall.rotation = SCNVector4(0, 1, 0, M_PI)
    backWall.castsShadow = false
    backWall.physicsBody = SCNPhysicsBody:staticBody()
    scene.rootNode:addChildNode(backWall)
    
    -- add ceil
    local ceilNode = SCNNode:nodeWithGeometry(objc.SCNPlane:planeWithWidth_height(400, 400))
    ceilNode.position = SCNVector3(0, 100, 0)
    ceilNode.rotation = SCNVector4(1, 0, 0, M_PI/2)
    ceilNode.geometry.firstMaterial.doubleSided = false
    ceilNode.castsShadow = false
    ceilNode.geometry.firstMaterial.locksAmbientWithDiffuse = true
    scene.rootNode:addChildNode(ceilNode)
    
end

function GameViewController:addWoodenBlockToScene_withImageNamed_atPosition(scene, imageName, position)
    
    local block = SCNNode:node()
    block.position = position
    block.geometry = SCNBox:boxWithWidth_height_length_chamferRadius(5, 5, 5, 0)
    
    -- use the specified image as a texture
    getResource(imageName, 'public.image', block.geometry.firstMaterial.diffuse, 'contents')
    block.geometry.firstMaterial.diffuse.mipFilter = ScnMaterial.SCNFilterMode.Linear
    
    -- make it a physics body
    block.physicsBody = SCNPhysicsBody:dynamicBody()
    
    -- and add to the scene
    scene.rootNode:addChildNode(block)
end

function GameViewController:setupSceneElements(scene)
    -- add a train
    self:addTrainToScene_atPosition(scene, SCNVector3(-5, 20, -40))
    
    -- add wooden blocks
    self:addWoodenBlockToScene_withImageNamed_atPosition(scene, "WoodCubeA", SCNVector3(-10, 15, 10))
    self:addWoodenBlockToScene_withImageNamed_atPosition(scene, "WoodCubeB", SCNVector3( -9, 10, 10))
    self:addWoodenBlockToScene_withImageNamed_atPosition(scene, "WoodCubeC", SCNVector3(20, 15, -11))
    self:addWoodenBlockToScene_withImageNamed_atPosition(scene, "WoodCubeA", SCNVector3(25, 5, -20))
    
    --add more block
    for i = 1, 4 do
        self:addWoodenBlockToScene_withImageNamed_atPosition(scene, "WoodCubeA", SCNVector3(rand(60) - 30, 20, rand(40) - 20))
        self:addWoodenBlockToScene_withImageNamed_atPosition(scene, "WoodCubeB", SCNVector3(rand(60) - 30, 20, rand(40) - 20))
        self:addWoodenBlockToScene_withImageNamed_atPosition(scene, "WoodCubeC", SCNVector3(rand(60) - 30, 20, rand(40) - 20))
    end
    
    -- add cartoon book
    local block = SCNNode:node()
    block.position = SCNVector3(20, 10, -16)
    block.rotation = SCNVector4(0, 1, 0, -M_PI/4)
    block.geometry = SCNBox:boxWithWidth_height_length_chamferRadius(22, 0.5, 34, 0)
    local frontMat = SCNMaterial:material()
    frontMat.locksAmbientWithDiffuse = true
    frontMat.diffuse.contents = "book_front.jpg"
    frontMat.diffuse.mipFilter = ScnMaterial.SCNFilterMode.Linear
    local backMat = SCNMaterial:material()
    backMat.locksAmbientWithDiffuse = true
    backMat.diffuse.contents = "book_back.jpg"
    backMat.diffuse.mipFilter = ScnMaterial.SCNFilterMode.Linear
    block.geometry.materials = {frontMat, backMat}
    block.physicsBody = SCNPhysicsBody:dynamicBody()
    scene.rootNode:addChildNode(block)
    
    -- add carpet
    local rug = SCNNode:node()
    rug.position = SCNVector3(0, 0.01, 0)
    rug.rotation = SCNVector4(1, 0, 0, M_PI/2)
    local path = objc.UIBezierPath:bezierPathWithRoundedRect_cornerRadius(struct.CGRect(-50, -30, 100, 50), 2.5)
    path.flatness = 0.1
    rug.geometry = SCNShape:shapeWithPath_extrusionDepth(path, 0.05)
    rug.geometry.firstMaterial.locksAmbientWithDiffuse = true
    getResource('carpet', 'public.image', rug.geometry.firstMaterial.diffuse, 'contents')
    scene.rootNode:addChildNode(rug)
    
    -- add ball
    local ball = SCNNode:node()
    ball.position = SCNVector3(-5, 5, -18)
    ball.geometry = objc.SCNSphere:sphereWithRadius(5)
    ball.geometry.firstMaterial.locksAmbientWithDiffuse = true
    ball.geometry.firstMaterial.diffuse.contents = "ball.jpg"
    ball.geometry.firstMaterial.diffuse.contentsTransform = ScnTypes.SCNMatrix4MakeScale(2, 1, 1)
    ball.geometry.firstMaterial.diffuse.wrapS = ScnMaterial.SCNWrapMode.Mirror
    ball.physicsBody = SCNPhysicsBody:dynamicBody()
    ball.physicsBody.restitution = 0.9
    scene.rootNode:addChildNode(ball) 
end

function GameViewController:setupVehicle(scene)
    
    local carScene = SCNScene:sceneNamed("rc_car")
    local chassisNode = carScene.rootNode:childNodeWithName_recursively("rccarBody", false)
    
    -- setup the chassis
    chassisNode.position = SCNVector3(0, 10, 30)
    chassisNode.rotation = SCNVector4(0, 1, 0, M_PI)
    
    local chassisBody = SCNPhysicsBody:dynamicBody()
    chassisBody.allowsResting = false
    chassisBody.mass = 80
    chassisBody.restitution = 0.1
    chassisBody.friction = 0.5
    chassisBody.rollingFriction = 0
    
    chassisNode.physicsBody = chassisBody
    scene.rootNode:addChildNode(chassisNode)
    
    local pipeNode = chassisNode:childNodeWithName_recursively("pipe", true)
    self.reactor = objc.SCNParticleSystem:particleSystemNamed_inDirectory("reactor", nil)
    self.reactorDefaultBirthRate = self.reactor.birthRate
    self.reactor.birthRate = 0
    pipeNode:addParticleSystem(self.reactor)
    
    -- add wheels
    local wheel0Node = chassisNode:childNodeWithName_recursively("wheelLocator_FL", true)
    local wheel1Node = chassisNode:childNodeWithName_recursively("wheelLocator_FR", true)
    local wheel2Node = chassisNode:childNodeWithName_recursively("wheelLocator_RL", true)
    local wheel3Node = chassisNode:childNodeWithName_recursively("wheelLocator_RR", true)
    
    local wheel0 = objc.SCNPhysicsVehicleWheel:wheelWithNode(wheel0Node)
    local wheel1 = objc.SCNPhysicsVehicleWheel:wheelWithNode(wheel1Node)
    local wheel2 = objc.SCNPhysicsVehicleWheel:wheelWithNode(wheel2Node)
    local wheel3 = objc.SCNPhysicsVehicleWheel:wheelWithNode(wheel3Node)
    
    local _, wheelMin, wheelMax = wheel0Node:getBoundingBoxMin_max()
    local wheelHalfWidth = 0.5 * (wheelMax.x - wheelMin.x);
    
    local wheel0ConnectionPosition = wheel0Node:convertPosition_toNode(SCNVector3Zero, chassisNode)
    wheel0ConnectionPosition.x = wheel0ConnectionPosition.x + wheelHalfWidth
    local wheel1ConnectionPosition = wheel1Node:convertPosition_toNode(SCNVector3Zero, chassisNode)
    wheel1ConnectionPosition.x = wheel1ConnectionPosition.x - wheelHalfWidth
    local wheel2ConnectionPosition = wheel2Node:convertPosition_toNode(SCNVector3Zero, chassisNode)
    wheel2ConnectionPosition.x = wheel2ConnectionPosition.x + wheelHalfWidth
    local wheel3ConnectionPosition = wheel3Node:convertPosition_toNode(SCNVector3Zero, chassisNode)
    wheel3ConnectionPosition.x = wheel3ConnectionPosition.x - wheelHalfWidth
    
    wheel0.connectionPosition = wheel0ConnectionPosition
    wheel1.connectionPosition = wheel1ConnectionPosition
    wheel2.connectionPosition = wheel2ConnectionPosition
    wheel3.connectionPosition = wheel3ConnectionPosition
    
    -- create the physics vehicle
    local vehicle = objc.SCNPhysicsVehicle:vehicleWithChassisBody_wheels(chassisBody, {wheel0, wheel1, wheel2, wheel3})
    scene.physicsWorld:addBehavior(vehicle)
    self.vehicle = vehicle
    
    return chassisNode
end

function GameViewController:setupScene()
    
    local scene = SCNScene:scene()
    
    self:setupEnvironment(scene)
    self:setupSceneElements(scene)
    
    self.vehicleNode = self:setupVehicle(scene)
    
    -- add an ambiant light
    local ambientLight = SCNNode:node()
    ambientLight.light = SCNLight:light()
    ambientLight.light.type = ScnLight.TypeAmbient
    ambientLight.light.color = UIColor:colorWithWhite_alpha(0.3, 1.0)
    scene.rootNode:addChildNode(ambientLight)
    
    -- add a key light to the scene
    local lightNode = SCNNode:node()
    lightNode.light = SCNLight:light()
    lightNode.light.type = ScnLight.TypeSpot
    if self.isHighEndDevice then
        lightNode.light.castsShadow = true
    end
    lightNode.light.color = UIColor:colorWithWhite_alpha(0.8, 1.0)
    lightNode.position = SCNVector3(0, 80, 30)
    lightNode.rotation = SCNVector4(1,0,0,-M_PI/2.8)
    lightNode.light.spotInnerAngle = 0
    lightNode.light.spotOuterAngle = 50
    lightNode.light.shadowColor = UIColor.blackColor
    lightNode.light.zFar = 500
    lightNode.light.zNear = 50
    scene.rootNode:addChildNode(lightNode)
    
    -- keep an ivar for later manipulation
    self.spotLightNode = lightNode
    
    -- create a main camera
    local cameraNode = SCNNode:node()
    cameraNode.camera = objc.SCNCamera:camera()
    cameraNode.camera.zFar = 500
    cameraNode.position = SCNVector3(0, 60, 50)
    cameraNode.rotation = SCNVector4(1, 0, 0, -M_PI/5)
    scene.rootNode:addChildNode(cameraNode)
    self.cameraNode = cameraNode
    
    -- add a secondary camera to the car
    local frontCameraNode = SCNNode:node()
    frontCameraNode.camera = objc.SCNCamera:camera()
    frontCameraNode.camera.zFar = 500
    frontCameraNode.camera.xFov = 75
    frontCameraNode.position = SCNVector3(0, 3.5, 2.5)
    frontCameraNode.rotation = SCNVector4(0, 1, 0, M_PI)
    self.vehicleNode:addChildNode(frontCameraNode)
    self.frontCameraNode = frontCameraNode
    
    -- add a third camera slightly behind the car
    local backCameraNode = SCNNode:node()
    backCameraNode.camera = objc.SCNCamera:camera()
    backCameraNode.camera.zFar = 500
    backCameraNode.camera.xFov = 75
    backCameraNode.position = SCNVector3(0, 15, -20)
    backCameraNode.rotation = SCNVector4(0, 1, 0.18, M_PI)
    self.vehicleNode:addChildNode(backCameraNode)
    self.backCameraNode = backCameraNode
    
    return scene
end

function GameViewController:viewDidLoad()
    -- call superclass
    self[objc.UIViewController]:viewDidLoad()
    
    local scnView = self.view
    scnView.backgroundColor = UIColor.blackColor
    
    -- setup the scene
    local scene = self:setupScene()
    scnView.scene = scene
    
    -- tweak physics
    scnView.scene.physicsWorld.speed = 4.0
    
    -- setup overlays
    scnView.overlaySKScene = objc.AAPLOverlayScene:newWithSize(scnView.bounds.size)
    
    -- setup accelerometer
    self:setupAccelerometer()
    
    -- set initial point of view
    scnView.pointOfView = self.cameraNode
    
    -- plug game logic
    scnView.delegate = self
    
    -- subscribe to update message
    self:addMessageHandler("system.did_load_module", "refreshScene")
end

local vehicleMaxSpeed = 250
local defaultEngineForce = 250.0
local defaultBrakingForce = 2.0
local steeringClamp = 0.4
local cameraDamping = 0.8

function GameViewController:renderer_didSimulatePhysicsAtTime(renderer, time)
    
    local scnView = self.view
    
    local engineForce = 0
    local brakingForce = 0
    
    local orientation = self.orientation / 2
    
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
    
    self.vehicleSteering = -orientation
    if orientation == 0 then
        self.vehicleSteering = self.vehicleSteering * 0.9
    elseif self.vehicleSteering > steeringClamp then
        self.vehicleSteering = steeringClamp
    elseif self.vehicleSteering < -steeringClamp then
        self.vehicleSteering = -steeringClamp
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
        local cameraTargetPosition = {x = carPosition.x, y = 18.0, z = carPosition.z + 20.0}
        self.cameraNode.position = cameraTargetPosition
        self.cameraNode.position = { x = cameraTargetPosition.x + cameraDamping * (cameraPosition.x - cameraTargetPosition.x),
                                     y = cameraTargetPosition.y + cameraDamping * (cameraPosition.y - cameraTargetPosition.y),
                                     z = cameraTargetPosition.z + cameraDamping * (cameraPosition.z - cameraTargetPosition.z)}
        
        -- move the spollight on top of the car
        self.spotLightNode.position = SCNVector3(carPosition.x, 40., carPosition.z + 30)
        self.spotLightNode.rotation = SCNVector4(1,0,0,-M_PI/3.4)
        self.spotLightNode.light.spotInnerAngle = 0
        self.spotLightNode.light.spotOuterAngle = 50
        
    else
        local backCameraNode = self.backCameraNode
            
        if scnView.pointOfView == self.backCameraNode then
            local cameraPosition = self.backCameraNode.position
            local cameraTargetPosition = SCNVector3(0, 25, -20 - vehicle.speedInKilometersPerHour / 10)
            backCameraNode.position = { x = cameraTargetPosition.x + cameraDamping * (cameraPosition.x - cameraTargetPosition.x),
                                        y = cameraTargetPosition.y + cameraDamping * (cameraPosition.y - cameraTargetPosition.y),
                                        z = cameraTargetPosition.z + cameraDamping * (cameraPosition.z - cameraTargetPosition.z)}
       end
            
        -- move the spotlight in front of the camera
        local frontPosition = scnView.pointOfView.presentationNode:convertPosition_toNode(SCNVector3(0, 0, -30), nil)
        self.spotLightNode.position = SCNVector3(frontPosition.x, 70., frontPosition.z)
        self.spotLightNode.rotation = SCNVector4(1,0,0,-M_PI/2)
        self.spotLightNode.light.spotInnerAngle = 0
        self.spotLightNode.light.spotOuterAngle = 60
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

function GameViewController:refreshScene()
    local scnView = self.view
    local overlaySKScene = scnView.overlaySKScene
    
    --[[ -- Add a SKShapeNode to the overlay scene
    local triangleShape = objc.SKShapeNode:shapeNodeWithPoints_count({ {x=0, y=0}, {x=100, y=0}, {x=50, y=80}, {x=0, y=0} }, 4)
    triangleShape.position = {x=0, y=0}
    overlaySKScene:addChild(triangleShape)]]
end

return GameViewController
