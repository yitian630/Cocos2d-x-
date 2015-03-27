require("Cocos2d")
require("Cocos2dConstants")
local ASEffectPlayer = require("src/ASMusicPlayer")
local ASTipLayer = class("src/ASTipLayer",function ()
	return cc.Layer:create()
end)

local visibleOrigin = cc.Director:getInstance():getVisibleOrigin()
local visibleSize = cc.Director:getInstance():getVisibleSize()

function ASTipLayer.create()
	local tipLayer = ASTipLayer.new()
	if tipLayer then
		tipLayer:init()
	end
	
	return tipLayer
end

function ASTipLayer:init()
    local bgFrame = cc.Sprite:create("res/EndScene/tip_frame.png")
    bgFrame:setPosition(visibleOrigin.x+visibleSize.width/2,visibleOrigin.y+visibleSize.height*0.6)
    self:addChild(bgFrame,0)
    
    --设置提示文字
--    local tipText = cc.Label:createWithTTF("the gold isn't enough","res/fonts/Marker Felt.ttf",60)
--    tipText:setPosition(visibleOrigin.x+visibleSize.width/2,visibleOrigin.y+visibleSize.height/5*3)
--    self:addChild(tipText,1)
    
    --按钮事件回调
    local function touchEvent(sender,TouchEventType)
        if TouchEventType == ccui.TouchEventType.ended then
            ASEffectPlayer:getInstance():currentPlayEffect("button.wav")
        	self:getParent():removeChild(self)
           
        end
    end
    
    --设置按钮
    local sureButton = ccui.Button:create()
    sureButton:loadTextures("res/EndScene/ok.png","res/EndScene/ok_pressed.png","")
    sureButton:setPosition(visibleOrigin.x+visibleSize.width/2,visibleOrigin.y+visibleSize.height*0.5)
    sureButton:addTouchEventListener(touchEvent)
    self:addChild(sureButton,1)
    
    --屏蔽触摸传递
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function()
    return true
    end ,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function()
        return true
    end ,cc.Handler.EVENT_TOUCH_ENDED)
    
    listener:setSwallowTouches(true)
    
    --创建事件分发器
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    
end

return ASTipLayer