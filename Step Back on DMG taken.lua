--[[
    Script Name: 		Step back on DMG taken 
    Description: 		Step to ground x, y, z when any dmg taken. // Edited: 2019-02-15, Added: step to position far than 1 sqm
    Author: 			Ascer - example
]]

local STEP_POS = {32323, 32349, 5}  -- our house position or safe area to hide when dmg
local STEP_BACK = {enabled = false, pos = {32323, 32349, 5}, delay = 6}    -- return to previus position when will safe, @eabled - true/false, @pos - {x, y, z}, @delay - minutes

local KEY_WORDS = {"You lose"}              -- set keyword for activate
local FRIENDS = {"Friend1", "Friend2"}      -- friend list to avoid, name with capital letters.

-- DON'T EDIT BELOW THIS LINE

local stepTime, lastProxy, isDmg, backPos = 0, "", false, false

----------------------------------------------------------------------------------------------------------------------------------------------------------
--> Function:       getProxy(keywords, friends)
--> Description:    Search in error message proxy specific keyword.
--> Class:          None
--> Params:         
-->                 @keywords table of strings we search.
-->                 @friends table if our friends to avoid if we skill example.
--> Return:         string last proxy message if keyword found or empty string ""
----------------------------------------------------------------------------------------------------------------------------------------------------------
function getProxy(keywords, friends)

    -- load last proxy msg
    local proxy = Proxy.ErrorGetLastMessage()

    -- in loop for key words
    for i = 1, #keywords do

        -- load single key
        local key = keywords[i]

        -- check if string is inside proxy
        if string.instr(proxy, key) then

            -- in loop check if string not contains our friends.
            for j = 1, #friends do

                -- load single friend.
                local friend = friends[j]

                -- check if attacking our friend.
                if string.instr(proxy, "attack by " .. friend) then

                    -- return empty string
                    return ""

                end    

            end

            -- return proxy.
            return proxy

        end
        
    end
    
    -- return empty string ""
    return ""        

end



Module.New("Step back on DMG taken", function ()
    
    -- load if we found proxy key
    local proxy = getProxy(KEY_WORDS, FRIENDS)

    -- if proxy is different than ""
    if proxy ~= "" then

        -- set param isDmg true
        isDmg = true

        -- store last proxy
        lastProxy = proxy

    end    

    -- if param isDmg contains true then we should step to house.
    if isDmg then

        -- load distane from step pos
        local dist = Self.DistanceFromPosition(STEP_POS[1], STEP_POS[2], STEP_POS[3])

        -- when distance is diff than 0
        if dist ~= 0 then

            -- wait time to avoid auto step this my by easy detectable as bot
            wait(800, 1500)

            -- load direction to step.
            local dir = Self.getDirectionFromPosition(STEP_POS[1], STEP_POS[2], STEP_POS[3], dist)

            -- step to safe pos
            Self.Step(dir)

            -- if you want to step into character in door use wait and step to go through.
            -- wait(200)
            -- Self.Step(dir)

        else

            -- we need to clear message.
            Proxy.ErrorClearMessage()

            -- set message to Rifbot console
            Rifbot.ConsoleWrite(lastProxy)

            -- set time we are in house.
            stepTime = os.time()

            -- set variable isDmg false
            isDmg = false

            -- set variable backPos true
            backPos = true

        end

    -- if no dmg taken or we are in house    
    else

        -- if backPos is enabled
        if backPos then

            -- when time is valid.
            if os.time() - stepTime > (STEP_BACK.delay * 60) then

                local distance = Self.DistanceFromPosition(STEP_BACK.pos[1], STEP_BACK.pos[2], STEP_BACK.pos[3])

                -- when our position is different than currentPos or we dont enabled step back.
                if distance > 0 then

                    -- load direction to step.
                    local dir = Self.getDirectionFromPosition(STEP_BACK.pos[1], STEP_BACK.pos[2], STEP_BACK.pos[3], distance)

                    -- step to this direction.
                    Self.Step(dir)

                    -- You can also use alana sio to tp yourself.
                    -- Self.Say("alana sio")

                    -- wait some time to avoid over dashing.
                    wait(500, 1000)

                -- our position is this same as we stay before
                else
                    
                    -- set message to console.
                    printf("Successfully return to position due a DMG taken.")

                    -- reset time
                    stepTime = 0

                    -- set backPos false
                    backPos = false

                end

            else
            
                -- When step back is enabled.
                if STEP_BACK.enabled then

                    -- show message time to back
                    printf(lastProxy .. " Back within " .. STEP_BACK.delay .. " minutes")

                else
                    
                    -- show message back is disabled
                    printf(lastProxy .. " Step back is disabled.")

                    -- reset time we dont want to back.
                    stepTime = 0

                    -- set backPos false
                    backPos = false    

                end
                    
            end

        end    

    end 

end)
