
local GameScene = class("GameScene",function()
    return cc.Scene:create()
end)

function GameScene.create()
    local scene = GameScene.new()
    scene:addChild(scene:createLayerFarm())
    return scene
end


function GameScene:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil
end

-- create farm
function GameScene:createLayerFarm()
    local layerFarm = cc.Layer:create()
    -- add in farm background
    local bg = cc.Sprite:create("farm.jpg")
    bg:setPosition(self.origin.x + self.visibleSize.width / 2 + 80, self.origin.y + self.visibleSize.height / 2)
    layerFarm:addChild(bg)

    return layerFarm
end

return GameScene
