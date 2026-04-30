
local r24_0 = {}

r24_0.SecretS = "adasdsad3235236hdfh"
r24_0.SecretSite = "5465@@)(#@!$HJDN"
function onResourceStart(r0_34)
  -- line: [389, 556] id: 34
  if r0_34 ~= getThisResource() then
    return 
  end
 	setTimer(function()
 	  loadAllClothes()
 	end, 3000, 1)
 if config.Global.triggerOnJoin == true then
   setTimer(function()
     for r3_38, r4_38 in ipairs(getElementsByType("player")) do
       setElementData(r4_38, "HG->shopInUse", false)
       setElementData(r4_38, "HG->inTattoShop", false)
       setElementData(r4_38, "HG->inPoliceShop", false)
       setElementModel(r4_38, getAccountData(getPlayerAccount(r4_38), "HG->MakeCustomGender") or 7)
       if not getAccountData(r5_38, "HG->MakeCustom") then
         triggerClientEvent(r4_38, "HG->CustomopenMenu", r4_38, r4_38)
       end
     end
   end, 2000, 1)
 end                
end
addEventHandler("onResourceStart", getRootElement(), onResourceStart)

addEventHandler("onPlayerLogin", root, function(r0_39, r1_39)
  if config.Global.triggerOnJoin == true and not getAccountData(r1_39, "HG->MakeCustom") then
    triggerClientEvent(source, "HG->CustomopenMenu", source, source)
  end
  setElementModel(source, getAccountData(r1_39, "HG->MakeCustomGender") or 7)
  loadNewClothesForAllPlayers(source)
  loadAllClothesForEnteringPlayer(source)
  loadCorpsClothesForJoiningPlayer(source)
end)
local r27_0 = dbConnect("sqlite", "core/assets/database/custom.db")
if r27_0 then
  dbExec(r27_0, "CREATE TABLE IF NOT EXISTS ply_clothes (id VARCHAR(255), tipo VARCHAR(255), clothes VARCHAR(255), stylo VARCHAR(255))")
  dbExec(r27_0, "CREATE TABLE IF NOT EXISTS rkst_custom_outfit_1 (id VARCHAR(255), tipo VARCHAR(255), clothes VARCHAR(255), stylo VARCHAR(255))")
  dbExec(r27_0, "CREATE TABLE IF NOT EXISTS rkst_custom_outfit_2 (id VARCHAR(255), tipo VARCHAR(255), clothes VARCHAR(255), stylo VARCHAR(255))")
