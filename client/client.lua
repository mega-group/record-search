TriggerEvent('chat:addSuggestion', '/recordsearch', 'Search for a ped name or license plate', {
    { name="name|lp", help="Type of search: 'name' or 'lp'" },
    { name="value", help="Name or license plate to search for" }
})

-- Show NUI (for example, with a command)
RegisterCommand("mdt", function()
    SetNuiFocus(true, true)
    SendNUIMessage({ type = "show" })
end)

-- Hide NUI (add a button in your HTML to call this)
RegisterNUICallback("close", function(_, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

-- Handle search from NUI
RegisterNUICallback("search", function(data, cb)
    -- Send search to server
    TriggerServerEvent("recordsearch:nuiSearch", data.query)
    cb("ok")
end)

-- Receive results from server and send to NUI
RegisterNetEvent("recordsearch:nuiResults")
AddEventHandler("recordsearch:nuiResults", function(results)
    SendNUIMessage({ type = "results", results = results })
end)