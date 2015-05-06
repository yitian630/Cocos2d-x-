--ASMainGameScene 游戏场景

local ASBeginnerGuideLayer = require("scene.ASBeginnerGuideLayer")
local ASMissile = require("entity.ASMissile")

require("data.Csv")

local ASMainGameScene = class("ASMainGameScene",function()
    return cc.Scene:create()
end)

local director = cc.Director:getInstance()
local size = director:getVisibleSize()
local origin = director:getVisibleOrigin()

ASMainGameScene.__index = ASMainGameScene
ASMainGameScene._moveMapSchedulerID = nil
ASMainGameScene._flyStateSchedulerID = nil
ASMainGameScene._guideScheduler = nil
-- 对应背景的tag
local kTag = {
    {1,2,3},
    {4,5,6},
    {7,8,9}
}
-- 9张背景图片
local BgSprite = {
    {"left_up", "top", "right_up"},
    {"left", "center", "right"},
    {"left_bottom", "bottom", "right_bottom"}
}
-- 飞机飞行状态

FlyState = {
    NORMAL="FlyNormal",
    LEFT="FlyLeft",
    RIGHT="FlyRight",
}

local speed = 5
local kTagSprite = 10
local _DirX, _DirY -- 初始方向
local _state = FlyState.NORMAL -- 默认飞机直线飞行
local rotA = 0 -- 旋转的角度值
local planeWorldPositionX = 0 -- 玩家飞机的世界坐标X轴
local planeWorldPositionY = 0 -- 玩家飞机的世界坐标Y轴
local distance = 0 -- 飞行距离
local distanceX = 0
local distanceY = 0

local touLabelText = 0
local curLabelText = 0
local m_CurLabelText = 0

local isGuide
local guideLayer = nil 

local rt_Normal = 0

local planeWorldXTextL --飞机世界坐标Label
local planeWorldYTextL --飞机世界坐标Label
local planeWorldXText = 0 --导弹世界坐标
local planeWorldYText = 0 --导弹世界坐标
-- 飞行距离Label
local distanceLabel = nil
-- 飞行距离 值
local distanceText = nil
-- 导弹测试
local M_curLabelText
local M_TarLabelText

local time = 0
local second = 0
--------------------------------------------------
-- create - 创建对象
-- @param：void
-- @return：返回创建的对象
--------------------------------------------------
function ASMainGameScene.create()
    local scene = ASMainGameScene.new()
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
function ASMainGameScene:init()
    -- 判断是否选择黄色飞机
    local isYellowSelect = cc.UserDefault:getInstance():getBoolForKey("isYellowSelect")
    -- 如果是重新开始，去掉引导页面
    if ASGlobalClient.isRestart == true then
        isGuide = false
        -- 判断
        local isBuy = cc.UserDefault:getInstance():getBoolForKey("isBuy")
        if isBuy == true then
            local buyDis = cc.UserDefault:getInstance():getIntegerForKey("integer")
            distance = buyDis
        else 
          	distance = 0
        end
        
        distanceX = 0
        distanceY = 0
        m_CurLabelText = 0
        planeWorldPositionX = 0
        planeWorldPositionY = 0
        -- if isYellowSelect == true then
        --     ASMusicPlayer:getInstance():playBgMusic("AS2BGMusic.mp3",true)
        -- else
        --     ASMusicPlayer:getInstance():playBgMusic("AS3BGMusic.mp3",true)
        -- end      
    else 
        local b = cc.UserDefault:getInstance():getBoolForKey("first_time")
        if b == true then
            isGuide = true
            -- 判断
        	local isBuy = cc.UserDefault:getInstance():getBoolForKey("isBuy")
        	if isBuy == true then
            	local buyDis = cc.UserDefault:getInstance():getIntegerForKey("integer")
            	distance = buyDis
        	else 
          		distance = 0
        	end
           
            distanceX = 0
            distanceY = 0
            planeWorldPositionX = 0
            planeWorldPositionY = 0
        else
            isGuide = false
            -- 判断
        	local isBuy = cc.UserDefault:getInstance():getBoolForKey("isBuy")
        	if isBuy == true then
            	local buyDis = cc.UserDefault:getInstance():getIntegerForKey("integer")
            	distance = buyDis
        	else 
          		distance = 0
        	end
            
            distanceX = 0
            distanceY = 0
            planeWorldPositionX = 0
            planeWorldPositionY = 0
        end   
        -- if isYellowSelect == true then
        --     ASMusicPlayer:getInstance():playBgMusic("AS2BGMusic.mp3",true)
        -- else
        --     ASMusicPlayer:getInstance():playBgMusic("AS3BGMusic.mp3",true)
        -- end
    end

    time = 0
    second = 1.0

    -- 产生随机算子
    math.randomseed(os.time())

    -- 添加地图层
    local mapLayer = self:createMapLayer()
    self:addChild(mapLayer)
    -- 添加游戏层
    local gameLayer = self:createGameLayer()
    self:addChild(gameLayer)

    ASGlobalClient.gameLayer = gameLayer

    -- 添加键盘监听
    local luaj = require("cocos.cocos2d.luaj")
    --do
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

    local eventDispatcher = gameLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, gameLayer)


    return true
