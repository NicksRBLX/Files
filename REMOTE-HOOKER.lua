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
    if not NPHHOOKENABLED then return HOOK(...); end
    local method = getnamecallmethod();

    if method and (method == "FireServer" or method == "fireServer" or method == "InvokeServer" or method == "invokeServer") then
        if typeof(...) == 'Instance' then
            local remote = cloneref(...);

            if game.IsA(remote, "RemoteEvent") or game.IsA(remote, "RemoteFunction") then
                if checkcaller() then return HOOK(...); end
                if not table.find(NPHHOOKWHITELIST, remote.Name) then return HOOK(...); end

                local args = { select(2, ...) };
                local before = nil;
				task.spawn(function() before = NPHGetData(); end);
                local returns = { HOOK(...) };

				task.spawn(function()
					local after = NPHGetData() or nil;
					
					local data = {
						method = method;
						remote = remote;
						args = deepclone(args);
						returnvalue = returns;
						before = before;
						after = after;
					};
					schedule(remoteHandler, data);
					
					args = nil;
				end)

                return unpack(returns);
            end
        end
    end
    return HOOK(...);
end));
