local E = require("entity_db")
local UP = require("kr1.upgrades")
local U = require("all.utils")
local EU = {}
local scripts = require("all.scripts")
local endless_balance = require("kr1.data.endless")
local enemy_buff = endless_balance.enemy_buff
local friend_buff = endless_balance.friend_buff
local enemy_upgrade_max_levels = endless_balance.enemy_upgrade_max_levels
local SU = require("script_utils")
require("constants")
local function vv(x)
    return {
        x = x,
        y = x
    }
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
            endless.lives_cost_per_wave = math.ceil(endless.total_lives_cost / endless.std_waves_count)
            endless.avg_interval = endless.avg_interval / enemy_buff.lives_cost_factor
            if endless.avg_interval < 0.1 then
                endless.avg_interval = 0.1
            end
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
    scorched_earth.aura.damage_max = scorched_earth.aura.damage_max +
        level * friend_buff.rain_scorch_damage_true
    local scorched_water = E:get_template("power_scorched_water")
    scorched_water.aura.damage_type = DAMAGE_TRUE
    scorched_water.aura.damage_min = scorched_water.aura.damage_min + level * friend_buff.rain_scorch_damage_true
    scorched_water.aura.damage_max = scorched_water.aura.damage_max +
        level * friend_buff.rain_scorch_damage_true
end

function EU.patch_upgrade_in_game(key, store, endless)
    if not key then
        return
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
end
return EU
