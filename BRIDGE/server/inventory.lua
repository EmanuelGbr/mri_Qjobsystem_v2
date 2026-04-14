local Inventory = exports.ox_inventory

BRIDGE.GetItems = function()
    return Inventory:Items()
end

BRIDGE.GetItemCount = function(playerId, itemName)
    return Inventory:Search(playerId, 'count', itemName) or 0
end

BRIDGE.AddItem = function(playerId, itemName, count, metadata)
    return Inventory:AddItem(playerId, itemName, count, metadata)
end

BRIDGE.RemoveItem = function(playerId, itemName, count)
    return Inventory:RemoveItem(playerId, itemName, count)
end

BRIDGE.RegisterStash = function(id, label, slots, weight, groups, coords)
    Inventory:RegisterStash(id, label, slots, weight, groups, coords)
end
