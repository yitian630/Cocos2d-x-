
cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("res")

-- CC_USE_DEPRECATED_API = true
require "cocos.init"

-- cclog
local cclog = function(...)
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

    -- initialize director
    local director = cc.Director:getInstance()

    --turn on display FPS
    director:setDisplayStats(false)

    --set FPS. the default value is 1.0/60 if you don't call this
    director:setAnimationInterval(1.0 / 60)
    
    cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(640, 960, 4)
    
    -- 加载精灵帧缓存
    cc.SpriteFrameCache:getInstance():addSpriteFrames("Images/sprites.plist")

    require("global.ASGlobalClient")
    require("data.Csv")
    -- 设置第一次运行
    cc.UserDefault:getInstance():setBoolForKey("first_time",true)
    -- 判断黄色飞机是否解锁
    local distance = getDistance()-0
    print("distance ==== "..distance)
    if distance < 5000 then
    	-- 未解锁
    	print("未解锁")
    	cc.UserDefault:getInstance():setBoolForKey("isYellowUnlock",false)
    	-- 设置黄色未被选中
    	cc.UserDefault:getInstance():setBoolForKey("isYellowSelect",false)
    else
        -- 解锁
        print("解锁")
        cc.UserDefault:getInstance():setBoolForKey("isYellowUnlock",true)
    end
    local scene = require("scene.ASMainMenuScene")
    local gameScene = scene.create()
    
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(gameScene)
    else
        cc.Director:getInstance():runWithScene(gameScene)
    end

end


local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
