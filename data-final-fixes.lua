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

    -- --- Entidades a afectar
    -- This_MOD.BuildInfo()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    -- --- Crear los nuevos prototipos
    -- This_MOD.CreateItem()
    -- This_MOD.CreateEntity()
    -- This_MOD.CreateRecipe()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Valores de la referencia
function This_MOD.setting_mod()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Elemento a duplicar
    This_MOD.entity_ref = "linked-chest"

    --- Información de referencia
    This_MOD.entity = {}
    This_MOD.recipe = {}
    This_MOD.item = {}

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Entidades a afectar
function This_MOD.BuildInfo()
    --- Espacios a usar
    This_MOD.Info.Entities = {}
    This_MOD.Info.Recipes = {}
    This_MOD.Info.Items = {}

    --- Renombrar
    local Entities = This_MOD.Info.Entities
    local Recipes = This_MOD.Info.Recipes
    local Items = This_MOD.Info.Items

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Duplicar la entidad objetivo
    Entities.Chest = data.raw["linked-container"][This_MOD.entity_ref]
    Entities.Chest = util.copy(Entities.Chest)

    --- Ajustar la parte de mineria
    if Entities.Chest.minable.result then
        --- Renombrar
        local minable = Entities.Chest.minable

        --- Dar el formato deseado
        minable.results = { {
            type = "item",
            name = minable.result,
            amount = minable.count or 1
        } }

        --- Borrar
        minable.result = nil
        minable.count = nil
    end

    --- Duplicar el objeto
    local Result = Entities.Chest.minable.results
    Result = GPrefix.get_table(Result, "name", This_MOD.entity_ref)
    Items.Chest = data.raw.item[Result.name]

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
    for key, name in pairs(Chest) do
        Chest[key] = GPrefix.items[name]
        Order_chest[Chest[key].order] = Chest[key]
        table.insert(Orders, Chest[key].order)
    end

    --- Ordenar los objetos
    table.sort(Orders)

    --- Obtener las referencia
    Items.Ref = Order_chest[Orders[#Chest]]
    Entities.Ref = GPrefix.entities[Items.Ref.place_result]
    Recipes.Ref = GPrefix.recipes[Items.Ref.name][1]
end

--- Crear el nuevo objeto
function This_MOD.CreateItem()
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
function This_MOD.CreateEntity()
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
function This_MOD.CreateRecipe()
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

---------------------------------------------------------------------------------------------------
