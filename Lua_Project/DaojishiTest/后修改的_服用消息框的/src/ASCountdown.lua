--写一个倒计时类

local ASCountdown = class("ASCountdown",function()
	return cc.Node:create()
end)

ASCountdown.__index = ASCountdown

ASCountdown.clickFunc = nil  -- 点击计时器时调用此方法
ASCountdown.notEnoughFunc = nil -- 精力值不足时调用此方法

ASCountdown.maxEnergyValue = nil  -- 总精力值
ASCountdown.SECOND = nil    -- 设置每增加一个精力值所需时间：秒
ASCountdown.COUNT = nil     -- 每次减少的精力值

ASCountdown.curEnergyValue = nil  -- 当前精力值
ASCountdown.energyLabel = nil     -- 精力值标签
ASCountdown.MINUTE = nil          -- 设置时间：分
ASCountdown.timeLabel = nil       -- 计时器标签

ASCountdown.stime = nil   -- 获取系统时间
ASCountdown.ptime = nil   -- 预测涨满精力值所需时间 点
ASCountdown.totalTime = 0    -- 涨满精力值所需的时间，单位：秒

ASCountdown.pt = nil      -- 圆形进度条

--create方法
function ASCountdown.create(maxEnergy, second, count)
    local obj = ASCountdown.new()
	if nil ~= obj then
        if obj:init(maxEnergy, second, count) ~= true then
        	return nil
        end
	end
	return obj
end

-- init方法
function ASCountdown:init(maxEnergy, second, count)
    self.maxEnergyValue = maxEnergy
    self.SECOND = second
    self.COUNT = count
    self.curEnergyValue = cc.UserDefault:getInstance():getIntegerForKey("energyValue",99)
    print("self.curEnergyValue ++++= "..self.curEnergyValue)
    -- 添加进度条背景图
    local bgSprite = cc.Sprite:create("win_energy.png")
    self:addChild(bgSprite)

    local cd = cc.Sprite:create("win_energy_cd.png")
    cd:setColor(cc.c3b(24,50,5))
    cd:setPosition(bgSprite:getPositionX(),bgSprite:getPositionY())
    self:addChild(cd)

    -- 创建进度条前景图
    local fSprite = cc.Sprite:create("win_energy_press.png")    
    -- 创建progressTimer对象，将图片载入进去
    self.pt = cc.ProgressTimer:create(fSprite)
    self.pt:setPosition(bgSprite:getPositionX(),bgSprite:getPositionY())
    self:addChild(self.pt,0,100)

    -- 设置初始的百分比，根据当前精力值求出
    local factor = self.curEnergyValue/self.maxEnergyValue
    self.pt:setPercentage(factor*100)
    -- 选择类型，是条型还是时针型
    self.pt:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    self.pt:setReverseDirection(false)

    -- 创建精力值label -----------------------------------------
    self.energyLabel = cc.Label:createWithBMFont("ASAlert.fnt",self.curEnergyValue.."/"..self.maxEnergyValue)
    self.energyLabel:setPosition(self.pt:getPositionX(),self.pt:getPositionY())
    self:addChild(self.energyLabel)

    -- 测试倒计时Label ----------------------------------------
    self.timeLabel = cc.Label:createWithBMFont("ASAlert.fnt",nil)
    self.timeLabel:setPosition(self.pt:getPositionX(),self.pt:getPositionY()-self.pt:getContentSize().height/2)
    self:addChild(self.timeLabel,3)  

    -- 创建点击事件
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
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)-- 添加进度条背景图
    
    -- 更新计时器函数,进度条每增加一个精力值 刷新一圈
    function updateProgressUI()
        -- 按当前精力值的比例显示进度条
        local factor = self.curEnergyValue/self.maxEnergyValue
        self.pt:setPercentage(factor*100)

        if self.energyLabel ~= nil then
            -- 刷新显示 精力值
            self.energyLabel:setString(self.curEnergyValue.."/"..self.maxEnergyValue)
        end
        cc.UserDefault:getInstance():setIntegerForKey("energyValue",self.curEnergyValue)
        if self.curEnergyValue < self.maxEnergyValue then
            self.stime = os.time()
            self.ptime = cc.UserDefault:getInstance():getIntegerForKey("ptime")
            -- 判断系统时间与预测的时间
            if self.stime >= self.ptime then  
                -- 系统时间超过了预测时间，精力值涨满 --------------------------

                self.pt:setPercentage(100)
                self.curEnergyValue = self.maxEnergyValue
                if self.timeLabel ~= nil then
                    self.timeLabel:setVisible(false)
                end  
                self.totalTime = self.ptime - self.stime       
            else   
                -- 系统时间没有超过预测时间 ------------------------- 
                if self.timeLabel ~= nil then
                    self.timeLabel:setVisible(true)
                end 

                -- 计算时间差，即 涨满精力值所需时间（倒计时），单位：秒
                self.totalTime = self.ptime - self.stime

                -- 刷新显示当前精力值，根据时间差 来求出需要减少的精力值-----------------------------------
                -- subCount 根据预测时间 求出涨满所需的精力值
                local subCount = math.ceil(self.totalTime/self.SECOND)
                self.curEnergyValue = self.maxEnergyValue - subCount

                --            self.MINUTE = math.floor(self.totalTime/60)      -- 涨满精力值总共需要的时间: 分

                -- 分段显示计时器，每增加一个精力值为一个显示周期            
                -- 每增加一个精力值需要的时间为: self.SECOND
                self.MINUTE = math.floor((self.totalTime-(subCount-1)*self.SECOND)/60)

                if self.MINUTE == 0 then
                    second = math.floor(self.totalTime-(subCount-1)*self.SECOND)
                else
                    second = math.floor(self.totalTime%60)
                end


                -- 转化成字符串
                self.MINUTE = tostring(self.MINUTE)
                second = tostring(second)
                if string.len(self.MINUTE) == 1 then
                    self.MINUTE = "0" .. self.MINUTE
                end
                if string.len(second) == 1 then
                    second = "0" .. second
                end
                if self.timeLabel ~= nil then
                    -- 刷新显示 计时器
                    self.timeLabel:setString(self.MINUTE .. ":" .. second .. " 后+1")
                end
                -- 每增加一个精力值所需要的 秒数为：self.SECOND
                -- 得到 精度条比例系数
                --            local factor = (self.SECOND-(self.MINUTE*60+second))/self.SECOND
                --            if self.pt ~= nil then
                --                self.pt:setPercentage(factor*100)
                --            end        

            end
        end
    end

    --开启schedule  
    self:scheduleUpdateWithPriorityLua(updateProgressUI, 0)      
	return true
