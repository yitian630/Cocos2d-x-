--写一个倒计时类

local ASCountdown = class("ASCountdown")

ASCountdown.__index = ASCountdown

ASCountdown.func = nil       -- 倒计时为0时执行
ASCountdown.clickFunc = nil  -- 点击计时器时调用此方法
ASCountdown.showtype = true

ASCountdown.maxEnergyValue = nil  -- 总精力值
ASCountdown.SECOND = nil    -- 设置每增加一个精力值所需时间：秒
ASCountdown.COUNT = nil     -- 每次减少的精力值

ASCountdown.schedulerID = nil

ASCountdown.curEnergyValue = nil  -- 当前精力值
ASCountdown.energyLabel = nil     -- 精力值标签
ASCountdown.MINUTE = nil          -- 设置时间：分
ASCountdown.timeLabel = nil       -- 计时器标签

ASCountdown.stime = nil   -- 获取系统时间
ASCountdown.ptime = nil   -- 预测涨满精力值所需时间 点
ASCountdown.totalTime = 0    -- 涨满精力值所需的时间，单位：秒

ASCountdown.pt = nil      -- 圆形进度条

ASCountdown.actionSprite = nil   -- 播放动画的精灵

--设置倒计时到00:00时调用这个函数，传入的参数是一个函数
function ASCountdown.function_(f)  
    ASCountdown.func = f
end

-- 点击计时器时调用
function ASCountdown.clickFunc_(f)
	ASCountdown.clickFunc = f
end

function ASCountdown.setValue(maxEnergyValue,second,count)
    ASCountdown.maxEnergyValue = maxEnergyValue -- 设置最大精力值
    ASCountdown.SECOND = second                 -- 设置每增加一个精力值所需的秒数
    ASCountdown.COUNT = count                   -- 设置每次减少的精力值个数
end

-- 设置当前的精力值
function ASCountdown.setEnergyValue(curEnergyValue)
	ASCountdown.curEnergyValue = curEnergyValue
end
-- 获取当前精力值
function ASCountdown.getEnergyValue()
	return ASCountdown.curEnergyValue
end
-- 获取最大精力值
function ASCountdown.getMaxEnergy()
    return ASCountdown.maxEnergyValue
end
-- 获取每次减少的精力值
function ASCountdown.getCount()
	return ASCountdown.COUNT
end
-- 获取每增加一个精力值所需的时间：秒
function ASCountdown.getSecond()
	return ASCountdown.SECOND
end
-- 获取涨满精力值所需总时间，单位：秒
function ASCountdown.getTotalTime()
	return ASCountdown.totalTime
end

--创建计时器UI，传入x，y坐标
function ASCountdown.showUI(x,y)
    local node = cc.Node:create()

    -- 添加进度条背景图
    local bgSprite = cc.Sprite:create("win_energy.png")
    bgSprite:setPosition(x,y)
    node:addChild(bgSprite)

    local cd = cc.Sprite:create("win_energy_cd.png")
    cd:setColor(cc.c3b(24,50,5))
    cd:setPosition(bgSprite:getPositionX(),bgSprite:getPositionY())
    node:addChild(cd)
    
    -- 创建动画精灵，先设置为隐藏
    ASCountdown.actionSprite = cc.Sprite:create("win_energy_t.png")
    ASCountdown.actionSprite:setPosition(bgSprite:getPositionX(),bgSprite:getPositionY()+ASCountdown.actionSprite:getBoundingBox().height/4+5)
    node:addChild(ASCountdown.actionSprite)
    
    -- 创建进度条前景图
    local fSprite = cc.Sprite:create("win_energy_press.png")    
    -- 创建progressTimer对象，将图片载入进去
    ASCountdown.pt = cc.ProgressTimer:create(fSprite)
    ASCountdown.pt:setPosition(bgSprite:getPositionX(),bgSprite:getPositionY())
    node:addChild(ASCountdown.pt)
    
    -- 设置初始的百分比，根据当前精力值求出
    local factor = ASCountdown.curEnergyValue/ASCountdown.maxEnergyValue
    ASCountdown.pt:setPercentage(factor*100)
    -- 选择类型，是条型还是时针型
    ASCountdown.pt:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    ASCountdown.pt:setReverseDirection(false)

    -- 创建精力值label -----------------------------------------
    ASCountdown.energyLabel = cc.Label:createWithBMFont("fonts/ASziti.fnt",ASCountdown.curEnergyValue.."/"..ASCountdown.maxEnergyValue)
    ASCountdown.energyLabel:setPosition(ASCountdown.pt:getPositionX(),ASCountdown.pt:getPositionY())
    node:addChild(ASCountdown.energyLabel)

    -- 测试倒计时Label ----------------------------------------
    ASCountdown.timeLabel = cc.Label:createWithBMFont("fonts/ASziti.fnt",nil)
    ASCountdown.timeLabel:setPosition(ASCountdown.pt:getPositionX(),ASCountdown.pt:getPositionY()-ASCountdown.pt:getContentSize().height/2)
    node:addChild(ASCountdown.timeLabel,3)  

    -- 创建点击事件
    local listener = cc.EventListenerTouchOneByOne:create()
    local function onTouchBegan(touch, event)
        return ASCountdown:onTouchBegan(touch,event)
    end
    local function onTouchMoved(touch,event)
        ASCountdown:onTouchMoved(touch,event)
    end
    local function onTouchEnded(touch,event)
        ASCountdown:onTouchEnded(touch,event)
    end
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
    listener:setSwallowTouches(true)
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)

    return node
