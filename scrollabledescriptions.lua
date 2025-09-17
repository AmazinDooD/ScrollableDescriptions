scr = SMODS.current_mod
SCR = {mod = scr, requires_restart = ""}

SCR.important = SMODS.Gradient{
    key = "important",
    colours = {
        HEX("FFD044"),
        HEX("FFFF16")
    },
    cycle = 0.5
}

if not _R then _R = SMODS.restart_game end

local ahp = Card.align_h_popup
function Card:align_h_popup()
    local ret = ahp(self)
    if not ret then return ret end -- only here so that vs code doesnt moan at me
    if not self.scr then self.scr = {x=0,y=0} end
    ret.offset.x = ret.offset.x + self.scr.x
    ret.offset.y = ret.offset.y + self.scr.y
    return ret
end

---Move a card's hover popup by the amount given in dir. dir should be a table with an x key and a y key.
---@param card Card
---@param dir table
function move_popup(card, dir)
    if not card or not dir then return end
    if not card.scr then card.scr = card.config.h_popup_config.offset and card.config.h_popup_config.offset or {x=0,y=0} end
    card.scr.x = card.scr.x + dir.x
    card.scr.y = card.scr.y + dir.y
end

function keybind_config_menu(key)
    local keybind_text = {
        "Keypad keys are prefixed by 'kp', e.g. 'kp7', 'kp.'",
        "Arrow keys are their direction, e.g 'left', 'up'",
        "The Enter key is 'return'",
        "(But for some reason, the keypad's enter is 'kpenter')"
    }
    return {
        definition = create_UIBox_generic_options{
            back_func = "scr_go_back",
            contents = {
                {n = G.UIT.C, config = {align = "cm", padding = 0.1}, nodes = {
                    {n = G.UIT.R, config = {align = "cm", padding = 0.05}, nodes = {
                        create_text_input{
                            max_length = 12,
                            all_caps = true,
                            ref_table = scr.config,
                            ref_value = key:lower().."_keybind",
                            align = "cm",
                            callback = function()
                                SMODS.save_mod_config(scr)
                            end
                        },
                        {n = G.UIT.C, config = {align = "cm", padding = 0.05}, nodes = {
                            {n = G.UIT.T, config = {text = "Enter "..key.." Keybind", scale = 0.5, align="cm"}}
                        }},
                    }},
                    {n = G.UIT.R, config = {align = "cm", padding = 0.05}, nodes = {
                        {n = G.UIT.T, config = {text = keybind_text[1], scale = 0.2, align = "cm"}},
                    }},
                    {n = G.UIT.R, config = {align = "cm", padding = 0.05}, nodes = {
                        {n = G.UIT.T, config = {text = keybind_text[2], scale = 0.2, align = "cm"}},
                    }},
                    {n = G.UIT.R, config = {align = "cm", padding = 0.05}, nodes = {
                        {n = G.UIT.T, config = {text = keybind_text[3], scale = 0.2, align = "cm"}},
                    }},
                    {n = G.UIT.R, config = {align = "cm", padding = 0.05}, nodes = {
                        {n = G.UIT.T, config = {text = keybind_text[4], scale = 0.2, align = "cm"}},
                    }}}
                }
            }
        }
    }
end

function G.FUNCS.scr_switch_move_distance(arg)
    scr.config.move_distance = arg.to_key
    SMODS.save_mod_config(scr)
end

function G.FUNCS.scr_up_keybind(arg)
    G.FUNCS.overlay_menu(keybind_config_menu("Up"))
end

function G.FUNCS.scr_down_keybind(arg)
    G.FUNCS.overlay_menu(keybind_config_menu("Down"))
end

function G.FUNCS.scr_left_keybind(arg)
    G.FUNCS.overlay_menu(keybind_config_menu("Left"))
end

function G.FUNCS.scr_right_keybind(arg)
    G.FUNCS.overlay_menu(keybind_config_menu("Right"))
end

function G.FUNCS.scr_home_keybind(arg)
    G.FUNCS.overlay_menu(keybind_config_menu("Home"))
end

function G.FUNCS.scr_go_back()
    -- Save config
    SMODS.save_mod_config(scr)
    -- Exit overlay
    G.FUNCS.exit_overlay_menu()
    -- Open this mod's menu
    G.FUNCS.openModUI_ScrDesc()
    SCR.requires_restart = "Keybinds have been updated, restart required!"
end