end
-------------------------------------
-- 创建背景地图
-------------------------------------
function ASMainGameScene:createMapLayer()
    local mapLayer = cc.Layer:create()

    local center = cc.Sprite:createWithSpriteFrameName("ditu.jpg")
    mapLayer:addChild(center)
    local scaling = size.height*1.5/center:getContentSize().width 
    center:setScale(scaling)
    local _width = center:getBoundingBox().width

    local _x = size.width/2-_width
    local _y = size.height/2+_width   

    for i=1, 3 do
        for j=1, 3 do
            -- 创建9个背景精灵         
            BgSprite[i][j] = cc.Sprite:createWithSpriteFrame(center:getSpriteFrame())
            BgSprite[i][j]:setPosition(cc.p(_x + _width*(j-1), _y - _width*(i-1)))
            BgSprite[i][j]:setScale(scaling)
            mapLayer:addChild(BgSprite[i][j],0,kTag[i][j])
        end
    end

    -- 随机任意角度 rt_Normal，初始角度取值（1至360度之间）
    rt_Normal = math.random(1,360)
    if isGuide == true then
        rt_Normal = 0
    end
    -- 根据角度求X，Y方向分量, _DirX,_DirY取-1到1之间，代表方向
    _DirX = math.sin(math.rad(rt_Normal))
    _DirY = math.cos(math.rad(rt_Normal))
--    curLabelText = rt_Normal

    -- 移动背景
    function moveMap()
        -- 移动背景
        for row, var in ipairs(BgSprite) do
            for col in ipairs(var) do
                local bg = BgSprite[row][col]
                if bg ~= nil then
                    bg:setPositionX(bg:getPositionX()-speed*_DirX)
                    bg:setPositionY(bg:getPositionY()-speed*_DirY)
                end

                -- 判断背景向右移出屏幕
                if bg:getPositionX() >= size.width+_width/2 then
                    bg:setPositionX(bg:getPositionX()-_width*2+1)
                end
                -- 地图向左移出屏幕
                if bg:getPositionX() <= origin.x-_width/2 then
                    bg:setPositionX(bg:getPositionX()+_width*2-1)
                end
                -- 地图向上移出屏幕
                if bg:getPositionY() >= size.height+_width/2  then
                    bg:setPositionY(bg:getPositionY()-_width*2+1)
                end
                -- 地图向下移出屏幕
                if bg:getPositionY() <= origin.y-_width/2 then
                    bg:setPositionY(bg:getPositionY()+_width*2-1)
                end
            end
        end   

    end
    -- 移动背景
    mapLayer:scheduleUpdateWithPriorityLua(moveMap,0)

    return mapLayer
end
------------------------------------------
-- 创建游戏层
------------------------------------------ 
function ASMainGameScene:createGameLayer()
    local gameLayer = cc.Layer:create()
    -- 参考节点,此时飞机世界坐标相对于参考节点的坐标
    local node = cc.Sprite:create()   
    -- 添加到游戏层中
    gameLayer:addChild(node)

    -- 添加玩家飞机精灵
    local player = cc.Sprite:createWithSpriteFrameName("feiji_1.png")
    gameLayer:addChild(player, 1, kTagSprite)
    player:setScale(0.75)
    player:setPosition(cc.p(size.width/2, size.height/2))
    -- 初始飞机角度
    player:setRotation(rt_Normal)

    -- 添加粒子效果
    local emitter = cc.ParticleSystemQuad:create("fire.plist")
    gameLayer:addChild(emitter)
    emitter:setPosition(size.width/2,size.height/2)
    emitter:setAngle(-rt_Normal+270)

    distanceLabel = cc.Label:createWithBMFont("fonts/ziti.fnt","飞行距离:")
    distanceText = cc.Label:createWithBMFont("fonts/ziti.fnt",distance.."米")

    distanceLabel:setScale(1.5)
    gameLayer:addChild(distanceLabel)
    distanceLabel:setPosition(cc.p(size.width/2-distanceLabel:getBoundingBox().width/2,size.height-60))
    
    distanceText:setScale(1.5)
    gameLayer:addChild(distanceText)
    distanceText:setPosition(cc.p(distanceLabel:getPositionX()+distanceLabel:getBoundingBox().width/2+distanceText:getBoundingBox().width/2,distanceLabel:getPositionY()))

    if isGuide == true then
        guideLayer = ASBeginnerGuideLayer.create()
        self:addChild(guideLayer,100)
