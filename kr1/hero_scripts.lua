require("klua.table")
require("i18n")
-- local scripts = require("scripts")
local AC = require("achievements")
require("game_scripts_utils")
local function upgrade_skill(this, skill_name, upgrade_func)
    local s = this.hero.skills[skill_name]
    local sl = s.xp_level_steps[this.hero.level]
    if sl then
        s.level = sl
        upgrade_func(this, s)
    end
end
local function ready_to_use_skill(skill_attack, store)
    return (not skill_attack.disabled) and (store.tick_ts - skill_attack.ts > skill_attack.cooldown)
end
local function update_regen(this)
    this.regen.health = math.ceil(this.health.hp_max * GS.soldier_regen_factor)
end
local function inc_armor_by_skill(this, amount)
    this.health.raw_armor = this.health.raw_armor + amount
    this.health.armor = km.clamp(0, 1, this.health.armor + amount)
end
local function inc_magic_armor_by_skill(this, amount)
    this.health.raw_magic_armor = this.health.raw_magic_armor + amount
    this.health.magic_armor = km.clamp(0, 1, this.health.magic_armor + amount)
end
local function level_up_basic(this)
    local hl = this.hero.level
    local ls = this.hero.level_stats
    this.health.hp_max = ls.hp_max[hl]
    update_regen(this)
    this.health.raw_armor = ls.armor[hl]
    SU.update_armor(this)
    if (ls.magic_armor) then
        this.health.raw_magic_armor = ls.magic_armor[hl]
        SU.update_magic_armor(this)
    end
    return hl, ls
end

local function find_target_at_critical_moment(this, store, range, ignore_bigguy, require_foremost, vis_bans)
    local target = nil
    local _, targets = U.find_foremost_enemy(store.entities, this.pos, 0, range, 0, F_RANGED, vis_bans or 0)
    local num = 0
    if targets then
        num = #targets
        if not ignore_bigguy then
            for _, t in pairs(targets) do
                if t.health and t.health.hp > 750 then
                    target = t
                    break
                end
            end
        end
        if #targets > 6 then
            if require_foremost then
                target = targets[1]
            else
                target = targets[math.random(1, #targets)]
            end
        end
    end
    return target, num
end

local function valid_land_node_nearby(pos)
    return not GR:cell_is(pos.x, pos.y, TERRAIN_FAERIE) and P:valid_node_nearby(pos.x, pos.y, 1.4285714285714286) and
               not GR:cell_is(pos.x, pos.y, TERRAIN_WATER)
end

local function valid_twister_node_nearby(pos)
    return P:valid_node_nearby(pos.x, pos.y, nil, NF_TWISTER) and
               GR:cell_is_only(pos.x, pos.y, bor(TERRAIN_LAND, TERRAIN_ICE))
end

local function valid_rally_node_nearby(pos)
    return GR:cell_is_only(pos.x, pos.y, bor(TERRAIN_LAND, TERRAIN_ICE)) and
               P:valid_node_nearby(pos.x, pos.y, nil, NF_RALLY)
end

return function(scripts)
    -- 杰拉尔德
    scripts.hero_gerald = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)
            this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
            this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]
            upgrade_skill(this, "block_counter", function(this, s)
                this.dodge.chance = this.dodge.chance_base + this.dodge.chance_inc * s.level
            end)
            upgrade_skill(this, "courage", function(this, s)
                this.timed_attacks.list[1].disabled = nil
            end)
            upgrade_skill(this, "paladin", function(this, s)
                local a = this.timed_attacks.list[2]
                a.disabled = nil
                local e = E:get_template(a.entity)
                e.health.hp_max = s.hp_max[s.level]
                a = e.melee.attacks[1]
                a.damage_min = s.melee_damage_min[s.level]
                a.damage_max = s.melee_damage_max[s.level]
                a = e.melee.attacks[2]
                a.damage_min = s.melee_damage_min[s.level]
                a.damage_max = s.melee_damage_max[s.level]
                e.motion.max_speed = s.max_speed[s.level]
            end)
            this.health.hp = this.health.hp_max
        end,

        fn_can_dodge = function(store, this, ranged_attack, attack, source)
            if (source and source.vis and band(source.vis.flags, F_BOSS) ~= 0) and math.random() >
                this.dodge.low_chance_factor then
                return false
            end
            return true
        end,

        update = function(this, store)
            local h = this.health
            local he = this.hero
            local courage = this.timed_attacks.list[1]
            local paladin = this.timed_attacks.list[2]
            local skill, brk, sta

            U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

            this.health_bar.hidden = false

            while true do
                if h.dead then
                    SU.y_hero_death_and_respawn(store, this)
                end

                if this.unit.is_stunned then
                    SU.soldier_idle(store, this)
                else
                    skill = this.hero.skills.block_counter

                    if skill.level > 0 and this.dodge and this.dodge.active then
                        this.dodge.active = false
                        this.dodge.counter_attack_pending = true

                        local la = this.dodge.last_attack
                        local ca = this.dodge.counter_attack

                        if la then
                            ca.damage_max = la.damage_max *
                                                (ca.reflected_damage_factor + ca.reflected_damage_factor_inc *
                                                    skill.level) * this.unit.damage_factor
                            ca.damage_min = la.damage_min *
                                                (ca.reflected_damage_factor + ca.reflected_damage_factor_inc *
                                                    skill.level) * this.unit.damage_factor
                        end

                        SU.hero_gain_xp_from_skill(this, skill)

                        goto label_39_0
                    end

                    while this.nav_rally.new do
                        if SU.y_hero_new_rally(store, this) then
                            goto label_39_1
                        end
                    end

                    if SU.hero_level_up(store, this) then
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    end

                    skill = this.hero.skills.paladin
                    if ready_to_use_skill(paladin, store) then
                        local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, nil, NF_RALLY)
                        if #nodes < 1 then
                            SU.delay_attack(store, paladin, 0.4)
                        else
                            U.animation_start(this, paladin.animation, nil, store.tick_ts)
                            S:queue(paladin.sound)
                            SU.hero_gain_xp_from_skill(this, skill)
                            paladin.ts = store.tick_ts
                            local pi, spi, ni = unpack(nodes[1])
                            local new_soldier = E:create_entity(paladin.entity)
                            local e_spi, e_ni = math.random(1, 3), ni
                            new_soldier.nav_rally.center = P:node_pos(pi, e_spi, e_ni)
                            new_soldier.nav_rally.pos = V.vclone(new_soldier.nav_rally.center)
                            new_soldier.pos = V.vclone(new_soldier.nav_rally.center)
                            new_soldier.owner = this
                            queue_insert(store, new_soldier)
                        end
                        SU.y_hero_animation_wait(this)
                        goto label_39_1
                    end

                    skill = this.hero.skills.courage
                    if ready_to_use_skill(courage, store) then
                        local triggers = U.find_soldiers_in_range(store.entities, this.pos, 0, courage.range,
                            courage.vis_flags, courage.vis_bans)

                        if not triggers or #triggers < courage.min_count then
                            SU.delay_attack(store, courage, 0.13333333333333333)
                        else
                            local start_ts = store.tick_ts
                            S:queue(courage.sound)
                            U.animation_start(this, courage.animation, nil, store.tick_ts)
                            if SU.y_hero_wait(store, this, courage.shoot_time) then
                                -- block empty
                            else
                                local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, courage.range,
                                    courage.vis_flags, courage.vis_bans)
                                if not targets then
                                    -- block empty
                                else
                                    courage.ts = start_ts
                                    SU.hero_gain_xp_from_skill(this, skill)
                                    for _, e in pairs(targets) do
                                        local mod = E:create_entity(courage.mod)
                                        mod.modifier.target_id = e.id
                                        mod.modifier.source_id = this.id
                                        mod.modifier.level = skill.level
                                        queue_insert(store, mod)
                                    end
                                    SU.y_hero_animation_wait(this)
                                    goto label_39_1
                                end
                            end
                        end
                    end

                    ::label_39_0::

                    brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)
                    if brk or sta ~= A_NO_TARGET then
                        -- block empty
                    elseif SU.soldier_go_back_step(store, this) then
                        -- block empty
                    else
                        SU.soldier_idle(store, this)
                        SU.soldier_regen(store, this)
                    end
                end

                ::label_39_1::
                coroutine.yield()
            end
        end
    }
    -- 艾莉瑞亚-野猫
    scripts.soldier_alleria_wildcat = {
        level_up = function(this, store, skill)
            local hp_factor = GS.difficulty_soldier_hp_max_factor[store.level_difficulty]
            this.health.hp_max = skill.hp_base + skill.hp_inc * skill.level * hp_factor
            this.health.hp = this.health.hp_max
            local at = this.melee.attacks[1]
            at.damage_max = skill.damage_max_base + skill.damage_inc * skill.level
            at.damage_min = skill.damage_min_base + skill.damage_inc * skill.level
        end,
        get_info = function(this)
            local min, max = this.melee.attacks[1].damage_min * this.unit.damage_factor,
                this.melee.attacks[1].damage_max * this.unit.damage_factor
            return {
                type = STATS_TYPE_SOLDIER,
                hp = this.health.hp,
                hp_max = this.health.hp_max,
                damage_min = min,
                damage_max = max,
                armor = this.health.armor,
                respawn = this.owner.timed_attacks.list[1].cooldown
            }
        end,
        insert = function(this, store)
            this.melee.order = U.attack_order(this.melee.attacks)
            return true
        end,
        update = function(this, store)
            local brk, sta
            U.y_animation_play(this, "spawn", nil, store.tick_ts)

            while true do
                if this.health.dead then
                    this.owner.timed_attacks.list[1].pet = nil
                    this.owner.timed_attacks.list[1].ts = store.tick_ts
                    SU.y_soldier_death(store, this)
                    return
                end

                if this.unit.is_stunned then
                    SU.soldier_idle(store, this)
                else
                    while this.nav_rally.new do
                        this.nav_grid.waypoints = GR:find_waypoints(this.pos, nil, this.nav_rally.pos,
                            this.nav_grid.valid_terrains)

                        if SU.y_hero_new_rally(store, this) then
                            goto label_35_0
                        end
                    end

                    brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                    if brk or sta ~= A_NO_TARGET then
                        goto label_35_0
                    end

                    if SU.soldier_go_back_step(store, this) then
                        -- block empty
                    else
                        SU.soldier_idle(store, this)
                        SU.soldier_regen(store, this)
                    end
                end

                ::label_35_0::
                coroutine.yield()
            end
        end
    }
    -- 艾莉瑞亚-分裂箭
    scripts.arrow_multishot_hero_alleria = {
        insert = function(this, store)
            if this.extra_arrows > 0 then
                local targets = U.find_enemies_in_range(store.entities, this.bullet.to, 0, this.extra_arrows_range,
                    F_RANGED, F_NONE)
                if targets then
                    local rate
                    if #targets > this.extra_arrows then
                        rate = this.extra_arrows
                    else
                        rate = #targets
                    end
                    local flight_time = fts(3 + 3 * rate)
                    for i = 1, this.extra_arrows do
                        local b = E:clone_entity(this)
                        b.extra_arrows = 0
                        local t
                        if targets[i] then
                            t = targets[i]
                        else
                            t = store.entities[this.bullet.target_id]
                            b.bullet.damage_min = 15
                            b.bullet.damage_max = 30
                        end
                        if t then
                            b.bullet.target_id = t.id
                            b.bullet.to = V.v(t.pos.x + t.unit.hit_offset.x, t.pos.y + t.unit.hit_offset.y)
                            b.bullet.flight_time = flight_time
                            b.bullet.damage_factor = this.bullet.damage_factor
                            queue_insert(store, b)
                        end
                    end
                    this.bullet.flight_time = flight_time
                end
            end
            return scripts.arrow.insert(this, store)
        end
    }
    -- 艾莉瑞亚
    scripts.hero_alleria = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)
            this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
            local bt = E:get_template(this.ranged.attacks[1].bullet)
            bt.bullet.damage_min = ls.ranged_damage_min[hl]
            bt.bullet.damage_max = ls.ranged_damage_max[hl]

            upgrade_skill(this, "multishot", function(this, s)
                local a = this.ranged.attacks[2]
                a.disabled = nil
                local b = E:get_template(a.bullet)
                b.extra_arrows = s.count_base + s.count_inc * s.level
            end)

            upgrade_skill(this, "callofwild", function(this, s)
                local a = this.timed_attacks.list[1]
                a.disabled = nil
                if a.pet then
                    a.pet.level = s.level
                    a.pet.fn_level_up(a.pet, store, s)
                end
            end)
            this.health.hp = this.health.hp_max
        end,
        update = function(this, store)
            local h = this.health
            local he = this.hero
            local a, skill, brk, sta

            local function get_wildcat_pos()
                local positions = P:get_all_valid_pos(this.nav_rally.pos.x, this.nav_rally.pos.y, a.min_range,
                    a.max_range, TERRAIN_LAND, nil, NF_RALLY)

                return positions[1]
            end

            U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
            this.health_bar.hidden = false
            while true do
                if h.dead then
                    SU.y_hero_death_and_respawn(store, this)
                end

                if this.unit.is_stunned then
                    SU.soldier_idle(store, this)
                else
                    while this.nav_rally.new do
                        a = this.timed_attacks.list[1]
                        if a.pet then
                            local pos = get_wildcat_pos()
                            if pos then
                                a.pet.nav_rally.center = pos
                                a.pet.nav_rally.pos = pos
                                a.pet.nav_rally.new = true
                            end
                        end
                        if SU.y_hero_new_rally(store, this) then
                            goto label_43_0
                        end
                    end

                    if SU.hero_level_up(store, this) then
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    end

                    a = this.timed_attacks.list[1]
                    skill = this.hero.skills.callofwild
                    if ready_to_use_skill(a, store) then
                        if a.pet then
                            SU.delay_attack(store, a, 0.25)
                        else
                            local spawn_pos = get_wildcat_pos()
                            if not spawn_pos then
                                SU.delay_attack(store, a, 0.25)
                            else
                                S:queue(a.sound)
                                this.health.immune_to = F_ALL
                                U.animation_start(this, a.animation, nil, store.tick_ts)
                                U.y_wait(store, a.spawn_time)
                                local e = E:create_entity(a.entity)
                                e.pos = V.vclone(spawn_pos)
                                e.nav_rally.pos = V.vclone(spawn_pos)
                                e.nav_rally.center = V.vclone(spawn_pos)
                                e.render.sprites[1].flip_x = math.random() < 0.5
                                e.owner = this
                                e.fn_level_up(e, store, skill)
                                queue_insert(store, e)
                                a.pet = e
                                U.y_animation_wait(this)
                                a.ts = store.tick_ts
                                this.health.immune_to = 0
                                SU.hero_gain_xp_from_skill(this, skill)
                                goto label_43_0
                            end
                        end
                    end

                    brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                    if brk or sta ~= A_NO_TARGET then
                        -- block empty
                    else
                        brk, sta = SU.y_soldier_ranged_attacks(store, this)

                        if brk then
                            -- block empty
                        elseif SU.soldier_go_back_step(store, this) then
                            -- block empty
                        else
                            SU.soldier_idle(store, this)
                            SU.soldier_regen(store, this)
                        end
                    end
                end

                ::label_43_0::
                coroutine.yield()
            end
        end
    }
    -- 幻影-攻击影子
    scripts.mirage_shadow = {
        insert = function(this, store, script)
            local b = this.bullet
            local target = store.entities[b.target_id]
            if not target then
                return false
            end
            b.to = V.vclone(target.pos)
            return true
        end,
        update = function(this, store, script)
            local b = this.bullet
            local target = store.entities[b.target_id]
            local start_ts = store.tick_ts
            local mspeed = U.frandom(b.min_speed, b.max_speed)
            while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
                target = store.entities[b.target_id]

                if not target or target.health.dead then
                    U.animation_start(this, "death", nil, store.tick_ts)
                    S:queue(this.sound_events.death)
                    local smoke = E:create_entity("fx_mirage_smoke")
                    smoke.pos = V.vclone(this.pos)
                    smoke.render.sprites[1].ts = store.tick_ts
                    queue_insert(store, smoke)
                    U.y_animation_wait(this)
                    queue_remove(store, this)
                    return
                end

                b.to.x, b.to.y = target.pos.x, target.pos.y
                b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
                this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length,
                    this.pos.y + b.speed.y * store.tick_length

                if V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) < mspeed * fts(8) then
                    if this.render.sprites[1].name ~= "attack" then
                        local an, af = U.animation_name_facing_point(this, "attack", b.to)

                        U.animation_start(this, an, af, store.tick_ts, false)
                    end
                else
                    local an, af = U.animation_name_facing_point(this, "running", b.to)
                    U.animation_start(this, an, af, store.tick_ts, true)
                end
                coroutine.yield()
            end

            S:queue(this.sound_events.hit)

            if target and not target.health.dead then
                local d = SU.create_bullet_damage(b, target.id, this.id)
                queue_damage(store, d)
            end

            if b.hit_fx and target.unit.blood_color then
                local fx = E:create_entity(b.hit_fx)
                fx.pos = V.vclone(target.pos)

                if target.unit.hit_offset then
                    fx.pos.x, fx.pos.y = fx.pos.x + target.unit.hit_offset.x, fx.pos.y + target.unit.hit_offset.y
                end

                fx.render.sprites[1].ts = store.tick_ts
                fx.render.sprites[1].flip_x = this.render.sprites[1].flip_x

                if fx.use_blood_color then
                    fx.render.sprites[1].name = target.unit.blood_color
                end

                queue_insert(store, fx)
            end

            queue_remove(store, this)
        end
    }
    -- 幻影-闪避影子
    scripts.soldier_mirage_illusion = {
        insert = function(this, store, script)
            this.lifespan.ts = store.tick_ts
            this.melee.order = U.attack_order(this.melee.attacks)
            return true
        end,
        update = function(this, store, script)
            local attack = this.melee.attacks[1]
            U.y_wait(store, attack.cooldown - fts(23))

            while true do
                if this.health.dead or store.tick_ts - this.lifespan.ts > this.lifespan.duration then
                    this.health.hp = 0

                    U.unblock_target(store, this)
                    U.animation_start(this, "idle", nil, store.tick_ts)
                    S:queue(this.sound_events.death)

                    local smoke = E:create_entity("fx_mirage_smoke")
                    smoke.pos = V.vclone(this.pos)
                    smoke.render.sprites[1].ts = store.tick_ts

                    queue_insert(store, smoke)

                    local enemies = U.find_enemies_in_range(store.entities, this.pos, 0, 20, F_AREA, 0)
                    if enemies then
                        for _, e in pairs(enemies) do
                            if e.health and not e.health.dead then
                                local d = SU.create_attack_damage(this.melee.attacks[1], e.id, this)
                                queue_damage(store, d)
                            end
                        end
                    end
                    U.y_wait(store, fts(4))
                    queue_remove(store, this)

                    return
                end

                SU.y_soldier_melee_block_and_attacks(store, this)
                coroutine.yield()
            end
        end
    }
    -- 幻影
    scripts.hero_mirage = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)

            this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

            local bt = E:get_template(this.ranged.attacks[1].bullet)
            bt.bullet.damage_min = ls.ranged_damage_min[hl]
            bt.bullet.damage_max = ls.ranged_damage_max[hl]

            upgrade_skill(this, "precision", function(this, s)
                -- this.ranged.attacks[1].max_range = this.ranged.attacks[1].max_range + s.extra_range[s.level]
                this.damage_buff = this.damage_buff + s.extra_buff[s.level]
            end)

            upgrade_skill(this, "shadowdodge", function(this, s)
                this.dodge.chance = s.dodge_chance[s.level]
                this.reward_shadowdance = s.reward_shadowdance[s.level]
                this.reward_lethalstrike = s.reward_lethalstrike[s.level]
                local e = E:get_template("soldier_mirage_illusion")
                e.lifespan.duration = s.lifespan[s.level]
            end)

            upgrade_skill(this, "swiftness", function(this, s)
                this.motion.max_speed = this.motion.max_speed * s.max_speed_factor[s.level]
                this.melee.range = this.melee.range * s.max_speed_factor[s.level]
            end)

            upgrade_skill(this, "shadowdance", function(this, s)
                this.timed_attacks.list[1].disabled = nil
                this.timed_attacks.list[1].burst = s.copies[s.level]
            end)

            upgrade_skill(this, "lethalstrike", function(this, s)
                local la = this.timed_attacks.list[2]
                la.disabled = nil
                la.instakill_chance = s.instakill_chance[s.level]
                la.damage_min = s.level * la.damage_min
                la.damage_max = s.level * la.damage_max
            end)
            this.health.hp = this.health.hp_max
        end,
        update = function(this, store, script)
            local h = this.health
            local he = this.hero
            local a_sd = this.timed_attacks.list[1]
            local s_sd = this.hero.skills.shadowdance
            local a_l = this.timed_attacks.list[2]
            local s_l = this.hero.skills.lethalstrike
            local brk, sta

            U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

            this.health_bar.hidden = false

            while true do
                if h.dead then
                    SU.y_hero_death_and_respawn(store, this)
                end

                if this.unit.is_stunned then
                    SU.soldier_idle(store, this)
                else
                    if this.dodge and this.dodge.chance > 0 and this.dodge.active then
                        this.dodge.active = false
                        this.health.immune_to = F_ALL
                        S:queue("HeroMirageShadowDodge")
                        U.animation_start(this, "disappear", nil, store.tick_ts, false)
                        U.y_wait(store, fts(3))

                        local smoke = E:create_entity("fx_mirage_smoke")

                        smoke.pos = V.vclone(this.pos)
                        smoke.render.sprites[1].ts = store.tick_ts

                        queue_insert(store, smoke)
                        U.y_animation_wait(this)

                        local enemy = store.entities[this.soldier.target_id]

                        if enemy and not enemy.health.dead then
                            local illu = E:create_entity("soldier_mirage_illusion")

                            illu.pos = V.vclone(this.pos)

                            queue_insert(store, illu)
                            U.replace_blocker(store, this, illu)

                            local enp = enemy.nav_path
                            local new_ni = enp.ni
                            local node_limit = 20
                            local node_jump = 12
                            local range

                            if node_jump < P:nodes_to_goal(enp) - node_limit then
                                range = {new_ni + node_jump, new_ni, -1}
                            elseif node_jump < P:nodes_from_start(enp) - node_limit then
                                range = {new_ni - node_jump, new_ni, 1}
                            else
                                goto label_296_0
                            end

                            for i = range[1], range[2], range[3] do
                                local n_pos = P:node_pos(enp.pi, enp.spi, i)

                                if P:is_node_valid(enp.pi, i) and GR:cell_is_only(n_pos.x, n_pos.y, TERRAIN_LAND) then
                                    new_ni = i

                                    break
                                end
                            end

                            ::label_296_0::

                            local new_pos = P:node_pos(enp.pi, enp.spi, new_ni)

                            this.pos.x, this.pos.y = new_pos.x, new_pos.y
                            this.nav_rally.center = V.vclone(this.pos)
                            this.nav_rally.pos = V.vclone(this.pos)
                        end

                        U.y_animation_play(this, "appear", nil, store.tick_ts)
                        this.health.immune_to = 0
                        if not this.dodge.from_ranged_attack then
                            if a_sd.ts then
                                a_sd.ts = a_sd.ts - a_sd.cooldown * this.reward_shadowdance
                            end
                            if a_l.ts then
                                a_l.ts = a_l.ts - a_l.cooldown * this.reward_lethalstrike
                            end
                        end
                        scripts.heal(this, this.health.hp_max * 0.1)
                        goto label_296_1
                    end

                    while this.nav_rally.new do
                        if SU.y_hero_new_rally(store, this) then
                            goto label_296_1
                        end
                    end

                    if SU.hero_level_up(store, this) then
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    end

                    if ready_to_use_skill(a_l, store) then
                        local target

                        if U.blocker_rank(store, this) ~= nil and U.is_blocked_valid(store, this) and
                            band(store.entities[this.soldier.target_id].vis.bans, a_l.vis_flags) == 0 then
                            target = store.entities[this.soldier.target_id]
                        else
                            target = U.find_random_enemy(store.entities, this.pos, 0, a_l.range, a_l.vis_flags,
                                a_l.vis_bans)
                        end

                        if not target or target.health.dead then
                            SU.delay_attack(store, a_l, 0.13333333333333333)
                        else
                            SU.hero_gain_xp_from_skill(this, s_l)
                            SU.stun_inc(target)
                            S:queue(this.sound_events.lethal_vanish)
                            this.health.immune_to = F_ALL
                            U.y_animation_play(this, "lethal_out", nil, store.tick_ts)
                            local initial_pos = V.vclone(this.pos)
                            local lpos, lflip = U.melee_slot_position(this, target, 1, true)

                            this.pos.x, this.pos.y = lpos.x, lpos.y
                            S:queue(a_l.sound)
                            U.animation_start(this, "lethal_attack", not lflip, store.tick_ts)
                            U.y_wait(store, a_l.hit_time)

                            if target and not target.health.dead then
                                local d = E:create_entity("damage")
                                d.source_id = this.id
                                d.target_id = target.id
                                if math.random() < a_l.instakill_chance then
                                    if band(target.vis.flags, F_BOSS) ~= 0 then
                                        d.damage_type = a_l.damage_type
                                        d.value = 2 * a_l.damage_max
                                    else
                                        d.pop = {"pop_instakill"}
                                        d.damage_type = DAMAGE_INSTAKILL
                                    end
                                else
                                    d.damage_type = a_l.damage_type
                                    d.value = a_l.damage_max
                                end
                                d.value = math.ceil(d.value * this.unit.damage_factor)
                                queue_damage(store, d)

                                if d.damage_type ~= DAMAGE_INSTAKILL and a_l.hit_fx and target.unit.blood_color then
                                    local fx = E:create_entity(a_l.hit_fx)
                                    fx.pos = V.vclone(target.pos)
                                    if target.unit.hit_offset then
                                        fx.pos.x = fx.pos.x + target.unit.hit_offset.x
                                        fx.pos.y = fx.pos.y + target.unit.hit_offset.y
                                    end
                                    fx.render.sprites[1].ts = store.tick_ts
                                    fx.render.sprites[1].flip_x = this.render.sprites[1].flip_x
                                    if fx.use_blood_color then
                                        fx.render.sprites[1].name = target.unit.blood_color
                                    end
                                    queue_insert(store, fx)
                                end
                            end

                            U.y_animation_wait(this)
                            SU.stun_dec(target)
                            S:queue(this.sound_events.lethal_vanish)

                            this.pos.x, this.pos.y = initial_pos.x, initial_pos.y

                            U.y_animation_play(this, "lethal_in", lflip, store.tick_ts)

                            this.health.immune_to = 0
                            a_l.ts = store.tick_ts

                            goto label_296_1
                        end
                    end

                    if ready_to_use_skill(a_sd, store) then
                        local targets = U.find_enemies_in_range(store.entities, this.pos, a_sd.min_range,
                            a_sd.max_range, a_sd.vis_flags, a_sd.vis_bans, function(v)
                                return (not GR:cell_is(v.pos.x, v.pos.y, TERRAIN_WATER)) and
                                           (not GR:cell_is(v.pos.x, v.pos.y, TERRAIN_FAERIE))
                            end)

                        if targets then
                            a_sd.ts = store.tick_ts
                            S:queue(a_sd.sound)
                            this.health.immune_to = F_ALL
                            U.animation_start(this, a_sd.animation, nil, store.tick_ts)

                            while store.tick_ts - a_sd.ts < a_sd.shoot_time do
                                if this.nav_rally.new then
                                    goto label_296_1
                                end

                                if this.health.dead then
                                    goto label_296_1
                                end

                                if this.unit.is_stunned then
                                    goto label_296_1
                                end

                                coroutine.yield()
                            end

                            SU.hero_gain_xp_from_skill(this, s_sd)

                            local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a_sd.max_range * 1.5,
                                a_sd.vis_flags, a_sd.vis_bans, function(v)
                                    return (not GR:cell_is(v.pos.x, v.pos.y, TERRAIN_WATER)) and
                                               (not GR:cell_is(v.pos.x, v.pos.y, TERRAIN_FAERIE))
                                end)

                            if targets then
                                for i = 1, a_sd.burst do
                                    local target = table.random(targets)
                                    local b = E:create_entity(a_sd.bullet)
                                    b.bullet.damage_factor = this.unit.damage_factor
                                    b.pos.x, b.pos.y = this.pos.x, this.pos.y
                                    b.bullet.target_id = target.id
                                    b.bullet.source_id = this.id
                                    b.bullet.level = s_sd.level

                                    queue_insert(store, b)
                                end
                            end

                            while not U.animation_finished(this) do
                                if this.nav_rally.new then
                                    goto label_296_1
                                end

                                if this.health.dead then
                                    goto label_296_1
                                end

                                if this.unit.is_stunned then
                                    goto label_296_1
                                end

                                coroutine.yield()
                            end
                            this.health.immune_to = 0
                            a_sd.ts = store.tick_ts

                            goto label_296_1
                        end
                    end

                    brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                    if sta ~= A_IN_COOLDOWN and (brk or sta ~= A_NO_TARGET) then
                        -- block empty
                    else
                        brk, sta = SU.y_soldier_ranged_attacks(store, this)

                        if brk or sta ~= A_NO_TARGET then
                            -- block empty
                        elseif SU.soldier_go_back_step(store, this) then
                            -- block empty
                        else
                            SU.soldier_idle(store, this)
                            SU.soldier_regen(store, this)
                        end
                    end
                end
                ::label_296_1::
                coroutine.yield()
            end
        end
    }
    -- 纽维斯-攻击
    scripts.ray_wizard_chain = {
        insert = function(this, store, script)
            if not store.entities[this.bullet.target_id] then
                return false
            end
            return true
        end,
        update = function(this, store, script)
            local b = this.bullet
            local s = this.render.sprites[1]
            local target = store.entities[b.target_id]
            local dest = b.to
            local ho = V.v(0, 0)

            s.scale = V.v(1, 1)

            local function update_sprite()
                if target and target.motion then
                    if target.unit and target.unit.hit_offset and not b.ignore_hit_offset then
                        ho.x, ho.y = target.unit.hit_offset.x, target.unit.hit_offset.y
                    else
                        ho.x, ho.y = 0, 0
                    end

                    local d = math.max(math.abs(target.pos.x + ho.x - dest.x), math.abs(target.pos.y + ho.y - dest.y))

                    if d > b.max_track_distance then
                        log.paranoid("(%s) ray_wizard_chain target (%s) out of max_track_distance", this.id, target.id)

                        target = nil
                    else
                        dest.x, dest.y = target.pos.x + ho.x, target.pos.y + ho.y
                    end
                end

                local angle = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)

                s.r = angle
                s.scale.x = V.dist(dest.x, dest.y, this.pos.x, this.pos.y) / this.image_width
            end

            s.ts = store.tick_ts

            update_sprite()

            local fx = SU.insert_sprite(store, b.hit_fx, dest)

            if target then
                fx.pos = target.pos

                if target.unit and target.unit.hit_offset then
                    fx.render.sprites[1].offset = V.vclone(target.unit.hit_offset)
                end
            end

            if target then
                if not b.mods then
                    b.mods = {b.mod}
                end

                for _, modname in pairs(b.mods) do
                    local mod = E:create_entity(modname)
                    mod.modifier.source_id = b.source_id
                    mod.modifier.target_id = target.id
                    mod.xp_gain_factor = b.xp_gain_factor
                    mod.xp_dest_id = b.source_id
                    mod.modifier.damage_factor = b.damage_factor
                    queue_insert(store, mod)
                end

                table.insert(this.seen_targets, target.id)

                if this.bounces > 0 then
                    local bounce_target = U.find_nearest_enemy(store.entities, target.pos, 0, this.bounce_range,
                        this.bounce_vis_flags, this.bounce_vis_bans, function(v)
                            return not table.contains(this.seen_targets, v.id)
                        end)

                    if bounce_target then
                        log.paranoid("bounce from %s to %s dist:%s", target.id, bounce_target.id,
                            V.dist(dest.x, dest.y, bounce_target.pos.x, bounce_target.pos.y))

                        local r = E:create_entity(this.template_name)
                        r.pos = V.vclone(dest)
                        r.bullet.to = V.vclone(bounce_target.pos)

                        if not b.ignore_hit_offset and bounce_target.unit and bounce_target.unit.hit_offset then
                            r.bullet.to.x = r.bullet.to.x + bounce_target.unit.hit_offset.x
                            r.bullet.to.y = r.bullet.to.y + bounce_target.unit.hit_offset.y
                        end
                        r.bullet.damage_factor = b.damage_factor
                        r.bullet.target_id = bounce_target.id
                        r.bullet.source_id = b.source_id
                        r.bounces = this.bounces - 1
                        r.seen_targets = this.seen_targets

                        queue_insert(store, r)
                    end
                end
            end

            while not U.animation_finished(this) do
                update_sprite()
                coroutine.yield()
            end

            queue_remove(store, this)
        end
    }
    -- 纽维斯-攻击伤害
    scripts.mod_ray_wizard = {
        insert = function(this, store, script)
            local target = store.entities[this.modifier.target_id]
            if not target or not target.health or target.health.dead then
                return false
            end
            this.modifier.ts = store.tick_ts
            return true
        end,
        update = function(this, store, script)
            local m = this.modifier
            local target = store.entities[m.target_id]
            local total_damage = math.ceil(math.random(this.damage_min, this.damage_max) * m.damage_factor)
            local final_damage = km.clamp(0, total_damage, total_damage - target.health.hp)
            local steps = math.floor(m.duration / this.damage_every)
            local step_damage = math.ceil((total_damage - final_damage) / steps)
            local step = 0
            local last_ts = m.ts
            local tick_steps, cycle_damage, d

            if not target then
                queue_remove(store, this)

                return
            end

            this.pos = target.pos

            while true do
                target = store.entities[m.target_id]

                if not target or target.health.dead then
                    queue_remove(store, this)

                    return
                end

                tick_steps = math.floor((store.tick_ts - last_ts) / this.damage_every)

                if tick_steps < 1 then
                    -- block empty
                else
                    step = step + tick_steps
                    last_ts = last_ts + tick_steps * this.damage_every
                    cycle_damage = step_damage * tick_steps

                    if steps <= step then
                        cycle_damage = cycle_damage + final_damage
                    end

                    d = E:create_entity("damage")
                    d.source_id = this.id
                    d.target_id = target.id
                    d.value = cycle_damage
                    d.damage_type = this.damage_type
                    d.pop = this.pop
                    d.pop_chance = this.pop_chance
                    d.pop_conds = this.pop_conds
                    d.xp_gain_factor = this.xp_gain_factor
                    d.xp_dest_id = this.xp_dest_id

                    queue_damage(store, d)

                    if steps <= step then
                        queue_remove(store, this)

                        return
                    end
                end

                coroutine.yield()
            end
        end
    }
    -- 纽维斯-导弹
    scripts.missile_wizard = {
        insert = function(this, store)
            local b = this.bullet
            if not store.entities[b.target_id] then
                return false
            end
            b.to = V.v(this.pos.x + math.random(10, 90) * (math.random() < 0.5 and -1 or 1),
                this.pos.y + math.random(100, 300))

            local ps = E:create_entity("ps_missile_wizard")
            ps.particle_system.track_id = this.id
            queue_insert(store, ps)
            for i = 1, 3 do
                local pss = E:create_entity("ps_missile_wizard_sparks")
                pss.particle_system.name = "missile_wizard_sparks" .. i
                pss.particle_system.track_id = this.id
                pss.particle_system.emit_ts = store.tick_ts + i / (3 * pss.particle_system.emission_rate)
                queue_insert(store, pss)
            end
            return true
        end
    }
    -- 纽维斯
    scripts.hero_wizard = {
        get_info = function(this)
            local m = E:get_template("mod_ray_wizard")
            local ranged_min, ranged_max = (m.damage_min + this.damage_buff) * this.unit.damage_factor,
                (m.damage_max + this.damage_buff) * this.unit.damage_factor
            local melee_min = (this.melee.attacks[1].damage_min + this.damage_buff) * this.unit.damage_factor
            local melee_max = (this.melee.attacks[1].damage_max + this.damage_buff) * this.unit.damage_factor
            local ranged_damage_type = DAMAGE_MAGICAL
            local melee_damage_type = this.melee.attacks[1].damage_type
            return {
                type = STATS_TYPE_SOLDIER,
                hp = this.health.hp,
                hp_max = this.health.hp_max,
                damage_min = melee_min,
                damage_max = melee_max,
                damage_type = melee_damage_type,
                ranged_damage_min = ranged_min,
                ranged_damage_max = ranged_max,
                ranged_damage_type = ranged_damage_type,
                armor = this.health.armor,
                respawn = this.health.dead_lifetime
            }
        end,
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)

            local mage_tower_types = {"mage", "archmage", "sorcerer", "sunray", "arcane_wizard", "necromancer"}
            local mage_towers = table.filter(store.entities, function(_, e)
                return e.tower and table.contains(mage_tower_types, e.tower.type)
            end)
            this.mage_tower_count = #mage_towers

            this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

            upgrade_skill(this, "magicmissile", function(this, s)
                local a = this.timed_attacks.list[2]
                a.disabled = nil
                a.loops = s.count[s.level]
                local b = E:get_template("missile_wizard")
                b.bullet.damage_max = s.damage[s.level] + this.mage_tower_count
                b.bullet.damage_min = s.damage[s.level] + this.mage_tower_count
            end)

            upgrade_skill(this, "chainspell", function(this, s)
                local a = this.ranged.attacks[2]
                a.disabled = nil
                local b = E:get_template("ray_wizard_chain")
                b.bounces = s.bounces[s.level]
            end)

            upgrade_skill(this, "disintegrate", function(this, s)
                local a = this.timed_attacks.list[1]
                a.disabled = nil
                a.total_damage = s.total_damage[s.level] + this.mage_tower_count * 15
                a.count = s.count[s.level]
            end)

            upgrade_skill(this, "arcanereach", function(this, s)
                local factor = 1 + s.extra_range_factor[s.level]
                this.ranged.attacks[1].max_range = this.ranged.attacks[1].max_range * factor
                this.ranged.attacks[2].max_range = this.ranged.attacks[2].max_range * factor
            end)

            upgrade_skill(this, "arcanefocus", function(this, s)
                this.arcanefocus_extra = s.extra_damage[s.level]
            end)

            local m = E:get_template("mod_ray_wizard")
            m.damage_max = ls.ranged_damage_max[hl] + this.mage_tower_count * 4 + this.arcanefocus_extra
            m.damage_min = ls.ranged_damage_min[hl] + this.mage_tower_count * 4 + this.arcanefocus_extra

            this.health.hp = this.health.hp_max
        end,
        update = function(this, store, script)
            local h = this.health
            local he = this.hero
            local a, skill, brk, sta

            U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

            this.health_bar.hidden = false

            while true do
                if h.dead then
                    SU.y_hero_death_and_respawn(store, this)
                end

                if this.unit.is_stunned then
                    SU.soldier_idle(store, this)
                else
                    while this.nav_rally.new do
                        if SU.y_hero_new_rally(store, this) then
                            goto label_326_0
                        end
                    end

                    if SU.hero_level_up(store, this) then
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    end

                    a = this.timed_attacks.list[1]
                    skill = this.hero.skills.disintegrate

                    if ready_to_use_skill(a, store) then
                        local triggers = U.find_enemies_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags,
                            a.vis_bans, function(v)
                                return v.health.hp <= a.total_damage
                            end)

                        if not triggers then
                            SU.delay_attack(store, a, 0.13333333333333333)
                        else
                            local remaining_damage = a.total_damage * this.unit.damage_factor

                            local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.damage_radius,
                                a.vis_flags, a.vis_bans, function(v)
                                    return v.health.hp <= remaining_damage
                                end)

                            if not targets then
                                SU.delay_attack(store, a, 0.13333333333333333)

                                goto label_326_0
                            end

                            a.ts = store.tick_ts

                            SU.hero_gain_xp_from_skill(this, skill)
                            S:queue(a.sound)
                            U.animation_start(this, a.animation, nil, store.tick_ts)
                            U.y_wait(store, a.hit_time)

                            local count = a.count

                            for _, t in pairs(targets) do
                                if remaining_damage <= 0 or count == 0 then
                                    break
                                end

                                if remaining_damage >= t.health.hp then
                                    remaining_damage = remaining_damage - t.health.hp
                                    count = count - 1

                                    local d = E:create_entity("damage")

                                    d.damage_type = DAMAGE_EAT
                                    d.target_id = t.id
                                    d.source_id = this.id

                                    queue_damage(store, d)

                                    local fx = E:create_entity("fx_wizard_disintegrate")

                                    fx.pos.x, fx.pos.y = t.pos.x + t.unit.hit_offset.x, t.pos.y + t.unit.hit_offset.y
                                    fx.render.sprites[1].ts = store.tick_ts

                                    queue_insert(store, fx)
                                end
                            end

                            U.y_animation_wait(this)

                            goto label_326_0
                        end
                    end

                    a = this.timed_attacks.list[2]
                    skill = this.hero.skills.magicmissile

                    if ready_to_use_skill(a, store) then
                        local target = U.find_foremost_enemy(store.entities, this.pos, a.min_range, a.max_range, false,
                            a.vis_flags, a.vis_bans)

                        if target then
                            local start_ts = store.tick_ts
                            this.health.immune_to = F_ALL
                            if SU.y_soldier_do_loopable_ranged_attack(store, this, target, a) then
                                a.ts = start_ts
                                SU.hero_gain_xp_from_skill(this, skill)
                            end
                            this.health.immune_to = 0
                            goto label_326_0
                        end
                    end

                    brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                    if brk or U.is_blocked_valid(store, this) then
                        -- block empty
                    else
                        brk, sta = SU.y_soldier_ranged_attacks(store, this)

                        if brk then
                            -- block empty
                        elseif SU.soldier_go_back_step(store, this) then
                            -- block empty
                        else
                            SU.soldier_idle(store, this)
                            SU.soldier_regen(store, this)
                        end
                    end
                end

                ::label_326_0::

                coroutine.yield()
            end
        end
    }
    -- 阿尔里奇-沙兵
    scripts.soldier_sand_warrior = {
        get_info = function(this)
            local t = scripts.soldier_barrack.get_info(this)
            t.respawn = nil
            return t
        end,
        insert = function(this, store, script)
            this.melee.order = U.attack_order(this.melee.attacks)
            this.health.hp_max = this.health.hp_max + this.health.hp_inc * this.unit.level
            local node_offset = math.random(3, 6)
            this.nav_path.ni = this.nav_path.ni + node_offset
            this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
            if not this.pos then
                return false
            end
            return true
        end,
        update = function(this, store, script)
            local attack = this.melee.attacks[1]
            local target
            local expired = false
            local next_pos = V.vclone(this.pos)
            local brk, sta, nearest

            this.lifespan.ts = store.tick_ts

            U.y_animation_play(this, "raise", nil, store.tick_ts, 1)

            while true do
                if this.health.dead or store.tick_ts - this.lifespan.ts > this.lifespan.duration then
                    this.health.hp = 0
                    SU.y_soldier_death(store, this)
                    queue_remove(store, this)
                    return
                end

                if this.unit.is_stunned then
                    U.animation_start(this, "idle", nil, store.tick_ts, -1)
                else
                    brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                    if brk or sta ~= A_NO_TARGET then
                        -- block empty
                    else
                        nearest = P:nearest_nodes(this.pos.x, this.pos.y, {this.nav_path.pi}, {this.nav_path.spi})

                        if nearest and nearest[1] and nearest[1][3] < this.nav_path.ni then
                            this.nav_path.ni = nearest[1][3]
                        end

                        U.y_animation_play(this, "start_walk", nil, store.tick_ts, 1)

                        while next_pos and not target and not this.health.dead and not expired and
                            not this.unit.is_stunned do
                            U.set_destination(this, next_pos)

                            local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

                            U.animation_start(this, an, af, store.tick_ts, -1)
                            U.walk(this, store.tick_length)
                            coroutine.yield()

                            target = U.find_foremost_enemy(store.entities, this.pos, 0, this.melee.range, false,
                                attack.vis_flags, attack.vis_bans)
                            expired = store.tick_ts - this.lifespan.ts > this.lifespan.duration
                            next_pos = P:next_entity_node(this, store.tick_length)

                            if not next_pos or not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) or
                                GR:cell_is(next_pos.x, next_pos.y,
                                    bor(TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK, TERRAIN_FAERIE)) then
                                next_pos = nil
                            end
                        end
                        target = nil
                        if expired or this.health.dead or not next_pos then
                            this.health.hp = 0
                            U.y_animation_play(this, "death_travel", nil, store.tick_ts, 1)
                            queue_remove(store, this)
                        end
                    end
                end

                coroutine.yield()
            end
        end
    }
    -- 阿尔里奇
    scripts.hero_alric = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)

            upgrade_skill(this, "swordsmanship", function(this, s)
                this.swordsmanship_extra = s.extra_damage[s.level]
            end)

            upgrade_skill(this, "spikedarmor", function(this, s)
                if this.health.spiked_armor then
                    this.health.spiked_armor = this.health.spiked_armor + s.values[s.level]
                else
                    this.health.spiked_armor = s.values[s.level]
                end
            end)

            upgrade_skill(this, "toughness", function(this, s)
                this.toughness_hp_extra = s.hp_max[s.level]
                this.toughness_regen_extra = s.regen[s.level]
            end)

            upgrade_skill(this, "flurry", function(this, s)
                this.melee.attacks[3].disabled = nil
                this.melee.attacks[3].cooldown = s.cooldown[s.level]
                this.melee.attacks[3].loops = s.loops[s.level]

            end)

            upgrade_skill(this, "sandwarriors", function(this, s)
                this.timed_attacks.list[1].disabled = nil
                local e = E:get_template(this.timed_attacks.list[1].entity)
                e.lifespan.duration = s.lifespan[s.level]
            end)

            for i = 1, 3 do
                this.melee.attacks[i].damage_min = ls.melee_damage_min[hl] + this.swordsmanship_extra
                this.melee.attacks[i].damage_max = ls.melee_damage_max[hl] + this.swordsmanship_extra
            end
            this.health.hp_max = this.health.hp_max + this.toughness_hp_extra
            update_regen(this)
            this.health.hp = this.health.hp_max
        end,
        update = function(this, store, script)
            local h = this.health
            local he = this.hero
            local swa = this.timed_attacks.list[1]
            local sws = this.hero.skills.sandwarriors
            local brk, sta

            U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

            this.health_bar.hidden = false

            while true do
                if h.dead then
                    SU.y_hero_death_and_respawn(store, this)
                end

                if this.unit.is_stunned then
                    SU.soldier_idle(store, this)
                else
                    while this.nav_rally.new do
                        if SU.y_hero_new_rally(store, this) then
                            goto label_289_0
                        end
                    end

                    if SU.hero_level_up(store, this) then
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    end

                    if ready_to_use_skill(swa, store) then
                        local target_info = U.find_enemies_in_paths(store.entities, this.pos, 0, swa.range_nodes, nil,
                            swa.vis_flags, swa.vis_bans, true)

                        if target_info then
                            local target = target_info[1].target
                            local origin = target_info[1].origin
                            local start_ts = store.tick_ts

                            S:queue(swa.sound)
                            U.animation_start(this, swa.animation, nil, store.tick_ts, 1)

                            while store.tick_ts - start_ts < swa.spawn_time do
                                if this.nav_rally.new then
                                    goto label_289_0
                                end

                                if this.health.dead then
                                    goto label_289_0
                                end

                                if this.unit.is_stunned then
                                    goto label_289_0
                                end

                                coroutine.yield()
                            end

                            swa.ts = start_ts

                            SU.hero_gain_xp_from_skill(this, sws)

                            for i = 1, sws.count[sws.level] do
                                local spawn = E:create_entity(swa.entity)

                                spawn.nav_path.pi = origin[1]
                                spawn.nav_path.spi = km.zmod(i, 3)
                                spawn.nav_path.ni = origin[3]
                                spawn.unit.level = sws.level

                                queue_insert(store, spawn)
                            end

                            while not U.animation_finished(this) do
                                if this.nav_rally.new then
                                    goto label_289_0
                                end

                                if this.health.dead then
                                    goto label_289_0
                                end

                                if this.unit.is_stunned then
                                    goto label_289_0
                                end

                                coroutine.yield()
                            end
                        else
                            swa.ts = store.tick_ts + 0.2
                        end
                    end

                    brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                    if brk or sta ~= A_NO_TARGET then
                        -- block empty
                    elseif SU.soldier_go_back_step(store, this) then
                        -- block empty
                    else
                        SU.soldier_idle(store, this)
                        SU.soldier_regen(store, this)
                    end
                end
                ::label_289_0::
                coroutine.yield()
            end
        end
    }
    -- 博林-地雷
    scripts.decal_bolin_mine = {
        update = function(this, store)
            local ts = store.tick_ts

            while true do
                if store.tick_ts - ts >= this.duration then
                    break
                end

                local targets = U.find_enemies_in_range(store.entities, this.pos, 0, this.radius, this.vis_flags,
                    this.vis_bans)

                if targets and #targets > 0 then
                    local dec = E:create_entity(this.hit_decal)

                    dec.pos = V.vclone(this.pos)
                    dec.render.sprites[1].ts = store.tick_ts

                    queue_insert(store, dec)
                    S:queue(this.sound)

                    local fx = E:create_entity(this.hit_fx)

                    fx.pos = V.vclone(this.pos)
                    fx.render.sprites[1].ts = store.tick_ts

                    queue_insert(store, fx)
                    local new_targets = U.find_enemies_in_range(store.entities, this.pos, 0, 2 * this.radius,
                        this.vis_flags, this.vis_bans)
                    for _, t in ipairs(new_targets) do
                        local d = E:create_entity("damage")
                        d.damage_type = DAMAGE_EXPLOSION
                        d.source_id = this.id
                        d.target_id = t.id
                        d.value = math.random(this.damage_min, this.damage_max)
                        queue_damage(store, d)
                    end

                    break
                end

                U.y_wait(store, this.check_interval)
            end

            queue_remove(store, this)
        end
    }
    -- 博林
    scripts.hero_bolin = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)

            this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
            local rf = this.timed_attacks.list[1]
            local b = E:get_template(rf.bullet)
            b.bullet.damage_min = ls.ranged_damage_min[hl]
            b.bullet.damage_max = ls.ranged_damage_max[hl]

            upgrade_skill(this, "tar", function(this, s)
                local a = this.timed_attacks.list[2]
                a.disabled = nil
                local tar = E:get_template("aura_bolin_tar")
                tar.duration = s.duration[s.level]
            end)

            upgrade_skill(this, "mines", function(this, s)
                local a = this.timed_attacks.list[3]
                a.disabled = nil
                local m = E:get_template("decal_bolin_mine")
                m.damage_min = s.damage_min[s.level]
                m.damage_max = s.damage_max[s.level]
            end)

            this.health.hp = this.health.hp_max
        end,
        update = function(this, store)
            local h = this.health
            local he = this.hero
            local a, skill, brk, sta
            local shoot_count = 0

            U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)

            this.health_bar.hidden = false

            while true do
                if h.dead then
                    SU.y_hero_death_and_respawn(store, this)
                end

                if this.unit.is_stunned then
                    SU.soldier_idle(store, this)
                else
                    while this.nav_rally.new do
                        if SU.y_hero_new_rally(store, this) then
                            goto label_47_0
                        end
                    end

                    if SU.hero_level_up(store, this) then
                        U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)
                    end

                    a = this.timed_attacks.list[2]
                    skill = this.hero.skills.tar

                    if ready_to_use_skill(a, store) then
                        local target = U.find_random_enemy(store.entities, this.pos, a.min_range, a.max_range,
                            a.vis_flags, a.vis_bans)

                        if not target then
                            SU.delay_attack(store, a, 0.5)
                        else
                            local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + 5

                            if not P:is_node_valid(pi, ni) then
                                ni = target.nav_path.ni
                            end

                            if not P:is_node_valid(pi, ni) then
                                SU.delay_attack(store, a, 0.5)
                            else
                                local start_ts = store.tick_ts
                                local flip = target.pos.x < this.pos.x

                                U.animation_start(this, "tar", flip, store.tick_ts)
                                SU.hero_gain_xp_from_skill(this, skill)

                                if U.y_wait(store, a.shoot_time, function()
                                    return SU.hero_interrupted(this)
                                end) then
                                    -- block empty
                                else
                                    a.ts = start_ts

                                    local af = this.render.sprites[1].flip_x
                                    local b = E:create_entity(a.bullet)
                                    local o = a.bullet_start_offset

                                    b.bullet.from = V.v(this.pos.x + (af and -1 or 1) * o.x, this.pos.y + o.y)
                                    b.bullet.to = P:node_pos(pi, spi, ni)
                                    b.pos = V.vclone(b.bullet.from)
                                    b.bullet.source_id = this.id

                                    queue_insert(store, b)

                                    if not U.y_animation_wait(this) then
                                        goto label_47_0
                                    end
                                end
                            end
                        end
                    end

                    a = this.timed_attacks.list[3]
                    skill = this.hero.skills.mines

                    if ready_to_use_skill(a, store) then
                        local nearest = P:nearest_nodes(this.pos.x, this.pos.y)

                        if not nearest or #nearest < 1 then
                            SU.delay_attack(store, a, 0.5)
                        else
                            local mine_pos
                            local _, enemy_pos = U.find_random_enemy_with_pos(store.entities, this.pos, a.min_range,
                                a.max_range, fts(24), a.vis_flags, a.vis_bans)
                            if enemy_pos then
                                mine_pos = enemy_pos
                            end

                            if not mine_pos then
                                local pi, spi, ni = unpack(nearest[1])
                                spi = math.random(1, 3)
                                local no = math.random(a.node_offset[1], a.node_offset[2])
                                ni = ni + no
                                if not P:is_node_valid(pi, ni) then
                                    ni = ni - no
                                end
                                mine_pos = P:node_pos(pi, spi, ni)
                            end

                            local start_ts = store.tick_ts
                            local flip = mine_pos.x < this.pos.x

                            U.animation_start(this, "mine", flip, store.tick_ts)
                            SU.hero_gain_xp_from_skill(this, skill)

                            if U.y_wait(store, a.shoot_time, function()
                                return SU.hero_interrupted(this)
                            end) then
                                -- block empty
                            else
                                a.ts = start_ts

                                local af = this.render.sprites[1].flip_x
                                local b = E:create_entity(a.bullet)
                                local o = a.bullet_start_offset

                                b.bullet.from = V.v(this.pos.x + (af and -1 or 1) * o.x, this.pos.y + o.y)
                                b.bullet.to = mine_pos
                                b.pos = V.vclone(b.bullet.from)
                                b.bullet.source_id = this.id

                                queue_insert(store, b)

                                if not U.y_animation_wait(this) then
                                    goto label_47_0
                                end
                            end
                        end
                    end

                    brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                    if brk or sta ~= A_NO_TARGET then
                        -- block empty
                    else
                        -- 连射或普攻
                        if math.random() < this.timed_attacks.list[4].chance then
                            a = this.timed_attacks.list[4]
                        else
                            a = this.timed_attacks.list[1]
                        end
                        if ready_to_attack(a, store) then
                            local target, _, pred_pos = U.find_foremost_enemy(store.entities, this.pos, a.min_range,
                                a.max_range, a.node_prediction, a.vis_flags, a.vis_bans, a.filter_fn, F_FLYING)

                            if not target then
                                -- block empty
                            else
                                local flip = target.pos.x < this.pos.x
                                local b, an, af, ai

                                an, af, ai = U.animation_name_facing_point(this, a.aim_animation, target.pos)

                                U.animation_start(this, an, af, store.tick_ts, 1)
                                U.set_destination(this, this.pos)

                                for si, st in pairs(a.shoot_times) do
                                    if U.y_wait(store, a.shoot_times[si], function()
                                        return SU.hero_interrupted(this)
                                    end) then
                                        goto label_47_0
                                    end

                                    if not target then
                                        -- block empty
                                    end

                                    local target_dist = V.dist(target.pos.x, target.pos.y, this.pos.x, this.pos.y)

                                    if si > 1 and
                                        (not target or target.health.death or not target_dist or
                                            not (target_dist >= a.min_range) or target_dist <= a.max_range or true) then
                                        target, _, pred_pos =
                                            U.find_foremost_enemy(store.entities, this.pos, a.min_range, a.max_range,
                                                a.node_prediction, a.vis_flags, a.vis_bans, a.filter_fn, F_FLYING)

                                        if not target then
                                            break
                                        end
                                    end

                                    an, af, ai = U.animation_name_facing_point(this, a.shoot_animation, target.pos)

                                    U.animation_start(this, an, af, store.tick_ts, 1)

                                    if U.y_wait(store, a.shoot_time, function()
                                        return SU.hero_interrupted(this)
                                    end) then
                                        goto label_47_0
                                    end

                                    b = E:create_entity(a.bullet)
                                    b.pos = V.vclone(this.pos)
                                    b.bullet.damage_type = a.damage_type
                                    if a.chance then
                                        b.bullet.damage_min = b.bullet.damage_max
                                        b.bullet.pop = {"pop_splat"}
                                    end
                                    if a.bullet_start_offset then
                                        local offset = a.bullet_start_offset[ai]
                                        b.pos.x, b.pos.y = b.pos.x + (af and -1 or 1) * offset.x, b.pos.y + offset.y
                                    end

                                    b.bullet.from = V.vclone(b.pos)
                                    b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x,
                                        target.pos.y + target.unit.hit_offset.y)
                                    b.bullet.target_id = target.id
                                    b.bullet.shot_index = si
                                    b.bullet.source_id = this.id
                                    b.bullet.xp_dest_id = this.id
                                    b.bullet.damage_factor = this.unit.damage_factor

                                    queue_insert(store, b)
                                end

                                U.y_animation_wait(this)

                                a.ts = store.tick_ts

                                U.animation_start(this, "reload", nil, store.tick_ts)

                                if U.y_animation_wait(this) then
                                    goto label_47_0
                                end
                            end
                        end

                        if SU.soldier_go_back_step(store, this) then
                            -- block empty
                        else
                            SU.soldier_idle(store, this)
                            SU.soldier_regen(store, this)
                        end
                    end
                end
                ::label_47_0::
                coroutine.yield()
            end
        end
    }
    -- 迪纳斯-火球
    scripts.denas_catapult_controller = {
        update = function(this, store)
            local w = store.visible_coords.right - store.visible_coords.left
            local rock_x = this.pos.x > w / 2 and store.visible_coords.right + this.rock_offset.x or
                               store.visible_coords.left - this.rock_offset.x
            local rock_y = this.pos.y + this.rock_offset.y
            local a = this.initial_angle

            U.y_wait(store, this.initial_delay)

            local delay = 0

            for i = 1, math.random(2, 4) do
                S:queue(this.sound_events.shoot, {
                    delay = delay
                })

                delay = delay + U.frandom(0.1, 0.3)
            end

            for i = 1, this.count do
                U.y_wait(store, U.frandom(unpack(this.rock_delay)))

                local r = U.frandom(0, 1) * 40 + 20
                local bullet = E:create_entity(this.bullet)
                bullet.pos = V.v(rock_x, rock_y)
                bullet.bullet.from = V.vclone(bullet.pos)
                bullet.bullet.to = U.point_on_ellipse(this.pos, r, a)
                bullet.bullet.target_id = nil
                bullet.bullet.source_id = this.id
                bullet.bullet.damage_factor = this.damage_factor
                queue_insert(store, bullet)
                a = a + this.angle_increment
            end

            U.y_wait(store, this.exit_time)

            this.tween.reverse = true
            this.tween.remove = true
            this.tween.ts = store.tick_ts
        end
    }
    -- 迪纳斯-施加buff特效
    scripts.denas_cursing = {
        update = function(this, store)
            this.render.sprites[1].ts = store.tick_ts

            local source = store.entities[this.source_id]
            local source_pos = source and V.vclone(source.pos) or nil
            local ts = store.tick_ts

            if not source or not source.health or source.health.dead then
                -- block empty
            else
                this.pos = V.vclone(source.pos)
                this.pos.x = this.pos.x + this.offset.x
                this.pos.y = this.pos.y + this.offset.y
                this.render.sprites[1].flip_x = source.render.sprites[1].flip_x

                while store.tick_ts - ts < this.duration do
                    if source.pos.x ~= source_pos.x or source.pos.y ~= source_pos.y or source.health.death then
                        break
                    end
                    coroutine.yield()
                end
            end
            queue_remove(store, this)
        end
    }
    -- 迪纳斯-被buff塔特效
    scripts.denas_buff_aura = {
        update = function(this, store)
            local target = store.entities[this.aura.target_id]
            local ts = store.tick_ts - this.aura.cycle_time
            local start_ts = store.tick_ts
            local inserted_entities = {}
            local force_remove = false

            if not target then
                -- block empty
            else
                this.pos = V.vclone(target.pos)
                this.tween.disabled = false
                this.tween.props[1].ts = store.tick_ts

                while true do
                    if store.tick_ts - start_ts >= this.aura.duration then
                        break
                    end

                    if target.pos.x ~= this.pos.x or target.pos.y ~= this.pos.y or target.health.death then
                        force_remove = true
                        break
                    end

                    if store.tick_ts - ts >= this.aura.cycle_time then
                        ts = store.tick_ts
                        local e = E:create_entity(this.entity)
                        e.pos = V.vclone(this.pos)
                        e.tween.disabled = false

                        for i, t in ipairs(e.tween.props) do
                            e.tween.props[i].ts = store.tick_ts
                        end

                        table.insert(inserted_entities, e)
                        queue_insert(store, e)
                    end

                    coroutine.yield()
                end
            end

            if force_remove then
                for _, e in pairs(inserted_entities) do
                    queue_remove(store, e)
                end
            end

            queue_remove(store, this)
        end
    }
    -- 迪纳斯-buff
    scripts.mod_denas_tower = {
        insert = function(this, store)
            local m = this.modifier
            local target = store.entities[m.target_id]

            if not target or not target.tower then
                log.error("error inserting mod_denas_tower %s", this.id)
                return true
            end

            SU.insert_tower_cooldown_buff(target, this.cooldown_factor)
            SU.insert_tower_range_buff(target, this.range_factor, false)

            for i = 1, #this.render.sprites do
                local s = this.render.sprites[i]
                s.ts = store.tick_ts
            end

            return true
        end,
        update = function(this, store)
            local m = this.modifier
            local target = store.entities[m.target_id]

            if target then
                this.pos = target.pos
            end

            m.ts = store.tick_ts
            this.tween.ts = store.tick_ts

            while store.tick_ts - m.ts < m.duration - 0.5 do
                coroutine.yield()
            end

            this.tween.reverse = true
            this.tween.ts = store.tick_ts

            U.y_wait(store, 0.5)
            queue_remove(store, this)
        end,
        remove = function(this, store)
            local m = this.modifier
            local target = store.entities[m.target_id]

            if not target or not target.tower then
                log.error("error removing mod_denas_tower %s", this.id)

                return false
            end
            SU.remove_tower_cooldown_buff(target, this.cooldown_factor)
            SU.remove_tower_range_buff(target, this.range_factor, false)
            return true
        end

    }
    -- 迪纳斯
    scripts.hero_denas = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)

            for _, b in pairs(this.timed_attacks.list[1].bullets) do
                local bt = E:get_template(b)
                bt.bullet.damage_min = ls.ranged_damage_min[hl]
                bt.bullet.damage_max = ls.ranged_damage_max[hl]
            end

            for _, b in pairs(this.ranged.attacks[1].bullets) do
                local bt = E:get_template(b)
                bt.bullet.damage_min = ls.ranged_damage_min[hl]
                bt.bullet.damage_max = ls.ranged_damage_max[hl]
            end

            upgrade_skill(this, "tower_buff", function(this, s)
                local a = this.timed_attacks.list[2]
                a.disabled = nil
                local m = E:get_template(a.mod)
                m.modifier.duration = s.duration[s.level]
            end)

            upgrade_skill(this, "catapult", function(this, s)
                local a = this.timed_attacks.list[3]
                a.disabled = nil
                local c = E:get_template(a.entity)
                c.count = s.count[s.level]
                local r = E:get_template(c.bullet)
                r.bullet.damage_min = s.damage_min[s.level]
                r.bullet.damage_max = s.damage_max[s.level]
            end)

            this.health.hp = this.health.hp_max
        end,
        update = function(this, store)
            local h = this.health
            local he = this.hero
            local a, skill, brk, sta, target, pred_pos
            local rock_flight_time = E:get_template("denas_catapult_rock").bullet.flight_time

            U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)
            this.health_bar.hidden = false

            local function do_denas_attack(target, attack, pred_pos)
                local bullet
                local bullet_to = pred_pos or target.pos
                local bullet_to_start = V.vclone(bullet_to)
                local bidx = math.random(1, #a.animations)
                local animation = attack.animations[bidx]
                local bullet_name = attack.bullets[bidx]
                local an, af, ai = U.animation_name_facing_point(this, animation, bullet_to)

                U.animation_start(this, an, af, store.tick_ts, false)

                if SU.y_hero_wait(store, this, a.shoot_time) then
                    return
                end

                bullet = E:create_entity(bullet_name)
                bullet.pos = V.vclone(this.pos)

                if attack.bullet_start_offset then
                    local offset = attack.bullet_start_offset[ai]
                    bullet.pos.x, bullet.pos.y = bullet.pos.x + (af and -1 or 1) * offset.x, bullet.pos.y + offset.y
                end

                bullet.bullet.from = V.vclone(bullet.pos)
                bullet.bullet.to = V.vclone(bullet_to)
                bullet.bullet.to.x = bullet.bullet.to.x + target.unit.hit_offset.x
                bullet.bullet.to.y = bullet.bullet.to.y + target.unit.hit_offset.y
                bullet.bullet.target_id = target.id
                bullet.bullet.source_id = this.id
                bullet.bullet.xp_dest_id = this.id
                bullet.bullet.level = attack.level
                bullet.bullet.damage_factor = this.unit.damage_factor

                queue_insert(store, bullet)

                if U.y_animation_wait(this) then
                    return
                end

                return true
            end

            while true do
                if h.dead then
                    SU.y_hero_death_and_respawn(store, this)
                end

                if this.unit.is_stunned then
                    SU.soldier_idle(store, this)
                else
                    while this.nav_rally.new do
                        if SU.y_hero_new_rally(store, this) then
                            goto label_54_0
                        end
                    end

                    if SU.hero_level_up(store, this) then
                        U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)
                    end

                    a = this.timed_attacks.list[2]
                    skill = this.hero.skills.tower_buff

                    if ready_to_use_skill(a, store) then
                        local towers = U.find_towers_in_range(store.entities, this.pos, a, function(t)
                            return t.tower.can_be_mod and
                                       (not t.barrack or t.template_name == "tower_sorcerer" or t.template_name ==
                                           "tower_necromancer" or t.template_name == "tower_mech" or t.template_name ==
                                           "tower_frankenstein" or t.template_name == "tower_druid")
                        end)

                        if not towers or #towers <= 0 then
                            SU.delay_attack(store, a, 0.134)
                        else
                            local start_ts = store.tick_ts

                            S:queue(a.sound)
                            U.animation_start(this, a.animation, nil, store.tick_ts, 1)

                            if SU.y_hero_wait(store, this, a.curse_time) then
                                goto label_54_0
                            end

                            local curse = E:create_entity("denas_cursing")

                            curse.source_id = this.id

                            queue_insert(store, curse)

                            if SU.y_hero_wait(store, this, a.cast_time - a.curse_time) then
                                goto label_54_0
                            end

                            a.ts = start_ts

                            SU.hero_gain_xp_from_skill(this, skill)

                            local au = E:create_entity(a.aura)

                            au.aura.target_id = this.id
                            au.aura.source_id = this.id

                            queue_insert(store, au)

                            for _, t in ipairs(towers) do
                                local m = E:create_entity(a.mod)
                                m.modifier.source_id = this.id
                                m.modifier.target_id = t.id
                                queue_insert(store, m)
                            end

                            SU.y_hero_animation_wait(this)

                            goto label_54_0
                        end
                    end

                    a = this.timed_attacks.list[3]
                    skill = this.hero.skills.catapult

                    if ready_to_use_skill(a, store) then
                        local target = U.find_random_enemy(store.entities, this.pos, a.min_range, a.max_range,
                            a.vis_flags, a.vis_bans)

                        if not target then
                            SU.delay_attack(store, a, 0.134)
                        else
                            local start_ts = store.tick_ts
                            local flip = target.pos.x < this.pos.x

                            S:queue(a.sound)
                            U.animation_start(this, a.animation, flip, store.tick_ts)

                            if SU.y_hero_wait(store, this, a.cast_time) then
                                goto label_54_0
                            end

                            a.ts = start_ts

                            SU.hero_gain_xp_from_skill(this, skill)

                            local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
                            local n_off = P:predict_enemy_node_advance(target, rock_flight_time)

                            if P:is_node_valid(pi, ni + n_off) then
                                ni = ni + n_off
                            end

                            local pos = P:node_pos(pi, 1, ni)
                            local e = E:create_entity(a.entity)
                            e.damage_factor = this.unit.damage_factor
                            e.pos = pos

                            queue_insert(store, e)
                            SU.y_hero_animation_wait(this)

                            goto label_54_0
                        end
                    end

                    a = this.timed_attacks.list[1]
                    target = SU.soldier_pick_melee_target(store, this)

                    if target then
                        if SU.soldier_move_to_slot_step(store, this, target) then
                            -- block empty
                        elseif store.tick_ts - a.ts < a.cooldown then
                            -- block empty
                        else
                            a.ts = store.tick_ts

                            do_denas_attack(target, a)
                        end
                    else
                        target, a, pred_pos = SU.soldier_pick_ranged_target_and_attack(store, this)

                        if target and a then
                            U.set_destination(this, this.pos)

                            a.ts = store.tick_ts

                            if not do_denas_attack(target, a, pred_pos) then
                                goto label_54_0
                            end
                        end

                        if SU.soldier_go_back_step(store, this) then
                            -- block empty
                        else
                            SU.soldier_idle(store, this)
                            SU.soldier_regen(store, this)
                        end
                    end
                end
                ::label_54_0::
                coroutine.yield()
            end
        end
    }
    -- 兽王-恢复
    scripts.aura_beastmaster_regeneration = {
        update = function(this, store)
            local hps = this.hps
            local hero = store.entities[this.aura.source_id]
            if not hero then
                return
            end
            while true do
                if not hero.health.dead and store.tick_ts - hps.ts >= hps.heal_every then
                    hps.ts = store.tick_ts
                    hero.health.hp = km.clamp(0, hero.health.hp_max, hero.health.hp + hps.heal_max)
                end
                coroutine.yield()
            end
        end
    }
    -- 兽王-犀牛
    scripts.beastmaster_rhino = {
        insert = function(this, store)
            this.pos = P:node_pos(this.nav_path)
            if not this.pos then
                return false
            end
            return true
        end,
        update = function(this, store)
            local attack = this.attack
            local start_ts = store.tick_ts
            this.tween.ts = store.tick_ts

            while true do
                local next, new = P:next_entity_node(this, store.tick_length)

                if not next then
                    log.debug("  X not next for %s", this.id)
                    queue_remove(store, this)
                    return
                end

                if not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) or
                    band(GR:cell_type(next.x, next.y), bor(TERRAIN_CLIFF, TERRAIN_WATER, TERRAIN_FAERIE)) ~= 0 then
                    local twk = this.tween.props[1].keys

                    if store.tick_ts - this.tween.ts < this.duration - 0.25 then
                        log.debug("  FF finish early for %s", this.id)

                        this.tween.ts = store.tick_ts - this.duration + 0.25
                    end
                end

                U.set_destination(this, next)

                local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

                U.animation_start(this, an, af, store.tick_ts)
                U.walk(this, store.tick_length)

                if store.tick_ts - attack.ts >= attack.cooldown then
                    attack.ts = store.tick_ts

                    local targets = U.find_enemies_in_range(store.entities, this.pos, 0, attack.damage_radius,
                        attack.damage_flags, attack.damage_bans, function(v)
                            return not table.contains(this.shared_enemies_hit, v)
                        end)

                    if not targets then
                        -- block empty
                    else
                        for _, e in pairs(targets) do
                            if band(e.vis.bans, F_STUN) == 0 and band(e.vis.flags, F_BOSS) == 0 and math.random() <
                                attack.mod_chance then
                                local m = E:create_entity(attack.mod)
                                m.modifier.source_id = this.id
                                m.modifier.target_id = e.id
                                queue_insert(store, m)
                            end

                            local d = E:create_entity("damage")
                            d.source_id = this.id
                            d.target_id = e.id
                            d.value = attack.damage
                            d.damage_type = attack.damage_type
                            queue_damage(store, d)
                            table.insert(this.shared_enemies_hit, e)
                        end
                    end
                end

                coroutine.yield()
            end
        end
    }
    -- 兽王-猎鹰
    scripts.beastmaster_falcon = {
        get_info = function(this)
            return {
                armor = 0,
                type = STATS_TYPE_SOLDIER,
                hp = this.fake_hp,
                hp_max = this.fake_hp,
                damage_min = this.custom_attack.damage_min,
                damage_max = this.custom_attack.damage_max
            }
        end,
        update = function(this, store)
            local sf = this.render.sprites[1]
            local h = this.owner
            local fm = this.force_motion
            local ca = this.custom_attack

            sf.offset.y = this.flight_height

            U.y_animation_play(this, "respawn", nil, store.tick_ts)
            U.animation_start(this, "idle", nil, store.tick_ts, true)

            while true do
                if h.health.dead then
                    U.y_animation_play(this, "death", nil, store.tick_ts)
                    queue_remove(store, this)

                    return
                end

                if store.tick_ts - ca.ts > ca.cooldown then
                    local target = U.find_nearest_enemy(store.entities, this.pos, ca.min_range, ca.max_range,
                        ca.vis_flags, ca.vis_bans)

                    if not target then
                        SU.delay_attack(store, ca, 0.13333333333333333)
                    else
                        S:queue(ca.sound)
                        U.animation_start(this, "attack_fly", af, store.tick_ts, false)

                        local accel = 180
                        local max_speed = 300
                        local min_speed = 60
                        local mspeed = min_speed
                        local dist = V.dist(this.pos.x, this.pos.y, target.pos.x, target.pos.y)
                        local start_dist = dist
                        local start_h = sf.offset.y
                        local target_h = target.unit.hit_offset.y

                        while dist > mspeed * store.tick_length and not target.health.dead do
                            local tx, ty = target.pos.x, target.pos.y
                            local dx, dy = V.mul(mspeed * store.tick_length,
                                V.normalize(V.sub(tx, ty, this.pos.x, this.pos.y)))

                            this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, dx, dy)
                            sf.offset.y = km.clamp(0, this.flight_height * 1.5,
                                start_h + (target_h - start_h) * (1 - dist / start_dist))
                            sf.flip_x = dx < 0

                            coroutine.yield()

                            dist = V.dist(this.pos.x, this.pos.y, target.pos.x, target.pos.y)
                            mspeed = km.clamp(min_speed, max_speed, mspeed + accel * store.tick_length)
                        end

                        if target.health.dead then
                            ca.ts = store.tick_ts
                        else
                            this.pos.x, this.pos.y = target.pos.x, target.pos.y - 1

                            local d = E:create_entity("damage")
                            d.source_id = this.id
                            d.target_id = target.id
                            d.value = math.random(ca.damage_min, ca.damage_max)
                            d.damage_type = ca.damage_type
                            d.xp_gain_factor = ca.xp_gain_factor
                            d.xp_dest_id = h.id
                            queue_damage(store, d)

                            local m = E:create_entity(ca.mod)
                            m.modifier.source_id = this.id
                            m.modifier.target_id = target.id
                            queue_insert(store, m)

                            U.y_animation_play(this, "attack_hit", nil, store.tick_ts, 1)
                            ca.ts = store.tick_ts
                        end
                    end
                end

                U.animation_start(this, "idle", nil, store.tick_ts, true)

                local dx, dy = V.sub(h.pos.x, h.pos.y, this.pos.x, this.pos.y)

                if V.len(dx, dy) > 50 then
                    fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(1440, V.mul(4, dx, dy)))
                end

                if V.len(fm.a.x, fm.a.y) > 1 then
                    fm.v.x, fm.v.y = V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y))
                    fm.a.x, fm.a.y = 0, 0
                else
                    fm.v.x, fm.v.y = 0, 0
                    fm.a.x, fm.a.y = 0, 0
                end

                this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, V.mul(store.tick_length, fm.v.x, fm.v.y))
                fm.a.x, fm.a.y = V.trim(1800, V.mul(-0.75, fm.v.x, fm.v.y))
                sf.offset.y = km.clamp(0, this.flight_height, sf.offset.y + this.flight_speed * store.tick_length)
                sf.flip_x = fm.v.x < 0

                coroutine.yield()
            end
        end
    }
    -- 兽王-宠物
    scripts.beastmaster_pet = {
        get_info = function(this)
            local min, max = this.melee.attacks[1].damage_min * this.unit.damage_factor,
                this.melee.attacks[1].damage_max * this.unit.damage_factor
            return {
                type = STATS_TYPE_SOLDIER,
                hp = this.health.hp,
                hp_max = this.health.hp_max,
                damage_min = min,
                damage_max = max,
                armor = this.health.armor,
                respawn = this.owner.timed_attacks.list[2].cooldown
            }
        end,
        insert = function(this, store)
            this.melee.order = U.attack_order(this.melee.attacks)
            return true
        end,
        update = function(this, store)
            local brk, sta
            if this.template_name == "beastmaster_boar" then
                U.y_animation_play(this, "spawn", nil, store.tick_ts)
            end

            while true do
                if this.health.dead then
                    table.removeobject(this.owner.boars, this)
                    SU.y_soldier_death(store, this)
                    return
                end

                if this.unit.is_stunned then
                    SU.soldier_idle(store, this)
                else
                    SU.soldier_courage_upgrade(store, this)

                    while this.nav_rally.new do
                        this.nav_grid.waypoints = GR:find_waypoints(this.pos, nil, this.nav_rally.pos,
                            this.nav_grid.valid_terrains)

                        if SU.y_hero_new_rally(store, this) then
                            goto label_344_0
                        end
                    end

                    if this.melee then
                        brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                        if brk or sta ~= A_NO_TARGET then
                            goto label_344_0
                        end
                    end

                    if SU.soldier_go_back_step(store, this) then
                        -- block empty
                    else
                        SU.soldier_idle(store, this)
                        SU.soldier_regen(store, this)
                    end
                end

                ::label_344_0::

                coroutine.yield()
            end
        end,
        level_up = function(this, s)
            if this.template_name == "beastmaster_boar" then
                this.health.hp_max = s.boar_hp_max[s.level]
            elseif this.template_name == "beastmaster_wolf" then
                this.health.hp_max = s.wolf_hp_max[s.level]
            end
            this.health.hp = this.health.hp_max
        end
    }
    -- 兽王
    scripts.hero_beastmaster = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)

            this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

            upgrade_skill(this, "boarmaster", function(this, s)
                local a = this.timed_attacks.list[2]
                a.disabled = nil
                a.max = s.boars[s.level]
                local e = E:get_template(a.entities[1])
                e.health.hp_max = s.boar_hp_max[s.level]
                local e = E:get_template(a.entities[2])
                e.health.hp_max = s.wolf_hp_max[s.level]
                for _, pet in pairs(this.boars) do
                    pet.fn_level_up(this, s)
                end
            end)

            upgrade_skill(this, "stampede", function(this, s)
                this.timed_attacks.list[1].disabled = nil
                this.timed_attacks.list[1].count = s.rhinos[s.level]
                local r = E:get_template(this.timed_attacks.list[1].entity)
                r.duration = s.duration[s.level]
                r.attack.damage = s.damage[s.level]
                r.attack.mod_chance = s.stun_chance[s.level]
                local m = E:get_template(r.attack.mod)
                m.modifier.duration = s.stun_duration[s.level]
            end)

            upgrade_skill(this, "deeplashes", function(this, s)
                local a = this.melee.attacks[2]
                a.disabled = nil
                a.damage_min = s.damage[s.level]
                a.damage_max = s.damage[s.level]
                a.cooldown = s.cooldown[s.level]
                local m = E:get_template(a.mod)
                m.dps.damage_min = s.blood_damage[s.level] / m.modifier.duration
                m.dps.damage_max = s.blood_damage[s.level] / m.modifier.duration
            end)

            upgrade_skill(this, "falconer", function(this, s)
                this.falcons_max = s.count[s.level]
            end)

            this.health.hp = this.health.hp_max
            this.timed_attacks.list[2].ts = -this.timed_attacks.list[2].cooldown
        end,
        insert = function(this, store, script)
            this.hero.fn_level_up(this, store)
            this.melee.order = U.attack_order(this.melee.attacks)
            local e = E:create_entity("aura_beastmaster_regeneration")
            e.aura.source_id = this.id
            e.aura.ts = store.tick_ts
            queue_insert(store, e)
            return true
        end,
        update = function(this, store, script)
            local h = this.health
            local he = this.hero
            local a, skill, brk, sta

            local function distribute_boars(x, y, qty)
                if qty < 1 then
                    return nil
                end

                local nodes = P:nearest_nodes(x, y, nil, nil, true)

                if #nodes < 1 then
                    log.debug("cannot insert boars, no valid nodes nearby %s,%s", x, y)
                    return nil
                end

                local opi, ospi, oni = unpack(nodes[1])
                local offset_options = {-2,-4, -6, -8, 2, 4, 6, 8}
                local positions = {}

                for i, offset in ipairs(offset_options) do
                    if qty <= #positions then
                        break
                    end

                    local ni = oni + offset
                    local spi = km.zmod(ospi + i, 3)
                    local npos = P:node_pos(opi, spi, ni)

                    if P:is_node_valid(opi, ni) and
                        band(GR:cell_type(npos.x, npos.y),
                            bor(TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK, TERRAIN_FAERIE)) == 0 then
                        table.insert(positions, npos)
                    end
                end

                if qty > #positions then
                    log.debug("could not find valid offsets for boars around %s,%s", x, y)
                    return nil
                end

                return positions
            end

            U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

            this.health_bar.hidden = false

            while true do
                if h.dead then
                    this.falcons = {}
                    SU.y_hero_death_and_respawn(store, this)
                end

                if #this.falcons < this.falcons_max then
                    local e = E:create_entity(this.falcons_name)
                    e.pos = V.v(math.random(10, 30) * km.rand_sign(), math.random(-15, 15))
                    e.pos.x, e.pos.y = e.pos.x + this.pos.x, e.pos.y + this.pos.y
                    queue_insert(store, e)
                    e.owner = this
                    table.insert(this.falcons, e)
                end

                if this.unit.is_stunned then
                    SU.soldier_idle(store, this)
                else
                    while this.nav_rally.new do
                        local positions = distribute_boars(this.nav_rally.pos.x, this.nav_rally.pos.y, #this.boars)

                        if positions then
                            for i, boar in ipairs(this.boars) do
                                local pos = positions[i]
                                boar.nav_rally.center = pos
                                boar.nav_rally.pos = pos
                                boar.nav_rally.new = true
                            end
                        end

                        if SU.y_hero_new_rally(store, this) then
                            goto label_339_0
                        end
                    end

                    if SU.hero_level_up(store, this) then
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    end

                    a = this.timed_attacks.list[2]
                    skill = this.hero.skills.boarmaster

                    if not a.disabled and #this.boars >= a.max then
                        a.ts = store.tick_ts
                    end

                    if ready_to_use_skill(a, store) and #this.boars < a.max then
                        local positions = distribute_boars(this.pos.x, this.pos.y, a.max)

                        if not positions then
                            -- block empty
                        else
                            local start_ts = store.tick_ts
                            this.health.immune_to = F_ALL
                            S:queue(a.sound)
                            U.animation_start(this, a.animation, nil, store.tick_ts, false)

                            while store.tick_ts - start_ts < a.spawn_time do
                                if this.nav_rally.new then
                                    goto label_339_0
                                end

                                if this.health.dead then
                                    goto label_339_0
                                end

                                if this.unit.is_stunned then
                                    goto label_339_0
                                end

                                coroutine.yield()
                            end

                            a.ts = store.tick_ts

                            while #this.boars < a.max do
                                local e
                                if math.random() < 0.5 then
                                    e = E:create_entity(a.entities[1])
                                else
                                    e = E:create_entity(a.entities[2])
                                end

                                e.pos = positions[#this.boars + 1]
                                e.nav_rally.center = V.vclone(e.pos)
                                e.nav_rally.pos = V.vclone(e.pos)
                                e.melee.attacks[1].xp_dest_id = this.id
                                e.render.sprites[1].flip_x = math.random() < 0.5

                                queue_insert(store, e)

                                e.owner = this

                                table.insert(this.boars, e)
                            end

                            while not U.animation_finished(this) do
                                if this.nav_rally.new then
                                    goto label_339_0
                                end

                                if this.health.dead then
                                    goto label_339_0
                                end

                                if this.unit.is_stunned then
                                    goto label_339_0
                                end

                                coroutine.yield()
                            end
                            this.health.immune_to = 0
                            a.ts = store.tick_ts
                            SU.hero_gain_xp_from_skill(this, skill)
                        end
                    end

                    a = this.timed_attacks.list[1]
                    skill = this.hero.skills.stampede

                    if ready_to_use_skill(a, store) then
                        local target_info = U.find_enemies_in_paths(store.entities, this.pos, a.range_nodes_min,
                            a.range_nodes_max, 60, a.vis_flags, a.vis_bans, true)

                        if not target_info then
                            SU.delay_attack(store, a, 1)
                        else
                            local target = target_info[1].enemy
                            local origin = target_info[1].origin
                            local start_ts = store.tick_ts
                            this.health.immune_to = F_ALL
                            S:queue(a.sound)

                            local flip = target.pos.x < this.pos.x

                            U.animation_start(this, a.animation, flip, store.tick_ts)

                            while store.tick_ts - start_ts < a.spawn_time do
                                if this.nav_rally.new then
                                    goto label_339_0
                                end

                                if this.health.dead then
                                    goto label_339_0
                                end

                                if this.unit.is_stunned then
                                    goto label_339_0
                                end

                                coroutine.yield()
                            end

                            a.ts = store.tick_ts

                            SU.hero_gain_xp_from_skill(this, skill)

                            local sni = origin[3] + 2

                            for i = 1, a.count do
                                local spawn = E:create_entity(a.entity)
                                spawn.nav_path.pi = origin[1]
                                spawn.nav_path.spi = km.zmod(i, 3)
                                spawn.nav_path.ni = sni
                                spawn.shared_enemies_hit = {}
                                queue_insert(store, spawn)
                                sni = km.clamp(1, origin[3] + 2, sni - 2)
                            end

                            while not U.animation_finished(this) do
                                if this.nav_rally.new then
                                    goto label_339_0
                                end

                                if this.health.dead then
                                    goto label_339_0
                                end

                                if this.unit.is_stunned then
                                    goto label_339_0
                                end

                                coroutine.yield()
                            end
                            this.health.immune_to = 0
                            a.ts = store.tick_ts
                        end
                    end

                    brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                    if brk or sta ~= A_NO_TARGET then
                        -- block empty
                    elseif SU.soldier_go_back_step(store, this) then
                        -- block empty
                    else
                        SU.soldier_idle(store, this)
                        SU.soldier_regen(store, this)
                    end
                end

                ::label_339_0::

                coroutine.yield()
            end
        end
    }
    -- 但丁-圣水炸弹
    scripts.van_helsing_grenade = {
        update = function(this, store)
            local b = this.bullet

            while store.tick_ts - b.ts + store.tick_length < b.flight_time do
                coroutine.yield()

                b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
                this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)
                this.render.sprites[1].r = this.render.sprites[1].r + b.rotation_speed * store.tick_length

                if b.hide_radius then
                    this.render.sprites[1].hidden =
                        V.dist(this.pos.x, this.pos.y, b.from.x, b.from.y) < b.hide_radius or
                            V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) < b.hide_radius
                end
            end

            local target = store.entities[b.target_id]
            local targets = U.find_enemies_in_range(store.entities, this.pos, 0, b.damage_radius, b.damage_flags,
                b.damage_bans)
            if targets then
                for _, t in pairs(targets) do
                    if t.health and not t.health.dead then
                        local mod = E:create_entity(b.mod)
                        mod.modifier.target_id = t.id
                        queue_insert(store, mod)
                    end
                end
            end

            local fx = E:create_entity(b.hit_fx)
            fx.render.sprites[1].ts = store.tick_ts
            fx.pos = V.vclone(b.to)
            queue_insert(store, fx)
            queue_remove(store, this)
        end
    }
    -- 但丁-减抗
    scripts.mod_van_helsing_relic = {
        update = function(this, store)
            local m = this.modifier
            local target = store.entities[m.target_id]
            local factor = 1 - this.armor_reduce_factor

            if not target or not target.health or target.health.dead then
                -- block empty
            else
                for _, n in pairs(this.remove_mods) do
                    SU.remove_modifiers(store, target, n)
                end
                factor = factor * (1 - target.health.armor_resilience)

                if target.health.armor > 0 then
                    SU.armor_dec(target, target.health.armor * factor)
                end
                if target.health.magic_armor > 0 then
                    SU.magic_armor_dec(target, target.health.magic_armor * factor)
                end

                this.pos.x, this.pos.y = target.pos.x, target.pos.y
                this.render.sprites[1].offset.y = target.health_bar.offset.y
                this.render.sprites[1].ts = store.tick_ts

                U.y_animation_wait(this)
            end

            queue_remove(store, this)
        end
    }
    -- 但丁-光明信标
    scripts.mod_van_helsing_beacon = {
        insert = function(this, store)
            local m = this.modifier
            local target = store.entities[m.target_id]
            if not target or not target.health or target.health.dead then
                return false
            end
            target.unit.damage_factor = target.unit.damage_factor * this.inflicted_damage_factor
            return true
        end,
        remove = function(this, store)
            local m = this.modifier
            local target = store.entities[m.target_id]
            if target then
                target.unit.damage_factor = target.unit.damage_factor / this.inflicted_damage_factor
            end
            return true
        end
    }
    -- 但丁
    scripts.hero_van_helsing = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)

            local a = this.melee.attacks[1]
            a.damage_max = ls.damage_max[hl]
            a.damage_min = ls.damage_min[hl]

            local b = E:get_template("van_helsing_shotgun")
            b.bullet.damage_max = ls.ranged_damage_max[hl]
            b.bullet.damage_min = ls.ranged_damage_min[hl]

            upgrade_skill(this, "multishoot", function(this, s)
                local a = this.timed_attacks.list[1]
                a.disabled = nil
                a.loops = s.loops[s.level]
            end)

            upgrade_skill(this, "silverbullet", function(this, s)
                local a = this.timed_attacks.list[2]
                a.disabled = nil
                local b = E:get_template(a.bullet)
                b.bullet.damage_max = s.damage[s.level]
                b.bullet.damage_min = s.damage[s.level]
            end)
            upgrade_skill(this, "holygrenade", function(this, s)
                local a = this.timed_attacks.list[3]
                a.disabled = nil
                local m = E:get_template("mod_van_helsing_silence")
                m.modifier.duration = s.silence_duration[s.level]
            end)

            upgrade_skill(this, "relicofpower", function(this, s)
                local a = this.melee.attacks[2]
                a.disabled = nil
                local m = E:get_template("mod_van_helsing_relic")
                m.armor_reduce_factor = s.armor_reduce_factor[s.level]
            end)

            upgrade_skill(this, "beaconoflight", function(this, s)
                local m = E:get_template("mod_van_helsing_beacon")
                m.inflicted_damage_factor = s.inflicted_damage_factor[s.level]
                this.info.hero_portrait_always_on = true
            end)
            this.health.hp = this.health.hp_max
        end,
        insert = function(this, store)
            this.hero.fn_level_up(this, store)
            this.ranged.order = U.attack_order(this.ranged.attacks)
            this.melee.order = U.attack_order(this.melee.attacks)
            local a = E:create_entity("van_helsing_beacon_aura")
            a.aura.source_id = this.id
            queue_insert(store, a)
            this._beaconoflight_aura = a
            return true
        end,
        update = function(this, store)
            local h = this.health
            local he = this.hero
            local ra = this.ranged.attacks[1]
            local a, skill, brk, sta

            local function is_werewolf(e)
                local t1 = e.template_name
                return t1 == "enemy_lycan" or t1 == "enemy_lycan_werewolf" or t1 == "enemy_werewolf"
            end

            local function shot_ready()
                return ready_to_attack(this.ranged.attacks[1], store)
            end

            U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
            this.health_bar.hidden = false

            while true do
                if h.dead then
                    if band(this.health.last_damage_types, bor(DAMAGE_EAT, DAMAGE_HOST, DAMAGE_DISINTEGRATE)) == 0 then
                        S:queue(this.sound_events.death)
                        U.unblock_target(store, this)

                        local death_ts = store.tick_ts
                        local bans, flags = this.vis.bans, this.vis.flags
                        local prefix = this.render.sprites[1].prefix

                        this.vis.bans = F_ALL
                        this.vis.flags = F_NONE
                        this.render.sprites[1].prefix = prefix .. "_ghost"
                        this.health.ignore_damage = true
                        this.info.hero_portrait = this.info.hero_portrait_dead
                        this.info.portrait = this.info.portrait_dead

                        U.y_animation_play(this, "start", nil, store.tick_ts)
                        U.animation_start(this, "idle", nil, store.tick_ts, true)

                        while store.tick_ts - death_ts < this.health.dead_lifetime do
                            SU.y_hero_new_rally(store, this)
                            this.health.ignore_damage = true
                            coroutine.yield()
                        end

                        this.vis.bans = bans
                        this.vis.flags = flags
                        this.render.sprites[1].prefix = prefix
                        this.health.hp = this.health.hp_max
                        this.health.dead = false
                        this.health.ignore_damage = false
                        this.info.hero_portrait = this.info.hero_portrait_alive
                        this.info.portrait = this.info.portrait_alive

                        S:queue(this.sound_events.respawn)
                        U.y_animation_play(this, "respawn", nil, store.tick_ts)

                        this.health_bar.hidden = false
                    else
                        local a = this._beaconoflight_aura

                        if a then
                            a.aura.requires_alive_source = true
                        end

                        SU.y_hero_death_and_respawn(store, this)

                        if a then
                            a.aura.requires_alive_source = false
                        end
                    end
                end

                if this.unit.is_stunned then
                    SU.soldier_idle(store, this)
                else
                    while this.nav_rally.new do
                        if SU.y_hero_new_rally(store, this) then
                            goto label_419_2
                        end
                    end

                    if SU.hero_level_up(store, this) then
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    end

                    a = this.timed_attacks.list[1]
                    skill = this.hero.skills.multishoot

                    if ready_to_use_skill(a, store) and not shot_ready() then
                        local target, targets = U.find_foremost_enemy(store.entities, this.pos, a.min_range,
                            a.max_range, a.shoot_time, a.vis_flags, a.vis_bans, function(e)
                                local center_pos = P:node_pos(e.nav_path.pi, 1, e.nav_path.ni)
                                local nearby = U.find_enemies_in_range(store.entities, center_pos, 0, a.search_range,
                                    a.vis_flags, a.vis_bans)

                                return nearby and #nearby >= a.search_min_count
                            end)

                        if not target then
                            SU.delay_attack(store, a, 0.2)
                        else
                            local an, af = U.animation_name_facing_point(this, a.animations[1], target.pos)
                            local aidx
                            U.animation_start(this, an, af, store.tick_ts, false)

                            while not U.animation_finished(this) do
                                if SU.hero_interrupted(this) then
                                    goto label_419_1
                                end
                                coroutine.yield()
                            end

                            for i = 1, a.loops / 2 do
                                log.paranoid("van_helsing multishoot target:%s (targets: %s)", target.id,
                                    table.concat(table.map(targets, function(k, v)
                                        return v.id
                                    end), ","))

                                an, af, aidx = U.animation_name_facing_point(this, a.animations[2], target.pos)

                                U.animation_start(this, an, af, store.tick_ts, false)

                                for i = 1, 2 do
                                    U.y_wait(store, fts(2))

                                    local b = E:create_entity(a.bullet)
                                    b.pos.x = this.pos.x + (af and -1 or 1) * a.bullet_start_offset[aidx].x
                                    b.pos.y = this.pos.y + a.bullet_start_offset[aidx].y
                                    b.bullet.from = V.vclone(b.pos)
                                    b.bullet.to = V.vclone(target.pos)
                                    b.bullet.target_id = target.id
                                    b.bullet.damage_factor = this.unit.damage_factor
                                    queue_insert(store, b)
                                end

                                while not U.animation_finished(this) do
                                    if SU.hero_interrupted(this) then
                                        goto label_419_0
                                    end
                                    coroutine.yield()
                                end

                                target = table.random(targets)

                                if target.health.dead then
                                    local center_pos = P:node_pos(target.nav_path.pi, 1, target.nav_path.ni)
                                    local nearby = U.find_nearest_enemy(store.entities, center_pos, 0, a.search_range,
                                        a.vis_flags, a.vis_bans)

                                    if nearby then
                                        table.removeobject(targets, target)
                                        table.insert(targets, nearby)
                                        target = nearby
                                    end
                                end
                            end

                            an, af = U.animation_name_facing_point(this, a.animations[3], target.pos)

                            U.animation_start(this, an, af, store.tick_ts, false)

                            while not U.animation_finished(this) and not SU.hero_interrupted(this) do
                                coroutine.yield()
                            end

                            ::label_419_0::

                            a.ts = store.tick_ts
                            SU.hero_gain_xp_from_skill(this, skill)
                            ra.ts = store.tick_ts

                            goto label_419_2
                        end
                    end

                    ::label_419_1::

                    a = this.timed_attacks.list[2]
                    skill = this.hero.skills.silverbullet

                    if ready_to_use_skill(a, store) then
                        local target = U.find_foremost_enemy(store.entities, this.pos, a.min_range, a.max_range,
                            a.shoot_time, a.vis_flags, a.vis_bans, function(e)
                                return math.abs(P:nodes_to_defend_point(e.nav_path)) < a.nodes_to_defend
                            end)

                        if not target then
                            local targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range,
                                a.vis_flags, a.vis_bans)

                            if targets then
                                table.sort(targets, function(e1, e2)
                                    local h1 = e1.health.hp / (1 - e1.health.armor)
                                    local h2 = e2.health.hp / (1 - e2.health.armor)
                                    local df = a.werewolf_damage_factor

                                    return h1 * (is_werewolf(e1) and df or 1) > h2 * (is_werewolf(e2) and df or 1)
                                end)

                                if #targets > 0 then
                                    target = targets[1]
                                end
                            end
                        end

                        if not target then
                            SU.delay_attack(store, a, 0.2)
                        else
                            local an, af, aidx = U.animation_name_facing_point(this, a.animation, target.pos)

                            U.animation_start(this, an, af, store.tick_ts, false)

                            if U.y_wait(store, a.crosshair_time, function()
                                return SU.hero_interrupted(this)
                            end) then
                                -- block empty
                            else
                                local m = E:create_entity(a.crosshair_name)

                                m.modifier.source_id = this.id
                                m.modifier.target_id = target.id
                                m.render.sprites[1].ts = store.tick_ts

                                queue_insert(store, m)

                                if U.y_wait(store, a.shoot_time - a.crosshair_time, function()
                                    return SU.hero_interrupted(this)
                                end) then
                                    queue_remove(store, m)
                                else
                                    local b = E:create_entity(a.bullet)

                                    b.pos.x = this.pos.x + (af and -1 or 1) * a.bullet_start_offset[aidx].x
                                    b.pos.y = this.pos.y + a.bullet_start_offset[aidx].y
                                    b.bullet.from = V.vclone(b.pos)
                                    b.bullet.to = V.vclone(target.pos)
                                    b.bullet.target_id = target.id
                                    b.bullet.damage_factor =
                                        (is_werewolf(target) and a.werewolf_damage_factor or 1) *
                                            this.unit.damage_factor

                                    queue_insert(store, b)

                                    while not U.animation_finished(this) and not SU.hero_interrupted(this) do
                                        coroutine.yield()
                                    end

                                    a.ts = store.tick_ts

                                    SU.hero_gain_xp_from_skill(this, skill)

                                    ra.ts = store.tick_ts

                                    goto label_419_2
                                end
                            end
                        end
                    end

                    a = this.timed_attacks.list[3]
                    skill = this.hero.skills.holygrenade

                    if ready_to_use_skill(a, store) and not shot_ready() then
                        local g = E:get_template("van_helsing_grenade")
                        local target, _, pred_pos = U.find_foremost_enemy(store.entities, this.pos, a.min_range,
                            a.max_range, a.shoot_time + g.bullet.flight_time, a.vis_flags, a.vis_bans,
                            enemy_is_silent_target)

                        if not target then
                            SU.delay_attack(store, a, 0.2)
                        else
                            local an, af = U.animation_name_facing_point(this, a.animation, target.pos)

                            U.animation_start(this, an, af, store.tick_ts, false)

                            if U.y_wait(store, a.shoot_time, function()
                                return SU.hero_interrupted(this)
                            end) then
                                -- block empty
                            else
                                local b = E:create_entity(a.bullet)
                                b.pos.x = this.pos.x + (af and -1 or 1) * a.bullet_start_offset[1].x
                                b.pos.y = this.pos.y + a.bullet_start_offset[1].y
                                b.bullet.from = V.vclone(b.pos)
                                b.bullet.to = V.vclone(pred_pos)
                                b.bullet.target_id = target.id
                                queue_insert(store, b)

                                while not U.animation_finished(this) and not SU.hero_interrupted(this) do
                                    coroutine.yield()
                                end

                                a.ts = store.tick_ts
                                SU.hero_gain_xp_from_skill(this, skill)
                                goto label_419_2
                            end
                        end
                    end

                    brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                    if brk or sta ~= A_NO_TARGET then
                        -- block empty
                    else
                        brk, sta = SU.y_soldier_ranged_attacks(store, this)

                        if brk then
                            -- block empty
                        elseif SU.soldier_go_back_step(store, this) then
                            -- block empty
                        else
                            SU.soldier_idle(store, this)
                            SU.soldier_regen(store, this)
                        end
                    end
                end
                ::label_419_2::
                coroutine.yield()
            end
        end,
        can_relic = function(this, store, attack, target)
            return (target.health.armor > 0 or target.health.magic_armor > 0) and target.health.hp_max > 500
        end
    }
    -- 马利克-地震
    scripts.aura_malik_fissure = {
        update = function(this, store)
            local a = this.aura
            local function do_attack(pos)
                local fx = E:create_entity(a.fx)
                fx.pos.x, fx.pos.y = pos.x, pos.y
                fx.render.sprites[2].ts = store.tick_ts
                fx.tween.ts = store.tick_ts
                queue_insert(store, fx)
                local targets =
                    U.find_enemies_in_range(store.entities, pos, 0, a.damage_radius, a.vis_flags, a.vis_bans)
                if targets then
                    for _, t in pairs(targets) do
                        local d = E:create_entity("damage")
                        d.value = math.random(a.damage_min, a.damage_max)
                        d.damage_type = a.damage_type
                        d.source_id = this.id
                        d.target_id = t.id
                        queue_damage(store, d)
                        if U.flags_pass(t.vis, this.stun) then
                            local m = E:create_entity(this.stun.mod)
                            m.modifier.source_id = this.id
                            m.modifier.target_id = t.id
                            queue_insert(store, m)
                        end
                    end
                    log.paranoid(">>>> aura_malik_fissure POS:%s,%s  damaged:%s", pos.x, pos.y,
                        table.concat(table.map(targets, function(k, v)
                            return v.id
                        end), ","))
                end
            end

            do_attack(this.pos)

            local pi, spi, ni

            if a.target_id and store.entities[a.target_id] then
                local np = store.entities[a.target_id].nav_path

                pi, spi, ni = np.pi, np.spi, np.ni
            else
                local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

                if #nodes < 1 then
                    log.error("aura_malik_fissure could not find valid nodes near %s,%s", this.pos.x, this.pos.y)

                    goto label_201_0
                end

                pi, spi, ni = unpack(nodes[1])
            end

            for i = 1, a.level do
                spi = (spi == 2 or spi == 3) and 1 or math.random() < 0.5 and 2 or 3

                U.y_wait(store, a.spread_delay)

                local nni = ni + i * a.spread_nodes
                local spos = P:node_pos(pi, spi, nni)

                do_attack(spos)

                nni = ni - i * a.spread_nodes
                spos = P:node_pos(pi, spi, nni)

                do_attack(spos)
            end

            ::label_201_0::

            queue_remove(store, this)
        end
    }
    -- 马利克
    scripts.hero_malik = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)

            this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
            this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

            upgrade_skill(this, "smash", function(this, s)
                local a = this.melee.attacks[3]
                a.disabled = nil
                a.damage_min = s.damage_min[s.level]
                a.damage_max = s.damage_max[s.level]
                a.mod_chance = s.stun_chance[s.level]
            end)

            upgrade_skill(this, "fissure", function(this, s)
                local a = this.melee.attacks[4]
                a.disabled = nil
                local au = E:get_template(a.hit_aura)
                au.aura.level = s.level
                au.aura.damage_min = s.damage_min[s.level]
                au.aura.damage_max = s.damage_max[s.level]
            end)
            this.health.hp = this.health.hp_max
        end,
        update = function(this, store)
            local h = this.health
            local he = this.hero
            local a, skill, brk, sta

            U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
            this.health_bar.hidden = false

            while true do
                if h.dead then
                    SU.y_hero_death_and_respawn(store, this)
                end

                if this.unit.is_stunned then
                    SU.soldier_idle(store, this)
                else
                    while this.nav_rally.new do
                        if SU.y_hero_new_rally(store, this) then
                            goto label_81_0
                        end
                    end

                    if SU.hero_level_up(store, this) then
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    end

                    brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                    if brk or sta ~= A_NO_TARGET then
                        -- block empty
                    elseif SU.soldier_go_back_step(store, this) then
                        -- block empty
                    else
                        SU.soldier_idle(store, this)
                        SU.soldier_regen(store, this)
                    end
                end
                ::label_81_0::
                coroutine.yield()
            end
        end
    }
    -- 德得尔-护甲buff
    scripts.mod_priest_armor = {
        insert = function(this, store, script)
            local target = store.entities[this.modifier.target_id]

            if not target or target.health.dead then
                return false
            end

            if band(this.modifier.vis_flags, target.vis.bans) ~= 0 or band(this.modifier.vis_bans, target.vis.flags) ~=
                0 then
                return false
            end

            local rate = this.armor_rate
            local function calc_inc(is_magic)
                if is_magic then
                    return rate * (1 - target.health.magic_armor)
                else
                    return rate * (1 - target.health.armor)
                end
            end

            this.armor_inc = calc_inc(false)
            this.magic_armor_inc = calc_inc(true)

            SU.armor_inc(target, this.armor_inc)
            SU.magic_armor_inc(target, this.magic_armor_inc)

            signal.emit("mod-applied", this, target)
            return true
        end,
        remove = function(this, store, script)
            local target = store.entities[this.modifier.target_id]
            if target then
                SU.armor_dec(target, this.armor_inc)
                SU.magic_armor_dec(target, this.magic_armor_inc)
            end
            return true
        end,
        update = function(this, store, script)
            local m = this.modifier
            local last_ts = store.tick_ts
            local target = store.entities[m.target_id]

            if not target then
                queue_remove(store, this)
                return
            end

            this.pos = target.pos

            while true do
                target = store.entities[m.target_id]
                if not target or target.health.dead or store.tick_ts - m.ts >= m.duration then
                    queue_remove(store, this)
                    return
                end
                if this.render and m.use_mod_offset and target.unit.mod_offset then
                    this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x,
                        target.unit.mod_offset.y
                end
                coroutine.yield()
            end
        end
    }
    -- 德得尔-塔buff
    scripts.mod_priest_consecrate = {
        update = function(this, store)
            local m = this.modifier
            local target = store.entities[m.target_id]

            if not target then
                queue_remove(store, this)
                return
            end

            this.pos = V.vclone(target.pos)
            m.ts = store.tick_ts
            this.tween.disabled = false
            this.tween.ts = store.tick_ts
            SU.insert_tower_damage_factor_buff(target, this.extra_damage)

            while store.tick_ts - m.ts < m.duration do
                coroutine.yield()
                target = store.entities[m.target_id]
                if not target then
                    goto label_374_0
                end
            end
            SU.remove_tower_damage_factor_buff(target, this.extra_damage)

            ::label_374_0::
            this.tween.reverse = true
            this.tween.ts = store.tick_ts
            this.tween.remove = true
        end
    }
    -- 德得尔
    scripts.hero_priest = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)

            this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

            local b = E:get_template("bolt_priest")
            b.bullet.damage_max = ls.ranged_damage_max[hl]
            b.bullet.damage_min = ls.ranged_damage_min[hl]

            upgrade_skill(this, "holylight", function(this, s)
                local a = this.timed_attacks.list[1]
                a.max_per_cast = s.heal_count[s.level]
                a.revive_chance = s.revive_chance[s.level]
                local m = E:get_template(a.mod)
                m.hps.heal_min = s.heal_hp[s.level]
                m.hps.heal_max = s.heal_hp[s.level]
            end)

            upgrade_skill(this, "consecrate", function(this, s)
                this.timed_attacks.list[2].disabled = nil
                local m = E:get_template("mod_priest_consecrate")
                m.modifier.duration = s.duration[s.level]
                m.extra_damage = s.extra_damage[s.level]
            end)

            upgrade_skill(this, "wingsoflight", function(this, s)
                this.teleport.disabled = nil
                local m = E:get_template("mod_priest_armor")
                m.modifier.duration = s.duration[s.level]
                m.armor_rate = s.armor_rate[s.level]
            end)

            upgrade_skill(this, "blessedarmor", function(this, s)
                this.blessedarmor_extra = s.armor[s.level]
            end)

            upgrade_skill(this, "divinehealth", function(this, s)
                this.divinehealth_extra_hp = s.extra_hp[s.level]
                this.divinehealth_regen_factor = s.regen_factor[s.level]
            end)

            this.health.hp_max = this.health.hp_max + this.divinehealth_extra_hp
            update_regen(this)
            inc_armor_by_skill(this, this.blessedarmor_extra)
            this.health.hp = this.health.hp_max
        end,
        update = function(this, store)
            local h = this.health
            local he = this.hero
            local a, skill, brk, sta

            local function do_armor_buff(pos, out)
                local skill = this.hero.skills.wingsoflight
                if skill.level < 1 then
                    return
                end

                local targets = U.find_soldiers_in_range(store.entities, pos, 0, skill.range, 0, 0)

                if targets then
                    for i = 1, math.min(#targets, skill.count[skill.level]) do
                        local target = targets[i]
                        local m = E:create_entity("mod_priest_armor")
                        m.modifier.target_id = target.id
                        m.render.sprites[1].ts = store.tick_ts
                        m.render.sprites[2].ts = store.tick_ts
                        m.render.sprites[2].offset.y = target.health_bar.offset.y + 7
                        queue_insert(store, m)
                    end
                end

                local fx = E:create_entity("fx_priest_wave_" .. (out and "out" or "in"))
                fx.pos = V.vclone(pos)
                fx.render.sprites[1].ts = store.tick_ts
                queue_insert(store, fx)
            end

            U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)
            this.health_bar.hidden = false

            while true do
                if h.dead then
                    SU.y_hero_death_and_respawn(store, this)
                end

                if this.unit.is_stunned then
                    SU.soldier_idle(store, this)
                else
                    while this.nav_rally.new do
                        this.nav_rally.new = false

                        U.unblock_target(store, this)
                        S:queue(this.sound_events.change_rally_point)

                        if SU.hero_will_teleport(this, this.nav_rally.pos) then
                            local vis_bans = this.vis.bans

                            this.vis.bans = F_ALL
                            this.health_bar.hidden = true
                            this.health.ignore_damage = true

                            local tp = this.teleport

                            S:queue(tp.sound)
                            do_armor_buff(this.pos, true)
                            U.y_animation_play(this, tp.animations[1], nil, store.tick_ts)

                            this.pos.x, this.pos.y = this.nav_rally.pos.x, this.nav_rally.pos.y

                            U.set_destination(this, this.pos)
                            do_armor_buff(this.pos, false)
                            U.y_animation_play(this, tp.animations[2], nil, store.tick_ts)

                            this.health.ignore_damage = false
                            this.health_bar.hidden = nil
                            this.vis.bans = vis_bans

                            goto label_365_0
                        else
                            local vis_bans = this.vis.bans

                            this.vis.bans = F_ALL

                            local out = SU.y_hero_walk_waypoints(store, this)

                            U.animation_start(this, "idle", nil, store.tick_ts, true)

                            this.vis.bans = vis_bans

                            if out == true then
                                goto label_365_0
                            end
                        end
                    end

                    if SU.hero_level_up(store, this) then
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    end

                    a = this.timed_attacks.list[1]
                    skill = this.hero.skills.holylight
                    if ready_to_attack(a, store) then
                        local targets = table.filter(store.entities, function(k, v)
                            return v.soldier and v.health and v.health.hp < 0.7 * v.health.hp_max and
                                       U.is_inside_ellipse(v.pos, this.pos, a.range) and v.template_name ~=
                                       "soldier_mecha"
                        end)

                        if #targets < 1 then
                            SU.delay_attack(store, a, 0.13333333333333333)
                        else
                            local dead_targets = table.filter(targets, function(k, v)
                                return v.health and v.health.dead
                            end)

                            local could_revive = false

                            for _, t in pairs(dead_targets) do
                                if not t.reinforcement and not table.contains(a.excluded_templates, t.template_name) then
                                    could_revive = true
                                    break
                                end
                            end

                            if #dead_targets == #targets and not could_revive then
                                SU.delay_attack(store, a, 0.13333333333333333)
                            else
                                could_revive = false
                                table.sort(targets, function(e1, e2)
                                    if e1.health.dead and e2.health.dead then
                                        return false
                                    elseif e1.health.dead then
                                        return true
                                    elseif e2.health.dead then
                                        return false
                                    else
                                        return e1.health.hp_max - e1.health.hp > e2.health.hp_max - e2.health.hp
                                    end
                                end)

                                if skill.level == 0 then
                                    SU.hero_gain_xp(this, 7, "holylight level 0")
                                else
                                    SU.hero_gain_xp_from_skill(this, skill)
                                end

                                S:queue(a.sound)
                                U.animation_start(this, a.animation, nil, store.tick_ts)
                                U.y_wait(store, a.shoot_time)

                                local count = 0

                                for _, s in pairs(targets) do
                                    -- 复活
                                    if s.health.dead and not s.unit.hide_during_death and
                                        (math.random() < a.revive_chance) and not s.reinforcement and not s.hero and
                                        not table.contains(a.excluded_templates, s.template_name) then

                                        s.health.dead = false
                                        s.health.hp = s.health.hp_max
                                        s.health_bar.hidden = nil
                                        s.ui.can_select = true

                                        if s.unit.hide_during_death then
                                            s.unit.hide_during_death = nil
                                            U.sprites_show(s)
                                        end

                                        s.main_script.runs = 1

                                        local fx = E:create_entity("fx_priest_revive")
                                        fx.pos = V.vclone(s.pos)
                                        fx.render.sprites[1].ts = store.tick_ts
                                        queue_insert(store, fx)
                                        count = count + 1
                                        -- 治疗
                                    elseif not s.health.dead then
                                        local m = E:create_entity(a.mod)
                                        m.modifier.target_id = s.id
                                        m.modifier.source_id = this.id
                                        queue_insert(store, m)
                                        count = count + 1
                                    end

                                    if count >= a.max_per_cast then
                                        break
                                    end
                                end

                                a.ts = store.tick_ts
                                U.y_animation_wait(this)
                                goto label_365_0
                            end
                        end
                    end

                    a = this.timed_attacks.list[2]
                    skill = this.hero.skills.consecrate

                    if ready_to_use_skill(a, store) then
                        local towers = table.filter(store.entities, function(_, e)
                            return e.tower and e.tower.can_be_mod and not e.tower.blocked and
                                       not table.contains(a.excluded_templates, e.template_name) and
                                       V.dist(e.pos.x, e.pos.y, this.pos.x, this.pos.y) < a.range
                        end)

                        if #towers < 1 then
                            SU.delay_attack(store, a, 0.13333333333333333)
                        else
                            a.ts = store.tick_ts

                            SU.hero_gain_xp_from_skill(this, skill)
                            S:queue(a.sound)
                            U.animation_start(this, a.animation, nil, store.tick_ts)
                            U.y_wait(store, a.shoot_time)

                            local buffed_tower_ids = {}

                            for _, e in pairs(store.entities) do
                                if e.modifier and e.template_name == "mod_priest_consecrate" then
                                    table.insert(buffed_tower_ids, e.modifier.target_id)
                                end
                            end

                            local towers = table.filter(store.entities, function(_, e)
                                return e.tower and e.tower.can_be_mod and not e.tower.blocked and
                                           not table.contains(a.excluded_templates, e.template_name) and
                                           V.dist(e.pos.x, e.pos.y, this.pos.x, this.pos.y) < a.range
                            end)

                            table.sort(towers, function(e1, e2)
                                return V.dist(e1.pos.x, e1.pos.y, this.pos.x, this.pos.y) <
                                           V.dist(e2.pos.x, e2.pos.y, this.pos.x, this.pos.y)
                            end)

                            local buffed_tower, unbuffed_tower

                            for _, t in pairs(towers) do
                                if not buffed_tower and table.contains(buffed_tower_ids, t.id) then
                                    buffed_tower = t
                                else
                                    unbuffed_tower = unbuffed_tower or t
                                end
                            end

                            local tower = unbuffed_tower or buffed_tower

                            if tower then
                                local m = E:create_entity("mod_priest_consecrate")
                                m.modifier.target_id = tower.id
                                queue_insert(store, m)
                            end

                            U.y_animation_wait(this)

                            goto label_365_0
                        end
                    end

                    brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                    if brk or U.is_blocked_valid(store, this) then
                        -- block empty
                    else
                        brk, sta = SU.y_soldier_ranged_attacks(store, this)

                        if brk then
                            -- block empty
                        elseif SU.soldier_go_back_step(store, this) then
                            -- block empty
                        else
                            SU.soldier_idle(store, this)
                            SU.soldier_regen(store, this)
                        end
                    end
                end
                ::label_365_0::
                coroutine.yield()
            end
        end
    }
    -- 马格努斯-奥术风暴控制器
    scripts.magnus_arcane_rain_controller = {
        update = function(this, store)
            this.tween.disabled = false
            this.tween.ts = store.tick_ts
            local range_factor = this.render.sprites[1].scale.x
            local a = this.initial_angle

            for i = 1, this.count do
                U.y_wait(store, this.spawn_time)

                local r = (U.frandom(0, 1) * 40 + 15) * range_factor
                local pos = U.point_on_ellipse(this.pos, r, a)
                local e = E:create_entity(this.entity)

                e.pos = V.vclone(pos)
                if this.is_illusion then
                    e.damage_min = e.damage_min * 0.35
                    e.damage_max = e.damage_max * 0.35
                    e.damage_type = DAMAGE_MAGICAL
                    e.damage_radius = e.damage_radius * range_factor
                    e.render.sprites[1].scale = V.vv(range_factor)
                end
                e.damage_factor = this.damage_factor
                queue_insert(store, e)

                a = a + this.angle_increment

                if a > 2 * math.pi then
                    a = a - 2 * math.pi
                end
            end

            U.y_wait(store, 0.5)

            this.tween.reverse = true
            this.tween.remove = true
            this.tween.ts = store.tick_ts
        end
    }
    -- 马格努斯-奥术风暴
    scripts.magnus_arcane_rain = {
        update = function(this, store)
            this.render.sprites[1].ts = store.tick_ts

            U.animation_start(this, "drop", nil, store.tick_ts, 1)
            S:queue(this.sound)
            U.y_wait(store, this.hit_time)

            local targets = U.find_enemies_in_range(store.entities, this.pos, 0, this.damage_radius, this.damage_flags,
                this.damage_bans or 0)

            if targets then
                for _, target in pairs(targets) do
                    local d = E:create_entity("damage")
                    d.damage_type = this.damage_type
                    d.source_id = this.id
                    d.target_id = target.id
                    d.value = math.ceil(math.random(this.damage_min, this.damage_max) * this.damage_factor)
                    queue_damage(store, d)
                end
            end

            U.y_animation_wait(this)
            queue_remove(store, this)

        end
    }
    -- 马格努斯-幻影
    scripts.soldier_magnus_illusion = {
        update = function(this, store)
            -- as a soldier
            local brk, stam, star

            this.reinforcement.ts = store.tick_ts
            this.render.sprites[1].ts = store.tick_ts

            if this.sound_events and this.sound_events.raise then
                S:queue(this.sound_events.raise)
            end

            this.health_bar.hidden = true

            U.y_animation_play(this, "raise", nil, store.tick_ts, 1)

            if not this.health.dead then
                this.health_bar.hidden = nil
            end
            local arcane_rain = this.timed_attacks.list[1]
            while true do
                if this.health.dead or this.reinforcement.duration and store.tick_ts - this.reinforcement.ts >
                    this.reinforcement.duration then
                    if this.health.hp > 0 then
                        this.reinforcement.hp_before_timeout = this.health.hp
                    end
                    this.health.hp = 0
                    SU.y_soldier_death(store, this)
                    return
                end

                if this.unit.is_stunned then
                    SU.soldier_idle(store, this)
                else
                    SU.soldier_courage_upgrade(store, this)
                    -- enable arcane rain attack
                    if ready_to_use_skill(arcane_rain, store) then
                        local target = U.find_random_enemy(store.entities, this.pos, arcane_rain.min_range,
                            arcane_rain.max_range, arcane_rain.vis_flags, arcane_rain.vis_bans)

                        if not target then
                            SU.delay_attack(store, arcane_rain, 0.13333333333333333)
                        else
                            S:queue(arcane_rain.sound)

                            local flip = target.pos.x < this.pos.x
                            this.render.sprites[1].prefix = "hero_magnus"
                            U.animation_start(this, arcane_rain.animation, flip, store.tick_ts)

                            if U.y_wait(store, arcane_rain.cast_time, function()
                                return SU.soldier_interrupted(this)
                            end) then
                                goto label_34_0
                            end

                            arcane_rain.ts = store.tick_ts

                            local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni

                            if #target.enemy.blockers == 0 and P:is_node_valid(pi, ni + 5) then
                                ni = ni + 5
                            end

                            local pos = P:node_pos(pi, spi, ni)
                            local e = E:create_entity(arcane_rain.entity)
                            e.is_illusion = true
                            e.pos = pos
                            e.damage_factor = this.unit.damage_factor
                            e.render.sprites[1].scale = V.v(0.8, 0.8)
                            queue_insert(store, e)

                            if not U.y_animation_wait(this) then
                                this.render.sprites[1].prefix = "soldier_magnus_illusion"
                                goto label_34_0
                            end
                        end
                    end
                    if this.melee then
                        brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

                        if brk or stam == A_DONE or stam == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
                            goto label_34_1
                        end
                    end

                    if this.ranged then
                        brk, star = SU.y_soldier_ranged_attacks(store, this)

                        if brk or star == A_DONE then
                            goto label_34_1
                        elseif star == A_IN_COOLDOWN then
                            goto label_34_0
                        end
                    end

                    if this.melee.continue_in_cooldown and stam == A_IN_COOLDOWN then
                        goto label_34_1
                    end

                    if SU.soldier_go_back_step(store, this) then
                        goto label_34_1
                    end

                    ::label_34_0::

                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end

                ::label_34_1::

                coroutine.yield()
            end
        end
    }
    -- 马格努斯
    scripts.hero_magnus = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)
            this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

            local ra = this.ranged.attacks[1]
            local b = E:get_template(ra.bullet)

            b.bullet.damage_min = ls.ranged_damage_min[hl]
            b.bullet.damage_max = ls.ranged_damage_max[hl]

            upgrade_skill(this, "mirage", function(this, s)
                local a = this.timed_attacks.list[1]
                a.disabled = nil
                a.count = s.count[s.level]
                local il = E:get_template(a.entity)
                il.level = hl
                il.health.hp_max = ls.hp_max[s.level] * s.health_factor
                il.melee.attacks[1].damage_min = math.floor(ls.melee_damage_min[s.level] * s.damage_factor)
                il.melee.attacks[1].damage_max = math.floor(ls.melee_damage_max[s.level] * s.damage_factor)
                local ira = il.ranged.attacks[1]
                local ib = E:get_template(ira.bullet)

                ib.bullet.damage_min = math.floor(ls.ranged_damage_min[s.level] * s.damage_factor)
                ib.bullet.damage_max = math.floor(ls.ranged_damage_max[s.level] * s.damage_factor)
                il.timed_attacks = il.timed_attacks or {}
                il.timed_attacks.list = il.timed_attacks.list or {}
                il.timed_attacks.list[1] = table.deepclone(this.timed_attacks.list[2])
            end)

            upgrade_skill(this, "arcane_rain", function(this, s)
                local a = this.timed_attacks.list[2]
                a.disabled = nil
                local c = E:get_template(a.entity)
                c.count = s.count[s.level]
                local r = E:get_template(c.entity)
                r.damage_min = s.damage[s.level]
                r.damage_max = s.damage[s.level]
            end)

            this.health.hp = this.health.hp_max
        end,
        update = function(this, store)
            local h = this.health
            local he = this.hero
            local a, skill, brk, sta
            local function d2r(d)
                return d * math.pi / 180
            end
            U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)

            this.health_bar.hidden = false

            while true do
                if h.dead then
                    SU.y_hero_death_and_respawn(store, this)
                end

                if this.unit.is_stunned then
                    SU.soldier_idle(store, this)
                else
                    while this.nav_rally.new do
                        if SU.y_hero_new_rally(store, this) then
                            goto label_75_0
                        end
                    end

                    skill = this.hero.skills.mirage
                    a = this.timed_attacks.list[1]

                    if ready_to_use_skill(a, store) then
                        S:queue(a.sound)
                        U.animation_start(this, a.animation, nil, store.tick_ts)

                        if U.y_wait(store, a.cast_time, function()
                            return SU.hero_interrupted(this)
                        end) then
                            goto label_75_0
                        end

                        SU.hero_gain_xp_from_skill(this, skill)

                        a.ts = store.tick_ts

                        for i = 1, a.count do
                            local angle = d2r(360 * i / a.count)
                            local o = V.v(V.rotate(angle, a.initial_pos.x, a.initial_pos.y))
                            local r = V.v(V.rotate(angle, a.initial_rally.x, a.initial_rally.y))
                            local e = E:create_entity(a.entity)
                            local rx, ry = this.pos.x + r.x, this.pos.y + r.y

                            e.nav_rally.center = V.v(rx, ry)
                            e.nav_rally.pos = V.v(rx, ry)
                            e.pos.x, e.pos.y = this.pos.x + o.x, this.pos.y + o.y
                            e.tween.ts = store.tick_ts
                            e.tween.props[1].keys[1][2].x = -o.x
                            e.tween.props[1].keys[1][2].y = -o.y
                            e.render.sprites[1].flip_x = this.render.sprites[1].flip_x
                            e.owner = this

                            queue_insert(store, e)
                        end

                        if not U.y_animation_wait(this) then
                            goto label_75_0
                        end
                    end

                    skill = this.hero.skills.arcane_rain
                    a = this.timed_attacks.list[2]

                    if ready_to_use_skill(a, store) then
                        local target = U.find_random_enemy(store.entities, this.pos, a.min_range, a.max_range,
                            a.vis_flags, a.vis_bans)

                        if not target then
                            SU.delay_attack(store, a, 0.13333333333333333)
                        else
                            S:queue(a.sound)

                            local flip = target.pos.x < this.pos.x

                            U.animation_start(this, a.animation, flip, store.tick_ts)

                            if U.y_wait(store, a.cast_time, function()
                                return SU.hero_interrupted(this)
                            end) then
                                goto label_75_0
                            end

                            SU.hero_gain_xp_from_skill(this, skill)

                            a.ts = store.tick_ts

                            local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni

                            if #target.enemy.blockers == 0 and P:is_node_valid(pi, ni + 5) then
                                ni = ni + 5
                            end

                            local pos = P:node_pos(pi, spi, ni)
                            local e = E:create_entity(a.entity)

                            e.pos = pos
                            e.damage_factor = this.unit.damage_factor
                            e.render.sprites[1].scale = V.v(1, 1)
                            queue_insert(store, e)

                            if not U.y_animation_wait(this) then
                                goto label_75_0
                            end
                        end
                    end

                    if SU.hero_level_up(store, this) then
                        U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)
                    end

                    brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                    if brk or sta ~= A_NO_TARGET then
                        -- block empty
                    else
                        brk, sta = SU.y_soldier_ranged_attacks(store, this)

                        if brk then
                            -- block empty
                        elseif SU.soldier_go_back_step(store, this) then
                            -- block empty
                        else
                            SU.soldier_idle(store, this)
                            SU.soldier_regen(store, this)
                        end
                    end
                end
                ::label_75_0::
                coroutine.yield()
            end
        end
    }
    -- 格劳尔-巨石
    scripts.giant_boulder = {
        insert = function(this, store, script)
            if not scripts.bomb.insert(this, store, script) then
                return false
            end

            local b = this.bullet
            local target = store.entities[b.target_id]

            if not target then
                return false
            end

            if target.unit and target.unit.hit_offset then
                b.hit_fx_sort_y_offset = -1 - target.unit.hit_offset.y

                if target.unit.hit_offset.y > 23 then
                    b.hit_decal = nil
                end
            end

            return true
        end
    }
    -- 格劳尔-岩晶肘击
    scripts.mod_giant_massivedamage = {
        insert = function(this, store, script)
            local m = this.modifier
            local source = store.entities[m.source_id]
            local target = store.entities[m.target_id]

            if not source or not target or target.health.dead then
                return false
            end

            this.pos = V.vclone(target.pos)

            local s = this.render.sprites[1]

            s.name = s.name .. "_" .. s.size_names[target.unit.size]
            s.anchor.y = s.size_anchors_y[target.unit.size]
            s.flip_x = source.render.sprites[1].flip_x
            s.ts = store.tick_ts

            local d = E:create_entity("damage")

            d.source_id = this.id
            d.target_id = target.id
            d.damage_type = DAMAGE_TRUE
            d.value = math.ceil(source.unit.damage_factor *
                                    (math.random(this.damage_min, this.damage_max) + source.damage_buff))

            local predicted_damage = math.ceil(d.value * target.health.damage_factor)

            if math.random() < this.instakill_chance then
                if (band(target.vis.flags, F_BOSS) ~= 0) or target.health.hp - predicted_damage > this.instakill_min_hp then
                    d.value = d.value * 2
                else
                    d.damage_type = DAMAGE_INSTAKILL
                end
            end

            queue_damage(store, d)

            return true
        end
    }
    -- 格劳尔-堡垒
    scripts.aura_giant_bastion = {
        update = function(this, store, script)
            local hero = store.entities[this.aura.source_id]

            this.pos = hero.pos

            local enabled = false
            local added_damage = 0
            local attack = hero.melee.attacks[1]
            local last_tick = store.tick_ts
            local last_pos = V.vclone(this.pos)
            local s = this.render.sprites[1]

            local function add_damage(value)
                SU.damage_inc(hero, value)
                added_damage = added_damage + value
            end

            while true do
                local rally_pos = hero.nav_rally.pos

                if enabled then
                    if hero.health.dead then
                        enabled = false
                        add_damage(-added_damage)
                        added_damage = 0
                    elseif V.dist(rally_pos.x, rally_pos.y, hero.pos.x, hero.pos.y) > this.max_distance and
                        store.tick_ts - last_tick > this.tick_time then
                        add_damage(-this.damage_per_tick)
                        last_tick = store.tick_ts
                    elseif added_damage < this.max_damage and store.tick_ts - last_tick > this.tick_time then
                        add_damage(this.damage_per_tick)
                        last_tick = store.tick_ts
                    end
                elseif not hero.health.dead and V.dist(rally_pos.x, rally_pos.y, hero.pos.x, hero.pos.y) <
                    this.max_distance then
                    enabled = true
                    added_damage = 0
                    last_tick = store.tick_ts
                end

                s.hidden = added_damage == 0

                local new_scale

                new_scale = added_damage == this.max_damage and 1 or added_damage > 0 and 0.5 or 0

                if new_scale ~= s.scale.x then
                    s.ts = store.tick_ts
                    s.scale.x, s.scale.y = new_scale, new_scale
                end
                coroutine.yield()
            end
        end
    }
    -- 格劳尔
    scripts.hero_giant = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)
            this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

            upgrade_skill(this, "boulderthrow", function(this, s)
                this.ranged.attacks[1].disabled = nil
                local b = E:get_template(this.ranged.attacks[1].bullet)
                b.bullet.damage_min = s.damage_min[s.level]
                b.bullet.damage_max = s.damage_max[s.level]
            end)

            upgrade_skill(this, "stomp", function(this, s)
                local a = this.timed_attacks.list[1]
                a.disabled = nil
                a.damage = s.damage[s.level]
                a.loops = s.loops[s.level]
                local stun = E:get_template("mod_giant_stun")
                stun.modifier.duration = s.stun_duration[s.level]
            end)

            upgrade_skill(this, "bastion", function(this, s)
                local a = E:get_template(this.auras.list[1].name)
                a.damage_per_tick = s.damage_per_tick[s.level]
                a.max_damage = s.max_damage[s.level]

                local aura_baston_key = table.find(store.entities, function(k, v)
                    return v.template_name == this.auras.list[1].name
                end)

                if (aura_baston_key) then
                    local aura_baston = store.entities[aura_baston_key]
                    aura_baston.damage_per_tick = s.damage_per_tick[s.level]
                    aura_baston.max_damage = s.max_damage[s.level]
                end
            end)

            upgrade_skill(this, "hardrock", function(this, s)
                this.hardrock_extra_hp = s.extra_hp[s.level]
                this.health.damage_block = s.damage_block[s.level]
            end)

            this.health.hp_max = this.health.hp_max + this.hardrock_extra_hp
            update_regen(this)

            upgrade_skill(this, "massivedamage", function(this, s)
                this.melee.attacks[2].disabled = nil
                local mod = E:get_template(this.melee.attacks[2].mod)
                mod.instakill_chance = s.chance[s.level]
                mod.instakill_min_hp = this.health.hp_max / s.health_factor
                mod.damage_min = ls.melee_damage_min[hl] + s.extra_damage[s.level]
                mod.damage_max = ls.melee_damage_max[hl] + s.extra_damage[s.level]
            end)

            this.health.hp = this.health.hp_max
        end,

        insert = function(this, store, script)
            this.hero.fn_level_up(this, store)

            this.melee.order = U.attack_order(this.melee.attacks)
            this.ranged.order = U.attack_order(this.ranged.attacks)

            local e = E:create_entity(this.auras.list[1].name)
            e.aura.source_id = this.id
            queue_insert(store, e)

            return true
        end,

        update = function(this, store, script)
            local h = this.health
            local he = this.hero
            local a, skill, brk, sta

            local function do_stomp(attack, targets)
                if not targets then
                    return
                end

                for _, t in pairs(targets) do
                    local d = E:create_entity("damage")

                    d.source_id = this.id
                    d.target_id = t.id
                    d.value = math.ceil((attack.damage + this.damage_buff) * this.unit.damage_factor)
                    d.damage_type = attack.damage_type

                    queue_damage(store, d)

                    local m = E:create_entity("mod_giant_slow")
                    m.modifier.source_id = this
                    m.modifier.target_id = t.id
                    queue_insert(store, m)
                end

                local stun_targets = table.filter(targets, function(k, v)
                    return v.vis and band(v.vis.bans, attack.stun_vis_flags) == 0 and
                               band(v.vis.flags, attack.stun_vis_bans) == 0
                end)

                if #stun_targets > 0 and math.random() < attack.stun_chance then
                    local t = table.random(stun_targets)
                    local m = E:create_entity("mod_giant_stun")
                    m.modifier.source_id = this
                    m.modifier.target_id = t.id
                    queue_insert(store, m)
                end
            end

            U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

            this.health_bar.hidden = false

            while true do
                if h.dead then
                    if band(h.last_damage_types, bor(DAMAGE_DISINTEGRATE, DAMAGE_HOST, DAMAGE_EAT)) == 0 then
                        this.unit.hide_after_death = true

                        local remains = E:create_entity("giant_death_remains")

                        remains.pos.x, remains.pos.y = this.pos.x, this.pos.y
                        remains.render.sprites[1].ts = store.tick_ts
                        remains.render.sprites[2].ts = store.tick_ts

                        queue_insert(store, remains)
                    end

                    SU.y_hero_death_and_respawn(store, this)
                end

                if this.unit.is_stunned then
                    SU.soldier_idle(store, this)
                else
                    while this.nav_rally.new do
                        if SU.y_hero_new_rally(store, this) then
                            goto label_306_0
                        end
                    end

                    if SU.hero_level_up(store, this) then
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    end

                    a = this.timed_attacks.list[1]
                    skill = this.hero.skills.stomp

                    if ready_to_use_skill(a, store) then
                        local targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range,
                            a.vis_flags, a.vis_bans)

                        if not targets then
                            -- block empty
                        else
                            local targets_hp = table.map(targets, function(k, v)
                                return v.health and v.health.hp or 0
                            end)
                            local max_target_hp_idx, max_target_hp = table.maxv(targets_hp)

                            if #targets < a.trigger_min_enemies and max_target_hp < a.trigger_min_hp then
                                SU.delay_attack(store, a, 0.13333333333333333)
                            else
                                a.ts = store.tick_ts

                                SU.hero_gain_xp_from_skill(this, skill)

                                for i = 1, a.loops do
                                    if this.health.dead or this.nav_rally.new then
                                        break
                                    end

                                    local flip_sign = this.render.sprites[1].flip_x and -1 or 1
                                    local start_ts = store.tick_ts
                                    local targets = U.find_enemies_in_range(store.entities, this.pos, 0,
                                        a.damage_radius, a.damage_flags, a.damage_bans)

                                    S:queue("HeroGiantStomp")
                                    U.animation_start(this, "stomp", nil, store.tick_ts, false)

                                    while store.tick_ts - start_ts < a.hit_times[1] do
                                        coroutine.yield()
                                    end

                                    do_stomp(a, targets)

                                    local fx = E:create_entity("giant_stomp_decal")

                                    fx.pos = V.v(this.pos.x - 20 * flip_sign, this.pos.y - 2)
                                    fx.render.sprites[1].ts = store.tick_ts

                                    queue_insert(store, fx)

                                    while store.tick_ts - start_ts < a.hit_times[2] do
                                        coroutine.yield()
                                    end

                                    do_stomp(a, targets)

                                    local fx = E:create_entity("giant_stomp_decal")

                                    fx.pos = V.v(this.pos.x + 19 * flip_sign, this.pos.y + 5)
                                    fx.render.sprites[1].ts = store.tick_ts

                                    queue_insert(store, fx)
                                    U.y_animation_wait(this)
                                end

                                goto label_306_0
                            end
                        end
                    end

                    brk, sta = SU.y_soldier_ranged_attacks(store, this)

                    if brk then
                        -- block empty
                    else
                        brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                        if brk or sta ~= A_NO_TARGET then
                            -- block empty
                        elseif SU.soldier_go_back_step(store, this) then
                            -- block empty
                        else
                            SU.soldier_idle(store, this)
                            SU.soldier_regen(store, this)
                        end
                    end
                end

                ::label_306_0::

                coroutine.yield()
            end
        end,

        on_damage = function(this, store, damage)
            damage.value = damage.value - this.health.damage_block
            damage.value = math.max(0, damage.value)
            return true
        end
    }
    -- 骨龙
    scripts.hero_dracolich = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)

            local b = E:get_template("fireball_dracolich")

            b.bullet.damage_max = ls.ranged_damage_max[hl]
            b.bullet.damage_min = ls.ranged_damage_min[hl]

            local m = E:get_template("mod_dracolich_disease")

            m.dps.damage_min = ls.disease_damage[hl]
            m.dps.damage_max = ls.disease_damage[hl]

            upgrade_skill(this, "spinerain", function(this, s)
                this.timed_attacks.list[2].disabled = nil
                b = E:get_template("dracolich_spine")
                b.bullet.damage_min = s.damage_min[s.level]
                b.bullet.damage_max = s.damage_max[s.level]
            end)

            upgrade_skill(this, "bonegolem", function(this, s)
                this.timed_attacks.list[1].disabled = nil
                local g = E:get_template("soldier_dracolich_golem")
                g.health.hp_max = s.hp_max[s.level]
                g.reinforcement.duration = s.duration[s.level]
                g.melee.attacks[1].damage_max = s.damage_max[s.level]
                g.melee.attacks[1].damage_min = s.damage_min[s.level]
            end)

            upgrade_skill(this, "plaguecarrier", function(this, s)
                this.timed_attacks.list[4].disabled = nil
                this.timed_attacks.list[4].count = s.count[s.level]
                local a = E:get_template("dracolich_plague_carrier")
                a.aura.duration = s.duration[s.level]
                E:get_template("dracolich_spine").bullet.mod = "mod_dracolich_disease"
                E:get_template("fireball_dracolich").bullet.mod = "mod_dracolich_disease"
            end)

            upgrade_skill(this, "diseasenova", function(this, s)
                local a = this.timed_attacks.list[3]
                a.disabled = nil
                a.damage_min = s.damage_min[s.level]
                a.damage_max = s.damage_max[s.level]
            end)

            upgrade_skill(this, "unstabledisease", function(this, s)
                local m = E:get_template("mod_dracolich_disease")
                m.spread_damage = s.spread_damage[s.level]
                m.spread_active = true
            end)

            this.health.hp = this.health.hp_max
        end
    }
    -- 黑棘船长
    scripts.hero_pirate = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)

            this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

            local bt = E:get_template(this.ranged.attacks[1].bullet)
            bt.bullet.damage_min = ls.ranged_damage_min[hl]
            bt.bullet.damage_max = ls.ranged_damage_max[hl]

            upgrade_skill(this, "swordsmanship", function(this, s)
                this.swordsmanship_extra = s.extra_damage[s.level]
            end)

            upgrade_skill(this, "looting", function(this, s)
                local m = E:get_template("mod_pirate_loot")
                m.percent = s.percent[s.level]
            end)

            upgrade_skill(this, "kraken", function(this, s)
                this.timed_attacks.list[1].disabled = nil
                local ka = E:get_template("kraken_aura")
                ka.max_active_targets = s.max_enemies[s.level]
                local m = E:get_template("mod_slow_kraken")
                m.slow.factor = s.slow_factor[s.level]
            end)

            upgrade_skill(this, "scattershot", function(this, s)
                this.timed_attacks.list[2].disabled = nil
                local b = E:get_template("pirate_exploding_barrel")
                b.fragments = s.fragments[s.level]
                local bf = E:get_template("barrel_fragment")
                bf.bullet.damage_min = s.fragment_damage[s.level]
                bf.bullet.damage_max = bf.bullet.damage_min
            end)

            upgrade_skill(this, "toughness", function(this, s)
                this.toughness_extra_hp = s.hp_max[s.level]
            end)

            this.melee.attacks[1].damage_min = this.melee.attacks[1].damage_min + this.swordsmanship_extra
            this.melee.attacks[1].damage_max = this.melee.attacks[1].damage_max + this.swordsmanship_extra

            this.health.hp_max = this.health.hp_max + this.toughness_extra_hp
            update_regen(this)

            this.health.hp = this.health.hp_max
        end
    }
    -- 冰女
    scripts.hero_elora = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)

            this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

            for i = 1, 2 do
                local bt = E:get_template(this.ranged.attacks[i].bullet)
                bt.bullet.damage_min = ls.ranged_damage_min[hl]
                bt.bullet.damage_max = ls.ranged_damage_max[hl]
            end

            upgrade_skill(this, "chill", function(this, s)
                local a = this.timed_attacks.list[2]
                a.disabled = nil
                a.max_range = s.max_range[s.level]
                a.count = s.count[s.level]
                local b = E:get_template(a.bullet)
                b.aura.level = s.level
                local m = E:get_template("mod_elora_chill")
                m.slow.factor = s.slow_factor[s.level]
            end)

            upgrade_skill(this, "ice_storm", function(this, s)
                local a = this.timed_attacks.list[1]
                a.disabled = nil
                a.count = s.count[s.level]
                a.max_range = s.max_range[s.level]
                local b = E:get_template(a.bullet)
                b.bullet.damage_min = s.damage_min[s.level]
                b.bullet.damage_max = s.damage_max[s.level]
            end)

            this.health.hp = this.health.hp_max
        end
    }
    -- 钢锯
    scripts.hero_hacksaw = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)

            this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

            upgrade_skill(this, "sawblade", function(this, s)
                local a = this.ranged.attacks[1]
                a.disabled = nil
                local b = E:get_template(a.bullet)
                b.bounces_max = s.bounces[s.level]
            end)
            upgrade_skill(this, "timber", function(this, s)
                local a = this.melee.attacks[2]
                a.disabled = nil
                a.cooldown = s.cooldown[s.level]
            end)

            this.health.hp = this.health.hp_max
        end
    }
    -- 英格瓦
    scripts.hero_ingvar = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)

            this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
            this.melee.attacks[2].damage_min = ls.melee_damage_min[hl] * 1.2
            this.melee.attacks[2].damage_max = ls.melee_damage_max[hl] * 1.2

            upgrade_skill(this, "ancestors_call", function(this, s)
                local a = this.timed_attacks.list[1]
                a.disabled = nil
                a.count = s.count[s.level]
                local e = E:get_template(a.entity)
                e.health.hp_max = s.hp_max[s.level]
                e.melee.attacks[1].damage_min = s.damage_min[s.level]
                e.melee.attacks[1].damage_max = s.damage_max[s.level]
                e.motion.max_speed = s.max_speed[s.level]
            end)

            upgrade_skill(this, "bear", function(this, s)
                local a = this.timed_attacks.list[2]
                a.duration = s.duration[s.level]
                a.disabled = nil
                local a = this.melee.attacks[3]
                a.damage_min = s.damage_min[s.level]
                a.damage_max = s.damage_max[s.level]
            end)

            this.health.hp = this.health.hp_max
        end,
        get_info = function(this)
            local info = scripts.soldier_barrack.get_info(this)
            if this.is_bear then
                info.ranged_damage_max = nil
                info.ranged_damage_min = nil
                info.ranged_damage_type = nil
                info.damage_min = (this.melee.attacks[3].damage_min + this.damage_buff) * this.unit.damage_factor
                info.damage_max = (this.melee.attacks[3].damage_max + this.damage_buff) * this.unit.damage_factor
                info.damage_type = this.melee.attacks[3].damage_type
            end
            return info
        end,
        update = function(this, store)
            local h = this.health
            local he = this.hero
            local ba = this.timed_attacks.list[2]
            local a, skill, brk, sta

            local function go_bear()
                this.sound_events.change_rally_point = this.sound_events.change_rally_point_bear

                for i = 1, 2 do
                    this.melee.attacks[i].disabled = true
                end

                this.melee.attacks[3].disabled = false
                this.health.immune_to = ba.immune_to

                S:queue(ba.sound)
                U.y_animation_play(this, "toBear", nil, store.tick_ts, 1)

                this.render.sprites[1].prefix = "hero_ingvar_bear"
                ba.ts = store.tick_ts
                this.is_bear = true
            end

            local function go_viking()
                this.sound_events.change_rally_point = this.sound_events.change_rally_point_viking

                for i = 1, 2 do
                    this.melee.attacks[i].disabled = false
                end

                this.melee.attacks[3].disabled = true

                this.is_bear = false
                U.y_animation_play(this, "toViking", nil, store.tick_ts, 1)

                this.render.sprites[1].prefix = "hero_ingvar"

                this.health.immune_to = DAMAGE_NONE

                ba.ts = store.tick_ts
            end

            for _, an in pairs(this.auras.list) do
                local aura = E:create_entity(an.name)
                aura.aura.source_id = this.id
                queue_insert(store, aura)
            end

            U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

            this.health_bar.hidden = false

            while true do
                if h.dead then
                    if this.is_bear then
                        go_viking()
                    end

                    SU.y_hero_death_and_respawn(store, this)
                end

                if this.unit.is_stunned then
                    SU.soldier_idle(store, this)
                else
                    while this.nav_rally.new do
                        if SU.y_hero_new_rally(store, this) then
                            goto label_67_0
                        end
                    end

                    if SU.hero_level_up(store, this) and not this.is_bear then
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    end

                    a = ba
                    skill = this.hero.skills.bear

                    if not this.is_bear and ready_to_use_skill(a, store) and this.health.hp < this.health.hp_max *
                        a.transform_health_factor then
                        SU.hero_gain_xp_from_skill(this, skill)
                        go_bear()
                    elseif this.is_bear and store.tick_ts - a.ts >= a.duration then
                        go_viking()
                    end

                    a = this.timed_attacks.list[1]
                    skill = this.hero.skills.ancestors_call

                    if ready_to_use_skill(a, store) then
                        if this.is_bear then
                            local compensation = ba.duration - (store.tick_ts - ba.ts)
                            go_viking()
                            ba.ts = ba.ts - compensation
                        end
                        local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, nil, NF_RALLY)

                        if #nodes < 1 then
                            SU.delay_attack(store, a, 0.4)
                        else
                            U.animation_start(this, a.animation, nil, store.tick_ts, 1)
                            S:queue(a.sound, a.sound_args)

                            if SU.y_hero_wait(store, this, a.cast_time) then
                                goto label_67_0
                            end

                            SU.hero_gain_xp_from_skill(this, skill)

                            a.ts = store.tick_ts

                            local pi, spi, ni = unpack(nodes[1])
                            local no_min, no_max = unpack(a.nodes_offset)
                            local no

                            for i = 1, a.count do
                                local e = E:create_entity(a.entity)
                                local e_spi, e_ni = math.random(1, 3), ni

                                no = math.random(no_min, no_max) * U.random_sign()

                                if P:is_node_valid(pi, e_ni + no) then
                                    e_ni = e_ni + no
                                end

                                e.nav_rally.center = P:node_pos(pi, e_spi, e_ni)
                                e.nav_rally.pos = V.vclone(e.nav_rally.center)
                                e.pos = V.vclone(e.nav_rally.center)
                                e.render.sprites[1].name = "raise"
                                e.owner = this

                                queue_insert(store, e)
                            end

                            SU.y_hero_animation_wait(this)

                            goto label_67_0
                        end
                    end

                    brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                    if brk or sta ~= A_NO_TARGET then
                        -- block empty
                    elseif SU.soldier_go_back_step(store, this) then
                        -- block empty
                    else
                        SU.soldier_idle(store, this)
                        SU.soldier_regen(store, this)
                    end
                end

                ::label_67_0::

                coroutine.yield()
            end
        end
    }
    -- 火男
    scripts.hero_ignus = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)
            this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
            this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]
            if hl == 2 then
                this.melee.attacks[2].mod = "mod_ignus_burn_1"
                this.melee.attacks[2].chance = 0.4
            elseif hl == 5 then
                this.melee.attacks[2].mod = "mod_ignus_burn_2"
                this.melee.attacks[2].chance = 0.5
            elseif hl == 8 then
                this.melee.attacks[2].mod = "mod_ignus_burn_3"
                this.melee.attacks[2].chance = 0.6
            end

            upgrade_skill(this, "flaming_frenzy", function(this, s)
                local a = this.timed_attacks.list[1]
                a.disabled = nil
                a.damage_min = s.damage_min[s.level]
                a.damage_max = s.damage_max[s.level]
            end)

            upgrade_skill(this, "surge_of_flame", function(this, s)
                local a = this.timed_attacks.list[2]
                a.disabled = nil
                local aura = E:get_template("aura_ignus_surge_of_flame")
                aura.aura.damage_min = s.damage_min[s.level]
                aura.aura.damage_max = s.damage_max[s.level]
            end)

            this.health.hp = this.health.hp_max
        end
    }
    -- 鬼侍
    scripts.hero_oni = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)
            this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

            upgrade_skill(this, "death_strike", function(this, s)
                local a = this.melee.attacks[2]
                a.disabled = nil
                a.chance = s.chance[s.level]
                a = this.melee.attacks[3]
                a.disabled = nil
                a.damage_min = s.damage[s.level]
                a.damage_max = s.damage[s.level]
            end)

            upgrade_skill(this, "torment", function(this, s)
                local a = this.timed_attacks.list[1]
                a.disabled = nil
                a.damage_min = s.min_damage[s.level]
                a.damage_max = s.max_damage[s.level]
            end)

            upgrade_skill(this, "rage", function(this, s)
                this.rage_max = s.rage_max[s.level]
                this.unyield_max = s.unyield_max[s.level]
            end)

            this.health.hp = this.health.hp_max
        end
    }
    -- 索尔
    scripts.hero_thor = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)

            this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
            this.melee.cooldown = ls.melee_cooldown[hl]
            this.lightning_heal = ls.lightning_heal[hl]
            this.melee.attacks[1].cooldown = ls.melee_cooldown[hl]
            this.melee.attacks[2].cooldown = ls.melee_cooldown[hl]

            upgrade_skill(this, "chainlightning", function(this, s)
                local a = this.melee.attacks[2]
                a.disabled = nil
                a.level = s.level
                a.chance = s.chance[s.level]
                local mod = E:get_template(a.mod)
                mod.chainlightning.count = s.count[s.level]
                mod.chainlightning.damage = s.damage_max[s.level]
            end)

            upgrade_skill(this, "thunderclap", function(this, s)
                local a = this.ranged.attacks[1]
                a.disabled = nil
                a.level = s.level
                local b = E:get_template(a.bullet)
                local mod = E:get_template(b.bullet.mod)
                mod.thunderclap.damage = s.damage_max[s.level]
                mod.thunderclap.secondary_damage = s.secondary_damage_max[s.level]
                mod.thunderclap.stun_duration_max = s.stun_duration[s.level]
                mod.thunderclap.max_range = s.max_range[s.level]
            end)

            this.health.hp = this.health.hp_max
        end
    }
    -- 天十
    scripts.hero_10yr = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)
            this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
            this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

            upgrade_skill(this, "rain", function(this, s)
                local a = this.timed_attacks.list[1]
                a.disabled = nil
                local au = E:get_template(a.entity)
                au.aura.loops = s.loops[s.level]
                local bt = E:get_template(au.aura.entity)
                bt.bullet.damage_min = s.damage_min[s.level]
                bt.bullet.damage_max = s.damage_max[s.level]
                if s.level == 3 then
                    bt.scorch_earth = true
                end
            end)

            upgrade_skill(this, "buffed", function(this, s)
                local a = this.timed_attacks.list[2]
                a.duration = s.duration[s.level]
                a.disabled = nil
                local a = this.timed_attacks.list[3]
                a.damage_min = s.bomb_damage_min[s.level]
                a.damage_max = s.bomb_damage_max[s.level]
                if s.level == 3 then
                    a.sound = a.sound_long
                end
                local au = E:get_template(a.hit_aura)
                au.aura.steps = s.bomb_steps[s.level]
                au.aura.damage_min = s.bomb_step_damage_min[s.level]
                au.aura.damage_max = s.bomb_step_damage_max[s.level]
                local a = this.melee.attacks[3]
                a.damage_min = s.spin_damage_min[s.level]
                a.damage_max = s.spin_damage_max[s.level]
            end)

            this.health.hp = this.health.hp_max
        end
    }
    -- 红龙
    scripts.hero_dragon = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)

            local b = E:get_template("fireball_dragon")

            b.bullet.damage_max = ls.ranged_damage_max[hl]
            b.bullet.damage_min = ls.ranged_damage_min[hl]

            upgrade_skill(this, "blazingbreath", function(this, s)
                this.ranged.attacks[2].disabled = nil
                local b = E:get_template("breath_dragon")
                b.bullet.damage_min = s.damage[s.level]
                b.bullet.damage_max = s.damage[s.level]
            end)

            upgrade_skill(this, "feast", function(this, s)
                local a = this.timed_attacks.list[1]
                a.disabled = nil
                a.damage = s.damage[s.level]
                a.devour_chance = s.devour_chance[s.level]
            end)

            upgrade_skill(this, "fierymist", function(this, s)
                local a = this.ranged.attacks[3]
                a.disabled = nil
                local aura = E:get_template("aura_fierymist_dragon")
                aura.aura.duration = s.duration[s.level]
                local m = E:get_template("mod_slow_fierymist")
                m.slow.factor = s.slow_factor[s.level]
            end)

            upgrade_skill(this, "wildfirebarrage", function(this, s)
                local a = this.ranged.attacks[4]
                a.disabled = nil
                local b = E:get_template("wildfirebarrage_dragon")
                b.explosions = s.explosions[s.level]
            end)

            upgrade_skill(this, "reignoffire", function(this, s)
                local m = E:get_template("mod_dragon_reign")
                m.dps.damage_min = s.dps[s.level] * m.dps.damage_every / m.modifier.duration
                m.dps.damage_max = s.dps[s.level] * m.dps.damage_every / m.modifier.duration
                local b = E:get_template("fireball_dragon")
                b.bullet.mod = "mod_dragon_reign"
                local b = E:get_template("breath_dragon")
                b.bullet.mod = "mod_dragon_reign"
                local b = E:get_template("wildfirebarrage_dragon")
                b.bullet.mod = "mod_dragon_reign"
            end)

            this.health.hp = this.health.hp_max
        end
    }
    -- 卢克雷齐娅
    scripts.hero_vampiress = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)

            upgrade_skill(this, "vampirism", function(this, s)
                local a = this.melee.attacks[2]
                a.disabled = nil
                a.damage_min = s.damage[s.level]
                a.damage_max = s.damage[s.level]
                local m = E:get_template("mod_vampiress_lifesteal")
                m.heal_hp = s.damage[s.level]
            end)

            upgrade_skill(this, "slayer", function(this, s)
                local a = this.timed_attacks.list[1]
                a.disabled = nil
                a.damage_min = s.damage_min[s.level]
                a.damage_max = s.damage_max[s.level]
            end)

            local gain = E:get_template("mod_vampiress_gain").gain
            this.health.hp_max = this.health.hp_max + this.gain_count * gain.hp
            update_regen(this)
            inc_armor_by_skill(this, this.gain_count * gain.armor)
            inc_magic_armor_by_skill(this, this.gain_count * gain.magic_armor)

            local a = this.melee.attacks[1]
            a.damage_min = ls.melee_damage_min[hl] + this.gain_count * gain.damage
            a.damage_max = ls.melee_damage_max[hl] + this.gain_count * gain.damage

            this.health.hp = this.health.hp_max
        end
    }
    -- 沙塔
    scripts.hero_alien = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)
            this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

            upgrade_skill(this, "energyglaive", function(this, s)
                local a = this.ranged.attacks[1]
                a.disabled = nil
                local b = E:get_template(a.bullet)
                b.bullet.damage_min = s.damage[s.level]
                b.bullet.damage_max = s.damage[s.level]
                b.bounce_chance = s.bounce_chance[s.level]
            end)

            upgrade_skill(this, "purificationprotocol", function(this, s)
                local a = this.timed_attacks.list[2]
                a.disabled = nil
                local e = E:get_template(a.entity)
                e.duration = s.duration[s.level]
            end)

            upgrade_skill(this, "abduction", function(this, s)
                local a = this.timed_attacks.list[1]
                a.disabled = nil
                a.total_hp = s.total_hp[s.level]
                a.total_targets = s.total_targets[s.level]
            end)

            upgrade_skill(this, "vibroblades", function(this, s)
                local a = this.melee.attacks[1]
                a.damage_min = a.damage_min + s.extra_damage[s.level]
                a.damage_max = a.damage_max + s.extra_damage[s.level]
                a.damage_type = s.damage_type
            end)

            upgrade_skill(this, "finalcountdown", function(this, s)
                this.selfdestruct.disabled = nil
                this.selfdestruct.damage = s.damage[s.level]
            end)

            this.health.hp = this.health.hp_max
            this.ranged.attacks[1].ts = -this.ranged.attacks[1].cooldown
            this.timed_attacks.list[1].ts = -this.timed_attacks.list[1].cooldown
            this.timed_attacks.list[2].ts = -this.timed_attacks.list[2].cooldown
        end
    }
    -- 库绍
    scripts.hero_monk = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)

            this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
            this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]
            this.melee.attacks[3].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[3].damage_max = ls.melee_damage_max[hl]

            upgrade_skill(this, "snakestyle", function(this, s)
                local a = this.melee.attacks[4]
                a.disabled = nil
                a.damage_max = s.damage[s.level]
                a.damage_min = s.damage[s.level]
                local m = E:get_template("mod_monk_damage_reduction")
                m.reduction_factor = s.damage_reduction_factor[s.level]
            end)

            upgrade_skill(this, "dragonstyle", function(this, s)
                local a = this.timed_attacks.list[1]
                a.disabled = nil
                a.damage_min = s.damage_min[s.level]
                a.damage_max = s.damage_max[s.level]
            end)

            upgrade_skill(this, "tigerstyle", function(this, s)
                local a = this.melee.attacks[5]
                a.disabled = nil
                a.damage_max = s.damage[s.level]
                a.damage_min = s.damage[s.level]
            end)
            upgrade_skill(this, "leopardstyle", function(this, s)
                local a = this.timed_attacks.list[2]
                a.disabled = nil
                a.damage_max = s.damage_max[s.level]
                a.damage_min = s.damage_min[s.level]
                a.loops = s.loops[s.level]
            end)

            upgrade_skill(this, "cranestyle", function(this, s)
                this.dodge.disabled = nil
                this.dodge.chance = s.chance[s.level]
                this.dodge.damage = s.damage[s.level]
                this.dodge.cooldown = s.cooldown[s.level]
            end)

            this.health.hp = this.health.hp_max
            this.melee.attacks[4].ts = -this.melee.attacks[4].cooldown
            this.melee.attacks[5].ts = -this.melee.attacks[5].cooldown
            this.timed_attacks.list[1].ts = -this.timed_attacks.list[1].cooldown
            this.timed_attacks.list[2].ts = -this.timed_attacks.list[2].cooldown
        end,
        insert = function(this, store, script)
            this.hero.fn_level_up(this, store)
            this.melee.order = {
                [1] = 4,
                [2] = 5,
                [3] = 2,
                [4] = 3,
                [5] = 1
            }
            return true
        end,
        update = function(this, store, script)
            local h = this.health
            local he = this.hero
            local a, skill, brk, sta

            U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

            this.health_bar.hidden = false

            while true do
                if h.dead then
                    SU.y_hero_death_and_respawn(store, this)
                end

                if this.unit.is_stunned then
                    SU.soldier_idle(store, this)
                else
                    a = this.dodge
                    skill = this.hero.skills.cranestyle

                    if not a.disabled and a.active then
                        a.active = false

                        local target = store.entities[this.soldier.target_id]

                        if not target or target.health.dead then
                            -- block empty
                        else
                            local vis_bans = this.vis.bans

                            this.vis.bans = F_ALL
                            this.health_bar.hidden = true

                            SU.hide_modifiers(store, this, true)

                            a.ts = store.tick_ts

                            SU.hero_gain_xp_from_skill(this, skill)
                            S:queue(a.sound, {
                                delay = fts(15)
                            })
                            U.animation_start(this, a.animation, nil, store.tick_ts)

                            if SU.y_hero_wait(store, this, a.hit_time) then
                                this.vis.bans = vis_bans
                                this.health_bar.hidden = this.health.dead

                                goto label_393_2
                            end

                            local d = E:create_entity("damage")

                            d.source_id = this.id
                            d.target_id = target.id
                            d.value = (a.damage + this.damage_buff) * this.unit.damage_factor
                            d.damage_type = a.damage_type

                            queue_damage(store, d)

                            this.vis.bans = vis_bans
                            this.health_bar.hidden = false

                            SU.show_modifiers(store, this, true)

                            if SU.y_hero_animation_wait(this) then
                                goto label_393_2
                            end
                        end
                    end

                    while this.nav_rally.new do
                        if SU.y_hero_new_rally(store, this) then
                            goto label_393_2
                        end
                    end

                    if SU.hero_level_up(store, this) then
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    end

                    a = this.timed_attacks.list[1]
                    skill = this.hero.skills.dragonstyle

                    if not a.disabled and store.tick_ts - a.ts > a.cooldown then
                        local targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags,
                            a.vis_bans)

                        if not targets then
                            SU.delay_attack(store, a, 0.13333333333333333)
                        else
                            local start_ts = store.tick_ts
                            this.health.ignore_damage = true
                            S:queue(a.sound, {
                                delay = fts(5)
                            })

                            local an, af = U.animation_name_facing_point(this, a.animation, targets[1].pos)

                            U.animation_start(this, an, af, store.tick_ts, false)

                            while store.tick_ts - start_ts < a.hit_time do
                                if SU.hero_interrupted(this) then
                                    this.health.ignore_damage = nil
                                    goto label_393_2
                                end

                                coroutine.yield()
                            end

                            a.ts = start_ts

                            SU.hero_gain_xp_from_skill(this, skill)

                            targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.damage_radius, a.damage_flags,
                                a.damage_bans)

                            if targets then
                                for _, t in pairs(targets) do
                                    local d = E:create_entity("damage")

                                    d.source_id = this.id
                                    d.target_id = t.id
                                    d.value = (math.random(a.damage_min, a.damage_max) + this.damage_buff) * this.unit.damage_factor
                                    d.damage_type = a.damage_type

                                    queue_damage(store, d)
                                end
                            end

                            while not U.animation_finished(this) do
                                if SU.hero_interrupted(this) then
                                    break
                                end

                                coroutine.yield()
                            end
                            this.health.ignore_damage = nil
                            goto label_393_2
                        end
                    end

                    a = this.timed_attacks.list[2]
                    skill = this.hero.skills.leopardstyle

                    if not a.disabled and store.tick_ts - a.ts > a.cooldown then
                        local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

                        if not targets then
                            SU.delay_attack(store, a, 0.13333333333333333)

                            goto label_393_1
                        end

                        U.unblock_target(store, this)

                        this.health.ignore_damage = true
                        this.health_bar.hidden = true

                        local start_ts = store.tick_ts
                        local start_pos = V.vclone(this.pos)
                        local last_target
                        local i = 1

                        U.animation_start(this, "leopard_start", nil, store.tick_ts, false)

                        while not U.animation_finished(this) do
                            if SU.hero_interrupted(this) then
                                goto label_393_0
                            end
                            coroutine.yield()
                        end

                        a.ts = start_ts

                        SU.hero_gain_xp_from_skill(this, skill)

                        while i <= a.loops do
                            i = i + 1
                            targets = U.find_enemies_in_range(store.entities, start_pos, 0, a.range, a.vis_flags, a.vis_bans)

                            if not targets then
                                break
                            end

                            if #targets > 1 then
                                targets = table.filter(targets, function(k, v)
                                    return v ~= last_target
                                end)
                            end

                            local target = table.random(targets)

                            last_target = target

                            local animation, animation_idx = table.random(a.hit_animations)
                            local hit_time = a.hit_times[animation_idx]
                            local hit_pos = U.melee_slot_position(this, target, 1)
                            local last_ts = store.tick_ts

                            this.pos.x, this.pos.y = hit_pos.x, hit_pos.y

                            if band(target.vis.bans, F_STUN) == 0 then
                                SU.stun_inc(target)
                            end

                            local sound = (i - 1) % 3 == 0 and "HeroMonkMultihitScream" or "HeroMonkMultihitPunch"

                            S:queue(sound)

                            local an, af = U.animation_name_facing_point(this, animation, target.pos)

                            U.animation_start(this, an, af, store.tick_ts)

                            while hit_time > store.tick_ts - last_ts do
                                if SU.hero_interrupted(this) then
                                    SU.stun_dec(target)

                                    goto label_393_0
                                end

                                coroutine.yield()
                            end

                            local d = E:create_entity("damage")

                            d.source_id = this.id
                            d.target_id = target.id
                            d.value = (math.random(a.damage_min, a.damage_max) + this.damage_buff) * this.unit.damage_factor

                            queue_damage(store, d)

                            local poff = a.particle_pos[animation_idx]
                            local fx = E:create_entity("fx")

                            fx.pos.x, fx.pos.y = (af and -1 or 1) * poff.x + this.pos.x, poff.y + this.pos.y
                            fx.render.sprites[1].name = "fx_hero_monk_particle"
                            fx.render.sprites[1].ts = store.tick_ts
                            fx.render.sprites[1].sort_y_offset = -2

                            queue_insert(store, fx)

                            while not U.animation_finished(this) do
                                if SU.hero_interrupted(this) then
                                    SU.stun_dec(target)

                                    goto label_393_0
                                end

                                coroutine.yield()
                            end

                            SU.stun_dec(target)
                        end

                        ::label_393_0::

                        this.health.ignore_damage = nil
                        this.health_bar.hidden = false
                        this.pos.x, this.pos.y = start_pos.x, start_pos.y

                        U.y_animation_play(this, "leopard_end", nil, store.tick_ts, 1)
                    end

                    ::label_393_1::

                    brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                    if brk or sta ~= A_NO_TARGET then
                        -- block empty
                        if this.cooldown_factor_dec_count < 8 then
                            this.cooldown_factor = this.cooldown_factor - 0.05
                        end

                        this.cooldown_factor_dec_count = this.cooldown_factor_dec_count + 1
                    elseif SU.soldier_go_back_step(store, this) then
                        -- block empty
                    else
                        if this.cooldown_factor_dec_count > 0 then
                            if this.cooldown_factor_dec_count <= 8 then
                                this.cooldown_factor = this.cooldown_factor + 0.05
                            end
                            this.cooldown_factor_dec_count = this.cooldown_factor_dec_count - 1
                        end
                        SU.soldier_idle(store, this)
                        SU.soldier_regen(store, this)
                    end
                end

                ::label_393_2::

                coroutine.yield()
            end
        end
    }
    scripts.mod_monk_damage_reduction = {
    insert = function(this, store)
        local target = store.entities[this.modifier.target_id]
        if target and target.unit then
            target.unit.damage_factor = target.unit.damage_factor * (1 - this.reduction_factor)
        end
        return false
    end
}

    -- 女巫
    scripts.hero_voodoo_witch = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)

            local a = this.melee.attacks[1]
            a.damage_max = ls.damage_max[hl]
            a.damage_min = ls.damage_min[hl]

            local b = E:get_template("bolt_voodoo_witch")

            b.bullet.damage_max = ls.ranged_damage_max[hl]
            b.bullet.damage_min = ls.ranged_damage_min[hl]

            upgrade_skill(this, "laughingskulls", function(this, s)
                local b = E:get_template("bolt_voodoo_witch_skull")
                b.bullet.damage_min = b.bullet.damage_min + s.extra_damage[s.level]
                b.bullet.damage_max = b.bullet.damage_max + s.extra_damage[s.level]
            end)

            upgrade_skill(this, "deathskull", function(this, s)
                local sk = E:get_template("voodoo_witch_skull")
                sk.sacrifice.disabled = nil
                sk.sacrifice.damage = s.damage[s.level]
            end)

            upgrade_skill(this, "bonedance", function(this, s)
                local a = E:get_template("voodoo_witch_skull_aura")
                a.skull_count = s.skull_count[s.level]
                local sp = E:get_template("mod_voodoo_witch_skull_spawn")
                sp.skull_count = s.skull_count[s.level]
            end)

            upgrade_skill(this, "deathaura", function(this, s)
                local m = E:get_template("mod_voodoo_witch_aura_slow")
                m.slow.factor = s.slow_factor[s.level]
            end)

            upgrade_skill(this, "voodoomagic", function(this, s)
                local a = this.timed_attacks.list[1]
                a.disabled = nil
                a.damage = s.damage[s.level]
            end)

            this.health.hp = this.health.hp_max
        end
    }
    -- 螃蟹
    scripts.hero_crab = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)
            this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

            upgrade_skill(this, "battlehardened", function(this, s)
                this.invuln.disabled = nil
                this.invuln.chance = s.chance[s.level]

            end)

            upgrade_skill(this, "pincerattack", function(this, s)
                local pa = this.timed_attacks.list[1]
                pa.disabled = nil
                pa.damage_min = s.damage_min[s.level]
                pa.damage_max = s.damage_max[s.level]
            end)

            upgrade_skill(this, "shouldercannon", function(this, s)
                local a = this.ranged.attacks[1]
                a.disabled = nil
                local b = E:get_template("crab_water_bomb")
                b.bullet.damage_max = s.damage[s.level]
                b.bullet.damage_min = s.damage[s.level]
                local m = E:get_template("mod_slow_water_bomb")
                m.modifier.duration = s.slow_duration[s.level]
                m.slow.factor = s.slow_factor[s.level]
            end)

            upgrade_skill(this, "burrow", function(this, s)
                this.burrow.disabled = nil
                this.burrow.extra_speed = s.extra_speed[s.level]
                this.nav_grid.valid_terrains = bor(TERRAIN_LAND, TERRAIN_WATER, TERRAIN_SHALLOW, TERRAIN_ICE)
            end)

            upgrade_skill(this, "hookedclaw", function(this, s)
                local pa = this.timed_attacks.list[1]
                if not pa.disabled then
                    pa.damage_min = pa.damage_min + s.extra_damage[s.level]
                    pa.damage_max = pa.damage_max + s.extra_damage[s.level]
                end
                this.melee.attacks[1].damage_min = this.melee.attacks[1].damage_min + s.extra_damage[s.level]
                this.melee.attacks[1].damage_max = this.melee.attacks[1].damage_max + s.extra_damage[s.level]
            end)

            this.health.hp = this.health.hp_max
        end
    }
    -- 卡兹 - 代达罗斯
    scripts.mod_minotaur_daedalus = {
        queue = function(this, store, insertion)
            local target = store.entities[this.modifier.target_id]

            if not target then
                return
            end

            if insertion then
                target.vis._bans = target.vis.bans
                target.vis.bans = F_ALL
                target.health.ignore_damage = true

                SU.stun_inc(target)

                local s = this.render.sprites[1]
                local m = this.modifier

                if s.size_names then
                    s.prefix = s.prefix .. "_" .. s.size_names[target.unit.size]
                end

                if s.size_anchor then
                    s.anchor = s.size_anchors[target.unit.size]
                end

                if m.custom_offsets then
                    s.offset = m.custom_offsets[target.template_name] or m.custom_offsets.default
                elseif m.use_mod_offset and target.unit.mod_offset then
                    s.offset.x, s.offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
                end
            else
                SU.stun_dec(target)

                if target.vis._bans then
                    target.vis.bans = target.vis._bans
                    target.vis._bans = nil
                    target.health.ignore_damage = true
                end
            end

        end,
        update = function(this, store)
            local m = this.modifier
            local target = store.entities[m.target_id]

            if not target then
                queue_remove(store, this)

                return
            end

            local fx = E:create_entity("decal_minotaur_daedalus")

            fx.pos = V.vclone(target.pos)
            fx.render.sprites[1].ts = store.tick_ts

            queue_insert(store, fx)
            U.y_wait(store, 0.5)

            local es = E:create_entity("daedalus_enemy_decal")

            es.pos.x, es.pos.y = target.pos.x, target.pos.y
            es.render = table.deepclone(target.render)
            es.tween.ts = store.tick_ts

            queue_insert(store, es)
            coroutine.yield()
            U.sprites_hide(target)

            target.health_bar.hidden = true

            U.y_wait(store, 0.5)

            target.nav_path.pi = this.dest_pi
            target.nav_path.spi = this.dest_spi
            target.nav_path.ni = this.dest_ni

            local pos = P:node_pos(target.nav_path)

            target.pos.x, target.pos.y = pos.x, pos.y
            es.pos = V.vclone(pos)
            this.pos = V.vclone(pos)
            es.tween.reverse = true
            es.tween.ts = store.tick_ts
            fx = E:create_entity("decal_minotaur_daedalus")
            fx.pos = V.vclone(target.pos)
            fx.render.sprites[1].ts = store.tick_ts

            queue_insert(store, fx)
            U.y_wait(store, 0.5)
            queue_remove(store, es)
            U.sprites_show(target)

            target.health_bar.hidden = nil
            target.health.ignore_damage = nil

            if target.vis._bans then
                target.vis.bans = target.vis._bans
                target.vis._bans = nil
            end

            local s = this.render.sprites[1]

            s.hidden = nil
            s.flip_x = target.render.sprites[1].flip_x
            m.ts = store.tick_ts

            while store.tick_ts - m.ts < m.duration and target and not target.health.dead do
                coroutine.yield()
            end

            queue_remove(store, this)
        end
    }
    -- 卡兹
    scripts.hero_minotaur = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)

            local a = this.melee.attacks[1]
            a.damage_max = ls.damage_max[hl]
            a.damage_min = ls.damage_min[hl]

            upgrade_skill(this, "bullrush", function(this, s)
                local a = this.timed_attacks.list[3]
                a.disabled = nil
                a.damage_min = s.damage_min[s.level]
                a.damage_max = s.damage_max[s.level]
                a.run_damage_min = s.run_damage_min[s.level]
                a.run_damage_max = s.run_damage_max[s.level]
                local m = E:get_template(a.mod)
                m.modifier.duration = s.duration[s.level]
            end)

            upgrade_skill(this, "bloodaxe", function(this, s)
                local a = this.melee.attacks[2]
                a.disabled = nil
                a.damage_max = ls.damage_max[hl] * s.damage_factor[s.level]
                a.damage_min = ls.damage_min[hl] * s.damage_factor[s.level]
            end)

            upgrade_skill(this, "daedalusmaze", function(this, s)
                local a = this.timed_attacks.list[4]
                a.disabled = nil
                local m = E:get_template(a.mod)
                m.modifier.duration = s.duration[s.level]
            end)

            upgrade_skill(this, "roaroffury", function(this, s)
                local a = this.timed_attacks.list[2]
                a.disabled = nil
                local m = E:get_template(a.mod)
                m.extra_damage = s.extra_damage[s.level]
            end)

            upgrade_skill(this, "doomspin", function(this, s)
                local a = this.timed_attacks.list[1]
                a.disabled = nil
                a.damage_min = s.damage_min[s.level]
                a.damage_max = s.damage_max[s.level]
            end)

            this.health.hp = this.health.hp_max
        end,
        update = function(this, store)
            local h = this.health
            local he = this.hero
            local a, skill, brk, sta
            local ps = E:create_entity("ps_minotaur_bullrush")

            ps.particle_system.track_id = this.id
            ps.particle_system.emit = false

            queue_insert(store, ps)

            local function do_rush_damage(target, a, final_hit)
                local d = E:create_entity("damage")

                d.source_id = this.id
                d.target_id = target.id

                if final_hit then
                    d.value = (math.random(a.damage_min, a.damage_max) + this.damage_buff) * this.unit.damage_factor
                else
                    d.value = (math.random(a.run_damage_min, a.run_damage_max) + this.damage_buff) *
                                  this.unit.damage_factor
                end

                d.damage_type = a.damage_type

                queue_damage(store, d)
            end

            local function do_rush_stun(target, a)
                local m = E:create_entity(a.mod)

                m.modifier.target_id = target.id
                m.modifier.source_id = this.id

                queue_insert(store, m)
            end

            U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

            this.health_bar.hidden = false

            while true do
                if h.dead then
                    SU.y_hero_death_and_respawn(store, this)
                end

                if this.unit.is_stunned then
                    SU.soldier_idle(store, this)
                else
                    while this.nav_rally.new do
                        if SU.y_hero_new_rally(store, this) then
                            goto label_437_2
                        end
                    end

                    if SU.hero_level_up(store, this) then
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    end

                    a = this.timed_attacks.list[1]
                    skill = this.hero.skills.doomspin

                    if ready_to_use_skill(a, store) then
                        local targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range,
                            a.vis_flags, a.vis_bans)

                        if not targets or #targets < a.min_count then
                            SU.delay_attack(store, a, 0.2)
                        else
                            local target = targets[1]

                            S:queue(a.sound)

                            local an, af = U.animation_name_facing_point(this, a.animation, target.pos)

                            U.animation_start(this, an, af, store.tick_ts, false)

                            if U.y_wait(store, a.hit_time, function()
                                return SU.hero_interrupted(this)
                            end) then
                                -- block empty
                            else
                                a.ts = store.tick_ts

                                SU.hero_gain_xp_from_skill(this, skill)

                                local heal = 0
                                for _, e in pairs(targets) do
                                    local d = E:create_entity("damage")
                                    d.source_id = this.id
                                    d.target_id = e.id
                                    d.value = (math.random(a.damage_min, a.damage_max) + this.damage_buff) *
                                                  this.unit.damage_factor
                                    heal = heal + d.value * 0.25
                                    d.damage_type = a.damage_type
                                    queue_damage(store, d)
                                end

                                scripts.heal(this, heal)

                                while not U.animation_finished(this) and not SU.hero_interrupted(this) do
                                    coroutine.yield()
                                end

                                goto label_437_2
                            end
                        end
                    end

                    a = this.timed_attacks.list[2]
                    skill = this.hero.skills.roaroffury

                    if ready_to_use_skill(a, store) then
                        local towers = table.filter(store.entities, function(_, e)
                            return e.tower and e.tower.can_be_mod and not e.tower.blocked and
                                       not table.contains(a.excluded_templates, e.template_name)
                        end)

                        if #towers < 1 then
                            SU.delay_attack(store, a, 0.2)
                        else
                            S:queue(a.sound)
                            U.animation_start(this, a.animation, nil, store.tick_ts)

                            if U.y_wait(store, a.shoot_time, function()
                                return SU.hero_interrupted(this)
                            end) then
                                -- block empty
                            else
                                a.ts = store.tick_ts

                                SU.hero_gain_xp_from_skill(this, skill)

                                local fx = E:create_entity(a.shoot_fx)

                                fx.pos = V.vclone(this.pos)
                                fx.render.sprites[1].anchor = V.vclone(this.render.sprites[1].anchor)
                                fx.render.sprites[1].ts = store.tick_ts
                                fx.render.sprites[1].flip_x = this.render.sprites[1].flip_x

                                queue_insert(store, fx)

                                for _, t in pairs(towers) do
                                    local m = E:create_entity(a.mod)
                                    m.modifier.target_id = t.id
                                    queue_insert(store, m)
                                end

                                while not U.animation_finished(this) and not SU.hero_interrupted(this) do
                                    coroutine.yield()
                                end

                                fx.render.sprites[1].hidden = true

                                goto label_437_2
                            end
                        end
                    end

                    a = this.timed_attacks.list[3]
                    skill = this.hero.skills.bullrush

                    if ready_to_use_skill(a, store) then
                        local target = U.find_first_target(store.entities, this.pos, a.min_range, a.max_range,
                            a.vis_flags, a.vis_bans, function(e)
                                if not e.heading or not e.nav_path then
                                    return false
                                end

                                local dist = V.dist(e.pos.x, e.pos.y, this.pos.x, this.pos.y)
                                local ftime = dist / (this.motion.max_speed * a.speed_factor)
                                local pni = e.nav_path.ni + P:predict_enemy_node_advance(e, ftime)
                                local ppos = P:predict_enemy_pos(e, ftime)
                                local slot_pos = U.melee_slot_position(this, e, 1)

                                return P:nodes_to_goal(e.nav_path) > a.nodes_limit and
                                           P:is_node_valid(e.nav_path.pi, e.nav_path.ni) and
                                           P:is_node_valid(e.nav_path.pi, pni) and
                                           GR:cell_is_only(slot_pos.x, slot_pos.y, this.nav_grid.valid_terrains_dest) and
                                           GR:cell_is_only(ppos.x, ppos.y, this.nav_grid.valid_terrains_dest) and
                                           GR:find_line_waypoints(this.pos, ppos, this.nav_grid.valid_terrains) ~= nil
                            end)

                        if not target then
                            SU.delay_attack(store, a, 0.2)

                            goto label_437_0
                        end

                        local damaged_enemies = {}

                        U.unblock_target(store, this)

                        this.health_bar.hidden = true
                        this.health.ignore_damage = true

                        local vis_bans = this.vis.bans

                        this.vis.bans = F_ALL
                        this.motion.max_speed = this.motion.max_speed * a.speed_factor

                        local an, af = U.animation_name_facing_point(this, a.animations[1], target.pos)

                        U.y_animation_play(this, an, af, store.tick_ts, 1)

                        ps.particle_system.emit = true

                        local dust = E:create_entity("mod_minotaur_dust")

                        dust.modifier.target_id = this.id

                        queue_insert(store, dust)

                        local interrupted = false

                        S:queue(a.sound)
                        U.animation_start(this, a.animations[2], nil, store.tick_ts, true)

                        local slot_pos, slot_flip = U.melee_slot_position(this, target, 1)

                        U.set_destination(this, slot_pos)

                        while not U.walk(this, store.tick_length) do
                            local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.stun_range,
                                a.stun_vis_flags, a.stun_vis_bans, function(v)
                                    return not table.contains(damaged_enemies, v)
                                end)

                            if targets then
                                for _, t in pairs(targets) do
                                    table.insert(damaged_enemies, t)
                                    do_rush_damage(t, a, false)
                                    do_rush_stun(t, a)
                                end
                            end

                            coroutine.yield()

                            slot_pos = U.melee_slot_position(this, target, 1)

                            if not GR:cell_is_only(slot_pos.x, slot_pos.y, this.nav_grid.valid_terrains_dest) or
                                not P:is_node_valid(target.nav_path.pi, target.nav_path.ni) then
                                log.debug("bullrush interrupted")

                                interrupted = true

                                break
                            end

                            U.set_destination(this, slot_pos)
                        end

                        this.nav_rally.center = V.vclone(this.pos)
                        this.nav_rally.pos = V.vclone(this.pos)

                        queue_remove(store, dust)

                        ps.particle_system.emit = false
                        an, af = U.animation_name_facing_point(this, a.animations[3], target.pos)

                        U.animation_start(this, an, af, store.tick_ts, false)
                        U.y_wait(store, fts(5))

                        if not interrupted then
                            do_rush_damage(target, a, true)

                            if target.health and not target.health.dead and band(target.vis.flags, a.stun_vis_bans) == 0 and
                                band(target.vis.bans, a.stun_vis_flags) == 0 then
                                do_rush_stun(target, a)
                            end
                        end

                        this.health_bar.hidden = nil
                        this.health.ignore_damage = false
                        this.vis.bans = vis_bans
                        this.motion.max_speed = this.motion.max_speed / a.speed_factor
                        a.ts = store.tick_ts
                        this.timed_attacks.list[1].ts = 0

                        SU.hero_gain_xp_from_skill(this, skill)
                        U.y_animation_wait(this)

                        goto label_437_2
                    end

                    ::label_437_0::

                    a = this.timed_attacks.list[4]
                    skill = this.hero.skills.daedalusmaze

                    if ready_to_use_skill(a, store) then
                        local nearest_nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, {1, 2, 3}, true, NF_NO_EXIT)

                        if #nearest_nodes < 1 then
                            SU.delay_attack(store, a, 0.2)

                            goto label_437_1
                        end

                        local pi, spi, ni = unpack(nearest_nodes[1])

                        ni = ni + a.node_offset

                        local n_pos = P:node_pos(pi, spi, ni)

                        if not U.is_inside_ellipse(this.pos, n_pos, this.melee.range) or not P:is_node_valid(pi, ni) or
                            P:nodes_to_defend_point(pi, spi, ni) < a.nodes_limit or
                            band(GR:cell_type(n_pos.x, n_pos.y), a.invalid_terrains) ~= 0 then
                            SU.delay_attack(store, a, 0.2)

                            goto label_437_1
                        end

                        local terrains = P:path_terrain_types(pi)

                        terrains = band(terrains, bnot(TERRAIN_CLIFF, TERRAIN_FAERIE))

                        local target = U.find_foremost_enemy(store.entities, this.pos, a.min_range, a.max_range, false,
                            a.vis_flags, a.vis_bans, function(v)
                                return (band(bnot(v.enemy.valid_terrains), terrains) == 0) and v.health.hp > 540
                            end)

                        if not target then
                            SU.delay_attack(store, a, 0.2)

                            goto label_437_1
                        end

                        SU.remove_modifiers(store, target)

                        local m = E:create_entity(a.mod)

                        m.modifier.target_id = target.id
                        m.modifier.source_id = this.id
                        m.dest_pi = pi
                        m.dest_spi = spi
                        m.dest_ni = ni

                        queue_insert(store, m)
                        S:queue(a.sound)

                        local an, af = U.animation_name_facing_point(this, a.animation, target.pos)

                        U.y_animation_play(this, an, af, store.tick_ts, 1)

                        a.ts = store.tick_ts
                        this.timed_attacks.list[1].ts = 0
                        this.timed_attacks.list[2].ts = 0

                        SU.hero_gain_xp_from_skill(this, skill)

                        goto label_437_2
                    end

                    ::label_437_1::

                    brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                    if brk or sta ~= A_NO_TARGET then
                        -- block empty
                    elseif SU.soldier_go_back_step(store, this) then
                        -- block empty
                    else
                        SU.soldier_idle(store, this)
                        SU.soldier_regen(store, this)
                    end
                end

                ::label_437_2::

                coroutine.yield()
            end

        end

    }
    -- 猴神
    scripts.hero_monkey_god = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)

            local a = this.melee.attacks[1]

            a.damage_max = ls.damage_max[hl]
            a.damage_min = ls.damage_min[hl]
            a = this.melee.attacks[2]
            a.damage_max = ls.damage_max[hl]
            a.damage_min = ls.damage_min[hl]

            upgrade_skill(this, "spinningpole", function(this, s)
                local a = this.melee.attacks[3]

                a.disabled = nil
                a.damage_min = s.damage[s.level]
                a.damage_max = s.damage[s.level]
                a.loops = s.loops[s.level]
            end)

            upgrade_skill(this, "tetsubostorm", function(this, s)
                local a = this.melee.attacks[4]

                a.disabled = nil
                a.damage_min = s.damage[s.level]
                a.damage_max = s.damage[s.level]
            end)

            upgrade_skill(this, "monkeypalm", function(this, s)
                local a = this.melee.attacks[5]
                a.disabled = nil
                local m = E:get_template(a.mod)
                m.modifier.duration = s.silence_duration[s.level]
                m.stun_duration = s.stun_duration[s.level]
            end)

            upgrade_skill(this, "angrygod", function(this, s)
                a = this.timed_attacks.list[1]
                a.disabled = nil

                local m = E:get_template(a.mod)

                m.received_damage_factor = s.received_damage_factor[s.level]
            end)

            this.health.hp = this.health.hp_max
        end,
        insert = function(this, store)
            this.hero.fn_level_up(this, store)
            this.melee.order = U.attack_order(this.melee.attacks)
            local e = E:create_entity("aura_monkey_god_divinenature")
            e.aura.source_id = this.id
            e.aura.ts = store.tick_ts
            queue_insert(store, e)
            return true
        end,
        can_spinningpole = function(this, store, attack, target)
            local targets = U.find_enemies_in_range(store.entities, this.pos, 0, attack.damage_radius, attack.vis_flags,
                attack.vis_bans)
            return targets and #targets >= attack.min_count
        end,
        update = function(this, store)
            local h = this.health
            local he = this.hero
            local a, skill, brk, sta
            local cloud_trail = E:create_entity("ps_monkey_god_trail")

            cloud_trail.particle_system.track_id = this.id
            cloud_trail.particle_system.track_offset = V.v(0, 50)
            cloud_trail.particle_system.emit = false
            cloud_trail.particle_system.z = Z_OBJECTS

            queue_insert(store, cloud_trail)
            U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

            this.health_bar.hidden = false

            while true do
                if h.dead then
                    SU.y_hero_death_and_respawn(store, this)
                end

                if this.unit.is_stunned then
                    SU.soldier_idle(store, this)
                else
                    while this.nav_rally.new do
                        local r = this.nav_rally
                        local cw = this.cloudwalk
                        local force_cloudwalk = false

                        for _, p in pairs(this.nav_grid.waypoints) do
                            if GR:cell_is(p.x, p.y, bor(TERRAIN_WATER, TERRAIN_SHALLOW, TERRAIN_NOWALK)) then
                                force_cloudwalk = true

                                break
                            end
                        end

                        if force_cloudwalk or V.dist(this.pos.x, this.pos.y, r.pos.x, r.pos.y) > cw.min_distance then
                            r.new = false

                            U.unblock_target(store, this)

                            local vis_bans = this.vis.bans

                            this.vis.bans = F_ALL
                            this.health.immune_to = F_ALL

                            local original_speed = this.motion.max_speed

                            this.motion.max_speed = this.motion.max_speed + cw.extra_speed
                            this.unit.marker_hidden = true
                            this.health_bar.hidden = true

                            S:queue(this.sound_events.change_rally_point)
                            S:queue(this.sound_events.cloud_start)
                            SU.hide_modifiers(store, this, true)
                            U.y_animation_play(this, cw.animations[1], r.pos.x < this.pos.x, store.tick_ts)
                            SU.show_modifiers(store, this, true)
                            S:queue(this.sound_events.cloud_loop)

                            cloud_trail.particle_system.emit = true
                            this.render.sprites[2].hidden = nil
                            this.render.sprites[1].z = Z_BULLETS

                            local ho = this.unit.hit_offset
                            local mo = this.unit.mod_offset

                            this.unit.hit_offset = cw.hit_offset
                            this.unit.mod_offset = cw.mod_offset

                            ::label_452_0::

                            local dest = r.pos
                            local n = this.nav_grid

                            while not V.veq(this.pos, dest) do
                                local w = table.remove(n.waypoints, 1) or dest

                                U.set_destination(this, w)

                                local an, af = U.animation_name_facing_point(this, cw.animations[2], this.motion.dest)

                                U.animation_start(this, an, af, store.tick_ts, true)

                                while not this.motion.arrived do
                                    if r.new then
                                        r.new = false

                                        goto label_452_0
                                    end

                                    U.walk(this, store.tick_length)
                                    coroutine.yield()

                                    this.motion.speed.x, this.motion.speed.y = 0, 0
                                end
                            end

                            cloud_trail.particle_system.emit = false

                            S:stop(this.sound_events.cloud_loop)
                            S:queue(this.sound_events.cloud_end, this.sound_events.cloud_end_args)
                            SU.hide_modifiers(store, this, true)
                            U.y_animation_play(this, cw.animations[3], nil, store.tick_ts)
                            SU.show_modifiers(store, this, true)

                            this.render.sprites[1].z = Z_OBJECTS
                            this.render.sprites[2].hidden = true
                            this.motion.max_speed = original_speed
                            this.vis.bans = vis_bans
                            this.health.immune_to = 0
                            this.unit.marker_hidden = nil
                            this.health_bar.hidden = nil
                            this.unit.hit_offset = ho
                            this.unit.mod_offset = mo
                        elseif SU.y_hero_new_rally(store, this) then
                            goto label_452_2
                        end
                    end

                    if SU.hero_level_up(store, this) then
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    end

                    a = this.timed_attacks.list[1]
                    skill = this.hero.skills.angrygod

                    if ready_to_use_skill(a, store) then
                        local targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range,
                            a.vis_flags, a.vis_bans)

                        if not targets or #targets < a.min_count then
                            SU.delay_attack(store, a, 0.2)
                        else
                            S:queue(a.sound_start)
                            U.y_animation_play(this, a.animations[1], nil, store.tick_ts, 1)

                            local loop_ts = store.tick_ts

                            a.ts = store.tick_ts
                            this.melee.attacks[3].ts = 0
                            this.melee.attacks[4].ts = 0
                            this.melee.attacks[5].ts = 0
                            SU.hero_gain_xp_from_skill(this, skill)
                            S:queue(a.sound_loop)
                            this.health.immune_to = F_ALL
                            for i = 1, a.loops do
                                U.animation_start(this, a.animations[2], nil, store.tick_ts, false)

                                local targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range,
                                    a.max_range, a.vis_flags, a.vis_bans)

                                if targets then
                                    for _, target in pairs(targets) do
                                        local m = E:create_entity(a.mod)

                                        m.modifier.target_id = target.id
                                        m.modifier.source_id = this.id
                                        m.render.sprites[1].ts = store.tick_ts

                                        queue_insert(store, m)

                                        local m = E:create_entity("mod_monkey_god_fire")
                                        m.modifier.target_id = target.id
                                        m.modifier.source_id = this.id
                                        m.modifier.level = skill.level
                                        queue_insert(store, m)
                                    end
                                end

                                while not U.animation_finished(this) do
                                    if SU.hero_interrupted(this) then
                                        a.ts = a.ts - a.cooldown * (a.loops - i)/a.loops
                                        goto label_452_1
                                    end

                                    coroutine.yield()
                                end
                            end

                            ::label_452_1::
                            this.health.immune_to = 0
                            S:stop(a.sound_loop)
                            U.y_animation_play(this, a.animations[3], nil, store.tick_ts, 1)

                            goto label_452_2
                        end
                    end

                    brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                    if brk or sta ~= A_NO_TARGET then
                        -- block empty
                    elseif SU.soldier_go_back_step(store, this) then
                        -- block empty
                    else
                        SU.soldier_idle(store, this)
                        SU.soldier_regen(store, this)
                    end
                end

                ::label_452_2::

                coroutine.yield()
            end
        end
    }
    -- 猴神 - 猴掌
    scripts.mod_monkey_god_palm = {
        insert = function(this, store)
            local m = this.modifier
            local target = store.entities[m.target_id]

            if target and not target.health.dead then
                local sm = E:create_entity(this.stun_mod)

                sm.modifier.target_id = target.id
                sm.modifier.source_id = this.id
                sm.modifier.duration = this.stun_duration

                queue_insert(store, sm)

                scripts.cast_silence(target)

                local s = this.render.sprites[1]

                s.ts = store.tick_ts

                if target.unit and target.unit.mod_offset then
                    s.offset.x = target.unit.mod_offset.x
                    s.offset.y = target.unit.mod_offset.y
                end

                local s_offset = this.custom_offsets[target.template_name] or this.custom_offsets.default

                if s_offset then
                    s.offset.x = s.offset.x + s_offset.x
                    s.offset.y = s.offset.y + s_offset.y
                end

                s.offset.x = (target.render.sprites[1].flip_x and -1 or 1) * s.offset.x

                signal.emit("mod-applied", this, target)

                return true
                -- end
            end

            return false
        end,
        remove = scripts.mod_silence.remove
    }
    -- 艾利丹
    scripts.hero_elves_archer = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)

            this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

            local bt = E:get_template(this.ranged.attacks[1].bullet)

            bt.bullet.damage_min = ls.ranged_damage_min[hl]
            bt.bullet.damage_max = ls.ranged_damage_max[hl]

            upgrade_skill(this, "multishot", function(this, s)
                local a = this.ranged.attacks[2]
                a.disabled = nil
                a.max_loops = s.loops[s.level]
            end)

            upgrade_skill(this, "porcupine", function(this, s)
                bt.bullet.damage_inc = s.damage_inc[s.level]
            end)

            upgrade_skill(this, "nimble_fencer", function(this, s)
                this.dodge.disabled = nil
                this.dodge.chance = s.chance[s.level]
            end)

            upgrade_skill(this, "double_strike", function(this, s)
                local a = this.melee.attacks[2]
                a.disabled = nil
                a.damage_min = s.damage_min[s.level]
                a.damage_max = s.damage_max[s.level]
            end)

            upgrade_skill(this, "ultimate", function(this, s)
                this.ultimate.disabled = nil
            end)

            this.health.hp = this.health.hp_max
        end,
        insert = function(this, store)
            this.hero.fn_level_up(this, store)

            this.melee.order = U.attack_order(this.melee.attacks)
            this.ranged.order = U.attack_order(this.ranged.attacks)

            local a = E:create_entity("aura_elves_archer_regen")

            a.aura.source_id = this.id
            a.aura.ts = store.tick_ts
            a.pos = this.pos

            queue_insert(store, a)

            return true
        end,
        update = function(this, store)
            local h = this.health
            local he = this.hero
            local brk, sta, a, skill
            local is_sword = false
            local porcupine_target, porcupine_level = nil, 0

            local function update_porcupine(attack, target)
                if porcupine_target == target then
                    porcupine_level = math.min(porcupine_level + 1, 3)
                    attack.level = porcupine_level
                else
                    porcupine_level = 0
                    attack.level = 0
                end

                porcupine_target = target
            end

            U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

            this.health_bar.hidden = false

            while true do
                this.regen.is_idle = nil

                if h.dead then
                    SU.y_hero_death_and_respawn(store, this)
                end

                if this.unit.is_stunned then
                    SU.soldier_idle(store, this)
                else
                    if this.dodge and this.dodge.active then
                        this.dodge.active = false
                        this.dodge.counter_attack_pending = true
                    end

                    while this.nav_rally.new do
                        if SU.y_hero_new_rally(store, this) then
                            goto label_79_4
                        end
                    end

                    if SU.hero_level_up(store, this) then
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    end

                    if ready_to_use_skill(this.ultimate, store) then
                        local enemy =
                            find_target_at_critical_moment(this, store, this.ranged.attacks[1].max_range, true)
                        if enemy and enemy.pos then
                            U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                            S:queue(this.sound_events.change_rally_point)
                            local ultimate_entity = E:create_entity(this.hero.skills.ultimate.controller_name)
                            ultimate_entity.damage_factor = this.unit.damage_factor
                            ultimate_entity.pos = V.vclone(enemy.pos)
                            ultimate_entity.level = this.hero.skills.ultimate.level
                            queue_insert(store, ultimate_entity)
                            this.ultimate.ts = store.tick_ts
                            SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
                        else
                            this.ultimate.ts = this.ultimate.ts + 1
                        end
                    end
                    -- 近战状态
                    local target = SU.soldier_pick_melee_target(store, this)

                    if not target then
                        -- block empty
                    else
                        if is_sword then
                            local slot_pos = U.melee_slot_position(this, target)

                            if slot_pos and not V.veq(slot_pos, this.pos) then
                                U.y_animation_play(this, "sword2bow", nil, store.tick_ts)

                                is_sword = false
                            end
                        end

                        if SU.soldier_move_to_slot_step(store, this, target) then
                            goto label_79_4
                        end

                        local attack = SU.soldier_pick_melee_attack(store, this, target)

                        if not attack then
                            goto label_79_4
                        end

                        if not is_sword then
                            U.y_animation_play(this, "bow2sword", nil, store.tick_ts)

                            is_sword = true
                        end

                        if attack.xp_from_skill then
                            SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
                        end

                        local attack_done = SU.y_soldier_do_single_melee_attack(store, this, target, attack)

                        U.animation_start(this, "idle_sword", nil, store.tick_ts, true)

                        goto label_79_4
                    end

                    if is_sword then
                        U.y_animation_play(this, "sword2bow", nil, store.tick_ts)

                        is_sword = false
                    end

                    if this.ranged then
                        local target, attack, pred_pos = SU.soldier_pick_ranged_target_and_attack(store, this)

                        if not target then
                            goto label_79_3
                        end

                        this.regen.is_idle = true

                        if not attack then
                            goto label_79_3
                        end

                        U.set_destination(this, this.pos)

                        local attack_done
                        local start_ts = store.tick_ts

                        if attack.max_loops then
                            local an, af, ai = U.animation_name_facing_point(this, attack.animations[1], target.pos)

                            U.y_animation_play(this, an, af, store.tick_ts, 1)

                            local retarget_flag
                            local loops, loops_done = attack.max_loops, 0
                            local pred_shots
                            local b = E:create_entity(attack.bullet)
                            local d = SU.create_bullet_damage(b.bullet)

                            ::label_79_0::

                            if retarget_flag then
                                retarget_flag = nil

                                local n_target, _, n_pred_pos =
                                    U.find_foremost_enemy(store.entities, this.pos, attack.min_range, attack.max_range,
                                        attack.node_prediction, attack.vis_flags, attack.vis_bans, function(v)
                                            return v ~= target
                                        end, F_FLYING)

                                if n_target then
                                    target = n_target
                                    pred_pos = n_pred_pos
                                else
                                    goto label_79_1
                                end
                            end

                            update_porcupine(attack, target)

                            d.value = math.ceil((b.bullet.damage_min + b.bullet.damage_max + 2 * attack.level *
                                                    (b.bullet.damage_inc or 0)) / 2)
                            pred_shots = math.ceil(target.health.hp / U.predict_damage(target, d))

                            log.paranoid("+++ pred_shots:%s d.value:%s target.hp:%s", pred_shots, d.value,
                                target.health.hp)

                            loops = math.min(attack.max_loops - loops_done, pred_shots)

                            for i = 1, loops do
                                an, af, ai = U.animation_name_facing_point(this, attack.animations[2], target.pos)

                                U.animation_start(this, an, af, store.tick_ts, false)

                                while store.tick_ts - this.render.sprites[1].ts < attack.shoot_times[1] do
                                    if SU.hero_interrupted(this) then
                                        goto label_79_2
                                    end

                                    coroutine.yield()
                                end

                                local b = E:create_entity(attack.bullet)

                                b.pos = V.vclone(this.pos)

                                if attack.bullet_start_offset then
                                    local offset = attack.bullet_start_offset[1]

                                    b.pos.x, b.pos.y = b.pos.x + (af and -1 or 1) * offset.x, b.pos.y + offset.y
                                end

                                b.bullet.from = V.vclone(b.pos)
                                b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x,
                                    target.pos.y + target.unit.hit_offset.y)
                                b.bullet.target_id = target.id
                                b.bullet.source_id = this.id
                                b.bullet.xp_dest_id = this.id
                                b.bullet.level = attack.level
                                b.bullet.damage_factor = this.unit.damage_factor

                                queue_insert(store, b)

                                if attack.xp_from_skill then
                                    SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
                                end

                                attack_done = true
                                loops_done = loops_done + 1

                                while not U.animation_finished(this) do
                                    if SU.hero_interrupted(this) then
                                        goto label_79_2
                                    end

                                    coroutine.yield()
                                end

                                if target.health.dead or band(F_RANGED, target.vis.bans) ~= 0 then
                                    retarget_flag = true

                                    goto label_79_0
                                end

                                update_porcupine(attack, target)
                            end

                            if loops_done < attack.max_loops then
                                retarget_flag = true

                                goto label_79_0
                            end

                            ::label_79_1::

                            an, af, ai = U.animation_name_facing_point(this, attack.animations[3], target.pos)

                            U.animation_start(this, an, af, store.tick_ts, 1)

                            while not U.animation_finished(this) do
                                if SU.hero_interrupted(this) then
                                    break
                                end

                                coroutine.yield()
                            end
                        else
                            update_porcupine(attack, target)

                            attack_done = SU.y_soldier_do_ranged_attack(store, this, target, attack, pred_pos)
                        end

                        ::label_79_2::

                        if attack_done then
                            attack.ts = start_ts
                        end

                        goto label_79_4
                    end

                    ::label_79_3::

                    if SU.soldier_go_back_step(store, this) then
                        -- block empty
                    else
                        SU.soldier_idle(store, this)

                        this.regen.is_idle = true
                    end
                end

                ::label_79_4::

                coroutine.yield()
            end

        end
    }
    -- 艾利丹 - 大招
    scripts.hero_elves_archer_ultimate = {
        update = function(this, store)
            local function spawn_arrow(pi, spi, ni)
                spi = spi or math.random(1, 3)

                local pos = P:node_pos(pi, spi, ni)

                pos.x = pos.x + math.random(-4, 4)
                pos.y = pos.y + math.random(-5, 5)

                local b = E:create_entity(this.bullet)

                b.bullet.damage_max = this.damage[this.level]
                b.bullet.damage_min = this.damage[this.level]
                b.bullet.from = V.v(pos.x + math.random(-170, -140), pos.y + REF_H)
                b.bullet.to = pos
                b.bullet.damage_factor = this.damage_factor
                b.pos = V.vclone(b.bullet.from)

                queue_insert(store, b)
            end

            local nearest = P:nearest_nodes(this.pos.x, this.pos.y)

            if #nearest > 0 then
                local pi, spi, ni = unpack(nearest[1])

                spawn_arrow(pi, spi, ni)

                local count = this.spread[this.level]
                local sequence = {}

                for i = 1, count do
                    sequence[i] = i
                end

                while #sequence > 0 do
                    local i = table.remove(sequence, math.random(1, #sequence))
                    local delay = U.frandom(0, 1 / count)

                    U.y_wait(store, delay / 2)

                    if P:is_node_valid(pi, ni + i) then
                        spawn_arrow(pi, nil, ni + i)
                    else
                        spawn_arrow(pi, nil, ni - i)
                    end

                    U.y_wait(store, delay / 2)

                    if P:is_node_valid(pi, ni - i) then
                        spawn_arrow(pi, nil, ni - i)
                    else
                        spawn_arrow(pi, nil, ni + i)
                    end
                end
            end

            queue_remove(store, this)
        end
    }

    -- 艾利丹 - 大招箭矢
    scripts.arrow_hero_elves_archer_ultimate = {
        update = function(this, store)
            local b = this.bullet
            local speed = b.max_speed

            while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) >= 2 * (speed * store.tick_length) do
                b.speed.x, b.speed.y = V.mul(speed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
                this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length,
                    this.pos.y + b.speed.y * store.tick_length
                this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

                coroutine.yield()
            end

            local targets = U.find_targets_in_range(store.entities, b.to, 0, b.damage_radius, b.damage_flags,
                b.damage_bans)

            if targets then
                for _, target in pairs(targets) do
                    local d = E:create_entity("damage")

                    d.damage_type = b.damage_type
                    d.value = b.damage_max * b.damage_factor
                    d.source_id = this.id
                    d.target_id = target.id

                    queue_damage(store, d)

                    if b.mod then
                        local mod = E:create_entity(b.mod)

                        mod.modifier.target_id = target.id

                        queue_insert(store, mod)
                    end
                end
            end

            if b.hit_fx then
                SU.insert_sprite(store, b.hit_fx, this.pos)
            end

            if b.arrive_decal then
                local decal = E:create_entity(b.arrive_decal)

                decal.pos = V.vclone(b.to)
                decal.render.sprites[1].ts = store.tick_ts

                queue_insert(store, decal)
            end

            queue_remove(store, this)

        end
    }

    -- 艾利丹 - 大招箭矢 - 特效
    scripts.decal_hero_elves_archer_ultimate = {
        insert = function(this, store)
            this.render.sprites[1].ts = store.tick_ts
            this.render.sprites[1].r = U.frandom(-10, 5) * math.pi / 180
            this.render.sprites[2].ts = store.tick_ts
            return true
        end
    }
    -- 雷格森
    scripts.hero_regson = {
        level_up = function(this, store)
            local hl, ls = level_up_basic(this)

            for i = 1, 3 do
                this.melee.attacks[i].damage_min = ls.melee_damage_min[hl]
                this.melee.attacks[i].damage_max = ls.melee_damage_max[hl]
            end

            upgrade_skill(this, "blade", function(this, s)
                this.melee.attacks[4].damage_max = s.damage[s.level] / 2
                this.melee.attacks[4].damage_min = s.damage[s.level] / 2
                this.melee.attacks[5].chance = s.instakill_chance[s.level]
                this.melee.attacks[5].damage_max = s.damage[s.level] / 2
                this.melee.attacks[5].damage_min = s.damage[s.level] / 2
            end)

            upgrade_skill(this, "heal", function(this, s)
                local hb = E:get_template("decal_regson_heal_ball")
                hb.hp_factor = s.heal_factor[s.level]
            end)

            upgrade_skill(this, "path", function(this, s)
                this.path_extra = s.extra_hp[s.level]
            end)

            upgrade_skill(this, "slash", function(this, s)
                local a = this.melee.attacks[6]

                a.disabled = nil
                a.count = s.targets[s.level]
                local m = E:get_template(a.mod)

                m.damage_max = s.damage_max[s.level]
                m.damage_min = s.damage_min[s.level]
            end)
            upgrade_skill(this, "ultimate", function(this, s)
                this.ultimate.disabled = nil
                this.ultimate.cooldown = s.cooldown[s.level]
                local u = E:get_template("hero_regson_ultimate")
                u.damage_boss = s.damage_boss[s.level]
            end)

            this.health.hp_max = this.health.hp_max + this.path_extra
            update_regen(this)
            this.health.hp = this.health.hp_max
        end,
        insert = function(this, store)
            this.hero.fn_level_up(this, store)

            this.melee.order = U.attack_order(this.melee.attacks)

            local a = E:create_entity("aura_regson_blade")

            a.aura.source_id = this.id
            a.aura.ts = store.tick_ts
            a.pos = this.pos

            queue_insert(store, a)

            local a = E:create_entity("aura_regson_heal")

            a.aura.source_id = this.id
            a.aura.ts = store.tick_ts
            a.pos = this.pos

            queue_insert(store, a)

            return true

        end,
        update = function(this, store)
            local h = this.health
            local he = this.hero
            local a, skill, brk, sta

            U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

            this.health_bar.hidden = false

            while true do
                if h.dead then
                    SU.y_hero_death_and_respawn(store, this)
                end

                if this.unit.is_stunned then
                    SU.soldier_idle(store, this)
                else
                    while this.nav_rally.new do
                        if SU.y_hero_new_rally(store, this) then
                            goto label_98_0
                        end
                    end

                    if SU.hero_level_up(store, this) then
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    end

                    if ready_to_use_skill(this.ultimate, store) then
                        local enemy = U.find_biggest_enemy(store.entities, this.pos, 0, 200, 0, F_RANGED, 0)
                        if enemy and enemy.pos then
                            U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                            S:queue(this.sound_events.change_rally_point)
                            local ultimate_entity = E:create_entity(this.hero.skills.ultimate.controller_name)
                            ultimate_entity.level = this.hero.skills.ultimate.level
                            ultimate_entity.damage_factor = this.unit.damage_factor
                            ultimate_entity.pos = V.vclone(enemy.pos)
                            queue_insert(store, ultimate_entity)
                            this.ultimate.ts = store.tick_ts
                            SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
                        else
                            this.ultimate.ts = this.ultimate.ts + 1
                        end
                    end
                    if this.blade_pending then
                        this.blade_pending = nil
                        S:queue("ElvesHeroEldritchBladeCharge")
                        U.y_animation_play(this, "goBerserk", nil, store.tick_ts, 1)
                    end

                    brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                    if brk or sta ~= A_NO_TARGET then
                        -- block empty
                    elseif SU.soldier_go_back_step(store, this) then
                        -- block empty
                    else
                        SU.soldier_idle(store, this)
                        SU.soldier_regen(store, this)
                    end
                end

                ::label_98_0::

                coroutine.yield()
            end
        end
    }

    scripts.aura_regson_blade = {}

    function scripts.aura_regson_blade.update(this, store)
        local hero = store.entities[this.aura.source_id]

        if not hero then
            log.error("hero not found for aura_regson_blade")
            queue_remove(store, this)

            return
        end

        this.blade_ts = store.tick_ts

        while true do
            if this.blade_active and store.tick_ts - this.blade_active_ts > this.blade_duration then
                this.blade_active = false
                this.blade_ts = store.tick_ts

                for i = 1, 3 do
                    hero.melee.attacks[i].disabled = nil
                end

                hero.melee.attacks[6].disabled = hero.hero.skills.slash.level < 1

                for i = 4, 5 do
                    hero.melee.attacks[i].disabled = true
                end

                hero.idle_flip.animations[1] = "idle"
                hero.render.sprites[1].angles.walk[1] = "run"
            elseif not this.blade_active and U.is_blocked_valid(store, hero) and store.tick_ts - this.blade_ts >
                this.blade_cooldown then
                hero.blade_pending = true
                this.blade_active = true
                this.blade_active_ts = store.tick_ts

                for i = 1, 3 do
                    hero.melee.attacks[i].disabled = true
                end

                hero.melee.attacks[6].disabled = true

                for i = 4, 5 do
                    hero.melee.attacks[i].disabled = nil
                end

                hero.idle_flip.animations[1] = "berserk_idle"
                hero.render.sprites[1].angles.walk[1] = "berserk_run"
            end

            coroutine.yield()
        end
    end

    scripts.aura_regson_heal = {}

    function scripts.aura_regson_heal.update(this, store)
        local a = this.aura
        local hero = store.entities[a.source_id]
        local last_ts = store.tick_ts

        if not hero then
            log.error("hero not found for aura_regson_heal")
            queue_remove(store, this)

            return
        end

        while true do
            if not hero.health.dead and store.tick_ts - last_ts >= a.cycle_time then
                last_ts = store.tick_ts

                local targets = U.find_enemies_in_range(store.entities, hero.pos, 0, a.radius, a.vis_flags, a.vis_bans)

                if targets then
                    for _, target in pairs(targets) do
                        local m = E:create_entity("mod_regson_heal")

                        m.modifier.source_id = hero.id
                        m.modifier.target_id = target.id

                        queue_insert(store, m)
                    end
                end
            end

            coroutine.yield()
        end
    end

    scripts.mod_regson_heal = {}

    function scripts.mod_regson_heal.update(this, store)
        this.modifier.ts = store.tick_ts

        while true do
            local target = store.entities[this.modifier.target_id]

            if not target or store.tick_ts - this.modifier.ts > this.modifier.duration then
                break
            end

            if target.health.dead and not U.flag_has(target.health.last_damage_types, DAMAGE_NO_LIFESTEAL) then
                local s = E:create_entity("decal_regson_heal_ball")

                s.target_id = this.modifier.source_id
                s.source_id = target.id
                s.source_hp = target.health.hp_max

                queue_insert(store, s)

                break
            end

            coroutine.yield()
        end

        queue_remove(store, this)
    end

    scripts.decal_regson_heal_ball = {}

    function scripts.decal_regson_heal_ball.update(this, store)
        local sp = this.render.sprites[1]
        local fm = this.force_motion
        local source = store.entities[this.source_id]
        local hero = store.entities[this.target_id]
        local initial_pos, initial_dest
        local initial_h = 0
        local dest_h = hero.unit.hit_offset.y
        local max_dist
        local last_pos = V.v(0, 0)

        local function move_step(dest)
            local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
            local dist = V.len(dx, dy)

            max_dist = math.max(dist, max_dist)

            local phase = km.clamp(0, 1, 1 - dist / max_dist)
            local df = (not fm.ramp_radius or dist > fm.ramp_radius) and 1 or math.max(dist / fm.ramp_radius, 0.1)

            fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(fm.max_a, V.mul(fm.a_step * df, dx, dy)))
            fm.v.x, fm.v.y = V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y))
            fm.v.x, fm.v.y = V.trim(fm.max_v, fm.v.x, fm.v.y)

            local sx, sy = V.mul(store.tick_length, fm.v.x, fm.v.y)

            this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, sx, sy)
            fm.a.x, fm.a.y = V.mul(-0.05 / store.tick_length, fm.v.x, fm.v.y)
            sp.offset.y = SU.parabola_y(phase, initial_h, dest_h, fm.max_flight_height)
            sp.r = V.angleTo(this.pos.x - last_pos.x, this.pos.y + sp.offset.y - last_pos.y)
            last_pos.x, last_pos.y = this.pos.x, this.pos.y + sp.offset.y

            return dist < 2 * fm.max_v * store.tick_length
        end

        if not source or not hero then
            log.debug("source or hero entity not found for decal_regson_heal_ball")
        else
            sp.hidden = true
            this.pos.x, this.pos.y = source.pos.x, source.pos.y

            if source.unit and source.unit.hit_offset then
                initial_h = source.unit.hit_offset.y
            end

            do
                local fx = E:create_entity("fx_regson_heal_ball_spawn")

                fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
                fx.render.sprites[1].offset.y = initial_h
                fx.render.sprites[1].ts = store.tick_ts

                queue_insert(store, fx)
            end

            U.y_wait(store, fts(10))

            sp.hidden = nil
            this.dest = hero.pos
            initial_pos = V.vclone(this.pos)
            initial_dest = V.vclone(hero.pos)
            initial_h = initial_h + 18
            fm.a.x, fm.a.y = 0, 2.5
            last_pos.x, last_pos.y = this.pos.x, this.pos.y + sp.offset.y
            max_dist = V.len(initial_dest.x - initial_pos.x, initial_dest.y - initial_pos.y)

            while not hero.health.dead and not move_step(this.dest) do
                coroutine.yield()
            end

            if not hero.health.dead then
                hero.health.hp = km.clamp(0, hero.health.hp_max, hero.health.hp + this.source_hp * this.hp_factor)

                local fx = E:create_entity("fx_regson_heal")

                fx.pos = hero.pos
                fx.render.sprites[1].ts = store.tick_ts
                fx.render.sprites[1].offset = hero.unit.mod_offset

                queue_insert(store, fx)
            end
        end

        queue_remove(store, this)
    end

    scripts.mod_regson_slash = {}

    function scripts.mod_regson_slash.update(this, store)
        local m = this.modifier
        local sp = this.render.sprites[1]
        local target = store.entities[m.target_id]

        if not target or not target.pos or target.health.dead then
            queue_remove(store, this)

            return
        end

        sp.hidden = true
        m.ts = store.tick_ts
        this.pos = target.pos

        if target.unit and target.unit.mod_offset then
            sp.offset.x, sp.offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y + 5
            sp.flip_x = not target.render.sprites[1].flip_x
        end

        local delay = (m.target_idx or 0) * this.delay_per_idx

        U.y_wait(store, delay)

        sp.hidden = nil

        U.animation_start(this, this.name, nil, store.tick_ts)
        U.y_wait(store, this.hit_time)

        local d = E:create_entity("damage")

        d.source_id = this.id
        d.target_id = target.id
        d.damage_type = this.damage_type
        d.value = math.random(this.damage_min, this.damage_max)

        queue_damage(store, d)
        U.y_animation_wait(this)
        queue_remove(store, this)
    end

    scripts.hero_regson_ultimate = {}

    function scripts.hero_regson_ultimate.update(this, store)
        local is_boss
        local sp = this.render.sprites[1]
        local targets = table.filter(store.entities, function(_, e)
            return e.pos and e.ui and e.ui.can_click and e.enemy and e.vis and e.nav_path and e.health and
                       not e.health.dead and band(e.vis.flags, this.vis_bans) == 0 and band(e.vis.bans, this.vis_flags) ==
                       0 and
                       U.is_inside_ellipse(V.v(e.pos.x + e.unit.hit_offset.x, e.pos.y + e.unit.hit_offset.y),
                    V.v(this.pos.x, this.pos.y), this.range) and
                       P:is_node_valid(e.nav_path.pi, e.nav_path.ni, NF_POWER_1)
        end)

        table.sort(targets, function(e1, e2)
            return V.dist(e1.pos.x + e1.unit.hit_offset.x, e1.pos.y + e1.unit.hit_offset.y, this.pos.x, this.pos.y) <
                       V.dist(e2.pos.x + e2.unit.hit_offset.x, e2.pos.y + e2.unit.hit_offset.y, this.pos.x, this.pos.y)
        end)

        local target = targets[1]

        if not target then
            -- block empty
        else
            is_boss = band(target.vis.flags, F_BOSS) ~= 0

            if not is_boss then
                this._target_prev_bans = target.vis.bans
                target.vis.bans = F_ALL
            end

            SU.stun_inc(target)

            this.pos = target.pos
            sp.offset.x, sp.offset.y = target.unit.hit_offset.x, target.unit.hit_offset.y

            U.animation_start(this, sp.name, nil, store.tick_ts)
            U.y_wait(store, this.hit_time)

            do
                local d = E:create_entity("damage")

                d.source_id = this.id
                d.target_id = target.id

                if is_boss then
                    d.damage_type = DAMAGE_TRUE
                    d.value = this.damage_boss * this.damage_factor
                else
                    d.damage_type = bor(DAMAGE_INSTAKILL, DAMAGE_FX_NOT_EXPLODE)
                end

                queue_damage(store, d)
            end

            U.y_animation_wait(this)
            SU.stun_dec(target)

            if not is_boss then
                target.vis.bans = this._target_prev_bans
            end
        end

        queue_remove(store, this)
    end
    -- 林恩
    scripts.hero_lynn = {}

    function scripts.hero_lynn.fn_damage_melee(this, store, attack, target)
        local skill = this.hero.skills.hexfury
        local value = math.ceil(this.unit.damage_factor *
                                    (math.random(attack.damage_min, attack.damage_max + this.damage_buff)))
        local mods = {"mod_lynn_curse", "mod_lynn_despair", "mod_lynn_ultimate", "mod_lynn_weakening"}

        if skill.level > 0 and U.has_modifier_in_list(store, target, mods) then
            value = value + math.ceil(this.unit.damage_factor * skill.extra_damage)

            log.debug(" fn_damage_melee LYNN: +++ adding extra damage %s", skill.extra_damage)
        end

        return value
    end

    function scripts.hero_lynn.on_damage(this, store, damage)
        local s = this.hero.skills.charm_of_unluck
        local dodge = this.dodge

        if dodge.last_check_ts == store.tick_ts then
            log.debug(" LYNN DAMAGE NOT dodged, already checked for dodge and passed", damage.value)

            return true
        elseif s.level > 0 and math.random() < s.chance[s.level] then
            log.debug(" LYNN DAMAGE dodged", damage.value)
            SU.hero_gain_xp_from_skill(this, s)

            return false
        else
            return true
        end
    end

    function scripts.hero_lynn.level_up(this, store)
        local hl, ls = level_up_basic(this)
        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
        this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

        upgrade_skill(this, "hexfury", function(this, s)
            this.melee.attacks[1].mod = "mod_lynn_curse"
            this.melee.attacks[2].mod = "mod_lynn_curse"
            this.melee.attacks[3].mod = "mod_lynn_curse"
            this.melee.attacks[3].loops = s.loops[s.level]
            this.melee.attacks[3].disabled = nil
        end)
        upgrade_skill(this, "despair", function(this, s)
            local a = this.timed_attacks.list[1]

            a.disabled = nil
            a.max_count = s.max_count[s.level]
            this.timed_attacks.list[2].max_count = s.max_count[s.level]
            local m = E:get_template(a.mod)

            m.modifier.duration = s.duration[s.level]
            m.speed_factor = s.speed_factor[s.level]
            m.inflicted_damage_factor = s.damage_factor[s.level]

        end)

        upgrade_skill(this, "weakening", function(this, s)
            local a = this.timed_attacks.list[2]

            a.disabled = nil

            local m = E:get_template(a.mod)

            m.modifier.duration = s.duration[s.level]
            m.armor_reduction = s.armor_reduction[s.level]
            m.magic_armor_reduction = s.magic_armor_reduction[s.level]
        end)

        upgrade_skill(this, "charm_of_unluck", function(this, s)
            this.dodge.chance = s.chance[s.level]
        end)

        upgrade_skill(this, "ultimate", function(this, s)
            this.ultimate.disabled = nil
            local m = E:get_template("mod_lynn_ultimate")
            m.dps.damage_max = s.damage[s.level]
            m.dps.damage_min = s.damage[s.level]
            m.explode_damage = s.explode_damage[s.level]
            this.ultimate.curse_damage_all = s.damage[s.level] * 10
        end)

        this.health.hp = this.health.hp_max
    end

    function scripts.hero_lynn.update(this, store)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta

        this.health_bar.hidden = false

        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                if this.dodge and this.dodge.active and this.dodge.last_check_ts ~= store.tick_ts then
                    this.dodge.active = nil
                end

                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_183_0
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                if ready_to_use_skill(this.ultimate, store) then
                    local enemy = U.find_biggest_enemy(store.entities, this.pos, 0, this.timed_attacks.list[1].range, 0,
                        F_RANGED, 0, function(e, origin)
                            return e.health.hp <= this.ultimate.curse_damage_all * this.unit.damage_factor *
                                       e.health.damage_factor
                        end)
                    if enemy and enemy.pos then
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                        S:queue(this.sound_events.change_rally_point)
                        local ultimate_entity = E:create_entity(this.hero.skills.ultimate.controller_name)
                        ultimate_entity.level = this.hero.skills.ultimate.level
                        ultimate_entity.damage_factor = this.unit.damage_factor
                        ultimate_entity.pos = V.vclone(enemy.pos)
                        queue_insert(store, ultimate_entity)
                        this.ultimate.ts = store.tick_ts
                        SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
                    else
                        this.ultimate.ts = this.ultimate.ts + 1
                    end
                end
                a = this.timed_attacks.list[1]
                skill = this.hero.skills.despair

                if ready_to_use_skill(a, store) then
                    local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, a.vis_flags,
                        a.vis_bans)

                    if not targets or #targets < a.min_count then
                        SU.delay_attack(store, a, 0.13333333333333333)
                    else
                        S:queue(a.sound, a.sound_args)
                        U.animation_start(this, a.animation, nil, store.tick_ts)

                        if SU.y_hero_wait(store, this, a.hit_time) then
                            -- block empty
                        else
                            SU.hero_gain_xp_from_skill(this, skill)

                            a.ts = store.tick_ts
                            targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, a.vis_flags,
                                a.vis_bans)

                            if targets then
                                for i, target in ipairs(targets) do
                                    if i > a.max_count then
                                        break
                                    end

                                    local m = E:create_entity(a.mod)

                                    m.modifier.source_id = this.id
                                    m.modifier.target_id = target.id

                                    queue_insert(store, m)
                                end
                            end

                            SU.y_hero_animation_wait(this)
                        end

                        goto label_183_0
                    end
                end

                a = this.timed_attacks.list[2]
                skill = this.hero.skills.weakening

                if ready_to_use_skill(a, store) then
                    local blocked = U.get_blocked(store, this)

                    if not blocked or blocked.health.armor < 0.1 and blocked.health.magic_armor < 0.1 or
                        not U.is_blocked_valid(store, this) then
                        SU.delay_attack(store, a, 0.13333333333333333)
                    else
                        S:queue(a.sound, a.sound_args)
                        U.animation_start(this, a.animation, nil, store.tick_ts)

                        if SU.y_hero_wait(store, this, a.hit_time) then
                            -- block empty
                        else
                            a.ts = store.tick_ts
                            blocked = U.get_blocked(store, this)

                            if blocked and U.is_blocked_valid(store, this) then
                                SU.hero_gain_xp_from_skill(this, skill)
                                local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.range,
                                    a.vis_flags, a.vis_bans)
                                for i, target in ipairs(targets) do
                                    if i > a.max_count then
                                        break
                                    end

                                    local m = E:create_entity(a.mod)

                                    m.modifier.source_id = this.id
                                    m.modifier.target_id = target.id

                                    queue_insert(store, m)
                                end

                            end

                            SU.y_hero_animation_wait(this)
                        end

                        goto label_183_0
                    end
                end

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta ~= A_NO_TARGET then
                    -- block empty
                elseif SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end
            end

            ::label_183_0::

            coroutine.yield()
        end
    end

    scripts.hero_lynn_ultimate = {}

    function scripts.hero_lynn_ultimate.update(this, store)
        local targets = table.filter(store.entities, function(_, e)
            return e.pos and e.ui and e.ui.can_click and e.enemy and e.vis and e.nav_path and e.health and
                       not e.health.dead and band(e.vis.flags, this.vis_bans) == 0 and band(e.vis.bans, this.vis_flags) ==
                       0 and
                       U.is_inside_ellipse(V.v(e.pos.x + e.unit.hit_offset.x, e.pos.y + e.unit.hit_offset.y),
                    V.v(this.pos.x, this.pos.y), this.range) and
                       P:is_node_valid(e.nav_path.pi, e.nav_path.ni, NF_POWER_1)
        end)

        table.sort(targets, function(e1, e2)
            return V.dist(e1.pos.x + e1.unit.hit_offset.x, e1.pos.y + e1.unit.hit_offset.y, this.pos.x, this.pos.y) <
                       V.dist(e2.pos.x + e2.unit.hit_offset.x, e2.pos.y + e2.unit.hit_offset.y, this.pos.x, this.pos.y)
        end)

        local target = targets[1]

        if target then
            local m = E:create_entity(this.mod)
            m.modifier.source_id = this.id
            m.modifier.target_id = target.id
            m.modifier.damage_factor = this.damage_factor
            queue_insert(store, m)
        end

        queue_remove(store, this)
    end

    scripts.mod_lynn_ultimate = {}

    function scripts.mod_lynn_ultimate.insert(this, store, script)
        local target = store.entities[this.modifier.target_id]

        if not target or target.health.dead then
            return false
        end

        if not U.flags_pass(target.vis, this.modifier) then
            return false
        end

        this.dps.ts = store.tick_ts - this.dps.damage_every
        this.modifier.ts = store.tick_ts
        this.tween.ts = store.tick_ts
        this.pos = target.pos

        signal.emit("mod-applied", this, target)

        return true
    end

    function scripts.mod_lynn_ultimate.update(this, store, script)
        local target
        local m = this.modifier
        local dps = this.dps
        local s_top, s_over = this.render.sprites[1], this.render.sprites[3]

        while store.tick_ts - m.ts < m.duration do
            target = store.entities[m.target_id]

            if not target then
                break
            end

            if target.health.dead then
                local p

                if U.flag_has(target.vis.flags, F_FLYING) then
                    p = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
                else
                    p = V.v(target.pos.x, target.pos.y)
                end

                SU.insert_sprite(store, this.explode_fx, p)

                local targets = U.find_enemies_in_range(store.entities, target.pos, 0, this.explode_range,
                    this.explode_vis_flags, this.explode_vis_bans)

                if targets then
                    for _, t in pairs(targets) do
                        local d = E:create_entity("damage")

                        d.damage_type = this.explode_damage_type
                        d.value = this.explode_damage * this.modifier.damage_factor
                        d.target_id = t.id
                        d.source_id = this.id

                        queue_damage(store, d)
                        local new_mod = E:create_entity("mod_lynn_ultimate")
                        new_mod.modifier.source_id = this.id
                        new_mod.modifier.target_id = t.id
                        new_mod.modifier.damage_factor = this.modifier.damage_factor * 0.5
                        queue_insert(store, new_mod)
                    end
                end

                break
            end

            s_top.offset.x = target.health_bar.offset.x + m.health_bar_offset.x
            s_top.offset.y = target.health_bar.offset.y + m.health_bar_offset.y
            s_over.offset.x = target.unit.mod_offset.x
            s_over.offset.y = target.unit.mod_offset.y

            if dps.damage_every and store.tick_ts - dps.ts >= dps.damage_every then
                dps.ts = dps.ts + dps.damage_every

                local d = E:create_entity("damage")

                d.source_id = this.id
                d.target_id = target.id
                d.value = dps.damage_max * this.modifier.damage_factor
                d.damage_type = dps.damage_type

                queue_damage(store, d)
            end

            coroutine.yield()
        end

        queue_remove(store, this)
    end

    scripts.mod_lynn_weakening = {}

    function scripts.mod_lynn_weakening.insert(this, store, script)
        local target = store.entities[this.modifier.target_id]

        if not target or target.health.dead or target.enemy and not target.enemy.can_accept_magic then
            return false
        end
        if this.magic_armor_reduction > target.health.magic_armor then
            this.armor_reduction = this.armor_reduction + 0.5 * target.health.magic_armor
        else
            this.armor_reduction = this.armor_reduction + 0.5 * this.magic_armor_reduction
        end
        this.magic_armor_reduction = this.magic_armor_reduction * (1 - target.health.armor_resilience)
        this.armor_reduction = this.armor_reduction * (1 - target.health.armor_resilience)
        SU.armor_dec(target, this.armor_reduction)
        SU.magic_armor_dec(target, this.magic_armor_reduction)

        -- local mods = U.get_modifiers(store, target, {"mod_lynn_despair", "mod_lynn_ultimate"})

        -- for _, m in pairs(mods) do
        --     if m ~= this then
        --         U.sprites_hide(m, nil, nil, true)
        --     end
        -- end

        signal.emit("mod-applied", this, target)

        return true
    end

    function scripts.mod_lynn_weakening.remove(this, store, script)
        local target = store.entities[this.modifier.target_id]

        if target then
            SU.armor_inc(target, this.armor_reduction)
            SU.magic_armor_inc(target, this.magic_armor_reduction)
        end

        return true
    end

    scripts.mod_lynn_despair = {}

    function scripts.mod_lynn_despair.insert(this, store)
        local target = store.entities[this.modifier.target_id]

        if not target or target.health.dead or not target.unit or not target.motion then
            return false
        end

        target.unit.damage_factor = target.unit.damage_factor * this.inflicted_damage_factor

        if not target.motion.invulnerable then
            target.motion.max_speed = target.motion.max_speed * this.speed_factor
        end

        this.modifier.ts = store.tick_ts
        this.render.sprites[1].ts = store.tick_ts

        -- local mods = U.get_modifiers(store, target, {"mod_lynn_ultimate", "mod_lynn_weakening"})

        -- for _, m in pairs(mods) do
        --     if m ~= this then
        --         U.sprites_hide(m, nil, nil, true)
        --     end
        -- end

        signal.emit("mod-applied", this, target)

        return true
    end

    function scripts.mod_lynn_despair.remove(this, store)
        local target = store.entities[this.modifier.target_id]

        if target and target.health and target.unit and target.motion then
            target.unit.damage_factor = target.unit.damage_factor / this.inflicted_damage_factor

            if not target.motion.invulnerable then
                target.motion.max_speed = target.motion.max_speed / this.speed_factor
            end
        end

        return true
    end

    scripts.mod_lynn_curse = {}

    function scripts.mod_lynn_curse.insert(this, store)
        local target = store.entities[this.modifier.target_id]

        if not target or math.random() >= this.modifier.chance or not U.flags_pass(target.vis, this.modifier) then
            log.debug("mod_lynn_curse chance miss")
            return false
        end

        log.debug("mod_lynn_curse chance hit")
        scripts.cast_silence(target)

        return true
    end

    function scripts.mod_lynn_curse.update(this, store)
        this.modifier.ts = store.tick_ts

        local target

        repeat
            coroutine.yield()

            target = store.entities[this.modifier.target_id]
        until store.tick_ts - this.modifier.ts >= this.modifier.duration or not target or target.health.dead

        queue_remove(store, this)
    end

    function scripts.mod_lynn_curse.remove(this, store)
        local target = store.entities[this.modifier.target_id]
        scripts.remove_silence(target)
        return true
    end

    -- 威尔伯
    scripts.hero_wilbur = {}

    function scripts.hero_wilbur.missile_filter_fn(e, origin)
        local pp = P:predict_enemy_pos(e, 2)
        local allow = math.abs(pp.y - origin.y) < 80

        return allow
    end

    function scripts.hero_wilbur.level_up(this, store)
        local hl, ls = level_up_basic(this)

        local b = E:get_template(this.ranged.attacks[1].bullet)

        b.bullet.damage_max = ls.ranged_damage_max[hl]
        b.bullet.damage_min = ls.ranged_damage_min[hl]

        upgrade_skill(this, "missile", function(this, s)
            local a = this.ranged.attacks[2]

            a.disabled = nil

            local b = E:get_template(a.bullet)

            b.bullet.damage_max = s.damage_max[s.level]
            b.bullet.damage_min = s.damage_min[s.level]

        end)
        upgrade_skill(this, "smoke", function(this, s)
            local a = this.timed_attacks.list[1]

            a.disabled = nil

            local au = E:get_template(a.bullet)

            au.aura.duration = s.duration[s.level]

            local m = E:get_template(au.aura.mod)

            m.slow.factor = s.slow_factor[s.level]
        end)

        upgrade_skill(this, "box", function(this, s)
            local a = this.timed_attacks.list[2]

            a.disabled = nil

            local pl = E:get_template(a.payload)

            pl.spawner.count = s.count[s.level]
        end)

        upgrade_skill(this, "engine", function(this, s)
            this.engine_factor = s.speed_factor[s.level]
        end)

        upgrade_skill(this, "ultimate", function(this, s)
            this.ultimate.disabled = nil
            local m = E:get_template("drone_wilbur")
            m.custom_attack.damage_max = s.damage[s.level] - 1
            m.custom_attack.damage_min = -1
        end)

        this.motion.max_speed = this.motion.max_speed_base * this.engine_factor

        this.health.hp = this.health.hp_max
    end

    function scripts.hero_wilbur.insert(this, store)
        this.hero.fn_level_up(this, store)

        this.ranged.order = U.attack_order(this.ranged.attacks)

        local a = E:create_entity("aura_bobbing_wilbur")

        a.aura.source_id = this.id
        a.aura.ts = store.tick_ts
        a.pos = this.pos

        queue_insert(store, a)

        return true
    end

    function scripts.hero_wilbur.update(this, store)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta

        U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)

        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
                U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil,
                    true)
            end

            while this.nav_rally.new do
                SU.y_hero_new_rally(store, this)
            end

            if SU.hero_level_up(store, this) then
                -- block empty
            end

            if ready_to_use_skill(this.ultimate, store) then
                local target = U.find_foremost_enemy(store.entities, this.pos, 0, this.ranged.attacks[1].max_range, 0,
                    F_RANGED, 0)

                if target and target.pos then
                    S:queue(this.sound_events.change_rally_point)
                    local e = E:create_entity(this.hero.skills.ultimate.controller_name)

                    e.level = this.hero.skills.ultimate.level
                    e.pos = V.vclone(target.pos)

                    queue_insert(store, e)
                end

                this.ultimate.ts = store.tick_ts
                SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
            end

            a = this.timed_attacks.list[1]
            skill = this.hero.skills.smoke

            if ready_to_use_skill(a, store) then
                local target = U.find_foremost_enemy(store.entities, this.pos, a.min_range, a.max_range,
                    a.node_prediction, a.vis_flags, a.vis_bans)

                if not target then
                    SU.delay_attack(store, a, 0.06666666666666667)
                else
                    S:queue(a.sound, a.sound_args)
                    U.y_animation_play(this, a.animations[1], nil, store.tick_ts)
                    SU.hero_gain_xp_from_skill(this, skill)

                    local au = E:create_entity(a.bullet)

                    au.pos.x, au.pos.y = this.pos.x, this.pos.y
                    queue_insert(store, au)
                    U.y_animation_play(this, a.animations[2], nil, store.tick_ts)
                    U.animation_start(this, a.animations[3], nil, store.tick_ts, false)
                    SU.y_hero_animation_wait(this)

                    a.ts = store.tick_ts

                    goto label_199_0
                end
            end

            a = this.timed_attacks.list[2]
            skill = this.hero.skills.box

            if ready_to_use_skill(a, store) then
                local target_info = U.find_enemies_in_paths(store.entities, this.pos, a.range_nodes_min,
                    a.range_nodes_max, a.max_path_dist, a.vis_flags, a.vis_bans, true, function(e)
                        return not U.flag_has(P:path_terrain_props(e.nav_path.pi), TERRAIN_FAERIE)
                    end)

                if not target_info then
                    SU.delay_attack(store, a, 0.16666666666666666)
                else
                    local target = target_info[1].enemy
                    local origin = target_info[1].origin
                    local start_ts = store.tick_ts
                    local bullet_to_ni = origin[3] - math.random(8, 13)

                    bullet_to_ni = km.clamp(5, P:get_end_node(origin[1]), bullet_to_ni)

                    local bullet_to = P:node_pos(origin[1], 1, bullet_to_ni)
                    local flip = bullet_to.x < this.pos.x

                    S:queue(a.sound)
                    U.animation_start(this, a.animation, flip, store.tick_ts)

                    if SU.y_hero_wait(store, this, a.shoot_time) then
                        goto label_199_0
                    end

                    SU.hero_gain_xp_from_skill(this, skill)

                    a.ts = store.tick_ts

                    local e = E:create_entity(a.payload)

                    e.spawner.pi = origin[1]
                    e.spawner.ni = bullet_to_ni
                    e.pos = bullet_to

                    local b = E:create_entity(a.bullet)

                    b.pos.x = this.pos.x + (flip and -1 or 1) * a.bullet_start_offset.x
                    b.pos.y = this.pos.y + a.bullet_start_offset.y
                    b.bullet.from = V.vclone(b.pos)
                    b.bullet.to = V.vclone(e.pos)
                    b.bullet.hit_payload = e

                    queue_insert(store, b)
                    SU.y_hero_animation_wait(this)

                    a.ts = store.tick_ts

                    goto label_199_0
                end
            end

            brk, sta = SU.y_soldier_ranged_attacks(store, this)

            if brk then
                -- block empty
            else
                SU.soldier_idle(store, this)
                SU.soldier_regen(store, this)
            end

            ::label_199_0::

            coroutine.yield()
        end
    end

    scripts.hero_wilbur_ultimate = {}

    function scripts.hero_wilbur_ultimate.update(this, store)
        for i, o in ipairs(this.spawn_offsets) do
            local e = E:create_entity(this.entity)

            e.pos.x, e.pos.y = this.pos.x + o.x, this.pos.y + o.y
            e.spawn_index = i
            queue_insert(store, e)
        end

        queue_remove(store, this)
    end

    scripts.aura_wilbur_bobbing = {}

    function scripts.aura_wilbur_bobbing.update(this, store)
        local hero = store.entities[this.aura.source_id]
        local s3 = hero.render.sprites[3]
        local nr = hero.nav_rally
        local layers = {hero.render.sprites[3], hero.render.sprites[4]}
        local r_names = {"r", "r"}
        local dist_th = 40
        local max_angle = km.deg2rad(5)
        local angle_step = km.deg2rad(20) * store.tick_length
        local h_max = 4
        local h_step = 20 * store.tick_length
        local h_ts = store.tick_ts

        while true do
            local dx = this.pos.x - nr.center.x
            local sign = dx < 0 and -1 or 1
            local dest_angle = km.clamp(-max_angle, max_angle, max_angle * dx / dist_th)

            for _, s in pairs(layers) do
                local da = km.clamp(-angle_step, angle_step, dest_angle - s.r)

                s.r = s.r + da
            end

            for _, s in pairs(layers) do
                local o = s.offset

                if s3.name == "idle" then
                    o.y = h_max * math.sin(2 * math.pi * (store.tick_ts - h_ts))
                else
                    local dy = km.clamp(-h_step, h_step, -o.y)

                    o.y = o.y + dy
                    h_ts = store.tick_ts
                end
            end

            coroutine.yield()
        end
    end

    scripts.drone_wilbur = {}

    function scripts.drone_wilbur.update(this, store)
        local sd = this.render.sprites[1]
        local ss = this.render.sprites[2]
        local ca = this.custom_attack
        local fm = this.force_motion

        local function find_target(range)
            local target, targets

            for _, set in pairs(ca.range_sets) do
                local min_range, max_range = unpack(set)

                target, targets = U.find_nearest_enemy(store.entities, this.pos, min_range, max_range, ca.vis_flags,
                    ca.vis_bans)

                if target then
                    break
                end
            end

            if not target then
                return nil
            end

            local drones = LU.list_entities(store.entities, this.template_name)
            local drone_target_ids = table.map(drones, function(k, v)
                return v._chasing_target_id or 0
            end)
            local untargeted = table.filter(targets, function(k, v)
                return not table.contains(drone_target_ids, v.id)
            end)

            for _, nt in ipairs(targets) do
                if table.contains(untargeted, nt) then
                    return nt
                end
            end

            return target
        end

        local shoot_ts, search_ts, shots = 0, 0, 0
        local target, targets, dist
        local dest = V.v(this.pos.x, this.pos.y)

        this.start_ts = store.tick_ts
        fm.a_step = fm.a_step + math.random(-3, 3)
        this.tween.ts = U.frandom(0, 1)

        local oos = {V.v(-6, 0), V.v(6, 2), V.v(2, 6), V.v(0, -6)}
        local oo = oos[this.spawn_index]

        U.animation_start(this, "idle", nil, store.tick_ts, true)

        while store.tick_ts - this.start_ts <= this.duration do
            search_ts = store.tick_ts

            if shots < ca.max_shots then
                target = find_target(ca.max_range)
            else
                target = nil
            end

            this._chasing_target_id = target and target.id or nil

            if target then
                repeat
                    dest.x, dest.y = target.pos.x + oo.x, target.pos.y + oo.y
                    sd.flip_x = this.pos.x < dest.x

                    U.force_motion_step(this, store.tick_length, dest)
                    coroutine.yield()

                    dist = V.dist(this.pos.x, this.pos.y, dest.x, dest.y)
                until dist < ca.shoot_range or target.health.dead or band(ca.vis_flags, target.vis.bans) ~= 0

                if shots < ca.max_shots and store.entities[target.id] and not target.health.dead and
                    band(ca.vis_flags, target.vis.bans) == 0 and store.tick_ts - shoot_ts > ca.cooldown then
                    shots = shots + 1

                    if math.random() < ca.sound_chance then
                        S:queue(ca.sound)
                    end

                    U.animation_start(this, "shoot", this.pos.x < target.pos.x, store.tick_ts, false)

                    for i = 1, ca.hit_cycles do
                        local hit_ts = store.tick_ts

                        while store.tick_ts - hit_ts < ca.hit_time do
                            U.force_motion_step(this, store.tick_length, dest)

                            sd.flip_x = this.pos.x < target.pos.x

                            coroutine.yield()
                        end

                        local d = SU.create_attack_damage(ca, target.id, this)

                        queue_damage(store, d)
                    end

                    while not U.animation_finished(this) do
                        U.force_motion_step(this, store.tick_length, dest)

                        sd.flip_x = this.pos.x < target.pos.x

                        coroutine.yield()
                    end

                    U.animation_start(this, "idle", nil, store.tick_ts, true)

                    shoot_ts = store.tick_ts
                end

                U.animation_start(this, "idle", nil, store.tick_ts, true)
            end

            while store.tick_ts - search_ts < ca.search_cooldown do
                U.force_motion_step(this, store.tick_length, dest)
                coroutine.yield()
            end
        end

        U.y_ease_keys(store, {sd, sd.offset, ss}, {"alpha", "y", "alpha"}, {255, 50, 255}, {0, 85, 0}, 0.4)
        queue_remove(store, this)
    end

    scripts.aura_box_wilbur = {}

    function scripts.aura_box_wilbur.update(this, store)
        local sp = this.spawner

        this.render.sprites[1].ts = store.tick_ts

        SU.insert_sprite(store, "decal_rock_crater", this.pos)
        U.y_wait(store, sp.spawn_time)

        this.render.sprites[1].z = Z_DECALS

        S:queue(sp.sound)

        for i = 1, sp.count do
            local e = E:create_entity(sp.entity)

            e.pos.x, e.pos.y = this.pos.x, this.pos.y
            e.nav_path.pi = sp.pi
            e.nav_path.spi = km.zmod(i, 3)
            e.nav_path.ni = sp.ni

            queue_insert(store, e)
        end

        SU.insert_sprite(store, "fx_box_wilbur_smoke_b", V.v(this.pos.x + 33 - 40, this.pos.y + 32 - 20))
        SU.insert_sprite(store, "fx_box_wilbur_smoke_a", V.v(this.pos.x + 60 - 40, this.pos.y + 32 - 22))
        SU.insert_sprite(store, "fx_box_wilbur_smoke_a", V.v(this.pos.x + 10 - 40, this.pos.y + 32 - 22), true)
        U.y_wait(store, fts(10))
        U.y_ease_key(store, this.render.sprites[1], "alpha", 255, 0, 1)
        queue_remove(store, this)
    end

    scripts.shot_wilbur = {}

    function scripts.shot_wilbur.update(this, store)
        local b = this.bullet
        local target = store.entities[b.target_id]
        local source = store.entities[b.source_id]

        if b.shot_index < 3 then
            local flip_x = b.to.x < source.pos.x
            local sfx = E:create_entity(b.shoot_fx)

            sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
            sfx.render.sprites[1].flip_x = flip_x
            sfx.render.sprites[1].r = (flip_x and -1 or 1) * km.deg2rad(-30)
            sfx.render.sprites[1].ts = store.tick_ts

            queue_insert(store, sfx)
        end

        if b.shot_index == 1 and target and not U.flag_has(target.vis.flags, F_FLYING) then
            local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni

            ni = ni + 6

            for i = 1, 6 do
                local sign = i % 2 == 0 and 1 or -1
                local p = P:node_offset_pos(10 * sign, pi, spi, ni - i)
                local fx = E:create_entity(b.hit_fx)

                fx.pos.x, fx.pos.y = p.x, p.y
                fx.render.sprites[1].ts = store.tick_ts + fts(2 * i)

                queue_insert(store, fx)
            end
        end

        U.y_wait(store, b.flight_time)

        if target then
            local d = SU.create_bullet_damage(b, target.id, this.id)

            queue_damage(store, d)
        end

        queue_remove(store, this)
    end
    scripts.missile_wilbur = {}

    function scripts.missile_wilbur.insert(this, store, script)
        local b = this.bullet

        b.to.x = this.pos.x
        b.to.y = this.pos.y + math.random(70, 110)

        if b.shot_index ~= 1 then
            local o_target = store.entities[b.target_id]
            local o = o_target and o_target.pos or this.pos
            local target, targets = U.find_foremost_enemy(store.entities, o, 0, b.first_retarget_range, false,
                b.vis_flags, b.vis_bans, function(e)
                    return e.id ~= b.target_id
                end)

            if targets then
                local target = targets[b.shot_index - 1] or table.random(targets)

                b.target_id = target.id
            end
        end

        return scripts.missile.insert(this, store, script)
    end

    scripts.hero_veznan = {}

    function scripts.hero_veznan.level_up(this, store)
        local hl, ls = level_up_basic(this)

        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

        local bt = E:get_template(this.ranged.attacks[1].bullet)

        bt.bullet.damage_min = ls.ranged_damage_min[hl]
        bt.bullet.damage_max = ls.ranged_damage_max[hl]

        upgrade_skill(this, "soulburn", function(this, s)
            local a = this.timed_attacks.list[1]

            a.disabled = nil
            a.total_hp = s.total_hp[s.level]

        end)
        upgrade_skill(this, "shackles", function(this, s)
            local a = this.timed_attacks.list[2]

            a.disabled = nil
            a.max_count = s.max_count[s.level]
        end)

        upgrade_skill(this, "hermeticinsight", function(this, s)
            this.hermeticinsight_factor = s.range_factor[s.level]
        end)

        upgrade_skill(this, "arcanenova", function(this, s)
            local a = this.timed_attacks.list[3]

            a.disabled = nil
            a.damage_max = s.damage_max[s.level]
            a.damage_min = s.damage_min[s.level]

        end)

        upgrade_skill(this, "ultimate", function(this, s)
            this.ultimate.disabled = nil
            local u = E:get_template(s.controller_name)
            local m = E:get_template(u.mod)

            m.modifier.duration = s.stun_duration[s.level]

            local e = E:get_template(u.entity)

            e.health.hp_max = s.soldier_hp_max[s.level]
            e.melee.attacks[1].damage_max = s.soldier_damage_max[s.level]
            e.melee.attacks[1].damage_min = s.soldier_damage_min[s.level]

            local b = E:get_template(e.ranged.attacks[1].bullet)

            b.bullet.damage_max = s.soldier_damage_max[s.level]
            b.bullet.damage_min = s.soldier_damage_min[s.level]

        end)

        this.ranged.attacks[1].max_range = this.ranged.attacks[1].max_range_base * this.hermeticinsight_factor
        this.timed_attacks.list[1].range = this.timed_attacks.list[1].range_base * this.hermeticinsight_factor
        this.timed_attacks.list[2].range = this.timed_attacks.list[2].range_base * this.hermeticinsight_factor
        this.timed_attacks.list[3].max_range = this.timed_attacks.list[3].max_range_base * this.hermeticinsight_factor

        this.health.hp = this.health.hp_max
    end

    function scripts.hero_veznan.update(this, store)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta

        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_154_0
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                a = this.timed_attacks.list[1]
                skill = this.hero.skills.soulburn

                if ready_to_use_skill(a, store) then
                    local triggers = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, a.vis_flags,
                        a.vis_bans, function(e)
                            return skill.level == 3 or e.health.hp_max <= a.total_hp
                        end)

                    if not triggers then
                        SU.delay_attack(store, a, 0.3333333333333333)
                    else
                        table.sort(triggers, function(e1, e2)
                            return e1.health.hp > e2.health.hp
                        end)

                        local targets = {}
                        local first_target = triggers[1]

                        table.insert(targets, first_target)

                        local hp_count = first_target.health.hp

                        if hp_count < a.total_hp then
                            for _, t in pairs(triggers) do
                                if t ~= first_target and hp_count + t.health.hp_max <= a.total_hp and
                                    U.is_inside_ellipse(t.pos, first_target.pos, a.radius) then
                                    table.insert(targets, t)

                                    hp_count = hp_count + t.health.hp_max
                                end
                            end
                        end

                        S:queue(a.sound)

                        local af = first_target.pos.x < this.pos.x

                        U.animation_start(this, a.animations[1], af, store.tick_ts, false)
                        U.y_wait(store, a.cast_time)

                        local balls = {}
                        local o = V.v(a.balls_dest_offset.x * (this.render.sprites[1].flip_x and -1 or 1),
                            a.balls_dest_offset.y)

                        for _, target in pairs(targets) do
                            local d = E:create_entity("damage")

                            d.damage_type = DAMAGE_EAT
                            d.target_id = target.id
                            d.source_id = this.id

                            queue_damage(store, d)

                            local fx = E:create_entity(a.hit_fx)

                            fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
                            fx.render.sprites[1].name = fx.render.sprites[1].size_names[target.unit.size]
                            fx.render.sprites[1].ts = store.tick_ts

                            queue_insert(store, fx)

                            local b = E:create_entity(a.ball)

                            b.from = V.v(target.pos.x + target.unit.mod_offset.x,
                                target.pos.y + target.unit.mod_offset.y)
                            b.to = V.v(this.pos.x + o.x, this.pos.y + o.y)
                            b.pos = V.vclone(b.from)
                            b.target = target

                            queue_insert(store, b)
                            table.insert(balls, b)
                        end

                        U.y_animation_wait(this)
                        U.animation_start(this, a.animations[2], nil, store.tick_ts, true)

                        while true do
                            coroutine.yield()

                            local arrived = true

                            for _, ball in pairs(balls) do
                                arrived = arrived and ball.arrived
                            end

                            if arrived then
                                break
                            end

                            if h.dead then
                                goto label_154_0
                            end
                        end

                        SU.hero_gain_xp_from_skill(this, skill)
                        U.animation_start(this, a.animations[3], nil, store.tick_ts, false)
                        U.y_animation_wait(this)

                        a.ts = store.tick_ts
                    end
                end

                a = this.timed_attacks.list[3]
                skill = this.hero.skills.arcanenova

                if ready_to_use_skill(a, store) then
                    local target, targets = U.find_foremost_enemy(store.entities, this.pos, a.min_range, a.max_range,
                        a.cast_time, a.vis_flags, a.vis_bans)

                    if not target or #targets < 2 then
                        SU.delay_attack(store, a, 0.3333333333333333)
                    else
                        local af = target.pos.x < this.pos.x

                        U.animation_start(this, a.animation, af, store.tick_ts, false)
                        U.y_wait(store, a.hit_time)

                        local node = table.deepclone(target.nav_path)

                        node.spi = 1

                        local node_pos = P:node_pos(node)
                        local targets = U.find_enemies_in_range(store.entities, node_pos, 0, a.damage_radius,
                            a.vis_flags, a.vis_bans)

                        if targets then
                            SU.hero_gain_xp_from_skill(this, skill)

                            for _, t in pairs(targets) do
                                queue_damage(store, SU.create_attack_damage(a, t.id, this))

                                local m = E:create_entity(a.mod)

                                m.modifier.source_id = this.id
                                m.modifier.target_id = t.id
                                queue_insert(store, m)
                            end
                        end

                        S:queue(a.cast_sound)

                        local fx = E:create_entity(a.hit_fx)

                        fx.pos.x, fx.pos.y = node_pos.x, node_pos.y

                        U.animation_start(fx, nil, nil, store.tick_ts, false)
                        queue_insert(store, fx)
                        U.y_wait(store, fts(5))

                        local decal = E:create_entity(a.hit_decal)

                        decal.pos.x, decal.pos.y = node_pos.x, node_pos.y
                        decal.tween.ts = store.tick_ts
                        decal.render.sprites[2].ts = store.tick_ts

                        queue_insert(store, decal)
                        U.y_animation_wait(this)

                        a.ts = store.tick_ts
                    end
                end

                a = this.timed_attacks.list[2]
                skill = this.hero.skills.shackles

                if ready_to_use_skill(a, store) then
                    local triggers = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, a.vis_flags,
                        a.vis_bans)

                    if not triggers then
                        SU.delay_attack(store, a, 0.3333333333333333)
                    else
                        local first_target = table.random(triggers)
                        local targets = U.find_enemies_in_range(store.entities, first_target.pos, 0, a.radius,
                            a.vis_flags, a.vis_bans)
                        local af = first_target.pos.x < this.pos.x

                        U.animation_start(this, a.animation, af, store.tick_ts, false)
                        U.y_wait(store, a.cast_time)
                        S:queue(a.cast_sound)
                        SU.hero_gain_xp_from_skill(this, skill)

                        for i = 1, math.min(#targets, a.max_count) do
                            local target = targets[i]

                            for _, m_name in pairs(a.mods) do
                                local m = E:create_entity(m_name)

                                m.modifier.target_id = target.id
                                m.modifier.source_id = this.id

                                queue_insert(store, m)
                            end
                        end

                        U.y_animation_wait(this)

                        a.ts = store.tick_ts
                    end
                end

                if ready_to_use_skill(this.ultimate, store) then
                    local target = find_target_at_critical_moment(this, store, this.ranged.attacks[1].max_range)

                    if target and target.pos and valid_rally_node_nearby(target.pos) then
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                        S:queue(this.sound_events.change_rally_point)
                        local e = E:create_entity(this.hero.skills.ultimate.controller_name)

                        e.level = this.hero.skills.ultimate.level
                        e.pos = V.vclone(target.pos)

                        queue_insert(store, e)

                        this.ultimate.ts = store.tick_ts
                        SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
                    else
                        this.ultimate.ts = this.ultimate.ts + 1
                    end
                end

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta ~= A_NO_TARGET then
                    -- block empty
                else
                    brk, sta = SU.y_soldier_ranged_attacks(store, this)

                    if brk then
                        -- block empty
                    elseif SU.soldier_go_back_step(store, this) then
                        -- block empty
                    else
                        SU.soldier_idle(store, this)
                        SU.soldier_regen(store, this)
                    end
                end
            end

            ::label_154_0::

            coroutine.yield()
        end
    end

    scripts.hero_veznan_ultimate = {}

    function scripts.hero_veznan_ultimate.update(this, store)
        local e = E:create_entity(this.entity)

        e.pos.x, e.pos.y = this.pos.x, this.pos.y
        e.nav_rally.pos = V.vclone(e.pos)
        e.nav_rally.center = V.vclone(e.pos)

        queue_insert(store, e)

        local targets = U.find_enemies_in_range(store.entities, this.pos, 0, this.range, this.vis_flags, this.vis_bans)

        if targets then
            for _, target in pairs(targets) do
                local m = E:create_entity(this.mod)

                m.modifier.source_id = this.id
                m.modifier.target_id = target.id

                queue_insert(store, m)
            end
        end

        queue_remove(store, this)
    end

    scripts.hero_durax = {}

    function scripts.hero_durax.get_info(this)
        local info = scripts.hero_basic.get_info(this)

        if this.clone then
            info.respawn = nil
        end

        return info
    end

    function scripts.hero_durax.level_up(this, store)
        local hl, ls = level_up_basic(this)

        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
        this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

        local upgrade_all_skill = function()
            upgrade_skill(this, "crystallites", function(this, s)
                local a = this.timed_attacks.list[2]
                a.disabled = nil
            end)
            upgrade_skill(this, "armsword", function(this, s)
                local a = this.melee.attacks[3]
                a.disabled = nil
                a.damage_min = s.damage[s.level]
                a.damage_max = s.damage[s.level]
            end)

            upgrade_skill(this, "lethal_prism", function(this, s)
                local a = this.timed_attacks.list[1]
                a.disabled = nil
                a.ray_count = s.ray_count[s.level]

                local b = E:get_template(a.bullet)

                b.bullet.damage_max = s.damage_max[s.level]
                b.bullet.damage_min = s.damage_min[s.level]
            end)
            upgrade_skill(this, "shardseed", function(this, s)
                local a = this.ranged.attacks[1]
                a.disabled = nil

                local b = E:get_template(a.bullet)

                b.bullet.damage_max = s.damage[s.level]
                b.bullet.damage_min = s.damage[s.level]
            end)

            upgrade_skill(this, "ultimate", function(this, s)
                this.ultimate.disabled = nil
                local u = E:get_template(s.controller_name)
                u.max_count = s.max_count[s.level]
                u.damage = s.damage[s.level]
            end)
        end

        if this.clone and not this.first_updated then
            local level = this.hero.level
            for i = 1, level do
                this.hero.level = i
                upgrade_all_skill()
            end
            this.first_updated = true
        else
            upgrade_all_skill()
        end

        this.health.hp = this.health.hp_max
    end

    function scripts.hero_durax.update(this, store)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta, decal

        this.health_bar.hidden = false

        if not this.clone then
            U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

            decal = E:create_entity("decal_durax")
            decal.pos = this.pos

            queue_insert(store, decal)
        end

        while true do
            if h.dead or this.clone and store.tick_ts - this.clone.ts > this.clone.duration then
                if this.clone then
                    this.ui.can_click = false
                    this.health.hp = 0
                    signal.emit("hero-removed-no-panel", this)
                    SU.y_soldier_death(store, this)

                    this.tween.disabled = nil
                    this.tween.ts = store.tick_ts

                    return
                else
                    decal.render.sprites[1].hidden = true

                    SU.y_hero_death_and_respawn(store, this)

                    decal.render.sprites[1].hidden = nil
                end
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_161_0
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                a = this.timed_attacks.list[1]
                skill = this.hero.skills.lethal_prism

                if ready_to_use_skill(a, store) then
                    local triggers = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, a.vis_flags,
                        a.vis_bans)

                    if not triggers then
                        SU.delay_attack(store, a, 0.3333333333333333)
                    else
                        SU.remove_modifiers(store, this)

                        this.health_bar.hidden = true
                        this.health.ignore_damage = true

                        local vis_flags = this.vis.flags
                        local vis_bans = this.vis.bans

                        this.vis.flags = U.flag_clear(this.vis.flags, F_RANGED)
                        this.vis.bans = F_ALL

                        U.y_animation_play(this, a.animations[1], nil, store.tick_ts)
                        U.animation_start(this, a.animations[2], nil, store.tick_ts, true)

                        for i = 1, a.ray_count do
                            local target = U.find_random_enemy(store.entities, this.pos, 0, a.range, a.vis_flags,
                                a.vis_bans)

                            if target then
                                local bo = a.bullet_start_offset[1]
                                local b = E:create_entity(a.bullet)
                                b.bullet.damage_factor = this.unit.damage_factor
                                b.bullet.target_id = target.id
                                b.bullet.source_id = this.id
                                b.pos = V.v(this.pos.x + bo.x, this.pos.y + bo.y)
                                b.bullet.from = V.vclone(b.pos)
                                b.bullet.to = V.vclone(target.pos)

                                queue_insert(store, b)
                            end

                            U.y_wait(store, a.ray_cooldown)
                        end

                        U.y_animation_play(this, a.animations[3], nil, store.tick_ts)

                        this.vis.flags = vis_flags
                        this.vis.bans = vis_bans
                        this.health.ignore_damage = nil
                        this.health_bar.hidden = nil
                        a.ts = store.tick_ts

                        SU.hero_gain_xp_from_skill(this, skill)

                        goto label_161_0
                    end
                end

                a = this.timed_attacks.list[2]
                skill = this.hero.skills.crystallites

                if not this.clone and ready_to_use_skill(a, store) then
                    local nearest = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_RALLY)

                    if #nearest < 1 then
                        SU.delay_attack(store, a, 0.3333333333333333)
                    else
                        local ns = {}

                        ns.pi = nearest[1][1]
                        ns.spi = math.random(1, 3)
                        ns.ni = nearest[1][3] - math.random(a.nodes_offset[1], a.nodes_offset[2])

                        local node_pos = P:node_pos(ns)

                        if not P:is_node_valid(ns.pi, ns.ni, NF_RALLY) or
                            band(GR:cell_type(node_pos.x, node_pos.y), bor(TERRAIN_NOWALK, TERRAIN_FAERIE)) ~= 0 then
                            SU.delay_attack(store, a, 0.3333333333333333)
                        else
                            S:queue(a.sound)
                            U.animation_start(this, a.animation, nil, store.tick_ts, false)
                            U.y_wait(store, a.spawn_time)

                            local spawn_pos = V.v(this.pos.x + (this.render.sprites[1].flip_x and -1 or 1) *
                                                      a.spawn_offset.x, this.pos.y + a.spawn_offset.y)
                            local clone = E:create_entity(a.entity)

                            clone.pos = spawn_pos
                            clone.nav_rally.pos = node_pos
                            clone.nav_rally.center = V.vclone(node_pos)
                            clone.nav_rally.new = true
                            clone.render.sprites[1].flip_x = this.render.sprites[1].flip_x
                            clone.clone.ts = store.tick_ts
                            clone.clone.duration = skill.duration[skill.level]
                            clone.hero.level = this.hero.level
                            clone.hero.xp = this.hero.xp
                            clone.unit.damage_factor = 0.8

                            for sn, s in pairs(this.hero.skills) do
                                clone.hero.skills[sn].level = s.level
                            end

                            queue_insert(store, clone)
                            signal.emit("hero-added-no-panel", clone)
                            SU.hero_gain_xp_from_skill(this, skill)
                            U.y_animation_wait(this)

                            a.ts = store.tick_ts
                        end
                    end
                end

                if ready_to_use_skill(this.ultimate, store) then

                    local target = U.find_foremost_enemy(store.entities, this.pos, 0, this.ranged.attacks[1].max_range,
                        0, F_RANGED, 0)

                    if target and target.pos and
                        scripts.hero_durax_ultimate.can_fire_fn(nil, target.pos.x, target.pos.y, store) then
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                        S:queue(this.sound_events.change_rally_point)
                        local e = E:create_entity(this.hero.skills.ultimate.controller_name)

                        e.level = this.hero.skills.ultimate.level
                        e.pos = V.vclone(target.pos)
                        e.damage_factor = this.unit.damage_factor
                        queue_insert(store, e)

                        this.ultimate.ts = store.tick_ts
                        SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
                    else
                        this.ultimate.ts = this.ultimate.ts + 1
                    end
                end
                if not this.ranged.attacks[1].disabled then
                    brk, sta = SU.y_soldier_ranged_attacks(store, this)

                    if brk then
                        goto label_161_0
                    end
                end

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta ~= A_NO_TARGET then
                    -- block empty
                elseif SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end
            end

            ::label_161_0::

            coroutine.yield()
        end
    end

    scripts.hero_durax_ultimate = {}

    function scripts.hero_durax_ultimate.can_fire_fn(this, x, y, store)
        for _, e in pairs(store.entities) do
            if e.pos and e.ui and e.ui.can_click and e.enemy and e.vis and e.nav_path and e.health and not e.health.dead and
                band(e.vis.flags, F_FLYING) == 0 and band(e.vis.bans, F_MOD) == 0 and
                U.is_inside_ellipse(V.v(e.pos.x + e.unit.hit_offset.x, e.pos.y + e.unit.hit_offset.y), V.v(x, y), 250) and
                P:is_node_valid(e.nav_path.pi, e.nav_path.ni, NF_POWER_1) then
                return true
            end
        end
        return false
    end

    function scripts.hero_durax_ultimate.update(this, store)
        this.damage = this.damage * this.damage_factor
        local targets = U.find_enemies_in_range(store.entities, this.pos, 0, this.range, this.vis_flags, this.vis_bans,
            function(e)
                return band(e.vis.flags, F_BOSS) ~= 0 or band(e.vis.bans, F_STUN) == 0
            end)

        if targets then
            local single = #targets == 1

            for i, target in pairs(targets) do
                if i > this.max_count then
                    break
                end

                local d = E:create_entity("damage")

                d.value = math.ceil(this.damage / #targets)
                d.damage_type = this.damage_type
                d.target_id = target.id
                d.source_id = this.id

                queue_damage(store, d)

                if target.unit.blood_color ~= BLOOD_NONE then
                    local sfx = E:create_entity(this.hit_blood_fx)

                    sfx.pos.x, sfx.pos.y = target.pos.x + target.unit.hit_offset.x,
                        target.pos.y + target.unit.hit_offset.y
                    sfx.render.sprites[1].ts = store.tick_ts

                    if sfx.use_blood_color and target.unit.blood_color then
                        sfx.render.sprites[1].name = target.unit.blood_color
                    end

                    queue_insert(store, sfx)
                end

                local m = E:create_entity(band(target.vis.flags, F_BOSS) ~= 0 and this.mod_slow or this.mod_stun)

                m.modifier.target_id = target.id
                m.modifier.source_id = this.id

                queue_insert(store, m)

                local fx = SU.insert_sprite(store, "fx_durax_ultimate_fang_" .. (single and "1" or "2"), target.pos)

                fx.render.sprites[1].scale = fx.render.sprites[1].size_scales[target.unit.size]

                local spikes_count = single and 12 or 8
                local radius = single and 40 or 30
                local angle = U.frandom(0, math.pi)

                for j = 1, spikes_count do
                    local p = U.point_on_ellipse(target.pos, U.frandom(0.5, 1) * radius, angle)

                    angle = angle + math.pi / 4.2

                    local fx = SU.insert_sprite(store, "fx_durax_ultimate_fang_extra_" .. math.random(1, 2), p, nil,
                        U.frandom(0.1, 0.2))

                    fx.render.sprites[1].scale = V.vv(U.frandom(0.8, 1.1))
                end
            end
        end

        queue_remove(store, this)
    end

    scripts.hero_elves_denas = {}

    function scripts.hero_elves_denas.level_up(this, store)
        local hl, ls = level_up_basic(this)

        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
        this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

        upgrade_skill(this, "sybarite", function(this, s)
            local a = this.timed_attacks.list[2]

            a.disabled = nil
            local m = E:get_template("mod_elves_denas_sybarite")

            m.heal_hp = s.heal_hp[s.level]
        end)
        upgrade_skill(this, "celebrity", function(this, s)
            local a = this.timed_attacks.list[1]

            a.disabled = nil
            a.max_targets = s.max_targets[s.level]

            local m = E:get_template("mod_elves_denas_celebrity")

            m.modifier.duration = s.stun_duration[s.level]
        end)

        upgrade_skill(this, "mighty", function(this, s)
            local a = this.melee.attacks[3]
            a.disabled = nil
            a.damage_min = s.damage_min[s.level]
            a.damage_max = s.damage_max[s.level]
        end)

        upgrade_skill(this, "shield_strike", function(this, s)
            local a = this.ranged.attacks[1]
            a.disabled = nil

            local b = E:get_template("shield_elves_denas")
            b.max_rebounds = s.rebounds[s.level]
            b.bullet.damage_min = s.damage_min[s.level]
            b.bullet.damage_max = s.damage_max[s.level]
        end)

        upgrade_skill(this, "ultimate", function(this, s)
            this.ultimate.disabled = nil
        end)

        this.health.hp = this.health.hp_max
    end

    function scripts.hero_elves_denas.insert(this, store)
        this.hero.fn_level_up(this, store)

        this.melee.order = U.attack_order(this.melee.attacks)

        return true
    end

    function scripts.hero_elves_denas.update(this, store)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta

        local function shield_strike_filter_fn(e, origin)
            local a = this.ranged.attacks[1]
            local targets = U.find_enemies_in_range(store.entities, e.pos, 0, a.rebound_range, a.vis_flags, a.vis_bans)

            return targets and #targets > 1
        end

        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_66_0
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                a = this.timed_attacks.list[1]
                skill = this.hero.skills.celebrity

                if ready_to_use_skill(a, store) then
                    local target = U.find_random_enemy(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans,
                        function(e)
                            return e.unit and not e.unit.is_stunned
                        end)

                    if not target then
                        SU.delay_attack(store, a, 0.13333333333333333)
                    else
                        a.ts = store.tick_ts

                        SU.hero_gain_xp_from_skill(this, skill)
                        U.animation_start(this, a.animation, nil, store.tick_ts)
                        U.y_wait(store, fts(22))
                        S:queue(a.sound)

                        local total_time = fts(52)
                        local flash_every = 1
                        local stun_every = 9 / a.max_targets

                        for i = 1, 9 do
                            if this.health.dead then
                                goto label_66_0
                            end

                            if i % flash_every == 0 then
                                local sfx = E:create_entity("fx_elves_denas_flash")

                                sfx.pos.x, sfx.pos.y = this.pos.x + math.random(-25, 25),
                                    this.pos.y + math.random(5, 40)
                                sfx.render.sprites[1].ts = store.tick_ts
                                sfx.render.sprites[1].flip_x = math.random() < 0.5

                                queue_insert(store, sfx)
                            end

                            if i % stun_every == 0 then
                                target = U.find_random_enemy(store.entities, this.pos, 0, a.range, a.vis_flags,
                                    a.vis_bans, function(e)
                                        return e.unit and not e.unit.is_stunned
                                    end)
                                target = target or
                                             U.find_random_enemy(store.entities, this.pos, 0, a.range, a.vis_flags,
                                        a.vis_bans)

                                if target then
                                    local mod = E:create_entity("mod_elves_denas_celebrity")

                                    mod.modifier.target_id = target.id

                                    queue_insert(store, mod)
                                end
                            end

                            U.y_wait(store, total_time / 9)
                        end

                        U.y_animation_wait(this)
                    end
                end

                if ready_to_use_skill(this.ultimate, store) then
                    local target = find_target_at_critical_moment(this, store, this.ranged.attacks[1].max_range)

                    if target and target.pos and valid_rally_node_nearby(target.pos) then
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                        S:queue(this.sound_events.change_rally_point)
                        local e = E:create_entity(this.hero.skills.ultimate.controller_name)

                        e.level = this.hero.skills.ultimate.level
                        e.pos = V.vclone(target.pos)
                        e.owner = this
                        queue_insert(store, e)

                        this.ultimate.ts = store.tick_ts
                        SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
                    else
                        this.ultimate.ts = this.ultimate.ts + 1
                    end
                end

                a = this.timed_attacks.list[2]
                skill = this.hero.skills.sybarite

                if ready_to_use_skill(a, store) and this.health.hp <= this.health.hp_max - a.lost_health then
                    U.animation_start(this, a.animation, nil, store.tick_ts)

                    if U.y_wait(store, a.hit_time, function()
                        return this.health.dead or this.unit.is_stunned
                    end) then
                        goto label_66_0
                    end

                    a.ts = store.tick_ts

                    S:queue(a.sound)

                    local mod = E:create_entity(a.mod)

                    mod.modifier.target_id = this.id
                    mod.modifier.source_id = this.id

                    queue_insert(store, mod)
                    U.y_animation_wait(this)
                    SU.hero_gain_xp_from_skill(this, skill)
                end

                a = this.ranged.attacks[1]
                skill = this.hero.skills.shield_strike

                if ready_to_use_skill(a, store) then
                    local target, _, pred_pos = U.find_foremost_enemy(store.entities, this.pos, a.min_range,
                        a.max_range, a.node_prediction, a.vis_flags, a.vis_bans, shield_strike_filter_fn, F_FLYING)

                    if target then
                        local start_ts = store.tick_ts
                        local attack_done = SU.y_soldier_do_ranged_attack(store, this, target, a, pred_pos)

                        if attack_done then
                            a.ts = start_ts
                        else
                            goto label_66_0
                        end
                    end
                end

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta ~= A_NO_TARGET then
                    -- block empty
                elseif SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    a = this.wealthy

                    if store.wave_group_number > a.last_wave then
                        a.last_wave = store.wave_group_number

                        S:queue(a.sound)

                        store.player_gold = store.player_gold + a.gold

                        U.animation_start(this, "coinThrow", nil, store.tick_ts)
                        U.y_wait(store, a.hit_time)

                        local fx = E:create_entity(a.fx)

                        fx.render.sprites[1].ts = store.tick_ts
                        fx.pos.x, fx.pos.y = this.pos.x + (this.render.sprites[1].flip_x and 1 or -1) * 20, this.pos.y
                        fx.tween.props[2] = E:clone_c("tween_prop")
                        fx.tween.props[2].name = "offset"
                        fx.tween.props[2].keys = {{0, V.v(0, 40)}, {0.5, V.v(0, 50)}}

                        queue_insert(store, fx)
                        U.y_animation_wait(this)
                    end

                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end
            end

            ::label_66_0::

            coroutine.yield()
        end
    end

    scripts.hero_elves_denas_ultimate = {}

    function scripts.hero_elves_denas_ultimate.update(this, store)
        local nearest = P:nearest_nodes(this.pos.x, this.pos.y)

        if #nearest > 1 then
            local pi, spi, ni = unpack(nearest[1])
            local pos = P:node_pos(pi, 1, ni)
            local count = this.guards_count[this.level]

            for i = 1, count do
                local p = U.point_on_ellipse(pos, 25, i * 2 * math.pi / count)
                local e = E:create_entity(this.guards_template)

                e.pos = p
                e.nav_rally.center = V.vclone(e.pos)
                e.nav_rally.pos = V.vclone(e.pos)
                e.melee.attacks[1].xp_dest_id = this.owner.id
                e.melee.attacks[2].xp_dest_id = this.owner.id

                queue_insert(store, e)
            end
        end

        queue_remove(store, this)
    end

    scripts.mod_elves_denas_sybarite = {}

    function scripts.mod_elves_denas_sybarite.insert(this, store)
        local m = this.modifier
        local target = store.entities[m.target_id]

        if not target or not target.health or target.health.dead then
            return false
        end

        target.unit.damage_factor = target.unit.damage_factor * this.inflicted_damage_factor
        target.health.hp = km.clamp(0, target.health.hp_max, target.health.hp + this.heal_hp)
        this.render.sprites[1].ts = store.tick_ts

        return true
    end

    function scripts.mod_elves_denas_sybarite.remove(this, store)
        local m = this.modifier
        local target = store.entities[m.target_id]

        if target then
            target.unit.damage_factor = target.unit.damage_factor / this.inflicted_damage_factor
        end

        return true
    end

    scripts.shield_elves_denas = {}

    function scripts.shield_elves_denas.update(this, store)
        local b = this.bullet
        local mspeed = b.max_speed
        local s = this.render.sprites[1]
        local target = store.entities[b.target_id]
        local ps
        local bounce_count = 0
        local visited = {}

        U.animation_start(this, nil, nil, store.tick_ts, true)

        b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)

        if b.particles_name then
            ps = E:create_entity(b.particles_name)
            ps.particle_system.track_id = this.id

            queue_insert(store, ps)
        end

        ::label_75_0::

        while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
            target = store.entities[b.target_id]

            if target and target.health and not target.health.dead then
                b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
            end

            b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
            this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length,
                this.pos.y + b.speed.y * store.tick_length
            this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

            coroutine.yield()
        end

        if target and not target.health.dead then
            table.insert(visited, target.id)

            local d = SU.create_bullet_damage(b, target.id, this.id)

            queue_damage(store, d)

            if b.hit_blood_fx and target.unit.blood_color ~= BLOOD_NONE then
                local sfx = E:create_entity(b.hit_blood_fx)

                sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
                sfx.render.sprites[1].ts = store.tick_ts

                if sfx.use_blood_color and target.unit.blood_color then
                    sfx.render.sprites[1].name = target.unit.blood_color
                    sfx.render.sprites[1].r = this.render.sprites[1].r
                end

                queue_insert(store, sfx)
            end
        end

        if b.hit_fx then
            local sfx = E:create_entity(b.hit_fx)

            sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
            sfx.render.sprites[1].ts = store.tick_ts

            queue_insert(store, sfx)
        end

        if bounce_count < this.max_rebounds then
            local last_target = target

            ::label_75_1::

            target = U.find_random_enemy(store.entities, this.pos, 0, this.rebound_range, b.vis_flags, b.vis_bans,
                function(v)
                    return not table.contains(visited, v.id)
                end)

            if not target and #visited > 1 then
                visited = {last_target.id}

                goto label_75_1
            end

            if target then
                S:queue(this.sound_events.bounce)

                bounce_count = bounce_count + 1
                b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
                b.target_id = target.id

                goto label_75_0
            end
        end

        queue_remove(store, this)
    end

    scripts.hero_arivan = {}

    function scripts.hero_arivan.level_up(this, store)
        local hl, ls = level_up_basic(this)
        this.melee_raw_min = ls.melee_damage_min[hl]
        this.melee_raw_max = ls.melee_damage_max[hl]

        local bt = E:get_template(this.ranged.attacks[1].bullet)

        bt.bullet.damage_min = ls.ranged_damage_min[hl]
        bt.bullet.damage_max = ls.ranged_damage_max[hl]

        upgrade_skill(this, "icy_prison", function(this, s)
            local a = this.ranged.attacks[3]
            a.disabled = nil
            local b = E:get_template(a.bullet)
            b.bullet.damage_min = s.damage[s.level]
            b.bullet.damage_max = s.damage[s.level]
            local m = E:get_template(b.bullet.mod)
            m.modifier.duration = s.duration[s.level]
        end)
        upgrade_skill(this, "lightning_rod", function(this, s)
            local a = this.ranged.attacks[2]
            a.disabled = nil
            local b = E:get_template(a.bullet)
            b.bullet.damage_min = s.damage_min[s.level]
            b.bullet.damage_max = s.damage_max[s.level]
        end)

        upgrade_skill(this, "seal_of_fire", function(this, s)
            local a = this.timed_attacks.list[1]
            a.disabled = nil
            a.loops = s.count[s.level]
        end)

        upgrade_skill(this, "stone_dance", function(this, s)
            local a = this.timed_attacks.list[2]
            a.disabled = nil
            a.ts = -a.cooldown + 2
            local aura = E:get_template("aura_arivan_stone_dance")
            aura.max_stones = s.count[s.level]
            this.stone_extra_per_stone = s.stone_extra[s.level]
            if a.aura then
                a.aura.max_stones = s.count[s.level]
                this.stone_extra = #a.aura.stones * this.stone_extra_per_stone
            end
        end)

        upgrade_skill(this, "ultimate", function(this, s)
            this.ultimate.disabled = nil
            local u = E:get_template("hero_arivan_ultimate")
            local tal = u.timed_attacks.list
            local mf = E:get_template("mod_arivan_ultimate_freeze")

            u.aura.duration = s.duration[s.level]
            tal[2].damage_max = s.damage[s.level]
            tal[2].damage_min = s.damage[s.level]
            mf.modifier.duration = s.freeze_duration[s.level]
            tal[3].chance = s.freeze_chance[s.level]
            tal[4].cooldown = s.lightning_cooldown[s.level]
            tal[4].chance = s.lightning_chance[s.level]
        end)

        this.melee.attacks[1].damage_min = this.melee_raw_min + this.stone_extra
        this.melee.attacks[1].damage_max = this.melee_raw_max + this.stone_extra
        this.health.hp = this.health.hp_max
    end

    function scripts.hero_arivan.on_damage(this, store, damage)
        local function quick_cooldown(a)
            a.ts = a.ts - 1
        end
        log.debug(" ARIVAN DAMAGE: %s", damage.value)

        local at = this.timed_attacks.list[2]
        local a = at.aura

        if not a or #a.stones < 1 or band(damage.damage_type, DAMAGE_MODIFIER) ~= 0 then
            return true
        end

        local stone = a.stones[#a.stones]

        stone.hp = stone.hp - damage.value

        if stone.hp <= 0 then
            local fx = E:create_entity("fx_arivan_stone_explosion")

            fx.pos = stone.pos
            fx.render.sprites[1].ts = store.tick_ts

            queue_insert(store, fx)
            queue_remove(store, stone)
            table.remove(a.stones, #a.stones)
            quick_cooldown(this.ranged.attacks[2])
            quick_cooldown(this.ranged.attacks[3])
            quick_cooldown(this.timed_attacks.list[1])
            quick_cooldown(this.ultimate)
            this.stone_extra = #a.stones * this.stone_extra_per_stone
            this.melee.attacks[1].damage_min = this.melee_raw_min + this.stone_extra
            this.melee.attacks[1].damage_max = this.melee_raw_max + this.stone_extra
        end

        a.shield_active = true

        return false
    end

    function scripts.hero_arivan.insert(this, store)
        this.hero.fn_level_up(this, store)

        this.melee.order = U.attack_order(this.melee.attacks)
        this.ranged.order = U.attack_order(this.ranged.attacks)

        local a = E:create_entity("aura_arivan_stone_dance")

        a.aura.source_id = this.id
        a.aura.ts = store.tick_ts
        a.pos = this.pos
        this.timed_attacks.list[2].aura = a

        queue_insert(store, a)

        return true
    end

    function scripts.hero_arivan.update(this, store)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta

        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_90_0
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                a = this.timed_attacks.list[2]
                skill = this.hero.skills.stone_dance

                if not a.disabled and #a.aura.stones == a.aura.max_stones then
                    a.ts = store.tick_ts
                end

                if ready_to_use_skill(a, store) and #a.aura.stones < a.aura.max_stones then
                    S:queue(a.sound)
                    U.animation_start(this, a.animation, nil, store.tick_ts)
                    U.y_wait(store, a.hit_time)

                    local aura = a.aura

                    for i = #a.aura.stones + 1, aura.max_stones do
                        local stone = E:create_entity("arivan_stone")
                        local angle = i * 2 * math.pi / aura.max_stones % (2 * math.pi)

                        stone.pos = U.point_on_ellipse(this.pos, aura.rot_radius, angle)
                        stone.render.sprites[1].name = string.format(stone.render.sprites[1].name, i)
                        stone.render.sprites[1].ts = store.tick_ts

                        queue_insert(store, stone)
                        table.insert(aura.stones, stone)
                    end

                    aura.aura.ts = store.tick_ts

                    this.stone_extra = #a.aura.stones * this.stone_extra_per_stone
                    this.melee.attacks[1].damage_min = this.melee_raw_min + this.stone_extra
                    this.melee.attacks[1].damage_max = this.melee_raw_max + this.stone_extra
                    U.y_animation_wait(this)

                    a.ts = store.tick_ts

                    goto label_90_0
                end

                a = this.timed_attacks.list[1]
                skill = this.hero.skills.seal_of_fire

                if ready_to_use_skill(a, store) then
                    local target = U.find_nearest_enemy(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags,
                        a.vis_bans)

                    if not target then
                        SU.delay_attack(store, a, 0.26666666666666666)
                    else
                        local pred_pos = target.pos
                        local start_ts = store.tick_ts
                        local an, af = U.animation_name_facing_point(this, a.animations[1], pred_pos)

                        U.y_animation_play(this, an, af, store.tick_ts, 1)

                        for i = 1, a.loops do
                            an, af = U.animation_name_facing_point(this, a.animations[2], pred_pos)

                            U.animation_start(this, an, af, store.tick_ts, false)

                            for si, st in pairs(a.shoot_times) do
                                while st > store.tick_ts - this.render.sprites[1].ts do
                                    if SU.hero_interrupted(this) then
                                        goto label_90_0
                                    end

                                    coroutine.yield()
                                end

                                local offset = a.bullet_start_offset[si]
                                local b = E:create_entity(a.bullet)

                                target = U.find_nearest_enemy(store.entities, this.pos, a.min_range, a.max_range,
                                    a.vis_flags, a.vis_bans)

                                if target then
                                    local dist = V.dist(this.pos.x, this.pos.y + offset.y, target.pos.x, target.pos.y)

                                    pred_pos = P:predict_enemy_pos(target, dist / b.bullet.min_speed)
                                end

                                a.ts = store.tick_ts
                                b.pos = V.vclone(this.pos)
                                b.pos.x, b.pos.y = b.pos.x + (af and -1 or 1) * offset.x, b.pos.y + offset.y
                                b.bullet.from = V.vclone(b.pos)
                                b.bullet.to = V.vclone(pred_pos)
                                b.bullet.to.x, b.bullet.to.y = b.bullet.to.x + U.frandom(-1, 1),
                                    b.bullet.to.y + U.frandom(-1, 1)
                                b.bullet.source_id = this.id
                                b.bullet.xp_dest_id = this.id
                                b.bullet.damage_factor = this.unit.damage_factor
                                b.bullet.damage_min = b.bullet.damage_min + this.damage_buff
                                b.bullet.damage_max = b.bullet.damage_max + this.damage_buff
                                queue_insert(store, b)
                            end

                            while not U.animation_finished(this) do
                                if SU.hero_interrupted(this) then
                                    goto label_90_0
                                end

                                coroutine.yield()
                            end
                        end

                        SU.hero_gain_xp_from_skill(this, skill)
                        U.animation_start(this, a.animations[3], nil, store.tick_ts, false)

                        while not U.animation_finished(this) do
                            if SU.hero_interrupted(this) then
                                break
                            end

                            coroutine.yield()
                        end

                        goto label_90_0
                    end
                end

                if ready_to_use_skill(this.ultimate, store) then
                    local target = find_target_at_critical_moment(this, store, this.ranged.attacks[1].max_range, true,
                        true)

                    if target and target.pos and valid_twister_node_nearby(target.pos) then
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                        S:queue(this.sound_events.change_rally_point)
                        local e = E:create_entity(this.hero.skills.ultimate.controller_name)

                        e.level = this.hero.skills.ultimate.level
                        e.pos = V.vclone(target.pos)
                        e.owner = this
                        queue_insert(store, e)

                        this.ultimate.ts = store.tick_ts
                        SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
                    else
                        this.ultimate.ts = this.ultimate.ts + 1
                    end
                end

                brk, sta = SU.y_soldier_ranged_attacks(store, this)

                if brk then
                    goto label_90_0
                end

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta ~= A_NO_TARGET then
                    goto label_90_0
                end

                if SU.soldier_go_back_step(store, this) then
                    goto label_90_0
                end
                -- brk, sta = SU.y_soldier_ranged_attacks(store, this)

                -- if brk then
                --     -- block empty
                -- elseif SU.soldier_go_back_step(store, this) then
                --     -- block empty
                -- else
                SU.soldier_idle(store, this)
                SU.soldier_regen(store, this)
                -- end
            end

            ::label_90_0::

            coroutine.yield()
        end
    end

    scripts.fireball_arivan = {}

    function scripts.fireball_arivan.update(this, store)
        local b = this.bullet
        local mspeed = b.min_speed
        local target, ps

        S:queue(this.sound_events.summon)
        U.animation_start(this, "idle", nil, store.tick_ts, false)
        U.y_wait(store, this.idle_time)

        ps = E:create_entity(b.particles_name)
        ps.particle_system.track_id = this.id

        queue_insert(store, ps)
        S:queue(this.sound_events.travel)

        while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > 2 * (mspeed * store.tick_length) do
            coroutine.yield()

            mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
            mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
            b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
            this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length,
                this.pos.y + b.speed.y * store.tick_length
            this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

            if ps then
                ps.particle_system.emit_direction = this.render.sprites[1].r
            end
        end

        local targets = U.find_enemies_in_range(store.entities, b.to, 0, b.damage_radius, b.damage_flags, b.damage_bans)

        if targets then
            for _, target in pairs(targets) do
                local d = E:create_entity("damage")

                d.damage_type = b.damage_type
                d.value = math.ceil(U.frandom(b.damage_min, b.damage_max)) * b.damage_factor
                d.source_id = this.id
                d.target_id = target.id

                queue_damage(store, d)
            end
        end

        S:queue(this.sound_events.hit)

        if b.hit_fx then
            local fx = E:create_entity(b.hit_fx)

            fx.pos = V.vclone(b.to)
            fx.render.sprites[1].ts = store.tick_ts

            queue_insert(store, fx)
        end

        coroutine.yield()
        queue_remove(store, this)
    end

    scripts.aura_arivan_stone_dance = {}

    function scripts.aura_arivan_stone_dance.update(this, store)
        local rot_phase = 0
        local owner = store.entities[this.aura.source_id]

        if not owner then
            log.error("aura_arivan_stone_dance owner is missing.")
            queue_remove(store, this)
            return
        end

        while true do
            if owner.health.dead and #this.stones > 1 then
                for i = #this.stones, 1, -1 do
                    local stone = this.stones[i]
                    local fx = E:create_entity("fx_arivan_stone_explosion")

                    fx.pos = stone.pos
                    fx.render.sprites[1].ts = store.tick_ts

                    queue_insert(store, fx)
                    queue_remove(store, stone)
                    table.remove(this.stones, i)
                end
            end

            if this.shield_active then
                this.shield_active = false

                local s = this.render.sprites[1]

                s.hidden = false
                s.ts = store.tick_ts
                s.runs = 0
                s.flip_x = owner.render.sprites[1].flip_x
            end

            if store.tick_ts - this.aura.ts > fts(13) then
                rot_phase = rot_phase + this.rot_speed * store.tick_length
            end

            for i, t in ipairs(this.stones) do
                local a = (i * 2 * math.pi / this.max_stones + rot_phase) % (2 * math.pi)

                t.pos = U.point_on_ellipse(this.pos, this.rot_radius, a)
            end

            if #this.stones < 1 then
                owner.vis.bans = band(owner.vis.bans, bnot(this.owner_vis_bans))
            else
                owner.vis.bans = bor(owner.vis.bans, this.owner_vis_bans)
            end

            coroutine.yield()
        end
    end

    scripts.hero_arivan_ultimate = {}

    function scripts.hero_arivan_ultimate.update(this, store)
        local np = this.nav_path
        local nodes_step = this.aura.nodes_step
        local last_freeze_target
        local targets = U.find_enemies_in_paths(store.entities, this.pos, 0, this.aura.range_nodes, nil,
            this.aura.vis_flags, this.aura.vis_bans, true)

        if targets then
            local o = targets[1].origin

            np.pi, np.spi, np.ni = o[1], 1, o[3] + 3
        else
            local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_TWISTER)

            if #nodes < 1 then
                coroutine.yield()

                goto label_95_1
            end

            local o = nodes[1]

            np.pi, np.spi, np.ni = o[1], 1, o[3]
        end

        this.pos = P:node_pos(np)

        U.y_animation_play(this, "start", nil, store.tick_ts)
        U.animation_start(this, "travel", nil, store.tick_ts, true)

        this.aura.ts = store.tick_ts

        while true do
            local next_pos = P:node_pos(np.pi, np.spi, np.ni + nodes_step)

            if P:is_node_valid(np.pi, np.ni + nodes_step, NF_TWISTER) and
                band(GR:cell_type(next_pos.x, next_pos.y), TERRAIN_CLIFF) == 0 then
                np.ni = np.ni + nodes_step
            end

            np.spi = np.spi == 2 and 3 or 2

            U.set_destination(this, P:node_pos(np.pi, np.spi, np.ni))

            while not this.motion.arrived do
                if store.tick_ts - this.aura.ts > this.aura.duration or
                    band(GR:cell_type(this.pos.x, this.pos.y), TERRAIN_CLIFF) ~= 0 then
                    goto label_95_0
                end

                U.walk(this, store.tick_length)

                for ai, a in ipairs(this.timed_attacks.list) do
                    if store.tick_ts - a.ts < a.cooldown then
                        -- block empty
                    else
                        a.ts = store.tick_ts

                        if a.chance and (a.chance == 0 or math.random() >= a.chance) then
                            -- block empty
                        else
                            local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.max_range,
                                a.vis_flags, a.vis_bans)

                            if not targets then
                                if ai == 3 then
                                    last_freeze_target = nil
                                end
                            elseif ai == 1 then
                                for _, target in pairs(targets) do
                                    local mod = E:create_entity(a.mod)

                                    mod.modifier.target_id = target.id

                                    queue_insert(store, mod)
                                end
                            elseif ai == 2 then
                                for _, target in pairs(targets) do
                                    local d = E:create_entity("damage")

                                    d.damage_type = a.damage_type
                                    d.value = a.damage_max
                                    d.source_id = this.id
                                    d.target_id = target.id

                                    queue_damage(store, d)
                                end
                            elseif ai == 3 then
                                local mod = E:create_entity(a.mod)

                                mod.modifier.target_id = targets[1].id

                                queue_insert(store, mod)

                                last_freeze_target = targets[1].id
                            elseif a.type == "bullet" then
                                if #targets > 1 and last_freeze_target then
                                    table.removeobject(targets, last_freeze_target)
                                end

                                local target = table.random(targets)
                                local b = E:create_entity(a.bullet)

                                b.pos = V.vclone(this.pos)
                                b.pos.x = b.pos.x + (target.pos.x > this.pos.x and 1 or -1) * a.bullet_start_offset[1].x
                                b.pos.y = b.pos.y + a.bullet_start_offset[1].y
                                b.bullet.from = V.vclone(b.pos)
                                b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x,
                                    target.pos.y + target.unit.hit_offset.y)
                                b.bullet.target_id = target.id
                                b.bullet.source_id = this.id

                                queue_insert(store, b)
                            end
                        end
                    end
                end

                coroutine.yield()
            end
        end

        ::label_95_0::

        U.y_animation_play(this, "end", nil, store.tick_ts)

        ::label_95_1::

        queue_remove(store, this)
    end

    scripts.hero_phoenix = {}

    function scripts.hero_phoenix.get_info(this)
        local b = E:get_template(this.ranged.attacks[1].bullet)
        local ba = E:get_template(b.bullet.hit_payload)
        local min, max = ba.aura.damage_min, ba.aura.damage_max

        return {
            type = STATS_TYPE_SOLDIER,
            hp = this.health.hp,
            hp_max = this.health.hp_max,
            ranged_damage_min = min,
            ranged_damage_max = max,
            damage_type = ba.aura.damage_type,
            armor = this.health.armor,
            respawn = this.health.dead_lifetime
        }
    end

    function scripts.hero_phoenix.level_up(this, store, initiaal)
        local hl, ls = level_up_basic(this)

        local b = E:get_template(this.ranged.attacks[1].bullet)
        local ba = E:get_template(b.bullet.hit_payload)

        ba.aura.damage_max = ls.ranged_damage_max[hl]
        ba.aura.damage_min = ls.ranged_damage_min[hl]

        local a = E:get_template("aura_phoenix_egg")

        a.custom_attack.damage_max = ls.egg_explosion_damage_max[hl]
        a.custom_attack.damage_min = ls.egg_explosion_damage_min[hl]

        local m = E:get_template(a.aura.mod)

        m.dps.damage_min = ls.egg_damage[hl]
        m.dps.damage_max = ls.egg_damage[hl]

        upgrade_skill(this, "inmolate", function(this, s)
            local sd = this.selfdestruct

            sd.disabled = nil
            sd.damage_min = s.damage_min[s.level]
            sd.damage_max = s.damage_max[s.level]

            local a = this.timed_attacks.list[1]

            a.disabled = nil
        end)

        upgrade_skill(this, "purification", function(this, s)
            local au = E:get_template("aura_phoenix_purification")
            au.aura.targets_per_cycle = s.max_targets[s.evel]

            for _, e in pairs(store.entities) do
                if e.template_name == "aura_phoenix_purification" then
                    e.aura.targets_per_cycle = s.max_targets[s.level]
                    break
                end
            end

            local b = E:get_template("missile_phoenix_small")
            b.bullet.damage_max = s.damage_max[s.level]
            b.bullet.damage_min = s.damage_min[s.level]
        end)

        upgrade_skill(this, "blazing_offspring", function(this, s)
            local a = this.ranged.attacks[2]

            a.disabled = nil
            a.shoot_times = {}

            for i = 1, s.count[s.level] do
                table.insert(a.shoot_times, fts(4))
            end

            local b = E:get_template(a.bullet)

            b.bullet.damage_max = s.damage_max[s.level]
            b.bullet.damage_min = s.damage_min[s.level]
        end)

        upgrade_skill(this, "flaming_path", function(this, s)
            local a = this.timed_attacks.list[2]

            a.disabled = nil

            local m = E:get_template(a.mod)

            m.custom_attack.damage = s.damage[s.level]
        end)

        upgrade_skill(this, "ultimate", function(this, s)
            this.ultimate.disabled = nil
            local au = E:get_template(s.controller_name)

            au.aura.damage_max = s.damage_max[s.level]
            au.aura.damage_min = s.damage_min[s.level]
        end)

        this.health.hp = this.health.hp_max
    end

    function scripts.hero_phoenix.insert(this, store)
        if not scripts.hero_basic.insert(this, store) then
            return false
        end

        local a = E:create_entity("aura_phoenix_purification")

        a.aura.source_id = this.id
        a.aura.ts = store.tick_ts
        a.pos = this.pos

        queue_insert(store, a)

        return true
    end

    function scripts.hero_phoenix.update(this, store)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta

        U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)

        while true do
            if h.dead then
                local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)
                local respawn_point

                if #nodes < 1 then
                    log.debug("hero_phoenix: could not find nearest node to place egg")

                    respawn_point = store.level.custom_spawn_pos or store.level.locations.exits[1].pos
                    this.selfdestruct.disabled = true
                else
                    local pi, spi, ni, dist = unpack(nodes[1])

                    respawn_point = P:node_pos(pi, spi, ni)

                    if dist > 30 then
                        log.debug("hero_phoenix: too far from nearest path for inmolate")

                        this.selfdestruct.disabled = true
                    end
                end

                local egg = E:create_entity("aura_phoenix_egg")

                if this.selfdestruct.disabled then
                    this.hero.respawn_point = respawn_point
                    egg.pos = V.vclone(respawn_point)
                    egg.show_delay = fts(15)
                else
                    egg.pos = V.vclone(this.pos)
                    egg.show_delay = fts(28)
                end

                queue_insert(store, egg)
                U.sprites_hide(this, 2, 2)
                SU.y_hero_death_and_respawn(store, this)

                this.selfdestruct.disabled = this.hero.skills.inmolate.level < 1

                U.sprites_show(this, 2, 2)

                this.hero.respawn_point = nil

                U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil,
                    true)
            end

            while this.nav_rally.new do
                SU.y_hero_new_rally(store, this)
            end

            if SU.hero_level_up(store, this) then
                -- block empty
            end

            if ready_to_use_skill(this.ultimate, store) then
                local targets = U.find_enemies_in_range(store.entities, this.pos, 0, this.ranged.attacks[1].max_range,
                    this.ranged.attacks[1].vis_flags, this.ranged.attacks[1].vis_bans)
                if targets and valid_land_node_nearby(this.pos) then
                    S:queue(this.sound_events.change_rally_point)
                    local e = E:create_entity(this.hero.skills.ultimate.controller_name)

                    e.level = this.hero.skills.ultimate.level
                    e.pos = V.vclone(this.pos)
                    e.owner = this
                    e.damage_factor = this.unit.damage_factor

                    queue_insert(store, e)

                    this.ultimate.ts = store.tick_ts
                    SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
                else
                    this.ultimate.ts = this.ultimate.ts + 1
                end
            end

            a = this.timed_attacks.list[1]
            skill = this.hero.skills.inmolate

            if ready_to_use_skill(a, store) then
                local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

                if not targets or #targets < a.min_count then
                    SU.delay_attack(store, a, 0.16666666666666666)
                else
                    a.ts = store.tick_ts
                    h.dead = true
                    h.hp = 0
                    this.health_bar.hidden = true

                    goto label_190_0
                end
            end

            a = this.timed_attacks.list[2]
            skill = this.hero.skills.flaming_path

            if ready_to_use_skill(a, store) then
                local targets = U.find_towers_in_range(store.entities, this.pos, a, function(e, o)
                    local enemies = U.find_enemies_in_range(store.entities, e.pos, 0, a.enemies_range,
                        a.enemies_vis_flags, a.enemies_vis_bans)

                    return e.tower.can_be_mod and enemies and #enemies >= a.enemies_min_count
                end)

                if not targets then
                    SU.delay_attack(store, a, 0.16666666666666666)
                else
                    S:queue(a.sound, a.sound_args)
                    U.animation_start(this, a.animation, nil, store.tick_ts)

                    if SU.y_hero_wait(store, this, a.hit_time) then
                        -- block empty
                    else
                        a.ts = store.tick_ts

                        SU.hero_gain_xp_from_skill(this, skill)
                        table.sort(targets, function(e1, e2)
                            return V.dist(e1.pos.x, e1.pos.y, this.pos.x, this.pos.y) <
                                       V.dist(e2.pos.x, e2.pos.y, this.pos.x, this.pos.y)
                        end)

                        for i, target in ipairs(targets) do
                            if i > a.max_count then
                                break
                            end

                            local mod = E:create_entity(a.mod)

                            mod.modifier.target_id = target.id
                            mod.modifier.source_id = this.id
                            mod.pos.x, mod.pos.y = target.pos.x, target.pos.y

                            queue_insert(store, mod)
                        end

                        SU.y_hero_animation_wait(this)
                    end

                    goto label_190_0
                end
            end

            brk, sta = SU.y_soldier_ranged_attacks(store, this)

            if brk then
                -- block empty
            else
                SU.soldier_idle(store, this)
                SU.soldier_regen(store, this)
            end

            ::label_190_0::

            coroutine.yield()
        end
    end

    scripts.hero_phoenix_ultimate = {}

    function scripts.hero_phoenix_ultimate.update(this, store)
        local a = this.aura

        a.ts = store.tick_ts

        local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, {1, 2, 3}, true)

        if #nodes < 1 then
            log.error("hero_phoenix_ultimate: could not find valid node")
            queue_remove(store, this)

            return
        end

        local node = {
            pi = nodes[1][1],
            spi = nodes[1][2],
            ni = nodes[1][3]
        }

        this.pos = P:node_pos(node.pi, node.spi, node.ni)

        U.y_animation_play(this, "place", nil, store.tick_ts)
        U.y_wait(store, this.activate_delay)
        S:queue(this.sound_events.activate)
        U.y_animation_play(this, "activate", nil, store.tick_ts)

        this.tween.disabled = nil

        local targets

        while store.tick_ts - a.ts < a.duration and not targets do
            U.y_wait(store, 0.2)
            coroutine.yield()

            targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.radius, a.vis_flags, a.vis_bans)
        end

        this.tween.disabled = true

        U.y_ease_key(store, this.render.sprites[2], "alpha", this.render.sprites[2].alpha, 255, 0.2)
        SU.insert_sprite(store, a.hit_fx, this.pos)
        SU.insert_sprite(store, a.hit_decal, this.pos)

        targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.radius, a.vis_flags, a.damage_vis_bans)

        if targets then
            for _, t in pairs(targets) do
                local d = E:create_entity("damage")

                d.value = math.random(a.damage_min, a.damage_max) * this.damage_factor
                d.damage_type = a.damage_type
                d.target_id = t.id
                d.source_id = this.id

                queue_damage(store, d)
            end
        end

        S:queue(this.sound_events.explode)
        queue_remove(store, this)
    end
    scripts.hero_bravebark = {}

    function scripts.hero_bravebark.level_up(this, store)
        local hl, ls = level_up_basic(this)

        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

        upgrade_skill(this, "rootspikes", function(this, s)
            local a = this.timed_attacks.list[1]

            a.disabled = nil
            a.ts = store.tick_ts
            a.damage_max = s.damage_max[s.level]
            a.damage_min = s.damage_min[s.level]
        end)

        upgrade_skill(this, "oakseeds", function(this, s)
            local a = this.timed_attacks.list[2]

            a.disabled = nil
            a.ts = store.tick_ts

            local st = E:get_template(a.entity)

            st.health.hp_max = s.soldier_hp_max[s.level]
            st.melee.attacks[1].damage_max = s.soldier_damage_max[s.level]
            st.melee.attacks[1].damage_min = s.soldier_damage_min[s.level]
        end)

        upgrade_skill(this, "branchball", function(this, s)
            local a = this.melee.attacks[2]

            a.hp_max = s.hp_max[s.level]
            a.disabled = nil
            a.ts = store.tick_ts
        end)
        upgrade_skill(this, "springsap", function(this, s)
            local a = this.springsap

            a.disabled = nil
            a.ts = store.tick_ts

            local aura = E:get_template(a.aura)

            aura.aura.duration = s.duration[s.level]

            local mod = E:get_template(aura.aura.mod)

            mod.hps.heal_min = s.hp_per_cycle[s.level]
            mod.hps.heal_max = s.hp_per_cycle[s.level]
        end)

        upgrade_skill(this, "ultimate", function(this, s)
            this.ultimate.disabled = nil
            local u = E:get_template("hero_bravebark_ultimate")

            u.count = s.count[s.level]
            u.damage = s.damage[s.level]
        end)

        this.health.hp = this.health.hp_max
    end

    function scripts.hero_bravebark.update(this, store)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta

        local function spawn_spikes(count, center, radius, angle, delay, scale)
            for i = 1, count do
                local p = U.point_on_ellipse(center, radius - math.random(0, 5), angle + i * 2 * math.pi / count)
                local e = E:create_entity("decal_bravebark_rootspike")

                e.pos.x, e.pos.y = p.x, p.y
                e.delay = delay
                e.scale = scale

                queue_insert(store, e)
            end
        end

        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_119_0
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                a = this.springsap
                skill = this.hero.skills.springsap

                if ready_to_use_skill(a, store) and
                    soldiers_around_need_heal(this, store, a.trigger_hp_factor, a.radius) then
                    a.ts = store.tick_ts

                    SU.hero_gain_xp_from_skill(this, skill)
                    S:queue(a.sound)
                    U.y_animation_play(this, a.animations[1], nil, store.tick_ts)

                    local aura = E:create_entity(a.aura)

                    aura.pos.x, aura.pos.y = this.pos.x, this.pos.y
                    aura.tween.ts = store.tick_ts
                    aura.aura.radius = a.radius
                    queue_insert(store, aura)
                    U.animation_start(this, a.animations[2], nil, store.tick_ts, true)

                    while store.tick_ts - a.ts <= aura.aura.duration do
                        if SU.hero_interrupted(this) then
                            queue_remove(store, aura)

                            break
                        end

                        coroutine.yield()
                    end

                    U.y_animation_play(this, a.animations[3], nil, store.tick_ts)

                    a.ts = store.tick_ts

                    goto label_119_0
                end

                a = this.timed_attacks.list[2]
                skill = this.hero.skills.oakseeds

                if ready_to_use_skill(a, store) then
                    local target = U.find_foremost_enemy(store.entities, this.pos, 0, a.max_range, 0.5, a.vis_flags,
                        a.vis_bans)

                    if not target then
                        SU.delay_attack(store, a, 0.3333333333333333)
                    else
                        local node_offset = P:predict_enemy_node_advance(target, 0.5)
                        local ni = target.nav_path.ni + node_offset

                        S:queue(a.sound)

                        local af = target.pos.x < this.pos.x

                        U.animation_start(this, a.animation, af, store.tick_ts)

                        if U.y_wait(store, a.spawn_time, function()
                            return SU.hero_interrupted(this)
                        end) then
                            -- block empty
                        else
                            a.ts = store.tick_ts

                            SU.hero_gain_xp_from_skill(this, skill)

                            for i = 1, a.count do
                                ni = ni + math.random(4, 6)

                                if not P:is_node_valid(target.nav_path.pi, ni) then
                                    -- block empty
                                else
                                    local e = E:create_entity(a.entity)

                                    e.pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, ni)
                                    e.nav_rally.center = V.vclone(e.pos)
                                    e.nav_rally.pos = V.vclone(e.pos)
                                    e.melee.attacks[1].xp_dest_id = this.id

                                    local b = E:create_entity(a.bullet)

                                    b.pos.x, b.pos.y = this.pos.x + (af and -1 or 1) * a.spawn_offset.x,
                                        this.pos.y + a.spawn_offset.y
                                    b.bullet.from = V.vclone(b.pos)
                                    b.bullet.to = V.vclone(e.pos)
                                    b.bullet.hit_payload = e

                                    queue_insert(store, b)
                                end
                            end

                            SU.y_hero_animation_wait(this)

                            goto label_119_0
                        end
                    end
                end

                a = this.timed_attacks.list[1]
                skill = this.hero.skills.rootspikes

                if ready_to_use_skill(a, store) then
                    local triggers = U.find_enemies_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags,
                        a.vis_bans)

                    if not triggers or #triggers < a.trigger_count then
                        SU.delay_attack(store, a, 0.13333333333333333)
                    else
                        S:queue(a.sound)

                        local af = triggers[1].pos.x < this.pos.x

                        U.animation_start(this, a.animation, af, store.tick_ts)

                        if U.y_wait(store, a.hit_time, function()
                            return SU.hero_interrupted(this)
                        end) then
                            -- block empty
                        else
                            local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.damage_radius,
                                a.vis_flags, a.vis_bans)

                            if not targets then
                                -- block empty
                            else
                                a.ts = store.tick_ts

                                SU.hero_gain_xp_from_skill(this, skill)

                                local tpos = V.vclone(targets[1].pos)
                                local hit_center = V.v(this.pos.x + a.hit_offset.x * (af and -1 or 1),
                                    this.pos.y + a.hit_offset.y)
                                local decal = E:create_entity(a.hit_decal)

                                decal.pos.x, decal.pos.y = hit_center.x, hit_center.y
                                decal.tween.ts = store.tick_ts

                                queue_insert(store, decal)
                                spawn_spikes(7, hit_center, a.decal_range / 2, 0, 0, 1)
                                spawn_spikes(9, hit_center, a.decal_range / 1.25, 0, 0.07, 0.75)
                                spawn_spikes(13, hit_center, a.decal_range, math.pi * 2 / 26, 0.17, 0.5)

                                for _, target in pairs(targets) do
                                    local d = SU.create_attack_damage(a, target.id, this)

                                    queue_damage(store, d)
                                end

                                SU.y_hero_animation_wait(this)

                                goto label_119_0
                            end
                        end
                    end
                end

                if ready_to_use_skill(this.ultimate, store) then
                    local target = find_target_at_critical_moment(this, store, this.ultimate.range, true)

                    if target and target.pos and valid_land_node_nearby(target.pos) then
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                        S:queue(this.sound_events.change_rally_point)
                        local e = E:create_entity(this.hero.skills.ultimate.controller_name)
                        e.pos = V.vclone(target.pos)
                        e.owner = this
                        e.damage_factor = this.unit.damage_factor
                        queue_insert(store, e)

                        this.ultimate.ts = store.tick_ts
                        SU.hero_gain_xp_from_skill(this, this.ultimate)
                    else
                        this.ultimate.ts = this.ultimate.ts + 1
                    end
                end
                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta ~= A_NO_TARGET then
                    -- block empty
                elseif SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end
            end

            ::label_119_0::

            coroutine.yield()
        end
    end

    scripts.hero_bravebark_ultimate = {}

    function scripts.hero_bravebark_ultimate.update(this, store)
        local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_POWER_3)

        if #nodes < 1 then
            log.error("hero_bravebark_ultimate: could not find valid node")
            queue_remove(store, this)

            return
        end

        local node_f = {
            pi = nodes[1][1],
            spi = math.random(1, 3),
            ni = nodes[1][3]
        }
        local node_b = {
            pi = nodes[1][1],
            spi = math.random(1, 3),
            ni = nodes[1][3]
        }
        local count = this.count
        local dir = 1
        local node

        for i = 1, 2 * count do
            node = dir == 1 and node_f or node_b

            local node_pos = P:node_pos(node.pi, node.spi, node.ni)

            if P:is_node_valid(node.pi, node.ni) and not GR:cell_is(node_pos.x, node_pos.y, TERRAIN_FAERIE) then
                local nni = node.ni + dir * math.random(this.sep_nodes_min, this.sep_nodes_max - 1)
                local nspi = km.zmod(node.spi + math.random(1, 2), 3)

                node.spi, node.ni = nspi, nni

                local e = E:create_entity(this.decal)

                e.render.sprites[1].prefix = e.render.sprites[1].prefix .. math.random(1, 3)
                e.pos = node_pos
                e.render.sprites[1].ts = store.tick_ts

                queue_insert(store, e)

                local targets = U.find_enemies_in_range(store.entities, e.pos, 0, this.damage_radius, this.vis_flags,
                    this.vis_bans)

                if targets then
                    for _, target in pairs(targets) do
                        local m = E:create_entity(this.mod)

                        m.modifier.target_id = target.id
                        m.modifier.source_id = this.id

                        queue_insert(store, m)

                        local d = E:create_entity("damage")

                        d.value = this.damage * this.damage_factor
                        d.source_id = this.id
                        d.target_id = target.id

                        queue_damage(store, d)
                    end
                end

                if count % 2 == 0 then
                    U.y_wait(store, U.frandom(this.show_delay_min, this.show_delay_max))
                end

                count = count - 1
            end

            if count <= 0 then
                break
            end

            dir = -1 * dir
        end

        queue_remove(store, this)
    end
    scripts.hero_catha = {}

    function scripts.hero_catha.level_up(this, store)
        local hl, ls = level_up_basic(this)
        local hl = this.hero.level
        local ls = this.hero.level_stats

        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

        local bt = E:get_template(this.ranged.attacks[1].bullet)
        bt.bullet.damage_min = ls.ranged_damage_min[hl]
        bt.bullet.damage_max = ls.ranged_damage_max[hl]
        bt = E:get_template("knife_soldier_catha")
        bt.bullet.damage_min = ls.ranged_damage_min[hl]
        bt.bullet.damage_max = ls.ranged_damage_max[hl]

        upgrade_skill(this, "soul", function(this, s)
            local a = this.timed_attacks.list[2]

            a.disabled = nil

            local m = E:get_template(a.mod)

            m.hps.heal_min = s.heal_hp[s.level]
            m.hps.heal_max = s.heal_hp[s.level]
        end)
        upgrade_skill(this, "tale", function(this, s)
            local a = this.timed_attacks.list[3]

            a.disabled = nil
            a.max_count = s.max_count[s.level]

            local e = E:get_template(a.entity)

            e.health.hp_max = s.hp_max[s.level]
        end)
        upgrade_skill(this, "fury", function(this, s)
            local a = this.timed_attacks.list[1]

            a.disabled = nil

            local b = E:get_template("catha_fury")

            b.bullet.damage_min = s.damage_min[s.level]
            b.bullet.damage_max = s.damage_max[s.level]
        end)

        upgrade_skill(this, "curse", function(this, s)
            local m = E:get_template("mod_catha_curse")

            m.chance = s.chance[s.level]
            m.modifier.duration = s.duration[s.level]
            this.melee.attacks[1].mod = "mod_catha_curse"

            local b = E:get_template("catha_fury")

            b.bullet.mod = "mod_catha_curse"

            local b = E:get_template("knife_catha")

            b.bullet.mod = "mod_catha_curse"

            local m = E:get_template("mod_soldier_catha_curse")

            m.chance = s.chance[s.level] * s.chance_factor_tale
            m.modifier.duration = s.duration[s.level]

            local b = E:get_template("knife_soldier_catha")

            b.bullet.mod = "mod_soldier_catha_curse"
        end)
        upgrade_skill(this, "ultimate", function(this, s)
            this.ultimate.disabled = nil
            local u = E:get_template("hero_catha_ultimate")

            u.duration = s.duration[s.level]
            u.duration_boss = s.duration_boss[s.level]
            u.range = s.range[s.level]
            this.ultimate.range = s.range[s.level]
        end)

        this.health.hp = this.health.hp_max
    end

    function scripts.hero_catha.update(this, store)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta

        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_133_0
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                a = this.timed_attacks.list[1]
                skill = this.hero.skills.fury

                if ready_to_use_skill(a, store) then
                    local targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range,
                        a.vis_flags, a.vis_bans)

                    if not targets then
                        SU.delay_attack(store, a, 0.3333333333333333)
                    else
                        S:queue(a.sound)
                        U.animation_start(this, a.animation, nil, store.tick_ts)

                        if U.y_wait(store, a.shoot_time, function()
                            return SU.hero_interrupted(this)
                        end) then
                            -- block empty
                        else
                            a.ts = store.tick_ts

                            SU.hero_gain_xp_from_skill(this, skill)

                            local targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range,
                                a.vis_flags, a.vis_bans)

                            if targets then
                                for i = 1, skill.count[skill.level] do
                                    local target = table.random(targets)
                                    local b = E:create_entity(a.bullet)

                                    b.pos.x, b.pos.y = this.pos.x, this.pos.y
                                    b.bullet.target_id = target.id
                                    b.bullet.source_id = this.id
                                    b.bullet.level = a.level

                                    queue_insert(store, b)
                                end
                            end

                            SU.y_hero_animation_wait(this)

                            a.ts = store.tick_ts

                            goto label_133_0
                        end
                    end
                end

                a = this.timed_attacks.list[2]
                skill = this.hero.skills.soul

                if ready_to_use_skill(a, store) then
                    local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags,
                        a.vis_bans, function(e)
                            return e.health.hp / e.health.hp_max < a.max_hp_factor and
                                       not table.contains(a.excluded_templates, e.template_name)
                        end)

                    if not targets then
                        SU.delay_attack(store, a, 0.3333333333333333)
                    else
                        S:queue(a.sound)
                        U.animation_start(this, a.animation, nil, store.tick_ts)

                        if U.y_wait(store, a.shoot_time, function()
                            return SU.hero_interrupted(this)
                        end) then
                            -- block empty
                        else
                            a.ts = store.tick_ts

                            SU.hero_gain_xp_from_skill(this, skill)

                            local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, a.max_range,
                                a.vis_flags, a.vis_bans, function(e)
                                    return not table.contains(a.excluded_templates, e.template_name)
                                end)

                            if targets then
                                table.sort(targets, function(e1, e2)
                                    return e1.health.hp < e2.health.hp
                                end)

                                for i = 1, math.min(#targets, a.max_count) do
                                    local target = targets[i]
                                    local m = E:create_entity(a.mod)

                                    m.modifier.source_id = this.id
                                    m.modifier.target_id = target.id

                                    queue_insert(store, m)
                                end
                            end

                            local fx = E:create_entity(a.shoot_fx)

                            fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
                            fx.render.sprites[1].ts = store.tick_ts

                            queue_insert(store, fx)
                            SU.y_hero_animation_wait(this)

                            a.ts = store.tick_ts

                            goto label_133_0
                        end
                    end
                end

                a = this.timed_attacks.list[3]
                skill = this.hero.skills.tale

                if ready_to_use_skill(a, store) then
                    local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags,
                        a.vis_bans)

                    if not targets then
                        SU.delay_attack(store, a, 0.3333333333333333)
                    else
                        S:queue(a.sound, a.sound_args)
                        U.animation_start(this, a.animation, nil, store.tick_ts)

                        if U.y_wait(store, a.spawn_time, function()
                            return SU.hero_interrupted(this)
                        end) then
                            -- block empty
                        else
                            a.ts = store.tick_ts

                            SU.hero_gain_xp_from_skill(this, skill)

                            for i = 1, a.max_count do
                                local o = a.entity_offsets[i]
                                local e = E:create_entity(a.entity)

                                e.pos.x, e.pos.y = this.pos.x + o.x, this.pos.y + o.y
                                e.nav_rally.center = V.vclone(e.pos)
                                e.nav_rally.pos = V.vclone(e.pos)
                                e.tween.ts = store.tick_ts
                                e.tween.props[1].keys[1][2].x = -o.x
                                e.tween.props[1].keys[1][2].y = -o.y
                                e.render.sprites[1].flip_x = this.render.sprites[1].flip_x
                                e.owner = this

                                queue_insert(store, e)
                            end

                            SU.y_hero_animation_wait(this)

                            a.ts = store.tick_ts

                            goto label_133_0
                        end
                    end
                end

                if ready_to_use_skill(this.ultimate, store) then
                    local target = find_target_at_critical_moment(this, store, this.ranged.attacks[1].max_range)
                    local target_found = false
                    if target then
                        target = U.find_foremost_enemy_with_max_coverage(store.entities, this.pos, 0,
                            this.ranged.attacks[1].max_range, 0, bor(F_RANGED, F_MOD), 0, nil, nil, this.ultimate.range)
                        if target and target.pos and valid_land_node_nearby(target.pos) then
                            target_found = true
                        end
                    end
                    if target_found then
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                        S:queue(this.sound_events.change_rally_point)
                        local e = E:create_entity(this.hero.skills.ultimate.controller_name)

                        e.pos = V.vclone(target.pos)

                        queue_insert(store, e)

                        this.ultimate.ts = store.tick_ts
                        SU.hero_gain_xp_from_skill(this, this.ultimate)
                    else
                        this.ultimate.ts = this.ultimate.ts + 1
                    end
                end
                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta ~= A_NO_TARGET then
                    -- block empty
                else
                    brk, sta = SU.y_soldier_ranged_attacks(store, this)

                    if brk then
                        -- block empty
                    elseif SU.soldier_go_back_step(store, this) then
                        -- block empty
                    else
                        SU.soldier_idle(store, this)
                        SU.soldier_regen(store, this)
                    end
                end
            end

            ::label_133_0::

            coroutine.yield()
        end
    end

    scripts.hero_catha_ultimate = {}

    function scripts.hero_catha_ultimate.update(this, store)
        U.animation_start(this, nil, nil, store.tick_ts, false)
        U.y_wait(store, this.hit_time)

        local fx = E:create_entity(this.hit_fx)

        fx.pos.x, fx.pos.y = this.pos.x, this.pos.y

        U.animation_start(fx, nil, nil, store.tick_ts, false)
        queue_insert(store, fx)

        local targets = U.find_enemies_in_range(store.entities, this.pos, 0, this.range, this.vis_flags, this.vis_bans,
            function(e)
                return U.flag_has(e.vis.flags, F_BOSS) or not U.flag_has(e.vis.bans, F_STUN)
            end)

        if targets then
            for _, target in pairs(targets) do
                local m = E:create_entity(this.mod)

                m.modifier.source_id = this.id
                m.modifier.target_id = target.id

                if U.flag_has(target.vis.flags, F_BOSS) then
                    m.modifier.duration = this.duration_boss
                    m.modifier.vis_flags = U.flag_clear(m.modifier.vis_flags, F_STUN)
                else
                    m.modifier.duration = this.duration
                end

                queue_insert(store, m)
            end
        end

        U.y_animation_wait(this)
        queue_remove(store, this)
    end

    scripts.hero_lilith = {}

    function scripts.hero_lilith.level_up(this, store)
        local hl, ls = level_up_basic(this)

        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
        this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

        local bt = E:get_template(this.ranged.attacks[1].bullet)

        bt.bullet.damage_min = ls.ranged_damage_min[hl]
        bt.bullet.damage_max = ls.ranged_damage_max[hl]

        upgrade_skill(this, "reapers_harvest", function(this, s)
            local a = this.melee.attacks[3]
            a.disabled = nil
            a.damage_min = s.damage[s.level]
            a.damage_max = s.damage[s.level]
            a = this.melee.attacks[4]
            a.disabled = nil
            a.damage_min = s.damage[s.level]
            a.damage_max = s.damage[s.level]
            a.chance = s.instakill_chance[s.level]
            a.origin_chance = s.instakill_chance[s.level]
        end)
        upgrade_skill(this, "soul_eater", function(this, s)
            local m = E:get_template("mod_lilith_soul_eater_damage_factor")

            m.soul_eater_factor = s.damage_factor[s.level]
        end)

        upgrade_skill(this, "infernal_wheel", function(this, s)
            local a = this.timed_attacks.list[1]

            a.disabled = nil

            local au = E:get_template(a.bullet)
            local m = E:get_template(au.aura.mod)

            m.dps.damage_min = s.damage[s.level]
            m.dps.damage_max = s.damage[s.level]
        end)

        upgrade_skill(this, "resurrection", function(this, s)
            local a = this.revive

            a.disabled = nil
            a.chance = s.chance[s.level]
        end)
        upgrade_skill(this, "ultimate", function(this, s)
            this.ultimate.disabled = nil
            local u = E:get_template(s.controller_name)

            u.angel_count = s.angel_count[s.level]

            local e = E:get_template(u.angel_entity)

            e.melee.attacks[1].damage_max = s.angel_damage[s.level] * 2
            e.melee.attacks[1].damage_min = s.angel_damage[s.level] * 2

            local b = E:get_template(u.meteor_bullet)

            b.bullet.damage_max = s.meteor_damage[s.level]
        end)

        this.health.hp = this.health.hp_max
    end

    function scripts.hero_lilith.insert(this, store)
        scripts.hero_basic.insert(this, store)

        local a = E:create_entity("aura_lilith_soul_eater")

        a.aura.source_id = this.id
        a.aura.ts = store.tick_ts
        a.pos = this.pos
        queue_insert(store, a)

        return true
    end

    function scripts.hero_lilith.update(this, store)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta

        this.health_bar.hidden = false
        local function skill_come_into_cooldown(skill_attack, is_ultimate)
            if is_ultimate then
                skill_attack.ts = store.tick_ts - km.clamp(0,1,this.revive.protect) * skill_attack.cooldown * 0.2
            else
                skill_attack.ts = store.tick_ts - km.clamp(0,1,this.revive.protect) * skill_attack.cooldown * 0.4
            end
        end
        local function inc_instakill_chance()
            this.melee.attacks[4].chance = this.melee.attacks[4].origin_chance + 0.2 * km.clamp(0, 1, this.revive.protect)
        end
        local function update_color()
            local revive_rate = km.clamp(0, 1, this.revive.protect) * 100
            this.render.sprites[1].alpha = 155 + revive_rate
            this.render.sprites[1].color[3] = 255 - revive_rate
        end
        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

        while true do
            if h.dead then
                local r = this.revive
                local chance_pass = math.random() < (this.revive.chance + this.revive.protect)

                if not this.revive.disabled and
                    not U.flag_has(h.last_damage_types, bor(DAMAGE_EAT, DAMAGE_HOST, DAMAGE_DISINTEGRATE)) and
                    chance_pass then
                    h.ignore_damage = true
                    h.dead = false
                    h.hp = h.hp_max

                    for _, s in pairs(this.render.sprites) do
                        s.hidden = false
                    end

                    S:queue(this.revive.sound)
                    U.y_animation_play(this, this.revive.animation, nil, store.tick_ts, 1)

                    this.health_bar.hidden = false
                    this.ui.can_click = true
                    h.ignore_damage = nil
                    this.revive.protect = this.revive.protect * 0.5
                    SU.hero_gain_xp_from_skill(this, this.hero.skills.resurrection)
                    this.melee.attacks[3].ts = 0
                    this.melee.attacks[4].ts = 0
                    this.timed_attacks.list[1].ts = 0
                else
                    SU.y_hero_death_and_respawn(store, this)
                end

                this.revive.ts = store.tick_ts
            end
            scripts.soldier_revive_resist(this, store)
            inc_instakill_chance()
            update_color()
            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_167_0
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                a = this.timed_attacks.list[1]
                skill = this.hero.skills.infernal_wheel

                if ready_to_use_skill(a, store) then
                    local target = U.find_random_enemy(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

                    if not target then
                        SU.delay_attack(store, a, 0.13333333333333333)
                    else
                        S:queue(a.sound)
                        U.animation_start(this, a.animation, nil, store.tick_ts)

                        if SU.y_hero_wait(store, this, a.shoot_time) then
                            goto label_167_0
                        end

                        SU.hero_gain_xp_from_skill(this, skill)

                        skill_come_into_cooldown(a)

                        local pos
                        local nodes = P:nearest_nodes(target.pos.x, target.pos.y, nil, nil, true)

                        if #nodes == 0 then
                            pos = V.vclone(this.pos)
                        else
                            pos = P:node_pos(nodes[1][1], 1, nodes[1][3])
                        end

                        local b = E:create_entity(a.bullet)

                        b.pos.x, b.pos.y = pos.x, pos.y
                        b.aura.ts = store.tick_ts

                        queue_insert(store, b)
                        SU.y_hero_animation_wait(this)

                        goto label_167_0
                    end
                end

                if ready_to_use_skill(this.ultimate, store) then
                    local target, target_num = find_target_at_critical_moment(this, store, this.ranged.attacks[1].max_range)

                    if target and target.pos and valid_land_node_nearby(target.pos) then
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                        S:queue(this.sound_events.change_rally_point)
                        local e = E:create_entity(this.hero.skills.ultimate.controller_name)

                        e.pos = V.vclone(target.pos)
                        if target_num <= 1 then
                            e.is_meteor = false
                        else
                            e.is_meteor = true
                        end
                        queue_insert(store, e)

                        skill_come_into_cooldown(this.ultimate, true)
                        SU.hero_gain_xp_from_skill(this, this.ultimate)
                    else
                        this.ultimate.ts = this.ultimate.ts + 1
                    end
                end
                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta ~= A_NO_TARGET then
                    -- block empty
                else
                    brk, sta = SU.y_soldier_ranged_attacks(store, this)

                    if brk then
                        -- block empty
                    elseif SU.soldier_go_back_step(store, this) then
                        -- block empty
                    else
                        SU.soldier_idle(store, this)
                        SU.soldier_regen(store, this)
                    end
                end
            end

            ::label_167_0::

            coroutine.yield()
        end
    end

    scripts.hero_lilith_ultimate = {}

    function scripts.hero_lilith_ultimate.update(this, store)
        local function spawn_meteor(pi, spi, ni)
            spi = spi or math.random(1, 3)

            local pos = P:node_pos(pi, spi, ni)

            pos.x = pos.x + math.random(-4, 4)
            pos.y = pos.y + math.random(-5, 5)

            local b = E:create_entity(this.meteor_bullet)

            b.bullet.from = V.v(pos.x + math.random(140, 170), pos.y + REF_H)
            b.bullet.to = pos
            b.pos = V.vclone(b.bullet.from)
            b.bullet.damage_factor = this.damage_factor

            queue_insert(store, b)
        end

        local pi, spi, ni
        local nearest = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

        if #nearest < 1 then
            log.error("could not find node to fire lilith ultimate")
        else
            pi, spi, ni = unpack(nearest[1])

            if this.is_meteor then
                local seq = {}

                for i = 1, this.meteor_node_spread do
                    seq[i] = i
                end

                spawn_meteor(pi, spi, ni)

                while #seq > 0 do
                    local delay = U.frandom(0.15, 0.3)
                    local i = table.remove(seq, math.random(1, #seq))
                    local can_up, can_down = P:is_node_valid(pi, ni + i), P:is_node_valid(pi, ni - i)

                    U.y_wait(store, delay / 2)

                    if can_up then
                        spawn_meteor(pi, nil, ni + i)
                    elseif can_down then
                        spawn_meteor(pi, nil, ni - i)
                    end

                    U.y_wait(store, delay / 2)

                    if can_down then
                        spawn_meteor(pi, nil, ni - i)
                    elseif can_up then
                        spawn_meteor(pi, nil, ni + i)
                    end
                end
            else
                local node = {
                    spi = 1,
                    pi = nearest[1][1],
                    ni = nearest[1][3]
                }
                local node_pos = P:node_pos(node)
                local target, targets = U.find_foremost_enemy(store.entities, this.pos, 0, this.angel_range, fts(10),
                    this.angel_vis_flags, this.angel_vis_bans)
                local idx = 1

                for i = 1, this.angel_count do
                    local e = E:create_entity(this.angel_entity)

                    if targets then
                        target = targets[km.zmod(idx, #targets)]
                        idx = idx + 1

                        if band(target.vis.bans, F_STUN) == 0 and band(target.vis.flags, F_BOSS) == 0 then
                            local m = E:create_entity(this.angel_mod)

                            m.modifier.target_id = target.id
                            m.modifier.source_id = this.id

                            queue_insert(store, m)
                        end

                        if band(target.vis.flags, F_BLOCK) ~= 0 then
                            U.block_enemy(store, e, target)
                        else
                            e.unblocked_target_id = target.id
                        end

                        local lpos, lflip = U.melee_slot_position(e, target, 1, math.random() < 0.5)

                        e.pos.x, e.pos.y = lpos.x, lpos.y
                        e.render.sprites[1].flip_x = lflip
                    else
                        local nni = node.ni + math.random(-10, 10)
                        local nspi = math.random(1, 3)
                        local npos = P:node_pos(node.pi, nspi, nni)

                        if not P:is_node_valid(node.pi, nni) or GR:cell_is(node_pos.x, node_pos.y, TERRAIN_FAERIE) then
                            npos = node_pos
                        end

                        e.pos.x, e.pos.y = npos.x, npos.y
                    end

                    e.nav_rally.center = V.vclone(e.pos)
                    e.nav_rally.pos = V.vclone(e.pos)

                    queue_insert(store, e)
                    U.y_wait(store, this.angel_delay)
                end
            end
        end

        queue_remove(store, this)
    end

    scripts.hero_xin = {}

    function scripts.hero_xin.level_up(this, store, initial)
        local hl, ls = level_up_basic(this)

        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
        this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

        upgrade_skill(this, "daring_strike", function(this, s)
            local a = this.timed_attacks.list[1]

            a.disabled = nil
            a.ts = store.tick_ts
            a.damage_max = s.damage_max[s.level]
            a.damage_min = s.damage_min[s.level]
        end)

        upgrade_skill(this, "inspire", function(this, s)
            local a = this.timed_attacks.list[2]

            a.disabled = nil
            a.ts = store.tick_ts

            local m = E:get_template(a.mod)

            m.modifier.duration = s.duration[s.level]
        end)
        upgrade_skill(this, "mind_over_body", function(this, s)
            local a = this.timed_attacks.list[3]

            a.disabled = nil
            a.ts = store.tick_ts
            this.mind_over_body_damage_buff_max = s.damage_buff[s.level]
            this.mind_over_body_duration = s.duration[s.level]
            local m = E:get_template(a.mod)

            m.modifier.duration = s.duration[s.level]
            m.hps.heal_every = s.heal_every[s.level]
            m.hps.heal_min = s.heal_hp[s.level]
            m.hps.heal_max = s.heal_hp[s.level]
        end)

        upgrade_skill(this, "panda_style", function(this, s)
            local a = this.melee.attacks[3]

            a.disabled = nil
            a.ts = store.tick_ts
            a.damage_max = s.damage_max[s.level]
            a.damage_min = s.damage_min[s.level]
        end)
        upgrade_skill(this, "ultimate", function(this, s)
            this.ultimate.disabled = nil
            local u = E:get_template("hero_xin_ultimate")

            u.count = s.count[s.level]

            local e = E:get_template(u.entity)

            for _, ma in pairs(e.melee.attacks) do
                ma.damage_max = s.damage[s.level]
                ma.damage_min = s.damage[s.level]
            end
        end)

        this.health.hp = this.health.hp_max
    end

    function scripts.hero_xin.update(this, store)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta

        U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        while true do
            if this.mind_over_body_active and store.tick_ts - this.mind_over_body_last_ts >=
                this.mind_over_body_duration then
                this.damage_buff = this.damage_buff - this.mind_over_body_damage_buff
                this.mind_over_body_active = false
                this.melee.attacks[3].ts = this.melee.attacks[3].ts - this.melee.attacks[3].cooldown * 0.1
                this.timed_attacks.list[1].ts = this.timed_attacks.list[1].ts - this.timed_attacks.list[1].cooldown *
                                                    0.1
                this.timed_attacks.list[2].ts = this.timed_attacks.list[2].ts - this.timed_attacks.list[2].cooldown *
                                                    0.1
            end
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    -- if SU.y_hero_new_rally(store, this) then
                    --     goto label_126_1
                    -- end
                    a = this.timed_attacks.list[1]
                    local initial_flip = this.render.sprites[1].flip_x
                    local shadow
                    S:queue(a.sounds[1])
                    U.animation_start(this, a.animations[1], nil, store.tick_ts)
                    SU.insert_sprite(store, "fx_xin_smoke_teleport_out", this.pos, initial_flip)
                    this.health_bar.hidden = true
                    if U.is_blocked_valid(store, this) then
                        local blocked = store.entities[this.soldier.target_id]
                        local m = E:create_entity("mod_xin_stun")

                        m.modifier.target_id = blocked.id
                        m.modifier.source_id = this.id

                        queue_insert(store, m)

                        shadow = E:create_entity("soldier_xin_shadow")
                        shadow.pos.x, shadow.pos.y = this.pos.x, this.pos.y
                        shadow.nav_rally.center = V.vclone(this.pos)
                        shadow.nav_rally.pos = V.vclone(this.pos)
                        shadow.render.sprites[1].flip_x = this.render.sprites[1].flip_x

                        queue_insert(store, shadow)
                        U.replace_blocker(store, this, shadow)
                    end
                    U.y_animation_wait(this)
                    this.health_bar.hidden = nil
                    this.pos.x = this.nav_rally.pos.x
                    this.pos.y = this.nav_rally.pos.y

                    SU.insert_sprite(store, "fx_xin_smoke_teleport_in", this.pos, initial_flip)
                    if shadow then
                        shadow.health.dead = true
                    end
                    this.nav_rally.new = false
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                a = this.timed_attacks.list[3]
                skill = this.hero.skills.mind_over_body

                if ready_to_use_skill(a, store) and this.health.hp / this.health.hp_max <= a.min_health_factor then
                    SU.hero_gain_xp_from_skill(this, skill)
                    this.health.ignore_damage = true
                    U.animation_start(this, a.animation, nil, store.tick_ts)
                    U.y_wait(store, a.cast_time)
                    S:queue(a.sound)
                    SU.insert_sprite(store, "decal_xin_drink_circle", this.pos)
                    local mod = E:create_entity(a.mod)
                    mod.modifier.target_id = this.id
                    mod.modifier.source_id = this.id
                    queue_insert(store, mod)
                    this.mind_over_body_active = true
                    this.mind_over_body_damage_buff = this.mind_over_body_damage_buff_max
                    this.mind_over_body_last_ts = store.tick_ts
                    this.damage_buff = this.damage_buff + this.mind_over_body_damage_buff
                    U.y_animation_wait(this)
                    this.health.ignore_damage = false
                    a.ts = store.tick_ts
                end

                a = this.timed_attacks.list[2]
                skill = this.hero.skills.inspire

                if ready_to_use_skill(a, store) then
                    local soldiers = U.find_soldiers_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags,
                        a.vis_bans)
                    local enemies = U.find_enemies_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags,
                        a.vis_bans)

                    if not soldiers or #soldiers < a.min_count or not enemies then
                        SU.delay_attack(store, a, 0.3333333333333333)
                    else
                        this.health.ignore_damage = true
                        U.animation_start(this, a.animation, nil, store.tick_ts)
                        U.y_wait(store, a.cast_time)
                        S:queue(a.sound)
                        SU.insert_sprite(store, "decal_xin_inspire", this.pos)

                        for i = 1, math.min(#soldiers, a.max_count) do
                            local soldier = soldiers[i]
                            local m = E:create_entity(a.mod)

                            m.modifier.target_id = soldier.id
                            m.modifier.source_id = this.id
                            m.modifier.ts = store.tick_ts

                            queue_insert(store, m)
                        end

                        U.y_animation_wait(this)
                        SU.hero_gain_xp_from_skill(this, skill)

                        a.ts = store.tick_ts
                        this.health.ignore_damage = false
                    end
                end

                a = this.timed_attacks.list[1]
                skill = this.hero.skills.daring_strike

                if ready_to_use_skill(a, store) then
                    local blocked_enemy = this.soldier.target_id and store.entities[this.soldier.target_id]

                    if not blocked_enemy and SU.soldier_pick_melee_target(store, this) then
                        SU.delay_attack(store, a, 0.3333333333333333)

                        goto label_126_0
                    end

                    local targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range,
                        a.vis_flags, a.vis_bans, function(e)
                            local ni_s = P:get_visible_start_node(e.nav_path.pi)
                            local ni_e = P:get_visible_end_node(e.nav_path.pi)

                            return
                                e ~= blocked_enemy and e.nav_path.ni > ni_s + a.node_margin and e.nav_path.ni < ni_e -
                                    a.node_margin
                        end)

                    if not targets then
                        SU.delay_attack(store, a, 0.3333333333333333)

                        goto label_126_0
                    end

                    table.sort(targets, function(e1, e2)
                        return e1.health.hp > e2.health.hp
                    end)

                    local target = targets[1]
                    local initial_pos = V.vclone(this.pos)
                    local initial_flip = this.render.sprites[1].flip_x
                    local _bans = this.vis.bans
                    local shadow

                    this.vis.bans = F_ALL
                    this.health.ignore_damage = true

                    S:queue(a.sounds[1])
                    U.animation_start(this, a.animations[1], nil, store.tick_ts)
                    SU.insert_sprite(store, "fx_xin_smoke_teleport_out", this.pos, initial_flip)
                    -- U.y_wait(store, fts(14))

                    this.health_bar.hidden = true

                    -- U.y_wait(store, fts(3))

                    if U.is_blocked_valid(store, this) then
                        local blocked = store.entities[this.soldier.target_id]
                        local m = E:create_entity("mod_xin_stun")

                        m.modifier.target_id = blocked.id
                        m.modifier.source_id = this.id

                        queue_insert(store, m)

                        shadow = E:create_entity("soldier_xin_shadow")
                        shadow.pos.x, shadow.pos.y = this.pos.x, this.pos.y
                        shadow.nav_rally.center = V.vclone(this.pos)
                        shadow.nav_rally.pos = V.vclone(this.pos)
                        shadow.render.sprites[1].flip_x = this.render.sprites[1].flip_x

                        queue_insert(store, shadow)
                        U.replace_blocker(store, this, shadow)
                    end

                    U.y_animation_wait(this)

                    local m = E:create_entity("mod_xin_stun")

                    m.modifier.target_id = target.id
                    m.modifier.source_id = this.id

                    queue_insert(store, m)

                    local lpos, lflip = U.melee_slot_position(this, target, 2)

                    this.pos.x, this.pos.y = lpos.x, lpos.y

                    U.animation_start(this, a.animations[2], lflip, store.tick_ts)
                    SU.insert_sprite(store, "fx_xin_smoke_teleport_hit", this.pos, lflip)
                    -- U.y_wait(store, fts(5))
                    S:queue(a.sounds[2])

                    this.health_bar.hidden = nil
                    queue_damage(store, SU.create_attack_damage(a, target.id, this))
                    U.y_animation_wait(this)

                    if target and not target.health.dead then
                        U.animation_start(this, a.animations[3], lflip, store.tick_ts)
                        queue_damage(store, SU.create_attack_damage(a, target.id, this))
                        U.y_animation_wait(this)
                    end

                    if target and not target.health.dead then
                        local m = E:create_entity(a.mod)
                        m.modifier.target_id = target.id
                        m.modifier.source_id = this.id
                        m.modifier.ts = store.tick_ts
                        queue_insert(store, m)
                    end
                    this.health_bar.hidden = true

                    U.animation_start(this, a.animations[4], lflip, store.tick_ts)
                    SU.insert_sprite(store, "fx_xin_smoke_teleport_hit_out", this.pos, lflip)
                    U.y_animation_wait(this)

                    if this.nav_rally.new then
                        this.nav_rally.new = false
                        this.pos.x, this.pos.y = this.nav_rally.pos.x, this.nav_rally.pos.y
                    else
                        this.pos.x, this.pos.y = initial_pos.x, initial_pos.y
                    end

                    S:queue(a.sounds[5])
                    U.animation_start(this, a.animations[5], initial_flip, store.tick_ts)
                    SU.insert_sprite(store, "fx_xin_smoke_teleport_in", this.pos, initial_flip)

                    if shadow then
                        shadow.health.dead = true

                        U.replace_blocker(store, shadow, this)
                    end

                    -- U.y_wait(store, fts(5))

                    this.health_bar.hidden = nil
                    this.vis.bans = _bans
                    this.health.ignore_damage = nil

                    U.y_animation_wait(this)
                    SU.hero_gain_xp_from_skill(this, skill)

                    a.ts = store.tick_ts
                end

                if ready_to_use_skill(this.ultimate, store) then
                    local target = find_target_at_critical_moment(this, store, this.ultimate.range)

                    if target and target.pos and valid_land_node_nearby(target.pos) then
                        this.health.ignore_damage = true
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                        this.health.ignore_damage = false
                        S:queue(this.sound_events.change_rally_point)
                        local e = E:create_entity(this.hero.skills.ultimate.controller_name)

                        e.pos = V.vclone(target.pos)

                        queue_insert(store, e)

                        this.ultimate.ts = store.tick_ts
                        SU.hero_gain_xp_from_skill(this, this.ultimate)
                    else
                        this.ultimate.ts = this.ultimate.ts + 1
                    end
                end
                ::label_126_0::

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta ~= A_NO_TARGET then
                    -- block empty
                elseif SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end
            end

            ::label_126_1::

            coroutine.yield()
        end
    end

    scripts.hero_xin_ultimate = {}

    function scripts.hero_xin_ultimate.update(this, store)
        local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

        if #nodes < 1 then
            log.error("hero_xin_ultimate: could not find valid node")
            queue_remove(store, this)

            return
        end

        local node = {
            spi = 1,
            pi = nodes[1][1],
            ni = nodes[1][3]
        }
        local node_pos = P:node_pos(node)
        local count = this.count
        local target, targets = U.find_foremost_enemy(store.entities, this.pos, 0, this.range, fts(10), this.vis_flags,
            this.vis_bans)
        local idx = 1

        while count > 0 do
            local e = E:create_entity(this.entity)

            if targets then
                target = targets[km.zmod(idx, #targets)]
                idx = idx + 1

                if band(target.vis.bans, F_STUN) == 0 and band(target.vis.flags, F_BOSS) == 0 then
                    local m = E:create_entity("mod_xin_stun")

                    m.modifier.target_id = target.id
                    m.modifier.source_id = this.id

                    queue_insert(store, m)
                end

                if band(target.vis.flags, F_BLOCK) ~= 0 then
                    U.block_enemy(store, e, target)
                else
                    e.unblocked_target_id = target.id
                end

                local lpos, lflip = U.melee_slot_position(e, target, 1)

                e.pos.x, e.pos.y = lpos.x, lpos.y
                e.render.sprites[1].flip_x = lflip
            else
                local nni = node.ni + math.random(-10, 10)
                local nspi = math.random(1, 3)
                local npos = P:node_pos(node.pi, nspi, nni)

                if not P:is_node_valid(node.pi, nni) or GR:cell_is(node_pos.x, node_pos.y, TERRAIN_FAERIE) then
                    npos = node_pos
                end

                e.pos.x, e.pos.y = npos.x, npos.y
            end

            e.nav_rally.center = V.vclone(e.pos)
            e.nav_rally.pos = V.vclone(e.pos)

            queue_insert(store, e)

            count = count - 1

            U.y_wait(store, this.spawn_delay)
        end

        queue_remove(store, this)
    end

    scripts.hero_faustus = {}

    function scripts.hero_faustus.level_up(this, store)
        local hl, ls = level_up_basic(this)

        local b = E:get_template(this.ranged.attacks[1].bullet)

        b.bullet.damage_max = ls.ranged_damage_max[hl]
        b.bullet.damage_min = ls.ranged_damage_min[hl]

        upgrade_skill(this, "dragon_lance", function(this, s)
            local a = this.ranged.attacks[2]

            a.disabled = nil

            local b = E:get_template(a.bullet)

            b.bullet.damage_max = s.damage_max[s.level]
            b.bullet.damage_min = s.damage_min[s.level]
        end)
        upgrade_skill(this, "teleport_rune", function(this, s)
            local a = this.ranged.attacks[3]

            a.disabled = nil

            local aura = E:get_template(a.bullet)

            aura.aura.targets_per_cycle = s.max_targets[s.level]
        end)

        upgrade_skill(this, "enervation", function(this, s)
            local a = this.ranged.attacks[4]

            a.disabled = nil

            local aura = E:get_template(a.bullet)

            aura.aura.targets_per_cycle = s.max_targets[s.level]

            local mod = E:get_template(aura.aura.mod)

            mod.modifier.duration = s.duration[s.level]
        end)
        upgrade_skill(this, "liquid_fire", function(this, s)
            local a = this.ranged.attacks[5]

            a.disabled = nil

            local b = E:get_template(a.bullet)

            b.flames_count = s.flames_count[s.level]

            local m = E:get_template("mod_liquid_fire_faustus")

            m.dps.damage_max = s.mod_damage[s.level]
            m.dps.damage_min = s.mod_damage[s.level]
        end)

        upgrade_skill(this, "ultimate", function(this, s)
            this.ultimate.disabled = nil
            local m = E:get_template("mod_minidragon_faustus")

            m.dps.damage_max = s.mod_damage[s.level]
            m.dps.damage_min = s.mod_damage[s.level]
        end)

        this.health.hp = this.health.hp_max
    end

    function scripts.hero_faustus.insert(this, store)
        this.hero.fn_level_up(this, store)

        this.ranged.order = U.attack_order(this.ranged.attacks)

        return true
    end

    function scripts.hero_faustus.update(this, store)
        local h = this.health
        local he = this.hero
        local a, skill

        U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)

        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
                U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil,
                    true)
            end

            while this.nav_rally.new do
                SU.y_hero_new_rally(store, this)
            end

            if SU.hero_level_up(store, this) then
                -- block empty
            end

            if ready_to_use_skill(this.ultimate, store) then
                local target = find_target_at_critical_moment(this, store, this.ranged.attacks[1].max_range, true)

                if target and target.pos and valid_land_node_nearby(target.pos) then
                    S:queue(this.sound_events.change_rally_point)
                    local e = E:create_entity(this.hero.skills.ultimate.controller_name)

                    e.pos = V.vclone(target.pos)

                    queue_insert(store, e)

                    this.ultimate.ts = store.tick_ts
                    SU.hero_gain_xp_from_skill(this, this.ultimate)
                else
                    this.ultimate.ts = this.ultimate.ts + 1
                end
            end
            for _, i in pairs(this.ranged.order) do
                local a = this.ranged.attacks[i]

                if a.disabled then
                    -- block empty
                elseif a.sync_animation and not this.render.sprites[1].sync_flag then
                    -- block empty
                elseif store.tick_ts - a.ts < a.cooldown then
                    -- block empty
                else
                    local bullet_t = E:get_template(a.bullet)
                    local flight_time = a.estimated_flight_time or 1
                    local target = U.find_random_enemy(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags,
                        a.vis_bans, function(e)
                            if U.flag_has(a.vis_flags, F_SPELLCASTER) and
                                (not U.flag_has(e.vis.flags, F_SPELLCASTER) or not e.enemy.can_do_magic) then
                                log.debug("filtering (%s)%s", e.id, e.template_name)

                                return false
                            end

                            if a.target_offset_rect then
                                local node_offset = P:predict_enemy_node_advance(e, a.shoot_time + flight_time)
                                local e_pos = P:node_pos(e.nav_path.pi, e.nav_path.spi, e.nav_path.ni + node_offset)
                                local is_inside = V.is_inside(V.v(math.abs(e_pos.x - this.pos.x), e_pos.y - this.pos.y),
                                    a.target_offset_rect)

                                if not is_inside then
                                    return false
                                end

                                if a.max_count_range and a.min_count then
                                    local min_count_pos = P:node_pos(e.nav_path.pi, e.nav_path.spi,
                                        e.nav_path.ni - a.min_count_nodes_offset)
                                    local nearby = U.find_enemies_in_range(store.entities, min_count_pos, 0,
                                        a.max_count_range, a.vis_flags, a.vis_bans)

                                    return nearby and #nearby >= a.min_count
                                end

                                return true
                            else
                                return true
                            end
                        end)

                    if target then
                        local start_ts = store.tick_ts
                        local start_fx, b, targets
                        local node_offset = P:predict_enemy_node_advance(target, flight_time)
                        local t_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi,
                            target.nav_path.ni + node_offset)
                        local an, af, ai = U.animation_name_facing_point(this, a.animation, t_pos)

                        U.animation_start(this, an, af, store.tick_ts)
                        S:queue(a.start_sound, a.start_sound_args)

                        if a.start_fx then
                            local fx = E:create_entity(a.start_fx)

                            fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
                            fx.render.sprites[1].ts = store.tick_ts
                            fx.render.sprites[1].flip_x = af

                            queue_insert(store, fx)

                            start_fx = fx
                        end

                        while store.tick_ts - start_ts < a.shoot_time do
                            if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
                                goto label_112_0
                            end

                            coroutine.yield()
                        end

                        S:queue(a.sound)

                        targets = {}

                        if a.bullet_count then
                            local extra_targets = U.find_enemies_in_range(store.entities, target.pos, 0, a.extra_range,
                                a.vis_flags, a.vis_bans, function(e)
                                    return af and e.pos.x <= this.pos.x or e.pos.x >= this.pos.x
                                end)

                            if not extra_targets then
                                goto label_112_0
                            end

                            for i = 1, a.bullet_count do
                                table.insert(targets, extra_targets[km.zmod(i, #extra_targets)])
                            end
                        else
                            targets = {target}
                        end

                        for i, t in ipairs(targets) do
                            b = E:create_entity(a.bullet)

                            if a.type == "aura" then
                                b.pos.x, b.pos.y = target.pos.x, target.pos.y
                                b.aura.ts = store.tick_ts
                            else
                                b.bullet.target_id = t.id
                                b.bullet.source_id = this.id
                                b.bullet.xp_dest_id = this.id
                                b.bullet.damage_factor = this.unit.damage_factor
                                b.pos = V.vclone(this.pos)
                                b.pos.x = b.pos.x + (af and -1 or 1) * a.bullet_start_offset[ai].x
                                b.pos.y = b.pos.y + a.bullet_start_offset[ai].y
                                b.bullet.from = V.vclone(b.pos)
                                b.bullet.to = V.v(t.pos.x + t.unit.hit_offset.x, t.pos.y + t.unit.hit_offset.y)
                                b.bullet.shot_index = i

                                if i == 1 then
                                    b.initial_impulse = 0
                                end
                            end

                            queue_insert(store, b)
                        end

                        if a.xp_from_skill then
                            SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
                        end

                        a.ts = start_ts

                        while not U.animation_finished(this) do
                            if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
                                goto label_112_0
                            end

                            coroutine.yield()
                        end

                        a.ts = start_ts

                        U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop,
                            nil, true)

                        ::label_112_0::

                        if start_fx then
                            start_fx.render.sprites[1].hidden = true
                        end

                        goto label_112_1
                    end
                end
            end

            SU.soldier_idle(store, this)
            SU.soldier_regen(store, this)

            ::label_112_1::

            coroutine.yield()
        end
    end

    scripts.hero_faustus_ultimate = {}

    function scripts.hero_faustus_ultimate.update(this, store)
        local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

        if #nodes < 1 then
            log.error("hero_faustus_ultimate: could not find valid node")
            queue_remove(store, this)

            return
        end

        local node = {
            spi = 1,
            pi = nodes[1][1],
            ni = nodes[1][3]
        }
        local node_offsets = {0, -this.separation_nodes, this.separation_nodes}
        local node_pos = P:node_pos(node.pi, node.spi, node.ni)
        local from_y = node_pos.y

        for i = 1, 3 do
            if P:is_node_valid(node.pi, node.ni + node_offsets[i]) then
                node_pos = P:node_pos(node.pi, node.spi, node.ni + node_offsets[i])
                from_y = node_pos.y
            end

            local e = E:create_entity("decal_minidragon_faustus")

            e.attack_pos = node_pos
            e.pos.x, e.pos.y = i % 2 == 0 and 2 * REF_W or -REF_W, from_y

            queue_insert(store, e)
            U.y_wait(store, this.show_delay)
        end

        queue_remove(store, this)
    end

    scripts.hero_rag = {}

    function scripts.hero_rag.level_up(this, store, initial)
        local hl, ls = level_up_basic(this, store)

        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

        local bt = E:get_template(this.ranged.attacks[1].bullet)
        bt.bullet.damage_min = ls.ranged_damage_min[hl]
        bt.bullet.damage_max = ls.ranged_damage_max[hl]

        upgrade_skill(this, "raggified", function(this, s)
            local a = this.timed_attacks.list[4]

            a.disabled = nil
            a.max_target_hp = s.max_target_hp[s.level]

            local m = E:get_template("mod_rag_raggified")

            m.doll_duration = s.doll_duration[s.level]
            m.break_factor = s.break_factor[s.level]
        end)
        upgrade_skill(this, "kamihare", function(this, s)
            local a = this.timed_attacks.list[2]

            a.disabled = nil
            a.count = s.count[s.level]
        end)

        upgrade_skill(this, "angry_gnome", function(this, s)
            local a = this.timed_attacks.list[1]

            a.disabled = nil

            for _, n in pairs(a.things) do
                local b = E:get_template(a.bullet_prefix .. n)

                b.bullet.damage_max = s.damage_max[s.level]
                b.bullet.damage_min = s.damage_min[s.level]
            end
        end)
        upgrade_skill(this, "hammer_time", function(this, s)
            local a = this.timed_attacks.list[3]

            a.disabled = nil
            a.duration = s.duration[s.level]
        end)

        upgrade_skill(this, "ultimate", function(this, s)
            this.ultimate.disabled = nil
            local u = E:get_template(s.controller_name)
            u.max_count = s.max_count[s.level]
        end)

        this.health.hp = this.health.hp_max
    end

    function scripts.hero_rag.update(this, store)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta, ranged_done

        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_144_0
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                a = this.timed_attacks.list[4]
                skill = this.hero.skills.raggified

                if ready_to_use_skill(a, store) then
                    local target = U.find_random_enemy(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags,
                        a.vis_bans, function(e)
                            return e.health.hp < a.max_target_hp * this.unit.damage_factor and
                                       GR:cell_is_only(e.pos.x, e.pos.y, bor(TERRAIN_LAND, TERRAIN_ICE))
                        end)

                    if not target then
                        SU.delay_attack(store, a, 0.16666666666666666)
                    else
                        a.ts = store.tick_ts

                        if not SU.y_soldier_do_ranged_attack(store, this, target, a) then
                            goto label_144_0
                        end
                    end
                end

                a = this.timed_attacks.list[2]
                skill = this.hero.skills.kamihare

                if ready_to_use_skill(a, store) then
                    local target_info = U.find_enemies_in_paths(store.entities, this.pos, a.range_nodes_min,
                        a.range_nodes_max, nil, a.vis_flags, a.vis_bans, true, function(e)
                            return not U.flag_has(P:path_terrain_props(e.nav_path.pi),
                                bor(TERRAIN_FAERIE, TERRAIN_WATER))
                        end)

                    if not target_info then
                        SU.delay_attack(store, a, 0.16666666666666666)
                    else
                        local target = target_info[1].enemy
                        local origin = target_info[1].origin
                        local start_ts = store.tick_ts
                        local bullet_to_ni = origin[3] - 5
                        local bullet_to = P:node_pos(origin[1], 1, bullet_to_ni)
                        local flip = bullet_to.x < this.pos.x

                        S:queue(a.sound, {
                            delay = a.sound_delay
                        })
                        U.animation_start(this, a.animations[1], flip, store.tick_ts)

                        if SU.y_hero_wait(store, this, a.spawn_time) then
                            -- block empty
                        else
                            SU.hero_gain_xp_from_skill(this, skill)

                            a.ts = store.tick_ts

                            for i = 1, a.count do
                                SU.y_hero_wait(store, this, fts(2))

                                local pi, spi, ni = origin[1], km.zmod(i, 3), bullet_to_ni + math.random(-10, 0)

                                if not P:is_node_valid(pi, ni) then
                                    log.debug("cannot spawn kamihare in invalid node: %s,%s,%s", pi, spi, ni)
                                else
                                    local e = E:create_entity(a.entity)

                                    e.pos = P:node_pos(pi, spi, ni)
                                    e.nav_path.pi = pi
                                    e.nav_path.spi = spi
                                    e.nav_path.ni = ni

                                    local b = E:create_entity(a.bullet)

                                    b.pos.x = this.pos.x + math.random(-3, 3) + a.spawn_offset.x
                                    b.pos.y = this.pos.y + math.random(0, 3) + a.spawn_offset.y
                                    b.bullet.from = V.vclone(b.pos)
                                    b.bullet.to = V.vclone(e.pos)
                                    b.bullet.hit_payload = e
                                    b.bullet.damage_factor = this.unit.damage_factor
                                    b.render.sprites[1].flip_x = flip
                                    b.render.sprites[1].ts = store.tick_ts

                                    queue_insert(store, b)
                                end
                            end

                            U.animation_start(this, a.animations[2], nil, store.tick_ts)
                            SU.y_hero_animation_wait(this)

                            a.ts = store.tick_ts
                        end

                        goto label_144_0
                    end
                end

                a = this.timed_attacks.list[1]
                skill = this.hero.skills.angry_gnome

                if ready_to_use_skill(a, store) then
                    local target = U.find_random_enemy(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags,
                        a.vis_bans)

                    if not target then
                        SU.delay_attack(store, a, 0.13333333333333333)
                    else
                        local pred_pos = P:predict_enemy_pos(target, fts(12))
                        local thing = table.random(a.things)

                        a.animation = "throw_" .. thing
                        a.bullet = a.bullet_prefix .. thing
                        a.ts = store.tick_ts

                        if not SU.y_soldier_do_ranged_attack(store, this, target, a, pred_pos) then
                            goto label_144_0
                        end
                    end
                end

                a = this.timed_attacks.list[3]
                skill = this.hero.skills.hammer_time

                if ready_to_use_skill(a, store) then
                    local nodes, start_node, end_node, next_node, damage_ts
                    local target, targets = U.find_nearest_enemy(store.entities, this.pos, 0, a.max_range, a.vis_flags,
                        a.vis_bans)
                    local total_hp = not targets and 0 or table.reduce(targets, function(e, hp_sum)
                        return e.health.hp + hp_sum
                    end)

                    if not target or total_hp < a.trigger_hp then
                        SU.delay_attack(store, a, 0.13333333333333333)
                    else
                        U.unblock_target(store, this)
                        S:queue(a.sound_loop)
                        U.y_animation_play(this, a.animations[1], nil, store.tick_ts)

                        if SU.hero_interrupted(this) then
                            -- block empty
                        else
                            SU.hero_gain_xp_from_skill(this, skill)

                            a.ts = store.tick_ts
                            nodes = P:nearest_nodes(this.pos.x, this.pos.y, {target.nav_path.pi}, nil, true)

                            if #nodes == 0 then
                                log.error("hammer_time could not find a valid node near %s,%s", this.pos.x, this.pos.y)

                                goto label_144_0
                            end

                            start_node = {
                                pi = nodes[1][1],
                                spi = nodes[1][2],
                                ni = nodes[1][3]
                            }
                            end_node = table.deepclone(target.nav_path)
                            next_node = table.deepclone(start_node)
                            next_node.dir = start_node.ni > end_node.ni and -1 or 1
                            end_node.ni = next_node.dir * a.nodes_range + start_node.ni

                            U.animation_start(this, a.animations[2], nil, store.tick_ts, true)

                            damage_ts = store.tick_ts - a.damage_every

                            while store.tick_ts - a.ts < a.duration and not SU.hero_interrupted(this) do
                                if U.walk(this, store.tick_length) then
                                    if math.abs(next_node.ni - start_node.ni) == a.nodes_range then
                                        next_node.dir = next_node.dir * -1
                                    end

                                    next_node.ni = next_node.ni + next_node.dir
                                    next_node.spi = next_node.spi == 3 and 2 or 3

                                    U.set_destination(this, P:node_pos(next_node))

                                    this.render.sprites[1].flip_x = this.motion.dest.x < this.pos.x
                                end

                                if store.tick_ts - damage_ts >= a.damage_every then
                                    damage_ts = store.tick_ts

                                    S:queue(a.sound_hit)

                                    local targets = U.find_enemies_in_range(store.entities, this.pos, 0,
                                        a.damage_radius, a.vis_flags, a.vis_bans)

                                    if targets then
                                        for _, t in pairs(targets) do
                                            local d = SU.create_attack_damage(a, t.id, this)

                                            queue_damage(store, d)

                                            local m = E:create_entity(a.mod)

                                            m.modifier.source_id = this.id
                                            m.modifier.target_id = t.id

                                            queue_insert(store, m)
                                        end
                                    end
                                end

                                coroutine.yield()
                            end
                        end

                        a.ts = store.tick_ts - (1 - km.clamp(0, 1 ,(store.tick_ts - a.ts) / a.duration)) * a.cooldown

                        S:stop(a.sound_loop)
                        U.y_animation_play(this, a.animations[3], nil, store.tick_ts)

                        goto label_144_0
                    end
                end

                if ready_to_use_skill(this.ultimate, store) then
                    local target = find_target_at_critical_moment(this, store, this.ranged.attacks[1].max_range, false, false, bor(F_FLYING, F_BOSS))

                    if target and target.pos and valid_land_node_nearby(target.pos) then
                        this.health.ignore_damage = true
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                        this.health.ignore_damage = false
                        S:queue(this.sound_events.change_rally_point)
                        local e = E:create_entity(this.hero.skills.ultimate.controller_name)

                        e.pos = V.vclone(target.pos)

                        queue_insert(store, e)

                        this.ultimate.ts = store.tick_ts
                        SU.hero_gain_xp_from_skill(this, this.ultimate)
                    else
                        this.ultimate.ts = this.ultimate.ts + 1
                    end
                end
                if not ranged_done then
                    brk, sta = SU.y_soldier_ranged_attacks(store, this)

                    if brk then
                        goto label_144_0
                    end

                    if sta == A_DONE then
                        ranged_done = true
                    end
                end

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta == A_DONE or sta == A_NO_TARGET then
                    ranged_done = nil
                end

                if brk or sta ~= A_NO_TARGET then
                    -- block empty
                elseif SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end
            end

            ::label_144_0::

            coroutine.yield()
        end
    end

    scripts.hero_rag_ultimate = {}

    function scripts.hero_rag_ultimate.update(this, store)
        SU.insert_sprite(store, this.hit_fx, this.pos)
        SU.insert_sprite(store, this.hit_decal, this.pos)
        U.y_wait(store, this.hit_time)

        local targets = U.find_enemies_in_range(store.entities, this.pos, 0, this.range, this.vis_flags, this.vis_bans,
            function(e)
                return GR:cell_is_only(e.pos.x, e.pos.y, bor(TERRAIN_LAND, TERRAIN_ICE))
            end)

        if targets then
            for i, target in ipairs(targets) do
                if i > this.max_count then
                    break
                end

                local m = E:create_entity(this.mod)
                m.modifier.source_id = this.id
                m.modifier.target_id = target.id
                m.doll_duration = this.doll_duration * U.frandom(0.97, 1.03)
                queue_insert(store, m)
            end
        end

        queue_remove(store, this)
    end

    scripts.rabbit_kamihare = {}

    function scripts.rabbit_kamihare.update(this, store)
        local start_ts = store.tick_ts
        local a = this.custom_attack
        local s = this.render.sprites[1]

        s.ts = store.tick_ts + (s.random_ts and U.frandom(-s.random_ts, 0) or 0)

        while true do
            local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans)

            if targets or store.tick_ts - start_ts > this.duration or
                not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) or not SU.y_enemy_walk_step(store, this) then
                break
            end
        end

        local aura = E:create_entity(a.aura)

        aura.pos = V.vclone(this.pos)

        queue_insert(store, aura)

        if a.hit_fx then
            local fx = E:create_entity(a.hit_fx)

            fx.pos = V.vclone(this.pos)
            fx.render.sprites[1].ts = store.tick_ts

            queue_insert(store, fx)
        end

        U.y_animation_play(this, "death", nil, store.tick_ts)
        queue_remove(store, this)
    end

    scripts.hero_bruce = {}

    function scripts.hero_bruce.fn_chance_sharp_claws(this, store, attack, target)
        return U.has_modifier_types(store, target, MOD_TYPE_BLEED, MOD_TYPE_POISON) or math.random() < attack.chance
    end

    function scripts.hero_bruce.level_up(this, store)
        local hl, ls = level_up_basic(this, store)
        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
        this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]
        this.melee.attacks[3].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[3].damage_max = ls.melee_damage_max[hl]

        upgrade_skill(this, "sharp_claws", function(this, s)
            local a = this.melee.attacks[3]
            a.disabled = nil
            local m = E:get_template(a.mod)
            m.dps.damage_min = s.damage[s.level]
            m.dps.damage_max = s.damage[s.level]
            m.extra_bleeding_damage = s.extra_damage[s.level]
        end)

        upgrade_skill(this, "kings_roar", function(this, s)
            local a = this.timed_attacks.list[1]
            a.disabled = nil
            local m = E:get_template(a.mod)
            m.modifier.duration = s.stun_duration[s.level]
        end)

        upgrade_skill(this, "lions_fur", function(this, s)
            this.lion_fur_extra = s.extra_hp[s.level]
        end)

        upgrade_skill(this, "grievous_bites", function(this, s)
            local a = this.melee.attacks[4]
            a.disabled = nil
            a.damage_max = s.damage[s.level]
            a.damage_min = s.damage[s.level]
        end)

        upgrade_skill(this, "ultimate", function(this, s)
            this.ultimate.disabled = nil
            local u = E:get_template(s.controller_name)
            u.count = s.count[s.level]
            local e = E:get_template(u.entity)
            e.custom_attack.damage_boss = s.damage_boss[s.level]
            local m = E:get_template("mod_lion_bruce_damage")
            m.dps.damage_max = s.damage_per_tick[s.level]
            m.dps.damage_min = s.damage_per_tick[s.level]
        end)

        this.health.hp_max = this.health.hp_max + this.lion_fur_extra
        update_regen(this)

        this.health.hp = this.health.hp_max
    end

    function scripts.hero_bruce.insert(this, store)
        if not scripts.hero_basic.insert(this, store) then
            return false
        end

        local a = E:create_entity("aura_bruce_hps")

        a.aura.source_id = this.id
        a.aura.ts = store.tick_ts
        a.pos = this.pos

        queue_insert(store, a)

        return true
    end

    function scripts.hero_bruce.update(this, store)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta

        this.health_bar.hidden = false

        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_174_0
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                a = this.timed_attacks.list[1]
                skill = this.hero.skills.kings_roar

                if ready_to_use_skill(a, store) then
                    local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, a.vis_flags,
                        a.vis_bans)

                    if not targets or #targets < a.min_count then
                        SU.delay_attack(store, a, 0.13333333333333333)
                    else
                        S:queue(a.sound, a.sound_args)
                        U.animation_start(this, a.animation, nil, store.tick_ts)

                        if SU.y_hero_wait(store, this, a.hit_time) then
                            -- block empty
                        else
                            SU.hero_gain_xp_from_skill(this, skill)

                            a.ts = store.tick_ts
                            targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, a.vis_flags,
                                a.vis_bans)

                            if targets then
                                for i, target in ipairs(targets) do
                                    if i > a.max_count then
                                        break
                                    end

                                    local m = E:create_entity(a.mod)
                                    m.modifier.source_id = this.id
                                    m.modifier.target_id = target.id
                                    queue_insert(store, m)
                                end
                            end

                            SU.y_hero_animation_wait(this)
                        end

                        goto label_174_0
                    end
                end

                if ready_to_use_skill(this.ultimate, store) then
                    local target = find_target_at_critical_moment(this, store, 150)

                    if target and target.pos and valid_rally_node_nearby(target.pos) then
                        S:queue(this.sound_events.change_rally_point)
                        local e = E:create_entity(this.hero.skills.ultimate.controller_name)

                        e.pos = V.vclone(target.pos)
                        e.damage_factor = this.unit.damage_factor
                        queue_insert(store, e)

                        this.ultimate.ts = store.tick_ts
                        SU.hero_gain_xp_from_skill(this, this.ultimate)
                    else
                        this.ultimate.ts = this.ultimate.ts + 1
                    end
                end
                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta ~= A_NO_TARGET then
                    -- block empty
                elseif SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end
            end

            ::label_174_0::

            coroutine.yield()
        end
    end

    scripts.hero_bruce_ultimate = {}

    function scripts.hero_bruce_ultimate.update(this, store)
        local pi, spi, ni
        local target_info = U.find_enemies_in_paths(store.entities, this.pos, this.range_nodes_min,
            this.range_nodes_max, nil, this.vis_flags, this.vis_bans, true, function(e)
                return not U.flag_has(P:path_terrain_props(e.nav_path.pi), TERRAIN_FAERIE)
            end)

        if target_info then
            local o = target_info[1].origin

            pi, spi, ni = o[1], o[2], o[3]
        else
            local nearest = P:nearest_nodes(this.pos.x, this.pos.y)

            if #nearest > 0 then
                for _, n in pairs(nearest) do
                    if band(P:path_terrain_props(n[1]), TERRAIN_FAERIE) == 0 then
                        pi, spi, ni = n[1], n[2], n[3]

                        break
                    end
                end
            end
        end

        if pi then
            for i = 1, this.count do
                local e = E:create_entity(this.entity)

                e.nav_path.pi = pi
                e.nav_path.spi = spi
                e.nav_path.ni = ni
                e.damage_factor = this.damage_factor
                queue_insert(store, e)

                spi = km.zmod(spi + 1, 3)
                ni = ni - 2
            end
        end

        queue_remove(store, this)
    end

    scripts.lion_bruce = {}

    function scripts.lion_bruce.insert(this, store)
        this.pos = P:node_pos(this.nav_path)

        if not this.pos then
            return false
        end

        return true
    end

    function scripts.lion_bruce.update(this, store)
        local attack = this.custom_attack
        local start_ts = store.tick_ts
        local fading

        this.tween.ts = store.tick_ts

        while true do
            local next, new = P:next_entity_node(this, store.tick_length)

            if not fading and
                (not next or not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) or store.tick_ts - start_ts >=
                    this.duration) then
                fading = true
                this.tween.remove = true
                this.tween.reverse = true
                this.tween.ts = store.tick_ts

                S:queue(this.sound_events.custom_loop_end)
            end

            if next then
                U.set_destination(this, next)
            end

            local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

            U.animation_start(this, an, af, store.tick_ts)
            U.walk(this, store.tick_length)

            if not fading and store.tick_ts - attack.ts > attack.cooldown then
                attack.ts = store.tick_ts

                local targets = U.find_enemies_in_range(store.entities, this.pos, 0, attack.range, attack.vis_flags,
                    attack.vis_bans)

                if targets then
                    for _, e in pairs(targets) do
                        if U.flag_has(e.vis.flags, F_BOSS) then
                            local d = E:create_entity("damage")

                            d.value = attack.damage_boss * this.damage_factor
                            d.source_id = this.id
                            d.target_id = e.id
                            d.damage_type = attack.damage_type

                            queue_damage(store, d)

                            this.render.sprites[1].loop_forced = false

                            U.y_animation_play(this, "boom", nil, store.tick_ts)

                            goto label_179_0
                        elseif U.flags_pass(e.vis, attack) then
                            for _, mn in pairs(attack.mods) do
                                local m = E:create_entity(mn)

                                m.modifier.target_id = e.id
                                m.modifier.source_id = this.id

                                queue_insert(store, m)
                            end

                            goto label_179_0
                        end
                    end
                end
            end

            coroutine.yield()
        end

        ::label_179_0::

        queue_remove(store, this)
    end

    scripts.hero_bolverk = {}
    function scripts.hero_bolverk.level_up(this, store)
        local hl, ls = level_up_basic(this, store)

        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

        upgrade_skill(this, "slash", function (this, s)
            this.melee.attacks[2].disabled = nil
            this.melee.attacks[2].damage_min = s.damage_min[s.level]
            this.melee.attacks[2].damage_max = s.damage_max[s.level]
        end)

        upgrade_skill(this, "scream", function (this, s)
            this.timed_attacks.list[1].disabled = nil
            local mod = E:get_template("mod_bolverk_fire")
            mod.dps.damage_min = s.fire_damage[s.level]
            mod.dps.damage_max = s.fire_damage[s.level]
        end)

        upgrade_skill(this, "berserker", function (this, s)
            this.berserker_factor = s.factor[s.level]
        end)

        this.health.hp = this.health.hp_max
    end
    function scripts.hero_bolverk.insert(this, store)
        this.hero.fn_level_up(this, store)
        this.melee.order = U.attack_order(this.melee.attacks)
        return true
    end

    function scripts.hero_bolverk.update(this, store)
        local h = this.health
        local he = this.hero
        local brk, sta, a, skill

        U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_223_0
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this,"respawn", nil, store.tick_ts)
                end

                local factor = (this.health.hp / this.health.hp_max) * (1 - this.berserker_factor) + this.berserker_factor
                this.timed_attacks.list[1].cooldown = this.timed_attacks.list[1].raw_cooldown * factor
                this.melee.attacks[1].cooldown = this.melee.attacks[1].raw_cooldown * factor
                this.melee.attacks[2].cooldown = this.melee.attacks[2].raw_cooldown * factor

                a = this.timed_attacks.list[1]

                if ready_to_use_skill(a, store) then
                    local targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range,
                        a.vis_flags, a.vis_bans)

                    if not targets or #targets < a.min_count then
                        SU.delay_attack(store, a, 0.13333333333333333)
                    else
                        S:queue(a.sound, a.sound_args)
                        U.animation_start(this, a.animation, nil, store.tick_ts)

                        if SU.y_hero_wait(store, this, a.hit_time) then
                            -- block empty
                        else
                            targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range,
                                a.vis_flags, a.vis_bans)

                            if targets then
                                for _, target in pairs(targets) do
                                    local m1 = E:create_entity(a.mods[1])
                                    m1.modifier.target_id = target.id
                                    m1.modifier.source_id = this.id

                                    queue_insert(store, m1)
                                    local m2 = E:create_entity(a.mods[2])
                                    m2.modifier.target_id = target.id
                                    m2.modifier.source_id = this.id
                                    queue_insert(store, m2)
                                end
                            end
                            scripts.heal(this, (this.health.hp_max - this.health.hp) * 0.06)
                            SU.y_hero_animation_wait(this)
                            SU.hero_gain_xp_from_skill(this,this.hero.skills.scream)
                            a.ts = store.tick_ts
                        end

                        goto label_223_0
                    end
                end

                if this.melee then
                    brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                    if brk or sta ~= A_NO_TARGET then
                        goto label_223_0
                    end
                end

                if SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end
            end

            ::label_223_0::

            coroutine.yield()
        end
    end

end
