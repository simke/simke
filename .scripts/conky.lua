--[[
Ring Meters by londonali1010 (2009)
 
This script draws percentage meters as rings. It is fully customisable; all options are described in the script.
 
IMPORTANT: if you are using the 'cpu' function, it will cause a segmentation fault if it tries to draw
a ring straight away. The if statement on line 145 uses a delay to make sure that this doesn't happen.
It calculates the length of the delay by the number of updates since Conky started. Generally, a value
of 5s is long enough, so if you update Conky every 1s, use update_num > 5 in that if statement (the default).
If you only update Conky every 2s, you should change it to update_num > 3; conversely if you update
Conky every 0.5s, you should use update_num > 10. ALSO, if you change your Conky, is it best to use
"killall conky; conky" to update it, otherwise the update_num will not be reset and you will get an error.
 
To call this script in Conky, use the following (assuming that you save this script to ~/scripts/rings.lua):
    lua_load ~/scripts/rings-v1.2.1.lua
    lua_draw_hook_pre ring_stats
 
Changelog:
+ v1.2.1 -- Fixed minor bug that caused script to crash if conky_parse() returns a nil value (20.10.2009)
+ v1.2 -- Added option for the ending angle of the rings (07.10.2009)
+ v1.1 -- Added options for the starting angle of the rings, and added the "max" variable, to allow for variables that output a numerical value rather than a percentage (29.09.2009)
+ v1.0 -- Original release (28.09.2009)
]]
conky_background_color = 0x00000
conky_background_alpha = 0.9

ring_background_color = 0xffffff
ring_background_alpha = 0.15
ring_foreground_color = 0xffffff
ring_foreground_alpha = 0.5
 
settings_table = {
    {
        -- Edit this table to customise your rings.
        -- You can create more rings simply by adding more elements to settings_table.
        -- "name" is the type of stat to display; you can choose from 'cpu', 'memperc', 'fs_used_perc', 'battery_used_perc'.
        name='time',
        -- "arg" is the argument to the stat type, e.g. if in Conky you would write ${cpu cpu0}, 'cpu0' would be the argument.
    -- If you would not use an argument in the Conky variable, use ''.
        arg='%I.%M',
        -- "max" is the maximum value of the ring. If the Conky variable outputs a percentage, use 100.
        max=12,
        -- "bg_colour" is the colour of the base ring.
        bg_colour=ring_background_color,
        -- "bg_alpha" is the alpha value of the base ring.
        bg_alpha=ring_background_alpha,
        -- "fg_colour" is the colour of the indicator part of the ring.
        fg_colour=ring_foreground_color,
        -- "fg_alpha" is the alpha value of the indicator part of the ring.
        fg_alpha=ring_foreground_alpha,
        -- "x" and "y" are the x and y coordinates of the centre of the ring, relative to the top left corner of the Conky window.
        x=26, y=30,
        -- "radius" is the radius of the ring.
        radius=10,
        -- "thickness" is the thickness of the ring, centred around the radius.
        thickness=5,
        -- "start_angle" is the starting angle of the ring, in degrees, clockwise from top. Value can be either positive or negative.
        start_angle=0,
        -- "end_angle" is the ending angle of the ring, in degrees, clockwise from top. Value can be either positive or negative, but must be larger (e.g. more clockwise) than start_angle.
        end_angle=360
    },
    {
        name='time',
        arg='%M.%S',
        max=60,
        bg_colour=ring_background_color,
        bg_alpha=ring_background_alpha,
        fg_colour=ring_foreground_color,
        fg_alpha=ring_foreground_alpha,
        x=26, y=30,
        radius=16,
        thickness=3,
        start_angle=0,
        end_angle=360
    },
    {
        name='time',
        arg='%S',
        max=60,
        bg_colour=ring_background_color,
        bg_alpha=ring_background_alpha,
        fg_colour=ring_foreground_color,
        fg_alpha=ring_foreground_alpha,
        x=26, y=30,
        radius=20,
        thickness=2,
        start_angle=0,
        end_angle=360
    },
    {
        name='cpu',
        arg='cpu1',
        max=100,
        bg_colour=ring_background_color,
        bg_alpha=ring_background_alpha,
        fg_colour=ring_foreground_color,
        fg_alpha=ring_foreground_alpha,
        x=26, y=80,
        radius=19,
        thickness=6,
        start_angle=-90,
        end_angle=210
    },
    {
        name='memperc',
        arg='',
        max=100,
        bg_colour=ring_background_color,
        bg_alpha=ring_background_alpha,
        fg_colour=ring_foreground_color,
        fg_alpha=ring_foreground_alpha,
        x=26, y=130,
        radius=19,
        thickness=5,
        start_angle=-90,
        end_angle=200
    },
    {
        name='swapperc',
        arg='',
        max=100,
        bg_colour=ring_background_color,
        bg_alpha=ring_background_alpha,
        fg_colour=ring_foreground_color,
        fg_alpha=ring_foreground_alpha,
        x=26, y=130,
        radius=13,
        thickness=5,
        start_angle=-90,
        end_angle=180
    },
    {
        name='upspeedf',
        arg='wlan0',
        max=100,
        bg_colour=ring_background_color,
        bg_alpha=ring_background_alpha,
        fg_colour=ring_foreground_color,
        fg_alpha=ring_foreground_alpha,
        x=26, y=180,
        radius=13,
        thickness=5,
        start_angle=-90,
        end_angle=180
    },
    {
        name='downspeedf',
        arg='wlan0',
        max=250,
        bg_colour=ring_background_color,
        bg_alpha=ring_background_alpha,
        fg_colour=ring_foreground_color,
        fg_alpha=ring_foreground_alpha,
        x=26, y=180,
        radius=19,
        thickness=5,
        start_angle=-90,
        end_angle=200
    },
}
 
 -- Use these settings to define the origin and extent of your clock.

