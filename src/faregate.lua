-- farebox/src/faregate.lua
-- Faregate node
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


local function _farebox_open(pos, node)
    node.name = "farebox:faregate_open"
    minetest.swap_node(pos, node)
    minetest.sound_play("doors_steel_door_open", {
        pos = pos,
        gain = 0.3,
        max_hear_distance = 10
    })

    local timer = minetest.get_node_timer(pos)
    timer:start(1)
end

local function _farebox_close(pos, node)
    node.name = "farebox:faregate"
    minetest.swap_node(pos, node)
    minetest.sound_play("doors_steel_door_close", {
        pos = pos,
        gain = 0.3,
        max_hear_distance = 10
    })
end

minetest.register_node("farebox:faregate", {
    description = S("Faregate"),
    tiles = {
        "default_steel_block.png"
    },
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            { -0.5,    -0.5, -0.4375, -0.4375, 0.5,    0.4375 }, -- NodeBox3
            { 0.4375,  -0.5, -0.4375, 0.5,     0.5,    0.4375 }, -- NodeBox5
            { -0.4375, -0.5, -0.0625, -0.0625, 0.6875, 0 },      -- NodeBox6
            { 0.0625,  -0.5, -0.0625, 0.4375,  0.6875, 0 },      -- NodeBox7
        }
    },
    mesecons = {
        effector = {
            rules = mesecon.rules.default,
            action_on = function(pos, node)
                _farebox_open(pos, node)
            end,
        }
    },
    can_dig = farebox.can_dig,
    after_place_node = function(pos, player, _)
        local meta = minetest.get_meta(pos)
        local player_name = player:get_player_name()

        meta:set_string("owner", player_name)
        meta:set_string("infotext", S("@1 (Owned by @2)",
            S("Faregate"), player_name
        ))

        local inv = meta:get_inventory()
        inv:set_size("request", 1)
        inv:set_size("main", 32)
    end,
    groups = { cracky = 3, farebox = 1 },
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        farebox.show_formspec(pos, player)
    end,
    allow_metadata_inventory_put = farebox.allow_metadata_inventory_take_put,
    allow_metadata_inventory_take = farebox.allow_metadata_inventory_take_put,
    allow_metadata_inventory_move = farebox.allow_metadata_inventory_move,

    _farebox_open = function(pos)
        local node = minetest.get_node(pos)
        _farebox_open(pos, node)
    end,
    on_timer = function(pos)
        local node = minetest.get_node(pos)
        _farebox_close(pos, node)
    end,
})

minetest.register_node("farebox:faregate_open", {
    tiles = {
        "default_steel_block.png"
    },
    paramtype2 = "facedir",
    mesecons = {
        effector = {
            rules = mesecon.rules.default,
            action_on = function(pos, node)
                _farebox_close(pos, node)

                local timer = minetest.get_node_timer(pos)
                timer:stop()
            end,
        }
    },
    groups = { not_in_creative_inventory = 1, cracky = 3 },
    drawtype = "nodebox",
    paramtype = "light",
    node_box = {
        type = "fixed",
        fixed = {
            { -0.5,    -0.5, -0.4375, -0.4375, 0.5,    0.4375 }, -- NodeBox3
            { 0.4375,  -0.5, -0.4375, 0.5,     0.5,    0.4375 }, -- NodeBox5
            { -0.4375, -0.5, -0.0625, -0.375,  0.6875, 0.3125 }, -- NodeBox6
            { 0.375,   -0.5, -0.0625, 0.4375,  0.6875, 0.3125 }, -- NodeBox7
        }
    },
    drop = "farebox:faregate",

    on_timer = function(pos)
        local node = minetest.get_node(pos)
        _farebox_close(pos, node)
    end,
})
