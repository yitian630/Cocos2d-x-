-- 导弹类型
local MissileType = {
    {
        type = 1,                             -- 导弹类型ID
        spriteFrame = "M_01-1_silver.png",    -- 导弹图片缓存
        moveSpeed = 6,                        -- 导弹移动速度
        moveMode = MISSILE_MOVE_TYPE.LINE     -- 直线移动
    },
    {
        type = 2,
        spriteFrame = "M_01-2_purple.png",
        moveSpeed = 6,
        moveMode = MISSILE_MOVE_TYPE.LINE
    },
    {
        type = 3,
        spriteFrame = "M_01-3_golden.png",
        moveSpeed = 6,
        moveMode = MISSILE_MOVE_TYPE.LINE
    },
    {
        type = 4,
        spriteFrame = "M_02-1_silver.png",
        moveSpeed = 6.5,
        moveMode = MISSILE_MOVE_TYPE.CURVE
    },
    {
        type = 5,
        spriteFrame = "M_02-2_golden.png",
        moveSpeed = 6.5,
        moveMode = MISSILE_MOVE_TYPE.CURVE
    },
    {
        type = 6,
        spriteFrame = "M_03-1_purple.png",
        moveSpeed = 7,
        moveMode = MISSILE_MOVE_TYPE.CURVE
    },
    {
        type = 7,
        spriteFrame = "M_03-2_golden.png",
        moveSpeed = 7,
        moveMode = MISSILE_MOVE_TYPE.CURVE
    }
}

return MissileType