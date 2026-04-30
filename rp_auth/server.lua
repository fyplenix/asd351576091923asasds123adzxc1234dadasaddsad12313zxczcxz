-- İstemciden (Client) gelecek kayıt isteğini dinleyecek event'i oluşturuyoruz
addEvent("auth:kayitTalebi", true)
addEventHandler("auth:kayitTalebi", resourceRoot, function(kullaniciAdi, sifre)
    local oyuncu = client
    local serial = getPlayerSerial(oyuncu)
    
    if not kullaniciAdi or not sifre or kullaniciAdi == "" or sifre == "" then
        if exports.rp_bildirim then exports.rp_bildirim:goster(oyuncu, "error", "Eksik Bilgi", "Lütfen tüm alanları doldurun.") end
        return
    end

    local serialSorgu = exports.mysql:sorgu("SELECT id FROM accounts WHERE serial = ?", serial)
    local serialSonuc = dbPoll(serialSorgu, -1)
    if serialSonuc and #serialSonuc > 0 then
        if exports.rp_bildirim then exports.rp_bildirim:goster(oyuncu, "error", "Kayıt Hatası", "Bu bilgisayar (Serial) üzerinden zaten bir hesap oluşturulmuş!") end
        return
    end

    local sorgu = exports.mysql:sorgu("SELECT id FROM accounts WHERE username = ?", kullaniciAdi)
    local sonuc = dbPoll(sorgu, -1)
    if sonuc and #sonuc > 0 then
        if exports.rp_bildirim then exports.rp_bildirim:goster(oyuncu, "error", "Kullanılıyor", "Bu kullanıcı adı zaten kullanılıyor!") end
        return
    end

    passwordHash(sifre, "bcrypt", {}, function(sifrelenmisSifre)
        local ip = getPlayerIP(oyuncu)
        local kayitEkle = exports.mysql:calistir("INSERT INTO accounts (username, password, serial, ip) VALUES (?, ?, ?, ?)", kullaniciAdi, sifrelenmisSifre, serial, ip)
        if kayitEkle then
            if exports.rp_bildirim then exports.rp_bildirim:goster(oyuncu, "success", "Kayıt Başarılı", "Başarıyla kayıt oldunuz! Şimdi giriş yapabilirsiniz.") end
        else
            if exports.rp_bildirim then exports.rp_bildirim:goster(oyuncu, "error", "Sistem Hatası", "Kayıt sırasında veritabanı hatası oluştu.") end
        end
    end)
end)

addEvent("auth:girisTalebi", true)
addEventHandler("auth:girisTalebi", resourceRoot, function(kullaniciAdi, sifre)
    local oyuncu = client
    if not kullaniciAdi or not sifre or kullaniciAdi == "" or sifre == "" then
        if exports.rp_bildirim then exports.rp_bildirim:goster(oyuncu, "error", "Eksik Bilgi", "Lütfen kullanıcı adı ve şifrenizi girin.") end
        return
    end

    local sorgu = exports.mysql:sorgu("SELECT id, password FROM accounts WHERE username = ?", kullaniciAdi)
    local sonuc = dbPoll(sorgu, -1)
    if sonuc and #sonuc > 0 then
        local dbSifresi = sonuc[1].password
        local hesapID = sonuc[1].id
        passwordVerify(sifre, dbSifresi, function(eslesti)
            if eslesti then
                setElementData(oyuncu, "hesapID", hesapID)
                setElementData(oyuncu, "girisYapti", true)
                setElementData(oyuncu, "accountID", hesapID)
                local karakterSorgu = exports.mysql:sorgu("SELECT * FROM characters WHERE account_id = ?", hesapID)
                local karakterler = dbPoll(karakterSorgu, -1)
                triggerClientEvent(oyuncu, "auth:karakterEkraninaGec", resourceRoot, karakterler)
            else
                if exports.rp_bildirim then exports.rp_bildirim:goster(oyuncu, "error", "Hatalı Şifre", "Hatalı şifre girdiniz!") end
            end
        end)
    else
        if exports.rp_bildirim then exports.rp_bildirim:goster(oyuncu, "error", "Bulunamadı", "Böyle bir hesap bulunamadı!") end
    end
end)

