local E = require("entity_db")
require("constants")
local UP = require("kr1.upgrades")
local U = require("all.utils")
local scripts = require("all.scripts")
local EL = require("kr1.data.endless")
local enemy_buff = EL.enemy_buff
local friend_buff = EL.friend_buff
local enemy_upgrade_max_levels = EL.enemy_upgrade_max_levels
local endless_template = EL.template
local SU = require("script_utils")
local storage = require("storage")
local function vv(x)
    return {
        x = x,
        y = x
    }
end

local EU = {}
local function get_enemy_lives_cost(name)
    local tpl = E:get_template(name)
    local lives_cost = 0
    if tpl.enemy then
        lives_cost = tpl.enemy.lives_cost
        if tpl.death_spawns and tpl.death_spawns.name then
            lives_cost = lives_cost + get_enemy_lives_cost(tpl.death_spawns.name) * (tpl.death_spawns.quantity or 1)
        end
    end
end
function EU.init_endless(level_name, groups)
    local endless
    local endless_history = storage:load_endless(level_name)
    if endless_history and (endless_history.lives > 0) then
        endless = endless_history
        endless.load_from_history = true
        local function deepcopy(table, base_table)
            for k, v in pairs(base_table) do
                if type(v) == "table" then
                    if table[k] == nil then
                        table[k] = {}
                    end
                    deepcopy(table[k], v)
                else
                    if table[k] == nil then
                        table[k] = v
                    end
                end
            end
        end
        deepcopy(endless_history, endless_template)
    else
        endless = table.deepclone(endless_template)
        local group = #groups > 1 and groups[#groups - 1] or groups[1]
        local waves = group.waves

        local total_spawns = 0
        for _, wave in pairs(waves) do
            for _, spawn in pairs(wave.spawns) do
                endless.avg_interval = endless.avg_interval + spawn.interval
                endless.avg_interval_next = endless.avg_interval_next + spawn.interval_next
                total_spawns = total_spawns + 1
                endless.total_lives_cost = endless.total_lives_cost + get_enemy_lives_cost(spawn.creep) * spawn.max
            end
        end
        endless.avg_interval = math.min(endless.avg_interval / total_spawns, 90)
        endless.avg_interval_next = endless.avg_interval_next / total_spawns

        for _, group in pairs(groups) do
            for _, wave in pairs(group.waves) do
                if wave.path_index and not table.contains(endless.available_paths, wave.path_index) then
                    table.insert(endless.available_paths, wave.path_index)
                end
                for _, spawn in pairs(wave.spawns) do
                    local tpl = E:get_template(spawn.creep)
                    if tpl and tpl.enemy then
                        endless.extra_cash = endless.extra_cash + (tpl.enemy.gold or 0) * spawn.max
                        if not table.contains(endless.enemy_list, spawn.creep) then
                            table.insert(endless.enemy_list, spawn.creep)
                        end
                    end
                end
            end
        end
        endless.spawn_count_per_wave = math.ceil(total_spawns / #endless.available_paths)
        endless.lives_cost_per_wave = math.ceil(endless.total_lives_cost / #endless.available_paths)
    end

    endless.enemy_upgrade_options = table.keys(endless.enemy_upgrade_levels)

    for k, v in pairs(endless.enemy_upgrade_levels) do
        if v >= EL.enemy_upgrade_max_levels[k] then
            table.removeobject(endless.enemy_upgrade_options, k)
        end
    end

    endless.upgrade_options = table.keys(endless.upgrade_levels)

    for k, v in pairs(endless.upgrade_levels) do
        if v >= EL.upgrade_max_levels[k] then
            table.removeobject(endless.upgrade_options, k)
        end
    end
    return endless
end

function EU.generate_group(endless)
    local group = {}

    group.interval = endless.interval
    group.waves = {}
    local i = 1
    for _, path_id in pairs(endless.available_paths) do
        group.waves[i] = {
            delay = 0,
            path_index = path_id,
            spawns = {}
        }
        i = i + 1
    end
    -- 加权数量的敌人列表，模拟加权随机
    local enemy_list = {}
    local remain_lives_cost = endless.total_lives_cost
    while remain_lives_cost > 0 do
        local template_name = table.random(endless.enemy_list)
        local tpl = E:get_template(template_name)
        for j = 1, math.floor(20 / tpl.enemy.lives_cost) do
            table.insert(enemy_list, template_name)
            remain_lives_cost = remain_lives_cost - tpl.enemy.lives_cost
        end
    end

    for _, wave in pairs(group.waves) do
        for j = 1, endless.spawn_count_per_wave do
            local this_spawn_lives_cost = math.ceil(endless.lives_cost_per_wave / endless.spawn_count_per_wave *
                                                        (0.8 + 0.4 * j / endless.spawn_count_per_wave))
            local function generate_creep(i)
                if i <= 0 then
                    return table.random(endless.enemy_list), 0
                end
                local creep = table.random(enemy_list)

                local lives_cost = get_enemy_lives_cost(creep)

                -- 避免前期就出 boss，太夸张了
                local max = math.floor(this_spawn_lives_cost / lives_cost)
                if max > 0 then
                    return creep, max
                else
                    return generate_creep(i - 1)
                end
            end
            local creep, max = generate_creep(5)

            wave.spawns[j] = {
                interval = endless.avg_interval,
                interval_next = endless.avg_interval_next,
                fixed_sub_path = 0,
                max = max,
                creep = creep
            }
        end
    end
    return group
end
function EU.patch_enemy_growth(endless)
    for i = 1, 2 do
        if #endless.enemy_upgrade_options == 0 then
            break
        end
        local key = table.random(endless.enemy_upgrade_options)

        if key == "health" then
            endless.enemy_health_factor = endless.enemy_health_factor * enemy_buff.health_factor
        elseif key == "damage" then
            endless.enemy_damage_factor = endless.enemy_damage_factor * enemy_buff.damage_factor
        elseif key == "speed" then
            endless.enemy_speed_factor = endless.enemy_speed_factor * enemy_buff.speed_factor
        elseif key == "health_damage_factor" then
            endless.enemy_health_damage_factor = endless.enemy_health_damage_factor * enemy_buff.health_damage_factor
        elseif key == "lives" then
            endless.total_lives_cost = math.ceil(endless.total_lives_cost * enemy_buff.lives_cost_factor)
            endless.lives_cost_per_wave = math.ceil(endless.total_lives_cost / #endless.available_paths)
            if endless.lives_cost_per_wave / endless.spawn_count_per_wave > 40 then
                endless.spawn_count_per_wave = endless.spawn_count_per_wave + 1
            end
            endless.avg_interval = endless.avg_interval / enemy_buff.lives_cost_factor
            if endless.avg_interval < 0.1 then
                endless.avg_interval = 0.1
            end
            endless.enemy_gold_factor = endless.enemy_gold_factor - 0.01
        elseif key == "wave_interval" then
            endless.avg_interval_next = endless.avg_interval_next * enemy_buff.wave_interval_factor
        end
        endless.enemy_upgrade_levels[key] = endless.enemy_upgrade_levels[key] + 1
        if endless.enemy_upgrade_levels[key] >= enemy_upgrade_max_levels[key] then
            table.removeobject(endless.enemy_upgrade_options, key)
        end
    end
end

function EU.patch_archer_bleed(level)
    local mod = E:get_template("mod_blood_elves")
    mod.damage_factor = 0.1 + friend_buff.archer_bleed * level
end
function EU.patch_archer_insight(level)
    for _, name in pairs(UP:arrows()) do
        local arrow = E:get_template(name)
        if not arrow._endless_archer_insight then
            U.append_mod(arrow.bullet, "mod_endless_archer_insight")
        end
        local mod = E:get_template("mod_endless_archer_insight")
        mod.modifier.health_damage_factor_inc = level * friend_buff.archer_insight
    end
end
function EU.patch_archer_multishot(level)
    for _, name in pairs(UP:arrows()) do
        local arrow = E:get_template(name)
        if not arrow._endless_multishot then
            arrow.main_script.insert = U.function_append(arrow.main_script.insert,
                scripts.arrow_endless_multishot.insert)
        end
        arrow._endless_multishot = level
    end
end
function EU.patch_archer_critical(level)
    for _, name in pairs(UP:arrows()) do
        local arrow = E:get_template(name)
        if not arrow._endless_archer_critical then
            arrow.main_script.insert = U.function_append(function(this, store, script)
                if math.random() < this._endless_archer_critical then
                    this.bullet.damage_factor = this.bullet.damage_factor * 3
                    if not (this.bullet.pop and table.contains(this.bullet.pop, "pop_headshot")) then
                        this.bullet.pop = {"pop_crit"}
                        this.bullet.pop_conds = DR_DAMAGE
                    end
                end
                return true
            end, arrow.main_script.insert)
        end
        arrow._endless_archer_critical = level * friend_buff.archer_critical
    end
end

function EU.patch_rain_count_inc(level)
    local controller = E:get_template("power_fireball_control")
    controller.cataclysm_count = controller.cataclysm_count + level * friend_buff.rain_count_inc
    controller.fireball_count = controller.fireball_count + level * friend_buff.rain_count_inc
end

function EU.patch_rain_damage_inc(level)
    local fireball = E:get_template("power_fireball")
    fireball.bullet.damage_min = fireball.bullet.damage_min + level * friend_buff.rain_damage_inc
    fireball.bullet.damage_max = fireball.bullet.damage_max + level * friend_buff.rain_damage_inc
    local scorched_water = E:get_template("power_scorched_water")
    scorched_water.aura.damage_min = scorched_water.aura.damage_min + level * friend_buff.rain_damage_inc * 0.1
    scorched_water.aura.damage_max = scorched_water.aura.damage_max + level * friend_buff.rain_damage_inc * 0.1
    local scorched_earth = E:get_template("power_scorched_earth")
    scorched_earth.aura.damage_min = scorched_earth.aura.damage_min + level * friend_buff.rain_damage_inc * 0.1
    scorched_earth.aura.damage_max = scorched_earth.aura.damage_max + level * friend_buff.rain_damage_inc * 0.1
end

function EU.patch_rain_radius_mul(level)
    local fireball = E:get_template("power_fireball")
    fireball.bullet.damage_radius = fireball.bullet.damage_radius * friend_buff.rain_radius_mul ^ level
    fireball.render.sprites[1].scale = vv(friend_buff.rain_radius_mul ^ level)
    local scorched_water = E:get_template("power_scorched_water")
    scorched_water.aura.radius = scorched_water.aura.radius * friend_buff.rain_radius_mul ^ level
    scorched_water.render.sprites[1].scale = vv(friend_buff.rain_radius_mul ^ level)
    local scorched_earth = E:get_template("power_scorched_earth")
    scorched_earth.aura.radius = scorched_earth.aura.radius * friend_buff.rain_radius_mul ^ level
    scorched_earth.render.sprites[1].scale = vv(friend_buff.rain_radius_mul ^ level)
end

function EU.patch_rain_cooldown_dec(level)
    local controller = E:get_template("power_fireball_control")
    controller.cooldown = controller.cooldown - level * friend_buff.rain_cooldown_dec
end

function EU.patch_rain_scorch_damage_true(level)
    local scorched_earth = E:get_template("power_scorched_earth")
    scorched_earth.aura.damage_type = DAMAGE_TRUE
    scorched_earth.aura.damage_min = scorched_earth.aura.damage_min + level * friend_buff.rain_scorch_damage_true
    scorched_earth.aura.damage_max = scorched_earth.aura.damage_max + level * friend_buff.rain_scorch_damage_true
    local scorched_water = E:get_template("power_scorched_water")
    scorched_water.aura.damage_type = DAMAGE_TRUE
    scorched_water.aura.damage_min = scorched_water.aura.damage_min + level * friend_buff.rain_scorch_damage_true
    scorched_water.aura.damage_max = scorched_water.aura.damage_max + level * friend_buff.rain_scorch_damage_true
end
function EU.patch_barrack_luck(level)
    for _, name in pairs(UP:barrack_soldiers()) do
        local s = E:get_template(name)
        if not s._endless_barrack_luck then
            s.health.on_damage = U.function_append(s.health.on_damage, function(this, store, damage)
                return math.random() > this._endless_barrack_luck
            end)
        end
        s._endless_barrack_luck = level * friend_buff.barrack_luck
    end
end

function EU.patch_barrack_unity(level)
    for _, name in pairs(UP:towers_with_barrack()) do
        local t = E:get_template(name)
        t.barrack.max_soldiers = t.barrack.max_soldiers + level * friend_buff.barrack_unity_count
    end
    for _, name in pairs(UP:barrack_soldiers()) do
        local s = E:get_template(name)
        s.health.dead_lifetime = s.health.dead_lifetime - friend_buff.barrack_unity_lifetime * level
    end
end

function EU.patch_barrack_synergy(level)
    for _, name in pairs(UP:barrack_soldiers()) do
        local s = E:get_template(name)
        if not s._barrack_synergy then
            if s.main_script then
                s.main_script.insert = U.function_append(s.main_script.insert, function(this, store)
                    local a = E:create_entity("endless_barrack_synergy_aura")
                    a.aura.source_id = this.id
                    queue_insert(store, a)
                    this._barrack_synergy_aura = a
                    return true
                end)
                s.main_script.remove = U.function_append(s.main_script.remove, function(this, store)
                    if this._barrack_synergy_aura then
                        queue_remove(this._barrack_synergy_aura)
                    end
                    return true
                end)
            end
            s._barrack_synergy = true
        end
    end
    local m = E:get_template("mod_endless_barrack_synergy")
    m.extra_damage = level * friend_buff.barrack_synergy
end

function EU.patch_barrack_rally(level)
    for _, name in pairs(UP:towers_with_barrack()) do
        local t = E:get_template(name)
        t.barrack.rally_range = math.huge
    end
end

function EU.patch_upgrade_in_game(key, store, endless)
    if not key then
        return
    end
    endless.upgrade_levels[key] = endless.upgrade_levels[key] + 1
    if endless.upgrade_levels[key] >= EL.upgrade_max_levels[key] then
        table.removeobject(endless.upgrade_options, key)
    end
    if key == "health" then
        for _, s in pairs(store.soldiers) do
            if s.health then
                s.health.hp_max = s.health.hp_max * friend_buff.health_factor
                s.health.hp = s.health.hp_max
            end
        end
        endless.soldier_health_factor = endless.soldier_health_factor * friend_buff.health_factor
    elseif key == "soldier_damage" then
        for _, s in pairs(store.soldiers) do
            if s.unit then
                s.unit.damage_factor = s.unit.damage_factor * friend_buff.soldier_damage_factor
            end
        end
        endless.soldier_damage_factor = endless.soldier_damage_factor * friend_buff.soldier_damage_factor
    elseif key == "soldier_cooldown" then
        for _, s in pairs(store.soldiers) do
            if s.cooldown_factor then
                s.cooldown_factor = s.cooldown_factor * friend_buff.soldier_cooldown_factor
            end
        end
        endless.soldier_cooldown_factor = endless.soldier_cooldown_factor * friend_buff.soldier_cooldown_factor
    elseif key == "tower_damage" then
        for _, t in pairs(store.towers) do
            SU.insert_tower_damage_factor_buff(t, friend_buff.tower_damage_factor)
        end
        endless.tower_damage_factor = endless.tower_damage_factor + friend_buff.tower_damage_factor
    elseif key == "tower_cooldown" then
        for _, t in pairs(store.towers) do
            SU.insert_tower_cooldown_buff(t, friend_buff.tower_cooldown_factor)
        end
        endless.tower_cooldown_factor = endless.tower_cooldown_factor * friend_buff.tower_cooldown_factor
    elseif key == "hero_damage" then
        for _, h in pairs(store.soldiers) do
            if h.hero then
                h.unit.damage_factor = h.unit.damage_factor * friend_buff.hero_damage_factor
            end
        end
        endless.hero_damage_factor = endless.hero_damage_factor * friend_buff.hero_damage_factor
    elseif key == "hero_cooldown" then
        for _, h in pairs(store.soldiers) do
            if h.hero then
                h.cooldown_factor = h.cooldown_factor * friend_buff.hero_cooldown_factor
            end
        end
        endless.hero_cooldown_factor = endless.hero_cooldown_factor * friend_buff.hero_cooldown_factor
    elseif key == "archer_bleed" then
        EU.patch_archer_bleed(endless.upgrade_levels[key])
    elseif key == "archer_multishot" then
        EU.patch_archer_multishot(endless.upgrade_levels[key])
    elseif key == "archer_insight" then
        EU.patch_archer_insight(endless.upgrade_levels[key])
    elseif key == "archer_critical" then
        EU.patch_archer_critical(endless.upgrade_levels[key])
    elseif key == "rain_count_inc" then
        EU.patch_rain_count_inc(1)
    elseif key == "rain_damage_inc" then
        EU.patch_rain_damage_inc(1)
    elseif key == "rain_radius_mul" then
        EU.patch_rain_radius_mul(1)
    elseif key == "rain_cooldown_dec" then
        EU.patch_rain_cooldown_dec(1)
    elseif key == "rain_scorch_damage_true" then
        EU.patch_rain_scorch_damage_true(1)
    elseif key == "more_gold" then
        endless.enemy_gold_factor = endless.enemy_gold_factor + friend_buff.more_gold
    elseif key == "barrack_rally" then
        for _, t in pairs(store.towers) do
            if t.barrack then
                t.barrack.rally_range = math.huge
            end
        end
        EU.patch_barrack_rally(endless.upgrade_levels[key])
    elseif key == "barrack_unity" then
        for _, t in pairs(store.towers) do
            if t.barrack then
                t.barrack.max_soldiers = t.barrack.max_soldiers + friend_buff.barrack_unity_count
            end
        end
        EU.patch_barrack_unity(endless.upgrade_levels[key])
    elseif key == "barrack_luck" then
        EU.patch_barrack_luck(endless.upgrade_levels[key])
        for _, s in pairs(store.soldiers) do
            if s.health then
                if not s._endless_barrack_luck then
                    s.health.on_damage = U.function_append(s.health.on_damage, function(this, store, damage)
                        return math.random() > this._endless_barrack_luck
                    end)
                end
                s._endless_barrack_luck = endless.upgrade_levels[key] * friend_buff.barrack_luck
            end
        end
    elseif key == "barrack_synergy" then
        for _, s in pairs(store.soldiers) do
            if not s._barrack_synergy_aura then
                local a = E:create_entity("endless_barrack_synergy_aura")
                a.aura.source_id = s.id
                queue_insert(store, a)
                s._barrack_synergy_aura = a
                if s.main_script then
                    s.main_script.remove = U.function_append(s.main_script.remove, function(this, store)
                        if this._barrack_synergy_aura then
                            queue_remove(this._barrack_synergy_aura)
                        end
                        return true
                    end)
                end
            end
        end
        EU.patch_barrack_synergy(endless.upgrade_levels[key])
    end
end

function EU.patch_upgrades(endless)
    if endless.upgrade_levels.archer_bleed > 0 then
        EU.patch_archer_bleed(endless.upgrade_levels.archer_bleed)
    end
    if endless.upgrade_levels.archer_multishot > 0 then
        EU.patch_archer_multishot(endless.upgrade_levels.archer_multishot)
    end
    if endless.upgrade_levels.archer_insight > 0 then
        EU.patch_archer_insight(endless.upgrade_levels.archer_insight)
    end
    if endless.upgrade_levels.archer_critical > 0 then
        EU.patch_archer_critical(endless.upgrade_levels.archer_critical)
    end
    if endless.upgrade_levels.rain_count_inc > 0 then
        EU.patch_rain_count_inc(endless.upgrade_levels.rain_count_inc)
    end
    if endless.upgrade_levels.rain_damage_inc > 0 then
        EU.patch_rain_damage_inc(endless.upgrade_levels.rain_damage_inc)
    end
    if endless.upgrade_levels.rain_radius_mul > 0 then
        EU.patch_rain_radius_mul(endless.upgrade_levels.rain_radius_mul)
    end
    if endless.upgrade_levels.rain_cooldown_dec > 0 then
        EU.patch_rain_cooldown_dec(endless.upgrade_levels.rain_cooldown_dec)
    end
    if endless.upgrade_levels.rain_scorch_damage_true > 0 then
        EU.patch_rain_scorch_damage_true(endless.upgrade_levels.rain_scorch_damage_true)
    end
    if endless.upgrade_levels.barrack_rally > 0 then
        EU.patch_barrack_rally(endless.upgrade_levels.barrack_rally)
    end
    if endless.upgrade_levels.barrack_luck > 0 then
        EU.patch_barrack_luck(endless.upgrade_levels.barrack_luck)
    end
    if endless.upgrade_levels.barrack_unity > 0 then
        EU.patch_barrack_unity(endless.upgrade_levels.barrack_unity)
    end
    if endless.upgrade_levels.barrack_synergy > 0 then
        EU.patch_barrack_synergy(endless.upgrade_levels.barrack_synergy)
    end
end
return EU
