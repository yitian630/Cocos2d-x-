-- local targetPlatform = cc.Application:getInstance():getTargetPlatform()

-- local luaj = nil

-- if (cc.PLATFORM_OS_ANDROID == targetPlatform) then

-- 	luaj = require "luaj"
-- end

local luaj = require "luaj"

function showDomobAds()
	-- body
	print("showDomobAds 方法执行")
	

		local args ={}
		local sig = "(IF)V"
		local className = "org/cocos2dx/lua/AppActivity"
        local ok, ret = luaj.callStaticMethod(className,"showBannerStatic",args,sigs)
     
       

		if not ok then
    		print("luaj error:", ret)
		else
   			print("ret:", ret) -- 输出 ret: 5
		end
    print("luaj 方法执行")
    
end

function closeDomobAds()
	-- body
	print("closeDomobAds 方法执行")
	

		local args ={}
		local sig = "(IF)V"
		local className = "org/cocos2dx/lua/AppActivity"
        local ok, ret = luaj.callStaticMethod(className,"closeBannerStatic",args,sigs)
            

		if not ok then
    		print("luaj error:", ret)
		else
   			print("ret:", ret) -- 输出 ret: 5
		end
    print("luaj 方法执行")
    
end