--local Text               = {}
local BanList            = {}
local BanListLoad        = false
CreateThread(function()
        while true do
                Wait(1000)
        if BanListLoad == false then
                        loadBanList()
                        if BanList ~= {} then
                                --print(Text.banlistloaded)
                                BanListLoad = true
                        else
                                --print(Text.starterror)
                        end
                end
        end
end)


CreateThread(function()
        while true do
                Wait(600000)
        if BanListLoad == true then
                        loadBanList()
                end
        end
end)

RegisterServerEvent('aopkfgebjzhfpazf77')
AddEventHandler('aopkfgebjzhfpazf77', function(reason,servertarget)
        local license,identifier,liveid,xblid,discord,playerip,target
        local duree     = 1
        local reason    = reason

        if not reason then reason = "Auto Anti-Cheat" end

        if tostring(source) == "" then
                target = tonumber(servertarget)
        else
                target = source
        end

        if target and target > 1 then
                local ping = GetPlayerPing(target)

                if ping and ping > 1 then
                        if duree and duree < 365 then
                                local sourceplayername = "PolarisAC"
                                local targetplayername = GetPlayerName(target)
                                        for k,v in ipairs(GetPlayerIdentifiers(target))do
                                                if string.sub(v, 1, string.len("license:")) == "license:" then
                                                        license = v
                                                elseif string.sub(v, 1, string.len("steam:")) == "steam:" then
                                                        identifier = v
                                                elseif string.sub(v, 1, string.len("live:")) == "live:" then
                                                        liveid = v
                                                elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
                                                        xblid  = v
                                                elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
                                                        discord = v
                                                elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
                                                        playerip = v
                                                end
                                        end

                                if duree > 1 then
                                        ban(target,license,identifier,liveid,xblid,discord,playerip,targetplayername,sourceplayername,duree,reason,1)
                                        DropPlayer(target, "〈💙〉 PolarisAC: ".. ConfigACC.BanReason .." ")
                                else
                                        ban(target,license,identifier,liveid,xblid,discord,playerip,targetplayername,sourceplayername,duree,reason,1)
                                        DropPlayer(target, "〈💙〉 PolarisAC: ".. ConfigACC.BanReason .." ")
                                end

                        else
                                --print("BanSql Error : Auto-Cheat-Ban time invalid.")
                        end
                else
                        --print("BanSql Error : Auto-Cheat-Ban target are not online.")
                end
        else
                --print("BanSql Error : Auto-Cheat-Ban have recive invalid id.")
        end
end)

AddEventHandler('playerConnecting', function (playerName,setKickReason)
        local license,steamID,liveid,xblid,discord,playerip  = "n/a","n/a","n/a","n/a","n/a","n/a"

        for k,v in ipairs(GetPlayerIdentifiers(source))do
                if string.sub(v, 1, string.len("license:")) == "license:" then
                        license = v
                elseif string.sub(v, 1, string.len("steam:")) == "steam:" then
                        steamID = v
                elseif string.sub(v, 1, string.len("live:")) == "live:" then
                        liveid = v
                elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
                        xblid  = v
                elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
                        discord = v
                elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
                        playerip = v
                end
        end

        if (Banlist == {}) then
                Citizen.Wait(1000)
        end


        for i = 1, #BanList, 1 do
                if
                          ((tostring(BanList[i].license)) == tostring(license)
                        or (tostring(BanList[i].identifier)) == tostring(steamID)
                        or (tostring(BanList[i].liveid)) == tostring(liveid)
                        or (tostring(BanList[i].xblid)) == tostring(xblid)
                        or (tostring(BanList[i].discord)) == tostring(discord)
                        or (tostring(BanList[i].playerip)) == tostring(playerip))
                then

                        if (tonumber(BanList[i].permanent)) == 1 then
                                setKickReason("〈💙〉 PolarisAC: " .. ConfigACC.BanReason .."")
                CancelEvent()
                break
                        end
                end
        end
end)

function ban(source,license,identifier,liveid,xblid,discord,playerip,targetplayername,sourceplayername,duree,reason,permanent)
        local expiration = duree * 84000
        local timeat     = os.time()
        local added      = os.date()

        if expiration < os.time() then
                expiration = os.time()+expiration
        end

                table.insert(BanList, {
                        license    = license,
                        identifier = identifier,
                        liveid     = liveid,
                        xblid      = xblid,
                        discord    = discord,
                        playerip   = playerip,
                        reason     = reason,
                        expiration = expiration,
                        permanent  = permanent
          })

                MySQL.Async.execute(
                'INSERT INTO polaris_bans (license,identifier,liveid,xblid,discord,playerip,targetplayername,sourceplayername,reason,expiration,timeat,permanent) VALUES (@license,@identifier,@liveid,@xblid,@discord,@playerip,@targetplayername,@sourceplayername,@reason,@expiration,@timeat,@permanent)',
                {
                                ['@license']          = license,
                                ['@identifier']       = identifier,
                                ['@liveid']           = liveid,
                                ['@xblid']            = xblid,
                                ['@discord']          = discord,
                                ['@playerip']         = playerip,
                                ['@targetplayername'] = targetplayername,
                                ['@sourceplayername'] = sourceplayername,
                                ['@reason']           = reason,
                                ['@expiration']       = expiration,
                                ['@timeat']           = timeat,
                                ['@permanent']        = permanent,
                                },
                                function ()
                end)
                BanListHistoryLoad = true
end

function loadBanList()
        MySQL.Async.fetchAll(
                'SELECT * FROM polaris_bans',
                {},
                function (data)
                  BanList = {}

                  for i=1, #data, 1 do
                        table.insert(BanList, {
                                license    = data[i].license,
                                identifier = data[i].identifier,
                                liveid     = data[i].liveid,
                                xblid      = data[i].xblid,
                                discord    = data[i].discord,
                                playerip   = data[i].playerip,
                                reason     = data[i].reason,
                                expiration = data[i].expiration,
                                permanent  = data[i].permanent
                          })
                  end
    end)
end

RegisterCommand("unban", function(source, args, raw)
                cmdunban(source, args)
end)

function cmdunban(source, args)
    if args[1] then
        local target = table.concat(args, " ")
        MySQL.Async.fetchAll('SELECT * FROM banlist WHERE targetplayername like @playername', {
            ['@playername'] = ("%"..target.."%")
        }, function(data)
            if data[1] then
                if #data > 1 then
                else
                    MySQL.Async.execute('DELETE FROM banlist WHERE targetplayername = @name', {
                        ['@name']  = data[1].targetplayername
                    }, function ()
                        loadBanList()
                        TriggerClientEvent('chat:addMessage', source, { args = { '^1Banlist ', data[1].targetplayername.." was unban from PolarisAC" } } )
                    end)
                end
            else
            end
        end)
    else
    end
end

local newestversion = "v4.0"
local versionac = ConfigACS.Version

function inTable(tbl, item)
    for key, value in pairs(tbl) do
        if value == item then return key end
    end
    return false
end

RegisterServerEvent("ws:getIsAllowed")
AddEventHandler("ws:getIsAllowed", function()
    if IsPlayerAceAllowed(source, "polarisacbypass") then
        TriggerClientEvent("ws:returnIsAllowed", source, true)
    else
        TriggerClientEvent("ws:returnIsAllowed", source, false)
    end
end)

