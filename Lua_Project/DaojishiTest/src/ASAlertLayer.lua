
-- 消息框类型，默认都带"确定"和"取消"按钮，可扩展
ENUM_TYPE = {
    TEXT_AND_TIME = 1,  -- 显示倒计时和精力值
    TEXT_ONLY           -- 只显示文字
}


local ASCountdown = require("ASCountdown")

local ASAlertLayer = class("ASAlertLayer",function()
    return cc.Layer:create()
end)

ASAlertLayer.__index = ASAlertLayer
ASAlertLayer.scheduleID = nil
ASAlertLayer.buyFunc = nil  -- 点击消息框“确定”按钮，进入购买方法

function ASAlertLayer.create(dtype)
    local layer = ASAlertLayer.new(dtype)
    return layer
end

--初始化
function ASAlertLayer:ctor(dtype)
    self.type = dtype        -- 消息框类型
    self.hour = 0            -- 小时
    self.minute = 0        -- 分钟
    self.second = 0        -- 秒
    self.winSize = cc.Director:getInstance():getWinSize()
    self:setVisible(true)
    self:setLocalZOrder(999)
    self:setContentSize(self.winSize)
    self.curEnergy = ASCountdown.getEnergyValue()       -- 获取当前精力值
    self.maxEnergy = ASCountdown.getMaxEnergy()    -- 获取最大精力值
    self.EnergyLabel = nil -- 精力值Label
    self.timeLabel = nil   -- 显示时间的Label
    self.count = ASCountdown.getCount()       -- 获取每次减少的精力值
    self.SECOND = ASCountdown.getSecond()     -- 获取每增加一个精力值所需秒数
    self.time = ASCountdown.getTotalTime()    -- 涨满精力值所需总时间
    local listener = cc.EventListenerTouchOneByOne:create()
    local function onTouchBegan(touch, event)
        return self:onTouchBegan(touch,event)
    end
    local function onTouchMoved(touch,event)
        self:onTouchMoved(touch,event)
    end
    local function onTouchEnded(touch,event)
        self:onTouchEnded(touch,event)
    end
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
    listener:setSwallowTouches(true)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    self:createMsgBox()
end

-- 点击“确定”按钮，进入购买 回调函数
function ASAlertLayer.buyFunc_(f)
    ASAlertLayer.buyFunc = f
end
	
