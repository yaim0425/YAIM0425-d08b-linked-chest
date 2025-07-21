---------------------------------------------------------------------------------------------------
---> control.lua <---
---------------------------------------------------------------------------------------------------

--- Contenedor de funciones y datos usados
--- unicamente en este archivo
local This_MOD = {}

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------

--- Cargar las funciones
require("__zzzYAIM0425-0000-lib__/control")

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
function This_MOD.start()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Obtener información desde el nombre de MOD
    GPrefix.split_name_folder(This_MOD)

    --- Valores de la referencia
    This_MOD.setting_mod()

    --- Cambiar la propiedad necesaria
    This_MOD.load_events()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Valores de la referencia
function This_MOD.setting_mod()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Información de referencia
    This_MOD.ref = {}
    This_MOD.ref.name = This_MOD.prefix .. "linked-chest"
    This_MOD.ref.entity = prototypes.entity[This_MOD.ref.name]
    This_MOD.ref.recipe = prototypes.recipe[This_MOD.ref.name]
    This_MOD.ref.item = prototypes.item[This_MOD.ref.name]

    --- Valores propios
    This_MOD.channel_default = { This_MOD.prefix .. "default-channel" }
    This_MOD.new_channel = { This_MOD.prefix .. "new-channel" }

    --- Posibles estados de la ventana
    This_MOD.action = {}
    This_MOD.action.none = nil
    This_MOD.action.build = 1
    This_MOD.action.edit = 2
    -- ThisMOD.action.apply = 3
    -- ThisMOD.action.discard = 4
    This_MOD.action.new_channel = 5

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Cargar los eventos a ejecutar
function This_MOD.load_events()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    script.on_event({
        defines.events.on_gui_opened,
        defines.events.on_gui_closed
    }, function(event)
        This_MOD.toggle_gui(This_MOD.create_data(event))
    end)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

--- Crea y agrupar las variables a usar
function This_MOD.create_data(event)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Consolidar la información
    local Data = GPrefix.create_data(event or {}, This_MOD)
    if not Data.gForce then return Data end
    if not event then return Data end

    --- Lista de los postes
    Data.gForce.channel = Data.gForce.channel or {}
    Data.channel = Data.gForce.channel

    --- Devolver el consolidado de los datos
    return Data

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------






---------------------------------------------------------------------------------------------------
--- Desde acá empieza la parte GUI: Esta sección es para cambiar el canal -------------------------
---------------------------------------------------------------------------------------------------

