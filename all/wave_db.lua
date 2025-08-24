-- chunkname: @./all/wave_db.lua
local log = require("klua.log"):new("wave_db")
local km = require("klua.macros")
local FS = love.filesystem
local E = require("entity_db")

require("constants")

local wave_db = {}

wave_db.db = nil
wave_db.game_mode = nil

local gms = {
    [GAME_MODE_CAMPAIGN] = "campaign",
    [GAME_MODE_HEROIC] = "heroic",
    [GAME_MODE_IRON] = "iron",
    -- [GAME_MODE_ENDLESS] = "endless"
    [GAME_MODE_ENDLESS] = "campaign" -- endless模式下也加载普通模式的波次
}

function wave_db:patch_waves(criket)
    self.db.groups = {}
    local criket_groups = criket.groups

    if not criket.fps_transformed then
        criket.fps_transformed = true

        for _, group in pairs(criket_groups) do
            for key, value in pairs(group) do
                if key == "delay" then
                    value = value * FPS
                elseif key == "spawns" then
                    for _, single_spawn in pairs(value) do
                        for k, v in pairs(single_spawn) do
                            if k == "interval" or k == "interval_next" then
                                single_spawn[k] = v * FPS
                            end
                        end
                    end
                end
            end
        end
    end

    self.db.groups[1] = {
        interval = 0,
        waves = criket_groups
    }
end

