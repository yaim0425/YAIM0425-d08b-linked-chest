---------------------------------------------------------------------------------------------------
---> control.lua <---
---------------------------------------------------------------------------------------------------

--- Contenedor de funciones y datos usados
--- unicamente en este archivo
local This_MOD = {}

---------------------------------------------------------------------------------------------------

--- Cargar las funciones
require("__zzzYAIM0425-0000-lib__/control")

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
    This_MOD.new_channel = { This_MOD.prefix .. "new-channel" }

    --- Posibles estados de la ventana
    This_MOD.action = {}
    This_MOD.action.none = nil
    This_MOD.action.edit = 1
    This_MOD.action.new_channel = 2

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Cargar los eventos a ejecutar
function This_MOD.load_events()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Al crear la entidad
    script.on_event({
        defines.events.on_built_entity,
        defines.events.on_robot_built_entity,
        defines.events.script_raised_built,
        defines.events.script_raised_revive,
        defines.events.on_space_platform_built_entity,
    }, function(event)
        This_MOD.create_entity(This_MOD.create_data(event))
    end)

    --- Abrir o cerrar la interfaz
    script.on_event({
        defines.events.on_gui_opened,
        defines.events.on_gui_closed
    }, function(event)
        This_MOD.toggle_gui(This_MOD.create_data(event))
    end)

    --- Al seleccionar otro canal
    script.on_event({
        defines.events.on_gui_selection_state_changed
    }, function(event)
        This_MOD.selection_channel(This_MOD.create_data(event))
    end)

    --- Al hacer clic en algún elemento de la ventana
    script.on_event({
        defines.events.on_gui_click
    }, function(event)
        This_MOD.button_action(This_MOD.create_data(event))
    end)

    --- Al seleccionar o deseleccionar un icon
    script.on_event({
        defines.events.on_gui_elem_changed
    }, function(event)
        This_MOD.add_icon(This_MOD.create_data(event))
    end)

    --- Al presionar ENTER
    script.on_event({
        defines.events.on_gui_confirmed
    }, function(event)
        This_MOD.validate_channel_name(This_MOD.Create_data(event))
    end)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

--- Crea y agrupar las variables a usar
function This_MOD.create_data(event)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Consolidar la información
    local Data = GPrefix.create_data(event or {}, This_MOD)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validación
    if not Data.gForce then return Data end
    if not event then return Data end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Canales
    Data.gForce.channels = Data.gForce.channels or {}
    Data.channels = Data.gForce.channels

    --- Antenas
    Data.gForce.nodes = Data.gForce.nodes or {}
    Data.nodes = Data.gForce.nodes

    -- --- Auxiliar
    -- Data.gForce.ghosts = Data.gForce.ghosts or {}
    -- Data.ghosts = Data.gForce.ghosts

    --- Entidad a trabajar
    if not Data.Entity then Data.Entity = Data.GUI.entity end

    --- Devolver el consolidado de los datos
    return Data

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---> Acciones por eventos
---------------------------------------------------------------------------------------------------

