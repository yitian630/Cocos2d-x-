--
-- ASGameOverScene 游戏结束场景
--
require("data.Csv")
local ASEffectPlayer = require("global.ASMusicPlayer")

local ASGameOverScene = class("ASGameOverScene", function()
    return cc.Scene:create()
end)

local director = cc.Director:getInstance()
local origin = director:getVisibleOrigin()
local size = director:getVisibleSize()
local grayPlaneItem = nil
local goldPlaneItem = nil
local message = nil
-- 返回菜单按钮 
local gobackItem = nil
-- 重新开始游戏
local replayItem = nil
-- 最远飞行距离Label
local distanceMaxLabel = nil
-- 最远飞行距离值
local distanceMaxText = nil

-- 本次飞行距离Label
local distanceCurLabel = nil
-- 本次飞行距离值
local distanceCurText = nil
-- 飞机解锁Label
local unlockDis = nil
local unlockDisNumber = nil
ASGameOverScene.__index = ASGameOverScene

----------------------------------------------------
-- create - 创建对象
-- @param：void
-- @return：返回创建的对象
----------------------------------------------------
function ASGameOverScene.create()
    local scene = ASGameOverScene.new()

    if nil ~= scene then
        if scene:init() ~= true then
            return nil
        end
    end

    return scene
end

-- 选择灰色飞机按钮回调
function grayItemHandler()
    ASEffectPlayer:getInstance():currentPlayEffect("button.wav",false)
    -- 灰色飞机状态
    local grayPlaneOn = cc.MenuItemImage:create("Images/MenuImage/planeGray_select.png","Images/MenuImage/planeGray_normal.png",nil)
    local grayPlaneOff = cc.MenuItemImage:create("Images/MenuImage/planeGray_normal.png","Images/MenuImage/planeGray_select.png",nil)
    -- 金色飞机状态
    local goldPlaneOn = cc.MenuItemImage:create("Images/MenuImage/planeGold_select.png","Images/MenuImage/planeGold_normal.png",nil)
    local goldPlaneOff = cc.MenuItemImage:create("Images/MenuImage/planeGold_normal.png","Images/MenuImage/planeGold_select.png",nil)
   
    -- 点击灰色飞机，设置黄色飞机未被选中
    cc.UserDefault:getInstance():setBoolForKey("isYellowSelect",false)

    local isYellowUnlock = cc.UserDefault:getInstance():getBoolForKey("isYellowUnlock")
    if isYellowUnlock == true then
        ASEffectPlayer:getInstance():currentPlayEffect("button.wav",false)      
        
        message:setString("普通战机")
       
        grayPlaneItem:setNormalImage(grayPlaneOn)
        grayPlaneItem:setSelectedImage(grayPlaneOff)
        goldPlaneItem:setNormalImage(goldPlaneOff)
        goldPlaneItem:setSelectedImage(goldPlaneOn)
    end
       
end
-- 选择金色飞机按钮回调
function goldItemHandler()

    -- 灰色飞机状态
    local grayPlaneOn = cc.MenuItemImage:create("Images/MenuImage/planeGray_select.png","Images/MenuImage/planeGray_normal.png",nil)
    local grayPlaneOff = cc.MenuItemImage:create("Images/MenuImage/planeGray_normal.png","Images/MenuImage/planeGray_select.png",nil)
    -- 金色飞机状态
    local goldPlaneOn = cc.MenuItemImage:create("Images/MenuImage/planeGold_select.png","Images/MenuImage/planeGold_normal.png",nil)
    local goldPlaneOff = cc.MenuItemImage:create("Images/MenuImage/planeGold_normal.png","Images/MenuImage/planeGold_select.png",nil)

    local isYellowUnlock = cc.UserDefault:getInstance():getBoolForKey("isYellowUnlock")
    if isYellowUnlock == true then
        ASEffectPlayer:getInstance():currentPlayEffect("button.wav",false)     
        
        message:setString("黄金战机开局奖励1000米")
       
        grayPlaneItem:setNormalImage(grayPlaneOff)
        grayPlaneItem:setSelectedImage(grayPlaneOn)
        goldPlaneItem:setNormalImage(goldPlaneOn)
        goldPlaneItem:setSelectedImage(goldPlaneOff)
        cc.UserDefault:getInstance():setBoolForKey("isYellowSelect",true)
    else
        ASEffectPlayer:getInstance():currentPlayEffect("button_unlock.mp3",false)
    end
  
