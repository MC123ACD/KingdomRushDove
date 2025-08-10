-- 这个文件用于斗蛐蛐中编辑出怪

return {
    on = true, -- 启用斗蛐蛐,
    path_index = 1, -- 设置主路径为 1
    delay = 0, -- 开始出怪前的延迟，单位为秒
    spawns = {
        {
            max = 50,
            creep = "enemy_slayer", -- 选择敌人为小哥布林
            fixed_sub_path = 0,
            interval = 0.7, -- 每隔 0.1 秒出一个小哥布林
            interval_next = 5 -- 本小波出完后，过 5 秒出下一波
        },
    }
}

-- 一个示例的斗蛐蛐文件：
-- return {
--     on = true, -- 启用斗蛐蛐,
--     path_index = 1, -- 设置主路径为 1
--     delay = 0,
--     spawns = {
--         {
--             max = 100,
--             creep = "enemy_goblin", -- 选择敌人为小哥布林
--             fixed_sub_path = 0,
--             interval = 1, -- 每隔 1 秒出一个小哥布林
--             interval_next = 5 -- 本小波出完后，过 5 秒出下一波
--         },
--         {
--             max = 50,
--             creep = "enemy_fat_orc", -- 选择敌人为小兽人
--             fixed_sub_path = 0,
--             interval = 2, -- 每隔 2 秒出一个小兽人
--             interval_next = 0
--         },
--     }
-- }