end

-- 获取当前精力值
function ASCountdown:getCurEnergy()
	return self.curEnergyValue
end
-- 获取最大精力值
function ASCountdown:getMaxEnergy()
    return self.maxEnergyValue
end
-- 获取每次减少的精力值
function ASCountdown:getCount()
	return self.COUNT
end
-- 获取每增加一个精力值所需的时间：秒
function ASCountdown:getSecond()
	return self.SECOND
end
-- 获取涨满精力值所需总时间，单位：秒
function ASCountdown:getTotalTime()
	return self.totalTime
end

-- 点击计时器调用
function ASCountdown:click_callback_(f)
	self.clickFunc = f
end

-- 点击事件
function ASCountdown:onTouchBegan(touch, event)
    return true
end

function ASCountdown:onTouchEnded(touch, event)
    local s = self.pt:convertToNodeSpace(touch:getLocation())

    local rect = cc.rect(0,0,self.pt:getContentSize().width,self.pt:getContentSize().height)
    if cc.rectContainsPoint(rect, s) then
        -- 点中计时器
        self:clickFunc() -- 点中时调用
    end
end

function ASCountdown:onTouchMoved(touch, event)

end

-- 精力值不够时调用
function ASCountdown:notEnough_callback_(f)
    self.notEnoughFunc = f
end

-- 减少精力值函数 -------------------
function ASCountdown:consumptionEnergy()
    if self.curEnergyValue > 0 then

        if self.curEnergyValue < self.COUNT then
            self.curEnergyValue = self.curEnergyValue
            print("精力值不足，请休息一会儿")
            -- 精力值不够时 回调
            self:notEnoughFunc()
        else
            self.curEnergyValue = self.curEnergyValue-self.COUNT
        end
        -- 精力值减少，记录当前系统时间
        self.stime = os.time()
        self.ptime = self.stime + (self.maxEnergyValue-self.curEnergyValue)*self.SECOND  -- 预测涨满精力值所需时间
        cc.UserDefault:getInstance():setIntegerForKey("ptime",self.ptime)
        -- 刷新时间
        self.totalTime = self.ptime - self.stime

    else
        print("精力值已用尽")
        -- 精力值用尽 状态提示
        self:notEnoughFunc()
    end
end

-- 增加精力值函数 -----------
function ASCountdown:addEnergy()
    if self.curEnergyValue < self.maxEnergyValue then
        self.curEnergyValue = self.curEnergyValue+self.COUNT
        if self.curEnergyValue >= self.maxEnergyValue then
            self.curEnergyValue = self.maxEnergyValue
            print("精力值     已加满")

            -- 购满精力值 后的操作 
            if self.timeLabel ~= nil then
                self.timeLabel:setVisible(false)
            end
            if self.pt ~= nil then
                self.pt:setPercentage(100)
            end                      
        end
        -- 精力值减少，记录当前系统时间
        self.stime = os.time()
        self.ptime = self.stime + (self.maxEnergyValue-self.curEnergyValue)*self.SECOND  -- 预测涨满精力值所需时间
        cc.UserDefault:getInstance():setIntegerForKey("ptime",self.ptime)
         
        self.totalTime = self.ptime - self.stime
    else
        print("精力值已加满")
        -- 精力值加满后 状态提示
    end	
end

return ASCountdown