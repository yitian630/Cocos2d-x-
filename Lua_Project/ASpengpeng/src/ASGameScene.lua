--游戏界面

require("math")
require("src.EndBg")
require("Cocos2d")
require("Cocos2dConstants")
require("src.Csv")

local ASGameScene = class("ASGameScene", function()
    return cc.Scene:create()
end)

--添加音频材料
local ASEffectPlayer = require("src/ASMusicPlayer")
local ASMusicsPlayer = require("src/ASBackGroundMusicPlayer")
local cache = cc.SpriteFrameCache:getInstance()

local bird = nil
local birdTexture = nil
local flower = nil
--local kFlowerTag = 500
local schedulerID = 0

local director = cc.Director:getInstance()
local size = director:getVisibleSize()
local origin = director:getVisibleOrigin()

local spikeDownScale = 0.8 --下边钉子移动的位置
local spikeUpScale = 0.6   --上边钉子移动的位置

local changeV = 500--点击之后向上的速度
local exitV = -1000
local v = -10
local v0 = 0
local g = -1150
local dX = 4.5--开始时的水平速度

local XNumDis = 30--顶部金币那的X和金币数的距离

local numberL = 0
local numberR = 0

local labelBest = nil
local labelScore = nil
local labelMoney = nil

local spikeDown = nil
local spikeUp = nil 

local flag = 0--小鸟方向
local best = 2

local score = 0
local money = 0
local level = 0 

local scoreTipsLabel = nil--破纪录提示label

local flagUpFlag = 0--小鸟和上边钉子未碰撞

local flagMoney = 1--金币状态，是否已经消失
local kMoneySpriteTag = 100
local spriteMoney = nil
local spriteMoneyPoint = nil

local layer = nil
local exitFlag = 1 --小鸟正常运动

local spikeRectLeft = 0
local spikeRectRight = 0
local spikeHeight = 0 --钉子大小
local spikeWidth = 0
local tableSpike = {}

local birdSpriteRect  = nil  --小鸟矩形
local birdWidth = 0 --小鸟的宽度
local birdHeight =0 --小鸟的高度

local maxSpikeNum  = 0--两边钉子的最大个数
local tableMaxSpike = {}--两边钉子的数组

local spikeDownRect = nil
local spikeUpRect = nil

ASGameScene.__index = ASGameScene


------------------------------------------------
-- create - 创建对象
-- @param：void
-- @return：返回创建的对象
------------------------------------------------
function ASGameScene.create()
    local scene = ASGameScene.new()
    if nil ~= scene then
        if scene:init() ~= true then return nil end
    end
    return scene
end

------------------------------------------------
--产生钉子
--------------------------------------------------
local function createRightSpikes()
    local spike = cc.Sprite:create("res/GameScenePic/spike.png")
    spike:setAnchorPoint(0,0)
    spikeHeight = spike:getContentSize().height
    spikeWidth = spike:getContentSize().width
    return spike
end

local function animationBirdFly ()  
    local animFrames = {}
    for i = 1,2 do 
        local name = "bird"..i.."_level"..level..".png"
        local frame = cache:getSpriteFrame(name)
        animFrames[i] = frame
    end
    return cc.Animate:create((cc.Animation:createWithSpriteFrames(animFrames,0.1)))
end

------------------------------------------------
--事件处理
--handing touch events
--------------------------------------------------
local function onTouchBegan(touch, event)
    --CCTOUCHBEGvent must return true
    bird.isPaused = false
    if exitFlag == 0 then
        return false
    else
        v = changeV
        --点击一次
        bird:runAction(cc.Repeat:create(animationBirdFly(),1))
        return true
    end
end

local function onTouchEnded(touch, event)
    --添加声音
    ASEffectPlayer:getInstance():currentPlayEffect("jump.wav",false)
end


local function onNodeEvent(event)
    if "exit" == event then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerID)
    end
end

------------------------------------------------
--小鸟转身
--------------------------------------------------
local function birdChangeDirectionL(aSprite)
    local orbit = cc.OrbitCamera:create(0.02, 1, 0, 0, 180, 0, 0)
    aSprite:runAction(orbit)