end
local r28_0 = {}
local r29_0 = {
  "tatto_bracoe",
  "tatto_bracod",
  "tatto_pernae1",
  "tatto_pernae2",
  "tatto_pernae3",
  "tatto_pernae4",
  "tatto_pernae5",
  "tatto_pernae6",
  "tatto_pernad1",
  "tatto_pernad2",
  "tatto_pernad3",
  "tatto_pernad4",
  "tatto_pernad5",
  "tatto_pernad6",
  "tatto_ombroe",
  "tatto_ombrod",
  "tatto_costas1",
  "tatto_costas2",
  "tatto_costas3",
  "tatto_corpo1",
  "tatto_corpo2",
  "tatto_corpo3",
  "tatto_corpo4",
  "cabelo",
  "mao",
  "rosto",
  "torso1",
  "torso2",
  "torso3",
  "torso4",
  "bracoe",
  "ombroe",
  "pernae1",
  "pernae2",
  "pernae3",
  "pernae4",
  "pernae5",
  "pernae6",
  "pee",
  "bracod",
  "ombrod",
  "pernad1",
  "pernad2",
  "pernad3",
  "pernad4",
  "pernad5",
  "pernad6",
  "ped",
  "cueca",
  "pe1",
  "pe2"
}
addEvent("HG->changeSkinID", true)
addEventHandler("HG->changeSkinID", root, function(r0_40)
  -- line: [594, 599] id: 40

  if r0_40 then
    setElementModel(source, tonumber(r0_40))
  end
end)
addEvent("HG->confirmCharacterCreation", true)
addEventHandler("HG->confirmCharacterCreation", root, function(oyuncu, r1_41, cinsiyetSkin, ad, soyad, yas)
    if not oyuncu or not isElement(oyuncu) then return end
    
    local hesapID = getElementData(oyuncu, "hesapID") -- Senin Auth sistemindeki hesap ID
    if not hesapID then return end
    
    local tamIsim = ad .. "_" .. soyad
    local boy = 175
    local kilo = 70
    local irk = "Türk"
    
    -- ÖNCE KARAKTERİ SQL'E KAYDET
    local ekle = exports.mysql:calistir("INSERT INTO characters (account_id, character_name, skin, age, height, weight, race) VALUES (?, ?, ?, ?, ?, ?, ?)", hesapID, tamIsim, cinsiyetSkin, yas, boy, kilo, irk)
    
    if ekle then
        -- OLUŞAN YENİ KARAKTERİN SQL ID'SİNİ ÇEK
        local sonKarakterSorgu = exports.mysql:sorgu("SELECT id FROM characters WHERE account_id = ? ORDER BY id DESC LIMIT 1", hesapID)
        local sonKarakter = dbPoll(sonKarakterSorgu, -1)
        local charID = sonKarakter[1].id
        
        setElementData(oyuncu, "aktifKarakterID", charID)
        setElementData(oyuncu, "ID", charID) -- Horizon kıyafetleri bu "ID" ile okur
        
        local hesapData = getPlayerAccount(oyuncu)
        if hesapData and not isGuestAccount(hesapData) then
            setAccountData(hesapData, "HG->MakeCustom", true)
            setAccountData(hesapData, "HG->MakeCustomGender", cinsiyetSkin)
        end
        
        -- HORIZON KIYAFETLERİNİ OYUNCUYA SQL'DE GİYDİR (Orijinal Kod)
        if type(r1_41) == "table" then
            for r8_41, r9_41 in pairs(r1_41) do
                if type(r9_41) == "table" and 1 <= #r9_41 then
                    dbExec(r27_0, "INSERT INTO ply_clothes VALUES(?, ?, ?, ?)", charID, r8_41, r9_41[1], r9_41[2])
                    triggerClientEvent(root, "setPlayerRoupa", root, oyuncu, r8_41, r9_41[1], r9_41[2])
                end
            end
        end
        
        triggerClientEvent(oyuncu, "HG->CustomopenMenu", oyuncu, oyuncu)
        
        -- OYUNCUYU OYUNA DOĞUR (SPAWN)
        setElementFrozen(oyuncu, false)
        setElementAlpha(oyuncu, 255)
        setCameraTarget(oyuncu, oyuncu)
        setPlayerName(oyuncu, tamIsim)
        spawnPlayer(oyuncu, 1552.5, -1677.3, 16.1, 90, tonumber(cinsiyetSkin))
        
        setElementData(oyuncu, "girisYapti", true)
        setElementData(oyuncu, "karakter:yas", yas)
        setElementData(oyuncu, "karakter:boy", boy)
        setElementData(oyuncu, "karakter:kilo", kilo)
        setElementData(oyuncu, "karakter:irk", irk)
        
        if config.confirmCreationCustomEvent then config.confirmCreationCustomEvent(oyuncu) end
        if exports.rp_bildirim then exports.rp_bildirim:goster(oyuncu, "success", "Karakter Oluşturuldu", "Los Santos'a hoş geldiniz!") end
    end
end)
function loadAllClothesForEnteringPlayer(r0_42)
  -- line: [625, 653] id: 42

  setTimer(function()
    -- line: [627, 652] id: 43
    for r3_43, r4_43 in ipairs(getElementsByType("player")) do
      if r4_43 ~= r0_42 and (getElementModel(r4_43) == 7 or getElementModel(r4_43) == 9) then
        local r5_43 = dbPoll(dbQuery(r27_0, "SELECT * FROM ply_clothes WHERE id = ?", tonumber(getElementData(r4_43, config.Global.elementID))), -1)
        if r5_43 and 1 <= #r5_43 then
          local r6_43 = {}
          local r7_43 = {}
          for r11_43, r12_43 in ipairs(r5_43) do
            if table.contains(r29_0, r12_43.tipo) then
              table.insert(r6_43, r12_43)
            else
              table.insert(r7_43, r12_43)
            end
          end
          for r11_43, r12_43 in ipairs(r6_43) do
            triggerClientEvent(r0_42, "setPlayerRoupa", r0_42, r4_43, r12_43.tipo, r12_43.clothes, r12_43.stylo)
          end
          for r11_43, r12_43 in ipairs(r7_43) do
            triggerClientEvent(r0_42, "setPlayerRoupa", r0_42, r4_43, r12_43.tipo, r12_43.clothes, r12_43.stylo)
          end
        end
      end
    end
  end, 3000, 1)
