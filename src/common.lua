-- farebox/src/common.lua
-- Common functions and definition tables
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

local S = minetest.get_translator("farebox")
local FS = function(...) return minetest.formspec_escape(S(...)) end

-- Formspec

function farebox.show_formspec(pos, player)
    if not player:is_player() then return end
    local formname = "farebox:farebox_" .. minetest.pos_to_string(pos, 0)
    local meta = minetest.get_meta(pos)
    local owner = meta:get_string("owner")
    local player_name = player:get_player_name()

    if player_name == owner then
        local loc = "nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z
        minetest.show_formspec(player_name, formname,
            "size[8,10]" ..
            "label[0.5,0.5;" .. FS("Entrance fee:") .. "]" ..
            "list[" .. loc .. ";request;2.5,0.25;1,1;]" ..
            "button_exit[6,0.25;2,1;open;" .. FS("Open") .. "]" ..
            "list[" .. loc .. ";main;0,1.5;8,4]" ..
            "list[current_player;main;0,5.75;8,1;]" ..
            "list[current_player;main;0,7;8,3;8]" ..
            "listring[]" .. default.get_hotbar_bg(0, 5.75)
        )
    else
        local inv = meta:get_inventory()
        local stack = inv:get_stack("request", 1)
        minetest.show_formspec(player_name, formname,
            "size[8,4]" ..
            "label[0.5,1.5;" .. FS("Owner Wants:") .. "]" ..
            "item_image_button[2.5,1.25;1,1;" ..
            stack:get_name() .. ";buy;\n\n\b\b\b\b\b" ..
            stack:get_count() .. "]" ..
            "label[3.5,1.5;" .. FS("(Click on the item to pay)") .. "]"
        )
    end
end

-- Access control

function farebox.allow_action(pos, player)
    if not player:is_player() then return end
    local meta = minetest.get_meta(pos)
    local name = player:get_player_name()
    if meta:get_string("owner") == name or minetest.check_player_privs(name, { protection_bypass = true }) then
        return true
    end
end

function farebox.allow_metadata_inventory_take_put(pos, listname, index, stack, player)
    return farebox.allow_action(pos, player) and stack:get_count() or 0
end

function farebox.allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
    return farebox.allow_action(pos, player) and count or 0
end

function farebox.can_dig(pos, player)
    local meta = minetest.get_meta(pos)
    local name = player:get_player_name()
    local inv = meta:get_inventory()
    return inv:is_empty("main") and inv:is_empty("request") and farebox.allow_action(pos, player)
end

-- Mesecons

farebox.mesecon_rules = mesecon.merge_rule_sets(mesecon.rules.default, {
    -- Custom rules to handle doors
    { x = 0, y = -2, z = 0 },
    { x = 0, y = 2,  z = 0 },
})
