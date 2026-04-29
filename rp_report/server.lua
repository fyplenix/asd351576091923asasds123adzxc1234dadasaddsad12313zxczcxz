-- [[ RAPOR SİSTEMİ - SERVER SİDE ]] --

function isPlayerAdmin(player)
    if not isElement(player) then return false end
    local level = tonumber(getElementData(player, "admin_level")) or 0
    return (level >= 1)
end

function notifyAdmins(message)
    for _, p in ipairs(getElementsByType("player")) do
        if isPlayerAdmin(p) then
            outputChatBox("[RAPOR] " .. message, p, 217, 83, 79, true)
        end
    end
end

-- [YENİ] Panel ilk açıldığında Admin durumunu sorgular
addEvent("Server:CheckAdminStatus", true)
addEventHandler("Server:CheckAdminStatus", root, function()
    local p = client
    triggerClientEvent(p, "Client:SetAdminStatus", p, isPlayerAdmin(p))
end)

addEvent("Server:ReportSubmit", true)
addEventHandler("Server:ReportSubmit", root, function(jsonData)
    local p = client
    local accId = getElementData(p, "account_id") or getElementData(p, "dbid") or getElementData(p, "id") or 0
    local pName = getPlayerName(p):gsub("_", " ")
    
    local data = fromJSON(jsonData)
    if not data or not data.desc then return end
    
    exports.mysql:calistir("INSERT INTO reports (account_id, player_name, type, category, priority, description, status) VALUES (?, ?, ?, ?, ?, ?, ?)", 
        accId, pName, data.type, data.category, data.priority, data.desc, "Açık")
        
    outputChatBox("[!] Talebiniz başarıyla iletildi. Yetkililer en kısa sürede yanıt verecektir.", p, 92, 184, 92, true)
    notifyAdmins("YENİ TALEP GELDİ! Gönderen: " .. pName .. " | Kategori: " .. data.category)
end)

-- [GÜNCELLEME] listType parametresi eklendi (my = taleplerim, all = gelen raporlar)
addEvent("Server:ReportRequestList", true)
addEventHandler("Server:ReportRequestList", root, function(listType)
    local p = client
    local adminStatus = isPlayerAdmin(p)
    local accId = getElementData(p, "account_id") or getElementData(p, "dbid") or getElementData(p, "id") or 0
    
    local qh
    if listType == "all" and adminStatus then
        -- ADMİN: Gelen Raporlar
        qh = exports.mysql:sorgu("SELECT * FROM reports ORDER BY CASE WHEN status='Açık' THEN 1 WHEN status='İşleniyor' THEN 2 ELSE 3 END, id DESC LIMIT 50")
    else
        -- OYUNCU (veya adminin kendi raporları)
        qh = exports.mysql:sorgu("SELECT * FROM reports WHERE account_id = ? ORDER BY id DESC", accId)
    end
    
    if qh then
        local results = dbPoll(qh, -1) or {}
        triggerClientEvent(p, "Client:ReceiveReportList", p, toJSON(results), adminStatus, listType or "my")
    end
end)

local function broadcastChatUpdate(reportId)
    local qh = exports.mysql:sorgu("SELECT * FROM report_messages WHERE report_id = ? ORDER BY id ASC", reportId)
    if qh then
        local results = dbPoll(qh, -1) or {}
        for i, row in ipairs(results) do
            row.time = row.created_at
        end
        triggerClientEvent(root, "Client:SyncReportChat", root, reportId, toJSON(results))
    end
end

local function sendChatToPlayer(player, reportId)
    local qh = exports.mysql:sorgu("SELECT * FROM report_messages WHERE report_id = ? ORDER BY id ASC", reportId)
    if qh then
        local results = dbPoll(qh, -1) or {}
        for i, row in ipairs(results) do
            row.time = row.created_at
        end
        triggerClientEvent(player, "Client:ReceiveReportChat", player, toJSON(results))
    end
end

addEvent("Server:ReportRequestChat", true)
addEventHandler("Server:ReportRequestChat", root, function(reportId)
    sendChatToPlayer(client, reportId)
end)

addEvent("Server:ReportSendMsg", true)
addEventHandler("Server:ReportSendMsg", root, function(reportId, message)
    local p = client
    local pName = getPlayerName(p):gsub("_", " ")
    local adminStatus = isPlayerAdmin(p) and 1 or 0
    
    exports.mysql:calistir("INSERT INTO report_messages (report_id, sender_name, is_admin, message) VALUES (?, ?, ?, ?)", 
        reportId, pName, adminStatus, message)
    
    broadcastChatUpdate(reportId)
end)

addEvent("Server:ReportUpdateStatus", true)
addEventHandler("Server:ReportUpdateStatus", root, function(reportId, newStatus)
    local p = client
    exports.mysql:calistir("UPDATE reports SET status = ? WHERE id = ?", newStatus, reportId)
    
    local msg = "[!] Talebin durumu güncellendi: " .. newStatus
    if newStatus == "İptal Edildi" then
        msg = "[!] Talebinizi başarıyla iptal ettiniz."
    end
    outputChatBox(msg, p, 240, 173, 78, true)
    triggerEvent("Server:ReportRequestList", p, "my") -- Herkes kendi ekranını sessizce yenilesin diye
end)

addEvent("Server:ReportClaim", true)
addEventHandler("Server:ReportClaim", root, function(reportId)
    local p = client
    if not isPlayerAdmin(p) then return end
    local pName = getPlayerName(p):gsub("_", " ")
    
    exports.mysql:calistir("UPDATE reports SET status = 'İşleniyor', claimed_by = ? WHERE id = ?", pName, reportId)
    exports.mysql:calistir("INSERT INTO report_messages (report_id, sender_name, is_admin, message) VALUES (?, ?, ?, ?)", 
        reportId, "SİSTEM", 1, pName .. " bu talebi üstlendi ve sizinle ilgileniyor.")
        
    outputChatBox("[!] Talebi başarıyla üstlendiniz.", p, 0, 255, 0)
    broadcastChatUpdate(reportId)
    triggerClientEvent(root, "Client:ReportClaimed", root, reportId, pName)
end)

addEvent("Server:RequestOnlineAdmins", true)
addEventHandler("Server:RequestOnlineAdmins", root, function()
    local p = client
    if not isPlayerAdmin(p) then return end
    
    local admins = {}
    for _, player in ipairs(getElementsByType("player")) do
        if isPlayerAdmin(player) then
            table.insert(admins, getPlayerName(player):gsub("_", " "))
        end
    end
    triggerClientEvent(p, "Client:ReceiveOnlineAdmins", p, toJSON(admins))
end)

addEvent("Server:ReportTransfer", true)
addEventHandler("Server:ReportTransfer", root, function(reportId, targetAdminName)
    local p = client
    if not isPlayerAdmin(p) then return end
    
    exports.mysql:calistir("UPDATE reports SET claimed_by = ? WHERE id = ?", targetAdminName, reportId)
    exports.mysql:calistir("INSERT INTO report_messages (report_id, sender_name, is_admin, message) VALUES (?, ?, ?, ?)", 
        reportId, "SİSTEM", 1, "Bu talep yetkili " .. targetAdminName .. " isimli admine devredildi.")
        
    outputChatBox("[!] Talep başarıyla " .. targetAdminName .. " isimli admine devredildi.", p, 240, 173, 78, true)
    broadcastChatUpdate(reportId)
    triggerClientEvent(root, "Client:ReportClaimed", root, reportId, targetAdminName)
end)