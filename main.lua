local utf8 = require("utf8")

cards = {
    ["name"] = {},
    ["damage"] = {},
    ["mana"] = {},
    ["type"] = {},
    ["elem"] = {},
    ["anim"] = {}
}

function split(pString, pPattern)
    local Table = {}
    local fpat = "(.-)" .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(Table, cap)
        end
        last_end = e + 1
        s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
        cap = pString:sub(last_end)
        table.insert(Table, cap)
    end
    return Table
end

function fileCheck(file_name)
    local file_found = io.open(file_name, "r")

    if file_found == nil then
        file_found = false
    else
        file_found = true
    end
    return file_found
end

function love.wheelmoved(dx, dy)
    velx = velx + dx * 20
    vely = vely + dy * 20
end

function findCard(name)
    name = string.lower(name)
    for i = 1, numCards do
        if cards.name[i] == name then
            return i
        end
    end
    return 0
end

function castSpell(index)
    message = "You cast " .. cards.name[index]
    if cards.type[index] == "attack" then
        message = "You cast " .. cards.name[index] .. " and dealt " .. cards.damage[index] .. " damage."
    elseif cards.type[index] == "defense" then
        message = "You cast " .. cards.name[index] .. " and blocked"
    end
end

function love.load()
    background = love.graphics.newImage("Assets/Background.png")
    mainMenuTextBackground = love.graphics.newImage("Assets/MainMenuText.png")
    person = love.graphics.newImage("Assets/Person.png")
    textBox = love.graphics.newImage("Assets/TextBox.png")
    titleFont = love.graphics.newFont("Assets/munro.ttf", 96)
    font = love.graphics.newFont("Assets/munro.ttf", 24)
    --initialize variables
    input = ""
    message = "Type P to Start"
    gameStage = "menu"
    --read each card into array cards
    io.input("Assets/Cards/cards.txt")
    numCards = io.read()
    for i = 1, numCards do
        local tempTable = split(io.read(), " ")
        cards.name[i] = tempTable[1]
        cards.damage[i] = tempTable[2]
        cards.mana[i] = tempTable[3]
        cards.type[i] = tempTable[4]
        cards.elem[i] = tempTable[5]
        if fileCheck("Assets/Cards/" .. tempTable[6]) then
            cards.anim[i] = newAnimation(love.graphics.newImage("Assets/Cards/" .. tempTable[6]), 160, 160, 1)
        else
            cards.anim[i] = newAnimation(love.graphics.newImage("Assets/Placeholder.png"), 160, 160, 1)
        end
    end
    io.close()

    --allow repeating input
    love.keyboard.setKeyRepeat(true)
    --scrolling
    scrollSpeed = 30
    posx, posy = love.graphics.getWidth() * 0.5, 200
    velx, vely = 0, 0 -- The scroll velocity
end

function love.textinput(t)
    input = input .. t
end

function love.keypressed(key)
    --erase message
    message = ""
    --textbox
    if key == "backspace" then
        if utf8.offset(input, -1) then
            input = string.sub(input, 1, utf8.offset(input, -1) - 1)
        end
    end
    if key == "return" then
        --take input
        input = string.lower(input)
        local location = findCard(input)
        --find location of card
        if input == "p" or input == "play game" then
            --start game
            gameStage = "cardSelect"
            input = ""
        elseif location > 0 and gameStage == "cardSelect" then
            --add card to deck
        elseif location > 0 and gameStage == "game" then
            --cast the spell
            castSpell(location)
        else
            message = "invalid input" --error message
        end
        input = "" -- clear input
    end
end

function love.update(dt)
    --animations
    for i = 1, numCards do
        cards.anim[i].currentTime = cards.anim[i].currentTime + dt
        if cards.anim[i].currentTime >= cards.anim[i].duration then
            cards.anim[i].currentTime = cards.anim[i].currentTime - cards.anim[i].duration
        end
    end
    --scrolling
    if posy >= 200 then
        posy = 200
    end
    posx = posx + velx * scrollSpeed * dt
    posy = posy + vely * scrollSpeed * dt

    -- Gradually reduce the velocity to create smooth scrolling effect.
    velx = velx - velx * math.min(dt * 10, 1)
    vely = vely - vely * math.min(dt * 10, 1)