end

----------------------------------------------------
-- init - （auto-invoked）
-- @param：void
-- @return：bool类型，表示创建是否成功
----------------------------------------------------
function ASGameOverScene:init()
    bestDistance = getDistance() - 0
    if bestDistance >= 5000 then
        --todo
        cc.UserDefault:getInstance():setBoolForKey("isYellowUnlock",true)
    end
    local isYellowUnlock = cc.UserDefault:getInstance():getBoolForKey("isYellowUnlock")
    
    ASEffectPlayer:getInstance():currentPlayEffect("ASFailMusic.mp3",false)    
    local layer = cc.Layer:create()
    self:addChild(layer, -100)

    -- 添加背景精灵
    local background = cc.Sprite:create("Images/img_endbg.png")
    background:setPosition(cc.p(size.width/2,size.height/2))
    layer:addChild(background)
    
    --添加最高分，最高分从文件中获取
    print("bestDistance == "..bestDistance)
    -- if bestDistance < ASGlobalClient.distance then
    --     bestDistance = ASGlobalClient.distance
    --     saveDistance(bestDistance)
    -- end
    

    distanceMaxLabel = cc.Label:createWithBMFont("fonts/ziti.fnt","最远飞行距离:")
    distanceMaxLabel:setScale(1.6)
    distanceMaxText = cc.Label:createWithBMFont("fonts/ziti.fnt",bestDistance.."米")
    distanceMaxText:setScale(1.6)
    distanceCurLabel = cc.Label:createWithBMFont("fonts/ziti.fnt","本次飞行距离:")
    distanceCurLabel:setScale(1.6)
    distanceCurText = cc.Label:createWithBMFont("fonts/ziti.fnt",ASGlobalClient.distance.."米")
    distanceCurText:setScale(1.6)
  
    distanceMaxLabel:setPosition(cc.p(size.width/3, size.height-size.height/12))
    layer:addChild(distanceMaxLabel)
   
    if bestDistance == ASGlobalClient.distance then
        distanceMaxText:runAction(cc.Blink:create(2,5))
    end
    distanceMaxText:setPosition(cc.p(distanceMaxLabel:getPositionX()+distanceMaxLabel:getBoundingBox().width/2+distanceMaxText:getBoundingBox().width/2, distanceMaxLabel:getPositionY()))
    layer:addChild(distanceMaxText)
   
    distanceCurLabel:setPosition(cc.p(size.width/3, distanceMaxLabel:getPositionY()-size.height/12))
    layer:addChild(distanceCurLabel)
   
    distanceCurText:setPosition(cc.p(distanceCurLabel:getPositionX()+distanceCurLabel:getBoundingBox().width/2+distanceCurText:getBoundingBox().width/2, distanceCurLabel:getPositionY()))
    distanceCurText:runAction(cc.Blink:create(2,5))
    layer:addChild(distanceCurText)
   
    if isYellowUnlock == true then
        local isYellowSelect = cc.UserDefault:getInstance():getBoolForKey("isYellowSelect")
        if isYellowSelect == true then
            message = cc.Label:createWithBMFont("fonts/ziti.fnt","黄金战机开局奖励1000米")
        else
            
            message = cc.Label:createWithBMFont("fonts/ziti.fnt","恭喜你获得黄金战机,\n选择你喜欢的战机吧!!!")     
        end 
    else   
        local subDis = 5000 - ASGlobalClient.distance             
        message = cc.Label:createWithBMFont("fonts/ziti.fnt","还差"..subDis.."米获得\n黄金战机,加油!!!")
        message:setScale(1.5)            
    end
    message:runAction(cc.Repeat:create(cc.Sequence:create(cc.ScaleBy:create(0.3,1.1),cc.ScaleTo:create(0.3,1.5)),5))
    message:setPosition(size.width/2,distanceCurLabel:getPositionY()-size.height/12-message:getBoundingBox().height/2)
    layer:addChild(message)
    -- 点击返回事件回调
    function mainMenuHandler()
