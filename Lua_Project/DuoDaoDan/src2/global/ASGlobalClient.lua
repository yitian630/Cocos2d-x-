ASGlobalClient = ASGlobalClient or {}

-- 实体类型
EntityType = {
    Missile = 1,
    Coin = 2,   
}

-- 碰撞处理类型
ContactLogicType = {
    None = 0,
    Move = 1,
    Destroy = 2, -- 销毁
}