-- 进度条
local ASProgress = require("scenes.ASProgress")

-- 金子矩阵
local ASGoldMatrix = require("scenes.ASGoldMatrix")
-- 结束层
local ASGameOver = require("scenes.ASGameOver")
local ASGameScene = class("ASGameScene",function ()
    return cc.Scene:create()
end)

local director = cc.Director:getInstance()
local origin = director:getVisibleOrigin()
local size = director:getVisibleSize()

Key_BestScore = "Key_BestScore"

ASGameScene.__index = ASGameScene
ASGameScene.m_goldMatrix = nil    -- 金子矩阵
ASGameScene.m_labelBestScore = nil -- 最高分
ASGameScene.m_levelLabel = nil     -- 关卡
ASGameScene.m_gameRun = nil        -- 游戏是否进行中
ASGameScene.m_gameOverLayer = nil  -- 游戏结束层
ASGameScene.scheduleID = nil       -- 调度器ID
ASGameScene.m_progress = nil       -- 游戏进度条
ASGameScene.currentLevel = nil     -- 当前关卡
function ASGameScene.create()
    local scene = ASGameScene.new()
    if nil ~= scene then
        if scene:init() ~= true then
            return nil
        end
    end

    return scene
end

function ASGameScene:init()

    local layer = cc.Layer:create()
    self:addChild(layer)
    -- 创建背景
    local bg = cc.Sprite:create("bg_game.jpg")
    bg:setPosition(size.width/2,size.height/2)
    layer:addChild(bg)
    
    -- 返回按钮回调
    local function startGameHandler()
        print("返回主场景")
        if self.scheduleID ~= nil then
        	director:getScheduler():unscheduleScriptEntry(self.scheduleID)
        	self.scheduleID = nil
        end
        local mainScene = require("ASMainScene").create()
        director:replaceScene(mainScene)
    end
    -- 添加返回菜单
    local labelBack = cc.Label:createWithSystemFont("返回","",35)
    local backItem = cc.MenuItemLabel:create(labelBack)
    backItem:registerScriptTapHandler(startGameHandler)
    local backMenu = cc.Menu:create(backItem)
    backMenu:setPosition(origin.x+backItem:getBoundingBox().width,size.height-backItem:getBoundingBox().height)
    layer:addChild(backMenu)

    -- 金子矩阵
    self.m_goldMatrix = ASGoldMatrix.create()
    self.m_goldMatrix:setPosition(cc.p(size.width/2, size.height/2))
    layer:addChild(self.m_goldMatrix)

    -- 添加进度条
    self.m_progress = ASProgress.create()
    layer:addChild(self.m_progress)
    self.m_progress:setPosition(size.width/2,size.height/8)
    self.m_progress:update(1)

    -- 最高成绩
    self.m_labelBestScore = cc.Label:createWithSystemFont("","",25)
    self.m_labelBestScore:setPosition(size.width-120,size.height-35)
    self.m_labelBestScore:setWidth(200)
    self.m_labelBestScore:setAlignment(cc.TEXT_ALIGNMENT_RIGHT)
    self.m_labelBestScore:setTextColor(cc.c4b(222,0,53,255))
    layer:addChild(self.m_labelBestScore)
    -- 关卡提示
    self.m_levelLabel = cc.Label:createWithSystemFont("","",50)
    self.m_levelLabel:setPosition(size.width/2,size.height/2+ASGoldMatrix.MATRIX_SIZE/2+60)
    layer:addChild(self.m_levelLabel)
    self.m_levelLabel:setString("第1关")
    self.m_labelBestScore:setVisible(false)
    --显示最高成绩
    local bestScore = cc.UserDefault:getInstance():getIntegerForKey(Key_BestScore,0)
    if bestScore>0 then
    	self.m_labelBestScore:setVisible(true)
    	self.m_labelBestScore:setString("最好成绩"..bestScore.."枚")
    end
    -- 添加游戏结束层
    self.m_gameOverLayer = ASGameOver.create()
    layer:addChild(self.m_gameOverLayer)
 
    self.m_gameOverLayer:setScale(0)
    
    
    local function onTouchBegan(touch,event)
        -- 游戏结束后不再接收点击
        if self.m_gameRun == false then           
        	return true
        end
    	print("-----touchBegan-----------")
    	-- 获取触摸点坐标
    	local location = touch:getLocation()
        -- 计算金子单元矩阵的rect
        local posX = self.m_goldMatrix:getPositionX()
        local posY = self.m_goldMatrix:getPositionY()
        local result = self.m_goldMatrix:getObtainResult(cc.p(location.x-posX,location.y-posY))
        print("result = "..result)
        if result == "SUCCESS" then
            self.currentLevel = self.m_goldMatrix:getCurrentLevel()
            local time = 2
            if self.currentLevel > 2 and self.currentLevel < 6 then
                time = 3/self.currentLevel + 2
            elseif self.currentLevel >= 6 and self.currentLevel < 10 then
                time = 6/self.currentLevel + 2
            elseif self.currentLevel >= 10 and self.currentLevel < 15 then
                time = 10/self.currentLevel + 2
            elseif  self.currentLevel >= 15 and self.currentLevel < 21 then
                time = 15/self.currentLevel + 2
            elseif self.currentLevel >= 21 then
                time = 21/self.currentLevel + 2
            end
            
            -- 购买成功，时间增加 -------------------------
            local _isBuy = cc.UserDefault:getInstance():getBoolForKey("isBuy")
            if _isBuy == true then
                time = time + cc.UserDefault:getInstance():getIntegerForKey("integer")
            end
            
            -- 刷新进度条
            self.m_progress:resetProgress()
            self.m_progress:update(time)
            
        	-- 更新关卡文本
        	local scale0 = cc.ScaleTo:create(0.2,0.0)
        	local callFunc = cc.CallFunc:create(function() 
                self.m_levelLabel:setString("第"..self.currentLevel.."关")
        	end)
        	local scale1 = cc.ScaleTo:create(0.1,1.0)
        	self.m_levelLabel:runAction(cc.Sequence:create(scale0,callFunc,scale1,nil))
        elseif result == "FAILURE" then
            -- 失败
            director:getScheduler():unscheduleScriptEntry(self.scheduleID)
            self.scheduleID = nil
            self.m_gameRun = false
            -- 进度条隐藏并重置
            self.m_progress:hideProgress()
            self.m_progress:resetProgress()
            -- 游戏结束
            local callFunc = cc.CallFunc:create(function() self:gameOver() end)
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.8),callFunc,nil))            
        end
    	
    	return true
    end
    
    -- 添加点击事件监听
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,layer)
    
    local function getProgressState()
        self:getProgressState()
    end

    -- 检测进度条是否读完
    self.scheduleID = director:getScheduler():scheduleScriptFunc(getProgressState,0,false)
    
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
    local listener_keyboard = cc.EventListenerKeyboard:create()
    listener_keyboard:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )

    local eventDispatcher_keyboard = layer:getEventDispatcher()
    eventDispatcher_keyboard:addEventListenerWithSceneGraphPriority(listener_keyboard, layer)
    
    return true
