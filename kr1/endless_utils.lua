local friend_buff = require("kr1.data.endless").friend_buff
local E = require("entity_db")
local UP = require("kr1.upgrades")
local U = require("all.utils")
local EU = {}
local scripts = require("all.scripts")

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
            arrow.main_script.insert = U.function_append(arrow.main_script.insert, scripts.arrow_endless_multishot.insert)
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
                end
                return true
            end, arrow.main_script.insert)
        end
        arrow._endless_archer_critical = level * friend_buff.archer_critical
    end
end
return EU