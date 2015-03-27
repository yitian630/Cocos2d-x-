require "javaBridgeCenter"

SceneTestLayer2 = function()
    print("将要执行showDomobAds方法")
        require "javaBridgeCenter"
        showDomobAds()
    local ret = cc.Layer:create()
    local m_timeCounter = 0

--    local function onGoBack(tag, pSender)
--    cc.log("将要执行closeDomobAds方法")
--        require "javaBridgeCenter"
--        closeDomobAds()
--        cc.Director:getInstance():popScene()
--    end
--
--
--    local  item3 = cc.MenuItemFont:create( "Go Back")
--    item3:registerScriptTapHandler(onGoBack)
--    local  menu = cc.Menu:create(item3)
--    
--
--    ret:addChild( menu )

    return ret
end