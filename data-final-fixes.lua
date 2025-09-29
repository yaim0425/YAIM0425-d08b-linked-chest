---------------------------------------------------------------------------
---[ data-final-fixes.lua ]---
---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Contenedor de este archivo ]---
---------------------------------------------------------------------------

local This_MOD = GMOD.get_id_and_name()
if not This_MOD then return end
GMOD[This_MOD.id] = This_MOD

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Inicio del MOD ]---
---------------------------------------------------------------------------

function This_MOD.start()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores de la referencia
    This_MOD.setting_mod()

    --- Obtener los elementos
    This_MOD.get_elements()

    --- Modificar los elementos
    for _, spaces in pairs(This_MOD.to_be_processed) do
        for _, space in pairs(spaces) do
            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

            --- Crear los elementos
            This_MOD.create_item(space)
            This_MOD.create_entity(space)
            This_MOD.create_recipe(space)

            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        end
    end

    --- Valores a usar en control.lua
    This_MOD.load_styles()
    This_MOD.load_icon()
    This_MOD.load_sound()

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Valores de la referencia ]---
---------------------------------------------------------------------------

function This_MOD.setting_mod()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validar si se cargó antes
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Contenedor de los elementos que el MOD modoficará
    This_MOD.to_be_processed = {}

    --- Validar si se cargó antes
    if This_MOD.setting then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en todos los MODs
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cargar la configuración
    This_MOD.setting = GMOD.setting[This_MOD.id] or {}

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en este MOD
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores de referencia
    This_MOD.old_entity_name = "linked-chest"
    This_MOD.new_entity_name = This_MOD.prefix .. "linked-chest"

    --- Rutas de los recursos
    This_MOD.path_graphics = "__" .. This_MOD.prefix .. This_MOD.name .. "__/graphics/"
    This_MOD.path_sound = "__" .. This_MOD.prefix .. This_MOD.name .. "__/sound/"

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---------------------------------------------------------------------------

---------------------------------------------------------------------------
---[ Funciones locales ]---
---------------------------------------------------------------------------

