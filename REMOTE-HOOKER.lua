local cloneref = (cloneref or clonereference or function(instance) return instance; end);

local function deepclone(args: table, copies: table): table
    local copy = nil;
    copies = copies or {};

    if type(args) == 'table' then
        if copies[args] then
            copy = copies[args];
        else
            copy = {};
            copies[args] = copy;
            for i, v in next, args do
                copy[deepclone(i, copies)] = deepclone(v, copies);
            end
        end
    elseif typeof(args) == "Instance" then
        copy = cloneref(args);
    else
        copy = args;
    end
    return copy;
end

local HOOK = nil;
HOOK = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local method = getnamecallmethod();

    if method and (method == "FireServer" or method == "fireServer" or method == "InvokeServer" or method == "invokeServer") then
        if typeof(...) == 'Instance' then
            local remote = cloneref(...);

            if game.IsA(remote, "RemoteEvent") or game.IsA(remote, "RemoteFunction") then
                if checkcaller() then return HOOK(...); end
                if not table.find(whitelist, remote.Name) then return HOOK(...); end

                local args = { select(2, ...) };
                local before = nil;
                if nphGetData then before = nphGetData(); end;
                local returns = { HOOK(...) };
                local after = nil;
                if nphGetData then after = nphGetData(); end;

                local data = {
                    method = method;
                    remote = remote;
                    args = deepclone(args);
                    before = before;
                    after = after;
                    returnvalue = returns;
                }

                args = nil
                schedule(remoteHandler, data);

                return unpack(returns);
            end
        end
    end
    return HOOK(...);
end));