end

local function birdChangeDirectionR(aSprite)
    local orbit = cc.OrbitCamera:create(0.02, 1, 0, 0, 360, 0, 0)
    aSprite:runAction(orbit)
end

------------------------------------------------
--插入到数组里边
------------------------------------------------
local function insertTable(aTable,pos,var)
    table.insert(aTable,pos,var)
end

------------------------------------------------
----碰到金币后回调设置金币值
------------------------------------------------
local function callBackSetMoney()
    if exitFlag ~= 0 then
         labelMoney:setString(money)
    end
end

------------------------------------------------
--结束界面回调
--------------------------------------------------
local function endSceneCallBack() 
    require("src/Csv")
    
--     savepresentGrade(score)
--     if best<score then
--          saveGrade(score)
--     end
     
    --保存当前分数
    saveCurrentGrade(score)
     
     -----------------------------------------------------------需要读csv文件
     if money ~= (getGold() -0) then
--     if money ~= 0 then
          saveGold(money)
     end
    
    --replace结束界面    
    local ASLayer = nil
    ASLayer = require("src/EndBg")
    local sceneGame = cc.Scene:create()
    sceneGame:addChild(require("src/ASBackgroundLayer").create())
    sceneGame:addChild(ASLayer.create())
    
    cc.Director:getInstance():replaceScene(sceneGame)
    
    --停止背景音乐
    ASMusicsPlayer:getInstance():stopCustemMusic()

    
end

