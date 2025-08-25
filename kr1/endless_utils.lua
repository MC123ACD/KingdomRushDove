local E = require("entity_db")
local UP = require("kr1.upgrades")
local U = require("all.utils")
local EU = {}
local scripts = require("all.scripts")
local endless_balance = require("kr1.data.endless")
local enemy_buff = endless_balance.enemy_buff
local friend_buff = endless_balance.friend_buff
local enemy_upgrade_max_levels = endless_balance.enemy_upgrade_max_levels
function EU.patch_enemy_growth(endless)
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
                    this.bullet.damage_factor = this.bullet.damage_factor * 2
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
return EU