--        print("rt_Normal=========:"..rt_Normal)   
    end

    -- 默认目标角度等于当前角度(默认角度)
    local rt_Touch = rt_Normal
    -- 判断是否触发touchmoved
    local isMoved = false
    -- 判断是否选择黄色飞机
    local isYellowSelect = cc.UserDefault:getInstance():getBoolForKey("isYellowSelect")
    local x = 0
    -- 飞行状态侦听     
    function flyStateUpdate()       
        local animation = cc.Animation:create()              
        local sName, number

        if _state == FlyState.NORMAL then

            x = 0
            if isYellowSelect == false then
                player:setSpriteFrame("feiji_1.png")
            else
                player:setSpriteFrame("feiji_2.png")
            end   
        elseif _state == FlyState.LEFT then
            x = -1      
            if rotA < 5 then                
                if isYellowSelect == false then
                    player:setSpriteFrame("feiji_1.png")
                else
                    player:setSpriteFrame("feiji_2.png")
                end   
            end
            if rotA < 10 and rotA >= 5 then
                if isYellowSelect == false then
                    player:setSpriteFrame("feiji_1.png")
                else
                    player:setSpriteFrame("feiji_2.png")
                end  
            end
            if rotA < 15 and rotA >= 10 then
                if isYellowSelect == false then
                    player:setSpriteFrame("feiji_1.png")
                else
                    player:setSpriteFrame("feiji_2.png")
                end  
            end
            if rotA >= 15 then
                if isYellowSelect == false then
                    player:setSpriteFrame("feiji_1.png")
                else
                    player:setSpriteFrame("feiji_2.png")
                end  
            end

        elseif _state == FlyState.RIGHT then 


            x = 1

            if rotA < 5 then              
                if isYellowSelect == false then
                    player:setSpriteFrame("feiji_1.png") 
                else
                    player:setSpriteFrame("feiji_2.png")
                end   
            end
            if rotA < 10 and rotA >= 5 then
                if isYellowSelect == false then
                    player:setSpriteFrame("feiji_1.png") 
                else
                    player:setSpriteFrame("feiji_2.png")
                end
            end
            if rotA < 15 and rotA >= 10 then
                if isYellowSelect == false then
                    player:setSpriteFrame("feiji_1.png") 
                else
                    player:setSpriteFrame("feiji_2.png")
                end
            end
            if rotA >= 15 then
                if isYellowSelect == false then
                    player:setSpriteFrame("feiji_1.png") 
                else
                    player:setSpriteFrame("feiji_2.png")
                end
            end
        end  

        if math.abs(rt_Touch-rt_Normal)<=180  then
            rotA = math.abs(rt_Touch-rt_Normal)
        else
            if rt_Normal > rt_Touch then
                rotA = rt_Touch - rt_Normal + 360
            end
            if rt_Normal < rt_Touch then
                rotA = rt_Normal - rt_Touch + 360
            end
        end       

        rt_Normal = rt_Normal + math.ceil(rotA/10)*x

        -- 判断停止旋转
        if rt_Normal == rt_Touch then
            _state = FlyState.NORMAL
        end
        -- 判断通过临界点（360度）的向右旋转
        if rt_Normal > 360 then
            rt_Normal = 0
        end
        -- 过临界点的向左旋转（此处改成<0,修改目标是360时，一直旋转的问题）
        if rt_Normal < 0 then
            rt_Normal = 360
        end
        -- 测试，显示当前角度-------------------
