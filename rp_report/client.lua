local screenW, screenH = guiGetScreenSize()
local reportBrowser = nil
local isBrowserVisible = false

addEventHandler("onClientResourceStart", resourceRoot, function()
    bindKey("F2", "down", toggleReportPanel)
end)

function toggleReportPanel()
    if not isElement(reportBrowser) then
        reportBrowser = guiCreateBrowser(0, 0, screenW, screenH, true, true, false)
        if not reportBrowser then return end

        local theBrowser = guiGetBrowser(reportBrowser)
        addEventHandler("onClientBrowserCreated", theBrowser, function()
            loadBrowserURL(source, "http://mta/local/html/index.html")
            isBrowserVisible = true
            showCursor(true)
            guiSetInputMode("no_binds")
            
            -- [YENİ] Browser yüklendiğinde Admin mi diye sunucuya sorar
            addEventHandler("onClientBrowserDocumentReady", source, function()
                triggerServerEvent("Server:CheckAdminStatus", localPlayer)
            end)
        end)
    else
        isBrowserVisible = not isBrowserVisible
        guiSetVisible(reportBrowser, isBrowserVisible)
        showCursor(isBrowserVisible)
        
        if isBrowserVisible then
            guiSetInputMode("no_binds")
        else
            guiSetInputMode("allow_binds")
        end
    end
end

addEvent("report:close", true)
addEventHandler("report:close", root, function()
    if isElement(reportBrowser) then
        isBrowserVisible = false
        guiSetVisible(reportBrowser, false)
        showCursor(false)
        guiSetInputMode("allow_binds")
    end
end)

-- [YENİ] Admin sekmesini açıp kapatan fonksiyon
addEvent("Client:SetAdminStatus", true)
addEventHandler("Client:SetAdminStatus", root, function(isAdmin)
    if isElement(reportBrowser) then
        executeBrowserJavascript(guiGetBrowser(reportBrowser), string.format("setAdminStatus(%s)", tostring(isAdmin)))
    end
end)

addEvent("report:submit", true)
addEventHandler("report:submit", root, function(jsonData)
    triggerServerEvent("Server:ReportSubmit", localPlayer, jsonData)
end)

addEvent("report:requestList", true)
addEventHandler("report:requestList", root, function(listType)
    triggerServerEvent("Server:ReportRequestList", localPlayer, listType or "my")
end)

addEvent("Client:ReceiveReportList", true)
addEventHandler("Client:ReceiveReportList", root, function(jsonData, isAdmin, listType)
    if isElement(reportBrowser) then
        local b64 = base64Encode(jsonData)
        local myName = getPlayerName(localPlayer):gsub("_", " ")
        local js = string.format("loadReportList('%s', %s, '%s', '%s')", b64, tostring(isAdmin), myName, tostring(listType))
        executeBrowserJavascript(guiGetBrowser(reportBrowser), js)
    end
end)

addEvent("report:requestChat", true)
addEventHandler("report:requestChat", root, function(reportId)
    triggerServerEvent("Server:ReportRequestChat", localPlayer, reportId)
end)

addEvent("Client:ReceiveReportChat", true)
addEventHandler("Client:ReceiveReportChat", root, function(jsonData)
    if isElement(reportBrowser) then
        local b64 = base64Encode(jsonData)
        local js = string.format("loadChatMessages('%s')", b64)
        executeBrowserJavascript(guiGetBrowser(reportBrowser), js)
    end
end)

addEvent("Client:SyncReportChat", true)
addEventHandler("Client:SyncReportChat", root, function(reportId, jsonData)
    if isElement(reportBrowser) then
        local b64 = base64Encode(jsonData)
        local js = string.format("syncChatIfActive(%d, '%s')", reportId, b64)
        executeBrowserJavascript(guiGetBrowser(reportBrowser), js)
    end
end)

addEvent("Client:ReportClaimed", true)
addEventHandler("Client:ReportClaimed", root, function(reportId, adminName)
    if isElement(reportBrowser) then
        local js = string.format("updateClaimUI(%d, '%s')", reportId, adminName)
        executeBrowserJavascript(guiGetBrowser(reportBrowser), js)
    end
end)

addEvent("report:sendMsg", true)
addEventHandler("report:sendMsg", root, function(reportId, message)
    triggerServerEvent("Server:ReportSendMsg", localPlayer, reportId, message)
end)

addEvent("report:updateStatus", true)
addEventHandler("report:updateStatus", root, function(reportId, newStatus)
    triggerServerEvent("Server:ReportUpdateStatus", localPlayer, reportId, newStatus)
end)

addEvent("report:claim", true)
addEventHandler("report:claim", root, function(reportId)
    triggerServerEvent("Server:ReportClaim", localPlayer, reportId)
end)

addEvent("report:requestOnlineAdmins", true)
addEventHandler("report:requestOnlineAdmins", root, function()
    triggerServerEvent("Server:RequestOnlineAdmins", localPlayer)
end)

addEvent("Client:ReceiveOnlineAdmins", true)
addEventHandler("Client:ReceiveOnlineAdmins", root, function(jsonData)
    if isElement(reportBrowser) then
        local b64 = base64Encode(jsonData)
        local js = string.format("loadOnlineAdmins('%s')", b64)
        executeBrowserJavascript(guiGetBrowser(reportBrowser), js)
    end
end)

addEvent("report:transfer", true)
addEventHandler("report:transfer", root, function(reportId, targetAdmin)
    triggerServerEvent("Server:ReportTransfer", localPlayer, reportId, targetAdmin)
end)