function ASAlertLayer:createMsgBox()
    local background = cc.Sprite:create("AlertPic/alert_frame3.png")
    self.bg = background  
    background:setPosition(cc.p(self.winSize.width/2,self.winSize.height/2))
    self:addChild(background)
    
    -- 确定按钮回调函数
    function ok_callback()
        -- 此处可能会 调用购买精力值相关的方法
        ASAlertLayer.buyFunc() -- 调用购买函数
    	self:removeFromParent(true)
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(ASAlertLayer.scheduleID)
    end
    -- 取消按钮回调函数
    function cancel_callback()
        self:removeFromParent(true)
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(ASAlertLayer.scheduleID)
    end
    -- 添加确定按钮
    local okButtonItem = cc.MenuItemImage:create("AlertPic/alert_yes.png","AlertPic/alert_yes_press.png")
    okButtonItem:registerScriptTapHandler(ok_callback)
    -- 添加关闭按钮
    local cancelButtonItem = cc.MenuItemImage:create("AlertPic/alert_no_press.png","AlertPic/alert_no.png") 
    cancelButtonItem:registerScriptTapHandler(cancel_callback)  
    
    local  menu = cc.Menu:create(cancelButtonItem,okButtonItem)
    menu:alignItemsHorizontallyWithPadding(background:getBoundingBox().width/4)
    menu:setPosition(background:getBoundingBox().width/2,background:getBoundingBox().height/4)
    background:addChild(menu)
    
    -- 根据消息框类型显示
    -- 带倒计时
    if self.type == ENUM_TYPE.TEXT_AND_TIME then
    -- 添加显示当前精力值label
        local energySprite = cc.Sprite:create("win_energy_t.png")
        energySprite:setPosition(background:getBoundingBox().width/4+energySprite:getBoundingBox().width,background:getBoundingBox().height-energySprite:getBoundingBox().height)
        background:addChild(energySprite)
        self.EnergyLabel = cc.Label:createWithBMFont("fonts/ASziti.fnt",self.curEnergy.."/"..self.maxEnergy)
        self.EnergyLabel:setPosition(energySprite:getPositionX()+energySprite:getBoundingBox().width/2+self.EnergyLabel:getBoundingBox().width/2,energySprite:getPositionY())
        background:addChild(self.EnergyLabel)

        -- 添加显示 涨满精力值所需总时间的Label
        self.timeLabel = cc.Label:createWithBMFont("fonts/ASziti.fnt",nil)
        self.hour = math.floor(self.time/3600)
        self.minute = math.floor(self.time%3600/60)
        self.second = self.time%3600%60
        self.hour = tostring(self.hour)
        if string.len(self.hour) == 1 then
            self.hour = "0"..self.hour
        end
        self.minute = tostring(self.minute)
        if string.len(self.minute) == 1 then
            self.minute = "0"..self.minute
        end
        self.second = tostring(self.second)
        if string.len(self.second) == 1 then
            self.second = "0"..self.second
        end
        if self.time == 0 then
            self.timeLabel:setString("精力值已满")
        else
            if self.hour == "00" then          
                self.timeLabel:setString(self.minute..":"..self.second.."后恢复至99点精力") 
            else
                if self.curEnergy < self.count then
                    local subTime = self.time - (self.maxEnergy - self.count)*self.SECOND
                    self.minute = math.floor(subTime/60)
                    self.minute = tostring(self.minute)
                    if string.len(self.minute) == 1 then
                        self.minute = "0"..self.minute
                    end
                    self.timeLabel:setString(self.minute..":"..self.second.."后恢复至"..self.count.."点精力") 
                else
                    self.timeLabel:setString(self.hour..":"..self.minute..":"..self.second.."后恢复至99点精力")
                end
            end
        end
        self.timeLabel:setPosition(background:getBoundingBox().width/2,self.EnergyLabel:getPositionY()-self.EnergyLabel:getBoundingBox().height/2-self.timeLabel:getBoundingBox().height/2)
        background:addChild(self.timeLabel)
    elseif self.type == ENUM_TYPE.TEXT_ONLY then
        -- 只显示文字
        self.EnergyLabel = cc.Label:createWithBMFont("fonts/ASziti.fnt",nil)    
        background:addChild(self.EnergyLabel)

        if self.curEnergy < self.maxEnergy then
            self.EnergyLabel:setString("精力不足是否购买")
        else
            self.EnergyLabel:setString("精力已满")
        end
        self.EnergyLabel:setPosition(background:getBoundingBox().width/2,background:getBoundingBox().height-background:getBoundingBox().height/3)

    end
           
    -- schedule回调函数
    function scheduleCallback()
        if self.type == ENUM_TYPE.TEXT_AND_TIME then
            self.curEnergy = ASCountdown.getEnergyValue()
            self.EnergyLabel:setString(self.curEnergy.."/"..self.maxEnergy)

            self.time = ASCountdown.getTotalTime()
            self.hour = math.floor(self.time/3600)
            self.minute = math.floor(self.time%3600/60)
            self.second = self.time%3600%60

            self.hour = tostring(self.hour)
            if string.len(self.hour) == 1 then
                self.hour = "0"..self.hour
            end
            self.minute = tostring(self.minute)
            if string.len(self.minute) == 1 then
                self.minute = "0"..self.minute
            end
            self.second = tostring(self.second)
            if string.len(self.second) == 1 then
                self.second = "0"..self.second
            end

            if self.time == 0 then
                self.timeLabel:setString("精力值已满")
            else
                if self.hour == "00" then
                    self.timeLabel:setString(self.minute..":"..self.second.."后恢复至99点精力")  
                else
                    if self.curEnergy < self.count then
                        local subTime = self.time - (self.maxEnergy - self.count)*self.SECOND
                        self.minute = math.floor(subTime/60)
                        self.minute = tostring(self.minute)
                        if string.len(self.minute) == 1 then
                            self.minute = "0"..self.minute
                        end
                        self.timeLabel:setString(self.minute..":"..self.second.."后恢复至"..self.count.."点精力") 
                    else
                        self.timeLabel:setString(self.hour..":"..self.minute..":"..self.second.."后恢复至99点精力")
                    end
                end
            end
        elseif self.type == ENUM_TYPE.TEXT_ONLY then
            if self.curEnergy < self.maxEnergy then
                self.EnergyLabel:setString("精力不足是否购买")
            else
                self.EnergyLabel:setString("精力已满")
            end

        end
    end
    ASAlertLayer.scheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(scheduleCallback,0,false)
end

function ASAlertLayer:onTouchBegan(touch, event)
    return true
end

function ASAlertLayer:onTouchEnded(touch, event)
    local curLocation = self:convertToNodeSpace(touch:getLocation())
    local rect = self.bg:getBoundingBox()
    if cc.rectContainsPoint(rect, curLocation) then
        print("point in rect")
    end

end

function ASAlertLayer:onTouchMoved(touch, event)

end

return ASAlertLayer