--- Crear o destruir el inicador
function This_MOD.toggle_gui(Data)
    local function validate_open()
        --- Validación
        if Data.GUI.frame_up then return false end
        if not Data.Entity then return false end
        if not Data.Entity.valid then return false end
        if Data.Entity.name ~= This_MOD.ref.name then return false end

        --- Canal inexistente
        if not Data.channel[Data.Entity.link_id] then
            -- This_MOD.on_entity_created({
            --     entity = Data.Node.entity,
            --     force = Data.Node.entity.force
            -- })
        end

        return true
    end
    local function validate_close()
        if not Data.GUI.frame_up then return false end
        if Data.GUI.Action == This_MOD.action.build then return false end
        if not Data.Entity then return false end
        if not Data.Entity.valid then return false end
        if Data.Entity.name ~= This_MOD.ref.name then return false end
        return true
    end

    local function build()
        --- Cambiar los guiones del nombre
        local Prefix = string.gsub(This_MOD.prefix, "%-", "_")

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Crear el cuadro principal
        Data.GUI.frame_up = {}
        Data.GUI.frame_up.type = "frame"
        Data.GUI.frame_up.name = "frame_up"
        Data.GUI.frame_up.direction = "horizontal"
        Data.GUI.frame_up.anchor = {}
        Data.GUI.frame_up.anchor.gui = defines.relative_gui_type.linked_container_gui
        Data.GUI.frame_up.anchor.position = defines.relative_gui_position.top
        Data.GUI.frame_up = Data.Player.gui.relative.add(Data.GUI.frame_up)
        Data.GUI.frame_up.style = "frame"

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Efecto de profundidad
        Data.GUI.frame_old_channel = {}
        Data.GUI.frame_old_channel.type = "frame"
        Data.GUI.frame_old_channel.name = "frame_old_channel"
        Data.GUI.frame_old_channel.direction = "horizontal"
        Data.GUI.frame_old_channel = Data.GUI.frame_up.add(Data.GUI.frame_old_channel)
        Data.GUI.frame_old_channel.style = Prefix .. "frame_body"

        --- Barra de movimiento
        Data.GUI.dropdown_channel = {}
        Data.GUI.dropdown_channel.type = "drop-down"
        Data.GUI.dropdown_channel.name = "drop_down_channel"
        Data.GUI.dropdown_channel = Data.GUI.frame_old_channel.add(Data.GUI.dropdown_channel)
        Data.GUI.dropdown_channel.style = Prefix .. "drop_down_channel"

        --- Cargar los canales
        for _, channel in pairs(Data.channel) do
            Data.GUI.dropdown_channel.add_item(channel.name)
        end
        Data.GUI.dropdown_channel.add_item(This_MOD.new_channel)

        --- Botón para aplicar los cambios
        Data.GUI.button_edit = {}
        Data.GUI.button_edit.type = "sprite-button"
        Data.GUI.button_edit.name = "button_edit"
        Data.GUI.button_edit.sprite = "utility/rename_icon"
        Data.GUI.button_edit.tooltip = { This_MOD.prefix .. "edit-channel" }
        Data.GUI.button_edit = Data.GUI.frame_old_channel.add(Data.GUI.button_edit)
        Data.GUI.button_edit.style = Prefix .. "button_blue"

        --- Botón para aplicar los cambios
        Data.GUI.button_confirm = {}
        Data.GUI.button_confirm.type = "sprite-button"
        Data.GUI.button_confirm.name = "button_confirm"
        Data.GUI.button_confirm.sprite = "utility/check_mark_white"
        Data.GUI.button_confirm.tooltip = { "gui.confirm" }
        Data.GUI.button_confirm = Data.GUI.frame_old_channel.add(Data.GUI.button_confirm)
        Data.GUI.button_confirm.style = Prefix .. "button_green"

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end
    local function destroy()
        Data.GUI.frame_up.destroy()
        Data.GPlayer.GUI = {}
        Data.GUI = Data.GPlayer.GUI
    end

    local function Info()
        --- Valores de la entidad
        Data.GUI.Node = Data.Node[Data.Entity.unit_number]

        --- Selección inicial
        Data.GUI.Pos_start = 0
        for index, _ in pairs(Data.channel) do
            Data.GUI.Pos_start = Data.GUI.Pos_start + 1
            if index == Data.GUI.Node.channel.index then
                break
            end
        end

        --- Selección actual
        Data.GUI.Pos = Data.GUI.Pos_start
    end

    --- Validación
    if not Data.gForces then return end

    --- Acción a ejecutar
    if validate_close() then
        destroy()
    elseif validate_open() then
        Data.GUI.Action = This_MOD.action.build
        build()
        -- Info()
        -- Data.GUI.dropdown_channels.selected_index = Data.GUI.Pos
        -- This_MOD.selection_channel(Data)
        Data.GUI.Action = This_MOD.action.none
    end
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
This_MOD.start()

---------------------------------------------------------------------------------------------------


--[[ Código base
    if true then return end

    GPrefix.var_dump(event)

    local player = game.get_player(event.player_index)
    local anchor = {
        gui = defines.relative_gui_type.linked_container_gui,
        position = defines.relative_gui_position.top
    }
    local frame = player.gui.relative.add({
        type = "frame",
        name = "main",
        anchor = anchor
    })
    frame.add({
        type = "label",
        caption = player.name
    })
    storage.algo = storage.algo or {}
    storage.algo.frame = frame
]]
