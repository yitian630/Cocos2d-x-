require "Cocos2d"
require "Cocos2dConstants"
require("src/Csv")
local ASTipLayer = require("src/ASTipLayer")
local ASEffectPlayer =require("src/ASMusicPlayer")
local EndBg = class("EndBg" , function()
    return cc.Layer:create()
end)

EndBg.__index = EndBg
EndBg._replayBtn = nil

cc.FileUtils:getInstance():addSearchResolutionsOrder("src")
cc.FileUtils:getInstance():addSearchResolutionsOrder("res")
cc.FileUtils:getInstance():addSearchResolutionsOrder("res/EndScene")
local visibleSize = cc.Director:getInstance():getVisibleSize()
local origin = cc.Director:getInstance():getVisibleOrigin()

--分数label
local goldLabel  = nil --金币数
local goldNeedLabel = nil    --升级所需金币数
local isBreakRecord = 0 --判断是否打破记录 1是 0否
local thePastBestGrade = 0 --记录之前的最高分

local currentBirdTag = 11
local nextBirdTag = 12
local updataMoneyTag = 13
local recordBreakTag = 222

--添加小鸟图集
local allBirds = cc.SpriteFrameCache:getInstance():addSpriteFrames("res/GameScenePic/bird.plist")

--得到金币数
local function GoldLabel() 
    --读取csv中金币数并显示
    
    --        saveGold(33333)
    local  tempGold=getGold()
    --        local tempGold=121
    goldLabel = cc.Label:createWithTTF(tempGold,"res/fonts/FZPWJW.TTF",48)
    goldLabel:setAnchorPoint(0,0.5)
    goldLabel:setPosition(visibleSize.width*0.53,visibleSize.height*0.96)
    return goldLabel
end

--破纪录提示
local function getRecordBreakLabel()
    local reCordBreakLabel = cc.Label:createWithTTF("great!","res/fonts/FZPWJW.TTF",42)
    reCordBreakLabel:setScale(7)
    reCordBreakLabel:setColor(cc.c3b(255,0,0))
    reCordBreakLabel:setPosition(cc.p(visibleSize.width/3,visibleSize.height*0.7))
        
    --缩放动作
    local labelScale = cc.ScaleTo:create(0.5,1.1)
    
    --动画
    local reCordBreakLabelMoveDown = cc.EaseExponentialIn:create(labelScale)
    reCordBreakLabel:runAction(reCordBreakLabelMoveDown)
    reCordBreakLabel:runAction(cc.RotateBy:create(0.5,-45))
    
    --淡出效果
--    local fadeOut = cc.FadeOut:create(3)
--    reCordBreakLabel:runAction(fadeOut)
    
    return reCordBreakLabel
    
end

--最高分
local function GradeLabel() 
   
    --        saveGrade(333333333)
    local  tempGrade=getGrade()
    
    --       local tempGrade = 1
    local gradeLabel = cc.Label:createWithTTF("最高成绩: "..tempGrade,"res/fonts/FZPWJW.TTF",64)
    gradeLabel:setColor(cc.c3b(255,255,0))
    gradeLabel:setAnchorPoint(0,0.5)
    gradeLabel:setPosition(visibleSize.width/4,visibleSize.height*0.74)
    return gradeLabel
end

--当前分数
local function currentGradeLabel() 

    --        saveGrade(333333333)
    --local  tempGrade=getGrade()
    --       local tempGrade = 1
    local gradeLabel = cc.Label:createWithTTF("本次成绩: "..getCurrentGrade(),"res/fonts/FZPWJW.TTF",64)
    gradeLabel:setAnchorPoint(0,0.5)
    gradeLabel:setPosition(visibleSize.width/4,visibleSize.height*0.84)
    return gradeLabel
end

--添加当前等级的小鸟
local function currentLevelBird()
    local currentLevel = getLevel() -0
    local bird = cc.Sprite:createWithSpriteFrameName("bird1_level"..currentLevel..".png")
    bird:setPosition(visibleSize.width/5,visibleSize.height*0.6)
    bird:setScale(1.3,1.3)
    return bird   
end

