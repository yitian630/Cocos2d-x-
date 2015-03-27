require("Cocos2d")
require("Cocos2dConstants")
require("src/Csv")
local ASEffectPlayer = require("src/ASMusicPlayer")

local ASSoundSet = class("ASSoundSet",function ()
	return cc.Layer:create()
end)

ASSoundSet.__index = ASSoundSet


local visibleOrigin = cc.Director:getInstance():getVisibleOrigin()
local visibleSize = cc.Director:getInstance():getVisibleSize()

cc.FileUtils:getInstance():addSearchResolutionsOrder("src");
cc.FileUtils:getInstance():addSearchResolutionsOrder("res/begin");


--返回按钮回调
local function turnBack()
    ASEffectPlayer:getInstance():currentPlayEffect("button.wav",false)
    cc.Director:getInstance():popScene()
end

--对开关的设置
local function touchEvent(sender,TouchEventType)
    local soundValue = getEffect() -0
    local aButton = sender
    if TouchEventType == ccui.TouchEventType.began then
        ASEffectPlayer:getInstance():currentPlayEffect("button.wav",false)
    	
    	if soundValue == 1 then--aButton:getTag()+0 == 101  then
            aButton:loadTextures("res/setting/gameset_close.png","res/setting/gameset_close.png","")
    		aButton:setTag(102)
            ASEffectPlayer:getInstance():setVolume(0)
            saveSoundEffect(0)
            
    	else
            aButton:loadTextures("res/setting/gameset_open.png","res/setting/gameset_open.png","")
           aButton:setTag(101)
            ASEffectPlayer:getInstance():setVolume(1.0)
            saveSoundEffect(1)
    	end
    	
    end
end

--create
function ASSoundSet:create()
    local soundSet = ASSoundSet.new()
    if soundSet then
    	soundSet:init()
    end
    return soundSet
end

--init
function ASSoundSet:init()
    local colorLayer = cc.LayerColor:create(cc.c4b(130,181,150,221),visibleSize.width,visibleSize.height)
    colorLayer:setVisible(true)
    self:addChild(colorLayer,0)
    
    --背景框
    local bgFrame = cc.Sprite:create("res/setting/gameset_beijingkuang.png")
    bgFrame:setPosition(visibleOrigin.x+visibleSize.width/2,visibleOrigin.y+visibleSize.height/2)
    bgFrame:setScale(1)
    self:addChild(bgFrame,0)
    
    --喇叭图标
    local laBa = cc.Sprite:create("res/setting/gameset_sound.png")
    laBa:setScale(1.3)
    laBa:setAnchorPoint(1,0.5)
    laBa:setPosition(visibleOrigin.x+visibleSize.width/5*2,visibleOrigin.y+visibleSize.height/2)
    self:addChild(laBa,5)
    
    --返回
    local returnButton = cc.MenuItemImage:create("res/begin/gameset_back.png","res/begin/gameset_back_press.png")
    returnButton:registerScriptTapHandler(turnBack)
    returnButton:setAnchorPoint(0,0.5)
    returnButton:setPosition(visibleOrigin.x+visibleSize.width/20,visibleOrigin.y+visibleSize.height/10*9)

    local menu = cc.Menu:create(returnButton)
    menu:setPosition(0,0)
    self:addChild(menu,5)
    
    --声音设置
    local switchButton = ccui.Button:create()
    switchButton:setTouchEnabled(true)
    switchButton:setScale(1.3)
    switchButton:loadTextures("res/setting/gameset_open.png","res/setting/gameset_open.png","")
    if getEffect()-0 == 1 then
    	switchButton:loadTextures("res/setting/gameset_open.png","res/setting/gameset_open.png","")
    else
        switchButton:loadTextures("res/setting/gameset_close.png","res/setting/gameset_open.png","")
    end
    switchButton:setPosition(visibleOrigin.x+visibleSize.width/3*2,visibleOrigin.y+visibleSize.height/2)
    switchButton:addTouchEventListener(touchEvent)
    switchButton:setTag(101)
    self:addChild(switchButton,3)
    
end

return ASSoundSet