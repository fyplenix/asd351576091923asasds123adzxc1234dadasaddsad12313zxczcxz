--client.lua

local cefBrowser, cefRequest
local oyuncuKarakterleri = nil

addEventHandler("onClientResourceStart", resourceRoot, function()
    -- Oyuncu giriş yapana kadar sohbeti ve varsa sağ üstteki hud'u gizle
    showChat(false)
    setElementData(localPlayer, "girisYapti", false)
    
    setCameraMatrix(1535.0, -1670.0, 40.0, 1552.0, -1675.0, 16.0)
    setElementAlpha(localPlayer, 0)
    setElementFrozen(localPlayer, true)

    local eX, eY = guiGetScreenSize()
    cefBrowser = guiCreateBrowser(0, 0, eX, eY, true, true, false)
    cefRequest = guiGetBrowser(cefBrowser)
    
    addEventHandler("onClientBrowserCreated", cefRequest, function()
        loadBrowserURL(source, "http://mta/local/html/login.html")
        showCursor(true)
        
        guiBringToFront(cefBrowser) -- Paneli ekranın en önüne al
        focusBrowser(source) -- KESİN ÇÖZÜM: Tarayıcıya tam odaklan
        guiSetInputEnabled(true) -- MTA'nın tuşları çalmasını engelle
        guiSetInputMode("no_binds") -- Bütün klavye tuşlarını sadece panele ver
    end)
end)

-- JS'den Gelen Login ve Kayıt Olayları
addEvent("cef:girisYap", true)
addEventHandler("cef:girisYap", resourceRoot, function(kAdi, sifre)
    triggerServerEvent("auth:girisTalebi", resourceRoot, kAdi, sifre)
end)

addEvent("cef:kayitOl", true)
addEventHandler("cef:kayitOl", resourceRoot, function(kAdi, sifre)
    triggerServerEvent("auth:kayitTalebi", resourceRoot, kAdi, sifre)
end)

-- Hesap girişi başarılı olunca Karakter Seçim/Oluşturma ekranına geçer
addEvent("auth:karakterEkraninaGec", true)
addEventHandler("auth:karakterEkraninaGec", resourceRoot, function(karakterListesi)
    oyuncuKarakterleri = karakterListesi
    if #oyuncuKarakterleri == 0 then
        -- EĞER HİÇ KARAKTERİ YOKSA:
        -- Eski paneli yüklemek yerine direkt CEF'i kapatıp Horizon'u açıyoruz!
        triggerEvent("auth:cefKapat", resourceRoot)
        triggerEvent("HG->CustomopenMenu", localPlayer, localPlayer)
    else
        -- Karakteri varsa seçim (select.html) ekranına yolla
        loadBrowserURL(cefRequest, "http://mta/local/html/select.html")
    end
end)

addEventHandler("onClientBrowserDocumentReady", root, function(url)
    if source == cefRequest and string.find(url, "select.html") then
        local jsonVeri = toJSON(oyuncuKarakterleri)
        executeBrowserJavascript(source, "loadCharacters(`" .. jsonVeri .. "`)")
    end
end)

addEvent("cef:karakterSecildi", true)
addEventHandler("cef:karakterSecildi", resourceRoot, function(charID)
    triggerServerEvent("auth:karakterleOyunaGir", resourceRoot, charID)
end)

addEvent("cef:yeniKarakterEkrani", true)
addEventHandler("cef:yeniKarakterEkrani", resourceRoot, function()
    -- GÜVENLİK DUVARI: Zaten karakteri varsa işlem iptal.
    if oyuncuKarakterleri and #oyuncuKarakterleri >= 1 then
        if exports.rp_bildirim then exports.rp_bildirim:goster(localPlayer, "error", "Erişim Reddedildi", "Hesabınızda zaten bir karakter mevcut. Yeni karakter oluşturma paneline erişemezsiniz!") end
        return
    end
    
    -- CEF PENCERESİNİ KAPAT
    triggerEvent("auth:cefKapat", resourceRoot) 
    
    -- EKSİK OLAN KISIM BURASI: Sunucuya bizi odaya doğurmasını söylüyoruz!
    triggerServerEvent("auth:karakterYaratmaOdasinaGit", resourceRoot)
end)

addEvent("cef:karakteriKaydet", true)
addEventHandler("cef:karakteriKaydet", resourceRoot, function(ad, soyad, skin, yas, boy, kilo, irk)
    triggerServerEvent("auth:veritabaninaKarakterEkle", resourceRoot, ad, soyad, skin, yas, boy, kilo, irk)
end)

addEvent("auth:cefKapat", true)
addEventHandler("auth:cefKapat", resourceRoot, function()
    if isElement(cefBrowser) then
        destroyElement(cefBrowser)
        showCursor(false)
        
        guiSetInputEnabled(false) 
        guiSetInputMode("allow_binds") 
        
        -- Görünmezliği kaldır
        setElementAlpha(localPlayer, 255)
        
        -- GTA Varsayılan HUD ve Radar gizleme (KESİN ÇÖZÜM)
        setPlayerHudComponentVisible("all", false)
        setPlayerHudComponentVisible("crosshair", true)
        
        -- Oyuna girince sohbeti geri aç!
        showChat(true)
        
        -- MUHTEŞEM ÇÖZÜM: Ekran kapandıktan 1.5 saniye sonra Client üzerinden 
        -- direkt HorizonGroup'a "Kıyafetlerimi Yükle" emrini yolluyoruz!
        setTimer(function()
            triggerServerEvent("HG->resetClothes", localPlayer, localPlayer)
        end, 1500, 1)
    end
end)