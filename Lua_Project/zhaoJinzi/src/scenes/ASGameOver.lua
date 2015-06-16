local ASGameOver = class("ASGameOver", function ()
	return cc.Layer:create()
end)

local director = cc.Director:getInstance()
local origin = director:getVisibleOrigin()
local size = director:getVisibleSize()

ASGameOver.__index = ASGameOver
ASGameOver.m_labelTitle = nil   -- 成绩结果显示
ASGameOver.m_labelScoreInfo = nil -- 分数信息
ASGameOver.m_restartItem = nil    -- 重新开始按钮

function ASGameOver.create()
	local layer = ASGameOver.new()
	if nil ~= layer then
		if layer:init() ~= true then
			return false
		end
	end
	
	return layer
end

function ASGameOver:init()
	-- 背景
	local bg = cc.Sprite:create("bg_gold.png")
	bg:setScale(4,3)
	bg:setPosition(size.width/2,size.height/2)
	self:addChild(bg)
	-- 成绩展示
	self.m_labelTitle = cc.Label:createWithSystemFont("游戏结束了","",45)
	self.m_labelTitle:setPosition(size.width/2,size.height/2+100)
	self:addChild(self.m_labelTitle)
	self.m_labelScoreInfo = cc.Label:createWithSystemFont("","",36)
    self.m_labelScoreInfo:setPosition(size.width/2,size.height/2+20)
    self:addChild(self.m_labelScoreInfo)
    
    -- 重新开始
    local function restartGame()
        self:runAction(cc.ScaleTo:create(0.3,0.0))
        self:getParent():startGame()
    end
    local labelRestart = cc.Label:createWithSystemFont("再来一次","",50)
    self.m_restartItem = cc.MenuItemLabel:create(labelRestart)
    -- 不断缩放
    self.m_restartItem:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(1.0,0.9),cc.ScaleTo:create(1.0,1.1),nil)))
    self.m_restartItem:registerScriptTapHandler(restartGame)
    local menu = cc.Menu:create(self.m_restartItem)
    menu:setPosition(size.width/2,size.height/2-70)
    self:addChild(menu)
	
	return true
end

function ASGameOver:gameOverByScore(curScore,bestScore)
    -- 不断缩放
    self.m_restartItem:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(1.0,0.9),cc.ScaleTo:create(1.0,1.1),nil)))
	if bestScore > 0 then
		if curScore > bestScore then
			self.m_labelTitle:setString("恭喜您破记录了")
			self.m_labelTitle:runAction(cc.Blink:create(1,8))
		else
		    self.m_labelTitle:setString("您未破纪录")
		    self.m_labelTitle:runAction(cc.Blink:create(1,4))
		end
		self.m_labelScoreInfo:setString("您的历史纪录是"..bestScore.."枚")
	else
	    if curScore > 0 then
	    	self.m_labelTitle:setString("您有新成绩了")
	    	self.m_labelTitle:runAction(cc.Blink:create(1,8))
	    	self.m_labelScoreInfo:setString("这次捡了"..curScore.."枚金币")
	    else
	        self.m_labelTitle:setString("您点错了")
            self.m_labelTitle:runAction(cc.Blink:create(1,8))
            self.m_labelScoreInfo:setString("这次一枚金币也没捡到")
	    end
	end
end

return ASGameOver