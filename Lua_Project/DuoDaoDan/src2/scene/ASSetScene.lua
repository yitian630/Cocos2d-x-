-- 
-- ASSetScene 设置场景
--

local ASSetScene = class("ASSetScene", function()
	return cc.Scene:create()
end)

local director = cc.Director:getInstance()
local size = director:getVisibleSize()
local origin = director:getVisibleOrigin()

ASSetScene.__index = ASSetScene

-------------------------------------------------
-- create - 创建对象
-- @param：void
-- @return：返回创建的对象
-------------------------------------------------
function ASSetScene.create()
	local scene = ASSetScene.new()
    if nil ~= scene then
        if scene:init() ~= true then
			return nil
		end
	end
	
    return scene
end

--------------------------------------------------
-- init - 初始化（auto-invoked）
-- @param：void
-- @return：bool类型，表示创建是否成功
--------------------------------------------------
function ASSetScene:init()
    -- 初始化背景颜色层
    local layer = cc.LayerColor:create(cc.c4b(125,125,125,255), size.width, size.height)
    self:addChild(layer)

    local labelTest = cc.Label:createWithTTF("SetScene","fonts/Marker Felt.ttf",50)
    labelTest:setColor(cc.c3b(0,0,0))
    labelTest:setPosition(cc.p(size.width/2, size.height/2))
    layer:addChild(labelTest)

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

return ASSetScene