end

-- 点击事件
function ASCountdown:onTouchBegan(touch, event)
    return true
end

function ASCountdown:onTouchEnded(touch, event)
    local s = ASCountdown.pt:convertToNodeSpace(touch:getLocation())

    local rect = cc.rect(0,0,ASCountdown.pt:getContentSize().width,ASCountdown.pt:getContentSize().height)
    if cc.rectContainsPoint(rect, s) then
        -- 点中计时器
        ASCountdown.clickFunc() -- 点中时调用
    end
end

function ASCountdown:onTouchMoved(touch, event)

end

-- 减少精力值函数 -------------------
function ASCountdown.consumptionEnergy()
    if ASCountdown.curEnergyValue > 0 then

        if ASCountdown.curEnergyValue < ASCountdown.COUNT then
            ASCountdown.curEnergyValue = ASCountdown.curEnergyValue
            print("精力值不足，请休息一会儿")
          
            -- 精力值刚 用尽的时候的操作
        else
            ASCountdown.curEnergyValue = ASCountdown.curEnergyValue-ASCountdown.COUNT
        end
        -- 精力值减少，记录当前系统时间
        ASCountdown.stime = os.time()
        ASCountdown.ptime = ASCountdown.stime + (ASCountdown.maxEnergyValue-ASCountdown.curEnergyValue)*ASCountdown.SECOND  -- 预测涨满精力值所需时间
        cc.UserDefault:getInstance():setIntegerForKey("ptime",ASCountdown.ptime)
        -- 刷新时间
        ASCountdown.totalTime = ASCountdown.ptime - ASCountdown.stime

    else
        print("精力值已用尽")
        -- 精力值用尽 状态提示
    end
end

-- 增加精力值函数 -----------
function ASCountdown.addEnergy()
    if ASCountdown.curEnergyValue < ASCountdown.maxEnergyValue then
        ASCountdown.curEnergyValue = ASCountdown.curEnergyValue+ASCountdown.COUNT
        if ASCountdown.curEnergyValue >= ASCountdown.maxEnergyValue then
            ASCountdown.curEnergyValue = ASCountdown.maxEnergyValue
            print("精力值     已加满")

            -- 购满精力值 后的操作 
            if ASCountdown.timeLabel ~= nil then
                ASCountdown.timeLabel:setVisible(false)
            end
            if ASCountdown.pt ~= nil then
                ASCountdown.pt:setPercentage(100)
            end 
                     
        end
        -- 精力值减少，记录当前系统时间
        ASCountdown.stime = os.time()
        ASCountdown.ptime = ASCountdown.stime + (ASCountdown.maxEnergyValue-ASCountdown.curEnergyValue)*ASCountdown.SECOND  -- 预测涨满精力值所需时间
        cc.UserDefault:getInstance():setIntegerForKey("ptime",ASCountdown.ptime)
         
        ASCountdown.totalTime = ASCountdown.ptime - ASCountdown.stime
    else
        print("精力值已加满")
        -- 精力值加满后 状态提示

    end
	
