local IS_SERVER = IsDuplicityVersion()

BRIDGE = BRIDGE or {}

BRIDGE.Framework = 'qbox'
BRIDGE.Inventory = 'ox_inventory'
BRIDGE.Target = 'ox_target'
BRIDGE.UseMarkers = false

if IS_SERVER then
    BRIDGE.Notify = function(playerId, notifyData)
        lib.notify(playerId, notifyData)
    end
else
    BRIDGE.Notify = function(notifyData)
        lib.notify(notifyData)
    end
end