end
function loadNewClothesForAllPlayers(r0_44)
  -- line: [655, 678] id: 44

  setTimer(function()
    -- line: [657, 677] id: 45
    local r0_45 = dbPoll(dbQuery(r27_0, "SELECT * FROM ply_clothes WHERE id = ?", tonumber(getElementData(r0_44, config.Global.elementID))), -1)
    if r0_45 and 1 <= #r0_45 then
      local r1_45 = {}
      local r2_45 = {}
      for r6_45, r7_45 in ipairs(r0_45) do
        if table.contains(r29_0, r7_45.tipo) then
          table.insert(r1_45, r7_45)
        else
          table.insert(r2_45, r7_45)
        end
      end
      for r6_45, r7_45 in ipairs(r1_45) do
        triggerClientEvent(root, "setPlayerRoupa", root, r0_44, r7_45.tipo, r7_45.clothes, r7_45.stylo)
      end
      for r6_45, r7_45 in ipairs(r2_45) do
        triggerClientEvent(root, "setPlayerRoupa", root, r0_44, r7_45.tipo, r7_45.clothes, r7_45.stylo)
      end
    end
  end, 3000, 1)
end
function reloadPlayerClothes(r0_46)
  -- line: [680, 717] id: 46

  if not r0_46 then
    return 
  end
  if not isElement(r0_46) then
    r0_46 = getPlayerByID(tonumber(r0_46))
    if not r0_46 then
      return 
    end
  end
  clearShaderAllClothes(r0_46)
  setElementModel(r0_46, getAccountData(getPlayerAccount(r0_46), "HG->MakeCustomGender") or 7)
  local r4_46 = dbPoll(dbQuery(r27_0, "SELECT * FROM ply_clothes WHERE id = ?", tonumber(getElementData(r0_46, config.Global.elementID))), -1)
  if r4_46 and 1 <= #r4_46 then
    local r5_46 = {}
    local r6_46 = {}
    for r10_46, r11_46 in ipairs(r4_46) do
      if table.contains(r29_0, r11_46.tipo) then
        table.insert(r5_46, r11_46)
      else
        table.insert(r6_46, r11_46)
      end
    end
    for r10_46, r11_46 in ipairs(r5_46) do
      triggerClientEvent("setPlayerRoupa", r0_46, r0_46, r11_46.tipo, r11_46.clothes, r11_46.stylo)
    end
    for r10_46, r11_46 in ipairs(r6_46) do
      triggerClientEvent("setPlayerRoupa", r0_46, r0_46, r11_46.tipo, r11_46.clothes, r11_46.stylo)
    end
  end
