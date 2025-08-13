-- 这个文件用于斗蛐蛐中编辑出怪

return {
    on = true, -- 启用斗蛐蛐,
    path_index = 5, -- 设置主路径为 1
    delay = 0, -- 开始出怪前的延迟，单位为秒
    spawns = {
        -- {
        --     max = 60,
        --     creep = "enemy_demon_mage", -- 选择敌人为小哥布林
        --     creep_aux = "enemy_demon_flareon",
        --     max_same = 2,
        --     fixed_sub_path = 0,
        --     interval = 0.4, -- 每隔 0.1 秒出一个小哥布林
        --     interval_next = 0.4 -- 本小波出完后，过 5 秒出下一波
        -- },
        -- {
        --     max = 20,
        --     creep = "enemy_demon",
        --     fixed_sub_path = 0,
        --     interval = 0.5,
        --     interval_next = 0.4 -- 每隔 1 秒出一个小兽人
        -- },
        -- {
        --     max = 20,
        --     creep = "enemy_demon_wolf",
        --     fixed_sub_path = 0,
        --     interval = 1,
        --     interval_next = 0.4 -- 每隔 1 秒出一个小兽人
        -- }
        {
            max = 50,
            creep = "enemy_soldier_barbarian",
            creep_aux = "enemy_soldier_paladin",
            max_same = 1,
            fixed_sub_path = 0,
            interval = 0.2,
            interval_next = 0.4 -- 每隔 1 秒出一个小兽人
        },
        {
            max = 50,
            creep = "enemy_soldier_barbarian",
            fixed_sub_path = 0,
            interval = 0.2,
            interval_next = 0.4 -- 每隔 1 秒出一个小兽人
        },
        -- {
        --     max = 30,
        --     creep = "enemy_soldier_djinn",
        --     fixed_sub_path = 0,
        --     interval = 0.1,
        --     interval_next = 0.4 -- 每隔 1 秒出一个小兽人
        -- },
        -- {
        --     max = 10,
        --     creep = "enemy_soldier_assassin",
        --     fixed_sub_path = 0,
        --     interval = 0.1,
        --     interval_next = 0.4
        -- },
        -- {
        --     max = 10,
        --     creep = "enemy_soldier_elemental",
        --     fixed_sub_path = 0,
        --     interval = 1,
        --     interval_next = 0.4
        -- },
        -- {
        --     max = 10,
        --     creep = "enemy_soldier_dwarf",
        --     fixed_sub_path = 0,
        --     interval = 0.1,
        --     interval_next = 0.4
        -- },
        -- {
        --     max = 10,
        --     creep = "enemy_soldier_death_rider",
        --     fixed_sub_path = 0,
        --     interval = 0.1,
        --     interval_next = 0.4
        -- },
        -- {
        --     max = 10,
        --     creep = "enemy_soldier_elf",
        --     fixed_sub_path = 0,
        --     interval = 0.1,
        --     interval_next = 0.4
        -- },
    },
    required_textures = {"go_enemies_acaroth", "go_enemies_ancient_metropolis", "go_enemies_bandits",
                     "go_enemies_bittering_rancor", "go_enemies_blackburn", "go_enemies_desert",
                     "go_enemies_elven_woods",
                     "go_enemies_faerie_grove",
                     "go_enemies_forgotten_treasures", "go_enemies_grass",
                     "go_enemies_halloween", "go_enemies_hulking_rage", "go_enemies_ice", "go_enemies_jungle",
                     "go_enemies_mactans_malicia", "go_enemies_rising_tides", "go_enemies_rotten",
                     "go_enemies_sarelgaz", "go_enemies_storm", "go_enemies_torment", "go_enemies_underground",
                     "go_enemies_wastelands"}
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