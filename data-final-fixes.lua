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

--- Crear el nuevo objeto
function This_MOD.create_item()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nuevo prototipo
    local Item = util.copy(This_MOD.ref.item)

    --- Sobre escribir las propiedades
    Item.name = This_MOD.prefix .. This_MOD.duplicate.item.name
    Item.icons = This_MOD.duplicate.item.icons
    Item.place_result = This_MOD.prefix .. This_MOD.duplicate.entity.name

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
    Entity.name = This_MOD.prefix .. This_MOD.duplicate.entity.name

    Entity.localised_name = { "", { "entity-name." .. This_MOD.duplicate.entity.name } }
    Entity.localised_description = { "", { "entity-description." .. This_MOD.duplicate.entity.name } }

    Entity.icons = This_MOD.duplicate.entity.icons
    Entity.picture = This_MOD.duplicate.entity.picture

    local Result = Entity.minable.results
    Result = GPrefix.get_table(Result, "name", This_MOD.ref.item.name)
    Result.name = This_MOD.prefix .. This_MOD.duplicate.item.name

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
    Recipe.name = This_MOD.prefix .. This_MOD.duplicate.item.name
    Recipe.icons = This_MOD.duplicate.entity.icons

    Recipe.localised_name = { "", { "entity-name." .. This_MOD.duplicate.entity.name } }
    Recipe.localised_description = { "", { "entity-description." .. This_MOD.duplicate.entity.name } }

    local Result = GPrefix.get_table(Recipe.results, "name", This_MOD.ref.item.name)
    Result.name = This_MOD.prefix .. This_MOD.duplicate.item.name

    local order = tonumber(Recipe.order) + 1
    Recipe.order = GPrefix.pad_left_zeros(#Recipe.order, order)

    --- Crear el prototipo
    GPrefix.add_recipe_to_tech_with_recipe(
        This_MOD.ref.recipe.name,
        Recipe
    )

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
This_MOD.start()
-- ERROR()

---------------------------------------------------------------------------------------------------
