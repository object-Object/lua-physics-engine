local logger={}

logger.timestamp = function()
    return os.date("%c")
end

logger.warn = function(msg)
    print("[ WARN ] "..msg)
end

return logger