--        curLabel:setString(rt_Normal)

        player:setRotation(rt_Normal)
        emitter:setAngle(-rt_Normal+270)

        -- 更新背景移动的方向
        _DirX = math.sin(math.rad(rt_Normal))
        _DirY = math.cos(math.rad(rt_Normal)) 

        if isGuide == false then
            -- 更新飞机的世界坐标
            planeWorldPositionX = planeWorldPositionX + _DirX*speed
            planeWorldPositionY = planeWorldPositionY + _DirY*speed

            -- 飞行距离
            distanceX = distanceX + math.abs(_DirX*speed)
            distanceY = distanceY + math.abs(_DirY*speed)

            distance = math.ceil(math.sqrt(distanceX*distanceX + distanceY*distanceY)/10)

            -- 选择黄色战机开局奖励1000米
            if isYellowSelect == true then
            	distance = distance + 1000
            end
            -- 判断是否购买
            local isBuy = cc.UserDefault:getInstance():getBoolForKey("isBuy")
            if isBuy == true then
                local buyDis = cc.UserDefault:getInstance():getIntegerForKey("integer")
                distance = distance + buyDis
            end
            -- 跟新飞行距离显示和label的X坐标    
            distanceText:setString(distance.."米")
            
            distanceText:setPositionX(distanceLabel:getPositionX()+distanceLabel:getBoundingBox().width/2+distanceText:getBoundingBox().width/2)

            ASGlobalClient.distance = distance

            -- 得到初始（0，0）点对应的世界坐标
            local worldX = math.ceil(planeWorldPositionX)
            local worldY = math.ceil(planeWorldPositionY)
            -- 设置参考节点的坐标
            node:setPosition(cc.p(-worldX,-worldY))
            -- 飞机的坐标（320，480）转换到参考节点坐标系下的坐标
            local pWorldPos = node:convertToNodeSpaceAR(cc.p(player:getPositionX(),player:getPositionY()))

            -- 飞机的世界坐标，初始为相对于 node节点（320，480）
            ASGlobalClient.pWorldX = math.ceil(pWorldPos.x)
            ASGlobalClient.pWorldY = math.ceil(pWorldPos.y)

            -- 测试，显示当前飞机的坐标置为（0，0） -----------------------------       
--            planeWorldXTextL:setString(pWorldPos.x-player:getPositionX())
--            planeWorldYTextL:setString(pWorldPos.y-player:getPositionY())
            -- 以上测试 --------------------------------------------

            time = time + 1
            -- 此处添加导弹(每隔5秒添加一枚)  
            if time/60 == second then

                self:addMissileFunc(node)
                time = 0
                second = 5.0
--                print("second ==== "..second)
            end               
        end                        
    end
    -- 开启飞行状态侦听
    gameLayer:scheduleUpdateWithPriorityLua(flyStateUpdate,1.0/40)

    -- 记录点击次数
    local touchID = 0
    -- 记录点击开始Y轴位置
    local touchBeganX = nil

    -- 触摸事件--开始触摸
    local function onTouchBegan(touch, event)
        isMoved = false
        -- 获取点击位置
        local pTouch = touch:getLocation()
        -- 获取点击开始Y轴位置
        touchBeganX = pTouch.x
        local s = gameLayer:getChildByTag(kTagSprite)
        local posX, posY = s:getPosition()

        local x = pTouch.x - posX
        local y = pTouch.y - posY

        -- 判断是引导页面的话，不做任何操作
        if isGuide == true then
            return true
        end
        -- 玩家飞机旋转角度
        --求角度（取1-360整数），反正切函数求弧度/π*180.0  --1弧度= 180/π, 1度=π/180
        rt_Touch = math.ceil(math.atan(x/y) / math.pi * 180.0)

        if x~=0 and y~=0 then         
            if y<0 then
                if x<0 then
                    -- 点击第三象限
                    rt_Touch = 180 + math.abs(rt_Touch)                             
                else
                    -- 点击第四象限
                    rt_Touch = 180 - math.abs(rt_Touch)
                end
            else          
                if x<0 then
                    -- 点击第二象限
                    rt_Touch = 360 + rt_Touch
                end
            end
        end

        -- 测试，显示目标角度-------------------
