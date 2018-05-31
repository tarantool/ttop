#!/usr/bin/env tarantool

local ffi = require('ffi')
local net_box = require('net.box')
local json = require('json')



local function maketermfunc(sequence_fmt)
  sequence_fmt = '\027[' .. sequence_fmt

  local func

  func = function(handle, ...)
    if io.type(handle) ~= 'file' then
      return func(io.stdout, handle, ...)
    end

    return handle:write(string.format(sequence_fmt, ...))
  end

  return func
end

local cursor = {
    ['goto'] = maketermfunc('%d;%dH'),
    jump     = maketermfunc('%d;%dH'),
    goup     = maketermfunc('%d;A'),
    godown   = maketermfunc('%d;B'),
    goright  = maketermfunc('%d;C'),
    goleft   = maketermfunc('%d;D'),
    save     = maketermfunc('s'),
    restore  = maketermfunc('u'),
}

local clear    = maketermfunc('2J')
local cleareol = maketermfunc('K')

ffi.cdef[[
int ioctl(int fildes, unsigned long request, ...);
int fileno(struct FILE *stream);
int isatty(int fd);
]]

local function capture(cmd, raw)
    local f = assert(io.popen(cmd, 'r'))
    local s = assert(f:read('*a'))
    f:close()
    if raw then return s end
    s = string.gsub(s, '^%s+', '')
    s = string.gsub(s, '%s+$', '')
    s = string.gsub(s, '[\n\r]+', ' ')
    return s
end

-- It is possible to get width and height through ioctl, but
-- it's hard to get the value of TIOCGWINSZ constant. Thus
-- I just fall back to regular shell calls, since they are
-- pretty infrequent.
local function stdout_width()
    return tonumber(capture('tput cols'))
end

local function stdout_height()
    return tonumber(capture('tput lines'))
end

local function isatty(descriptor)
    local fileno = ffi.C.fileno(descriptor)
    local is_tty = ffi.C.isatty(fileno)

    return is_tty == 1
end


if not isatty(io.stdout) then
    os.exit("stdout is not a tty")
end

local function draw_progressbar(x, y, length, value, text)

end


local function main()
    local url = 'localhost:3301'

    if arg[1] ~= nil then
        url = arg[1]
    end
end


main()
