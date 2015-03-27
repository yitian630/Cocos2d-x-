
local ASAlertLayer = require("ASAlertLayer")

local GameScene = class("GameScene",function()
    return cc.Scene:create()
end)

GameScene.__index = GameScene

function GameScene.create()
    local scene = GameScene.new()
    scene:addChild(scene:createLayerFarm())
    return scene
end

GameScene.messageType = nil  -- 消息框类型

function GameScene:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil   
    
    GameScene.messageType = ENUM_TYPE.TEXT_AND_TIME 
end

-- create farm
function GameScene:createLayerFarm()
    local mainLayer = cc.Layer:create()
    
    -- 得到当前精力值,没有保存就用 默认值 99
    local curEnergyValue = cc.UserDefault:getInstance():getIntegerForKey("energyValue",99)
    
    local ASCountdown = require("ASCountdown")
    ASCountdown.setValue(99,120,5)              -- 设置最大精力值、每增加一个精力值所需的秒数、每次减少的精力值个数
    ASCountdown.setEnergyValue(curEnergyValue)  -- 设置当前精力值
    ASCountdown.scheduleFunc()                  -- 开启倒计时schedule方法
    
    -- 显示UI，并设置位置, 在不需要显示计时器UI的地方可以设置隐藏
    local ui = ASCountdown.showUI(self.visibleSize.width-100,self.visibleSize.height-100)
--    ui:setVisible(false)  -- 设置隐藏UI
    mainLayer:addChild(ui)
      
    function changeMessageType()
        if GameScene.messageType == ENUM_TYPE.TEXT_AND_TIME then
    		GameScene.messageType = ENUM_TYPE.TEXT_ONLY
    	else
    	    GameScene.messageType = ENUM_TYPE.TEXT_AND_TIME
    	end
    end  
    -- 添加两个测试按钮 ----ASCountdown.addEnergy() 和 ASCountdown.consumptionEnergy() 分别为增加或减少精力值时
    local addItem = cc.MenuItemFont:create("增加精力值")
    addItem:registerScriptTapHandler(ASCountdown.addEnergy)
    local subItem = cc.MenuItemFont:create("减少精力值")
    subItem:registerScriptTapHandler(ASCountdown.consumptionEnergy)
    local changeItem = cc.MenuItemFont:create("切换消息框")
    changeItem:registerScriptTapHandler(changeMessageType)

    -- 点击计时器回调
    local function clickCountdown()
    	print("-----------点击了计时器 进入回调函数-------------")
        -- create方法创建消息框，参数为 ENUM_TYPE.TEXT_ONLY（只显示文字） 和 ENUM_TYPE.TEXT_AND_TIME（带倒计时）
        local mesBox = ASAlertLayer.create(GameScene.messageType)
    	mainLayer:addChild(mesBox)
    end
    ASCountdown.clickFunc_(clickCountdown)
    
    -- 购买回调
    local function buyCallback()
    	print("--------调用购买 函数---------")
    end
    ASAlertLayer.buyFunc_(buyCallback)

    local menu = cc.Menu:create(addItem, subItem, changeItem)
    menu:alignItemsHorizontallyWithPadding (50)
    menu:setPosition(self.visibleSize.width/2,self.visibleSize.height/5)
    mainLayer:addChild(menu) 
    
    return mainLayer
end

return GameScene