--        TouchLabel:setString(rt_Touch)
        -- 判断飞机旋转方向（向左/向右）
        if rt_Normal ~= rt_Touch then
            if rt_Normal<180 then
                if rt_Touch>rt_Normal and rt_Touch<rt_Normal+180 then
                    _state = FlyState.RIGHT                            
                else 
                    _state = FlyState.LEFT    
                end            
            else
                if rt_Touch<rt_Normal and rt_Touch>rt_Normal-180 then
                    _state = FlyState.LEFT     
                else
                    _state = FlyState.RIGHT      
                end
            end
        end

        return true           
    end

    -- 开始移动
    local function onTouchMoved(touch, event)
        if isGuide == true then
            -- 判断点击引导时，不能滑动
            if touchID >= 0 then
                return
            end
        end

        isMoved = true
        -- 获取点击位置
        local pTouch = touch:getLocation()
        local s = gameLayer:getChildByTag(kTagSprite)
        local posX, posY = s:getPosition()

        local x = pTouch.x - posX
        local y = pTouch.y - posY
        -- 引导界面判断
        if guideLayer ~= nil then
            local rect = cc.rect(nodef:getPositionX()-nodef:getContentSize().width/2,
                nodef:getPositionY()-nodef:getContentSize().height/2,
                nodef:getContentSize().width,nodef:getContentSize().height) -- 设置框坐标和大小处于btn 按钮的位置上 
            if cc.rectContainsPoint(rect, pTouch) then  
                -- 点击位置在rect范围内，此处不做逻辑，让飞机按游戏逻辑跟随旋转
                else
                    -- 点击位置不在rect范围内，不能move
                    return
                end
        end
        -- 飞机旋转角度
        --求角度（取1-360整数），反正切函数求弧度/π*180.0  --1弧度= 180/π, 1度=π/180
        rt_Touch = math.ceil(math.atan(x/y) / math.pi * 180.0)
        if x~=0 and y~=0 then         
            if y<0 then
                if x<0 then
                    -- 点击第三象限
                    rt_Touch = 180 + math.abs(rt_Touch)                             
                else
                    -- 点击第四象限
                    rt_Touch = 180 - math.abs(rt_Touch)
                end
            else
                if x<0 then
                    -- 点击第二象限
                    rt_Touch = 360 + rt_Touch
                end
            end
        end

        -- 测试，显示目标角度-------------------
--        TouchLabel:setString(rt_Touch)

        -- 判断飞机旋转方向（向左/向右）
        if rt_Normal ~= rt_Touch then
            if rt_Normal<180 then
                if rt_Touch>rt_Normal and rt_Touch<rt_Normal+180 then
                    _state = FlyState.RIGHT                            
                else 
                    _state = FlyState.LEFT    
                end            
            else
                if rt_Touch<rt_Normal and rt_Touch>rt_Normal-180 then
                    _state = FlyState.LEFT     
                else
                    _state = FlyState.RIGHT      
                end
            end
        end

    end

    -- 触摸结束
    local function onTouchEnded(touch, event)
        if isMoved == true then
            _state = FlyState.NORMAL
        end    
        isMoved = false

        -- 获取点击位置
        local pTouch = touch:getLocation()
        local s = gameLayer:getChildByTag(kTagSprite)
        local posX, posY = s:getPosition()

        local x = pTouch.x - posX
        local y = pTouch.y - posY

        -- 引导界面判断
        if guideLayer ~= nil then
            -- 设置框坐标和大小处于btn 按钮的位置上 
            local rect = cc.rect(nodef:getPositionX()-nodef:getContentSize().width/2,
                nodef:getPositionY()-nodef:getContentSize().height/2,
                nodef:getContentSize().width,nodef:getContentSize().height) 
            -- 引导触摸回调，每次执行一次
            function showNodef()   
                -- 设置引导按钮可见            
                nodef:setVisible(true)
                label:setVisible(true)
                -- 引导图片换成滑动
                if touchID >= 1 then
                    nodef:setTexture("Images/arrow.png")
                   
                    label:setString("按箭头方向滑动")
                 
                    nodef:setPosition(cc.p(size.width/2,size.height/4))
                    label:setPosition(nodef:getPositionX()+70,nodef:getPositionY())
                end
                if touchID >1 and (pTouch.x - touchBeganX) < -20 then
                    touchID = -1
                    self:removeChild(guideLayer,true)
                    guideLayer = nil
                    isGuide = false       
                end
                director:getScheduler():unscheduleScriptEntry(self._guideScheduler)
            end
            -- 如果触点处于rect中 
            if cc.rectContainsPoint(rect, pTouch) then 
                -- 点击次数加1
                touchID = touchID+1
                -- 判断引导按钮时调用，使飞机转到按钮中心
                if touchID <= 1 then
                    nodef:setPositionX(size.width + 200)
                    x = nodef:getPositionX() - posX
                    y = nodef:getPositionY() - posY
                    nodef:setVisible(false)
                    label:setVisible(false)
                    self._guideScheduler = director:getScheduler():scheduleScriptFunc(showNodef,2,false)         
                else
                    -- 如果滑动引导时，滑动距离大于20，表示滑动成功
                    if (pTouch.x - touchBeganX) < -20 then
                        cc.UserDefault:getInstance():setBoolForKey("first_time", false)
                        nodef:setPositionY(size.height + 500)
                        nodef:setVisible(false)