end
addEvent("HG->resetClothes", true)
addEventHandler("HG->resetClothes", root, reloadPlayerClothes)
function loadAllClothes()
  -- line: [722, 749] id: 47

  for r3_47, r4_47 in ipairs(getElementsByType("player")) do
    local r5_47 = dbPoll(dbQuery(r27_0, "SELECT * FROM ply_clothes WHERE id = ?", getElementData(r4_47, config.Global.elementID)), -1)
    if r5_47 and 1 <= #r5_47 then
      local r6_47 = {}
      local r7_47 = {}
      for r11_47, r12_47 in ipairs(r5_47) do
        if table.contains(r29_0, r12_47.tipo) then
          table.insert(r6_47, r12_47)
        else
          table.insert(r7_47, r12_47)
        end
      end
      for r11_47, r12_47 in ipairs(r6_47) do
        triggerClientEvent(root, "setPlayerRoupa", root, r4_47, r12_47.tipo, r12_47.clothes, r12_47.stylo)
      end
      for r11_47, r12_47 in ipairs(r7_47) do
        triggerClientEvent(root, "setPlayerRoupa", root, r4_47, r12_47.tipo, r12_47.clothes, r12_47.stylo)
      end
    end
  end
  print("[HG-Custom-Character] Todos os modelos foram carregados com sucesso!")
end
function table.contains(r0_48, r1_48)
  -- line: [751, 758] id: 48
  for r5_48, r6_48 in ipairs(r0_48) do
    if r6_48 == r1_48 then
      return true
    end
  end
  return false
end
addEvent("HG->setPlayerRoupaS", true)
addEventHandler("HG->setPlayerRoupaS", root, function(r0_49, r1_49, r2_49, r3_49)
  -- line: [761, 766] id: 49

  if r0_49 and r1_49 and r2_49 and r3_49 then
    triggerClientEvent(r0_49, "setPlayerRoupa", r0_49, r0_49, r1_49, r2_49, r3_49)
  end
end)
function clearShaderAllClothes(r0_50)
  -- line: [771, 776] id: 50

  for r4_50, r5_50 in pairs(roupas_categorias[getElementModel(r0_50)]) do
    triggerClientEvent(root, "clearShaderClothe", root, r0_50, getElementModel(r0_50), r4_50)
  end
end
function resetCharacter(r0_51)
  -- line: [778, 803] id: 51

  if not isElement(r0_51) then
    r0_51 = getPlayerByID(tonumber(r0_51))
  end
  if r0_51 then
    local r1_51 = getElementModel(r0_51)
    local r2_51 = getElementData(r0_51, config.Global.elementID)
    if (r1_51 == 7 or r1_51 == 9) and r2_51 then
      local r3_51 = dbPoll(dbQuery(r27_0, "SELECT * FROM ply_clothes WHERE id = ?", r2_51), -1)
      if r3_51 then
        if #r3_51 >= 1 then
          dbExec(r27_0, "DELETE FROM ply_clothes WHERE id = ?", r2_51)
        end
        clearShaderAllClothes(r0_51)
        setAccountData(getPlayerAccount(r0_51), "HG->MakeCustom", false)
        triggerClientEvent(r0_51, "HG->CustomopenMenu", r0_51, r0_51)
      else
        dbFree(r3_51)
      end
    end
  end
