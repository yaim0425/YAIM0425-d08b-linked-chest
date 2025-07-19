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
    This_MOD.ref.name = "requester-chest"
    This_MOD.ref.entity = GPrefix.entities[This_MOD.ref.name]
    This_MOD.ref.recipe = GPrefix.recipes[This_MOD.ref.name][1]
    This_MOD.ref.item = GPrefix.items[This_MOD.ref.name]

    --- Información a duplicar
    This_MOD.duplicate = {}
    This_MOD.duplicate.name = "linked-chest"
    This_MOD.duplicate.entity = data.raw["linked-container"][This_MOD.duplicate.name]
    This_MOD.duplicate.item = data.raw["item"][This_MOD.duplicate.name]

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Crear el nuevo objeto
function This_MOD.create_item()
    --- Renombrar
    local Chest = This_MOD.Info.Items.Chest
    local Ref = This_MOD.Info.Items.Ref

    --- Nuevo prototipo
    local Item = util.copy(Ref)

    --- Sobre escribir las propiedades
    Item.name = This_MOD.NewNombre
    Item.localised_name = { "", { "entity-name." .. Chest.name } }
    Item.localised_description = nil
    Item.place_result = This_MOD.NewNombre
    Item.icons = { { icon = Chest.icon } }

    local order = tonumber(Item.order) + 1
    Item.order = GPrefix.pad_left(#Item.order, order)

    --- Crear el prototipo
    GPrefix.addDataRaw({ Item })
end

--- Crear la nueva entidad
function This_MOD.create_entity()
    --- Renombrar
    local Chest = This_MOD.Info.Entities.Chest
    local RefEntity = This_MOD.Info.Entities.Ref
    local RefItem = This_MOD.Info.Items.Ref

    --- Nuevo prototipo
    local Entity = util.copy(RefEntity)

    --- Sobre escribir las propiedades
    Entity.type = Chest.type
    Entity.name = This_MOD.NewNombre
    Entity.localised_name = { "", { "entity-name." .. Chest.name } }
    Entity.localised_description = nil
    Entity.icons = { { icon = Chest.icon } }
    Entity.picture = Chest.picture

    local Result = Entity.minable.results
    Result = GPrefix.get_table(Result, "name", RefItem.name)
    Result.name = This_MOD.NewNombre

    --- Crear el prototipo
    GPrefix.addDataRaw({ Entity })
end

--- Crear la receta
function This_MOD.create_recipe()
    --- Renombrar
    local Chest = This_MOD.Info.Items.Chest
    local RefRecipe = This_MOD.Info.Recipes.Ref
    local RefItem = This_MOD.Info.Items.Ref

    --- Nuevo prototipo
    local Recipe = util.copy(RefRecipe)

    --- Sobre escribir las propiedades
    Recipe.name = This_MOD.NewNombre
    Recipe.localised_name = { "", { "entity-name." .. Chest.name } }
    Recipe.localised_description = nil
    Recipe.icons = { { icon = Chest.icon } }

    local Result = GPrefix.get_table(Recipe.results, "name", RefItem.name)
    Result.name = This_MOD.NewNombre

    local order = tonumber(Recipe.order) + 1
    Recipe.order = GPrefix.pad_left(#Recipe.order, order)

    --- Crear el prototipo
    GPrefix.addDataRaw({ Recipe })
    GPrefix.addRecipeToTechnology(RefRecipe.name, nil, Recipe)
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
This_MOD.start()
ERROR()

---------------------------------------------------------------------------------------------------
