Card = {}

function Card:Create()
    local tempTable = split(io.read(), " ")
    local card = {
        name = tempTable[1],
        damage = tempTable[2],
        mana = tempTable[3],
        type = tempTable[4],
        elem = tempTable[5],
        deck = 0
    }
    if fileCheck("Assets/Cards/" .. card.name .. ".png") then
        card.anim = newAnimation(love.graphics.newImage("Assets/Cards/" .. card.name .. ".png"), 160, 160, 1)
    else
        card.anim = newAnimation(love.graphics.newImage("Assets/Placeholder.png"), 160, 160, 1)
    end
    return card
end

function Card:Display(cardIndex)
    love.graphics.setFont(font)
    local colNum, rowNum = cardIndex % 3, math.ceil(cardIndex / 3)
    if colNum == 0 then
        colNum = 3
    end
    local cardX, cardY = 245 * (colNum - 1) + 65, 317 * (rowNum - 1) + posy
    if cards[cardIndex].deck == 1 then
        love.graphics.setColor(colors.player1)
        love.graphics.rectangle("fill", cardX - 10, cardY - 10, 200, 272, 5)
    elseif cards[cardIndex].deck == 2 then
        love.graphics.setColor(colors.player2)
        love.graphics.rectangle("fill", cardX - 10, cardY - 10, 200, 272, 5)
    end
    if cards[cardIndex].elem == "fire" then
        love.graphics.setColor(colors.red)
    elseif cards[cardIndex].elem == "earth" then
        love.graphics.setColor(colors.green)
    elseif cards[cardIndex].elem == "water" then
        love.graphics.setColor(colors.blue)
    else
        love.graphics.setColor(colors.grey)
    end
    love.graphics.rectangle("fill", cardX, cardY, 180, 252)
    --print images
    love.graphics.setColor(colors.white)
    love.graphics.rectangle("fill", cardX + 10, cardY + 25, 160, 160)
    local spriteNum = math.floor(cards[cardIndex].anim.currentTime / cards[cardIndex].anim.duration * #cards[cardIndex].anim.quads) + 1
    love.graphics.draw(cards[cardIndex].anim.spriteSheet, cards[cardIndex].anim.quads[spriteNum], cardX + 10, cardY + 25, 0, 1)
    --print text
    love.graphics.printf(cards[cardIndex].name, cardX + 10, cardY, 180, "left")
    love.graphics.printf(cards[cardIndex].mana, cardX - 10, cardY, 180, "right")
    local cardText = ""
    if cards[cardIndex].type == "attack" then
        cardText = "Deal " .. cards[cardIndex].damage .. " damage."
    elseif cards[cardIndex].type == "heal" then
        cardText = "Gain " .. cards[cardIndex].damage .. " life."
    end
    love.graphics.printf(cardText, cardX + 10, cardY + 200, 180, "left")
end

function findCard(cardToFind)
    cardToFind = string.lower(cardToFind)
    for i = 1, numCards do
        if cards[i].name == cardToFind then
            return i
        end
    end
    return 0
end