addEvent("auth:veritabaninaKarakterEkle", true)
addEventHandler("auth:veritabaninaKarakterEkle", resourceRoot, function(ad, soyad, skin, yas, boy, kilo, irk)
    local oyuncu = client
    local hesapID = getElementData(oyuncu, "hesapID")
    if not hesapID then return end

    local karakterSorgu = exports.mysql:sorgu("SELECT id FROM characters WHERE account_id = ?", hesapID)
    local karakterSonuc = dbPoll(karakterSorgu, -1)
    if karakterSonuc and #karakterSonuc >= 1 then
        if exports.rp_bildirim then exports.rp_bildirim:goster(oyuncu, "error", "Sınır Aşıldı", "Hesabınızda zaten bir karakter mevcut. 2. karakteri oluşturamazsınız!") end
        return
    end

    if not string.match(ad, "^[%ağüşıöçĞÜŞİÖÇ]+$") or not string.match(soyad, "^[%ağüşıöçĞÜŞİÖÇ]+$") then
        if exports.rp_bildirim then exports.rp_bildirim:goster(oyuncu, "error", "Geçersiz İsim", "İsim ve soyisimde özel karakter veya sayı kullanılamaz!") end
        return
    end
    if tonumber(yas) < 18 or tonumber(boy) < 150 or tonumber(kilo) < 45 then
        if exports.rp_bildirim then exports.rp_bildirim:goster(oyuncu, "error", "Standart Dışı", "Karakter standartlarına uymalısınız! (Yaş 18+, Boy 150+, Kilo 45+)") end
        return
    end

    local tamIsim = ad .. "_" .. soyad
    local ekle = exports.mysql:calistir("INSERT INTO characters (account_id, character_name, skin, age, height, weight, race) VALUES (?, ?, ?, ?, ?, ?, ?)", hesapID, tamIsim, skin, yas, boy, kilo, irk)
    
    if ekle then
        if exports.rp_bildirim then exports.rp_bildirim:goster(oyuncu, "success", "Karakter Oluşturuldu", "Karakteriniz oluşturuldu! Lütfen görünümünüzü ayarlayın.") end
        local sonKarakterSorgu = exports.mysql:sorgu("SELECT id FROM characters WHERE account_id = ? ORDER BY id DESC LIMIT 1", hesapID)
        local sonKarakter = dbPoll(sonKarakterSorgu, -1)
        local charID = sonKarakter[1].id

        setElementData(oyuncu, "aktifKarakterID", charID)
        setElementData(oyuncu, "ID", charID) 
        setElementData(oyuncu, "girisYapti", true)
        setElementData(oyuncu, "karakter:yas", yas)
        setElementData(oyuncu, "karakter:boy", boy)
        setElementData(oyuncu, "karakter:kilo", kilo)
        setElementData(oyuncu, "karakter:irk", irk)
        setPlayerName(oyuncu, tamIsim)

        triggerClientEvent(oyuncu, "auth:cefKapat", resourceRoot)
        setElementFrozen(oyuncu, false)
        setElementAlpha(oyuncu, 255)
        spawnPlayer(oyuncu, 1552.5, -1677.3, 16.1, 90, tonumber(skin))
        
        local cinsiyetID = tonumber(skin)
        triggerClientEvent(oyuncu, "HG->CustomopenMenu", oyuncu, oyuncu, cinsiyetID)
    end
end)

addEventHandler("onPlayerQuit", root, function()
    local charID = getElementData(source, "aktifKarakterID")
    if charID then
        local x, y, z = getElementPosition(source)
        local aclik = getElementData(source, "aclik") or 100
        local susuzluk = getElementData(source, "susuzluk") or 100
        local cuzdan = getPlayerMoney(source) 
        exports.mysql:calistir("UPDATE characters SET x=?, y=?, z=?, hunger=?, thirst=?, cash=? WHERE id=?", x, y, z, aclik, susuzluk, cuzdan, charID)
    end
end)

addEvent("auth:karakterYaratmaOdasinaGit", true)
addEventHandler("auth:karakterYaratmaOdasinaGit", resourceRoot, function()
    local oyuncu = client
    spawnPlayer(oyuncu, -153.2, 112.40108, -37.47705, 180, 7, 0, 0)
    setElementAlpha(oyuncu, 255)
    setElementFrozen(oyuncu, true)
    setCameraTarget(oyuncu, oyuncu)
    triggerClientEvent(oyuncu, "HG->CustomopenMenu", oyuncu, oyuncu)
end)

addEvent("auth:karakterleOyunaGir", true)
addEventHandler("auth:karakterleOyunaGir", resourceRoot, function(charID)
    local oyuncu = client
    local hesapID = getElementData(oyuncu, "hesapID")
    if not hesapID then return end

    local sorgu = exports.mysql:sorgu("SELECT * FROM characters WHERE id = ? AND account_id = ?", charID, hesapID)
    local sonuc = dbPoll(sorgu, -1)
    
    if sonuc and #sonuc > 0 then
        local charData = sonuc[1]
        triggerClientEvent(oyuncu, "auth:cefKapat", resourceRoot)
        
        local sX, sY, sZ = charData.x or 1552.5, charData.y or -1677.3, charData.z or 16.1
        local skin = charData.skin or 7
        if sX == 0 and sY == 0 then sX, sY, sZ = 1552.5, -1677.3, 16.1 end

        spawnPlayer(oyuncu, sX, sY, sZ, 0, skin)
        setElementDimension(oyuncu, 0)
        setElementInterior(oyuncu, 0)
        setCameraTarget(oyuncu, oyuncu)
        fadeCamera(oyuncu, true, 1.5) 
        
        setElementFrozen(oyuncu, false)
        setElementAlpha(oyuncu, 255)
        
        setElementData(oyuncu, "aktifKarakterID", charID)
        setElementData(oyuncu, "ID", charID) 
        setPlayerName(oyuncu, charData.character_name)
        setPlayerMoney(oyuncu, charData.cash or 0)
        setElementData(oyuncu, "karakter:yas", charData.age)
        setElementData(oyuncu, "karakter:boy", charData.height)
        setElementData(oyuncu, "karakter:kilo", charData.weight)
        setElementData(oyuncu, "karakter:irk", charData.race)
        setElementData(oyuncu, "aclik", charData.hunger or 100)
        setElementData(oyuncu, "susuzluk", charData.thirst or 100)
        
        if exports.rp_bildirim then exports.rp_bildirim:goster(oyuncu, "success", "Giriş Başarılı", "İyi roller dileriz!") end
        
        -- DİKKAT: HORIZON'A GİDECEK OLAN KÖPRÜ TETİĞİ (Hataya sebep olan kısım buradaydı, düzeltildi)
        setTimer(function()
            triggerEvent("Horizon:KiyafetleriYukle", root, oyuncu)
        end, 1500, 1)
    else
        if exports.rp_bildirim then exports.rp_bildirim:goster(oyuncu, "error", "Hata", "Karakter verisine ulaşılamadı!") end
    end
end)