end

function displayCard(cardNum)
    love.graphics.setFont(font)
    local colNum, rowNum = cardNum % 3, math.ceil(cardNum / 3)
    if colNum == 0 then
        colNum = 3
    end
    local cardX, cardY = 245 * (colNum - 1) + 65, 317 * (rowNum - 1) + posy
    if cards.elem[cardNum] == "fire" then
        love.graphics.setColor(232 / 255, 0 / 255, 43 / 255)
    elseif cards.elem[cardNum] == "earth" then
        love.graphics.setColor(78 / 255, 171 / 255, 84 / 255)
    elseif cards.elem[cardNum] == "water" then
        love.graphics.setColor(39 / 255, 98 / 255, 176 / 255)
    else
        love.graphics.setColor(160 / 255, 160 / 255, 160 / 255)
    end
    love.graphics.rectangle("fill", cardX, cardY, 180, 252)
    --print image
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", cardX + 10, cardY + 25, 160, 160)
    local spriteNum = math.floor(cards.anim[cardNum].currentTime / cards.anim[cardNum].duration * #cards.anim[cardNum].quads) + 1
    love.graphics.draw(cards.anim[cardNum].spriteSheet, cards.anim[cardNum].quads[spriteNum], cardX + 10, cardY + 25, 0, 1)
    --print text
    love.graphics.printf(cards.name[cardNum], cardX + 10, cardY, 180, "left")
    love.graphics.printf(cards.mana[cardNum], cardX - 10, cardY, 180, "right")
    if cards.type[cardNum] == "attack" then
        love.graphics.printf("Deal " .. cards.damage[cardNum] .. " damage.", cardX + 10, cardY + 200, 180, "left")
    end
end

function love.draw()
    --background
    love.graphics.draw(background, 0, 0)
    love.graphics.setFont(font)
    love.graphics.draw(person, 100, 320)
    love.graphics.draw(person, 700, 320, 0, -1, 1)
    --set font to normal font
    if gameStage == "menu" then
        --title
        love.graphics.draw(mainMenuTextBackground, 0, 205)
        love.graphics.setFont(titleFont) --set font to title font
        love.graphics.printf("TypeFighter", 0, 200, love.graphics.getWidth(), "center")
        --menu
        love.graphics.setFont(font)
        love.graphics.printf("[P]lay Game", 0, 300, love.graphics.getWidth(), "center")
        --animation
        local spriteNum0 = math.floor(cards.anim[findCard("torrent")].currentTime / cards.anim[findCard("torrent")].duration * #cards.anim[findCard("torrent")].quads) + 1
        local spriteNum1 = math.floor(cards.anim[findCard("fireball")].currentTime / cards.anim[findCard("fireball")].duration * #cards.anim[findCard("fireball")].quads) + 1
        love.graphics.draw(cards.anim[findCard("torrent")].spriteSheet, cards.anim[findCard("torrent")].quads[spriteNum0], 50, 180, 0, 1)
        love.graphics.draw(cards.anim[findCard("fireball")].spriteSheet, cards.anim[findCard("fireball")].quads[spriteNum1], 750, 345, 3.14159, 1)
    end
    if gameStage == "cardSelect" then --Stage of card selection
        love.graphics.setColor(255, 255, 255) -- reset colors
        --Display card select title
        love.graphics.setFont(titleFont) --set font to title font
        love.graphics.printf("Select Cards", 0, posy - 135, love.graphics.getWidth(), "center")

        for i = 1, math.ceil(numCards / 3) do
            for j = 1, 3 do
                displayCard(i + j - 1)
            end
        end
        if gameStage == "game" then
        end
    end

    --input box at bottom of screen
    love.graphics.draw(textBox, 0, 570)
    love.graphics.printf(message, 5, 570, love.graphics.getWidth(), "left")
    love.graphics.printf(input, 5, 570, love.graphics.getWidth(), "left")
end

function newAnimation(image, width, height, duration)
    local animation = {}
    animation.spriteSheet = image
    animation.quads = {}

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end

    animation.duration = duration or 1
    animation.currentTime = 0

    return animation
end
