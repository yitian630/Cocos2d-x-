require "Cocos2d"
require "Cocos2dConstants"

-- cclog
cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    return msg
end

local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
    cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(640, 960, 4)
	cc.FileUtils:getInstance():addSearchResolutionsOrder("src");
	cc.FileUtils:getInstance():addSearchResolutionsOrder("res");
	local schedulerID = 0
    --support debug
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or 
       (cc.PLATFORM_OS_ANDROID == targetPlatform) or (cc.PLATFORM_OS_WINDOWS == targetPlatform) or
       (cc.PLATFORM_OS_MAC == targetPlatform) then
        cclog("result is ")
		--require('debugger')()
        
    end
    

    ---------------
    
    cc.Director:getInstance():setDisplayStats(false)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local visibleOrigin = cc.Director:getInstance():getVisibleOrigin()
    
    --创建刚打开的时候的场景
    local function turnOnSceneCreate()
    	local turnOnLayer = cc.Layer:create()
    	turnOnLayer._schedule_changeScene = nil
    	
    	--载入音频文件
    	local ASEffectPlayer = require("src/ASMusicPlayer")
        ASEffectPlayer:getInstance():loadAllMusic()
        
        --载入声音文件
        local ASMusicPlayer = require("src/ASBackGroundMusicPlayer")
        ASMusicPlayer:getInstance():loadAllMusic()
    	
        local colorLayer = cc.LayerColor:create(cc.c4b(130,181,150,221),visibleSize.width,visibleSize.height)
        colorLayer:setVisible(true)
        turnOnLayer:addChild(colorLayer,0)
        
        local tipas = cc.Label:createWithTTF("alpha 303","res/fonts/FZPWJW.TTF",64)
        tipas:setColor(cc.c3b(28,147,134))
        tipas:setPosition(visibleOrigin.x+visibleSize.width/2,visibleOrigin.y+visibleSize.height/2)
        turnOnLayer:addChild(tipas,1)
        
        
        --切换场景 响应函数
        local function changeScene()
            local backgroundLayer = require("src/ASBackgroundLayer")
            local beginLayer = require("src/ASBeginLayer")
            local scene = cc.Scene:create()
            scene:addChild(backgroundLayer.create())
            scene:addChild(beginLayer:create())
            if cc.Director:getInstance():getRunningScene() then
                cc.Director:getInstance():replaceScene(scene)
            else
                cc.Director:getInstance():runWithScene(scene)
            end
            
            
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(turnOnLayer._schedule_changeScene)

        end


        turnOnLayer._schedule_changeScene = cc.Director:getInstance():getScheduler():scheduleScriptFunc(changeScene,3,false)
    	
    	return turnOnLayer
    end
    
    local sceneGame = cc.Scene:create()

    sceneGame:addChild(turnOnSceneCreate())

    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(sceneGame)
    else
        cc.Director:getInstance():runWithScene(sceneGame)
    end
    
end


local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
