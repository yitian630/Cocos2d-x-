local ASMainScene = class("ASMainScene",function ()
	return cc.Scene:create()
end)

local director = cc.Director:getInstance()
local origin = director:getVisibleOrigin()
local size = director:getVisibleSize()

ASMainScene.__index = ASMainScene

function ASMainScene.create()
	local scene = ASMainScene.new()
	if nil ~= scene then
		if scene:init() ~= true then
			return nil
		end
	end
	
	return scene
end

function ASMainScene:init()

    local layer = cc.Layer:create()
    self:addChild(layer)
	-- 创建背景
	local bg = cc.Sprite:create("bg_game.jpg")
	bg:setPosition(size.width/2,size.height/2)
	layer:addChild(bg)
    
    -- logo
    local logo = cc.Sprite:create("logo1.png")
    logo:setPosition(size.width/2,size.height/4*3)
    logo:setScale(1.5)
    layer:addChild(logo);

    -- 开始游戏回调
    local function startGameHandler()
        print("开始游戏")
        local gameScene = require("ASGameScene").create()
        director:replaceScene(gameScene)
    end
    -- 开始游戏按钮
    local labelStart = cc.Label:createWithSystemFont("开始游戏","",50)
    local menuItem = cc.MenuItemLabel:create(labelStart)
    menuItem:registerScriptTapHandler(startGameHandler)
    local menu = cc.Menu:create(menuItem)
    layer:addChild(menu)
    
    -- 提示
    local helpLabel = cc.Label:createWithSystemFont("在规定时间内快速点击\n\"金\"字即可进入下一关","",24)
    helpLabel:setColor(cc.c4b(255, 15, 15, 255))
	helpLabel:setPosition(size.width/2,size.height/8)
    layer:addChild(helpLabel)

    -- 添加键盘监听
    local luaj = require("cocos.cocos2d.luaj")
    -- 添加键盘监听
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

return ASMainScene