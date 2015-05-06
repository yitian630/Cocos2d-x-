
local ASAlertLayer = class("ASAlertLayer",function()
    return cc.Layer:create()
end)

ASAlertLayer.__index = ASAlertLayer
ASAlertLayer.messageLabel = nil -- 显示消息的Label
ASAlertLayer.ok_callback = nil  -- 点击消息框"确定"按钮，进入购买方法
ASAlertLayer.cancel_callback = nil -- 点击"取消"按钮回调

function ASAlertLayer.create(text)
    local obj = ASAlertLayer.new(text)
    if nil ~= obj then
        if obj:init(text) ~= true then
    		return nil
    	end
    end
    return obj
end

--初始化
function ASAlertLayer:init(text)
    self.text = text     -- 消息框内容

    self.winSize = cc.Director:getInstance():getWinSize()
    self:setVisible(true)
    self:setLocalZOrder(999)
    self:setContentSize(self.winSize)

    local background = cc.Sprite:create("alert_frame.png")
    self.bg = background  
    background:setPosition(cc.p(self.winSize.width/2,self.winSize.height/2))
    self:addChild(background)

    -- 确定按钮回调函数
    local function ok_handler()
        -- 此处可能会 调用购买精力值相关的方法
        self.ok_callback() -- 调用确定函数
        self:removeFromParent(true)
    end
    -- 取消按钮回调函数
    local function cancel_handler()
        self.cancel_callback() -- 调用取消函数
        self:removeFromParent(true)
    end
    -- 添加确定按钮
    local okButtonItem = cc.MenuItemImage:create("alert_yes.png","alert_yes_press.png")
    okButtonItem:registerScriptTapHandler(ok_handler)
    -- 添加取消按钮
    local cancelButtonItem = cc.MenuItemImage:create("alert_no_press.png","alert_no.png") 
    cancelButtonItem:registerScriptTapHandler(cancel_handler)  

    local  menu = cc.Menu:create(cancelButtonItem,okButtonItem)
    menu:alignItemsHorizontallyWithPadding(background:getBoundingBox().width/4)
    menu:setPosition(background:getBoundingBox().width/2,background:getBoundingBox().height/4)
    background:addChild(menu)

    self.messageLabel = cc.Label:createWithBMFont("ASAlert.fnt",self.text)
    self.messageLabel:setPosition(background:getBoundingBox().width/2,background:getBoundingBox().height/3*2)
    background:addChild(self.messageLabel)

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
    
    return true
end

-- 点击“确定”按钮，进入购买 回调函数
function ASAlertLayer:ok_callback_(f)
    self.ok_callback = f
end

-- 点击“取消”按钮，进入购买 回调函数
function ASAlertLayer:cancel_callback_(f)
    self.cancel_callback = f
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