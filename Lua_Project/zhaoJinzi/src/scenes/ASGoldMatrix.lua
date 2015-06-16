local ASGoldCell = require("scenes.ASGoldCell")

local ASGoldMatrix = class("ASGoldMatrix",function ()
	return cc.Node:create()
end)

ASGoldMatrix.__index = ASGoldMatrix

ASGoldMatrix.Result = {
    Result_Success = "SUCCESS",   --成功
    Result_DontObtain = "DONTOBTAIN",    --没捡到
    Result_Failure = "FAILURE",       --失败
    Result_Invalid = "INVALID"        --无效
}

ASGoldMatrix.m_level = nil
ASGoldMatrix.m_canObtain = nil
ASGoldMatrix.MATRIX_SIZE = 400
ASGoldMatrix.MAX_SIZE = 7
ASGoldMatrix.m_gold = nil

ASGoldMatrix.m_goldCell = {{"1","2","3","4","5","6","7"},
                            {"1","2","3","4","5","6","7"},
                            {"1","2","3","4","5","6","7"},
                            {"1","2","3","4","5","6","7"},
                            {"1","2","3","4","5","6","7"},
                            {"1","2","3","4","5","6","7"},
                            {"1","2","3","4","5","6","7"}}


function ASGoldMatrix.create()
	local node = ASGoldMatrix.new()
	if nil ~= node then
		if node:init() ~= true then
			return nil
		end
	end
	
	return node
end

function ASGoldMatrix:init()
	-- 金子单元矩阵
	for r=1, self.MAX_SIZE do
		for c=1, self.MAX_SIZE do
            self.m_goldCell[r][c] = ASGoldCell.create()
            self:addChild(self.m_goldCell[r][c])
			-- 暂时不显示
            self.m_goldCell[r][c]:setVisible(false)
		end
	end
	self.m_canObtain = true
	-- 重置金子单元矩阵
	self:resetGoldMatrix()
	
	return true
end
-- 重置金子单元矩阵
function ASGoldMatrix:resetGoldMatrix()
	self.m_level = 1
	-- 显示金子单元矩阵
	self:showGoldMatrix()
end

-- 获取金子单元显示密度
function ASGoldMatrix:getMatrixSizeShow()
	-- 根据关卡计算金子单元显示密度
	local matrixSize_Show = 0
	local levelSum = 0
    for size=2, self.MAX_SIZE do
		if self.m_level > levelSum and self.m_level <= levelSum+size then
			matrixSize_Show = size
			break
		end
		levelSum = levelSum + size
	end
	if matrixSize_Show < 2 then
		matrixSize_Show = self.MAX_SIZE
	end
	
	return matrixSize_Show
end
-- 显示金子单元矩阵
function ASGoldMatrix:showGoldMatrix()
	-- 开始动画不能点
	self.m_canObtain = false
	-- 获取金子单元显示密度
	local matrixSize_Show = self:getMatrixSizeShow()
	print("matrixSize_Show = "..matrixSize_Show)
	-- 随机生成金子坐标
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    local rGold = math.random(1,matrixSize_Show)
    local cGold = math.random(1,matrixSize_Show)
    print("rGold = "..rGold)
    local goldSize = self.MATRIX_SIZE/matrixSize_Show
    local callFunc = cc.CallFunc:create(function() self.m_canObtain = true end)
    -- 显示金子单元
    for r=1, self.MAX_SIZE do
    	for c=1, self.MAX_SIZE do
    		if r <= matrixSize_Show and c <= matrixSize_Show then
                self.m_goldCell[r][c]:setVisible(true)
    			local pos = cc.p(-self.MATRIX_SIZE/2+r*goldSize-goldSize/2,
                    -self.MATRIX_SIZE/2+c*goldSize-goldSize/2)
                self.m_goldCell[r][c]:setPosition(pos)
                self.m_goldCell[r][c]:setVisible(true)
                self.m_goldCell[r][c]:setGoldAndSize(r==rGold and c == cGold,self.MATRIX_SIZE/matrixSize_Show)
    		    -- 动画显示
    		    local scale1 = cc.ScaleTo:create(0.1,1.0)
    		    if callFunc ~= nil then
    		    	self.m_goldCell[r][c]:runAction(cc.Sequence:create(scale1,callFunc,nil))
    		    else
                    self.m_goldCell[r][c]:runAction(scale1) 
    		    end
    	    else
                self.m_goldCell[r][c]:setVisible(false)
    		end
    	end
    end
    self.m_gold = self.m_goldCell[rGold][cGold]
end
-- 隐藏金子矩阵
function ASGoldMatrix:hideGoldMatrix()
	-- 开始动画不能点
	self.m_canObtain = false
	-- 遍历金子单元，把显示的缩小
	for r=1, self.MAX_SIZE do
		for c=1, self.MAX_SIZE do
		    -- 未显示的不往下遍历了
			if self.m_goldCell[r][c]:isVisible() == false then
				break
			end
			-- 动画隐藏
            local scale0 = cc.ScaleTo:create(0.1,0.0)
            self.m_goldCell[r][c]:runAction(scale0)
		end
	end
end

-- 返回点击结果
function ASGoldMatrix:getObtainResult(p)
	if self.m_canObtain == false then
        return self.Result.Result_DontObtain
	end
	-- 遍历查看点到哪个金子单元了
	for r=1, self.MAX_SIZE do
		for c=1, self.MAX_SIZE do
			-- 未显示的不往下遍历了
			if self.m_goldCell[r][c]:isVisible() == false then
				break
			end
			-- 计算金子单元矩阵
            local _posX = self.m_goldCell[r][c]:getPositionX()
            local _posY = self.m_goldCell[r][c]:getPositionY()
            local _size = self.m_goldCell[r][c]:getCellSize()
            local rect = cc.rect(_posX-_size/2,_posY-_size/2,_size,_size)
            -- 点到当前金子单元
            if cc.rectContainsPoint(rect, p) then
            	-- 当前单元是金子
            	if self.m_goldCell[r][c] == self.m_gold then
            		-- 进入下一关
            		self.m_level = self.m_level + 1
            		-- 动画隐藏，换关卡后动画显示
                    self:runAction(cc.Sequence:create(cc.CallFunc:create(function() self:hideGoldMatrix() end),
                                    cc.DelayTime:create(0.3),
                                    cc.CallFunc:create(function() self:showGoldMatrix() end), nil))
                    return self.Result.Result_Success
                else
                    --当前单元里不是金子,金子单元闪烁
                    self.m_gold:runAction(cc.Blink:create(0.7,5))
                    return self.Result.Result_Failure
            	end
            end
		end
	end
	-- 点击无效
    return self.Result.Result_Invalid
end

-- 获取当前关卡
function ASGoldMatrix:getCurrentLevel()
	return self.m_level
end
-- 获取当前成绩
function ASGoldMatrix:getCurrentScore()
	return self.m_level - 1
end
return ASGoldMatrix