end

function ASGameScene:getProgressState()
    if self.m_progress.isUpdate == false then
        self.m_gameRun = false
        director:getScheduler():unscheduleScriptEntry(self.scheduleID)
        self.scheduleID = nil
        -- 游戏结束
        local callFunc = cc.CallFunc:create(function() self:gameOver() end)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.8),callFunc,nil)) 
    end
--    return 
end
-- 开始游戏
function ASGameScene:startGame()
    print("------开始游戏----------")
	self.m_levelLabel:setString("第1关")
    self.m_goldMatrix:resetGoldMatrix()
    self.m_goldMatrix:runAction(cc.ScaleTo:create(0.3,1))
    local function getProgressState()
        self:getProgressState()
    end
    -- 检测进度条是否读完
    self.scheduleID = director:getScheduler():scheduleScriptFunc(getProgressState,0,false)
    self.m_progress:resetProgress()
    self.m_progress:update(1)
    
    self.m_gameRun = true
end
-- 游戏结束
function ASGameScene:gameOver()
    local shop = require("scenes.ASShopScene")
    local shopScene = shop.create()
    director:pushScene(shopScene)
	print("游戏结束了")
    self.m_goldMatrix:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,0.0),cc.CallFunc:create(function()
        self.m_gameOverLayer:runAction(cc.ScaleTo:create(0.3,1))
        -- 当前得分
        local curScore = self.m_goldMatrix:getCurrentScore()
        -- 历史最高分
        local bestScore = cc.UserDefault:getInstance():getIntegerForKey(Key_BestScore,0)
        if curScore > bestScore then
        	-- 更新最高成绩
        	self.m_labelBestScore:setVisible(true)
        	self.m_labelBestScore:setString("最好成绩"..curScore.."枚")
        	-- 保存最好成绩
        	cc.UserDefault:getInstance():setIntegerForKey(Key_BestScore,curScore)
        	cc.UserDefault:getInstance():flush()
        end
        self.m_gameOverLayer:gameOverByScore(curScore,bestScore)
    end)))
end

return ASGameScene