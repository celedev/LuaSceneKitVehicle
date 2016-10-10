-- Scene setup methods for the Game View Controller

local ScnTypes = require 'SceneKit.SceneKitTypes'
local ScnLight = require 'SceneKit.SCNLight'
local ScnMaterial = require 'SceneKit.SCNMaterialProperty'

local GameViewController = class.extendClass (objc.GameViewController, "Game setup")

local SCNScene = objc.SCNScene
local SCNNode = objc.SCNNode
local SCNLight = objc.SCNLight
local SCNBox = objc.SCNBox
local SCNPhysicsBody = objc.SCNPhysicsBody
local SCNPhysicsShape = objc.SCNPhysicsShape
local SCNMaterial = objc.SCNMaterial
local SCNShape = objc.SCNShape
local SCNPhysicsVehicle = objc.SCNPhysicsVehicle

local SCNVector3 = struct.SCNVector3
local SCNVector4 = struct.SCNVector4
local SCNVector3Zero = ScnTypes.SCNVector3Zero

local UIColor = objc.UIColor

local NSLayoutConstraint = objc.NSLayoutConstraint

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

function GameViewController:cubeWithImageNamed_atPosition(imageName, position)
    
    local block = SCNNode:node()
    block.name = "cube"
    block.position = position
    block.geometry = SCNBox:boxWithWidth_height_length_chamferRadius(5, 5, 5, 0)
    
    -- use the specified image as a texture
    getResource(imageName, 'public.image', block.geometry.firstMaterial.diffuse, 'contents')
    block.geometry.firstMaterial.diffuse.mipFilter = ScnMaterial.SCNFilterMode.Linear
    
    -- make it a physics body
    block.physicsBody = SCNPhysicsBody:dynamicBody()   
    
    return block
end

function GameViewController:bookWithImagesNamed(frontImageName, backImageName)
    local book = SCNNode:node()
    book.name = "book"
    book.geometry = SCNBox:boxWithWidth_height_length_chamferRadius(22, 0.5, 34, 0)
    
    local frontMat = SCNMaterial:material()
    frontMat.locksAmbientWithDiffuse = true
    frontMat.diffuse.contents = frontImageName
    frontMat.diffuse.mipFilter = ScnMaterial.SCNFilterMode.Linear
    
    local backMat = SCNMaterial:material()
    backMat.locksAmbientWithDiffuse = true
    backMat.diffuse.contents = backImageName
    backMat.diffuse.mipFilter = ScnMaterial.SCNFilterMode.Linear
    
    book.geometry.materials = {frontMat, backMat}
    book.physicsBody = SCNPhysicsBody:dynamicBody()
    
    return book
end

function GameViewController:carpetWithImageNamed_size (imageName, size)
    local carpet = SCNNode:node()
    carpet.name = "carpet"
    carpet.rotation = SCNVector4(1, 0, 0, M_PI/2)
    local path = objc.UIBezierPath:bezierPathWithRoundedRect_cornerRadius(struct.CGRect({x = 0, y = 0}, size), 2.5)
    carpet.geometry = SCNShape:shapeWithPath_extrusionDepth(path, 0.05)
    carpet.geometry.firstMaterial.locksAmbientWithDiffuse = true
    getResource(imageName, 'public.image', function (image) carpet.geometry.firstMaterial.diffuse.contents = image end)
    return carpet
end

function SCNVector3:translate (vector)
    self.x = self.x + vector.x
    self.y = self.y + vector.y
    self.z = self.z + vector.z
end

