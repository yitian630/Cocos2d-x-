ASMusicPlayer = {}
ASMusicPlayer.__index = ASMusicPlayer
ASMusicPlayer._audioEngine = nil
local instance = nil

--create
function ASMusicPlayer:getInstance()
    if instance == nil then
    	instance = {}
    	setmetatable(instance,ASMusicPlayer)
    	self._audioEngine = cc.SimpleAudioEngine:getInstance()
    end
    
    return instance
end

function ASMusicPlayer:loadAllMusic()
	--local prePath = "res/effectMusic/"
	local allTheMusic = {
	button = "sound/button.wav",
	dead = "sound/effect_boom.mp3",
	overScene = "sound/ASFailMusic.mp3",
    buttonUnlock = "button_unlock.mp3"
	}
	
	for key, value in pairs(allTheMusic) do
		self._audioEngine:preloadEffect(cc.FileUtils:getInstance():fullPathForFilename(value))
	end
	
end


function ASMusicPlayer:currentPlayEffect(aEffectFileName,isLoop)
	

    local fileName = "res/sound/"..tostring(aEffectFileName)
    local path = cc.FileUtils:getInstance():fullPathForFilename(fileName)    
    local soundId = self._audioEngine:playEffect(path,isLoop)

    return soundId
end

--暂停
function ASMusicPlayer:pausePlayer(aSoundId)
    if aSoundId ~= "all" then
    	self._audioEngine:pauseEffect(aSoundId)
    else
        self._audioEngine:pauseAllEffects()  
    end
        
end

--恢复
function ASMusicPlayer:resumePlayer(aSoundId)
	if aSoundId ~= "all" then
		self._audioEngine:resumeEffect(aSoundId)
	else
	   self._audioEngine:resumeAllEffects()
	end
 
end

--关闭
function ASMusicPlayer:stopPlayer(aSoundId)
    if aSoundId ~= "all" then
    	self._audioEngine:stopEffect(aSoundId)
    else
        self._audioEngine:stopAllEffects()
    end
end

--设置声音音量
function ASMusicPlayer:setVolume(parameters)
	self._audioEngine:setEffectsVolume(parameters)
end


return ASMusicPlayer