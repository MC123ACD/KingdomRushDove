local i18n = require("i18n")
require("constants")
local anchor_x = 0
local anchor_y = 0
local image_x = 0
local image_y = nil
local tt = nil
local log = require("klua.log"):new("soldier_enemies")
local signal = require("hump.signal")

package.loaded.scripts = nil
local scripts = require("scripts")
require("templates")
local function adx(v)
    return v - anchor_x * image_x
end
local function ady(v)
    return v - anchor_y * image_y
end
local bit = require("bit")
local bor = bit.bor
local band = bit.band
local bnot = bit.bnot
local E = require("entity_db")
local U = require("utils")
require("constants")
local IS_PHONE = KR_TARGET == "phone"
local IS_PHONE_OR_TABLET = KR_TARGET == "phone" or KR_TARGET == "tablet"
local IS_CONSOLE = KR_TARGET == "console"
local SU = require("script_utils")
local simulation = require("simulation")
local S = require("sound_db")
local function queue_insert(store, e)
    simulation:queue_insert_entity(e)
end

local function queue_remove(store, e)
    simulation:queue_remove_entity(e)
end

local function v(v1, v2)
    return {
        x = v1,
        y = v2
    }
end

local function vv(v1)
    return {
        x = v1,
        y = v1
    }
end

local function r(x, y, w, h)
    return {
        pos = v(x, y),
        size = v(w, h)
    }
end

local function fts(v)
    return v / FPS
end

local function np(pi, spi, ni)
    return {
        dir = 1,
        pi = pi,
        spi = spi,
        ni = ni
    }
end

local function d2r(d)
    return d * math.pi / 180
end

local function RT(name, ref)
    return E:register_t(name, ref)
end

local function AC(tpl, ...)
    return E:add_comps(tpl, ...)
end

local function CC(comp_name)
    return E:clone_c(comp_name)
end

local function soldier_enemy_do_timed_action(store, this, action)
    local action_done = false
    local start_ts = store.tick_ts

    U.animation_start(this, action.animation, nil, store.tick_ts)
    S:queue(action.sound)

    if action.cast_time and U.y_wait(store, action.cast_time, function(store, time)
        return this.health.dead or this.unit.is_stunned
    end) then
        -- block empty
    else
        action.ts = start_ts
        action_done = true

        if action.mod then
            local e = E:create_entity(action.mod)

            e.modifier.target_id = this.id
            e.modifier.source_id = this.id
            e.modifier.level = action.level
            e.modifier.damage_factor = this.unit.damage_factor
            queue_insert(store, e)
        elseif action.aura then
            local e = E:create_entity(action.aura)

            e.aura.source_id = this.id
            e.aura.level = action.level
            e.aura.damage_factor = this.unit.damage_factor
            e.pos = V.vclone(this.pos)

            queue_insert(store, e)
        end

        while not U.animation_finished(this) do
            if this.health.dead or this.unit.is_stunned then
                break
            end
            coroutine.yield()
        end

    end

    return action_done
end

local function soldier_enemy_timed_actions(store, this)
    for _, a in pairs(this.timed_actions.list) do
        if a.disabled or store.tick_ts - a.ts < a.cooldown then
            -- block empty
        elseif a.fn_can and not a.fn_can(this, store, a) then
            return false, A_NO_TARGET
        elseif not a.chance or math.random() < a.chance then
            local attack_done = soldier_enemy_do_timed_action(store, this, a)

            if attack_done then
                return false, A_DONE
            else
                return true
            end
        else
            a.ts = store.tick_ts
        end
    end

    return false, A_IN_COOLDOWN

end

local function soldier_enemy_insert(this, store, script)
    if this.melee then
        this.melee.order = U.attack_order(this.melee.attacks)
        for _, a in pairs(this.melee.attacks) do
            a.ts = store.tick_ts
        end

    end

    if this.ranged then
        this.ranged.order = U.attack_order(this.ranged.attacks)
        for _, a in pairs(this.ranged.attacks) do
            a.ts = store.tick_ts
        end

    end

    if this.auras then
        for _, a in pairs(this.auras.list) do
            a.ts = store.tick_ts

            if a.cooldown == 0 then
                local e = E:create_entity(a.name)

                e.pos = V.vclone(this.pos)
                e.aura.level = this.unit.level
                e.aura.source_id = this.id
                e.aura.ts = store.tick_ts

                queue_insert(store, e)
            end
        end
    end

    if this.track_kills and this.track_kills.mod then
        local mod_name = this.track_kills.mod
        local m = E:create_entity(mod_name)
        m.modifier.target_id = this.id
        m.modifier.source_id = this.id
        m.pos = V.vclone(this.pos)
        queue_insert(store, m)
    end

    if this.track_damage and this.track_damage.mod then
        local e = E:create_entity(this.track_damage.mod)

        e.pos = V.vclone(this.pos)
        e.modifier.target_id = this.id
        e.modifier.source_id = this.id

        queue_insert(store, e)
    end

    if this.powers then
        for pn, p in pairs(this.powers) do
            p.level = p.max_level
            for i = 1, p.max_level do
                SU.soldier_power_upgrade(this, pn)
            end
        end
    end

    if this.info and this.info.random_name_format then
        this.info.i18n_key = string.format(string.gsub(this.info.random_name_format, "_NAME", ""),
            math.random(this.info.random_name_count))
    end

    if this.render then
        for _, s in pairs(this.render.sprites) do
            s.ts = store.tick_ts
        end
    end

    local next, new = P:next_entity_node(this, store.tick_length)

    if not next then
        log.debug("(%s) %s has no valid next node", this.id, this.template_name)

        return false
    end

    U.set_destination(this, next)
    U.set_heading(this, next)
    if not this.pos or this.pos.x == 0 and this.pos.y == 0 then
        this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
    end
    this.enemy.gold_bag = math.ceil(this.enemy.gold * 0.6)

    if this.water and this.spawn_data and this.spawn_data.water_ignore_pi then
        this.water.ignore_pi = this.spawn_data.water_ignore_pi
    end

    return true