function GameViewController:addTrainToScene_atPosition(scene, trainPosition)
    local trainScene = SCNScene:sceneNamed "train_flat"
    
    -- Physicalize the train wirth simple boxes
    trainScene.rootNode.childNodes:enumerateObjectsUsingBlock 
    (function (node)
         if node.geometry ~= nil then
             node.position:translate (trainPosition)
             
             local _, min, max = node:getBoundingBoxMin_max()
             node.pivot = ScnTypes.SCNMatrix4MakeTranslation(0, -min.y, 0);
             
             local nodeBox = SCNBox:boxWithWidth_height_length_chamferRadius (max.x - min.x, max.y - min.y, max.z -min.z, 0)
             local nodeBody = SCNPhysicsBody:dynamicBody()
             nodeBody.physicsShape = SCNPhysicsShape:shapeWithGeometry_options (nodeBox)
             node.physicsBody = nodeBody
             
             scene.rootNode:addChildNode (node)
         end
     end)
    
    -- add smoke
    local smokeHandle = scene.rootNode:childNodeWithName_recursively ('Smoke', true)
    smokeHandle:addParticleSystem (objc.SCNParticleSystem:particleSystemNamed_inDirectory('smoke'))
    
    -- add physics between engine and wagons
    local engineCar = scene.rootNode:childNodeWithName_recursively ("EngineCar", true)
    local wagon1 = scene.rootNode:childNodeWithName_recursively ("Wagon1", true)
    local wagon2 = scene.rootNode:childNodeWithName_recursively ("Wagon2", true)
    
    local _, eMin, eMax = engineCar:getBoundingBoxMin_max()
    local _, wMin, wMax = wagon1:getBoundingBoxMin_max()
    
    -- tie engineCar and wagon1, wagon1 and wagon2
    local SCNPhysicsBallSocketJoint = objc.SCNPhysicsBallSocketJoint
    scene.physicsWorld:addBehavior (SCNPhysicsBallSocketJoint:jointWithBodyA_anchorA_bodyB_anchorB (engineCar.physicsBody, SCNVector3(eMax.x, eMin.y, 0),
                                                                                                    wagon1.physicsBody, SCNVector3(wMin.x, wMin.y, 0)))
    scene.physicsWorld:addBehavior (SCNPhysicsBallSocketJoint:jointWithBodyA_anchorA_bodyB_anchorB (wagon1.physicsBody, SCNVector3(wMax.x + 0.1, wMin.y, 0),
                                                                                                    wagon2.physicsBody, SCNVector3(wMin.x - 0.1, wMin.y, 0)))
end

function GameViewController:setupSceneElements(scene)
    
    local rootNode = scene.rootNode
    
    -- add a train
    self:addTrainToScene_atPosition(scene, SCNVector3(-5, 20, -40))
    
    -- add wooden blocks
    rootNode:addChildNode (self:cubeWithImageNamed_atPosition("WoodCubeA", SCNVector3(-10, 15, 10)))
    rootNode:addChildNode (self:cubeWithImageNamed_atPosition("WoodCubeB", SCNVector3( -9, 10, 10)))
    rootNode:addChildNode (self:cubeWithImageNamed_atPosition("WoodCubeC", SCNVector3(20, 15, -11)))
    rootNode:addChildNode (self:cubeWithImageNamed_atPosition("WoodCubeA", SCNVector3(25, 5, -20)))
    
    --add more block
    for i = 1, 4 do
        rootNode:addChildNode (self:cubeWithImageNamed_atPosition("WoodCubeA", SCNVector3(rand(60) - 30, 20, rand(40) - 20)))
        rootNode:addChildNode (self:cubeWithImageNamed_atPosition("WoodCubeB", SCNVector3(rand(60) - 30, 20, rand(40) - 20)))
        rootNode:addChildNode (self:cubeWithImageNamed_atPosition("WoodCubeC", SCNVector3(rand(60) - 30, 20, rand(40) - 20)))
    end
    
    -- add cartoon book
    local book = self:bookWithImagesNamed("book_front.jpg", "book_back.jpg")
    book.position = SCNVector3(20, 10, -16)
    book.rotation = SCNVector4(0, 1, 0, -M_PI/4)
    rootNode:addChildNode(book)
    
    -- add carpet
    local rug =  self:carpetWithImageNamed_size('carpet', {width = 100, height = 50}) -- SCNNode:node()
    rug.position = SCNVector3(-50, 0.01, -30)
    rug.rotation = SCNVector4(1, 0, 0, M_PI/2)
    --[[ local path = objc.UIBezierPath:bezierPathWithRoundedRect_cornerRadius(struct.CGRect(-50, -30, 100, 50), 2.5)
    path.flatness = 0.1
    rug.geometry = SCNShape:shapeWithPath_extrusionDepth(path, 0.05)
    rug.geometry.firstMaterial.locksAmbientWithDiffuse = true
    getResource('carpet', 'public.image', rug.geometry.firstMaterial.diffuse, 'contents')
    ]]
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

return GameViewController