------------------------------------------------
--更新的回调函数
------------------------------------------------
local function tick(dt)

    --小鸟暂停
    if bird.isPaused then return end
    
    --获取小鸟精灵及其矩形
    local x = bird:getPositionX()
    local y = bird:getPositionY()  
    birdSpriteRect = bird:getBoundingBox()    
        
    --判断是否到最右边
    if x >=  size.width-bird:getContentSize().width*0.5+20 then
        
        flag = 1--向左走
        
        ----移除钉子
        --判断右边是否出来钉子
        if numberR ~= 0 then
            for j = maxSpikeNum+1,numberR do 
                layer:removeChildByTag(j,true)
            end
            tableSpike = {}
        end
        
        ----产生之前先移除金币精灵
        if flagMoney==1 then
            layer:removeChildByTag(kMoneySpriteTag,true)
            flagMoney = 0
        end
        
        if exitFlag ~= 0  then
            ----产生钉子            
            --判断分数，由分数的高低来决定钉子的数量
            numberL = (math.floor(score/6))+1
            if numberL >= maxSpikeNum-1  then
                numberL = numberL - 2
            end
            local tempTableMaxSpikeL = {}
            for  i=1, table.getn(tableMaxSpike) do
                tempTableMaxSpikeL[i] = tableMaxSpike[i]
            end
            local positionYL = 0
            --产生随机数，即钉子的数量，钉子的位置
            for i=1,numberL
            do
                local spike = createRightSpikes()
                spike:setAnchorPoint(0.15,0)
                local temp = math.random(1,table.getn(tempTableMaxSpikeL))
                positionYL = tempTableMaxSpikeL[temp]
                spike:setPosition(origin.x,positionYL)
                layer:addChild(spike,1,i)
                spikeRectLeft =cc.p(spikeWidth/2, positionYL+spikeHeight/2)
                insertTable(tableSpike,i,spikeRectLeft)
                table.remove(tempTableMaxSpikeL,temp)
            end
            
            
            ----产生金币精灵(每个金币代表相同的值，如果想改变它的值可以在上边添加label)
            spriteMoney = cc.Sprite:create("res/GameScenePic/win_gold.png")
            spriteMoney:setAnchorPoint(0.5,0.5)
            local positionX = math.random(spikeWidth+spriteMoney:getContentSize().width*0.5,size.width-spikeWidth-spriteMoney:getContentSize().width*0.5)
            local positionY = math.random(spikeDown:getPositionY()+spikeDown:getContentSize().height*spikeDownScale,size.height-spikeUp:getContentSize().height*spikeUpScale)
            spriteMoney:setPosition(positionX,positionY) 

            layer:addChild(spriteMoney,5,kMoneySpriteTag)
            spriteMoneyPoint = cc.p(positionX,positionY)
            flagMoney = 1
        end

        --改变方向
        birdChangeDirectionL(bird)          
        --设置分数，最高纪录,设置声音
        score = score+1
        labelScore:setString(score)
        -----破纪录提示
        if score > best  and scoreTipsLabel == nil then
           ----弹出label精灵，持续1秒钟 
            scoreTipsLabel = cc.Label:createWithTTF("v5!","res/fonts/FZPWJW.TTF",64)
            scoreTipsLabel:setPosition(cc.p(size.width/2,size.height*0.7))
            local action = cc.FadeOut:create(2)
            scoreTipsLabel:runAction(action)
            scoreTipsLabel:setColor(cc.c3b(255,255,0))
            layer:addChild(scoreTipsLabel,5)
        end
        
        ASEffectPlayer:getInstance():currentPlayEffect("point.wav",false)
        

        
    --判断是否到最左边
    elseif x <= bird:getContentSize().width*0.5-20 then
    
        flag = 0--向右走
        
        --判断左边是否出来钉子
        --移除钉子     
        if numberL ~= 0 then
            for k = 1,numberL do
                layer:removeChildByTag(k,true)
            end
            tableSpike = {}
        end
        
        ----产生之前先移除金币精灵
        if flagMoney == 1 then
            layer:removeChildByTag(kMoneySpriteTag,true)
            flagMoney = 0--金币已经消失
        end
        
        if exitFlag ~= 0 then
            ----产生钉子
            --判断分数，由分数的高低来决定钉子的数量
            --产生随机数，即钉子的数量，钉子的位置
            numberR = maxSpikeNum+numberL
            local positionYR
            local tempTableMaxSpikeR = {}
            for  i=1, table.getn(tableMaxSpike) do
                tempTableMaxSpikeR[i] = tableMaxSpike[i]
            end            
            --产生随机数，即钉子的数量，钉子的位置
            for i=maxSpikeNum+1,numberR
            do
                local spike = createRightSpikes()
                spike:setAnchorPoint(0.15,0)
                local temp = math.random(1,table.getn(tempTableMaxSpikeR))
                positionYR = tempTableMaxSpikeR[temp]
                spike:setPosition(size.width,positionYR)
                --转变方向
                local orbit = cc.OrbitCamera:create(0.0001, 1, 0, 0, 180, 0, 0)
                spike:runAction(orbit)
                --放入数组中，来判断是否碰撞
                layer:addChild(spike,1,i)
                spikeRectRight = cc.p(size.width-spikeWidth/2, positionYR+spikeHeight/2)
                insertTable(tableSpike,i-maxSpikeNum,spikeRectRight)

                table.remove(tempTableMaxSpikeR,temp)
            end 
            ----产生金币精灵(每个金币代表相同的值，如果想改变它的值可以在上边添加label
            spriteMoney = cc.Sprite:create("res/GameScenePic/win_gold.png")
            spriteMoney:setAnchorPoint(0.5,0.5)
            local positionX = math.random(spikeWidth+spriteMoney:getContentSize().width*0.5,size.width-spikeWidth-spriteMoney:getContentSize().width*0.5)
            local positionY = math.random(spikeDown:getPositionY()+spikeDown:getContentSize().height*spikeDownScale,size.height-spikeUp:getContentSize().height*spikeUpScale)

            spriteMoney:setPosition(positionX,positionY) 
            layer:addChild(spriteMoney,5,kMoneySpriteTag)
            spriteMoneyPoint = cc.p(positionX,positionY)
            flagMoney = 1  
        end
              
        --改变方向
        birdChangeDirectionR(bird)
        --设置分数，最高纪录，设置声音
        score = score+1  
        labelScore:setString(score)
        
        ---------破纪录提示
        if score > best and scoreTipsLabel == nil then
            scoreTipsLabel = cc.Label:createWithBMFont("res/fonts/font.fnt","v5!")
            scoreTipsLabel:setScale(1.5) 
            scoreTipsLabel:setPosition(cc.p(size.width/2,size.height*0.7))
            local action = cc.FadeOut:create(2)
            scoreTipsLabel:runAction(action)
            scoreTipsLabel:setColor(cc.c3b(255,255,0))
            layer:addChild(scoreTipsLabel,5)         
        end
        
        ASEffectPlayer:getInstance():currentPlayEffect("point.wav",false)
        
--        --小鸟到一定程度变色
--        if score%5 == 0 and score ~= 0 then
--            bird:runAction(cc.TintTo:create(0,84,255,159))         
--        end
        
    end
    
    --判断完成，各种情况都要执行的即：小鸟一直移动
    
    --小鸟动作和碰撞检测和设置金币数量（时刻都要进行的）
        if cc.rectContainsPoint(birdSpriteRect,spriteMoneyPoint) then
        --移除金币精灵
        if flagMoney ==1 and exitFlag ~= 0 then
--        --金币消失时候的动画
            ASEffectPlayer:getInstance():currentPlayEffect("getMoney.mp3",false)
--            local actionOut = cc.MoveTo:create(1,cc.p(labelMoney:getPositionX(),labelMoney:getPositionY()))
--            local actionScale2 = cc.ScaleTo:create(0.5,0.5)
--            local removeSelf = cc.RemoveSelf:create()--消除金币
--            local callFun = cc.CallFunc:create(callBackSetMoney)--回调函数,设置金币值
--            local sequeueAction = cc.Sequence:create(
--            actionScale2,actionOut,callFun,removeSelf)
--            spriteMoney:runAction(cc.RepeatForever:create(sequeueAction))
            layer:removeChildByTag(kMoneySpriteTag,true)
--添加了removeself动画，所以不用自己remove了
            flagMoney = 0
            --设置声音
            money = money+1
            callBackSetMoney()
        end
    end
    
    --小鸟碰撞检测
    
        --和上边钉子碰撞
    if cc.rectIntersectsRect(birdSpriteRect,spikeUpRect) then
--        local actColor = cc.TintTo:create(0,128,138,135)
--        local actOrbit = cc.OrbitCamera:create(1, 1, 0, 0,0,0, 0)
--        local seq = cc.Sequence:create(actColor,actOrbit)
--        bird:runAction(cc.Repeat:create(seq,5))   
        
        v = exitV
        exitFlag = 0 
        flagUpFlag = 1
        --添加声音
        ASEffectPlayer:getInstance():currentPlayEffect("dead.wav",false)
        
        --和下边钉子碰撞
    elseif exitFlag~= 0 and cc.rectIntersectsRect(birdSpriteRect,spikeDownRect) then
        v = exitV
        exitFlag = 0
        --添加声音
        ASEffectPlayer:getInstance():currentPlayEffect("dead.wav",false)
        
        --和两边钉子碰撞
    elseif bird:getPositionX() <= spikeWidth*0.5+birdWidth/2  or bird:getPositionX()>=(size.width-spikeWidth*0.5-birdWidth/2) then
        --判断已经有数组了
        for key, var in ipairs(tableSpike) do
            if (cc.rectContainsPoint(birdSpriteRect,tableSpike[key]))  then
                v = exitV
                exitFlag = 0
                --添加声音
                ASEffectPlayer:getInstance():currentPlayEffect("dead.wav",false)
            end
        end
    end
    
    --小鸟的水平运动
    --小鸟正常运动
    if exitFlag ~= 0 then
    	--小鸟动作
        if flag == 0 then
            x = x+dX
        else
            x = x-dX
        end
    else 
        --小鸟变灰色  
        local tex = cache:getSpriteFrame("die_level"..level..".png")
        bird:setTextureRect(tex:getRect())
        bird:setTexture(tex)
        
        --小鸟碰钉子之后
            --小鸟和上边钉子碰撞
        if flagUpFlag == 1 then
        else
            if flag == 0 then
                x = x-dX
            else
                x = x+dX
            end
        end
    end
    
    v = v+g*dt
    y=y+v*dt
    
    bird:setPositionX(x)
    bird:setPositionY(y)
    flower:setPosition(x,y)
    if  exitFlag == 0 and bird:getPositionY()<= spikeDown:getPositionY()+spikeDown:getContentSize().height*spikeDownScale then
        flower:setDuration(1)
        --停止更新
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerID)
        --结束界面
        endSceneCallBack()
    end
    
