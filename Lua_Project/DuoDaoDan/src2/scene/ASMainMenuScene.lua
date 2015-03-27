-- ASMainMenuScene 主菜单场景

require("data.Csv")
local ASEffectPlayer = require("global.ASMusicPlayer")
local ASMusicPlayer = require("global.ASBackGroundMusicPlayer")
-- 获取加载场景对象
local ASLoadingScene = require("scene.ASLoadingScene")
-- 获取游戏场景对象
local ASMainGameScene = require("scene.ASMainGameScene")
-- 获取飞机场景对象
local ASSelectCraftScene = require("scene.ASSelectCraftScene")
-- 获取地图场景对象
local ASSelectMapScene = require("scene.ASSelectMapScene")
-- 获取商店场景对象
local ASMainShopScene = require("scene.ASMainShopScene")
-- 获取设置场景对象
local ASSetScene = require("scene.ASSetScene")
-- 音乐按钮
local musicSetItem = nil
-- 音效按钮
local soundSetItem = nil
-- 飞机LOGO
local currentCraft = nil
-- 开始游戏按钮
local startGameButton = nil
local ASMainMenuScene = class("ASMainMenuScene", function ()
    return cc.Scene:create()
end)

local director = cc.Director:getInstance()
local origin = director:getVisibleOrigin()
local size = director:getVisibleSize()

ASMainMenuScene.__index = ASMainMenuScene

-------------------------------------------
-- create - 创建对象
-- @param: void
-- @return: 返回创建的对象
-------------------------------------------
function ASMainMenuScene.create()   
    local scene = ASMainMenuScene.new()
    if nil ~= scene then
        if scene:init() ~= true then return nil end
    end

    return scene
end

-- 音效按钮回调
local function soundCallBack()
    ASEffectPlayer:getInstance():currentPlayEffect("button.wav",false)
    local soundValue = getEffect()-0

    local onImageNode = cc.MenuItemImage:create("Images/MenuImage/sound_effect_button_normal.png","Images/MenuImage/sound_effect_button_selected.png")
    local offImageNode = cc.MenuItemImage:create("Images/MenuImage/sound_effect_button_disabled.png","Images/MenuImage/sound_effect_button_selected.png")
    if soundValue == 1 then
--        print("音效关")
        -- 设置音量
        ASEffectPlayer:getInstance():setVolume(0)
        soundSetItem:setNormalImage(offImageNode)
        soundSetItem:setSelectedImage(offImageNode)
        saveSoundEffect(0)
    else
--        print("音效开")
        ASEffectPlayer:getInstance():setVolume(1)
        soundSetItem:setNormalImage(onImageNode)
        soundSetItem:setSelectedImage(onImageNode)
        saveSoundEffect(1)
    end
end

-- 音乐按钮回调
local function musicCallBack()
    ASEffectPlayer:getInstance():currentPlayEffect("button.wav",false)
    local musicValue = getMusic()-0
    local onImageNode = cc.MenuItemImage:create("Images/MenuImage/music_button_normal.png","Images/MenuImage/music_button_selected.png")
    local offImageNode = cc.MenuItemImage:create("Images/MenuImage/music_button_disabled.png","Images/MenuImage/music_button_selected.png")
    if musicValue == 1 then
--        print("音乐关")
        ASMusicPlayer:getInstance():setVolume(0)
        musicSetItem:setNormalImage(offImageNode)
        musicSetItem:setSelectedImage(offImageNode)
        saveMusic(0)
    else
--        print("音乐开")
        ASMusicPlayer:getInstance():setVolume(1)
        musicSetItem:setNormalImage(onImageNode)
        musicSetItem:setSelectedImage(onImageNode)
        saveMusic(1)
    end
end 

------------------------------------------
-- init - 初始化（auto-invoked）
-- @param: void
-- @return: bool类型，表示创建是否成功
------------------------------------------
function ASMainMenuScene:init()
--    print("init()")
    local layer = cc.Layer:create()
    self:addChild(layer, -100)

    -- 判断当前语言
    local currentLanguageType = cc.Application:getInstance():getCurrentLanguage()

    -- 添加背景精灵
    local background = cc.Sprite:create("Images/img_bg_logo.jpg")
    background:setPosition(cc.p(size.width/2,size.height/2))
    layer:addChild(background)

    -- 添加当前飞机展示
    if currentLanguageType == cc.LANGUAGE_CHINESE then
        currentCraft = cc.Sprite:create("Images/LOGO.png")
    else
        currentCraft = cc.Sprite:create("Images/LOGO_en.png")
    end

    currentCraft:setPosition(cc.p(size.width/2,size.height/7*5.2))
    layer:addChild(currentCraft)

    -- 点“开始游戏”事件回调
    function startGameHandler()
--        print("进入加载游戏场景")
        ASEffectPlayer:getInstance():currentPlayEffect("button.wav",false)
        local b = cc.UserDefault:getInstance():getBoolForKey("first_time")
        if b == true then
            local loadScene = ASLoadingScene.create()
            director:replaceScene(loadScene)       
        else
            local gameScene = ASMainGameScene.create()
            director:replaceScene(gameScene)
        end 
    end
    if currentLanguageType == cc.LANGUAGE_CHINESE then
        startGameButton = cc.MenuItemImage:create("Images/MenuImage/play_nor.png","Images/MenuImage/play_pre.png",nil)
    else
        startGameButton = cc.MenuItemImage:create("Images/MenuImage/play_nor_en.png","Images/MenuImage/play_pre_en.png",nil)
    end
    
    startGameButton:registerScriptTapHandler(startGameHandler)
    local startMenu = cc.Menu:create(startGameButton)
    startMenu:setPosition(cc.p(size.width/2,size.height/7*3))
    layer:addChild(startMenu)

    -- 创建音效菜单项
    local soundValue = getEffect()-0
    if soundValue == 1 then
        ASEffectPlayer:getInstance():setVolume(1)
        soundSetItem = cc.MenuItemImage:create("Images/MenuImage/sound_effect_button_normal.png","Images/MenuImage/sound_effect_button_selected.png")
    else  
        ASEffectPlayer:getInstance():setVolume(0)
        soundSetItem = cc.MenuItemImage:create("Images/MenuImage/sound_effect_button_disabled.png","Images/MenuImage/sound_effect_button_selected.png")
    end   
    soundSetItem:registerScriptTapHandler(soundCallBack)

    -- 创建音乐菜单项
    local musicValue = getMusic()-0
    if musicValue == 1 then
        ASMusicPlayer:getInstance():setVolume(1)
        musicSetItem = cc.MenuItemImage:create("Images/MenuImage/music_button_normal.png","Images/MenuImage/music_button_selected.png")
    else
        ASMusicPlayer:getInstance():setVolume(0)
        musicSetItem = cc.MenuItemImage:create("Images/MenuImage/music_button_disabled.png","Images/MenuImage/music_button_selected.png")            
    end   
    musicSetItem:registerScriptTapHandler(musicCallBack)

    -- 根据菜单项创建菜单
    local menus = cc.Menu:create(soundSetItem,musicSetItem)
    -- 菜单项横向排列
    menus:alignItemsHorizontallyWithPadding(size.width/4)
    -- 设置菜单位置
    menus:setPosition(cc.p(size.width/2,origin.y+size.height/5))

    layer:addChild(menus)

    -- 添加广告
   -- require("ASAdmLayer")
   -- local admLayer = SceneTestLayer2()
   -- layer:addChild(admLayer)

    return true
end

return ASMainMenuScene