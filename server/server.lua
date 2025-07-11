local MySQLExport = "oxmysql" -- easily change your export if needed

local function collectQueryResults(query, params, formatter, cb)
    exports[MySQLExport](query, params, function(results)
        local out = {}
        if results and #results > 0 then
            for i = 1, #results do
                table.insert(out, formatter(results[i]))
            end
        end
        cb(out)
    end)
end

RegisterCommand("recordsearch", function(source, args, rawCommand)
    local searchType = args[1] -- "name" or "lp"
    local searchValue = table.concat(args, " ", 2)
    if not searchType or not searchValue then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {"Records", "Usage: /recordsearch [name|lp] [value]"}
        })
        return
    end

    if searchType == "name" then
    exports[MySQLExport]:query('SELECT * FROM `pedcitations` WHERE `name` = ?', {
        searchValue
    }, function(citations)
        if citations and #citations > 0 then
            for i = 1, #citations do
                local citation = citations[i]
                TriggerClientEvent('chat:addMessage', source, {
                    color = {255, 140, 0},
                    args = {"Citations", ("ID: %s | Reason: %s | Amount: $%s | Date: %s | Location: %s, %s"):format(
                        citation.citationID, citation.reason, citation.amount, citation.date, arrest.address, citation.location
                    )}
                })
            end
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 255, 0},
                args = {"Citation Records", "No citations found for this ped."}
            })
        end

        -- Now do the second query after the first finishes
        exports[MySQLExport]:query('SELECT * FROM `defaultreports` WHERE `involved` LIKE ? OR `suspects` LIKE ? OR `victims` LIKE ?', {
            "%" .. searchValue .. "%", "%" .. searchValue .. "%", "%" .. searchValue .. "%"
        }, function(reports)
            if reports and #reports > 0 then
                for i = 1, #reports do
                    local report = reports[i]
                    TriggerClientEvent('chat:addMessage', source, {
                        color = {0, 191, 255},
                        args = {"Call Reports", ("CaseID: %s | Date: %s | Location: %s | Report: %s | Officer: %s"):format(
                            report.caseID, report.date, report.location, report.report or "N/A", report.officer or "N/A"
                        )}
                    })
                end
            else
                TriggerClientEvent('chat:addMessage', source, {
                    color = {255, 255, 0},
                    args = {"Call Reports", "No reports found for this ped."}
                })
            end

            -- Now do arrest reports only after reports finish
            exports[MySQLExport]:query('SELECT * FROM `arrestreports` WHERE `defendantName` = ?', {
                searchValue
            }, function(arrests)
                if arrests and #arrests > 0 then
                    for i = 1, #arrests do
                        local arrest = arrests[i]
                        TriggerClientEvent('chat:addMessage', source, {
                            color = {255, 0, 255},
                            args = {"Arrest Reports", ("CaseID: %s | Date: %s | Charges: %s | Officer: %s | Location: %s, %s, %s"):format(
                                arrest.caseID, arrest.date, arrest.charges, arrest.arrestingOfficer, arrest.city, arrest.street, arrest.zip
                            )}
                        })
                    end
                else
                    TriggerClientEvent('chat:addMessage', source, {
                        color = {255, 255, 0},
                        args = {"Arrest Records", "No arrest reports found for this ped."}
                    })
                end
            end)
        end)
    end)
    elseif searchType == "lp" then
        -- Vehicle Citations
        exports[MySQLExport]:query('SELECT * FROM `vehiclecitations` WHERE `licenseplate` = ?', {
            searchValue
        }, function(citations)
            if citations and #citations > 0 then
                for i = 1, #citations do
                    local citation = citations[i]
                    TriggerClientEvent('chat:addMessage', source, {
                        color = {255, 140, 0},
                        args = {"Vehicle Citation", ("ID: %s | Reason: %s | Amount: $%s | Date: %s | Location: %s"):format(
                            citation.citationID, citation.reason, citation.amount, citation.date, citation.location
                        )}
                    })
                end
            else
                TriggerClientEvent('chat:addMessage', source, {
                    color = {255, 255, 0},
                    args = {"Records", "No vehicle citations found for this plate."}
                })
            end
        end)
    end
end)

RegisterNetEvent("recordsearch:nuiSearch")
AddEventHandler("recordsearch:nuiSearch", function(query)
    local src = source
    local allResults = {}

    -- Ped Citations
    exports[MySQLExport]:query('SELECT * FROM `pedcitations` WHERE `name` = ?', {query}, function(citations)
        table.sort(citations, function(a, b)
            return (a.date or a.timestamp or 0) > (b.date or b.timestamp or 0)
        end)
        for _, c in ipairs(citations) do
            table.insert(allResults, ("Citation: ID: %s | Reason: %s | Amount: $%s | Date: %s | Location: %s, %s"):format(
                c.citationID, c.reason, c.amount, c.date, c.address, c.location))
        end

        -- Reports
        exports[MySQLExport]:query('SELECT * FROM `defaultreports` WHERE `involved` LIKE ? OR `suspects` LIKE ? OR `victims` LIKE ?', 
            {"%" .. query .. "%", "%" .. query .. "%", "%" .. query .. "%"}, function(reports)
            table.sort(reports, function(a, b)
                return (a.date or a.timestamp or 0) > (b.date or b.timestamp or 0)
            end)
            for _, r in ipairs(reports) do
                table.insert(allResults, ("Report: CaseID: %s | Date: %s | Location: %s | Officer: %s"):format(
                    r.caseID, r.date, r.location, r.officer or "N/A"))
            end

            -- Arrest Reports
            exports[MySQLExport]:query('SELECT * FROM `arrestreports` WHERE `defendantName` = ?', {query}, function(arrests)
                table.sort(arrests, function(a, b)
                    return (a.date or a.timestamp or 0) > (b.date or b.timestamp or 0)
                end)
                for _, a in ipairs(arrests) do
                    table.insert(allResults, ("Arrest: CaseID: %s | Date: %s | Charges: %s | Officer: %s | Location: %s, %s, %s"):format(
                        a.caseID, a.date, a.charges, a.arrestingOfficer, a.city, a.street, a.zip))
                end

                -- Vehicle Citations
                exports[MySQLExport]:query('SELECT * FROM `vehiclecitations` WHERE `licenseplate` = ?', {query}, function(vcits)
                    table.sort(vcits, function(a, b)
                        return (a.date or a.timestamp or 0) > (b.date or b.timestamp or 0)
                    end)
                    for _, v in ipairs(vcits) do
                        table.insert(allResults, ("Vehicle Citation: ID: %s | Reason: %s | Amount: $%s | Date: %s | Location: %s"):format(
                            v.citationID, v.reason, v.amount, v.date, v.location))
                    end

                    -- Send sorted results to client
                    TriggerClientEvent("recordsearch:nuiResults", src, allResults)
                end)
            end)
        end)
    end)
end)