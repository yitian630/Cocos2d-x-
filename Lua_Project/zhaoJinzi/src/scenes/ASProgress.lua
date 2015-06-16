local ASProgress = class("ASProgress", function()
	return cc.Sprite:create()
end)

ASProgress.__index = ASProgress

ASProgress.progress = nil       -- 进度条
ASProgress.isUpdate = nil       -- 是否正在更新

function ASProgress.create()
    local sprite = ASProgress.new()
	if nil ~= sprite then
		if sprite:init() ~= true then
			return nil
		end
	end
	
	return sprite
end

function ASProgress:init()
	-- 背景
	local proBg = cc.Sprite:create("progress_bg.png")
	self:addChild(proBg)
	-- 进度条
	local proFt = cc.Sprite:create("progress.png")
	self.progress = cc.ProgressTimer:create(proFt)
    self.progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.progress:setBarChangeRate(cc.p(1, 0))
    self.progress:setMidpoint(cc.p(0, 1))
	-- 设置百分比
    self.progress:setPercentage(100)	
    self:addChild(self.progress)
    
    -- 设置更新开关
    self.isUpdate = true
    
	return true
end

-- 更新进度条
function ASProgress:update(time)
    if self.isUpdate == false then
    	return
    end
	self:showProgress()
	local progressTo = cc.ProgressTo:create(time,0)
	local callFunc = cc.CallFunc:create(function()
        
        if self:getPercentage() <= 0 then
            -- 游戏结束
            print("--游戏结束,停止更新-----")
            -- 更新关闭
            self.isUpdate = false
            -- 停止所有动作
            self.progress:stopAllActions()
            -- 延时隐藏
            self:runAction(cc.Sequence:create(cc.Blink:create(0.8,3),cc.CallFunc:create(function() self:hideProgress()  end)))                          
        end
     end)
    self.progress:runAction(cc.RepeatForever:create(cc.Sequence:create(progressTo,callFunc,nil)))
end
-- 显示进度条
function ASProgress:showProgress()
	self:setVisible(true)
end
-- 隐藏进度条
function ASProgress:hideProgress()
	self:setVisible(false)    
end

-- 获取进度条当前百分比
function ASProgress:getPercentage()
	return self.progress:getPercentage()
end
-- 重置进度条
function ASProgress:resetProgress()
    self.isUpdate = true
    self.progress:stopAllActions()
    self.progress:setPercentage(100)
end
return ASProgress