--下个等级的鸟
local function nextLevelBird()
	local nextLevel = getLevel() + 1
	if nextLevel>5 then
		nextLevel = nextLevel -1
	end
	
	local bird = cc.Sprite:createWithSpriteFrameName("bird1_level"..nextLevel..".png")
	bird:setPosition(visibleSize.width/5*4,visibleSize.height*0.6)
	bird:setScale(1.3,1.3)
	bird:setColor(cc.c3b(0,0,0))
	
	return bird
end


--本次升级需要的金币数
--local function updataMoney()
--	local currentLevel = getLevel()-0
--	if currentLevel == 5 then
--		currentLevel = currentLevel -1
--	end
--    local goldNeed = getNextLevelGold(currentLevel+1)
--    goldNeedLabel = cc.Label:createWithTTF("need"..goldNeed,"res/fonts/Marker Felt.ttf",50)
--    goldNeedLabel:setPosition(visibleSize.width/2,visibleSize.height*0.6)
--    
--    return goldNeedLabel
--end

--升级提示箭头
local function upDirection()
    local upTip = cc.Sprite:create("res/EndScene/update_arrow.png")
    upTip:setScale(2,1.5)
    upTip:setPosition(visibleSize.width/2,visibleSize.height*0.6)
    
    return upTip
end

--create函数
function EndBg.create()
    local mainMenu = EndBg.new()
    if mainMenu then
        mainMenu:init() 
    end
    return mainMenu
end

--init函数
function EndBg:init( )

    --判断是否打破了记录 OS操作会导致卡顿所以提前计算
    local theCurrentGrade = getCurrentGrade()+0
    if getGrade()+0<theCurrentGrade then
    	isBreakRecord = 1
    	saveGrade(theCurrentGrade)  --如果打破纪录了the修改最高分
    	theCurrentGrade = 0
    end
    
     
  -- 重新开始  
    local function RePlayBegin()
        ASEffectPlayer:getInstance():currentPlayEffect("button.wav",false)
        --replay结束界面    
        local ASLayer = nil
        ASLayer = require("src/ASBeginLayer")
        local sceneGame = cc.Scene:create()
        sceneGame:addChild(require("src/ASBackgroundLayer").create())
        sceneGame:addChild(ASLayer.create())
   
        local trans = cc.TransitionFade:create(1.2,sceneGame,cc.c3b(100,200,255))
        cc.Director:getInstance():replaceScene(sceneGame)
     end
       
     --重玩儿
     local function createrePlayBegin()
           local replayBtnNew= cc.MenuItemImage:create("replay.png","res/EndScene/replay_pressed.png")
                  replayBtnNew:setPosition(0,0)
               replayBtnNew:registerScriptTapHandler(RePlayBegin)
--               RePlayBegin()
              self._replyBtn = cc.Menu:create(replayBtnNew)
--               self._replyBtn:addTouchEventListener(rightCallBack)
           self._replyBtn:setPosition(visibleSize.width/2,visibleSize.height/4)
         return self._replyBtn
     end
     
    ---顶部金币X金币数
    local XLabel= cc.Label:createWithTTF("x","res/fonts/FZPWJW.TTF",48)
    XLabel:setAnchorPoint(0.5,0.5)
    XLabel:setPosition(visibleSize.width*0.49,visibleSize.height*0.965)
    self:addChild(XLabel,10)

    local goldSprite = cc.Sprite:create("res/GameScenePic/win_gold.png")
    goldSprite:setPosition(visibleSize.width*0.42,visibleSize.height*0.96)
    self:addChild(goldSprite,10)
