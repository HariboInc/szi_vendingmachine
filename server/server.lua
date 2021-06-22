ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('szi_vendingmachine:canRob', function(source, cb, pos)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetPlayers()
	local itemcount = 0
	local police = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.getJob().name == 'police' then
			police = police + 1
		end
	end

	for k,v in pairs(Config.RequiredItems) do
        local item =  xPlayer.getInventoryItem(v.name)
	    if (item) and (item.count >= v.quantity) then
	    	itemcount = itemcount + 1
	    end
	end
    
	if (itemcount == #(Config.RequiredItems)) and (police >= Config.PoliceRequired) then
	    cb(true)
	    itemcount = 0
	else
	    cb(false)
	    itemcount = 0
		if police < Config.PoliceRequired then
			TriggerClientEvent('esx:showNotification', source, _U('min_police', Config.PoliceRequired))
		end
	end
end)

RegisterNetEvent("szi_vendingmachine:success")
AddEventHandler('szi_vendingmachine:success', function(pos)
	local xPlayer = ESX.GetPlayerFromId(source)
	for k,v in pairs(Config.Rewards) do
        if (v.name ~= "money") and (v.name ~= "bank") and (v.name ~= "black_money") then
		    if xPlayer.canCarryItem(v.name, v.amount) then
    	    	xPlayer.addInventoryItem(v.name, v.amount)
	    	else
   	     	    xPlayer.showNotification(_U('no_room'))
	    	end
        elseif (v.name == "bank") or (v.name == "black_money") then
            xPlayer.addAccountMoney(v.name, v.amount)
		elseif (v.name == "money") then
            xPlayer.addMoney(v.amount)
        end
	end
end)

RegisterNetEvent("szi_vendingmachine:robSuccess")
AddEventHandler('szi_vendingmachine:robSuccess', function(success)
	local xPlayer = ESX.GetPlayerFromId(source)
	if success then
		for k,v in pairs(Config.RemoveItems) do
   		 	xPlayer.removeInventoryItem(v.name, 1)
		end
	end
end)

RegisterNetEvent('szi_vendingmachine:notifyPolice')
AddEventHandler('szi_vendingmachine:notifyPolice', function(street1, street2, pos)
    local xPlayers = ESX.GetPlayers()
    local startedRobbing = true

    if startedRobbing == true then
		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
            if xPlayer.job.name == 'police' then
                TriggerClientEvent('szi_vendingmachine:blip', xPlayers[i], pos.x, pos.y, pos.z)
                TriggerClientEvent('szi_vendingmachine:notifyPolice', xPlayers[i], 'Robbery In Progress : Vending Machine | ' .. street1 .. " | " .. street2 .. ' ')
			end
		end
	end
end)

RegisterServerEvent('szi_vendingmachine:buyItem')
AddEventHandler('szi_vendingmachine:buyItem', function(itemName, price, amount)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.getMoney() >= price and xPlayer.canCarryItem(itemName, amount) then
		xPlayer.addInventoryItem(itemName, amount)
		xPlayer.removeMoney(price)
	elseif xPlayer.getMoney() <= price then
		xPlayer.showNotification('you don\'t have enough money!')
	else
		xPlayer.showNotification('You cannot carry anything else')
	end
end)

Citizen.CreateThread(function()
        local vRaw = LoadResourceFile(GetCurrentResourceName(), 'version.json')
        if vRaw then
            local v = json.decode(vRaw)
            PerformHttpRequest('https://raw.githubusercontent.com/Sub-Zero-Interactive/szi_vendingmachine/main/version.json', function(code, res, headers)
                if code == 200 then
                    local rv = json.decode(res)
                    if rv.version == v.version then
                        if rv.commit ~= v.commit then 
                            print(([[
^1----------------------------------------------------------------------
^1WARNING: YOUR SZI_VENDINGMACHINE IS OUTDATED!
^1COMMIT UPDATE: ^5%s AVAILABLE
^1DOWNLOAD:^5 https://github.com/Sub-Zero-Interactive/szi_vendingmachine
^1CHANGELOG:^5 %s
^1-----------------------------------------------------------------------
^0]]):format(rv.commit, rv.changelog))
                        else
                            print(([[
^8-------------------------------------------------------
^2Your szi_vendingmachine is the latest version!
^5Version:^0 %s
^5COMMIT:^0 %s
^5CHANGELOG:^0 %s
^8-------------------------------------------------------
^0]]):format( rv.version, rv.commit, rv.changelog))
                        end
                    else
                        print(([[
^1----------------------------------------------------------------------
^1URGENT: YOUR SZI_VENDINGMACHINE IS OUTDATATED!!!
^1COMMIT UPDATE: ^5%s AVAILABLE
^1DOWNLOAD:^5 https://github.com/Sub-Zero-Interactive/szi_vendingmachine
^1CHANGELOG:^5 %s
^1-----------------------------------------------------------------------
^0]]):format(rv.commit, rv.changelog))
                    end
                else
                    print('[^1ERROR^0] szi_vendingmachine unable to check version!')
                end
            end,'GET'
        )
    end
end)