function scr.config_tab()
    local config_nodes =
    {n=G.UIT.ROOT, config = {align = "cm", colour = G.C.L_BLACK, minw = 4, minh = 4}, nodes = {
        {n = G.UIT.C, config = {align = "cm"}, nodes = {}}
    }}
    config_nodes.nodes[1].nodes[1] = create_option_cycle{
        label = "Move Distance",
        w = 6.3,
        scale = 0.9,
        options = {
            "0.1",
            "0.2",
            "0.3",
            "0.4",
            "0.5",
            "0.6",
            "0.7",
            "0.8",
            "0.9",
            "1.0"
        },
        opt_callback = "scr_switch_move_distance",
        current_option = scr.config.move_distance
    }

    config_nodes.nodes[1].nodes[2] = 
    {n = G.UIT.R, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
        {n = G.UIT.T, config = {align = "cm", colour = G.C.WHITE, text = "Keybinds", scale = 0.5}}
    }}

    config_nodes.nodes[1].nodes[3] = 
    {n = G.UIT.R, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
        {n = G.UIT.B, config = {align = "cm", w = 3.9, h = 0.3}}
    }}

    config_nodes.nodes[1].nodes[4] =
    {n = G.UIT.R, config = {align = "cm", colour = G.C.UI.TEXT_INACTIVE, padding = 0.2, r=0.05}, nodes = {}}

    config_nodes.nodes[1].nodes[4].nodes[1] =
    {n = G.UIT.C, config = {button = "scr_up_keybind", colour = G.C.RED, padding = 0.2, r=0.1, shadow=true, hover =true}, nodes = {
        {n = G.UIT.O, config = {object = DynaText{
            string = "Up Keybind: "..scr.config.up_keybind,
            scale = 0.5,
            colours = {G.C.WHITE}
        }}}
    }}

    config_nodes.nodes[1].nodes[4].nodes[2] =
    {n = G.UIT.C, config = {button = "scr_down_keybind", colour = G.C.RED, padding = 0.2, r=0.1, shadow=true, hover =true}, nodes = {
        {n = G.UIT.O, config = {object = DynaText{
            string = "Down Keybind: "..scr.config.down_keybind,
            scale = 0.5,
            colours = {G.C.WHITE},
        }}}
    }}

    config_nodes.nodes[1].nodes[4].nodes[3] =
    {n = G.UIT.C, config = {button = "scr_left_keybind", colour = G.C.RED, padding = 0.2, r=0.1, shadow=true, hover =true}, nodes = {
        {n = G.UIT.O, config = {object = DynaText{
            string = "Left Keybind: "..scr.config.left_keybind,
            scale = 0.5,
            colours = {G.C.WHITE}
        }}}
    }}

    config_nodes.nodes[1].nodes[4].nodes[4] =
    {n = G.UIT.C, config = {button = "scr_right_keybind", colour = G.C.RED, padding = 0.2, r=0.1, shadow=true, hover =true}, nodes = {
        {n = G.UIT.O, config = {object = DynaText{
            string = "Right Keybind: "..scr.config.right_keybind,
            scale = 0.5,
            colours = {G.C.WHITE}
        }}}
    }}

    config_nodes.nodes[1].nodes[4].nodes[5] =
    {n = G.UIT.C, config = {button = "scr_home_keybind", colour = G.C.RED, padding = 0.2, r=0.1, shadow=true, hover =true}, nodes = {
        {n = G.UIT.O, config = {object = DynaText{
            string = "Home Keybind: "..scr.config.home_keybind,
            scale = 0.5,
            colours = {G.C.WHITE}
        }}}
    }}

    config_nodes.nodes[1].nodes[5] =
    {n = G.UIT.C, config = {padding = 0.05}, nodes = {
        {n = G.UIT.O, config = {object = DynaText{
            string = {{
                ref_table = SCR,
                ref_value = "requires_restart",
            }},
            scale = 0.5,
            colours = {SCR.important},
            align = "cm",
        }}}
    }}
    return config_nodes
end

SMODS.Keybind {
    key_pressed = scr.config.up_keybind:lower(),
    event = "pressed",
    action = function(self) 
        local hovered = G and G.CONTROLLER and (G.CONTROLLER.focused.target or G.CONTROLLER.hovering.target)
        if hovered then move_popup(hovered, {x=0,y=0 - scr.config.move_distance / 10}) end
    end
}

SMODS.Keybind {
    key_pressed = "down",
    event = "pressed",
    action = function(self) 
        local hovered = G and G.CONTROLLER and (G.CONTROLLER.focused.target or G.CONTROLLER.hovering.target)
        if hovered then move_popup(hovered, {x=0,y=scr.config.move_distance / 10}) end
    end
}

SMODS.Keybind {
    key_pressed = "left",
    event = "pressed",
    action = function(self) 
        local hovered = G and G.CONTROLLER and (G.CONTROLLER.focused.target or G.CONTROLLER.hovering.target)
        if hovered then move_popup(hovered, {x=0 - scr.config.move_distance / 10,y=0}) end
    end
}

SMODS.Keybind {
    key_pressed = "right",
    event = "pressed",
    action = function(self) 
        local hovered = G and G.CONTROLLER and (G.CONTROLLER.focused.target or G.CONTROLLER.hovering.target)
        if hovered then move_popup(hovered, {x=scr.config.move_distance / 10,y=0}) end
    end
}

SMODS.Keybind {
    key_pressed = "home",
    action = function(self)
        local hovered = G and G.CONTROLLER and (G.CONTROLLER.focused.target or G.CONTROLLER.hovering.target)
        if hovered then hovered.scr = {x=0,y=0} end
    end
}

SMODS.Atlas {
    key = "modicon",
    path = "modicon.png",
    px = 34,
    py = 34
}
