--
-- ASSelectCraftScene 选择飞机场景
--

local ASSelectCraftScene = class("ASSelectCraftScene", function()
	return cc.Scene:create()
end)

local director = cc.Director:getInstance()
local size = director:getVisibleSize()
local origin = director:getVisibleOrigin()

ASSelectCraftScene.__index = ASSelectCraftScene

-------------------------------------------------------------------
-- create - 创建对象
-- @param：void
-- @return：返回创建的对象
-------------------------------------------------------------------
function ASSelectCraftScene.create()
	local scene = ASSelectCraftScene.new()
    if nil ~= scene then
        if scene:init() ~= true then
			return nil
		end
	end
	
    return scene
end

-------------------------------------------------------------------
-- init - 初始化（auto-invoked）
-- @param：void
-- @return：bool类型，表示创建是否成功
-------------------------------------------------------------------
function ASSelectCraftScene:init()
    -- 初始化背景颜色层
    local layer = cc.LayerColor:create(cc.c4b(0,255,0,255), size.width, size.height)
    self:addChild(layer)

    -- 添加不同的飞机
    local craft1 = cc.MenuItemImage:create("Craft/craft1.png", "Craft/craft1.png", nil)

    local craft2 = cc.MenuItemImage:create("Craft/craft2.png", "Craft/craft2.png", nil)

    local craft3 = cc.MenuItemImage:create("Craft/craft3.png", "Craft/craft3.png", nil)
    local craftMenu = cc.Menu:create(craft1, craft2, craft3)
    craftMenu:setPosition(cc.p(size.width/2,size.height/2))
    craftMenu:alignItemsVertically()
    layer:addChild(craftMenu)

    -- 点击返回事件回调
    function goBackHandler()
        print("返回主场景")
        -- 获取主场景对象
        local ASMainMenuScene = require("scene.ASMainMenuScene")
        local mainScene = ASMainMenuScene.create()
        director:replaceScene(mainScene)
    end
    local label = cc.Label:createWithTTF("back", "fonts/Marker Felt.ttf", 30)
    label:setColor(cc.c3b(0,0,0))
    local item = cc.MenuItemLabel:create(label)
    item:registerScriptTapHandler(goBackHandler)    
    local backMenu = cc.Menu:create(item)
    backMenu:setPosition(cc.p(30,size.height-20))
    layer:addChild(backMenu)
	
	return true
end

return ASSelectCraftScene