function wave_db:load(level_name, game_mode, endless)
    self.game_mode = game_mode
    self.is_endless = endless
    local suffix = gms[game_mode]
    local wn = string.format("%s/data/waves/%s_waves_%s", KR_PATH_GAME, level_name, suffix)
    local wf = string.format("%s.lua", wn)

    log.debug("Loading %s", wn)

    local ok, wchunk = pcall(FS.load, wf)

    if not ok then
        log.error("Failed to load %s: error: %s", wf, wchunk)

        return
    end

    local ok, wtable = pcall(wchunk)

    if not ok then
        log.error("Failed to eval chunk for %s: error: %s", wf, wtable)

        return
    end

    wave_db.db = wtable

    local wen = string.format("%s_extra", wn)
    local wef = string.format("%s.lua", wen)

    if FS.isFile(wef) then
        log.info("Found extra waves: %s", wef)

        local ok, wchunk = pcall(FS.load, wef)

        if not ok then
            log.error("Failed to load %s: error: %s", wef, wchunk)

            return
        end

        local ok, extraw = pcall(wchunk)

        if not ok then
            log.error("Failed to eval extra waves chunk for %s: error: %s", wef, extraw)

            return
        end

        self:add_waves_to_groups(extraw)
    end

    if endless then
        local storage = require("all.storage")
        local endless_history = storage:load_endless(level_name)
        if endless_history then
            wave_db.endless = endless_history
            wave_db.endless.load_from_history = true
        else
            wave_db.endless = {
                enemy_list = {},
                total_lives_cost = 0,
                enemy_health_factor = 1,
                enemy_damage_factor = 1,
                enemy_speed_factor = 1,
                enemy_health_damage_factor = 1,
                soldier_health_factor = 1,
                soldier_damage_factor = 1,
                tower_damage_factor = 1,
                soldier_cooldown_factor = 1,
                tower_cooldown_factor = 1,
                hero_damage_factor = 1,
                hero_cooldown_factor = 1,
                interval = 0,
                available_paths = {},
                avg_interval = 0,
                avg_interval_next = 0,
                extra_cash = 0,
                std_waves_count = 0,
                spawn_count_per_wave = 0,
                lives_cost_per_wave = 0,
                load_from_history = false,
                upgrade_levels = {
                    health = 0,
                    soldier_damage = 0,
                    soldier_cooldown = 0,
                    tower_damage = 0,
                    tower_cooldown = 0,
                    hero_damage = 0,
                    hero_cooldown = 0,
                    archer_bleed = 0,
                    archer_multishot = 0,
                    archer_insight = 0,
                    archer_trick = 0
                }
            }
            local endless = wave_db.endless
            local group = wave_db:group(#wave_db:groups() - 1 >= 1 and #wave_db:groups() - 1 or 1)
            local waves = group.waves

            local total_spawns = 0
            for _, wave in pairs(waves) do
                for _, spawn in pairs(wave.spawns) do
                    endless.avg_interval = endless.avg_interval + spawn.interval
                    endless.avg_interval_next = endless.avg_interval_next + spawn.interval_next
                    total_spawns = total_spawns + 1
                    local tpl = E:get_template(spawn.creep)
                    if tpl and tpl.enemy then
                        endless.total_lives_cost = endless.total_lives_cost + tpl.enemy.lives_cost * spawn.max
                    end
                end
            end
            endless.std_waves_count = #waves
            endless.spawn_count_per_wave = math.ceil(total_spawns / #waves)
            endless.lives_cost_per_wave = math.ceil(endless.total_lives_cost / #waves)
            endless.avg_interval = endless.avg_interval / total_spawns
            endless.avg_interval_next = endless.avg_interval_next / total_spawns

            for _, group in pairs(wave_db:groups()) do
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
        end
    end
end

function wave_db:add_waves_to_groups(gwaves)
    if self.db.groups then
        for g, more_waves in pairs(gwaves) do
            log.info("adding %d extra waves to group %d", #more_waves.waves, g)

            if not self.db.groups[g] then
                log.warning("Adding waves to inexistent group %d")

                self.db.groups[g] = {
                    waves = {}
                }
            end

            for _, w in pairs(more_waves.waves) do
                table.insert(self.db.groups[g].waves, w)
            end
        end
    else
        log.error("Unable to add waves. No wave groups have been loaded yet.")
    end
end

function wave_db:groups()
    return self.db.groups
end

function wave_db:group(group_number)
    return self.db.groups[group_number]
end

function wave_db:initial_gold()
    return self.db.cash or self.db.gold
end

function wave_db:initial_lives()
    return self.db.lifes
end

function wave_db:groups_count()
    if self.is_endless then
        return 0
    else
        return #self.db.groups
    end
end

function wave_db:waves_count()
    if self.is_endless then
        return 0
    else
        local result = 0

        for __, group in pairs(self.db.groups) do
            result = result + #group.waves
        end

        return result
    end
end

function wave_db:has_group(i)
    if self.is_endless then
        return i > 0
    else
        return i <= #self.db.groups
    end
end

function wave_db:get_group(i)
    if self.is_endless then
        return self:get_endless_group(i)
    else
        return self.db.groups[i]
    end
end

function wave_db:get_endless_early_wave_reward_factor()
    if self.db and self.db.nextWaveRewardMoneyMultiplier then
        return self.db.nextWaveRewardMoneyMultiplier
    else
        return 1
    end
end

function wave_db:get_endless_score_config()
    if self.db and self.db.score then
        return table.deepclone(self.db.score)
    else
        return nil
    end
end

function wave_db:get_endless_boss_config(i)
    local out = {}
    local db = self.db
    local dif_max = #db.difficulties
    local dif_level = math.ceil(i / 10)
    local dif_idx = km.clamp(1, dif_max, dif_level)
    local dif = db.difficulties[dif_idx]
    local dbc = dif.bossConfig

    out.chance = dbc.powerChance + dbc.powerChanceIncrement * dif_level
    out.cooldown = math.random(dbc.powerCooldownMin, dbc.powerCooldownMax)
    out.multiple_attacks_chance = dbc.powerMultiChance
    out.power_chances = dbc.powerDistribution
    out.powers_config_dif = dbc.powerConfig
    out.boss_config_dif = dbc
    out.powers_config = db.bossConfig.powerConfig

    return out
end

function wave_db:get_endless_group(i)
    local group = {}
    local endless = self.endless
    endless.current_wave_count = i
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
            local this_spawn_lives_cost = math.floor(endless.lives_cost_per_wave / endless.spawn_count_per_wave *
                                                         (0.8 + 0.4 * j / endless.spawn_count_per_wave))
            local creep = table.random(enemy_list)
            local tpl = E:get_template(creep)
            local max = math.ceil(this_spawn_lives_cost / tpl.enemy.lives_cost)
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

function wave_db:set_entity_progression(e, wave_idx)
    local function prog_value(key, raw_value)
        local t
        local tall = self.db.enemyProgression
        local tdefault = self.db.enemyProgression.DEFAULT

        if string.find(key, ".", 1, true) ~= nil then
            local parts = string.split(key, ".")

            t = self.db.enemyProgression

            for i = 1, #parts do
                t = t[parts[i]]
            end

            if not t then
                log.error("entity progression not found for key %s", key)

                return raw_value
            end
        elseif tall[e.template_name] and tall[e.template_name][key] then
            t = table.merge(tdefault[key] or {}, tall[e.template_name][key], true)
        else
            t = tdefault[key] or {}
        end

        if not self.db.vars.first_entity_wave[e.template_name] then
            self.db.vars.first_entity_wave[e.template_name] = wave_idx
        end

        local waves_count = wave_idx

        if t.activeAfterWave then
            if wave_idx < t.activeAfterWave then
                log.paranoid("(%s)%s - %s activeAfterWave %s", e.id, e.template_name, key, t.activeAfterWave)

                return raw_value
            end

            waves_count = waves_count - t.activeAfterWave
        else
            waves_count = waves_count - self.db.vars.first_entity_wave[e.template_name]
        end

        local mult, val

        if t.factor_steps and #t.factor_steps > 0 then
            local cycle = t.cicle or 1
            local step_idx = math.ceil(waves_count / cycle)

            step_idx = km.clamp(1, #t.factor_steps, step_idx)
            mult = t.factor_steps[step_idx]
            val = mult * raw_value
        else
            local factor = t.factor or 1
            local base = t.base or 1
            local cycle = t.cicle or 1

            mult = base * math.pow(factor, math.floor(waves_count / cycle))

            local limit = t.limit or factor > 1 and 99999 or -99999

            if factor > 1 then
                mult = math.min(mult, limit)
            elseif factor < 1 then
                mult = math.max(mult, limit)
            end

            val = mult * raw_value

            if t.limit_value then
                if factor < 1 then
                    val = math.max(val, t.limit_value)
                else
                    val = math.min(val, t.limit_value)
                end
            end
        end

        return val
    end

    local function prog_factor(key)
        return prog_value(key, 1)
    end

    if e.enemy then
        e.enemy.gold = km.clamp(0, e.enemy.gold, km.round(prog_value("gold", e.enemy.gold)))

        if e.health then
            e.health.hp_max = km.round(prog_value("health", e.health.hp_max))
            e.health.hp_max = km.round(prog_factor("megaHealth") * e.health.hp_max)
            e.health.armor = prog_value("armor", e.health.armor)
            e.health.magic_armor = prog_value("magicArmor", e.health.magic_armor)
        end

        if e.melee and e.melee.attacks[1] then
            local damage_factor = prog_factor("damage")

            e.melee.attacks[1].damage_max = km.round(damage_factor * e.melee.attacks[1].damage_max)
            e.melee.attacks[1].damage_min = km.round(damage_factor * e.melee.attacks[1].damage_min)
        end
    end

    if e.endless and e.endless.factor_map then
        for _, item in pairs(e.endless.factor_map) do
            local fmt

            fmt = item[3] and "e.%s = round(prog_value('%s', e.%s))" or "e.%s = prog_value('%s', e.%s)"

            local n = string.format(fmt, item[2], item[1], item[2])
            local nf = loadstring(n)
            local env = {}

            env.e = e
            env.wave_idx = wave_idx
            env.prog_value = prog_value
            env.round = km.round

            setfenv(nf, env)
            nf()
            log.paranoid("  ENDLESS - factor_map: %s", n)
        end
    end

    log.paranoid("ENDLESS - w:%s (%s)%s | factors - health:%s damage:%s gold:%s armor:%s magic_armor:%s megaHealth:%s ",
        wave_idx, e.id, e.template_name, prog_factor("health"), prog_factor("damage"), prog_factor("gold"),
        prog_factor("armor"), prog_factor("magicArmor"), prog_factor("megaHealth"))
end

return wave_db