end
addEventHandler("onResourceStart", root, function(r0_52)
  -- line: [824, 837] id: 52
  if r0_52 == getThisResource() then
    for r4_52 = 1, #clotheShops, 1 do
      local r5_52 = clotheShops[r4_52]
      setElementData(createMarker(r5_52[1], r5_52[2], r5_52[3] - 0.8, "cylinder", 1, 0, 0, 0, 0), "HG->ShopClothe", true)
      local r8_52 = config.Global.Blips.Shops.Blip
      if config.Global.Blips.Shops.Active == true then
        createBlip(r5_52[1], r5_52[2], r5_52[3], r8_52)
      end
    end
  end
end)
addEventHandler("onMarkerHit", root, function(r0_53)
  -- line: [839, 848] id: 53
  if getElementType(r0_53) == "player" and (getElementModel(r0_53) == 7 or getElementModel(r0_53) == 9) and getElementData(source, "HG->ShopClothe") == true then
    setElementData(r0_53, "HG->shopInUse", true)
    triggerClientEvent(r0_53, "HG->customOpenShopMenu", r0_53)
  end
end)
addEvent("HG->confirmBuyClothes_S", true)
addEventHandler("HG->confirmBuyClothes_S", root, function(r0_54, r1_54, r2_54)
  if r0_54 and r1_54 and r2_54 then
    if haveFunds(r0_54, r1_54) then
      local r4_54 = getElementData(r0_54, config.Global.elementID)
      local r5_54 = dbPoll(dbQuery(r27_0, "SELECT * FROM ply_clothes WHERE id = ?", r4_54), -1)
      local r6_54 = {}
      if r5_54 and next(r5_54) then
        for r10_54, r11_54 in ipairs(r5_54) do
          local r12_54 = r11_54.tipo
          if r2_54[r12_54] then
            dbExec(r27_0, "UPDATE ply_clothes SET clothes = ?, stylo = ? WHERE id = ? AND tipo = ?", r2_54[r12_54][2], r2_54[r12_54][3], r4_54, r12_54)
            r6_54[r12_54] = true
          end
        end
      end
      for r10_54, r11_54 in pairs(r2_54) do
        if not r6_54[r10_54] then
          dbExec(r27_0, "INSERT INTO ply_clothes (id, tipo, clothes, stylo) VALUES (?, ?, ?, ?)", r4_54, r10_54, r11_54[2], r11_54[3])
        end
      end
      loadNewClothesForAllPlayers(r0_54)
      
      -- ÇÖZÜM: BAŞARILI SATIN ALIM BİLDİRİMİ
      if exports.rp_bildirim then 
          exports.rp_bildirim:goster(r0_54, "success", "Satın Alındı", "Kıyafetleriniz başarıyla kaydedildi.") 
      end
      
      payInvoices(r0_54, r1_54)
    else
      reloadPlayerClothes(r0_54)
      
      -- ÇÖZÜM: YETERSİZ BAKİYE BİLDİRİMİ
      if exports.rp_bildirim then 
          exports.rp_bildirim:goster(r0_54, "error", "Yetersiz Bakiye", "Bu kıyafetleri almak için yeterli paranız yok!") 
      end
      
    end
  end
end)
addEventHandler("onResourceStart", root, function(r0_55)
  -- line: [898, 924] id: 55
  if r0_55 == getThisResource() then
    for r4_55 = 1, #Barbers, 1 do
      local r5_55 = Barbers[r4_55]
      local r6_55 = createMarker(r5_55.Entry[1], r5_55.Entry[2], r5_55.Entry[3] - 0.8, "cylinder", 1, 0, 0, 0, 0)
      local r8_55 = config.Global.Blips.Barbers.Blip
      if config.Global.Blips.Barbers.Active == true then
        createBlip(r5_55.Entry[1], r5_55.Entry[2], r5_55.Entry[3], r8_55)
      end
      setElementData(r6_55, "HG->ShopClotheBarber", true)
      setElementData(r6_55, "HG->ShopClotheBarberInt", r5_55.Interior)
      setElementData(r6_55, "HG->ShopClotheBarberEntry", r5_55.TPEntry)
      local r9_55 = createMarker(r5_55.Exit[1], r5_55.Exit[2], r5_55.Exit[3] - 0.8, "cylinder", 1, 0, 0, 0, 0)
      setElementInterior(r9_55, r5_55.Interior)
      setElementData(r9_55, "HG->ShopClotheBarberExit", true)
      setElementData(r9_55, "HG->ShopClotheBarberExitTP", r5_55.TPExit)
      for r13_55, r14_55 in ipairs(r5_55.Chairs) do
        local r15_55 = createMarker(r14_55[1], r14_55[2], r14_55[3] - 0.8, "cylinder", 1, 255, 255, 255, 50)
        setElementInterior(r15_55, r5_55.Interior)
        setElementData(r15_55, "HG->BarberChair", true)
        setElementData(r15_55, "HG->BarberChairPos", {
          r14_55[1],
          r14_55[2],
          r14_55[3],
          r14_55[4],
          r14_55[5],
          r14_55[6]
        })
      end
    end
  end
end)
addEventHandler("onMarkerHit", root, function(r0_56)
  -- line: [926, 952] id: 56
  if getElementType(r0_56) == "player" then
    if getElementData(source, "HG->ShopClotheBarber") == true then
      local r1_56 = getElementData(source, "HG->ShopClotheBarberInt")
      local r2_56 = getElementData(source, "HG->ShopClotheBarberEntry")
      setElementInterior(r0_56, r1_56)
      setElementPosition(r0_56, r2_56[1], r2_56[2], r2_56[3])
    elseif getElementData(source, "HG->ShopClotheBarberExit") == true then
      local r1_56 = getElementData(source, "HG->ShopClotheBarberExitTP")
      setElementInterior(r0_56, 0)
      setElementPosition(r0_56, r1_56[1], r1_56[2], r1_56[3])
    elseif getElementData(source, "HG->BarberChair") == true then
      if getElementData(source, "HG->BarberChairUse") == true then
        return 
      else
        local r1_56 = getElementData(source, "HG->BarberChairPos")
        setElementPosition(r0_56, r1_56[4], r1_56[5], r1_56[6])
        setElementRotation(r0_56, 0, 0, 90)
        setPedAnimation(r0_56, "HAIRCUTS", "BRB_Sit_In", -1, false, false, false, true)
        setElementData(source, "HG->BarberChairUse", true)
        triggerClientEvent(r0_56, "HG->onPlayerOpenBarber", r0_56)
        setElementData(r0_56, "HG->BlockBarberKeys", true)
        setElementData(r0_56, "HG->BarberChairElement", source)
      end
    end
  end
end)
addEventHandler("onResourceStart", root, function(r0_57)
  -- line: [958, 971] id: 57
  if r0_57 == getThisResource() then
    for r4_57 = 1, #TattoShops, 1 do
      local r5_57 = TattoShops[r4_57]
      setElementData(createMarker(r5_57[1], r5_57[2], r5_57[3] - 0.8, "cylinder", 1, 0, 0, 0, 0), "HG->ShopClotheTattos", true)
      local r8_57 = config.Global.Blips.Tattos.Blip
      if config.Global.Blips.Tattos.Active == true then
        createBlip(r5_57[1], r5_57[2], r5_57[3], r8_57)
      end
    end
  end
end)
addEventHandler("onMarkerHit", root, function(r0_58)
  -- line: [973, 980] id: 58
  if getElementType(r0_58) == "player" and getElementData(source, "HG->ShopClotheTattos") == true then
    triggerClientEvent(r0_58, "HG->onPlayerOpenTatto", r0_58)
    setElementData(r0_58, "HG->inTattoShop", true)
  end
end)
addEventHandler("onResourceStart", root, function(r0_59)
  -- line: [988, 997] id: 59
  if r0_59 == getThisResource() then
    for r4_59 = 1, #CorpsMarkers, 1 do
      local r5_59 = CorpsMarkers[r4_59]
      local r6_59 = createMarker(r5_59[2], r5_59[3], r5_59[4] - 0.8, "cylinder", 1, 0, 0, 0, 0)
      setElementData(r6_59, "HG->ShopClothePolice", true)
      setElementData(r6_59, "HG->ShopClotheCorpACL", r5_59[1])
    end
  end
end)
addEventHandler("onMarkerHit", root, function(hitElement)
  -- Eğer marker'a giren bir oyuncuysa ve bu marker Polis Kıyafet menüsüyse:
  if getElementType(hitElement) == "player" and getElementData(source, "HG->ShopClothePolice") == true then
    
    local charID = getElementData(hitElement, "aktifKarakterID")
    if not charID then return end

    -- rp_factions sistemi için MySQL veritabanından oyuncunun birliğini kontrol ediyoruz
    local sorgu = exports.mysql:sorgu("SELECT faction_id FROM characters WHERE id = ?", charID)
    local sonuc = dbPoll(sorgu, -1)

    -- Eğer oyuncunun verisi varsa ve faction_id'si 1 (LSPD / Polis) ise:
    if sonuc and #sonuc > 0 and tonumber(sonuc[1].faction_id) == 1 then
        triggerClientEvent(hitElement, "HG->onPlayerOpenPoliceShop", hitElement)
        setElementData(hitElement, "HG->inPoliceShop", true)
    else
        -- Polis değilse hata ver!
        if exports.rp_bildirim then
            exports.rp_bildirim:goster(hitElement, "error", "Erişim Reddedildi", "Bu dolabı sadece polis memurları kullanabilir!")
        end
    end
    
  end
end)
function loadCorpClothesForAllOnlinePlayers(r0_61)
  -- line: [1021, 1044] id: 61

  if r28_0[r0_61] then
    triggerClientEvent("HG->updateClothesCorps", r0_61, r0_61, r28_0[r0_61])
    local r1_61 = {}
    local r2_61 = {}
    for r6_61, r7_61 in pairs(r28_0[r0_61]) do
      if table.contains(r29_0, r7_61[1]) then
        table.insert(r1_61, r7_61)
      else
        table.insert(r2_61, r7_61)
      end
    end
    for r6_61, r7_61 in ipairs(r1_61) do
      triggerClientEvent("setPlayerRoupa", r0_61, r0_61, r7_61[1], r7_61[2], r7_61[3])
    end
    for r6_61, r7_61 in ipairs(r2_61) do
      triggerClientEvent("setPlayerRoupa", r0_61, r0_61, r7_61[1], r7_61[2], r7_61[3])
    end
  end
