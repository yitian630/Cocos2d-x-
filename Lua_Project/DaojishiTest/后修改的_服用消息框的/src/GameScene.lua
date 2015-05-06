
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
end

-- create farm
function GameScene:createLayerFarm()
    local mainLayer = cc.Layer:create()

    local ASCountdown = require("ASCountdown")
    local ASAlertLayer = require("ASAlertLayer")
    
    -- 显示UI，并设置位置, 在不需要显示计时器UI的地方可以设置隐藏
    local ui = ASCountdown.create(99,120,5)
    ui:setPosition(self.visibleSize.width-100,self.visibleSize.height-100)
    mainLayer:addChild(ui)
  
    -- 场景消息框
    -- 精力值不够 每次减少的值时 调用
    function notEnough()
    	print("++++++++++++++++++")
    	local messageBox = ASAlertLayer.create("精力不足是否购买")
        mainLayer:addChild(messageBox)
        -- 消息框 确定 按钮回调
        function okCallback()
--            messageBox:removeFromParent(true)
        end
        messageBox:ok_callback_(okCallback)

        -- 消息框 取消 按钮回调
        function cancelCallback()
--            messageBox:removeFromParent(true)
        end
        messageBox:cancel_callback_(cancelCallback)
    end  
    ui:notEnough_callback_(notEnough)
    
    -- 点击计时器时 调用
    function clickCallback()
    	-- 根据当前精力值显示Label信息
    	local curEnergy = ui:getCurEnergy()
    	local count = ui:getCount()
    	local maxEnergy = ui:getMaxEnergy()
        local messageBox = ASAlertLayer.create()
        mainLayer:addChild(messageBox)
        if curEnergy < count then
            messageBox.messageLabel:setString("精力值不足")
        else
            if curEnergy < maxEnergy then
            	messageBox.messageLabel:setString("精力不足是否购买")
            else
                messageBox.messageLabel:setString("精力已满")
            end
    	end
        -- 消息框 确定 按钮回调
        function okCallback()
        --            messageBox:removeFromParent(true)
        end
        messageBox:ok_callback_(okCallback)

        -- 消息框 取消 按钮回调
        function cancelCallback()
        --            messageBox:removeFromParent(true)
        end
        messageBox:cancel_callback_(cancelCallback)
    end   
    ui:click_callback_(clickCallback)

    -- 加精力值
    function add()
    	ui:addEnergy()
    end
    -- 消耗精力值
    function consumption()
    	ui:consumptionEnergy()
    end
 -- 添加两个测试按钮 ----ASCountdown.addEnergy() 和 ASCountdown.consumptionEnergy() 分别为增加或减少精力值时
    local addItem = cc.MenuItemFont:create("增加精力值")
    addItem:registerScriptTapHandler(add)
    local subItem = cc.MenuItemFont:create("减少精力值")
    subItem:registerScriptTapHandler(consumption)

    local menu = cc.Menu:create(addItem, subItem)
    menu:alignItemsHorizontallyWithPadding (50)
    menu:setPosition(self.visibleSize.width/2,self.visibleSize.height/5)
    mainLayer:addChild(menu) 
    
    return mainLayer
end

return GameScene
