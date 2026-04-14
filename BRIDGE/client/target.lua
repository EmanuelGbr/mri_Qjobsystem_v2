local Target = exports.ox_target

BRIDGE.AddSphereTarget = function(data)
    if BRIDGE.UseMarkers then
        error('BRIDGE.UseMarkers is no longer supported in this Qbox/ox build.')
    end

    return Target:addSphereZone(data)
end

BRIDGE.RemoveSphereTarget = function(id)
    Target:removeZone(id)
    return true
end

BRIDGE.AddModelTarget = function(models, targetData)
    return Target:addModel(models, targetData)
end