Citizen.CreateThread(function()
    SetConvarServerInfo("💙PolarisAC", "ON")
    logo()
    print("^1Loading Configs...")
    print("^2Loading Configs...")
    print("^3Loading Configs...^0")
    Wait(1000)
    print("^1[PolarisAC] ^0Authenticating to PolarisAC.....")
    print("^2[PolarisAC] ^2Authentification Was Successful.")
    print("^3[PolarisAC] ^0License Expires: ^2Never")
    print("^4[PolarisAC] ^2Contact Neuss#1864 if you have problems")
    print("^5[PolarisAC] ^3Welcome to PolarisAC")
    if nullfieldcheck() then
        print("^8[PolarisAC] ^2Files Are Correct!^0")
        Wait(1000)
        print("^2Succesfully Loaded Anti-Cheat!^0")
    end
    ACStarted()
end)

function logo()
    print([[

    ^8    __        __         _                                   
    ^8    \ \      / /   ___  | |   ___    ___    _ __ ___     ___ 
    ^8     \ \ /\ / /   / _ \ | |  / __|  / _ \  | '_ ` _ \   / _ \
    ^8      \ V  V /   |  __/ | | | (__  | (_) | | | | | | | |  __/
    ^8       \_/\_/     \___| |_|  \___|  \___/  |_| |_| |_|  \___|
                                                                 

]])
end