--                        label:setVisible(false)
                        
                        label:setString("小心导弹哦!!!")
                     
                        
                        local blink = cc.Blink:create(2,3)
                        label:runAction(blink)
                        label:setPosition(cc.p(size.width/2,size.height/4))
                        self._guideScheduler = director:getScheduler():scheduleScriptFunc(showNodef,2,false)
                    else
                        -- 否则什么也不做
                        return
                    end
                end                
            else
                return
            end
        end

        -- 玩家飞机旋转角度
        --求角度（取1-360整数），反正切函数求弧度/π*180.0  --1弧度= 180/π, 1度=π/180
        rt_Touch = math.ceil(math.atan(x/y) / math.pi * 180.0)

        if x~=0 and y~=0 then         
            if y<0 then
                if x<0 then
                    -- 点击第三象限
                    rt_Touch = 180 + math.abs(rt_Touch)                             
                else
                    -- 点击第四象限
                    rt_Touch = 180 - math.abs(rt_Touch)
                end
            else          
                if x<0 then
                    -- 点击第二象限
                    rt_Touch = 360 + rt_Touch
                end
            end
        end

        -- 测试，显示目标角度-------------------
--        TouchLabel:setString(rt_Touch)

        -- 判断飞机旋转方向（向左/向右）
        if rt_Normal ~= rt_Touch then
            if rt_Normal<180 then
                if rt_Touch>rt_Normal and rt_Touch<rt_Normal+180 then
                    _state = FlyState.RIGHT                            
                else 
                    _state = FlyState.LEFT    
                end            
            else
                if rt_Touch<rt_Normal and rt_Touch>rt_Normal-180 then
                    _state = FlyState.LEFT     
                else
                    _state = FlyState.RIGHT      
                end
            end           
        end     
    end
    -- 单点触摸监听器
    local listener = cc.EventListenerTouchOneByOne:create()
    -- 注册三个回调监听方法
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
    -- 事件派发器
    local eventDispatcher = gameLayer:getEventDispatcher()
    -- 绑定触摸事件到层中
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,gameLayer)

    return gameLayer
end

-- 表示屏幕四个边
local posDir = {
    {0,1}, --上边
    {0,-1}, -- 下边
    {-1,0}, -- 左边
    {1,0} -- 右边
}

-- 添加导弹
function ASMainGameScene:addMissileFunc(node)
    local rot = math.random(1,360)
    local speed = math.random(6,7)
    local factor = math.random()+0.2
    local i = math.random(1,4)
    -- 获取屏幕四个边上的随机位置
    local randX,randY = self:getRandPos(posDir[i])
    local pos = cc.p(randX,randY)
    local aMissile = ASMissile:create(pos,rot,speed,factor)
    node:addChild(aMissile)
end

-- 得到屏幕四个边的随机位置
function ASMainGameScene:getRandPos(randDir)
    local posX, posY
    if randDir == posDir[1] then
        posX = math.random(ASGlobalClient.pWorldX-size.width/2,ASGlobalClient.pWorldX+size.width/2)
        posY = ASGlobalClient.pWorldY+size.height/2-20
    elseif randDir == posDir[2] then
        posX = math.random(ASGlobalClient.pWorldX-size.width/2,ASGlobalClient.pWorldX+size.width/2)
        posY = ASGlobalClient.pWorldY-size.height/2+20
    elseif randDir == posDir[3] then
        posX = ASGlobalClient.pWorldX-size.width/2+20
        posY = math.random(ASGlobalClient.pWorldY-size.height/2,ASGlobalClient.pWorldY+size.height/2)
    elseif randDir == posDir[4] then
        posX = ASGlobalClient.pWorldX+size.width/2-20
        posY = math.random(ASGlobalClient.pWorldY-size.height/2,ASGlobalClient.pWorldY+size.height/2)
    end

    return posX,posY
end

return ASMainGameScene