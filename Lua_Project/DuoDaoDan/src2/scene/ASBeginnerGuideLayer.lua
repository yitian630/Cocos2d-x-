-- ASBeginnerGuideLayer

local ASBeginnerGuideLayer = class("ASBeginnerGuideLayer",function()
	return cc.Layer:create()
end)

local director = cc.Director:getInstance()
local size = director:getVisibleSize()
local origin = director:getVisibleOrigin()

ASBeginnerGuideLayer.__index = ASBeginnerGuideLayer
nodef = nil
label = nil

local kTagClipNode = 100
----------------------------------------------------
-- create - 创建对象
-- @param：void
-- @return：返回创建的对象
----------------------------------------------------
function ASBeginnerGuideLayer.create()
    local layer = ASBeginnerGuideLayer.new()
    if nil ~= layer then
        if layer:init() ~= true then
            return nil
        end 
    end

    return layer
end

-----------------------------------------------------
-- init - 初始化（auto-invoked）
-- @param：void
-- @return：bool类型，表示创建是否成功
-----------------------------------------------------
function ASBeginnerGuideLayer:init()
    -- 判断当前语言
    local currentLanguageType = cc.Application:getInstance():getCurrentLanguage()
    -- 设置裁剪节点
    local clip = cc.ClippingNode:create()
    -- 设置底板可见
    clip:setInverted(true)
    clip:setAlphaThreshold(0)
    clip:setPosition(0,0)
    self:addChild(clip,0,kTagClipNode)
    
    -- 在裁剪节点添加一个灰色的透明层 
    local layerColor = cc.LayerColor:create(cc.c4b(0,0,0,80))
    clip:addChild(layerColor,100)
    -- 创建模板，也就是你要在裁剪节点上挖出来的那个”洞“是什么形状的，这里我用btn的图标来作为模板 
    nodef = cc.Sprite:create("Images/btn.png")
    nodef:setPosition(size.width/6*5, size.height/2)
    nodef:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleBy:create(0.3,0.95),cc.ScaleTo:create(0.3,1))))
    clip:setStencil(nodef) -- 设置模板  
    
    if currentLanguageType == cc.LANGUAGE_CHINESE then
        label = cc.Label:createWithBMFont("fonts/ziti.fnt","点击")
        label:setScale(2.0)
    else
        label = cc.Label:createWithBMFont("fonts/ziti.fnt","Click")
        label:setScale(1.5)
    end    
    label:setAnchorPoint(0.5,0.5)    
    label:setPosition(nodef:getPositionX(), nodef:getPositionY())
    self:addChild(label)

    return true
end

return ASBeginnerGuideLayer