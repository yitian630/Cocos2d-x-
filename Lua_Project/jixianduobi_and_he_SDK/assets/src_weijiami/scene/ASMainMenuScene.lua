-- ASMainMenuScene 主菜单场景

require("data.Csv")
local ASEffectPlayer = require("global.ASMusicPlayer")
local ASMusicPlayer = require("global.ASBackGroundMusicPlayer")
-- 获取加载场景对象
local ASLoadingScene = require("scene.ASLoadingScene")
-- 获取游戏场景对象
local ASMainGameScene = require("scene.ASMainGameScene")
-- 音乐按钮
local musicSetItem = nil
-- 音效按钮
local soundSetItem = nil
-- 飞机LOGO
local currentCraft = nil
local onItem = nil
local offItem = nil
-- 开始游戏按钮
local startGameButton = nil
local ASMainMenuScene = class("ASMainMenuScene", function ()
    return cc.Scene:create()
end)

local director = cc.Director:getInstance()
local origin = director:getVisibleOrigin()
local size = director:getVisibleSize()

ASMainMenuScene.__index = ASMainMenuScene

-------------------------------------------
-- create - 创建对象
-- @param: void
-- @return: 返回创建的对象
-------------------------------------------
function ASMainMenuScene.create()   
    local scene = ASMainMenuScene.new()
    if nil ~= scene then
        if scene:init() ~= true then return nil end
    end

    return scene
end

-- 音效按钮回调
local function soundCallBack()
    ASEffectPlayer:getInstance():currentPlayEffect("button.wav",false)
    local soundValue = getEffect()-0

    if soundValue == 1 then
       print("音效关")
        -- 设置音量
        ASEffectPlayer:getInstance():setVolume(0)
        saveSoundEffect(0)
    else
       print("音效开")
        ASEffectPlayer:getInstance():setVolume(1)
        saveSoundEffect(1)
    end

end

-- 音乐按钮回调
local function shopCallBack()
    local scene = require("scene.ASShopScene")
    shopScene = scene.create()
    director:pushScene(shopScene)
end 

------------------------------------------
-- init - 初始化（auto-invoked）
-- @param: void
-- @return: bool类型，表示创建是否成功
------------------------------------------
function ASMainMenuScene:init()
--    print("init()")
    local layer = cc.Layer:create()
    self:addChild(layer, -100)

    -- 添加背景精灵
    local background = cc.Sprite:create("Images/img_bg_logo.jpg")
    background:setPosition(cc.p(size.width/2,size.height/2))
    layer:addChild(background)

    -- 添加当前飞机展示
    currentCraft = cc.Sprite:create("Images/LOGO.png")
    currentCraft:setScale(1.5)
    currentCraft:setPosition(cc.p(size.width/2,size.height/7*5.2))
    layer:addChild(currentCraft)

    -- 点“开始游戏”事件回调
    function startGameHandler()
--        print("进入加载游戏场景")
        ASEffectPlayer:getInstance():currentPlayEffect("button.wav",false)
        local b = cc.UserDefault:getInstance():getBoolForKey("first_time")
        if b == true then
            local loadScene = ASLoadingScene.create()
            director:replaceScene(loadScene)       
        else
            local gameScene = ASMainGameScene.create()
            director:replaceScene(gameScene)
        end 
    end
    
    local startLabel = cc.Label:createWithBMFont("fonts/ziti.fnt","开始游戏")
    startGameButton = cc.MenuItemLabel:create(startLabel)
    startGameButton:setScale(2.5)
    startGameButton:registerScriptTapHandler(startGameHandler)
    local startMenu = cc.Menu:create(startGameButton)
    startMenu:setPosition(cc.p(size.width/2,size.height/7*3))
    layer:addChild(startMenu)

    -- 创建音效菜单项
    local onLabel = cc.Label:createWithBMFont("fonts/ziti.fnt","音效开")
    onLabel:setAnchorPoint(cc.p(0.5,0.5))
    local offLabel = cc.Label:createWithBMFont("fonts/ziti.fnt","音效关")
    offLabel:setAnchorPoint(cc.p(0.5,0.5))
    onItem = cc.MenuItemLabel:create(onLabel)
    offItem = cc.MenuItemLabel:create(offLabel)
    local soundValue = getEffect()-0
    if soundValue == 1 then
        ASEffectPlayer:getInstance():setVolume(1)
        soundSetItem = cc.MenuItemToggle:create(onItem)
        soundSetItem:addSubItem(offItem)
    else  
        ASEffectPlayer:getInstance():setVolume(0)
        soundSetItem = cc.MenuItemToggle:create(offItem) 
        soundSetItem:addSubItem(onItem)
    end  
    soundSetItem:setScale(2)
    soundSetItem:registerScriptTapHandler(soundCallBack)

    -- 创建商店菜单项
    local shopLabel = cc.Label:createWithBMFont("fonts/ziti.fnt","商城")
    shopItem = cc.MenuItemLabel:create(shopLabel)
    shopItem:setScale(2)
    shopItem:registerScriptTapHandler(shopCallBack)

    -- 根据菜单项创建菜单
    local menus = cc.Menu:create(soundSetItem,shopItem)
    -- 菜单项横向排列
    menus:alignItemsHorizontallyWithPadding(size.width/4)
    -- 设置菜单位置
    menus:setPosition(cc.p(size.width/2,origin.y+size.height/5))

    layer:addChild(menus)

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

return ASMainMenuScene