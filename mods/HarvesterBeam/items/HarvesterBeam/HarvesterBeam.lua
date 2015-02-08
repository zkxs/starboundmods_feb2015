function init()
        harvestBlacklist = {}
        self.distance = item.instanceValue("harvestDistance") or 40
end
 
function fireTriggered()
        if self.owner == nil then return nil end
        local armPos = vec2.add(vec2.norm(vec2.sub(item.ownerAimPosition(), item.ownerPosition())), item.ownerPosition())
        local toPointer = vec2.sub(armPos, vec2.mul(vec2.norm(world.distance(armPos, item.ownerAimPosition())), self.distance))
        local blockCheck = world.collisionBlocksAlongLine(armPos, toPointer, true, 1)
        if blockCheck[1] ~= nil then
                local blockSide = 0
                if world.distance(item.ownerPosition(), blockCheck[1])[1] < 0 then
                        blockSide = -0.5
                else
                        blockSide = 1.5
                end
                local tempWallX = {vec2.add(blockCheck[1], {blockSide, -3}), vec2.add(blockCheck[1], {blockSide, 3})}
                if world.distance(item.ownerPosition(), blockCheck[1])[2] < 0 then
                        blockSide = -0.5
                else
                        blockSide = 1.5
                end
                local tempWallY = {vec2.add(blockCheck[1], {-3, blockSide}), vec2.add(blockCheck[1], {3, blockSide})}
                world.debugLine(tempWallX[1], tempWallX[2], "green")
                world.debugLine(tempWallY[1], tempWallY[2], "green")
                toPointer = vec2.intersect(armPos, toPointer, tempWallX[1], tempWallX[2]) or toPointer
                toPointer = vec2.intersect(armPos, toPointer, tempWallY[1], tempWallY[2]) or toPointer
        end
        world.debugLine(armPos, toPointer, "blue")
        local farmQuery = world.entityLineQuery(armPos, toPointer,{inSightOf = self.owner})
        for i,j in pairs(farmQuery) do
                --world.logInfo("%s, %s at %s: %s", j, world.entityType(j), world.entityPosition(j), world.farmabaleStage(j))
                if world.farmableStage(j) ~= nil and harvestBlacklist[j] == nil then
                        harvestBlacklist[j] = 100
                        world.damageTiles({world.entityPosition(j)}, "foreground", world.entityPosition(j), "plantish", 0.2, 1)
                end    
        end
end
 
function update(dt)
        if self.owner == nil then
                self.owner = world.playerQuery(item.ownerPosition(), 0.2)[1]
                --world.logInfo("%s", self.owner)
        end
        if harvestBlacklist ~= {} then
                for i,j in pairs(harvestBlacklist) do
                        if j > 0 then
                                harvestBlacklist[i] = j-1
                        else
                                harvestBlacklist[i] = nil
                        end
                end
        end
end