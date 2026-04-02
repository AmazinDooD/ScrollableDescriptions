scr = SMODS.current_mod
SCR = {mod = scr, requires_restart = "", easing = "insine", ease_delay = 0.1}

SCR.important = SMODS.Gradient{
    key = "important",
    colours = {
        HEX("FFD044"),
        HEX("FFFF16")
    },
    cycle = 0.5
}

local event_hook = EventManager.add_event
function EventManager:add_event(...)
    if not self.queues.scr_x or not self.queues.scr_y then
        -- these two extra event queues are added in order to allow for smoother movement without being interrupted by vanilla processes or other mods
        self.queues.scr_x = {}
        self.queues.scr_y = {}
    end
    event_hook(self, ...)
end

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
    if not card.scr then card.scr = (card.config.h_popup_config and card.config.h_popup_config.offset) and card.config.h_popup_config.offset or {x=0,y=0} end

    if dir.x ~= 0 then
        G.E_MANAGER:add_event(Event({
        trigger = 'ease',
        ease = SCR.easing, --easing type
        ref_table = card.scr,
        ref_value = "x",
        ease_to = card.scr.x+dir.x, --end value
        delay = SCR.ease_delay, --time taken
        timer = "REAL",
        func = (function(t) return t end),
        }), "scr_x")
    end

    if dir.y ~= 0 then
        G.E_MANAGER:add_event(Event({
            trigger = 'ease',
            ease = SCR.easing, --easing type
            ref_table = card.scr,
            ref_value = "y",
            ease_to = card.scr.y+dir.y, --end value
            delay = SCR.ease_delay, --time taken
            timer = "REAL",
            func = (function(t) return t end),
        }), "scr_y")
    end
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
    local slider = create_slider{
        label = "Move Distance",
        w = 6.3,
        scale = 0.9,
        ref_table = scr.config,
        ref_value = "move_distance",
        min = 0,
        max = 2,
        decimal_places = 1
    }

    local keybinds_text = {n = G.UIT.R, config = {align = "cm", colour = G.C.CLEAR, minh = 0.65}, nodes = {
        {n = G.UIT.T, config = {align = "cm", colour = G.C.WHITE, text = "Keybinds", scale = 0.5}}
    }}

    local keybind_buttons = {}

    for _, dir in pairs({"up", "down", "left", "right", "home"}) do
        table.insert(keybind_buttons,
            {
                n = G.UIT.R,
                config = { button = "scr_" .. dir .. "_keybind", colour = G.C.RED, padding = 0.2, r = 0.1, shadow = true, hover = true },
                nodes = {
                    {
                        n = G.UIT.O,
                        config = {
                            object = DynaText {
                                string = dir:gsub("^%l", string.upper) .. " Keybind: " .. scr.config[dir .. "_keybind"],
                                scale = 0.5,
                                colours = { G.C.WHITE }
                            }
                        }
                    }
                }
            })
    end

    local keybind_container = {
        n = G.UIT.R,
        config = {align = "cm"},
        nodes = {
            {n = G.UIT.C, config = {align = "cm", colour = G.C.UI.TEXT_INACTIVE, padding = 0.1, r=0.05}, nodes = keybind_buttons}
        },
    }
    

    local requires_restart_dynatext = {n = G.UIT.R, config = {padding = 0.05, align = "cm"}, nodes = {
        {n = G.UIT.O, config = {object = DynaText{
            string = {{
                ref_table = SCR,
                ref_value = "requires_restart",
            }},
            scale = 0.35,
            colours = {SCR.important},
            align = "cm",
            maxw = 4,
        }}}
    }}

    local config_nodes = {n=G.UIT.ROOT, config = {align = "cm", colour = G.C.L_BLACK, minw = 4, minh = 4}, nodes = {
        {n = G.UIT.C, config = {align = "cm"}, nodes = {
            slider,
            keybinds_text,
            keybind_container,
            requires_restart_dynatext,
        }}
    }}

    return config_nodes
end

SMODS.Keybind {
    key_pressed = scr.config.up_keybind:lower(),
    event = "pressed",
    action = function(self) 
        local hovered = G and G.CONTROLLER and (G.CONTROLLER.focused.target or G.CONTROLLER.hovering.target)
        if hovered then move_popup(hovered, {x=0,y=0 - scr.config.move_distance}) end
    end
}

SMODS.Keybind {
    key_pressed = scr.config.down_keybind:lower(),
    event = "pressed",
    action = function(self) 
        local hovered = G and G.CONTROLLER and (G.CONTROLLER.focused.target or G.CONTROLLER.hovering.target)
        if hovered then move_popup(hovered, {x=0,y=scr.config.move_distance}) end
    end
}

SMODS.Keybind {
    key_pressed = scr.config.left_keybind:lower(),
    event = "pressed",
    action = function(self) 
        local hovered = G and G.CONTROLLER and (G.CONTROLLER.focused.target or G.CONTROLLER.hovering.target)
        if hovered then move_popup(hovered, {x=0 - scr.config.move_distance,y=0}) end
    end
}

SMODS.Keybind {
    key_pressed = scr.config.right_keybind:lower(),
    event = "pressed",
    action = function(self) 
        local hovered = G and G.CONTROLLER and (G.CONTROLLER.focused.target or G.CONTROLLER.hovering.target)
        if hovered then move_popup(hovered, {x=scr.config.move_distance,y=0}) end
    end
}

SMODS.Keybind {
    key_pressed = scr.config.home_keybind:lower(),
    action = function(self)
        local hovered = G and G.CONTROLLER and (G.CONTROLLER.focused.target or G.CONTROLLER.hovering.target)
        if not hovered then return end

        hovered.scr = hovered.scr or {x=0,y=0} -- ensure it exists first

        move_popup(hovered, {
            x = -hovered.scr.x,
            y = -hovered.scr.y
        }) -- this just negates it back to 0
    end
}

SMODS.Atlas {
    key = "modicon",
    path = "modicon.png",
    px = 34,
    py = 34
}