end

--------------------------------------------------
--创建层
--返回值：layer
--------------------------------------------------
local function createLayer()

    layer = cc.Layer:create()
    
    --设置随机种子
    math.randomseed(os.time())
    
    --添加背景颜色
    local layerBg = cc.Sprite:create("res/GameScenePic/background.png")
    layerBg:setAnchorPoint(0.5,0.5)
    layerBg:setPosition(origin.x+size.width/2,origin.y+size.height/2)
    layerBg:setScale(0.8)
    layer:addChild(layerBg,1)

--    --添加成绩的label的背景
--    local labelBg = cc.Sprite:create("res/GameScenePic/circle.png")
--    labelBg:setPosition(cc.p(size.width/2,size.height/2))
--    layer:addChild(labelBg,1)

    --添加金币精灵及其矩形
    spriteMoney = cc.Sprite:create("res/GameScenePic/win_gold.png")
    spriteMoney:setAnchorPoint(0.5,0.5)
    spriteMoney:setPosition(100,100)
    layer:addChild(spriteMoney,1,kMoneySpriteTag)
    spriteMoneyPoint = cc.p(100,100)
    
    
    --添加计成绩的label
    score = 0
    labelScore = cc.Label:createWithTTF(score,"res/fonts/FZPWJW.TTF",64)
    labelScore:setColor(cc.c3b(0,50,0))
    labelScore:setPosition(cc.p(size.width/2,size.height/2))
    layer:addChild(labelScore,1)

    -------------------------------------------------------------------------------需要读csv文件

    --添加最高分，最高分从文件中获取
    require("src/Csv")
    best = getGrade() - 0
