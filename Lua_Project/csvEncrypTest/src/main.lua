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
    director:setDisplayStats(true)

    --set FPS. the default value is 1.0/60 if you don't call this
    director:setAnimationInterval(1.0 / 60)
    
    cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(640, 960, 4)
    
--  --------------------------------------
    -- csv文件加密 
    require("Csv")
    
    -- 路径为绝对路径,可以现在桌面建两个文件夹，把要加密的csv文件放在input里，运行即可
    local input = "/Users/sunfei/Desktop/input"
    local outpath = "/Users/sunfei/Desktop/output"
    
    -- 批量处理
    local lfs = require"lfs"
    function attrdir (path)
        for file in lfs.dir(path) do
            if file ~= "." and file ~= ".." then
                local f = path..'/'..file
                print(f)
                -- 加密所有csv文件,第一个参数要加密的文件，第二个输出路径，第三个加密签名（解密时要对应）
                encrypCsvFile(f,outpath,"csv")
                print("csv文件已加密")
            end
        end
    end
    
    attrdir (input)
    
--  -----------------------------------------

end


local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
