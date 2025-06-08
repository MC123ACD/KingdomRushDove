local bit = require("bit")
bor = bit.bor
band = bit.band
bnot = bit.bnot
E = require("entity_db")
require("constants")
IS_PHONE = KR_TARGET == "phone"
IS_PHONE_OR_TABLET = KR_TARGET == "phone" or KR_TARGET == "tablet"
IS_CONSOLE = KR_TARGET == "console"
barrack_templates = {"tower_barrack_1", "tower_barrack_2", "tower_barrack_3", "tower_assassin", "tower_templar",
                     "tower_paladin", "tower_barbarian", "tower_elf", "tower_barrack_amazonas", "tower_barrack_dwarf",
                     "tower_barrack_pirates", "tower_barrack_mercenaries", "tower_blade", "tower_forest"}
function vec_2(v1, v2)
    return {
        x = v1,
        y = v2
    }
end

function vec_1(v1)
    return {
        x = v1,
        y = v1
    }
end

function r(x, y, w, h)
    return {
        pos = vec_2(x, y),
        size = vec_2(w, h)
    }
end

function fts(v)
    return v / FPS
end

function np(pi, spi, ni)
    return {
        dir = 1,
        pi = pi,
        spi = spi,
        ni = ni
    }
end

function d2r(d)
    return d * math.pi / 180
end

function RT(name, ref)
    return E:register_t(name, ref)
end

function AC(tpl, ...)
    return E:add_comps(tpl, ...)
end

function CC(comp_name)
    return E:clone_c(comp_name)
end
