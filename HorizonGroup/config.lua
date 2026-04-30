-- Sitemiz : https://sparrow-mta.blogspot.com/

-- Facebook : https://facebook.com/sparrowgta/
-- İnstagram : https://instagram.com/sparrowmta/
-- YouTube : https://www.youtube.com/@TurkishSparroW/

-- Discord : https://discord.gg/DzgEcvy

--- Author : Rakash
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- GENERAL CONFIGS
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
config = {
    ['Global'] = {
        ["elementID"] = "ID"; -- ElementData do seu sistema de IDs.
        ["triggerOnJoin"] = false; -- Define se o custom será chamado para todo jogador novo que entrar na cidade pela primeira vez.
        ["ShowCursor"] = true; -- Mostrar cursor ao abrir o custom (Se não utilizar bind M para cursor default).
		["finishCustom"] = {1115.85522, -1373.38989, 13.99097, 180}; -- Local que o jogador é teleportado ao criar o personagem. (x,y,z,rotação)
        ["Blips"] = {
            ["Barbers"] = {Active = true, Blip = 7}; -- Blips dos cabeleireiros.
            ["Shops"] = {Active = true, Blip = 45}; -- Blips das lojas de roupas.
            ["Tattos"] = {Active = true, Blip = 39}; -- Blips das lojas de roupas.
        };
    };

    confirmCreationCustomEvent = function(player)
        -- Coloque aqui tudo que você precisa executar depois que a criação de personagem for finalizada.
        -- para chamar funções em eventos externos você deve usar EXPORTS! NÃO COLOQUE TRIGGEREVENTS DENTRO DO CONFIG OU CAIRÁ NA BLACKLIST!!!
        -- Exemplo : export para sistema de identidades, sistema de lobby, etc.
        -- Os exports devem ser SERVER-SIDE!        
        return true
    end,

};

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- CLOTHE SHOPS CONFIG
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
markersColors = { -- Marker personalizado - cores
    {
        icon = {56,140,220,255}, -- Cor do ícone flutuante.
        circle = {56,140,220,0}, -- Cor do círculo em baixo do ícone
    },
};

clotheprices = { -- Altere o valor dos itens das lojas abaixo.
    ['mascara'] = 1;
    ['colete'] = 1;
    ['oculos'] = 1;
    ['camisa'] = 1;
    ['relogio'] = 1;
    ['oculos'] = 1;
    ['chapeu'] = 1;
    ['calca'] = 1;
    ['sapato'] = 1;
    ['mochila'] = 1;
    ['brinco'] = 1;
    ['bochecha'] = 1;
    ["cabelo"] = 1;
    ["sobrancelha"] = 1;
    ["barba"] = 1;
    ["corrente"] = 1;
};

clotheShops = { -- Pos X, Pos Y, Pos Z Markers de loja de roupas.
    {1104.59546, -1372.77380, 13.98438},
    {1107.90503, -1372.48840, 13.99097},
    {1111.83008, -1372.42761, 13.98438},
};

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- CORPS CONFIG
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CorpsMarkers = { -- {Acl, Pos X, Pos Y, Pos Z}
    {"Policia", 1089.94702, -1412.36743, 13.66260},
    {"Policia", 1085.22729, -1412.43762, 13.67851},
}

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- BARBER CONFIG
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Barbers = {
    [1] = {
        Entry = {1045.79724, -1371.28796, 13.58155}; -- Marker de entrada.
        TPEntry = {414.21982, -22.55494, 1001.80469}; -- Local para onde é teleportado ao entrar.
        Exit = {411.58228, -22.56068, 1001.80469}; -- Marker de saída.
        TPExit = {1050.11621, -1370.72961, 13.38281}; -- Local para onde é teleportado ao sair.
        Interior = 2; -- Interior.
        Chairs = { -- Cadeiras. (NÃO ALTERAR)
            {414.22522, -20.88248, 1001.80469, 414.5, -21.95, 1001.80469},
            {414.22522, -18.90691, 1001.80469, 414.5, -20, 1001.80469},
            {414.22522, -16.76345, 1001.80469, 414.5, -17.90, 1001.80469},
        };
    }; 
};

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- TATTOS CONFIG
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TattoShops = {
    {1106.07947, -1411.96484, 13.60872},
    {1101.53418, -1412.35742, 13.62302},
    {1097.24365, -1412.15210, 13.63834},
};

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- NOTIFY BOX EXPORTS
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
notifys = { -- Configure aqui as notificações e os tipos de notificação de acordo com a infobox que você utiliza!
    [1] = {'Compra efetuada com sucesso!', 'sucesso'}, -- {mensagem, infobox type}
    [2] = {'Saldo insuficiente!', 'negado'}, -- {mensagem, infobox type}
}

function mensagem (ply,src,info) -- info = notifys[index] = retorna o índice exato correspondente a mensagem solicitada, edite em 'notifys' acima.
    if src == 'server' then
        exports["hrp_notifysystem"]:Alert(ply, 'Roupas', info[1], 10000, info[2])
    elseif src == 'client' then
        exports["hrp_notifysystem"]:Alert('Roupas', info[1], 10000, info[2])
    end
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Funções uteis
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function formatNumber(number, sep)
	assert(type(tonumber(number))=="number", "Bad argument @'formatNumber' [Expected number at argument 1 got "..type(number).."]")
	assert(not sep or type(sep)=="string", "Bad argument @'formatNumber' [Expected string at argument 2 got "..type(sep).."]")
	local money = number
	for i = 1, tostring(money):len()/3 do
		money = string.gsub(money, "^(-?%d+)(%d%d%d)", "%1"..sep.."%2")
	end
	return money
end

---- Função que retorna o jogador pelo id. (Não modifique isso).
function getPlayerByID (id)
    local p = false
    for k, v in ipairs (getElementsByType ("player")) do
        if getElementData (v, config["Global"]["elementID"]) == id then
            p = v
        end
    end
    return p
end

---- Função que verifica o dinheiro do jogador (para comprar roupas, tatuagens, cabelo, etc). Por padrão usa o dinheiro nativo do MTA.
---- A função deve retornar true/false e é chamada via server-side (Você pode alterar toda a função caso queira por exemplo vincular a um item 'dinheiro' do seu inventário).
function haveFunds(ply,total)
    return (tonumber(getPlayerMoney(ply)) >= tonumber(total))
end

---- Função que retira o dinheiro do jogador, nativamente utilizando o dinheiro padrão do MTA. (Você pode editar a função para por exemplo dar takeitem 'dinheiro' caso faça vínculo com item do inventário acima).
---- Função server-side.
function payInvoices(ply,total)
    if ply and total then
        takePlayerMoney(ply, tonumber(total))
    end
end

-- Sitemiz : https://sparrow-mta.blogspot.com/

-- Facebook : https://facebook.com/sparrowgta/
-- İnstagram : https://instagram.com/sparrowmta/
-- YouTube : https://www.youtube.com/@TurkishSparroW/

-- Discord : https://discord.gg/DzgEcvy