function digDown(targetY)
    while pos.getLocation["y"] > 0 do
        turtle.digDown()
        pos.down()
    end

    pos.saveLocation()
end