--    best = 0

        
    labelBest = cc.Label:createWithTTF(best,"res/fonts/FZPWJW.TTF",42)
    labelBest:setColor(cc.c3b(255,255,0))
    labelBest:setPosition(cc.p(size.width/2,size.height/2-80))
    layer:addChild(labelBest,1)

    --添加上、下的钉子
    spikeUp = cc.Sprite:create("res/spike/spikesup.png")
    spikeUp:setAnchorPoint(0.5,spikeUpScale)
    spikeUp:setPosition(size.width/2,size.height)
    local spikeUpWidth = spikeUp:getContentSize().width
    local spikeUpHeight = spikeUp:getContentSize().height
    spikeUpRect = cc.rect(spikeUp:getPositionX()-size.width/2,spikeUp:getPositionY()-spikeUpHeight*0.5,spikeUpWidth,spikeUpHeight*spikeUpScale-20)
    layer:addChild(spikeUp,100)
    
    spikeDown = cc.Sprite:create("res/spike/spikedown.png")
    spikeDown:setAnchorPoint(0.5,1-spikeDownScale)
    --注意位置
    spikeDown:setPosition(origin.x+size.width/2,origin.y)
    spikeDownRect = cc.rect(spikeDown:getPositionX()-size.width/2,spikeDown:getPositionY(),spikeDown:getContentSize().width,spikeDown:getContentSize().height*spikeDownScale-20)
    layer:addChild(spikeDown,100) 
    
    spikeHeight = 100
    maxSpikeNum = math.floor((size.height - spikeDown:getContentSize().height*spikeDownScale - spikeUp:getContentSize().height*spikeUpScale)/spikeHeight)
    local tmp = spikeDown:getPositionY()+spikeDown:getContentSize().height*spikeDownScale
    for i = 1,maxSpikeNum do
        insertTable(tableMaxSpike,i,tmp)
        tmp = tmp + spikeHeight
    end
    
    --添加小鸟及其矩形
    --生成纹理图集
    --生成birdSprite
    cache:addSpriteFrames("res/GameScenePic/bird.plist")
    bird = cc.Sprite:createWithSpriteFrame(cache:getSpriteFrame("bird1_level"..level..".png"))
    bird:setAnchorPoint(0.5,0.5)
    bird:setScale(0.9)
    bird:setPosition(size.width/2,size.height/2)
    --添加到layer上
    layer:addChild(bird,100)    
    birdSpriteRect = bird:getBoundingBox()
    birdWidth = bird:getContentSize().width*0.8    
    
