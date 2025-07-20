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

    --- Contenedor
    This_MOD.new_mame = This_MOD.prefix .. "transceiver"
    This_MOD.channel_default = { This_MOD.prefix .. "default-channel" }
    This_MOD.new_channel = { This_MOD.prefix .. "new-channel" }

    --- Posibles estados de la ventana
    This_MOD.action = {}
    This_MOD.action.none = nil
    This_MOD.action.build = 1
    This_MOD.action.edit = 2
    -- ThisMOD.Action.apply = 3
    -- ThisMOD.Action.discard = 4
    This_MOD.action.new_channel = 5

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Cargar los eventos a ejecutar
function This_MOD.load_events()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    script.on_event({
        defines.events.on_gui_opened
    }, function(event)

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
    end)

    script.on_event({
        defines.events.on_gui_closed
    }, function(event)
        storage.algo = storage.algo or {}
        if storage.algo.frame then
            storage.algo.frame.destroy()
        end
    end)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

--- Crea y agrupar las variables a usar
function This_MOD.create_data(event)
    --- Consolidar la información
    local Data = GPrefix.create_data(event or {}, This_MOD)
    if not event then return Data end

    --- Entidad en el event
    if event.entity and event.entity.valid then
        Data.Entity = event.entity
    elseif event.created_entity and event.created_entity.valid then
        Data.Entity = event.created_entity
    end

    --- Lista de los postes
    Data.gForce.Channel = Data.gForce.Channel or {}
    Data.Channel = Data.gForce.Channel

    --- Lista de los transceiver
    Data.gForce.Node = Data.gForce.Node or {}
    Data.Node = Data.gForce.Node

    --- Devolver el consolidado de los datos
    return Data
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

---
function This_MOD.gui_opened(Data)
    
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
This_MOD.start()

---------------------------------------------------------------------------------------------------
