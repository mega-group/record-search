function GetCurrentVersion()
	return GetResourceMetadata( GetCurrentResourceName(), "version" )
end

function GetLatestVersion(callback)
    PerformHttpRequest(
        "https://raw.githubusercontent.com/mega-group/record-search/refs/heads/main/fxmanifest.lua",
        function(status, body, headers)
            if status == 200 and body then
                local latest = string.match(body, 'version%s+"([%d%.]+)"')
                callback(latest)
            else
                callback(nil)
            end
        end, "GET", "", {}
    )
end

function CheckForUpdate()
    local current = GetCurrentVersion()
    GetLatestVersion(function(latest)
        if not latest then
            print("^1[Updater]^0 Could not fetch latest version info.")
            return
        end
        if current == latest then
            print(("^2[Updater]^0 Version %s is up to date."):format(current))
            print("^2[Updater]^0 Thank you for using Record Search! We wish you the best in your FivePD adventures!")
        else
            print(("^1[Updater]^0 You have version %s which is outdated. Please update to version %s."):format(current, latest))
        end
    end)
end

if GetCurrentResourceName() == "record-search" then
    CheckForUpdate()
else
    print("^1[Updater]^0 This script is not running in the record-search resource.")
end