end

local function soldier_enemy_timed_attacks(store, this)
    for _, a in pairs(this.timed_attacks.list) do
        if a.disabled or store.tick_ts - a.ts < a.cooldown then
            -- block empty
        else
            local target = U.find_nearest_soldier(store.soldiers, this.pos, a.min_range, a.max_range, a.vis_flags,
                a.vis_bans)

            if not target then
                return false, A_NO_TARGET
            elseif math.random() < a.chance then
                local attack_done = SU.y_soldier_do_timed_attack(store, this, target, a)

                if attack_done then
                    return false, A_DONE
                else
                    return true
                end
            else
                a.ts = store.tick_ts
            end
        end
    end

    return false, A_IN_COOLDOWN
end

local function soldier_enemy_update(this, store, script)
    if this.render.sprites[1].name == "raise" then
        this.health_bar.hidden = true

        U.animation_start(this, "raise", nil, store.tick_ts, 1)

        while not U.animation_finished(this) and not this.health.dead do
            coroutine.yield()
        end

        if not this.health.dead then
            this.health_bar.hidden = nil
        end
    end

    ::label_25_0::

    while true do
        if this.health.dead and not SU.y_soldier_revive(store, this) then
            SU.y_enemy_death(store, this)
            return
        end
        if this.unit.is_stunned then
            SU.y_enemy_stun(store, this)
        else
            if this.dodge and this.dodge.active then
                this.dodge.active = false

                if this.dodge.counter_attack and this.dodge.counter_attack.power_name and
                    this.powers[this.dodge.counter_attack.power_name].level > 0 then
                    this.dodge.counter_attack_pending = true
                elseif this.dodge.animation then
                    U.animation_start(this, this.dodge.animation, nil, store.tick_ts, 1)

                    while not U.animation_finished(this) do
                        coroutine.yield()
                    end
                end

                signal.emit("soldier-dodge", this)
            end
            local brk, sta
            if this.timed_actions then
                brk, sta = soldier_enemy_timed_actions(store, this)

                if brk then
                    goto label_25_0
                end
            end

            if this.timed_attacks then
                brk, sta = soldier_enemy_timed_attacks(store, this)

                if brk then
                    goto label_25_0
                end
            end
            local cont, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, false, function()
                return this.timed_actions and soldier_enemy_timed_actions(store, this)
            end)

            if not cont then
                -- block empty
            else
                if blocker then
                    if not SU.y_wait_for_blocker(store, this, blocker) then
                        goto label_25_0
                    end

                    while SU.can_melee_blocker(store, this, blocker) do
                        if this.ranged and this.ranged.range_while_blocking and ranged then
                            SU.y_enemy_range_attacks(store, this, ranged)
                        end
                        if not SU.y_enemy_melee_attacks(store, this, blocker) then
                            goto label_25_0
                        end

                        coroutine.yield()
                    end
                elseif ranged then
                    while SU.can_range_soldier(store, this, ranged) and #this.enemy.blockers == 0 do
                        if not SU.y_enemy_range_attacks(store, this, ranged) then
                            goto label_25_0
                        end

                        coroutine.yield()
                    end
                end

                coroutine.yield()
            end

        end
    end
end

-- return function()
for _, t in pairs(E:filter_templates("soldier")) do
    if t.health and t.health.hp_max and t.motion and t.motion.max_speed and t.info and t.vis then
        tt = E:register_t("enemy_" .. t.template_name, t.template_name)
        if tt then
            E:add_comps(tt, "enemy", "nav_path")
            tt.soldier = nil
            if t.template_name == "soldier_barbarian" then
                tt.powers.dual.on_power_upgrade = function(this, power_name, power)
                    if not this._on_power_upgrade_called then
                        this._on_power_upgrade_called = true
                        this.ranged.attacks[1].animation = this.ranged.attacks[1].animation .. "2"
                        this.melee.attacks[1].animation = this.melee.attacks[1].animation .. "2"
                        this.melee.attacks[2].animation = this.melee.attacks[2].animation .. "2"
                        this.render.sprites[1].angles.walk[1] = this.render.sprites[1].angles.walk[1] .. "2"
                        this.idle_flip.last_animation = this.idle_flip.last_animation .. "2"
                        this.enemy.melee_slot = v(7, 0)
                        this.melee.attacks[1].damage_type = DAMAGE_RUDE
                        this.melee.attacks[2].damage_type = DAMAGE_RUDE
                        this.ranged.attacks[1].bullet = "axe_barbarian_rude"
                    end
                end
            end
            tt.main_script.insert = soldier_enemy_insert
            tt.main_script.update = soldier_enemy_update
            tt.motion.max_speed = t.motion.max_speed / 1.2
            tt.enemy.melee_slot = v(t.soldier.melee_slot_offset.x, t.soldier.melee_slot_offset.y)
            if not tt.info.i18n_key then
                tt.info.i18n_key = string.upper(t.template_name)
            end
            -- log.error("registered soldier enemy: %s", tt.template_name)
            tt.vis.flags = bor(U.flag_clear(tt.vis.flags, F_FRIEND), F_ENEMY)
        end
    end
end
-- end

