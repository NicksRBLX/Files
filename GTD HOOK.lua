local HOOK = nil;
HOOK = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local method = getnamecallmethod();

    if method and (method == "FireServer" or method == "fireServer" or method == "InvokeServer" or method == "invokeServer") then
        if typeof(...) == 'Instance' then
            local remote = cloneref(...);

            if game.IsA(remote, "RemoteEvent") or game.IsA(remote, "RemoteFunction") then
                if checkcaller() then return HOOK(...); end
                if not Toggles["EnableRecordMacro"].Value then return HOOK(...); end
                if not table.find({
                    "PlaceUnit",
                    "UpgradeUnit",
                    "SellUnit"
                }, remote.Name) then return HOOK(...); end

                local args = { select(2, ...) };
                local returns = { HOOK(...) };

                local saveTask = false;
                local task = {};

                -- Make Condition Checker
                task["Condition"] = { ["Type"] = "None"; };
                if Options["RecordMacroMode"].Value == "Cash" then
                    task["Condition"]["Type"] = "Cash";
                    task["Condition"]["Data"] = tonumber(LocalPlayer:GetAttribute("Cash"));
                elseif Options["RecordMacroMode"].Value == "Time" then
                    task["Condition"]["Type"] = "Time";
                    task["Condition"]["Speed"] = tonumber(Workspace:GetAttribute("TickSpeed"));
                    task["Condition"]["Data"] = math.ceil(os.time() - tonumber(Workspace:GetAttribute("GameStartTime")));
                elseif Options["RecordMacroMode"].Value == "Wave" then
                    task["Condition"]["Type"] = "Wave";
                    task["Condition"]["Data"] = tonumber(Workspace:GetAttribute("Round"));
                end

                local whitelist = Options["RecordMacroWhitelist"].Value;
                if remote.Name == "PlaceUnit" and whitelist["Place Unit"] == true then
                    if returns[1] == true then
                        task["Task"] = "PlaceUnit";
                        task["Unit"] = args[1];
                        task["Data"] = {
                            ["Position"] = { args[2]["Position"].X, args[2]["Position"].Y, args[2]["Position"].Z };
                            ["CF"] = { (args[2]["CF"]):GetComponents() };
                            ["Rotation"] = tonumber(args[2]["Rotation"]);
                        };
                        if args[2]["PathIndex"] then task["Data"]["PathIndex"] = tonumber(args[2]["PathIndex"]); end
                        if args[2]["DistanceAlongPath"] then task["Data"]["DistanceAlongPath"] = tonumber(args[2]["DistanceAlongPath"]); end
                        task["ID"] = "unit_"..tostring(returns[2]);
                        saveTask = true;
                    end
                elseif remote.Name == "UpgradeUnit" and whitelist["Upgrade Unit"] == true then
                    if returns[1] == true then
                        task["Task"] = "UpgradeUnit";
                        task["Upgrades"] = 1;
                        task["ID"] = "unit_"..tostring(args[1]);
                        saveTask = true;

                        local lastTask = RECORDS[#RECORDS];
                        if lastTask then
                            if lastTask["Task"] == "UpgradeUnit" and lastTask["ID"] == task["ID"] then
                                lastTask["Upgrades"] = lastTask["Upgrades"] + 1;
                                saveTask = false;
                            end
                        end
                    end
                elseif remote.Name == "SellUnit" and whitelist["Sell Unit"] == true then
                    if returns[1] == true then
                        task["Task"] = "SellUnit";
                        task["ID"] = "unit_"..tostring(args[1]);
                        saveTask = true;
                    end
                end

                if saveTask then table.insert(RECORDS, task); end
                return unpack(returns);
            end
        end
    end
    return HOOK(...);
end));
