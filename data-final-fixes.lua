---------------------------------------------------------------------------------------------------
---> data-final-fixes.lua <---
---------------------------------------------------------------------------------------------------

--- Contenedor de funciones y datos usados
--- unicamente en este archivo
local ThisMOD = {}

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
function ThisMOD.Start()
    --- Valores de la referencia
    ThisMOD.setSetting()

    --- Entidades a afectar
    ThisMOD.BuildInfo()

    --- Crear los nuevos prototipos
    ThisMOD.CreateItem()
    ThisMOD.CreateEntity()
    ThisMOD.CreateRecipe()
end

--- Valores de la referencia
function ThisMOD.setSetting()
    --- Otros valores
    ThisMOD.Prefix    = "zzzYAIM0425-0800-"
    ThisMOD.name      = "linked-chest"

    --- Elemento a duplicar
    ThisMOD.Entity    = "linked-chest"

    --- Información de referencia
    ThisMOD.Info      = {}

    --- Nombre a usar
    ThisMOD.NewNombre = ThisMOD.Prefix .. ThisMOD.Entity
end

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------

--- Entidades a afectar
function ThisMOD.BuildInfo()
    --- Espacios a usar
    ThisMOD.Info.Entities = {}
    ThisMOD.Info.Recipes = {}
    ThisMOD.Info.Items = {}

    --- Renombrar
    local Entities = ThisMOD.Info.Entities
    local Recipes = ThisMOD.Info.Recipes
    local Items = ThisMOD.Info.Items

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Duplicar la entidad objetivo
    Entities.Chest = data.raw["linked-container"][ThisMOD.Entity]
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
    Result = GPrefix.get_table(Result, "name", ThisMOD.Entity)
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
function ThisMOD.CreateItem()
    --- Renombrar
    local Chest = ThisMOD.Info.Items.Chest
    local Ref = ThisMOD.Info.Items.Ref

    --- Nuevo prototipo
    local Item = util.copy(Ref)

    --- Sobre escribir las propiedades
    Item.name = ThisMOD.NewNombre
    Item.localised_name = { "", { "entity-name." .. Chest.name } }
    Item.localised_description = nil
    Item.place_result = ThisMOD.NewNombre
    Item.icons = { { icon = Chest.icon } }

    local order = tonumber(Item.order) + 1
    Item.order = GPrefix.pad_left(#Item.order, order)

    --- Crear el prototipo
    GPrefix.addDataRaw({ Item })
end

--- Crear la nueva entidad
function ThisMOD.CreateEntity()
    --- Renombrar
    local Chest = ThisMOD.Info.Entities.Chest
    local RefEntity = ThisMOD.Info.Entities.Ref
    local RefItem = ThisMOD.Info.Items.Ref

    --- Nuevo prototipo
    local Entity = util.copy(RefEntity)

    --- Sobre escribir las propiedades
    Entity.type = Chest.type
    Entity.name = ThisMOD.NewNombre
    Entity.localised_name = { "", { "entity-name." .. Chest.name } }
    Entity.localised_description = nil
    Entity.icons = { { icon = Chest.icon } }
    Entity.picture = Chest.picture

    local Result = Entity.minable.results
    Result = GPrefix.get_table(Result, "name", RefItem.name)
    Result.name = ThisMOD.NewNombre

    --- Crear el prototipo
    GPrefix.addDataRaw({ Entity })
end

--- Crear la receta
function ThisMOD.CreateRecipe()
    --- Renombrar
    local Chest = ThisMOD.Info.Items.Chest
    local RefRecipe = ThisMOD.Info.Recipes.Ref
    local RefItem = ThisMOD.Info.Items.Ref

    --- Nuevo prototipo
    local Recipe = util.copy(RefRecipe)

    --- Sobre escribir las propiedades
    Recipe.name = ThisMOD.NewNombre
    Recipe.localised_name = { "", { "entity-name." .. Chest.name } }
    Recipe.localised_description = nil
    Recipe.icons = { { icon = Chest.icon } }

    local Result = GPrefix.get_table(Recipe.results, "name", RefItem.name)
    Result.name = ThisMOD.NewNombre

    local order = tonumber(Recipe.order) + 1
    Recipe.order = GPrefix.pad_left(#Recipe.order, order)

    --- Crear el prototipo
    GPrefix.addDataRaw({ Recipe })
    GPrefix.addRecipeToTechnology(RefRecipe.name, nil, Recipe)
end

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
ThisMOD.Start()

---------------------------------------------------------------------------------------------------