end
function loadCorpsClothesForJoiningPlayer(r0_62)
  -- line: [1046, 1075] id: 62

  for r4_62, r5_62 in pairs(r28_0) do
    triggerClientEvent(r0_62, "HG->updateClothesCorps", r0_62, r4_62, r5_62)
    local r6_62 = {}
    local r7_62 = {}
    for r11_62, r12_62 in pairs(r5_62) do
      if table.contains(r29_0, r12_62[1]) then
        table.insert(r6_62, r12_62)
      else
        table.insert(r7_62, r12_62)
      end
    end
    for r11_62, r12_62 in ipairs(r6_62) do
      triggerClientEvent(r0_62, "setPlayerRoupa", r0_62, r4_62, r12_62[1], r12_62[2], r12_62[3])
    end
    for r11_62, r12_62 in ipairs(r7_62) do
      triggerClientEvent(r0_62, "setPlayerRoupa", r0_62, r4_62, r12_62[1], r12_62[2], r12_62[3])
    end
  end
end
addEvent("HG->saveLocalCorpClothes", true)
addEventHandler("HG->saveLocalCorpClothes", root, function(r0_63, r1_63)
  -- line: [1079, 1087] id: 63
  if r0_63 and r1_63 then
    if not r28_0[r0_63] then
      r28_0[r0_63] = {}
    end
    r28_0[r0_63] = r1_63
    loadCorpClothesForAllOnlinePlayers(r0_63)
  end
end)


-- ====================================================================
-- RP_AUTH İÇİN ÖZEL KIYAFET YÜKLEME KÖPRÜSÜ
-- ====================================================================
addEvent("Horizon:KiyafetleriYukle", true)
addEventHandler("Horizon:KiyafetleriYukle", root, function(oyuncu)
    if isElement(oyuncu) then
        -- Oyuncunun kendi kıyafetlerini herkese göster
        loadNewClothesForAllPlayers(oyuncu)
        -- Sunucudaki diğer oyuncuların kıyafetlerini bu oyuncuya yükle
        loadAllClothesForEnteringPlayer(oyuncu)
        -- Polis/Meslek kıyafetlerini yükle
        loadCorpsClothesForJoiningPlayer(oyuncu)
    end
end)



