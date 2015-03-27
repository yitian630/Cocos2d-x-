require("Cocos2d")
require("Cocos2dConstants")
require("src/Csv")
local ASMusicsPlayer  = require("src/ASBackGroundMusicPlayer")
local ASEffectPlayer = require("src/ASMusicPlayer")
local ASSoundSet = require("src/ASSoundSet")
local ASGameScene = require("src/ASGameScene")

local ASBeginLayer = class("ASBeginLayer",function()
	return cc.Layer:create()
end)

ASBeginLayer._index = ASBeginLayer
ASBeginLayer._gameSceneLayer = nil --主游戏场景
ASBeginLayer._theMaxCount = 0  --最大分数
local settingItem = nil   --音效设置的菜单项
local musicSetItem = nil  --背景音乐设置按钮

cc.FileUtils:getInstance():addSearchResolutionsOrder("src");
cc.FileUtils:getInstance():addSearchResolutionsOrder("res/begin");

local visibleOrigin = cc.Director:getInstance():getVisibleOrigin()
local visibleSize = cc.Director:getInstance():getVisibleSize()

------游戏开始回调函数-----------
local function gameBegin(...)
    ASEffectPlayer:getInstance():currentPlayEffect("button.wav",false)
    cc.Director:getInstance():replaceScene(ASGameScene.create())
    
end

---------音效的回调函数------------
local function effectSetting()
    ASEffectPlayer:getInstance():currentPlayEffect("button.wav",false)
    local soundValue = getEffect() -0
    local onImageNode = cc.MenuItemImage:create("res/begin/voice.png","res/begin/voice_no.png")
    local offImageNode = cc.MenuItemImage:create("res/begin/voice_no.png","res/begin/voice.png")
    
    if soundValue == 1 then
        ASEffectPlayer:getInstance():setVolume(0)
        settingItem:setNormalImage(offImageNode)
        settingItem:setSelectedImage(offImageNode)
        saveSoundEffect(0)  --记录到文件
    else
        ASEffectPlayer:getInstance():setVolume(1)
        settingItem:setNormalImage(onImageNode)
        settingItem:setSelectedImage(onImageNode)
        saveSoundEffect(1)  --记录到文件
    end
    
end

------------音乐回调-------------
local function musicSetting()
    ASEffectPlayer:getInstance():currentPlayEffect("button.wav",false)
    local musicValue = getMusic() -0
    local onImageNode = cc.MenuItemImage:create("res/begin/win_music.png","res/begin/win_music_no.png")
    local offImageNode = cc.MenuItemImage:create("res/begin/win_music_no.png","res/begin/win_music.png")

    if musicValue == 1 then
        ASMusicsPlayer:getInstance():setVolume(0)
        musicSetItem:setNormalImage(offImageNode)
        musicSetItem:setSelectedImage(offImageNode)
        saveMusic(0)  --记录到文件
    else
        ASMusicsPlayer:getInstance():setVolume(1)
        musicSetItem:setNormalImage(onImageNode)
        musicSetItem:setSelectedImage(onImageNode)
        saveMusic(1)  --记录到文件
    end
end

-------------------------------
--开始界面的create函数
-------------------------------
function ASBeginLayer:create()
    local beginLayer = ASBeginLayer.new()
    if beginLayer then
        beginLayer:init()
    end
	
	return beginLayer
end


--------------------------------
--游戏开始界面的初始化函数
--------------------------------
function ASBeginLayer:init()
  
    
 --添加广告
--    require "src/ASAdmLayer"
--    local admLayer = SceneTestLayer2()
--    self:addChild(admLayer,10)
    
    --添加小鸟
    
    --引入plist文件
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/GameScenePic/bird.plist")
    local levelNumber = getLevel()-0
    local aBird = cc.Sprite:createWithSpriteFrameName("bird1_level"..levelNumber..".png")
    aBird:setScale(1.5,1.5)
    aBird:setPosition(visibleOrigin.x+visibleSize.width/2,visibleOrigin.y+visibleSize.height/3*2)
    self:addChild(aBird,1)
    
    --游戏开始菜单项
    
    
    local gameBeginItem = cc.MenuItemImage:create("res/begin/play_off.png","res/begin/play_on.png")
    gameBeginItem:setScale(0.7,0.7)
    gameBeginItem:registerScriptTapHandler(gameBegin)
    gameBeginItem:setPosition(visibleOrigin.x+visibleSize.width/2,visibleOrigin.y+visibleSize.height/5*2)
      
      
    --获取当前音效值
    local soundValue = getEffect() -0
    ASEffectPlayer:getInstance():setVolume(soundValue)
    
    --根据音效值选择菜单图片    
    if soundValue == 1 then
        settingItem = cc.MenuItemImage:create("res/begin/voice.png","res/begin/voice_no.png")
    else
        settingItem = cc.MenuItemImage:create("res/begin/voice_no.png","res/begin/voice.png")
    end
    
    
    --音效设置
    settingItem:setScale(0.6)
    settingItem:registerScriptTapHandler(effectSetting)
    settingItem:setPosition(visibleOrigin.x+visibleSize.width/5,visibleOrigin.x+visibleSize.height/4)
   
   --音乐设置
    local musicValue = getMusic()-0
    ASMusicsPlayer:getInstance():setVolume(musicValue)
    
    if musicValue == 1 then
    	musicSetItem = cc.MenuItemImage:create("res/begin/win_music.png","res/begin/win_music_no.png")
    else
        musicSetItem = cc.MenuItemImage:create("res/begin/win_music_no.png","res/begin/win_music.png")
    end
    
    musicSetItem:setScale(0.6)
    musicSetItem:registerScriptTapHandler(musicSetting)
    musicSetItem:setPosition(visibleOrigin.x+visibleSize.width/5*4,visibleOrigin.y+visibleSize.height/4)
    
    --编写菜单
    local menu = cc.Menu:create(gameBeginItem,settingItem,musicSetItem)
    
    
    menu:setPosition(0,0)
    self:addChild(menu,3)  
    
end

return ASBeginLayer