function This_MOD.get_elements()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if GMOD.items[This_MOD.new_entity_name] then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cargar los valores de referencia
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Posibles objetos de referencia
    local Chest = {}
    table.insert(Chest, "storage-chest")
    table.insert(Chest, "passive-provider-chest")
    table.insert(Chest, "requester-chest")
    table.insert(Chest, "buffer-chest")
    table.insert(Chest, "active-provider-chest")

    --- Objeto de referencia
    local Orders = {}
    local Order_chest = {}
    for _, name in pairs(Chest) do
        local Item = GMOD.items[name]
        Order_chest[Item.order] = name
        table.insert(Orders, Item.order)
    end

    --- Ordenar los objetos
    table.sort(Orders)

    --- Información de referencia
    local Space = {}
    Space.name = Order_chest[Orders[#Orders]]
    Space.item = GMOD.items[Space.name]
    Space.entity = GMOD.entities[Space.name]

    Space.recipe = GMOD.recipes[Space.name]
    Space.tech = GMOD.get_technology(Space.recipe)
    Space.recipe = Space.recipe and Space.recipe[1] or nil

    Space.name = This_MOD.old_entity_name
    Space.chest_entity = data.raw["linked-container"][Space.name]
    Space.chest_item = data.raw.item[Space.name]

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Guardar la información
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    This_MOD.to_be_processed["linked-container"] = This_MOD.to_be_processed["linked-container"] or {}
    This_MOD.to_be_processed["linked-container"][Space.name] = Space

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------

function This_MOD.create_item(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.item then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Item = GMOD.copy(space.item)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Item.name = This_MOD.new_entity_name

    --- Copiar los iconos del cofre
    Item.icons = GMOD.copy(space.chest_item.icons)

    --- Apodo y descripción
    Item.localised_name = { "", { "entity-name." .. This_MOD.old_entity_name } }
    Item.localised_description = { "", { "entity-description." .. This_MOD.old_entity_name } }

    --- Actualizar el order
    local Order = tonumber(Item.order) + 1
    Item.order = GMOD.pad_left_zeros(#Item.order, Order)

    --- Entidad a crear
    Item.place_result = This_MOD.new_entity_name

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Item)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_entity(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.entity then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Entity = GMOD.copy(space.entity)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Entity.name = This_MOD.new_entity_name

    --- Tipo de entidad
    Entity.type = space.chest_entity.type

    --- Apodo y descripción
    Entity.localised_name = { "", { "entity-name." .. This_MOD.old_entity_name } }
    Entity.localised_description = { "", { "entity-description." .. This_MOD.old_entity_name } }

    --- Objeto a minar
    Entity.minable.results = { {
        type = "item",
        name = This_MOD.new_entity_name,
        amount = 1
    } }

    --- Elimnar propiedades inecesarias
    Entity.fast_replaceable_group = nil
    Entity.next_upgrade = nil

    --- Copiar los iconos del cofre
    Entity.icons = GMOD.copy(space.item.icons)

    --- Copiar la imagen del cofre
    Entity.picture = GMOD.copy(space.chest_entity.picture)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Entity)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_recipe(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.recipe then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Recipe = GMOD.copy(space.recipe)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Recipe.name = This_MOD.new_entity_name

    --- Apodo y descripción
    Recipe.localised_name = { "", { "entity-name." .. This_MOD.old_entity_name } }
    Recipe.localised_description = { "", { "entity-description." .. This_MOD.old_entity_name } }

    --- Elimnar propiedades inecesarias
    Recipe.main_product = nil

    --- Receta desbloqueada por tecnología
    Recipe.enabled = space.tech == nil

    --- Agregar indicador del MOD
    Recipe.icons = GMOD.copy(space.chest_item.icons)

    --- Actualizar el order
    local Order = tonumber(Recipe.order) + 1
    Recipe.order = GMOD.pad_left_zeros(#Recipe.order, Order)

    --- Resultados
    Recipe.results = { {
        type = "item",
        name = This_MOD.new_entity_name,
        amount = 1
    } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Recipe)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------

---------------------------------------------------------------------------
---------------------------------------------------------------------------





---------------------------------------------------------------------------
--- [ Valores a usar en control.lua ] ---
---------------------------------------------------------------------------

--- Estilos a usar
function This_MOD.load_styles()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores a usar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cambiar los guiones del nombre
    local Prefix = string.gsub(This_MOD.prefix, "%-", "_")

    --- Renombrar
    local Styles = data.raw["gui-style"].default

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cuerpo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Styles[Prefix .. "frame_body"] = {
        type = "frame_style",
        parent = "entity_frame",
        horizontally_stretchable = "off",
        padding = 4
    }

    Styles[Prefix .. "drop_down_channels"] = {
        type = "dropdown_style",
        parent = "dropdown",
        list_box_style = {
            type = "list_box_style",
            item_style = {
                type = "button_style",
                parent = "list_box_item",
                left_click_sound = This_MOD.path_sound .. "empty_audio.ogg",
            },
        },
        width = 296 + 64
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Nuevo canal
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Styles[Prefix .. "button_red"] = {
        type = "button_style",
        parent = "tool_button_red",
        padding = 0,
        margin = 0,
        size = 28
    }

    Styles[Prefix .. "button_green"] = {
        type = "button_style",
        parent = "tool_button_green",
        left_click_sound = This_MOD.path_sound .. "empty_audio.ogg",
        padding = 0,
        margin = 0,
        size = 28
    }

    Styles[Prefix .. "button_blue"] = {
        type = "button_style",
        parent = "tool_button_blue",
        padding = 0,
        margin = 0,
        size = 28
    }

    Styles[Prefix .. "button"] = {
        type = "button_style",
        parent = "button",
        top_margin = 1,
        padding = 0,
        size = 28
    }

    Styles[Prefix .. "stretchable_textfield"] = {
        type = "textbox_style",
        width = 296
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Icono para las imagenes
function This_MOD.load_icon()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Name = GMOD.name .. "-icon"
    if data.raw["virtual-signal"][Name] then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear la señal
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend({
        type = "virtual-signal",
        name = Name,
        localised_name = "",
        icon = This_MOD.path_graphics .. "icon.png",
        icon_size = 40,
        subgroup = "virtual-signal",
        order = "z-z-o"
    })

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Cargar el sonido
function This_MOD.load_sound()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend({
        type = "sound",
        name = "gui_tool_button",
        filename = "__core__/sound/gui-tool-button.ogg",
        volume = 1.0
    })

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Iniciar el MOD ]---
---------------------------------------------------------------------------

This_MOD.start()

---------------------------------------------------------------------------
