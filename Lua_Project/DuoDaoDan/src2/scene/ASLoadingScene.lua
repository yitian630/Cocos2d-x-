--
-- ASLoadingScene 加载游戏场景（过渡场景，显示游戏帮助）
--

local ASMusicPlayer = require("global.ASBackGroundMusicPlayer")
local ASMainGameScene = require("scene.ASMainGameScene")

local ASLoadingScene = class("ASLoadingScene", function ()
    return cc.Scene:create()
end)

local director = cc.Director:getInstance()
local size = director:getVisibleSize()

ASLoadingScene.__index = ASLoadingScene
ASLoadingScene._scheduleID = nil
ASLoadingScene._loadScheduID = nil
-----------------------------------------------------------
-- create - 创建对象
-- @param：void
-- @return：返回创建对象
-----------------------------------------------------------
function ASLoadingScene.create()
    local scene = ASLoadingScene.new()
    if nil ~= scene then
        if scene:init() ~= true then
            return nil
        end
    end

    return scene
end

------------------------------------------------------------
-- init -初始化（auto-invoked）
-- @param：void
-- @return：bool类型，表示创建是否成功
------------------------------------------------------------
function ASLoadingScene:init()
    local layer = cc.LayerColor:create(cc.c3b(0,0,0), size.width, size.height)
    self:addChild(layer)

    local label = cc.Label:createWithBMFont("fonts/ziti.fnt","Loading")
    label:setScale(1.5)
    layer:addChild(label)
    label:setPosition(cc.p(size.width/2,size.height/2))

    -- label做动画
    count = 1
    function loadFunc()
        if count % 5 == 1 then
            label:setString("Loading")
        elseif count % 5 == 2 then
            label:setString("Loading.")
        elseif count % 5 == 3 then
            label:setString("Loading..")
        elseif count % 5 == 4 then
            label:setString("Loading...")
        end
        count = count + 1
        if count == 5 then 
            count = 1
        end
    end

    self._loadScheduID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(loadFunc, 0.2, false)

    -- 2秒后自动调用
    function jumpScene()
--        print("进入游戏主场景")    
        -- 判断是否选择黄色飞机
        local isYellowSelect = cc.UserDefault:getInstance():getBoolForKey("isYellowSelect")    
        --添加背景音乐
        if isYellowSelect == true then
            ASMusicPlayer:getInstance():playBgMusic("AS2BGMusic.mp3",true)
        else
            ASMusicPlayer:getInstance():playBgMusic("AS3BGMusic.mp3",true)
        end  
        local gameScene = ASMainGameScene.create()
        director:replaceScene(gameScene)
        -- 跳转场景的同时停止调度器
        director:getScheduler():unscheduleScriptEntry(self._scheduleID)
        director:getScheduler():unscheduleScriptEntry(self._loadScheduID)
    end
    self._scheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(jumpScene, 2.0, false)

    return true
end

return ASLoadingScene
