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

---------------------------------------------------------------------------------------------------

--- Cargar los eventos a ejecutar
function This_MOD.load_events()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

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

    --- Al presionar ENTER
    script.on_event({
        defines.events.on_gui_confirmed
    }, function(event)
        This_MOD.validate_channel_name(This_MOD.Create_data(event))
    end)

    --- Al seleccionar o deseleccionar un icon
    script.on_event({
        defines.events.on_gui_elem_changed
    }, function(event)
        This_MOD.add_icon(This_MOD.create_data(event))
    end)

    --- Verificar que la entidad tenga energía
    script.on_nth_tick(20, This_MOD.check_channel)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

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
---> Acciones en el GUI
---------------------------------------------------------------------------------------------------

--- Crear o destruir el indicador
function This_MOD.toggle_gui(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validación
    if not Data.gForces then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function validate_open()
        --- --- --- --- --- --- --- --- --- --- --- --- ---
        ---> Validación
        --- --- --- --- --- --- --- --- --- --- --- --- ---

        if Data.GUI.frame_up then return false end
        if not Data.Entity then return false end
        if not Data.Entity.valid then return false end
        if not GPrefix.has_id(Data.Entity.name, This_MOD.id) then return false end

        --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- ---
        ---> Canal por defecto
        --- --- --- --- --- --- --- --- --- --- --- --- ---

        This_MOD.get_channel({
            Entity = { link_id = 0 },
            channel = Data.channel
        }, "0")

        --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- ---
        ---> Canal del cofre
        --- --- --- --- --- --- --- --- --- --- --- --- ---

        This_MOD.get_channel(Data, "" .. Data.Entity.link_id)

        --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- ---
        ---> Aprovado
        --- --- --- --- --- --- --- --- --- --- --- --- ---

        return true

        --- --- --- --- --- --- --- --- --- --- --- --- ---
    end
    local function validate_close()
        --- --- --- --- --- --- --- --- --- --- --- --- ---
        ---> Validación
        --- --- --- --- --- --- --- --- --- --- --- --- ---

        if not Data.GUI.frame_up then return false end
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

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function build()
        --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Cambiar los guiones del nombre
        local Prefix = string.gsub(This_MOD.prefix, "%-", "_")

        --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Crear el cuadro principal
        Data.GUI.frame_up = {}
        Data.GUI.frame_up.type = "frame"
        Data.GUI.frame_up.name = "frame_up"
        Data.GUI.frame_up.direction = "vertical"
        Data.GUI.frame_up.anchor = {}
        Data.GUI.frame_up.anchor.gui = defines.relative_gui_type.linked_container_gui
        Data.GUI.frame_up.anchor.position = defines.relative_gui_position.top
        Data.GUI.frame_up = Data.Player.gui.relative.add(Data.GUI.frame_up)
        Data.GUI.frame_up.style = "frame"

        --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- ---

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
            Data.GUI.dropdown_channel.add_item(channel)
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

        --- --- --- --- --- --- --- --- --- --- --- --- ---



        --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Efecto de profundidad
        Data.GUI.frame_new_channel = {}
        Data.GUI.frame_new_channel.type = "frame"
        Data.GUI.frame_new_channel.name = "frame_new_channels"
        Data.GUI.frame_new_channel.direction = "horizontal"
        Data.GUI.frame_new_channel = Data.GUI.frame_up.add(Data.GUI.frame_new_channel)
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
    local function destroy()
        --- --- --- --- --- --- --- --- --- --- --- --- ---

        Data.GUI.frame_up.destroy()
        Data.GPlayer.GUI = {}
        Data.GUI = Data.GPlayer.GUI

        --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Acción a ejecutar
    if validate_close() then
        destroy()
    elseif validate_open() then
        build()
        Data.GUI.entity = Data.Entity
        Data.GUI.dropdown_channel.selected_index = This_MOD.get_index_of_link_id(Data)
    end
end

--- Al seleccionar un canal
function This_MOD.selection_channel(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validación
    if not Data.GUI.frame_up then return end
    local Element = Data.Event.element
    local Channels = Data.GUI.dropdown_channel
    if Element and Element ~= Channels then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Selección actul
    local Selected_index = Channels.selected_index

    --- Se quiere crear un nuevo canal
    if Selected_index == #Channels.items then
        Data.GUI.action = This_MOD.action.new_channel
        This_MOD.show_new_channel(Data)
        return
    end

    --- Cambiar el canal del cofre
    Data.GUI.entity.link_id = This_MOD.get_link_id_of_index(Data)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Acciones de los botones
function This_MOD.button_action(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Variables a usar
    local Flag = false
    local EventID = 0

    --- Validar el elemento
    EventID = defines.events.on_gui_click
    Flag = Data.Event.name == EventID
    if not Flag then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cancelar el cambio de nombre o el nuevo canal
    Flag = Data.Event.element == Data.GUI.button_cancel
    if Flag then
        Data.Entity = Data.GUI.entity
        This_MOD.toggle_gui(Data) --- Destruir
        This_MOD.toggle_gui(Data) --- Construir
        return
    end

    --- Cambiar el nombre de un canal o agregar un nuevo canal
    Flag = false or Data.GUI.action == This_MOD.action.edit
    Flag = Flag or Data.GUI.action == This_MOD.action.new_channel
    Flag = Flag and Data.Event.element == Data.GUI.button_confirm
    if Flag then
        This_MOD.validate_channel_name(Data)
        return
    end

    --- Editar el nombre del canal seleccionado
    Flag = Data.Event.element == Data.GUI.button_edit
    if Flag then
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
    if not Data.GUI.button_icon then return end
    if Data.Event.element ~= Data.GUI.button_icon then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cargar la selección
    local Select = Data.GUI.button_icon.elem_value

    --- Restaurar el icono
    Data.GUI.button_icon.elem_value = {
        type = "virtual",
        name = GPrefix.name .. "-icon"
    }

    --- Se intentó limpiar el icono
    if not Select then return end

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
    local text = Data.GUI.textfield_new_channel.text
    text = text .. signal_to_rich_text(Select)
    Data.GUI.textfield_new_channel.text = text
    Data.GUI.textfield_new_channel.focus()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

--- Validar el nombre del canal
function This_MOD.validate_channel_name(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Texto a evaluar
    local Text = Data.GUI.textfield_new_channel

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validación
    if Text.text == "" or GPrefix.get_key(Data.channel, Text.text) then
        Data.Player.play_sound({ path = "utility/cannot_build" })
        Text.focus()
        return
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Crear un nuevo canal
    if Data.GUI.action == This_MOD.action.new_channel then
        Data.gForce.last_index = Data.gForce.last_index or 0
        for i = Data.gForce.last_index, 2 ^ 32 - 1, 1 do
            local Index = GPrefix.pad_left_zeros(10, i)
            if not Data.channel[Index] then
                Data.channel[Index] = Text.text
                Data.gForce.last_index = i
                Data.GUI.entity.link_id = i
                break
            end
        end
        Data.Player.play_sound({ path = "utility/wire_connect_pole" })
    end

    --- Cambiar el nombre de un canal
    if Data.GUI.action == This_MOD.action.edit then
        Data.channel[Data.GUI.selected_index] = Text.text
        -- Data.Player.play_sound({ path = "utility/gui_tool_button" })
        Data.Player.play_sound({ path = "gui_tool_button" })
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Actualizar el indicador
    Data.Entity = Data.GUI.entity
    This_MOD.toggle_gui(Data) --- Destruir
    This_MOD.toggle_gui(Data) --- Construir

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
        local Channels = Data.GUI.dropdown_channel
        local Text = Data.GUI.textfield_new_channel
        Text.text = Channels.get_item(Channels.selected_index)
        Data.GUI.selected_index = GPrefix.get_key(Data.channel, Text.text)
    end

    --- Enfocar nombre
    Data.GUI.textfield_new_channel.focus()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Verificar el cambio de cada canal
function This_MOD.check_channel()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cargar toda la información
    local Datas = This_MOD.create_data()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Recorrer cada jugador enlistado
    for player_index, GPlayer in pairs(Datas.GPlayers) do
        if GPlayer.GUI.entity then
            --- Consolidar información
            local Data = This_MOD.create_data({
                entity = GPlayer.GUI.entity,
                player_index = player_index
            })

            repeat
                --- No está mostrando el canal
                if Data.GUI.action then break end

                --- Valores a evaluar
                local Channel_index = Data.GUI.dropdown_channel.selected_index
                local Chest_index = This_MOD.get_index_of_link_id(Data)

                --- Validar cambio
                if Channel_index == Chest_index then break end

                --- Actualizar el indicador
                This_MOD.toggle_gui(Data) --- Destruir
                This_MOD.toggle_gui(Data) --- Construir
            until true
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---> Funciones de apoyo
---------------------------------------------------------------------------------------------------

--- Obtener un canal
function This_MOD.get_channel(Data, channel)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cargar el poste del canal indicado
    local Found = GPrefix.get_key(Data.channel, channel)
    if Found then return channel end

    --- Formato al indice
    local Link_id = Data.Entity.link_id
    Link_id = GPrefix.pad_left_zeros(10, Link_id)
    if Data.channel[Link_id] then return end

    --- Guardar el nuevo canal
    Data.channel[Link_id] = channel

    --- Devolver el canal indicado
    return channel

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Obtener el canal seleccionado
function This_MOD.get_link_id_of_index(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Variables a usar
    local Index = 0
    local Channel_index = Data.GUI.dropdown_channel.selected_index

    --- Buscar el index
    for key, _ in pairs(Data.channel) do
        Index = Index + 1
        if Index == Channel_index then
            return tonumber(key)
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Obtener el canal seleccionado
function This_MOD.get_index_of_link_id(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Variables a usar
    local Index = 0
    local Key = Data.Entity.link_id
    Key = GPrefix.pad_left_zeros(10, Key)

    --- Buscar el index
    for key, _ in pairs(Data.channel) do
        Index = Index + 1
        if key == Key then
            return Index
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
This_MOD.start()

---------------------------------------------------------------------------------------------------