--    --检测输出 
--    local gradeLabel = cc.Label:createWithBMFont("res/fonts/font.fnt","x")--createWithTTF(getGold(),"res/fonts/Marker Felt.ttf",60)
--    gradeLabel:setPosition(visibleSize.width/2,visibleSize.height/3*2)
--    self:addChild(gradeLabel,3)
--    
--    --检测输出
--    local goldLabel = cc.Label:createWithTTF(getNextLevelGold(getLevel()+1),"res/fonts/Marker Felt.ttf",60)
--    goldLabel:setPosition(visibleSize.width/2+150,visibleSize.height/3*2)
--    self:addChild(goldLabel,3)
--    
--    --监测输出
--    local levelLabel = cc.Label:createWithTTF(getLevel(),"res/fonts/Marker Felt.ttf",60)
--    levelLabel:setPosition(visibleSize.width/2-150,visibleSize.height/3*2)
--    self:addChild(levelLabel,3)

    --得到当前等级
   local function getPresentLevel()
        local presentLevel = getLevel() + 0
        if presentLevel == 5 then   --防止超出最大溢出
           presentLevel = presentLevel - 1
        end 
        return presentLevel
   end
    
    --得到本次升级需要的金币数
    local function getNextLevelMoneyNeed()
        return getNextLevelGold(getPresentLevel()+1) -0
    end
    
    --每次升级需要金币提示label
    local updateMoneyLabel = cc.Label:createWithTTF(getNextLevelMoneyNeed(),"res/fonts/FZPWJW.TTF",32)
    updateMoneyLabel:setColor(cc.c3b(28,147,134))
    updateMoneyLabel:setPosition(visibleSize.width*0.43,visibleSize.height*0.6)
    self:addChild(updateMoneyLabel,3)
    
    --添加金币图案、“X”
--    local updateGoldSprite = cc.Sprite:create("res/GameScenePic/win_gold.png")
--    updateGoldSprite:setPosition(visibleSize.width*0.44,visibleSize.height*0.68)
--    self:addChild(updateGoldSprite,3)
    
--    local update_X = cc.Label:createWithBMFont("res/fonts/font.fnt","x")
--    update_X:setScale(0.9)
--    update_X:setPosition(visibleSize.width/2,visibleSize.height*0.69)
--    self:addChild(update_X,3)
    
    --升级按钮监听事件
    local function touchEvent(sender,TouchEventType)
        if TouchEventType == ccui.TouchEventType.ended then
            ASEffectPlayer:getInstance():currentPlayEffect("button.wav",false)
            
            local presentLevel = getPresentLevel()
            local nextLevelMoneyNeed = getNextLevelMoneyNeed()
            --总的金币数
            local presentGold = getGold()-0
            
            --剩余金币数
            local theRestMoney = presentGold - nextLevelMoneyNeed
            
            if theRestMoney>=0 then
                ASEffectPlayer:getInstance():currentPlayEffect("loseGold.mp3",false)
                saveLevel(presentLevel+1)
                saveGold(theRestMoney)
                
                --其他设置
                goldLabel:setString(getGold())
                updateMoneyLabel:setString(getNextLevelMoneyNeed())
                self:removeChildByTag(currentBirdTag,true)
                self:removeChildByTag(nextBirdTag,true)
                --self:removeChildByTag(updataMoneyTag,true)
                
                self:addChild(currentLevelBird(),3,currentBirdTag)
                self:addChild(nextLevelBird(),3,nextBirdTag)
                --self:addChild(updataMoney(),3,updataMoneyTag)
            else
                
                --余额不足，提示
                self:addChild(ASTipLayer.create(),10)                
            end
        end
        
    end 
    
    --升级按钮
    local upDateButton = ccui.Button:create()
    upDateButton:setTouchEnabled(true)
    upDateButton:loadTextures("res/EndScene/update.png","res/EndScene/update_pressed.png","")
    upDateButton:setPosition(origin.x+visibleSize.width/2,origin.y+visibleSize.height*0.4)
    upDateButton:addTouchEventListener(touchEvent)
    upDateButton:setTag(112)
    self:addChild(upDateButton,5)
    
    --添加破纪录提示
    if isBreakRecord ==1  then
    	self:addChild(getRecordBreakLabel(),5,recordBreakTag)
    	isBreakRecord = 0
    end
    
    self:addChild(createrePlayBegin(),3)
    self:addChild(GoldLabel(),3)
    self:addChild(GradeLabel(),3)
    self:addChild(currentGradeLabel(),3)
    self:addChild(currentLevelBird(),3,currentBirdTag)
    self:addChild(nextLevelBird(),3,nextBirdTag)
    self:addChild(upDirection(),3,updataMoneyTag)

end


      
return EndBg