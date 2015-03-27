 require("Cocos2d")
require("Cocos2dConstants")

local ASBackgroundLayer = class("src/ASBackgroundLayer",function ()
	return cc.Layer:create()
end)

local visibleOrigin = cc.Director:getInstance():getVisibleOrigin()
local visibleSize = cc.Director:getInstance():getVisibleSize()

function ASBackgroundLayer.create()
	local backgroundLayer = ASBackgroundLayer.new()
	
	if backgroundLayer then
		backgroundLayer:init()
	end
	
	return backgroundLayer
end

function ASBackgroundLayer:init()
    --saveLevel(0)
    --添加背景
    local bg = cc.Sprite:create("res/begin/background.png")
    bg:setScale(0.8)--bg:setScale(visibleSize.width/bg:getContentSize().width,visibleSize.height/bg:getContentSize().height)
    bg:setPosition(visibleOrigin.x+visibleSize.width/2,visibleOrigin.y+visibleSize.height/2)
    self:addChild(bg,0)
    
    
    --添加钉子
    local headChip = cc.Sprite:create("res/spike/spikesup.png")
    headChip:setAnchorPoint(cc.p(0.5,0.6))
    headChip:setPosition(visibleOrigin.x+visibleSize.width/2,visibleOrigin.y+visibleSize.height)
    self:addChild(headChip,1)

    local sheetChip = cc.Sprite:create("res/spike/spikedown.png")
    sheetChip:setAnchorPoint(cc.p(0.5,0.2))
    sheetChip:setPosition(visibleOrigin.x+visibleSize.width/2,visibleOrigin.y)
    self:addChild(sheetChip,1)


end

return ASBackgroundLayer