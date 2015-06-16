local ASGoldCell = class("ASGoldCell", function ()
	return cc.Node:create()
end)

ASGoldCell.__index = ASGoldCell

ASGoldCell.m_cellSize = nil
ASGoldCell.m_goldHead = nil
ASGoldCell.m_goldLabel = nil

function ASGoldCell.create()
	local node = ASGoldCell.new()
	if nil ~= node then
		if node:init() ~= true then
			return nil
		end
	end
	
	return node
	
end

function ASGoldCell:init()
    self.m_cellSize = 0.0	
	-- 金子堆
	self.m_goldHead = cc.Sprite:create("bg_gold.png")
	self:addChild(self.m_goldHead)
	
	self.m_goldLabel = cc.Label:createWithSystemFont("","",20)
	self:addChild(self.m_goldLabel,0)
	
	return true
end

function ASGoldCell:setGoldAndSize(gold, size)
	self.m_cellSize = size

	-- 显示金子堆和文字
	self.m_goldHead:setScale(self.m_cellSize/96)
	self.m_goldLabel:setString((gold and "金") or "全")
	self.m_goldLabel:setSystemFontSize(self.m_cellSize*0.95)
end

function ASGoldCell:getCellSize()
	return self.m_cellSize
end

return ASGoldCell