--        print("返回主场景")
        ASEffectPlayer:getInstance():stopPlayer("all")
        ASEffectPlayer:getInstance():currentPlayEffect("button.wav",false)
        saveDistance(bestDistance)
        if bestDistance < ASGlobalClient.distance then
            saveDistance(ASGlobalClient.distance)
        end
        ASGlobalClient.isRestart = false
        -- 获取主场景对象
        local ASMainMenuScene = require("scene.ASMainMenuScene")
        local mainScene = ASMainMenuScene.create()
        director:replaceScene(mainScene)
        --        director:replaceScene(cc.TransitionFade:create(1,mainScene))
    end

    -- 重新开始游戏
    function restartHandler()
        ASEffectPlayer:getInstance():stopPlayer("all")
        ASEffectPlayer:getInstance():currentPlayEffect("button.wav",false)
        saveDistance(bestDistance)
        if bestDistance < ASGlobalClient.distance then
            saveDistance(ASGlobalClient.distance)
        end
        ASGlobalClient.isRestart = true
        local ASMainGameScene = require("scene.ASMainGameScene")
        local mainGame = ASMainGameScene.create()
        director:replaceScene(mainGame)
    end
    local gobackLabel = cc.Label:createWithBMFont("fonts/ziti.fnt","返回主页")
    gobackLabel:setAnchorPoint(cc.p(0.5,0.5))
    gobackItem = cc.MenuItemLabel:create(gobackLabel)
    gobackItem:setScale(2)
    local replayLabel = cc.Label:createWithBMFont("fonts/ziti.fnt","重新开始")
    replayLabel:setAnchorPoint(cc.p(0.5,0.5))
    replayItem = cc.MenuItemLabel:create(replayLabel)
    replayItem:setScale(2)
    gobackItem:registerScriptTapHandler(mainMenuHandler)   
    replayItem:registerScriptTapHandler(restartHandler)
    
    local menu = cc.Menu:create(gobackItem,replayItem)
    menu:alignItemsHorizontallyWithPadding(size.width/10)
    menu:setPosition(cc.p(size.width/2,origin.y+size.height/5))
    layer:addChild(menu)

    if isYellowUnlock == true then
    	-- 解锁,判断黄色飞机是否被选中
    	local isSelect = cc.UserDefault:getInstance():getBoolForKey("isYellowSelect")
    	if isSelect == true then
            grayPlaneItem = cc.MenuItemImage:create("Images/MenuImage/planeGray_normal.png","Images/MenuImage/planeGray_select.png",nil)
            goldPlaneItem = cc.MenuItemImage:create("Images/MenuImage/planeGold_select.png","Images/MenuImage/planeGold_normal.png",nil)
    	else
            grayPlaneItem = cc.MenuItemImage:create("Images/MenuImage/planeGray_select.png","Images/MenuImage/planeGray_normal.png",nil)
            goldPlaneItem = cc.MenuItemImage:create("Images/MenuImage/planeGold_normal.png","Images/MenuImage/planeGold_select.png",nil)
    	end
    elseif isYellowUnlock == false then
        grayPlaneItem = cc.MenuItemImage:create("Images/MenuImage/planeGray_select.png","Images/MenuImage/planeGray_normal.png",nil)
        goldPlaneItem = cc.MenuItemImage:create("Images/MenuImage/planeGold_locked.png",nil)

        unlockDis = cc.Label:createWithBMFont("fonts/ziti.fnt","5000米解锁")
          
        unlockDis:setPosition(110,30)
        goldPlaneItem:addChild(unlockDis)
    end
        
    grayPlaneItem:registerScriptTapHandler(grayItemHandler)    
    goldPlaneItem:registerScriptTapHandler(goldItemHandler)
    
    local planeMenus = cc.Menu:create(grayPlaneItem,goldPlaneItem)
    planeMenus:alignItemsHorizontally()
    planeMenus:setPosition(size.width/2,size.height/2-size.height/14)
    layer:addChild(planeMenus)

     -- 添加键盘监听
    local luaj = require("cocos.cocos2d.luaj")
    --do
    local function onKeyReleased(keyCode, event)
        if keyCode == cc.KeyCode.KEY_BACK then
            print("BACK clicked!")
            local className = "org/cocos2dx/lua/AppActivity"
            local method = "exitGameStatic"
            luaj.callStaticMethod(className, method)
        elseif keyCode == cc.KeyCode.KEY_MENU  then
            print("MENU clicked!")
        end
    end
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )

    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

    return true
end

return ASGameOverScene