clock_r=20

-- "clock_x" and "clock_y" are the coordinates of the centre of the clock, in pixels, from the top left of the Conky window.

clock_x=26
clock_y=30

show_seconds=true

require 'cairo'
 
function rgb_to_r_g_b(colour,alpha)
    return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

function conky_round_rect(cr, x0, y0, w, h, r)
    if (w == 0) or (h == 0) then return end
    local x1 = x0 + w
    local y1 = y0 + h
    if w/2 < r then
        if h/2 < r then
            cairo_move_to  (cr, x0, (y0 + y1)/2)
            cairo_curve_to (cr, x0 ,y0, x0, y0, (x0 + x1)/2, y0)
            cairo_curve_to (cr, x1, y0, x1, y0, x1, (y0 + y1)/2)
            cairo_curve_to (cr, x1, y1, x1, y1, (x1 + x0)/2, y1)
            cairo_curve_to (cr, x0, y1, x0, y1, x0, (y0 + y1)/2)
        else
            cairo_move_to  (cr, x0, y0 + r)
            cairo_curve_to (cr, x0 ,y0, x0, y0, (x0 + x1)/2, y0)
            cairo_curve_to (cr, x1, y0, x1, y0, x1, y0 + r)
            cairo_line_to (cr, x1 , y1 - r)
            cairo_curve_to (cr, x1, y1, x1, y1, (x1 + x0)/2, y1)
            cairo_curve_to (cr, x0, y1, x0, y1, x0, y1- r)
        end
    else
        if h/2 < r then
            cairo_move_to  (cr, x0, (y0 + y1)/2)
            cairo_curve_to (cr, x0 , y0, x0 , y0, x0 + r, y0)
            cairo_line_to (cr, x1 - r, y0)
            cairo_curve_to (cr, x1, y0, x1, y0, x1, (y0 + y1)/2)
            cairo_curve_to (cr, x1, y1, x1, y1, x1 - r, y1)
            cairo_line_to (cr, x0 + r, y1)
            cairo_curve_to (cr, x0, y1, x0, y1, x0, (y0 + y1)/2)
        else
            cairo_move_to  (cr, x0, y0 + r)
            cairo_curve_to (cr, x0 , y0, x0 , y0, x0 + r, y0)
            cairo_line_to (cr, x1 - r, y0)
            cairo_curve_to (cr, x1, y0, x1, y0, x1, y0 + r)
            cairo_line_to (cr, x1 , y1 - r)
            cairo_curve_to (cr, x1, y1, x1, y1, x1 - r, y1)
            cairo_line_to (cr, x0 + r, y1)
            cairo_curve_to (cr, x0, y1, x0, y1, x0, y1- r)
        end
    end
    cairo_close_path (cr)
end

