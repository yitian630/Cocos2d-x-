-- 实体类：导弹, "1.png"
require("entity.ASConfig")
require("data.Csv")
--local ASMissileType = require("entity.ASMissileType")
local ASEffectPlayer = require("global.ASMusicPlayer")
local ASMusicPlayer = require("global.ASBackGroundMusicPlayer")

local ASMissile = class("ASMissile", function ()
    return cc.Sprite:createWithSpriteFrameName("daodan.png")
end)
ASMissile.__index = ASMissile
ASMissile._moveSpeed = nil -- 导弹的移动速度
ASMissile._rtNorRot = nil -- 导弹的初始角度
ASMissile._rtTarRot = nil -- 导弹的目标角度
ASMissile._rotFactor = nil -- 导弹旋转系数
ASMissile._isDead = nil -- 导弹是否死亡
ASMissile._distanceForPlane = nil -- 导弹和飞机的距离
ASMissile._X = nil -- 导弹X轴方向分量
ASMissile._Y = nil -- 导弹Y轴方向分量
ASMissile._Dir = nil --导弹旋转方向
ASMissile._time = nil --导弹出现的时间
ASMissile._emitter = nil -- 粒子效果
ASMissile._scheduleID = nil -- 定时器

local size = cc.Director:getInstance():getWinSize()

function ASMissile:create(position,rotation, speed, factor) 
    local aMissile= ASMissile.new()
    if aMissile ~= nil then
        --todo
        table.insert(CONTAINER.MISSILES, aMissile)
        
        aMissile:init(position,rotation,speed, factor)
    end

    return aMissile 
end

function ASMissile:init(position,rotation,speed, factor)

    self._rtNorRot = rotation
    self:setPosition(position)
    self:setRotation(rotation)

    self._moveSpeed = speed
    self._isDead = false
    self._time = 0
    self._rotFactor = factor
    self._scheduleID = nil

    self._X = math.sin(math.rad(self._rtNorRot))
    self._Y = math.cos(math.rad(self._rtNorRot))

    self._distanceForPlane = 0
    self._Dir = 0
    
    -- 导弹移动
    self:startRun()

    return true
end

-- 得到当前状态
function ASMissile:getIsDead()
    -- body
    return self._isDead
end

-- 开始移动
function ASMissile:startRun()
    if self._isDead == true then
        return
    end

    function run()       
        self:setPositionX(self:getPositionX() + self._moveSpeed*self._X)
        self:setPositionY(self:getPositionY() + self._moveSpeed*self._Y)
        -- body
        local posX = self:getPositionX()
        local posY = self:getPositionY()

        local x = ASGlobalClient.pWorldX - posX
        local y = ASGlobalClient.pWorldY - posY

        --求飞机和导弹之间的距离
        self._distanceForPlane = math.sqrt(x*x+y*y)

        --求角度（取1-360整数），反正切函数求弧度/π*180.0  --1弧度= 180/π, 1度=π/180
        self._rtTarRot = math.ceil(math.atan(x/y) / math.pi * 180.0)

        if x~=0 and y~=0 then         
            if y<0 then
                if x<0 then
                    -- 点击第三象限
                    self._rtTarRot = 180 + math.abs(self._rtTarRot)                             
                else
                    -- 点击第四象限
                    self._rtTarRot = 180 - math.abs(self._rtTarRot)
                end
            else          
                if x<0 then
                    -- 点击第二象限
                    self._rtTarRot = 360 + self._rtTarRot
                end
            end
        end

        -- 在屏幕更新导弹当前角度和目标角度
--        ASGlobalClient.M_curLabelText:setString(math.ceil(self._rtNorRot))
--        ASGlobalClient.M_TarLabelText:setString(self._rtTarRot)
        
        -- 判断飞机旋转方向（向左/向右）
        if self._rtNorRot ~= self._rtTarRot then
            if self._rtNorRot<180 then
                if self._rtTarRot>self._rtNorRot and self._rtTarRot<self._rtNorRot+180 then
                    self._Dir = 1                            
                else 
                    self._Dir = -1   
                end            
            else
                if self._rtTarRot<self._rtNorRot and self._rtTarRot>self._rtNorRot-180 then
                    self._Dir = -1    
                else
                    self._Dir = 1      
                end
            end
        else
            self._Dir = 0
        end

        local tempAngle 

        if self._distanceForPlane >= 1000 then
            tempAngle = 2
        elseif self._distanceForPlane >= 800 and self._distanceForPlane <1000 then
            tempAngle = 1
        elseif self._distanceForPlane < 800 then
            tempAngle = 0.5 
        end

        self._rtNorRot = self._rtNorRot + self._Dir*tempAngle*self._rotFactor

        -- 判断通过临界点（360度）的向右旋转
        if self._rtNorRot > 360 then
            self._rtNorRot = 0
        end
        -- 过临界点的向左旋转（此处改成<0,修改目标是360时，一直旋转的问题）
        if self._rtNorRot < 0 then
            self._rtNorRot = 360
        end

        self:setRotation(self._rtNorRot)
        --        self._emitter:setAngle(-self._rtNorRot)
        -- 更新导弹移动的方向
        self._X = math.sin(math.rad(self._rtNorRot))
        self._Y = math.cos(math.rad(self._rtNorRot))

        local px = ASGlobalClient.pWorldX
        local py = ASGlobalClient.pWorldY
        local mx,my = self:getPosition()
        local deltaX = math.abs(px - mx)
        local deltaY = math.abs(py - my)
        -- 飞机和导弹碰撞
        if deltaX < 20 and deltaY < 20 then
            --todo
--            print("飞机和导弹碰撞，游戏结束")  
            
            ASEffectPlayer:getInstance():currentPlayEffect("effect_boom.mp3",false)   
            ASMusicPlayer:getInstance():stopCustemMusic()      
            --todo
            self._isDead = true

--            self:jumpScene()
            --添加最高分，最高分从文件中获取
            bestDistance = getDistance() - 0
            print("bestDistance 保存前== "..bestDistance)
            if bestDistance < ASGlobalClient.distance then
                saveDistance(ASGlobalClient.distance)
            else 
                saveDistance(bestDistance)
            end
            local gameOverScene = require("scene.ASGameOverScene")      
            local overScene = gameOverScene.create()
            cc.Director:getInstance():replaceScene(overScene)
            -- 商店
            local shopScene = require("scene.ASShopScene")      
            local scene = shopScene.create()
            cc.Director:getInstance():pushScene(scene)
        end

        --        self._time = self._time + 1  
        --        -- 判断导弹超过一定时间(15秒)就移除掉    
        --        if self._time/60 >= 15 and self._distanceForPlane >= size.height/2 then
        --            print("self removed............self._time= "..self._time)
        --          self:removed()
        --        end

    end
    self:scheduleUpdateWithPriorityLua(run,0)
--    self._scheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(run,0,false)
end

-- 删除导弹
function ASMissile:removed()
    self:removeFromParent()
end

-- 跳转场景
function ASMissile:jumpScene()
    local gameOverScene = require("scene.ASGameOverScene")      
    local scene = gameOverScene.create()
    cc.Director:getInstance():replaceScene(cc.TransitionFade:create(1,scene))
end

return ASMissile