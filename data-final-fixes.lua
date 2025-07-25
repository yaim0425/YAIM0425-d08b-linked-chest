---------------------------------------------------------------------------------------------------
---> data-final-fixes.lua <---
---------------------------------------------------------------------------------------------------

--- Contenedor de funciones y datos usados
--- unicamente en este archivo
local This_MOD = {}

---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
function This_MOD.start()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Obtener información desde el nombre de MOD
    GPrefix.split_name_folder(This_MOD)

    --- Valores de la referencia
    This_MOD.setting_mod()

    --- Entidades a afectar
    This_MOD.get_ref()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Crear los nuevos prototipos
    This_MOD.create_item()
    This_MOD.create_entity()
    This_MOD.create_recipe()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Estilos a usar
    This_MOD.load_styles()
    This_MOD.loda_icon()
    This_MOD.load_sound()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Valores de la referencia
function This_MOD.setting_mod()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Información de referencia
    This_MOD.ref = {}
    This_MOD.ref.name = {}
    This_MOD.ref.entity = {}
    This_MOD.ref.recipe = {}
    This_MOD.ref.item = {}

    --- Información a duplicar
    This_MOD.duplicate = {}
    This_MOD.duplicate.name = "linked-chest"
    This_MOD.duplicate.entity = data.raw["linked-container"][This_MOD.duplicate.name]
    This_MOD.duplicate.item = data.raw["item"][This_MOD.duplicate.name]

    --- Valores constante
    This_MOD.graphics = "__" .. This_MOD.prefix .. This_MOD.name .. "__/graphics/"
    This_MOD.sound = "__" .. This_MOD.prefix .. This_MOD.name .. "__/sound/"

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Entidades a afectar
function This_MOD.get_ref()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

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
        local Item = GPrefix.items[name]
        Order_chest[Item.order] = name
        table.insert(Orders, Item.order)
    end

    --- Ordenar los objetos
    table.sort(Orders)

    --- Información de referencia
    This_MOD.ref.name = Order_chest[Orders[#Chest]]
    This_MOD.ref.entity = GPrefix.entities[This_MOD.ref.name]
    This_MOD.ref.recipe = GPrefix.recipes[This_MOD.ref.name][1]
    This_MOD.ref.item = GPrefix.items[This_MOD.ref.name]
    This_MOD.ref.tech = GPrefix.get_technology(This_MOD.ref.recipe)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

--- Crear el nuevo objeto
function This_MOD.create_item()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nuevo prototipo
    local Item = util.copy(This_MOD.ref.item)

    --- Sobre escribir las propiedades
    Item.name = This_MOD.prefix .. This_MOD.duplicate.name
    Item.icons = This_MOD.duplicate.item.icons
    Item.place_result = This_MOD.prefix .. This_MOD.duplicate.name

    Item.localised_name = { "", { "entity-name." .. This_MOD.duplicate.entity.name } }
    Item.localised_description = { "", { "entity-description." .. This_MOD.duplicate.entity.name } }

    local order = tonumber(Item.order) + 1
    Item.order = GPrefix.pad_left_zeros(#Item.order, order)

    --- Crear el objeto
    GPrefix.extend(Item)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Crear la nueva entidad
function This_MOD.create_entity()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nuevo prototipo
    local Entity = util.copy(This_MOD.ref.entity)

    --- Sobre escribir las propiedades
    Entity.type = This_MOD.duplicate.entity.type
    Entity.name = This_MOD.prefix .. This_MOD.duplicate.name

    Entity.localised_name = { "", { "entity-name." .. This_MOD.duplicate.name } }
    Entity.localised_description = { "", { "entity-description." .. This_MOD.duplicate.name } }

    Entity.icons = This_MOD.duplicate.entity.icons
    Entity.picture = This_MOD.duplicate.entity.picture

    local Result = Entity.minable.results
    Result = GPrefix.get_table(Result, "name", This_MOD.ref.item.name)
    Result.name = This_MOD.prefix .. This_MOD.duplicate.name

    --- Crear el prototipo
    GPrefix.extend(Entity)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Crear la receta
function This_MOD.create_recipe()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nuevo prototipo
    local Recipe = util.copy(This_MOD.ref.recipe)

    --- Sobre escribir las propiedades
    Recipe.name = This_MOD.prefix .. This_MOD.duplicate.name
    Recipe.icons = This_MOD.duplicate.entity.icons

    Recipe.localised_name = { "", { "entity-name." .. This_MOD.duplicate.name } }
    Recipe.localised_description = { "", { "entity-description." .. This_MOD.duplicate.name } }

    local Result = GPrefix.get_table(Recipe.results, "name", This_MOD.ref.item.name)
    Result.name = This_MOD.prefix .. This_MOD.duplicate.name

    local order = tonumber(Recipe.order) + 1
    Recipe.order = GPrefix.pad_left_zeros(#Recipe.order, order)

    --- Crear la receta
    GPrefix.extend(Recipe)

    --- Agregar a la tecnología
    This_MOD.create_tech(This_MOD.ref, Recipe)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

--- Crear las tecnologías
function This_MOD.create_tech(space, new_recipe)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validación
    if not space.tech then return end

    --- Nombre de la nueva tecnología
    local Tech_name = space.tech and space.tech.name
    Tech_name = GPrefix.delete_prefix(Tech_name)
    Tech_name = This_MOD.prefix .. Tech_name

    --- La tecnología ya existe
    if GPrefix.tech.raw[Tech_name] then
        GPrefix.add_recipe_to_tech(Tech_name, new_recipe)
        return
    end

    --- Preprar la nueva tecnología
    local Tech = util.copy(space.tech)
    Tech.prerequisites = { Tech.name }
    Tech.name = Tech_name
    Tech.effects = { {
        type = "unlock-recipe",
        recipe = new_recipe.name
    } }

    --- Crear la nueva tecnología
    GPrefix.extend(Tech)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Estilos a usar
function This_MOD.load_styles()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cambiar los guiones del nombre
    local Prefix = string.gsub(This_MOD.prefix, "%-", "_")

    --- Renombrar
    local Styles = data.raw["gui-style"].default

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Cuerpo
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Styles[Prefix .. "frame_body"] = {
        type = "frame_style",
        parent = "entity_frame",
        horizontally_stretchable = "off",
        padding = 4
    }
    Styles[Prefix .. "drop_down_channel"] = {
        type = "dropdown_style",
        width = 296 + 64
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Nuevo canal
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

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
        left_click_sound = This_MOD.sound .. "empty_audio.ogg",
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

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Icono para las imagenes
function This_MOD.loda_icon()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validación
    local Name = GPrefix.name .. "-icon"
    if data.raw["virtual-signal"][Name] then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Crear la señal
    GPrefix.extend({
        type = "virtual-signal",
        name = Name,
        localised_name = "",
        icon = This_MOD.graphics .. "icon.png",
        icon_size = 40,
        subgroup = "virtual-signal",
        order = "z-z-o"
    })

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Cargar el sonido
function This_MOD.load_sound()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GPrefix.extend({
        type = "sound",
        name = "gui_tool_button",
        filename = "__core__/sound/gui-tool-button.ogg",
        volume = 1.0
    })

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
This_MOD.start()

---------------------------------------------------------------------------------------------------
