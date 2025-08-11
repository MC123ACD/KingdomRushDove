-- 这是一个编辑斗蛐蛐出怪的样例文件
-- 你可以在同一文件夹中创建一个名为 criket.lua 的新文件来定义你的斗蛐蛐波次
-- 请保证选择的出怪在你选择斗蛐蛐的关卡中出现，否则不会加载贴图
-- 本文件不会生效
return {
    on = true, -- 启用斗蛐蛐,
    path_index = 1, -- 设置主路径为 1
    delay = 0, -- 开始出怪前的延迟，单位为秒
    spawns = {{
        max = 100,
        creep = "enemy_goblin", -- 选择敌人为小哥布林
        fixed_sub_path = 0,
        interval = 0.1, -- 每隔 0.1 秒出一个小哥布林
        interval_next = 5 -- 本小波出完后，过 5 秒出下一波
    }, {
        max = 50,
        creep = "enemy_fat_orc", -- 选择敌人为小兽人
        fixed_sub_path = 0,
        interval = 0.2, -- 每隔 0.2 秒出一个小兽人
        interval_next = 0
    }},
    -- 启用的贴图列表
    required_textures = {
        "go_enemies_acaroth",
        "go_enemies_ancient_metropolis",
        "go_enemies_bandits",
        "go_enemies_bittering_rancor",
        "go_enemies_blackburn",
        "go_enemies_desert",
        "go_enemies_elven_woods",
        "go_enemies_faerie_grove",
        "go_enemies_forgotten_treasures",
        "go_enemies_grass",
        "go_enemies_halloween",
        "go_enemies_hulking_rage",
        "go_enemies_ice",
        "go_enemies_jungle",
        "go_enemies_mactans_malicia",
        "go_enemies_rising_tides",
        "go_enemies_rotten",
        "go_enemies_sarelgaz",
        "go_enemies_storm",
        "go_enemies_torment",
        "go_enemies_underground",
        "go_enemies_wastelands"
    }
}
