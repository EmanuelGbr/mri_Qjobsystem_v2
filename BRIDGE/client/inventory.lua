local Inventory = exports.ox_inventory

BRIDGE.GetItems = function()
    return Inventory:Items()
end

BRIDGE.GetItemCount = function(itemName)
    return Inventory:Search('count', itemName) or 0
end

BRIDGE.OpenStash = function(stashName)
    Inventory:openInventory('stash', { id = stashName })
end