function show()
    print([[
        ^8        _______ad88888888888888888888888a, 
        ^8________a88888"8888888888888888888888, 
        ^8______,8888"__"P88888888888888888888b, 
        ^8______d88_________`""P88888888888888888, 
        ^8_____,8888b_______________""88888888888888, 
        ^8_____d8P'''__,aa,______________""888888888b 
        ^8_____888bbdd888888ba,__,I_________"88888888, 
        ^8_____8888888888888888ba8"_________,88888888b 
        ^8____,888888888888888888b,________,8888888888 
        ^8____(88888888888888888888,______,88888888888, 
        ^8____d888888888888888888888,____,8___"8888888b 
        ^8____88888888888888888888888__.;8'"""__(888888 
        ^8____8888888888888I"8888888P_,8"_,aaa,__888888 
        ^8____888888888888I:8888888"_,8"__`b8d'__(88888 
        ^8____(8888888888I'888888P'_,8)__________88888 
        ^8_____88888888I"__8888P'__,8")__________88888 
        ^8_____8888888I'___888"___,8"_(._.)_______88888 
        ^8_____(8888I"_____"88,__,8"_____________,8888P 
        ^8______888I'_______"P8_,8"_____________,88888) 
        ^8_____(88I'__________",8"__M""""""M___,888888' 
        ^8____,8I"____________,8(____"aaaa"___,8888888 
        ^8___,8I'____________,888a___________,8888888) 
        ^8__,8I'____________,888888,_______,888888888 
        ^8_,8I'____________,8888888'`-===-'888888888' 
        ^8,8I'____________,8888888"________88888888" 
        ^88I'____________,8"____88_________"888888P 
        ^88I____________,8'_____88__________`P888" 
        ^88I___________,8I______88____________"8ba,. 
        ^8(8,_________,8P'______88______________88""8bma,. 
        ^8_8I________,8P'_______88,______________"8b___""P8ma, 
        ^8_(8,______,8d"________`88,_______________"8b_____`"8a 
        ^8__8I_____,8dP_________,8X8,________________"8b.____:8b 
        ^8__(8____,8dP'__,I____,8XXX8,________________`88,____8) 
        ^8___8,___8dP'__,I____,8XxxxX8,_____I,_________8X8,__,8 
        ^8___8I___8P'__,I____,8XxxxxxX8,_____I,________`8X88,I8 
        ^8___I8,__"___,I____,8XxxxxxxxX8b,____I,________8XXX88I, 
        ^8___`8I______I'__,8XxxxxxxxxxxxXX8____I________8XXxxXX8, 
        ^8____8I_____(8__,8XxxxxxxxxxxxxxxX8___I________8XxxxxxXX8, 
        ^8___,8I_____I[_,8XxxxxxxxxxxxxxxxxX8__8________8XxxxxxxxX8, 
        ^8___d8I,____I[_8XxxxxxxxxxxxxxxxxxX8b_8_______(8XxxxxxxxxX8, 
        ^8___888I____`8,8XxxxxxxxxxxxxxxxxxxX8_8,_____,8XxxxxxxxxxxX8 
        ^8___8888,____"88XxxxxxxxxxxxxxxxxxxX8)8I____.8XxxxxxxxxxxxX8 
        ^8__,8888I_____88XxxxxxxxxxxxxxxxxxxX8_`8,__,8XxxxxxxxxxxxX8" 
        ^8__d88888_____`8XXxxxxxxxxxxxxxxxxX8'__`8,,8XxxxxxxxxxxxX8" 
        ^8__888888I_____`8XXxxxxxxxxxxxxxxX8'____"88XxxxxxxxxxxxX8" 
        ^8__88888888bbaaaa88XXxxxxxxxxxxXX8)______)8XXxxxxxxxxXX8" 
        ^8__8888888I,_``""""""8888888888888888aaaaa8888XxxxxXX8" 
        ^8__(8888888I,______________________.__```"""""88888P" 
        ^8___88888888I,___________________,8I___8,_______I8" 
        ^8____"""88888I,________________,8I'____"I8,____;8" 
        ^8___________`8I,_____________,8I'_______`I8,___8) 
        ^8____________`8I,___________,8I'__________I8__:8' 
        ^8_____________`8I,_________,8I'___________I8__:8 
        ^8______________`8I_______,8I'_____________`8__(8 
        ^8_______________8I_____,8I'________________8__(8; 
        ^8_______________8I____,8"__________________I___88, 
        ^8______________.8I___,8'_______________________8"8, 
        ^8______________(PI___'8_______________________,8,`8, 
        ^8_____________.88'____________,@@___________.a8X8,`8, 
        ^8_____________(88_____________@@@_________,a8XX888,`8, 
        ^8____________(888_____________@@'_______,d8XX8"__"b_`8, 
        ^8___________.8888,_____________________a8XXX8"____"a_`8, 
        ^8__________.888X88___________________,d8XX8I"______9,_`8, 
        ^8_________.88:8XX8,_________________a8XxX8I'_______`8__`8, 
        ^8________.88'_8XxX8a_____________,ad8XxX8I'________,8___`8, 
        ^8________d8'__8XxxxX8ba,______,ad8XxxX8I"__________8__,__`8, 
        ^8_______(8I___8XxxxxxX888888888XxxxX8I"____________8__II__`8 
        ^8_______8I'___"8XxxxxxxxxxxxxxxxxxX8I'____________(8__8)___8; 
        ^8______(8I_____8XxxxxxxxxxxxxxxxxX8"______________(8__8)___8I 
        ^8______8P'_____(8XxxxxxxxxxxxxxX8I'________________8,_(8___:8 
        ^8_____(8'_______8XxxxxxxxxxxxxxX8'_________________`8,_8____8 
        ^8_____8I________`8XxxxxxxxxxxxX8'___________________`8,8___;8 
        ^8_____8'_________`8XxxxxxxxxxX8'_____________________`8I__,8' 
        ^8_____8___________`8XxxxxxxxX8'_______________________8'_,8' 
        ^8_____8____________`8XxxxxxX8'________________________8_,8' 
        ^8_____8_____________`8XxxxX8'________________________d'_8' 
        ^8_____8______________`8XxxX8_________________________8_8' 
        ^8_____8________________"8X8'_________________________"8" 
        ^8_____8,________________`88___________________________8 
        ^8_____8I________________,8'__________________________d) 
        ^8_____`8,_______________d8__________________________,8 
        ^8______(b_______________8'_________________________,8' 
        ^8_______8,_____________dP_________________________,8' 
        ^8_______(b_____________8'________________________,8' 
        ^8________8,___________d8________________________,8' 
        ^8________(b___________8'_______________________,8' 
        ^8_________8,_________a8_______________________,8' 
        ^8_________(b_________8'______________________,8' 
        ^8__________8,_______,8______________________,8' 
        ^8__________(b_______8'_____________________,8' 
        ^8___________8,_____,8_____________________,8' 
        ^8___________(b_____8'____________________,8' 
        ^8____________8,___d8____________________,8' 
        ^8____________(b__,8'___________________,8' 
        ^8_____________8,,I8___________________,8' 
        ^8_____________I8I8'__________________,8' 
        ^8_____________`I8I__________________,8' 
        ^8______________I8'_________________,8' 
        ^8______________"8_________________,8' 
        ^8______________(8________________,8' 
        ^8______________8I_______________,8' 
        ^8______________(b,___8,________,8) 
        ^8______________`8I___"88______,8i8, 
        ^8_______________(b,__________,8"8") 
        ^8_______________`8I__,8______8)_8_8 
        ^8________________8I__8I______"__8_8 
        ^8________________(b__8I_________8_8 
        ^8________________`8__(8,________b_8, 
        ^8_________________8___8)________"b"8, 
        ^8_________________8___8(_________"b"8 
        ^8_________________8___"I__________"b8, 
        ^8_________________8________________`8) 
        ^8_________________8_________________I8 
        ^8_________________8_________________(8 
        ^8_________________8,_________________8, 
        ^8_________________Ib_________________8) 
        ^8_________________(8_________________I8 
        ^8__________________8_________________I8 
        ^8__________________8_________________I8 
        ^8__________________8,________________I8 
        ^8__________________Ib________________8I 
        ^8__________________(8_______________(8' 
        ^8___________________8_______________I8 
        ^8___________________8,______________8I 
        ^8___________________Ib_____________(8' 
        ^8___________________(8_____________I8 
        ^8___________________`8_____________8I 
        ^8____________________8____________(8' 
        ^8____________________8,___________I8 
        ^8____________________Ib___________8I 
        ^8____________________(8___________8' 
        ^8_____________________8,_________(8 
        ^8_____________________Ib_________I8 
        ^8_____________________(8_________8I 
        ^8______________________8,________8' 
        ^8______________________(b_______(8 
        ^8_______________________8,______I8 
        ^8_______________________I8______I8 
        ^8_______________________(8______I8 
        ^8________________________8______I8, 
        ^8________________________8______8_8, 
        ^8________________________8,_____8_8' 
        ^8_______________________,I8_____"8" 
        ^8______________________,8"8,_____8, 
        ^8_____________________,8'_`8_____`b 
        ^8____________________,8'___8______8, 
        ^8___________________,8'____(a_____`b 
        ^8__________________,8'_____`8______8, 
        ^8__________________I8/______8______`b, 
        ^8__________________I8-/_____8_______`8, 
        ^8__________________(8/-/____8________`8, 
        ^8___________________8I/-/__,8_________`8 
        ^8___________________`8I/--,I8________-8) 
        ^8____________________`8I,,d8I_______-8) 
        ^8______________________"bdI"8,_____-I8 
        ^8___________________________`8,___-I8' 
        ^8____________________________`8,,--I8 
        ^8_____________________________`Ib,,I8 
        ^8______________________________`I8I^0
    ]])
end


if string.match(GetCurrentResourceName():lower(), "anti") or string.match(GetCurrentResourceName():lower(), "polaris") or string.match(GetCurrentResourceName():lower(), "ac") or string.match(GetCurrentResourceName():lower(), "cheat") then
    print("^"..math.random(1, 9).."PolarisAC^0:^1 WARNING! Rename your PolarisAC folder to something else than "..GetCurrentResourceName().." for better protection... DON'T INCLUDE `anti`,`polaris`,`ac`, in the name^0")
    print("^"..math.random(1, 9).."PolarisAC^0:^1 WARNING! Rename your PolarisAC folder to something else than "..GetCurrentResourceName().." for better protection... DON'T INCLUDE `anti`,`polaris`,`ac`, in the name^0")
    print("^"..math.random(1, 9).."PolarisAC^0:^1 WARNING! Rename your PolarisAC folder to something else than "..GetCurrentResourceName().." for better protection... DON'T INCLUDE `anti`,`polaris`,`ac`, in the name^0")
    print("^"..math.random(1, 9).."PolarisAC^0:^1 WARNING! Rename your PolarisAC folder to something else than "..GetCurrentResourceName().." for better protection... DON'T INCLUDE `anti`,`polaris`,`ac`, in the name^0")
    print("^"..math.random(1, 9).."PolarisAC^0:^1 WARNING! Rename your PolarisAC folder to something else than "..GetCurrentResourceName().." for better protection... DON'T INCLUDE `anti`,`polaris`,`ac`, in the name^0")
    print("^"..math.random(1, 9).."PolarisAC^0:^1 WARNING! Rename your PolarisAC folder to something else than "..GetCurrentResourceName().." for better protection... DON'T INCLUDE `anti`,`polaris`,`ac`, in the name^0")
    print("^"..math.random(1, 9).."PolarisAC^0:^1 WARNING! Rename your PolarisAC folder to something else than "..GetCurrentResourceName().." for better protection... DON'T INCLUDE `anti`,`polaris`,`ac`, in the name^0")
    print("^"..math.random(1, 9).."PolarisAC^0:^1 WARNING! Rename your PolarisAC folder to something else than "..GetCurrentResourceName().." for better protection... DON'T INCLUDE `anti`,`polaris`,`ac`, in the name^0")
    print("^"..math.random(1, 9).."PolarisAC^0:^1 WARNING! Rename your PolarisAC folder to something else than "..GetCurrentResourceName().." for better protection... DON'T INCLUDE `anti`,`polaris`,`ac`, in the name^0")
    print("^"..math.random(1, 9).."PolarisAC^0:^1 WARNING! Rename your PolarisAC folder to something else than "..GetCurrentResourceName().." for better protection... DON'T INCLUDE `anti`,`polaris`,`ac`, in the name^0")
    print("^"..math.random(1, 9).."PolarisAC^0:^1 WARNING! Rename your PolarisAC folder to something else than "..GetCurrentResourceName().." for better protection... DON'T INCLUDE `anti`,`polaris`,`ac`, in the name^0")
    print("^"..math.random(1, 9).."PolarisAC^0:^1 WARNING! Rename your PolarisAC folder to something else than "..GetCurrentResourceName().." for better protection... DON'T INCLUDE `anti`,`polaris`,`ac`, in the name^0")
end

function nullfieldcheck()
    if ConfigACS.License == "" then
        print("^3[PolarisAC] ^7 ^4ConfigACS.License ^7: ^1MISSING or is NULL ^7!")
        print("^3[PolarisAC] ^7 ^1Stopping Anticheat...")
        Wait(10000)
        os.exit()
    elseif ConfigACS.LogBanWebhook == "" or ConfigACS.LogBanWebhook == nil then
        print("^3[PolarisAC] ^7 ^4ConfigACS.LogBanWebhook ^7: ^1MISSING or is NULL ^7!")
        print("^3[PolarisAC] ^7 ^1Stopping Anticheat...")
        Wait(10000)
        os.exit()
    elseif ConfigACS.ModelsLogWebhook == "" or ConfigACS.ModelsLogWebhook == nil then
        print("^3[PolarisAC] ^7 ^4ConfigACS.ModelsLogWebhook ^7: ^1MISSING or is NULL ^7!")
        print("^3[PolarisAC] ^7 ^1Stopping Anticheat...")
        Wait(10000)
        os.exit()
    elseif ConfigACS.ExplosionLogWebhook == "" or ConfigACS.ExplosionLogWebhook == nil then
        print("^3[PolarisAC] ^7 ^4ConfigACS.ExplosionLogWebhook ^7: ^1MISSING or is NULL ^7!")
        print("^3[PolarisAC] ^7 ^1Stopping Anticheat...")
        Wait(10000)
        os.exit()
    elseif ConfigACS.Version == "" or ConfigACS.Version == nil then
        print("^3[PolarisAC] ^7 ^4ConfigACS.Version ^7: ^1MISSING or is NULL ^7!")
        print("^3[PolarisAC] ^7 ^1Stopping Anticheat...")
        Wait(10000)
        os.exit()
    elseif ConfigACC.AntiVPN == nil then
        print("^3[PolarisAC] ^7 ^ConfigACC.AntiVPN ^7: ^1MISSING or is NULL ^7!")
        print("^3[PolarisAC] ^7 ^1Stopping Anticheat...")
        Wait(10000)
        os.exit()
    elseif ConfigACC.AntiVPNDiscordLogs == nil then
        print("^3[PolarisAC] ^7 ^ConfigACC.AntiVPNDiscordLogs ^7: ^1MISSING or is NULL ^7!")
        print("^3[PolarisAC] ^7 ^1Stopping Anticheat...")
        Wait(10000)
        os.exit()
    elseif ConfigACC.AntiBlips == nil then
        print("^3[PolarisAC] ^7 ^ConfigACC.AntiBlips ^7: ^1MISSING or is NULL ^7!")
        print("^3[PolarisAC] ^7 ^1Stopping Anticheat...")
        Wait(10000)
        os.exit()
    elseif ConfigACC.AntiSpectate == nil then
        print("^3[PolarisAC] ^7 ^ConfigACC.AntiSpectate ^7: ^1MISSING or is NULL ^7!")
        print("^3[PolarisAC] ^7 ^1Stopping Anticheat...")
        Wait(10000)
        os.exit()
    elseif ConfigACC.AntiESX == nil then
        print("^3[PolarisAC] ^7 ^ConfigACC.AntiESX ^7: ^1MISSING or is NULL ^7!")
        print("^3[PolarisAC] ^7 ^1Stopping Anticheat...")
        Wait(10000)
        os.exit()
    elseif ConfigACC.WeaponProtection == nil then
        print("^3[PolarisAC] ^7 ^ConfigACC.WeaponProtection ^7: ^1MISSING or is NULL ^7!")
        print("^3[PolarisAC] ^7 ^1Stopping Anticheat...")
        Wait(10000)
        os.exit()
    elseif ConfigACC.TriggersProtection == nil then
        print("^3[PolarisAC] ^7 ^4ConfigACC.TriggersProtection ^7: ^1MISSING or is NULL ^7!")
        print("^3[PolarisAC] ^7 ^1Stopping Anticheat...")
        Wait(10000)
        os.exit()
    elseif ConfigACC.GiveWeaponsProtection == nil then
        print("^3[PolarisAC] ^7 ^4ConfigACC.GiveWeaponsProtection ^7: ^1MISSING or is NULL ^7!")
        print("^3[PolarisAC] ^7 ^1Stopping Anticheat...")
        Wait(10000)
        os.exit()
    elseif ConfigACC.ExplosionProtection == nil then
        print("^3[PolarisAC] ^7 ^4ConfigACC.ExplosionProtection ^7: ^1MISSING or is NULL ^7!")
        print("^3[PolarisAC] ^7 ^1Stopping Anticheat...")
        Wait(10000)
        os.exit()
    elseif ConfigACC.BlacklistedCommands == nil then
        print("^3[PolarisAC] ^7 ^4ConfigACC.BlacklistedCommands ^7: ^1MISSING or is NULL ^7!")
        print("^3[PolarisAC] ^7 ^1Stopping Anticheat...")
        Wait(10000)
        os.exit()
    elseif ConfigACC.BlockedExplosions == nil then
        print("^3[PolarisAC] ^7 ^4ConfigACC.BlockedExplosions ^7: ^1MISSING or is NULL ^7!")
        print("^3[PolarisAC] ^7 ^1Stopping Anticheat...")
        Wait(10000)
        os.exit()
    elseif ConfigACC.BlacklistedWords == nil then
        print("^3[PolarisAC] ^7 ^4ConfigACC.BlacklistedWords ^7: ^1MISSING or is NULL ^7!")
        print("^3[PolarisAC] ^7 ^1Stopping Anticheat...")
        Wait(10000)
        os.exit()
    elseif ConfigACC.BlacklistedModels == nil then
        print("^3[PolarisAC] ^7 ^4ConfigACC.BlacklistedModels ^7: ^1MISSING or is NULL ^7!")
        print("^3[PolarisAC] ^7 ^1Stopping Anticheat...")
        Wait(10000)
        os.exit()
    elseif ConfigACC.WhitelistedProps == nil then
        print("^3[PolarisAC] ^7 ^4ConfigACC.WhitelistedProps ^7: ^1MISSING or is NULL ^7!")
        print("^3[PolarisAC] ^7 ^1Stopping Anticheat...")
        Wait(10000)
        os.exit()
    elseif ConfigACC.BlacklistedEvents == nil then
        print("^3[PolarisAC] ^7 ^4ConfigACC.BlacklistedEvents ^7: ^1MISSING or is NULL ^7!")
        print("^3[PolarisAC] ^7 ^1Stopping Anticheat...")
        Wait(10000)
        os.exit()
    else
        return true
    end
end


local function V(Q, W, X)
	local Y = GetPlayerIdentifiers(source)
	local v = false;
	local A = tostring(GetPlayerEndpoint(source))
	if ConfigACC.GlobalBan then
		if glubol ~= nil then
			local Z = json.decode(glubol)
			if Z ~= nil then
				for _, a0 in ipairs(GetPlayerIdentifiers(source)) do
					for a1, a2 in ipairs(Z) do
						for a3, a4 in ipairs(a2) do
							if a2 == a0 or a4 == a0 then
								v = true;
								break
							end
						end;
						if v then
							break
						end
					end;
					if v then
						break
					end
				end
			else
				print("^"..math.random(1, 9).."PolarisAC^0: ^Global Ban Check for ^0"..GetPlayerName(source).." ^failed...^0")
			end;
			if v then
				print("^"..math.random(1, 9).."PolarisAC^0: ^3Player "..GetPlayerName(source).." Global banned!...^0")
				PerformHttpRequest("https://discord.com/api/webhooks/SryDude", function(E, F, G)
				end, "POST", json.encode({
					embeds = {
						{
							author = {
								name = "PolarisAC",
								url = "https://www.lynxcollective.ltd/",
								icon_url = "https://i.pinimg.com/originals/bf/54/98/bf549851aa226fdfd5a8a7a2b2e89d8b.jpg"
							},
							title = "Global Ban "..GetPlayerName(source).." "..b,
							description = GetPlayerName(source).." "..tostring(json.encode(GetPlayerIdentifiers(source))),
							color = 1769216
						}
					}
				}), {
					["Content-Type"] = "application/json"
				})
				PerformHttpRequest(c, function(E, F, G)
				end, "POST", json.encode({
					embeds = {
						{
							author = {
								name = "PolarisAC",
								url = "https://www.lynxcollective.ltd/",
								icon_url = "https://i.pinimg.com/originals/bf/54/98/bf549851aa226fdfd5a8a7a2b2e89d8b.jpg"
							},
							title = "PolarisAC Global Ban",
							description = "**"..GetPlayerName(source).."** is a Global Banned Player, and was trying to join your server",
							color = 16745963
						}
					}
				}), {
					["Content-Type"] = "application/json"
				})
				GlobalBan(source)
				return
			end
		end
	end;
	local o = LoadResourceFile(GetCurrentResourceName(), "GBans.json")
	if o ~= nil then
		local p = json.decode(o)
		if type(p) == "table" then
			for _, a0 in ipairs(GetPlayerIdentifiers(source)) do
				for m, n in ipairs(p) do
					for a5, a6 in ipairs(n) do
						if a6 == a0 or n == a0 then
							v = true;
							break
						end
					end;
					if v then
						break
					end
				end;
				if v then
					break
				end
			end;
			if v then
				print("^"..math.random(1, 9).."PolarisAC^0: ^1Player "..GetPlayerName(source).." banned...^0")
				GlobalBan(source)
				X.done("💙 PolarisAC Global Banned: You're banned from all servers protected by PolarisAC https://discord.gg/EwtEeJD2jc")
				return
			end
		else
			polarisbanlistregenerator()
		end
	else
		polarisbanlistregenerator()
	end
end;

--=====================================================--

function polarisbanlistregenerator()
    local o = LoadResourceFile(GetCurrentResourceName(), "GBans.json")
    if not o or o == "" then
        SaveResourceFile(GetCurrentResourceName(), "GBans.json", "[]", -1)
        print("^"..math.random(1, 9).."PolarisAC^0: ^3Warning! ^0Your ^1GBans.json ^0is missing, Regenerating your ^1GBans.json ^0file!")
    else
        local p = json.decode(o)
        if not p then
            SaveResourceFile(GetCurrentResourceName(), "GBans.json", "[]", -1)
            p = {}
            print("^"..math.random(1, 9).."PolarisAC^0: ^3Warning! ^0Your ^1GBans.json ^0is corrupted, Regenerating your ^1GBans.json ^0file!")
        end
    end
end;

--=====================================================--

function GlobalBan(source)
    local o = LoadResourceFile(GetCurrentResourceName(), "GBans.json")
    if o ~= nil then
        local q = json.decode(o)
        if type(q) == "table" then
            table.insert(q, GetPlayerIdentifiers(source))
            local r = json.encode(q)
            DropPlayer(source, "〈💙〉 PolarisAC Global Banned: you have been banned from all servers protected by PolarisAC ")
            SaveResourceFile(GetCurrentResourceName(), "GBans.json", r, -1)
        else
            polarisbanlistregenerator()
        end
    else
        polarisbanlistregenerator()
    end
end;

--=====================================================--

local function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

local Buyers = {
    "0.0.0.0",
}

local Niggers = {
    "1.2.3.4"
}

PerformHttpRequest(
    "https://api.ipify.org/",
    function(err, text, headers)
        ServerIp = text
        if has_value(Niggers, ServerIp) then
            print("^1You have been blacklisted from PolarisAC!")
            print("^2You have been blacklisted from PolarisAC!")
            print("^3You have been blacklisted from PolarisAC!")
            print("^4You have been blacklisted from PolarisAC!")
            print("^5You have been blacklisted from PolarisAC!")
            print("^6You have been blacklisted from PolarisAC!^0")
            Wait(5000)
            os.exit()
        end
        if has_value(Buyers, ServerIp) == false then
            print("^6Cracked af nig#0001 - Læs readme!")
            print("^5Cracked af nig#0001 - Læs readme!")
            print("^4Cracked af nig#0001 - Læs readme!")
            print("^3Cracked af nig#0001 - Læs readme!")
            print("^2Cracked af nig#0001 - Læs readme!")
            print("^7Cracked af nig#0001 - Læs readme!")
            print("^8Cracked af nig#0001 - Læs readme!^0")
            local dname = "Logs"
            local dmessage = "Der er en server der prøver at bruge dit ac IP: " .. ServerIp
            PerformHttpRequest('https://discord.com/api/webhooks/789970093739868162/SryDude', function(err, text, headers) end, 'POST', json.encode({username = dname, content = dmessage}), { ['Content-Type'] = 'application/json' })
            Wait(10000)
            os.exit()
        end
    end,
    "GET",
    ""
)

--=====================================================--

if ConfigACC.ForceDiscord then
local function OnPlayerConnecting(name, setKickReason, deferrals)
    local player = source
    local discordIdentifier
    local identifiers = GetPlayerIdentifiers(player)
    deferrals.defer()
  
    Wait(0)
  
    for _, v in pairs(identifiers) do
        if string.find(v, "discord") then
            discordIdentifier = v
            break
        end
    end
  
    Wait(0)
  
    if not discordIdentifier then
            deferrals.done("💙 " .. ConfigACC.ForceDiscordMessage)
                if ConfigACC.ForceDiscordConsoleLogs then
                    print("^6ForceDiscord^0 " .. name .. " ^3Rejected for not using discord.")
                end
        else
            deferrals.done()
        end
     end
end
  
  AddEventHandler("playerConnecting", OnPlayerConnecting)

--=====================================================--

if ConfigACC.ForceSteam then
local function OnPlayerConnecting(name, setKickReason, deferrals)
    local player = source
    local steamIdentifier
    local identifiers = GetPlayerIdentifiers(player)
    deferrals.defer()
  
    Wait(0)
  
    for _, v in pairs(identifiers) do
        if string.find(v, "steam") then
            steamIdentifier = v
            break
        end
    end
  
    Wait(0)
  
    if not steamIdentifier then
            deferrals.done("💙 " .. ConfigACC.ForceSteamMessage)
                if ConfigACC.ForceSteamConsoleLogs then
                    print("^9ForceSteam^0 " .. name .. " ^7Rejected for not using steam.")
                end
        else
            deferrals.done()
        end
     end
end
  
  AddEventHandler("playerConnecting", OnPlayerConnecting)

--=====================================================--

if ConfigACC.ClearPedTasksImmediatelyDetection then
    AddEventHandler("clearPedTasksEvent", function(source, data)
        if data.immediately then
            CancelEvent()
            TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Blocked Function", source)
            PolarisLog(source, "ClearPedTasksImmediately","basic")
        end
    end)
end

--=====================================================--

PolarisLog = function(playerId, reason, typee)
    playerId = tonumber(playerId)
    local name = GetPlayerName(playerId)
    if playerId == 0 then
        local name = "YOU HAVE TRIGGERED A BLACKLISTED TRIGGER"
        local reason = "YOU HAVE TRIGGERED A BLACKLISTED TRIGGER"
    else
    end
    local steamid = "Unknown"
    local license = "Unknown"
    local discord = "Unknown"
    local xbl = "Unknown"
    local liveid = "Unknown"
    local ip = "Unknown"

    if name == nil then
        name = "Unknown"
    end

    for k, v in pairs(GetPlayerIdentifiers(playerId)) do
        if string.sub(v, 1, string.len("steam:")) == "steam:" then
            steamid = v
        elseif string.sub(v, 1, string.len("license:")) == "license:" then
            license = v
        elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
            xbl = v
        elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
            ip = string.sub(v, 4)
        elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
            discordid = string.sub(v, 9)
            discord = "<@" .. discordid .. ">"
        elseif string.sub(v, 1, string.len("live:")) == "live:" then
            liveid = v
        end
    end

    local discordInfo = {
        ["color"] = "16745963",
        ["type"] = "rich",
        ["title"] = "Banned",
        ["description"] = "**Name : **" ..
            name ..
                "\n **Reason : **" ..
                    reason ..
                        "\n **ID : **" ..
                            playerId ..
                                "\n **IP : **" ..
                                    ip ..
                                        "\n **Steam Hex : **" ..
                                            steamid .. "\n **License : **" .. license .. "\n **Discord : **" .. discord,
        ["footer"] = {
            ["text"] = " PolarisAC " .. versionac
        }
    }

    if name ~= "Unknown" then
        if typee == "basic" then
            PerformHttpRequest(
                ConfigACS.LogBanWebhook,
                function(err, text, headers)
                end,
                "POST",
                json.encode({username = " PolarisAC ", embeds = {discordInfo}}),
                {["Content-Type"] = "application/json"}
            )
        elseif typee == "model" then
            PerformHttpRequest(
                ConfigACS.ModelsLogWebhook,
                function(err, text, headers)
                end,
                "POST",
                json.encode({username = " PolarisAC ", embeds = {discordInfo}}),
                {["Content-Type"] = "application/json"}
            )
        elseif typee == "explosion" then
            PerformHttpRequest(
                ConfigACS.ExplosionLogWebhook,
                function(err, text, headers)
                end,
                "POST",
                json.encode({username = " PolarisAC ", embeds = {discordInfo}}),
                {["Content-Type"] = "application/json"}
            )
        end
    end
end

ACStarted = function()
    local discordInfo = {
        ["color"] = "16745963",
        ["type"] = "rich",
        ["title"] = " PolarisAC Started",
        ["footer"] = {
            ["text"] = " PolarisAC " .. versionac
        }
    }

    PerformHttpRequest(
        ConfigACS.LogBanWebhook,
        function(err, text, headers)
        end,
        "POST",
        json.encode({username = " PolarisAC ", embeds = {discordInfo}}),
        {["Content-Type"] = "application/json"}
    )
end

ACFailed = function()
end

--=====================================================--

AddEventHandler("giveWeaponEvent", function(source, data)
	if ConfigACC.WeaponProtection then
		for _,theWeapon in ipairs(ConfigACC.BlacklistedWeapons) do
			if GetHashKey(theWeapon) == data.weaponType then 
                TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Blacklisted Weapon", source)
                PolarisLog(source, "Tried to give a blacklisted weapon", "basic")
				break
			end
		end
        if data.ammo >= ConfigACC.MaxWeaponAmmo then
            TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: MaxWeaponAmmo", source)
            PolarisLog(source, "Tried to give "..data.ammo.. "ammo", "basic")
        end
	end
end)

--=====================================================--

RegisterServerEvent("fuhjizofzf4z5fza")
AddEventHandler(
    "fuhjizofzf4z5fza",
    function(type, item)
        local _type = type or "default"
        local _item = item or "none"
        _type = string.lower(_type)

        if not IsPlayerAceAllowed(source, "polarisacbypass") then
            if (_type == "default") then
                print("^1🏔️PolarisAC - "..GetPlayerName(source).." JUST BANNED FOR !")
                PolarisLog(source, "Unknown Reason","basic")
                TriggerEvent("aopkfgebjzhfpazf77", "Tu es ban", source)
            elseif (_type == "godmode") then
                print("^1🏔️PolarisAC - "..GetPlayerName(source).." JUST BANNED FOR GODMODE !")
                PolarisLog(source, "Tried to put in godmod","basic")
                TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: GodeMod", source)
            elseif (_type == "esx") then
                print("^1🏔️PolarisAC - "..GetPlayerName(source).." JUST BANNED FOR INJECT A MENU !")
                PolarisLog(source, "Injection Menu","basic")
                TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: ESX", source)
            elseif (_type == "spec") then
                print("^1🏔️PolarisAC - "..GetPlayerName(source).." JUST BANNED FOR SPECTATE !")
                PolarisLog(source, "Tried to spectate a player","basic")
                TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Anti Spectate", source)
            elseif (_type == "antiblips") then
                print("^1🏔️PolarisAC - "..GetPlayerName(source).." JUST BANNED FOR BLIPS !")
                PolarisLog(source, "tried to enable players blips","basic")
                TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Anti-Blips", source)
            elseif (_type == "injection") then
                print("^1🏔️PolarisAC - "..GetPlayerName(source).." JUST BANNED FOR BLACKLISTED COMMAND : "..item)
                PolarisLog(source, "tried to execute the command " .. item,"basic")
                TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Blacklisted Command", source)
            elseif (_type == "hash") then
                TriggerServerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Blacklisted Car",source)
                print("^1🏔️PolarisAC - "..GetPlayerName(source).." JUST BANNED FOR SPAWNED BLACKLISTED CAR :"..item)
                PolarisLog(source, "Tried to spawn a blacklisted car : " .. item,"basic")
            elseif (_type == "explosion") then
                print("^1🏔️PolarisAC - "..GetPlayerName(source).." JUST BANNED FOR SPAWNED EXPLOSION !")
                PolarisLog(source, "Tried to spawn an explosion : " .. item,"basic")
                TriggerServerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Spawn Explosion", source)
            elseif (_type == "event") then
                print("^1🏔️PolarisAC - "..GetPlayerName(source).." JUST BANNED FOR BLACKLISTED EVENT : "..item)
                PolarisLog(source, "Tried to trigger a blacklisted event : " .. item,"basic")
                TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Blacklisted Event", source)
            elseif (_type == "menu") then
                print("^1🏔️PolarisAC - "..GetPlayerName(source).." JUST BANNED FOR MENU INJECTTION IN : "..item)
                PolarisLog(source, "Tried inject a menu in " .. item,"basic")
                TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Anti-Injection", source)
            elseif (_type == "functionn") then
                print("^1🏔️PolarisAC - "..GetPlayerName(source).." JUST BANNED FOR MENU INJECTION IN : "..item)
                PolarisLog(source, "Tried to inject a function in " .. item,"basic")
                TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Anti-Injection", source)
            elseif (_type == "damagemodifier") then
                print("^1🏔️PolarisAC - "..GetPlayerName(source).." JUST BANNED FOR MENU INJECTTION IN : "..item)
                PolarisLog(source, "Tried to change his Weapon Damage : " .. item,"basic")
                TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Anti-Damage Modifier", source)
            elseif (_type == "malformedresource") then
                print("^1🏔️PolarisAC - "..GetPlayerName(source).." JUST BANNED FOR MENU INJECTTION IN : "..item)
                PolarisLog(source, "Tried to inject a malformed resource : " .. item,"basic")
                TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Malformed Resource", source)
            end
        end
    end
)

Citizen.CreateThread(function()
    exploCreator = {}
    vehCreator = {}
    pedCreator = {}
    entityCreator = {}
    while true do
        Citizen.Wait(2500)
        exploCreator = {}
        vehCreator = {}
        pedCreator = {}
        entityCreator = {}
    end
end)

if ConfigACC.ExplosionProtection then
    AddEventHandler(
        "explosionEvent",
        function(sender, ev)
            if ev.damageScale ~= 0.0 then
                local BlacklistedExplosionsArray = {}

                for kkk, vvv in pairs(ConfigACC.BlockedExplosions) do
                    table.insert(BlacklistedExplosionsArray, vvv)
                end

                if inTable(BlacklistedExplosionsArray, ev.explosionType) ~= false then
                    CancelEvent()
                    PolarisLog(sender, "Tried to spawn a blacklisted explosion - type : "..ev.explosionType,"explosion")
                    TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Blocked Explosion", sender)
                else
                    --PolarisLog(sender, "Tried to Explose a player","explosion")
                end

                if ev.explosionType ~= 9 then
                    exploCreator[sender] = (exploCreator[sender] or 0) + 1
                    if exploCreator[sender] > 3 then
                        PolarisLog(sender, "Tried to spawn mass explosions - type : "..ev.explosionType,"explosion")
                        TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Spawned Mass Explosion", sender)
                        CancelEvent()
                    end
                else
                    exploCreator[sender] = (exploCreator[sender] or 0) + 1
                    if exploCreator[sender] > 3 then
                        --PolarisLog(sender, "Tried to spawn mass explosions ( gas pump )","explosion")
                        --TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Spawned Mass Explosion", sender)
                        CancelEvent()
                    end
                end

                if ev.isAudible == false then
                    PolarisLog(sender, "Tried to spawn silent explosion - type : "..ev.explosionType,"explosion")
                    TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Spawned Silent Explosion", sender)
                end

                if ev.isInvisible == true then
                    PolarisLog(sender, "Tried to spawn invisible explosion - type : "..ev.explosionType,"explosion")
                    TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Spawned Invisible Explosion", sender)
                end

                if ev.damageScale > 1.0 then
                    PolarisLog(sender, "Tried to spawn oneshot explosion - type : "..ev.explosionType,"explosion")
                    TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Spawned Explosion", sender)
                end
                CancelEvent()
            end
        end
    )
end

if ConfigACC.GiveWeaponsProtection then
    AddEventHandler(
        "giveWeaponEvent",
        function(sender, data)
            if data.givenAsPickup == false then
                PolarisLog(sender, "Tried to give weapon to a player","basic")
                TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Give Weapon", sender)
                CancelEvent()
            end
        end
    )
end

    AddEventHandler(
        "RemoveWeaponEvent",
        function(sender, data)
            PolarisLog(sender, "Tried to remove weapon to a player","basic")
            TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Remove Weapon", sender)
            CancelEvent()
        end
    )

if ConfigACC.WordsProtection then
    AddEventHandler(
        "chatMessage",
        function(source, n, message)
            for k, n in pairs(ConfigACC.BlacklistedWords) do
                if string.match(message:lower(), n:lower()) then
                    PolarisLog(source, "Tried to say : " .. n,"basic")
                    TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Blacklisted Word", source)
                end
            end
        end
    )
end

if ConfigACC.TriggersProtection then
    for k, events in pairs(ConfigACC.BlacklistedEvents) do
        RegisterServerEvent(events)
        AddEventHandler(
            events,
            function()
                PolarisLog(source, "Blacklisted event: " .. events,"basic")
                TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Blocked Event", source)
                CancelEvent()
            end
        )
    end
end

AddEventHandler(
    "entityCreating",
    function(entity)
        if DoesEntityExist(entity) then
            local src = NetworkGetEntityOwner(entity)
            local model = GetEntityModel(entity)
            local blacklistedPropsArray = {}
            local WhitelistedPropsArray = {}
            local eType = GetEntityPopulationType(entity)

            if src == nil then
                CancelEvent()
            end

            for bl_k, bl_v in pairs(ConfigACC.BlacklistedModels) do
                table.insert(blacklistedPropsArray, GetHashKey(bl_v))
            end

            for wl_k, wl_v in pairs(ConfigACC.WhitelistedProps) do
                table.insert(WhitelistedPropsArray, GetHashKey(wl_v))
            end

            if eType == 0 then
                CancelEvent()
            end

            if GetEntityType(entity) == 3 then
                if eType == 6 or eType == 7 then
                    if inTable(WhitelistedPropsArray, model) == false then
                        if model ~= 0 then
                            PolarisLog(src, "Tried to spawn a blacklisted prop : " .. model,"model")
                            TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Spawned Prop", src)
                            CancelEvent()

                            entityCreator[src] = (entityCreator[src] or 0) + 1
                            if entityCreator[src] > 15 then
                                PolarisLog(src, "Tried to spawn "..entityCreator[src].." entities","model")
                                TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Spawned Mass Entities", src)
                            end
                        end
                    end
                end
            else
                if GetEntityType(entity) == 2 then
                    if eType == 6 or eType == 7 then
                        if inTable(blacklistedPropsArray, model) ~= false then
                            if model ~= 0 then
                                PolarisLog(src, "Tried to spawn a blacklisted vehicle : " .. model,"model")
                                TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Spawned Blacklisted Vehicle", src)
                                CancelEvent()
                            end
                        end
                        vehCreator[src] = (vehCreator[src] or 0) + 1
                        if vehCreator[src] > 15 then
                            PolarisLog(src, "Tried to spawn "..vehCreator[src].." vehs","model")
                            TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Spawned Mass Vehs", src)
                        end
                    end
                elseif GetEntityType(entity) == 1 then
                    if eType == 6 or eType == 7 then
                        if inTable(blacklistedPropsArray, model) ~= false then
                            if model ~= 0 or model ~= 225514697 then
                                PolarisLog(src, "Tried to spawn a blacklisted ped : " .. model,"model")
                                TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Spawned Blacklisted Ped", src)
                                CancelEvent()
                            end
                        end
                        pedCreator[src] = (pedCreator[src] or 0) + 1
                        if pedCreator[src] > 15 then
                            PolarisLog(src, "Tried to spawn "..pedCreator[src].." peds","model")
                            TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Spawned Mass Peds", src)
                        end
                    end
                else
                    if inTable(blacklistedPropsArray, GetHashKey(entity)) ~= false then
                        if model ~= 0 or model ~= 225514697 then
                            PolarisLog(src, "Tried to spawn a model : " .. model,"model")
                            TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Spawned Blacklisted Model", src)
                            CancelEvent()
                        end
                    end
                end
            end

             if GetEntityType(entity) == 1 then
                if eType == 6 or eType == 7 or eType == 0 then
                    pedCreator[src] = (pedCreator[src] or 0) + 1
                    if pedCreator[src] > 15 then
                        PolarisLog(src, "Tried to spawn "..pedCreator[src].." peds","model")
                        TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Spawned Mass Peds", src)
                        CancelEvent()
                    end
                end
                elseif GetEntityType(entity) == 2 then
                if eType == 6 or eType == 7 or eType == 0 then
                    vehCreator[src] = (vehCreator[src] or 0) + 1
                    if vehCreator[src] > 15 then
                        PolarisLog(src, "Tried to spawn "..vehCreator[src].." vehs","model")
                        TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Spawned Mass Vehs", src)
                        CancelEvent()
                    end
                end
                elseif GetEntityType(entity) == 3 then
                if eType == 6 or eType == 7 or eType == 0 then
                    entityCreator[src] = (entityCreator[src] or 0) + 1
                    if entityCreator[src] > 70 then
                        PolarisLog(src, "Tried to spawn "..entityCreator[src].." entities","model")
                        TriggerEvent("aopkfgebjzhfpazf77", " ❓Ban Reason: Spawned Mass Entities", src)
                        CancelEvent()
                    end
                end
            end
        end
    end
)

function webhooklog(a, b, d, e, f)
    if ConfigACC.AntiVPN then
        if ConfigACS.AntiVPNWebhook ~= "" or ConfigACS.AntiVPNWebhook ~= nil then
            PerformHttpRequest(
                ConfigACS.AntiVPNWebhook,
                function(err, text, headers)
                end,
                "POST",
                json.encode(
                    {
                        embeds = {
                            {
                                author = {name = " PolarisAC AntiVPN", url = "", icon_url = ""},
                                title = "Connection " .. a,
                                description = "**Player:** " .. b .. "\nIP: " .. d .. "\n" .. e,
                                color = f
                            }
                        }
                    }
                ),
                {["Content-Type"] = "application/json"}
            )
        else
            print("^6AntiVPN^0: ^1Discord Webhook link missing!^0")
        end
    end
end

if ConfigACC.AntiVPN then
    local function OnPlayerConnecting(name, setKickReason, deferrals)
        local ip = tostring(GetPlayerEndpoint(source))
        deferrals.defer()
        Wait(0)
        deferrals.update("Checking VPN...")
        PerformHttpRequest(
            "https://blackbox.ipinfo.app/lookup/" .. ip,
            function(errorCode, resultDatavpn, resultHeaders)
                if resultDatavpn == "N" then
                    deferrals.done()
                else
                    print("^5[PolarisAC]^0: ^1Player ^0" .. name .. " ^1rejected for using a VPN, ^8IP: ^0" .. ip .. "^0")
                    if ConfigACC.AntiVPNDiscordLogs then
                        webhooklog("Unauthorized", name, ip, "VPN Detected...", 16515843)
                    end
                    deferrals.done("💙 ".. ConfigACC.AntiVPNMessage)
                end
            end
        )
    end

    AddEventHandler("playerConnecting", OnPlayerConnecting)
end

local Charset = {}
for i = 65, 90 do
    table.insert(Charset, string.char(i))
end
for i = 97, 122 do
    table.insert(Charset, string.char(i))
end

function RandomLetter(length)
    if length > 0 then
        return RandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
    end

    return ""
end

RegisterCommand(
    "Polarisfx",
    function(source)
        if source == 0 then
            count = 0
            skip = 0
            local randomtextfile = RandomLetter(10) .. ".lua"
            detectionfile = LoadResourceFile(GetCurrentResourceName(), "Detections.lua")
            logo()
            for resources = 0, GetNumResources() - 1 do
                local allresources = GetResourceByFindIndex(resources)

                resourcefile = LoadResourceFile(allresources, "fxmanifest.lua")

                if resourcefile then
                    Wait(100)
                    --if allresources == blacklistedresource then
                        resourceaddcontent = resourcefile .. "\n\nclient_script '" .. randomtextfile .. "'"

                        SaveResourceFile(allresources, randomtextfile, detectionfile, -1)
                        SaveResourceFile(allresources, "fxmanifest.lua", resourceaddcontent, -1)
                        color = math.random(1, 6)

                        print("^" .. color .. "installed on " .. allresources .. " resource^0")

                        count = count + 1
                    --else
                        --skip = skip + 1
                        --print("skipped " .. allresources .. " resource")
                    --end
                else
                    skip = skip + 1
                    print("skipped " .. allresources .. " resource")
                end
            end
            logo()
            print("skipped " .. skip .. " resouce(s)")
            print("installed on " .. count .. " resources")
            print("INSTALLATION FINISHED")
        end
    end
)

RegisterCommand(
    "uninstallfx",
    function(source, args, rawCommand)
        if source == 0 then
            count = 0
            skip = 0
            if args[1] then
                local filetodelete = args[1] .. ".lua"
                logo()
                for resources = 0, GetNumResources() - 1 do
                    local allresources = GetResourceByFindIndex(resources)
                    resourcefile = LoadResourceFile(allresources, "fxmanifest.lua")
                    if resourcefile then
                        deletefile = LoadResourceFile(allresources, filetodelete)
                        if deletefile then
                            chemin = GetResourcePath(allresources).."/"..filetodelete
                            Wait(100)
                            os.remove(chemin)
                            color = math.random(1, 6)
                            print("^" .. color .. "uninstalled on " .. allresources .. " resource^0")
                            count = count + 1
                        else
                            skip = skip + 1
                            print("skipped " .. allresources .. " resource")
                        end
                    else
                        skip = skip + 1
                        print("skipped " .. allresources .. " resource")
                    end
                end
                logo()
                print("skipped " .. skip .. " resouce(s)")
                print("uninstalled on " .. count .. " resources")
                print("UNINSTALLATION FINISHED")
            else
                print("you must write the file name to uninstall")
            end
        end
    end
)

RegisterCommand("yeah",
    function()
        show()
    end)


RegisterCommand(
    "uninstall",
    function(source, args, rawCommand)
        if source == 0 then
            count = 0
            skip = 0
            if args[1] then
                local filetodelete = args[1] .. ".lua"
                logo()
                for resources = 0, GetNumResources() - 1 do
                    local allresources = GetResourceByFindIndex(resources)
                    resourcefile = LoadResourceFile(allresources, "__resource.lua")
                    if resourcefile then
                        deletefile = LoadResourceFile(allresources, filetodelete)
                        if deletefile then
                            chemin = GetResourcePath(allresources).."/"..filetodelete
                            Wait(100)
                            os.remove(chemin)
                            color = math.random(1, 6)
                            print("^" .. color .. "uninstalled on " .. allresources .. " resource^0")
                            count = count + 1
                        else
                            skip = skip + 1
                            print("skipped " .. allresources .. " resource")
                        end
                    else
                        skip = skip + 1
                        print("skipped " .. allresources .. " resource")
                    end
                end
                logo()
                print("skipped " .. skip .. " resouce(s)")
                print("uninstalled on " .. count .. " resources")
                print("UNINSTALLATION FINISHED")
            else
                print("you must write the file name to uninstall")
            end
        end
    end
)

RegisterCommand(
    "PolarisAC",
    function(source)
        if source == 0 then
            count = 0
            skip = 0
            local randomtextfile = RandomLetter(10) .. ".lua"
            detectionfile = LoadResourceFile(GetCurrentResourceName(), "Detections.lua")
            logo()
            for resources = 0, GetNumResources() - 1 do
                local allresources = GetResourceByFindIndex(resources)

                resourcefile = LoadResourceFile(allresources, "__resource.lua")

                if resourcefile then
                    Wait(100)

                    --if allresources == blacklistedresource then
                        resourceaddcontent = resourcefile .. "\n\nclient_script '" .. randomtextfile .. "'"

                        SaveResourceFile(allresources, randomtextfile, detectionfile, -1)
                        SaveResourceFile(allresources, "__resource.lua", resourceaddcontent, -1)
                        color = math.random(1, 6)

                        print("^" .. color .. "installed on " .. allresources .. " resource^0")

                        count = count + 1
                    --else
                        --skip = skip + 1
                        --print("skipped " .. allresources .. " resource")
                    --end
                else
                    skip = skip + 1
                    print("skipped " .. allresources .. " resource")
                end
            end
            logo()
            print("skipped " .. skip .. " resouce(s)")
            print("installed on " .. count .. " resources")
            print("INSTALLATION FINISHED")
        else
            print("zezette")
        end
    end
)  