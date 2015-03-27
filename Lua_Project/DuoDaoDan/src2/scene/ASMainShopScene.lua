--
-- ASMainShopScene 商店主场景
--

-- 获取购买金币场景对象
local ASCoinShopScene = require("scene.ASCoinShopScene")

local ASMainShopScene = class("ASMainShopScene", function()
	return cc.Scene:create()
end)

local director = cc.Director:getInstance()
local size = director:getVisibleSize()
local origin = director:getVisibleOrigin()

ASMainShopScene.__index = ASMainShopScene

----------------------------------------------------
-- create - 创建对象
-- @param：void
-- @return：返回创建的对象
----------------------------------------------------
function ASMainShopScene.create()
	local scene = ASMainShopScene.new()
    if nil ~= scene then
        if scene:init() ~= true then
	    	return nil
	    end	
	end
	
    return scene
end

-----------------------------------------------------
-- init - 初始化（auto-invoked）
-- @param：void
-- @return：bool类型，表示创建是否成功
-----------------------------------------------------
function ASMainShopScene:init()
    -- 初始化背景颜色层
    local layer = cc.LayerColor:create(cc.c4b(0,255,255,255), size.width, size.height)
    self:addChild(layer)

    -- 显示当前场景名称
    local labelTest = cc.Label:createWithTTF("MainShopScene","fonts/Marker Felt.ttf",50)
    labelTest:setColor(cc.c3b(0,0,0))
    labelTest:setPosition(cc.p(size.width/2, size.height/2))
    layer:addChild(labelTest)

    -- 点击购买金币事件回调
    function buyGoldHandler()
        print("进入购买金币场景")
        local coinScene = ASCoinShopScene.create()
        director:replaceScene(coinScene)       
    end
    -- 创建购买金币菜单项
    local buyGoldCoinButton = cc.MenuItemFont:create("购买金币")
    buyGoldCoinButton:registerScriptTapHandler(buyGoldHandler)
    local buyMenu = cc.Menu:create(buyGoldCoinButton) 
    buyMenu:setPosition(cc.p(size.width/2, size.height-50))
    buyMenu:setColor(cc.c3b(0,0,0))
    layer:addChild(buyMenu)

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

return ASMainShopScene