--    --添加X号label
--    local XLabel = cc.Label:createWithTTF("X","res/fonts/Marker Felt.ttf",30)
--    XLabel:setAnchorPoint(0.5,0.5)
--    XLabel:setPosition(spikeUp:getContentSize().width*0.53,spikeUp:getContentSize().height*0.4)
--    spikeUp:addChild(XLabel)
--    
--    --添加金币图形Sprite
--    for i=1,3 do
--        local MoneyPicSprite = cc.Sprite:create("res/GameScenePic/win_gold.png")
--        MoneyPicSprite:setAnchorPoint(0.5,0.5)
--        MoneyPicSprite:setPosition(spikeUp:getContentSize().width*0.445,spikeUp:getContentSize().height*(0.33+i*0.05))
--        spikeUp:addChild(MoneyPicSprite,i)
--    end

        
--------------------------------------------------------------------------------需要读csv文件
----添加金币的label
----从csv文件中获取当前金币的值
----    require("src/Csv")
----    money = getGold()-0
--    
--    labelMoney = cc.Label:createWithTTF(money,"res/fonts/Marker Felt.ttf",40)
--    labelMoney:setAnchorPoint(0,0.5)
--    labelMoney:setPosition(XLabel:getPositionX()+XNumDis,XLabel:getPositionY())
--    spikeUp:addChild(labelMoney)
    
    ---顶部金币X金币数
    local XLabel= cc.Label:createWithTTF("x","res/fonts/FZPWJW.TTF",48)
    XLabel:setAnchorPoint(0.5,0.5)
    XLabel:setPosition(size.width*0.49,size.height*0.965)
    layer:addChild(XLabel,100)
    
    local goldSprite = cc.Sprite:create("res/GameScenePic/win_gold.png")
    goldSprite:setPosition(size.width*0.42,size.height*0.96)
    layer:addChild(goldSprite,100)
    
    require("src/Csv")
    money = getGold()-0
--     money = 0

    labelMoney = cc.Label:createWithTTF(money,"res/fonts/FZPWJW.TTF",48)
    -------------------------------------------------------------------------改动
    labelMoney:setAnchorPoint(0,0.5)
    labelMoney:setPosition(size.width*0.53,size.height*0.96)
    --------------------------------------------------------------------------
    layer:addChild(labelMoney,100)
    
    
    --产生粒子效果
    flower = cc.ParticleFlower:create()
    flower:setLife(0.001)
--    flower:setLifeVar(1)
    flower:setTexture(cc.Director:getInstance():getTextureCache():addImage("res/GameScenePic/fire.png"))
    layer:addChild(flower,4)--kFlowerTag--
 
    schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick,0.01,false)

    --注册观察者
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

    layer:registerScriptHandler(onNodeEvent)

    return layer
end

-------------------------------------------------
-- init - 初始化（auto-invoked)
-- @param: void
-- @return: bool类型，表示创建是否成功
-------------------------------------------------
function ASGameScene:init()
    
      schedulerID = 0
      changeV = 500--点击之后向上的速度
      exitV = -1200
      v = -10
     -- g = -1150
      dX = 4.5--开始时的水平速度
      numberL = 0
      numberR = 0
      flag = 0--小鸟方向
      scoreTipsLabel = nil--破纪录提示label
      
      require("src/Csv")
      score = getGrade()-0
      money = getGold()-0
      level = getLevel()-0
      
      tableSpike = {}
      tableMaxSpike = {}
      flagUpFlag = 0--小鸟和上边钉子未碰撞

      flagMoney = 1--金币状态，是否已经消失
      kMoneySpriteTag = 100
      exitFlag = 1 --小鸟正常运动
      
    --添加背景音乐
    ASMusicsPlayer:getInstance():playBgMusic("playingMusic.mp3")
   
    local myLayer = createLayer()
    self:addChild(myLayer)
    return true
end

return ASGameScene