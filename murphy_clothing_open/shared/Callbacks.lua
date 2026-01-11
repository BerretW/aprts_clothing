local currentRequestId = 0
local responseCallback = {}
local registeredCallback = {}

local server = IsDuplicityVersion()

Callback = {}

local function executeCallback(name, ...)
  if not registeredCallback[name] then return printconsole(('No callback for: %s'):format(name)) end
  return registeredCallback[name].cb(...)
end

local function executeResponse(requestId, fromRessource, ...)
  if not responseCallback[requestId] then return printconsole(('No callback response for: %d - Called from: %d'):format(requestId, fromRessource)) end
  responseCallback[requestId](...)
  responseCallback[requestId] = nil
end


---@param name string the name of the event
---@param cb function
function Callback.register(name, cb)
  if registeredCallback[name] then return printconsole('Callback already registered:', name) end
  registeredCallback[name] = {
    cb = cb,
    resource = GetInvokingResource()
  }
end



if server then

  ---@param name string Name of the callback event
  ---@param cb function return of the event
  ---@param ...? any
  function Callback.triggerClient(name, source, cb, ...)
    if not GetPlayerIdentifier(source) then
      return printconsole('Callback Module: Player is not connected - source: ' .. source)
    end
    responseCallback[currentRequestId] = cb

    -- Use latent event for large data transfers (e.g., MURPHY_ASSETS)
    TriggerLatentClientEvent('murphy_clothing:triggerCallback', source, 900000, name, currentRequestId, GetInvokingResource() or "unknown", ...)

    currentRequestId = currentRequestId < 65535 and currentRequestId + 1 or 0
  end

  function Callback.triggerServer(name, cb, ...)
    if not registeredCallback[name] then return printconsole('No server callback for:', name) end

    if cb then
      cb(executeCallback(name, ...))
    else
      return executeCallback(name, ...)
    end
  end

  RegisterServerEvent('murphy_clothing:responseCallback', executeResponse)

  RegisterServerEvent('murphy_clothing:triggerCallback', function(name, requestId, fromRessource, ...)
    local source = source
    -- Use latent event for large response data (e.g., clothing data)
    TriggerLatentClientEvent('murphy_clothing:responseCallback', source, 900000, requestId, fromRessource, executeCallback(name, source, ...))
  end)

else

  ---@param name string Name of the callback event
  ---@param cb function return of the event
  ---@param ...? any
  function Callback.triggerServer(name, cb, ...)
    responseCallback[currentRequestId] = cb

    TriggerLatentServerEvent("murphy_clothing:triggerCallback", 900000, name, currentRequestId, GetInvokingResource() or 'unknown', ...)

    currentRequestId = currentRequestId < 65535 and currentRequestId + 1 or 0
  end


  function Callback.triggerClient(name, cb, ...)
    if not registeredCallback[name] then return printconsole('No client callback for:', name) end
    if cb then
      cb(executeCallback(name, ...))
    else
      return executeCallback(name, ...)
    end
  end

  RegisterNetEvent('murphy_clothing:responseCallback', executeResponse)

  RegisterNetEvent('murphy_clothing:triggerCallback', function(name, requestId, fromRessource, ...)
    TriggerLatentServerEvent("murphy_clothing:triggerCallback", 900000, requestId, fromRessource, executeCallback(name, ...))
  end)


end

function printconsole(...)
  if IsDuplicityVersion() then
    return print("^1" .. GetCurrentResourceName() .. ":", ..., "^0")
  end
  return print("^1", ...)
end

AddEventHandler('onResourceStop', function(resource)
  for name, callback in pairs(registeredCallback) do
    if callback.resource == resource then
      registeredCallback[name] = nil
    end
  end
end)