end
-- 更新计时器函数,进度条每增加一个精力值 刷新一圈
function ASCountdown.updateProgressUI()
    -- 按当前精力值的比例显示进度条
    local factor = ASCountdown.curEnergyValue/ASCountdown.maxEnergyValue
    ASCountdown.pt:setPercentage(factor*100)
    
    if ASCountdown.energyLabel ~= nil then
        -- 刷新显示 精力值
        ASCountdown.energyLabel:setString(ASCountdown.curEnergyValue.."/"..ASCountdown.maxEnergyValue)
    end
    cc.UserDefault:getInstance():setIntegerForKey("energyValue",ASCountdown.curEnergyValue)
    if ASCountdown.curEnergyValue < ASCountdown.maxEnergyValue then
        ASCountdown.stime = os.time()
        ASCountdown.ptime = cc.UserDefault:getInstance():getIntegerForKey("ptime")
        -- 判断系统时间与预测的时间
        if ASCountdown.stime >= ASCountdown.ptime then  
            -- 系统时间超过了预测时间，精力值涨满 --------------------------
          
            ASCountdown.pt:setPercentage(100)
            ASCountdown.curEnergyValue = ASCountdown.maxEnergyValue
            if ASCountdown.timeLabel ~= nil then
                ASCountdown.timeLabel:setVisible(false)
            end  
            ASCountdown.totalTime = ASCountdown.ptime - ASCountdown.stime       
        else   
            -- 系统时间没有超过预测时间 ------------------------- 
            if ASCountdown.timeLabel ~= nil then
                ASCountdown.timeLabel:setVisible(true)
            end 
     
            -- 计算时间差，即 涨满精力值所需时间（倒计时），单位：秒
            ASCountdown.totalTime = ASCountdown.ptime - ASCountdown.stime

            -- 刷新显示当前精力值，根据时间差 来求出需要减少的精力值-----------------------------------
            -- subCount 根据预测时间 求出涨满所需的精力值
            local subCount = math.ceil(ASCountdown.totalTime/ASCountdown.SECOND)
            ASCountdown.curEnergyValue = ASCountdown.maxEnergyValue - subCount
          
            --            ASCountdown.MINUTE = math.floor(ASCountdown.totalTime/60)      -- 涨满精力值总共需要的时间: 分

            -- 分段显示计时器，每增加一个精力值为一个显示周期            
            -- 每增加一个精力值需要的时间为: ASCountdown.SECOND
            ASCountdown.MINUTE = math.floor((ASCountdown.totalTime-(subCount-1)*ASCountdown.SECOND)/60)
            
            if ASCountdown.MINUTE == 0 then
                second = math.floor(ASCountdown.totalTime-(subCount-1)*ASCountdown.SECOND)
            else
                second = math.floor(ASCountdown.totalTime%60)
            end
            

            -- 转化成字符串
            ASCountdown.MINUTE = tostring(ASCountdown.MINUTE)
            second = tostring(second)
            if string.len(ASCountdown.MINUTE) == 1 then
                ASCountdown.MINUTE = "0" .. ASCountdown.MINUTE
            end
            if string.len(second) == 1 then
                second = "0" .. second
            end
            if ASCountdown.timeLabel ~= nil then
                -- 刷新显示 计时器
                ASCountdown.timeLabel:setString(ASCountdown.MINUTE .. ":" .. second .. " 后+1")
            end
            -- 每增加一个精力值所需要的 秒数为：ASCountdown.SECOND
            -- 得到 精度条比例系数
--            local factor = (ASCountdown.SECOND-(ASCountdown.MINUTE*60+second))/ASCountdown.SECOND
--            if ASCountdown.pt ~= nil then
--                ASCountdown.pt:setPercentage(factor*100)
--            end        

        end
    end
end

--倒计时刷新函数
function ASCountdown.scheduleFunc()
    --隔一秒刷新这个函数
    ASCountdown.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(ASCountdown.updateProgressUI,0,false)  
end

return ASCountdown