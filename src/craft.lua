-- farebox/src/craft.lua
-- Handle crafting recipies
--[[
    ISC License

    Copyright (c) 2017 Gabriel Pérez-Cerezo
    Copyright (c) 2024 1F616EMO

    Permission to use, copy, modify, and/or distribute this software for any
    purpose with or without fee is hereby granted, provided that the above
    copyright notice and this permission notice appear in all copies.

    THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
    REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
    AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
    INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
    LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE
    OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
    PERFORMANCE OF THIS SOFTWARE.
]]

local mese = "default:mese_crystal"
if minetest.get_modpath("mesecons_wires") then
    mese = "mesecons:wire_00000000_off"
end

minetest.register_craft({
    output = "farebox:farebox",
    recipe = {
        { "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" },
        { "default:steel_ingot", "",                    "default:steel_ingot" },
        { "default:steel_ingot", mese,                  "default:steel_ingot" },
    }
})

local door = "default:steel_ingot"
if minetest.get_modpath("doors") then
    door = "doors:door_steel"
end

minetest.register_craft({
    output = "farebox:faregate",
    recipe = {
        { "farebox:farebox", door },
    }
})
