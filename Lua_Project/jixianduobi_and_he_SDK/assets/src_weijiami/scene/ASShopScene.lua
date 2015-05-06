--
-- ASShopScene 游戏结束场景
--
require("data.Csv")
local luaj = require("cocos.cocos2d.luaj")
local ASShopScene = class("ASShopScene", function()
    return cc.Scene:create()
end)

local director = cc.Director:getInstance()
local origin = director:getVisibleOrigin()
local size = director:getVisibleSize()
local buyItem = nil
local cell_bg = nil
local label_d = nil
local label_m = nil
ASShopScene.__index = ASShopScene

----------------------------------------------------
-- create - 创建对象
-- @param：void
-- @return：返回创建的对象
----------------------------------------------------
function ASShopScene.create()
    local scene = ASShopScene.new()
    if nil ~= scene then
        if scene:init() ~= true then
            return nil
        end
    end

    return scene
end

----------------------------------------------------
-- init - （auto-invoked）
-- @param：void
-- @return：bool类型，表示创建是否成功
----------------------------------------------------
function ASShopScene:init()
    local layer = cc.Layer:create()
    self:addChild(layer)
    -- 添加背景精灵
    local background = cc.Sprite:create("Images/img_endbg.png")
    background:setPosition(cc.p(size.width/2,size.height/2))
    layer:addChild(background)


    -- 返回游戏回调
    local function goBackHandler()
        --todo
        director:popScene()
    end

    -- 用于处理支付结果的函数
    local function callback(id)
        -- 购买成功回调，设置购买标签为true
        cc.UserDefault:getInstance():setBoolForKey("isBuy", true)
        -- 判断购买id
        if id == "001" then
            -- 10米
            cc.UserDefault:getInstance():setIntegerForKey("integer", 10)
        elseif id == "002" then
            -- 100米
            cc.UserDefault:getInstance():setIntegerForKey("integer", 100)
        elseif id == "003" then
            -- 200米
            cc.UserDefault:getInstance():setIntegerForKey("integer", 200)
        elseif id == "004" then
            -- 400米
            cc.UserDefault:getInstance():setIntegerForKey("integer", 400)
        elseif id == "005" then
            -- 500米
            cc.UserDefault:getInstance():setIntegerForKey("integer", 500)
        elseif id == "006" then
            -- 600米
            cc.UserDefault:getInstance():setIntegerForKey("integer", 600)
        elseif id == "007" then 
            -- 800米
            cc.UserDefault:getInstance():setIntegerForKey("integer", 800)
        elseif id == "008" then
            -- 1000米
            cc.UserDefault:getInstance():setIntegerForKey("integer", 1000)
        elseif id == "009" then
            -- 1500米 
            cc.UserDefault:getInstance():setIntegerForKey("integer", 1500)
        elseif id == "010" then
            -- 2000米
            cc.UserDefault:getInstance():setIntegerForKey("integer", 2000)
        end
    end
    
    local function getString(i)
        --todo
        if (i < 9) then
          return "00"..i
        else 
          return "0"..i
        end
    end

    local function buyHandler(tag)
        
        -- 参数
        local args = {
            getString(tag),
            callback
        }
        local className = "org/cocos2dx/lua/AppActivity"
        local method = "showBuyStatic"
        local sigs = "(Ljava/lang/String;I)V"
        local ok, ret = luaj.callStaticMethod(className, method, args, sigs)
        -- if not ok then
        --     print("luaj error:"..ret)
        -- else
        --     print("ret:"..ret) -- 输出 ret: 5
        --     cc.UserDefault:getInstance():setIntegerForKey("integer", ret)
        -- end
        ------------------
       
    end
   
    for i=1,11 do
        print(i)
        cell_bg = cc.Sprite:create("shopUI/cell_bg.png")
        cell_bg:setPosition(size.width/2,size.height/9*8-(i-1)*cell_bg:getBoundingBox().height)
        layer:addChild(cell_bg,0,i)
		
        if i<11 then
            --do
            -- 添加label
			label_d = cc.Label:createWithBMFont("fonts/ziti.fnt","10点")
    		label_d:setAnchorPoint(cc.p(0.5,0.5))
    		label_m = cc.Label:createWithBMFont("fonts/ziti.fnt","10米")
    		label_m:setAnchorPoint(cc.p(0.5,0.5))
        	label_d:setPosition(size.width/2-cell_bg:getBoundingBox().width/2+label_d:getBoundingBox().width,cell_bg:getPositionY())
        	layer:addChild(label_d)
        	label_m:setPosition(size.width/2,cell_bg:getPositionY())
        	layer:addChild(label_m)
            if i == 2 then
                label_d:setString("100点")
                label_m:setString("100米")
            elseif i == 3 then
                label_d:setString("200点")
                label_m:setString("200米")
            elseif i == 4 then
                label_d:setString("400点")
                label_m:setString("400米")
            elseif i == 5 then
                label_d:setString("500点")
                label_m:setString("500米")
            elseif i == 6 then
                label_d:setString("600点")
                label_m:setString("600米")
            elseif i == 7 then
                label_d:setString("800点")
                label_m:setString("800米")
            elseif i == 8 then
                label_d:setString("1000点")
                label_m:setString("1000米")
            elseif i == 9 then
                label_d:setString("1500点")
                label_m:setString("1500米")
            elseif i == 10 then
                label_d:setString("2000点")
                label_m:setString("2000米")
            end

            buyItem = cc.MenuItemImage:create("shopUI/buy.png","shopUI/buy_press.png")
            buyItem:setTag(i)
            buyItem:registerScriptTapHandler(buyHandler)
            local menu = cc.Menu:create(buyItem)
            menu:setPosition(size.width/2+cell_bg:getBoundingBox().width/2-buyItem:getBoundingBox().width/2,cell_bg:getPositionY())
            layer:addChild(menu)
        
        elseif i == 11 then
            --do
            local label = cc.Label:createWithBMFont("fonts/ziti.fnt","1元=100点")
            label:setPosition(size.width/2, cell_bg:getPositionY())
            layer:addChild(label)
        end
    end
   
    local goBack = cc.MenuItemImage:create("shopUI/back.png","shopUI/back_press.png")
    
    -- 注册回调
    goBack:registerScriptTapHandler(goBackHandler)
    local menu = cc.Menu:create(goBack)
    menu:setPosition(size.width/2, size.height/10)
    layer:addChild(menu)

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
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )

    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

    return true
end

return ASShopScene