function draw_clock_hands(cr,xc,yc)
    local secs,mins,hours,secs_arc,mins_arc,hours_arc
    local xh,yh,xm,ym,xs,ys
    
    secs=os.date("%S")    
    mins=os.date("%M")
    hours=os.date("%I")
        
    secs_arc=(2*math.pi/60)*secs
    mins_arc=(2*math.pi/60)*mins+secs_arc/60
    hours_arc=(2*math.pi/12)*hours+mins_arc/12
        
    -- Draw hour hand
    
    xh=xc+0.7*clock_r*math.sin(hours_arc)
    yh=yc-0.7*clock_r*math.cos(hours_arc)
    cairo_move_to(cr,xc,yc)
    cairo_line_to(cr,xh,yh)
    
    cairo_set_line_cap(cr,CAIRO_LINE_CAP_ROUND)
    cairo_set_line_width(cr,3)
    cairo_set_source_rgba(cr,1.0,1.0,1.0,1.0)
    cairo_stroke(cr)
    
    -- Draw minute hand
    
    xm=xc+clock_r*math.sin(mins_arc)
    ym=yc-clock_r*math.cos(mins_arc)
    cairo_move_to(cr,xc,yc)
    cairo_line_to(cr,xm,ym)
    
    cairo_set_line_width(cr,2)
    cairo_stroke(cr)
    
    -- Draw seconds hand
    
    if show_seconds then
        xs=xc+clock_r*math.sin(secs_arc)
        ys=yc-clock_r*math.cos(secs_arc)
        cairo_move_to(cr,xc,yc)
        cairo_line_to(cr,xs,ys)
    
        cairo_set_line_width(cr,1)
        cairo_stroke(cr)
    end
end

function draw_ring(cr,t,pt)
    local w,h=conky_window.width,conky_window.height
 
    local xc,yc,ring_r,ring_w,sa,ea=pt['x'],pt['y'],pt['radius'],pt['thickness'],pt['start_angle'],pt['end_angle']
    local bgc, bga, fgc, fga=pt['bg_colour'], pt['bg_alpha'], pt['fg_colour'], pt['fg_alpha']
 
    local angle_0=sa*(2*math.pi/360)-math.pi/2
    local angle_f=ea*(2*math.pi/360)-math.pi/2
    local t_arc=t*(angle_f-angle_0)
 
    -- Draw background ring
 
    cairo_arc(cr,xc,yc,ring_r,angle_0,angle_f)
    cairo_set_source_rgba(cr,rgb_to_r_g_b(bgc,bga))
    cairo_set_line_width(cr,ring_w)
    cairo_stroke(cr)
 
    -- Draw indicator ring
 
    cairo_arc(cr,xc,yc,ring_r,angle_0,angle_0+t_arc)
    cairo_set_source_rgba(cr,rgb_to_r_g_b(fgc,fga))
    cairo_stroke(cr)        
end
 
cs, cr = nil -- initialize our cairo surface and context to nil
function conky_ring_stats()
    local function setup_rings(cr,pt)
        local str=''
        local value=0
 
        str=string.format('${%s %s}',pt['name'],pt['arg'])
        str=conky_parse(str)

    if pt['name'] == 'diskio' or pt['name'] == 'diskio_read' or pt['name'] == 'diskio_write' then
        --what units?
        if string.find(str,'M') == nil then
            if string.find(str,'K') == nil then
                --bytes
                --value=tonumber(string.sub(str,0,string.find(str,'B')))
                str=string.sub(str,0,string.find(str,'B')-1)
                value=tonumber(str)
            else --kilobytes
                --value=tonumber(string.sub(str,0,string.find(str,'KiB')))*1024*1024
                str=string.sub(str,0,string.find(str,'K')-1)
                value=tonumber(str)*1024
            end
        else --megabytes
            --value=tonumber(string.sub(str,0,string.find(str,'MiB')))*1024*1024
            str=string.sub(str,0,string.find(str,'M')-1)
            value=tonumber(str)*1024*1024
        end
        if value == nil then value = 0 end
    else
        value=tonumber(str)
    end
		
        if value == nil then value = 0 end
        pct=value/pt['max']
 
        draw_ring(cr,pct,pt)
    end
 
    if conky_window==nil then return end
    local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual, conky_window.width,conky_window.height)
 
    local cr=cairo_create(cs)

    if cs == nil or cairo_xlib_surface_get_width(cs) ~= conky_window.width or cairo_xlib_surface_get_height(cs) ~= conky_window.height then
        if cs then cairo_surface_destroy(cs) end
        cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
    end
    if cr then cairo_destroy(cr) end
    cr = cairo_create(cs)

 
    local updates=conky_parse('${updates}')
    update_num=tonumber(updates)
 
    if update_num>3 then
        conky_round_rect(cr, 3, 0, conky_window.width-6, conky_window.height-3, 15)
        cairo_set_source_rgba(cr, rgb_to_r_g_b(conky_background_color, conky_background_alpha))
        cairo_fill(cr)
        for i in pairs(settings_table) do
            setup_rings(cr,settings_table[i])
        end
    end
	
	draw_clock_hands(cr,clock_x,clock_y)
    cairo_destroy(cr)
    cr = nil
end

function conky_cairo_cleanup()
    cairo_surface_destroy(cs)
    cs = nil
end