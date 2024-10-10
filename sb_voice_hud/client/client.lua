local microphoneEnabled = true
local isCurrentlySpeaking = false
local voiceDistance = nil
local runLoop = true
local isRangeVisible = true
local showTime = 0

-- Register YACA events
RegisterNetEvent('yaca:external:microphoneMuteStateChanged')
AddEventHandler('yaca:external:microphoneMuteStateChanged', function(state)
    microphoneEnabled = not state
end)

RegisterNetEvent("yaca:external:isTalking")
AddEventHandler('yaca:external:isTalking', function(state)
    isCurrentlySpeaking = state
end)

RegisterNetEvent('yaca:external:voiceRangeUpdate')
AddEventHandler('yaca:external:voiceRangeUpdate', function(range, rangeIndex)
    voiceDistance = range
    SendNUIMessage({
        action = "updateVoiceRange",
        range = range
    })
end)

-- Main thread for updating HUD
Citizen.CreateThread(function()
    voiceDistance = exports["yaca-voice"]:getVoiceRange()

    while true do
        Citizen.Wait(100)

        if runLoop then
            local playerName = GetPlayerName(PlayerId())
            local voiceRanges = exports["yaca-voice"]:getVoiceRanges()
            local micMuted = exports["yaca-voice"]:getMicrophoneMuteState()
            local micDisabled = exports["yaca-voice"]:getMicrophoneDisabledState()
            local soundMuted = exports["yaca-voice"]:getSoundMuteState()
            local soundDisabled = exports["yaca-voice"]:getSoundDisabledState()
            local pluginState = exports["yaca-voice"]:getPluginState()

            SendNUIMessage({
                action = "updateVoiceHUD",
                show = true,
                playerName = playerName,
                voiceRange = (not micMuted and tostring(voiceDistance) .. " m") or "Mic Off",
                voiceRanges = voiceRanges,
                isSpeaking = isCurrentlySpeaking,
                micEnabled = not micMuted,
                micDisabled = micDisabled,
                soundMuted = soundMuted,
                soundDisabled = soundDisabled,
                pluginState = pluginState
            })
        end
    end
end)

-- Toggle HUD visibility
RegisterCommand("togglevoicehud", function()
    runLoop = not runLoop
    SendNUIMessage({ action = "setVisibility", show = runLoop })
end, false)

-- Change voice range
RegisterCommand("voicerange", function(source, args)
    if #args > 0 then
        local newRange = tonumber(args[1])
        if newRange then
            TriggerEvent('yaca:external:voiceRangeUpdate', newRange, 0)
        end
    end
end, false)

-- Additional YACA events
RegisterNetEvent('yaca:external:pluginInitialized')
AddEventHandler('yaca:external:pluginInitialized', function(clientId)
    print("YACA plugin initialized with client ID: " .. clientId)
end)

RegisterNetEvent('yaca:external:pluginStateChanged')
AddEventHandler('yaca:external:pluginStateChanged', function(state)
    print("YACA plugin state changed to: " .. state)
end)

RegisterNetEvent('yaca:external:isRadioEnabled')
AddEventHandler('yaca:external:isRadioEnabled', function(state)
    SendNUIMessage({
        action = "updateRadioState",
        enabled = state
    })
end)

RegisterNetEvent('yaca:external:changedActiveRadioChannel')
AddEventHandler('yaca:external:changedActiveRadioChannel', function(channel)
    SendNUIMessage({
        action = "updateActiveRadioChannel",
        channel = channel
    })
end)

RegisterNetEvent('yaca:external:isRadioTalking')
AddEventHandler('yaca:external:isRadioTalking', function(state, channel)
    SendNUIMessage({
        action = "updateRadioTalking",
        talking = state,
        channel = channel
    })
end)

RegisterNetEvent('yaca:external:isRadioReceiving')
AddEventHandler('yaca:external:isRadioReceiving', function(state, channel)
    SendNUIMessage({
        action = "updateRadioReceiving",
        receiving = state,
        channel = channel
    })
end)