--- Al crear la entidad
function This_MOD.create_entity(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not Data.Entity then return end
    if not GPrefix.has_id(Data.Entity.name, This_MOD.id) then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Canal por defecto
    --- --- --- --- --- --- --- --- --- --- --- --- ---

    if #Data.channels == 0 then
        local Entity = Data.Entity
        Data.Entity = { link_id = 0 }
        This_MOD.get_channel(Data)
        Data.Entity = Entity
    end

    --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Canal del cofre
    --- --- --- --- --- --- --- --- --- --- --- --- ---

    This_MOD.get_channel(Data)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---> Acciones en el GUI
---------------------------------------------------------------------------------------------------

--- Crear o destruir el indicador
function This_MOD.toggle_gui(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function validate_close()
        --- --- --- --- --- --- --- --- --- --- --- --- ---
        ---> Validación
        --- --- --- --- --- --- --- --- --- --- --- --- ---

        if not Data.GUI.frame_main then return false end
        if not Data.Entity then return false end
        if not Data.Entity.valid then return false end
        if Data.Entity.name ~= This_MOD.ref.name then return false end

        --- --- --- --- --- --- --- --- --- --- --- --- ---


        --- --- --- --- --- --- --- --- --- --- --- --- ---
        ---> Aprovado
        --- --- --- --- --- --- --- --- --- --- --- --- ---

        return true

        --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    local function validate_open()
        --- --- --- --- --- --- --- --- --- --- --- --- ---
        ---> Validación
        --- --- --- --- --- --- --- --- --- --- --- --- ---

        if Data.GUI.frame_main then return false end
        if not Data.Entity then return false end
        if not Data.Entity.valid then return false end
        if not GPrefix.has_id(Data.Entity.name, This_MOD.id) then return false end

        --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Garantizar la creación del canal
        --- --- --- --- --- --- --- --- --- --- --- --- ---

        This_MOD.create_entity(Data)

        --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- ---
        ---> Aprovado
        --- --- --- --- --- --- --- --- --- --- --- --- ---

        return true

        --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function gui_destroy()
        --- --- --- --- --- --- --- --- --- --- --- --- ---

        Data.GUI.frame_main.destroy()
        Data.GPlayer.GUI = {}
        Data.GUI = Data.GPlayer.GUI

        --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    local function gui_build()
        --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Cambiar los guiones del nombre
        local Prefix = string.gsub(This_MOD.prefix, "%-", "_")

        --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Crear el cuadro principal
        Data.GUI.frame_main = {}
        Data.GUI.frame_main.type = "frame"
        Data.GUI.frame_main.name = "frame_main"
        Data.GUI.frame_main.direction = "vertical"
        Data.GUI.frame_main.anchor = {}
        Data.GUI.frame_main.anchor.gui = defines.relative_gui_type.linked_container_gui
        Data.GUI.frame_main.anchor.position = defines.relative_gui_position.top
        Data.GUI.frame_main = Data.Player.gui.relative.add(Data.GUI.frame_main)
        Data.GUI.frame_main.style = "frame"

        --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Efecto de profundidad
        Data.GUI.frame_old_channel = {}
        Data.GUI.frame_old_channel.type = "frame"
        Data.GUI.frame_old_channel.name = "frame_old_channel"
        Data.GUI.frame_old_channel.direction = "horizontal"
        Data.GUI.frame_old_channel = Data.GUI.frame_main.add(Data.GUI.frame_old_channel)
        Data.GUI.frame_old_channel.style = Prefix .. "frame_body"

        --- Barra de movimiento
        Data.GUI.dropdown_channels = {}
        Data.GUI.dropdown_channels.type = "drop-down"
        Data.GUI.dropdown_channels.name = "drop_down_channels"
        Data.GUI.dropdown_channels = Data.GUI.frame_old_channel.add(Data.GUI.dropdown_channels)
        Data.GUI.dropdown_channels.style = Prefix .. "drop_down_channels"

        --- Botón para aplicar los cambios
        Data.GUI.button_edit = {}
        Data.GUI.button_edit.type = "sprite-button"
        Data.GUI.button_edit.name = "button_edit"
        Data.GUI.button_edit.sprite = "utility/rename_icon"
        Data.GUI.button_edit.tooltip = { This_MOD.prefix .. "edit-channel" }
        Data.GUI.button_edit = Data.GUI.frame_old_channel.add(Data.GUI.button_edit)
        Data.GUI.button_edit.style = Prefix .. "button_blue"

        --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Efecto de profundidad
        Data.GUI.frame_new_channel = {}
        Data.GUI.frame_new_channel.type = "frame"
        Data.GUI.frame_new_channel.name = "frame_new_channels"
        Data.GUI.frame_new_channel.direction = "horizontal"
        Data.GUI.frame_new_channel = Data.GUI.frame_main.add(Data.GUI.frame_new_channel)
        Data.GUI.frame_new_channel.style = Prefix .. "frame_body"
        Data.GUI.frame_new_channel.visible = false

        --- Nuevo nombre
        Data.GUI.textfield_new_channel = {}
        Data.GUI.textfield_new_channel.type = "textfield"
        Data.GUI.textfield_new_channel.name = "write-channel"
        Data.GUI.textfield_new_channel.text = "xXx"
        Data.GUI.textfield_new_channel = Data.GUI.frame_new_channel.add(Data.GUI.textfield_new_channel)
        Data.GUI.textfield_new_channel.style = Prefix .. "stretchable_textfield"

        --- Crear la imagen de selección
        Data.GUI.button_icon = {}
        Data.GUI.button_icon.type = "choose-elem-button"
        Data.GUI.button_icon.name = "button_icon"
        Data.GUI.button_icon.elem_type = "signal"
        Data.GUI.button_icon.signal = { type = "virtual", name = GPrefix.name .. "-icon" }
        Data.GUI.button_icon = Data.GUI.frame_new_channel.add(Data.GUI.button_icon)
        Data.GUI.button_icon.style = Prefix .. "button"

        --- Botón para cancelar los cambios
        Data.GUI.button_cancel = {}
        Data.GUI.button_cancel.type = "sprite-button"
        Data.GUI.button_cancel.name = "button_cancel"
        Data.GUI.button_cancel.sprite = "utility/close_fat"
        Data.GUI.button_cancel.tooltip = { "gui-mod-settings.cancel" }
        Data.GUI.button_cancel = Data.GUI.frame_new_channel.add(Data.GUI.button_cancel)
        Data.GUI.button_cancel.style = Prefix .. "button_red"

        --- Botón para aplicar los cambios
        Data.GUI.button_confirm = {}
        Data.GUI.button_confirm.type = "sprite-button"
        Data.GUI.button_confirm.name = "button_green"
        Data.GUI.button_confirm.sprite = "utility/check_mark_white"
        Data.GUI.button_confirm.tooltip = { "gui.confirm" }
        Data.GUI.button_confirm = Data.GUI.frame_new_channel.add(Data.GUI.button_confirm)
        Data.GUI.button_confirm.style = Prefix .. "button_green"

        --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cargar los canales
    local function load_channels()
        --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Cargar los canales
        local Dropdown = Data.GUI.dropdown_channels
        for _, channel in pairs(Data.channels) do
            Dropdown.add_item(channel.name)
        end
        Dropdown.add_item(This_MOD.new_channel)

        --- Seleccionar el canal actual
        Dropdown.selected_index = This_MOD.get_channel(Data).index

        --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Acción a ejecutar
    if validate_close() then
        gui_destroy()
    elseif validate_open() then
        gui_build()
        load_channels()
        Data.GUI.entity = Data.Entity
    end
end

--- Al seleccionar un canal
function This_MOD.selection_channel(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validación
    if not Data.GUI.frame_main then return end
    local Element = Data.Event.element
    local Channels = Data.GUI.dropdown_channels
    if Element and Element ~= Channels then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Selección actul
    local Index = Channels.selected_index

    --- Se quiere crear un nuevo canal
    if Index == #Channels.items then
        Data.GUI.action = This_MOD.action.new_channel
        This_MOD.show_new_channel(Data)
        This_MOD.sound_channel_selected(Data)
        return
    end

    --- Cambiar el canal del cofre
    Data.Entity.link_id = Data.channels[Index].link_id
    This_MOD.sound_channel_changed(Data)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Acciones de los botones
function This_MOD.button_action(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validar el elemento
    if not Data.GUI.frame_main then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cancelar el cambio de nombre o el nuevo canal
    if Data.Event.element == Data.GUI.button_cancel then
        This_MOD.show_old_channel(Data)
        return
    end

    --- Cambiar el nombre de un canal o agregar un nuevo canal
    if Data.Event.element == Data.GUI.button_confirm then
        This_MOD.validate_channel_name(Data)
        return
    end

    --- Editar el nombre del canal seleccionado
    if Data.Event.element == Data.GUI.button_edit then
        Data.GUI.action = This_MOD.action.edit
        This_MOD.show_new_channel(Data)
        return
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Seleccionar un nuevo objeto
function This_MOD.add_icon(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validación
    if not Data.Event.element then return end
    if Data.Event.element ~= Data.GUI.button_icon then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cargar la selección
    local Select = Data.GUI.button_icon.elem_value

    --- Restaurar el icono
    Data.GUI.button_icon.elem_value = {
        type = "virtual",
        name = GPrefix.name .. "-icon"
    }

    --- Renombrar
    local Textbox = Data.GUI.textfield_new_channel

    --- Se intentó limpiar el icono
    if not Select then
        Textbox.focus()
        return
    end

    --- Convertir seleccion en texto
    local function signal_to_rich_text(select)
        local type = ""

        if not select.type then
            if prototypes.entity[select.name] then
                type = "entity"
            elseif prototypes.recipe[select.name] then
                type = "recipe"
            elseif prototypes.fluid[select.name] then
                type = "fluid"
            elseif prototypes.item[select.name] then
                type = "item"
            end
        end

        if select.type then
            type = select.type
            if select.type == "virtual" then
                type = type .. "-signal"
            end
        end

        return "[img=" .. type .. "." .. select.name .. "]"
    end

    --- Agregar la imagen seleccionada
    local Text = Textbox.text
    Text = Text .. signal_to_rich_text(Select)
    Textbox.text = Text
    Textbox.focus()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Validar el nombre del canal
function This_MOD.validate_channel_name(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Texto a evaluar
    local Textbox = Data.GUI.textfield_new_channel

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validación
    local Flag = Textbox.text == ""
    Flag = Flag or GPrefix.get_table(Data.channels, "name", Textbox.text)
    if Flag then
        This_MOD.sound_bad(Data)
        Textbox.focus()
        return
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Renombrar
    local Dropdown = Data.GUI.dropdown_channels
    local Index = Dropdown.selected_index

    --- Crear un nuevo canal
    if Data.GUI.action == This_MOD.action.new_channel then
        --- Buscar un espacio libre
        Data.gForce.last_value = Data.gForce.last_value or 0
        while GPrefix.get_table(Data.channels, "link_id", Data.gForce.last_value) do
            Data.gForce.last_value = Data.gForce.last_value + 1
        end

        --- Agregar el nuevo nombre a la GUI
        Dropdown.add_item(Textbox.text, Index)

        --- Cambiar el indicador
        Data.Entity.link_id = Data.gForce.last_value

        --- Efecto de sonido
        This_MOD.sound_channel_changed(Data)
    end

    --- Cambiar el nombre de un canal
    if Data.GUI.action == This_MOD.action.edit then
        --- Cambiar el nombre en la GUI
        Dropdown.remove_item(Index)
        Dropdown.add_item(Textbox.text, Index)

        --- Efecto de sonido
        This_MOD.sound_good(Data)
    end

    --- Actualizar el nombre
    This_MOD.get_channel(Data).name = Textbox.text
    This_MOD.show_old_channel(Data)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

--- Mostrar el cuerpo para seleccionar un canal
function This_MOD.show_old_channel(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cambiar de frame
    Data.GUI.frame_new_channel.visible = false
    Data.GUI.frame_old_channel.visible = true

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Enfocar la selección
    Data.GUI.dropdown_channels.selected_index = This_MOD.get_channel(Data).index
    This_MOD.selection_channel(Data)
    Data.GUI.action = nil

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Mostrar el cuerpo para crear un nuevo canal
function This_MOD.show_new_channel(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cambiar de frame
    Data.GUI.frame_old_channel.visible = false
    Data.GUI.frame_new_channel.visible = true

    --- Configuración para un nuevo canal
    if Data.GUI.action == This_MOD.action.new_channel then
        Data.GUI.action = This_MOD.action.new_channel
        Data.GUI.textfield_new_channel.text = ""
    end

    --- Configuración para editar el nombre
    if Data.GUI.action == This_MOD.action.edit then
        local Dropdown = Data.GUI.dropdown_channels
        local Textbox = Data.GUI.textfield_new_channel
        Textbox.text = Data.channels[Dropdown.selected_index].name
    end

    --- Enfocar nombre
    Data.GUI.textfield_new_channel.focus()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---> Funciones de apoyo
---------------------------------------------------------------------------------------------------

--- Obtener un canal
function This_MOD.get_channel(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cargar el canal indicado
    local Channel = GPrefix.get_table(Data.channels, "link_id", Data.Entity.link_id)
    if Channel then return Channel end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Guardar el nuevo canal
    Channel = {}
    Channel.index = #Data.channels + 1
    Channel.link_id = Data.Entity.link_id
    Data.channels[Channel.index] = Channel

    --- Nombre del canal
    Channel.name = ""
    local ID = tostring(Channel.link_id)
    for n = 1, #ID do
        Channel.name = Channel.name .. "[img=virtual-signal.signal-" .. ID:sub(n, n) .. "]"
    end

    --- Devolver el canal indicado
    return Channel

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

--- Sonido normal
function This_MOD.sound_good(Data)
    Data.Player.play_sound({ path = "gui_tool_button" })
end

--- Sonido de error
function This_MOD.sound_bad(Data)
    Data.Player.play_sound({ path = "utility/cannot_build" })
end

--- Sonido de click
function This_MOD.sound_channel_selected(Data)
    Data.Player.play_sound({ path = "utility/gui_click" })
end

--- Sonido de cambio de canal
function This_MOD.sound_channel_changed(Data)
    Data.Player.play_sound({ path = "utility/wire_connect_pole" })
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
This_MOD.start()

---------------------------------------------------------------------------------------------------
