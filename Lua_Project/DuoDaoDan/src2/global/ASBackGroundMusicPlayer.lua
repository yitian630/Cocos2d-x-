ASBackgroundMusicPlayer = {}
ASBackgroundMusicPlayer.__index = ASBackgroundMusicPlayer
ASBackgroundMusicPlayer._audioEngine = nil
ASBackgroundMusicPlayer._bgMusicPath = nil 
local instance = nil -- 设置单例

--单例设置
function ASBackgroundMusicPlayer:getInstance()
    if instance == nil then
    	instance = {}
    	setmetatable(instance,ASBackgroundMusicPlayer)
        self._audioEngine = cc.SimpleAudioEngine:getInstance()
    end
    
    return instance
end

--销毁单例
function ASBackgroundMusicPlayer:destoryInstance()
	instance = nil
end

--载入资源
function ASBackgroundMusicPlayer:loadAllMusic()
	local MUSIC_PREFIX = "res/sound/"
	local MUSIC_TABLE = {
        fightLayerMusic1 = MUSIC_PREFIX.."AS2BGMusic.mp3",
        fightLayerMusic2 = MUSIC_PREFIX.."AS3BGMusic.mp3",
	}
	
    self._audioEngine:preloadMusic(cc.FileUtils:getInstance():fullPathForFilename(MUSIC_TABLE.fightLayerMusic1))
    self._audioEngine:preloadMusic(cc.FileUtils:getInstance():fullPathForFilename(MUSIC_TABLE.fightLayerMusic2))
end


--播放音乐
function ASBackgroundMusicPlayer:playBgMusic(aMusicName,isPlayedLoop)
    local fileName = "res/sound/"..tostring(aMusicName)
    local path = cc.FileUtils:getInstance():fullPathForFilename(fileName)
    local musicId = self._audioEngine:playMusic(path, isPlayedLoop)
    
    return musicId
end

--停止音乐
function ASBackgroundMusicPlayer:stopCustemMusic()
	self._audioEngine:stopMusic()
end

--设置音量
function ASBackgroundMusicPlayer:setVolume(parameters)
    self._audioEngine:setMusicVolume(parameters)
end

return ASBackgroundMusicPlayer