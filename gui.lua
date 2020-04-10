gui={}
gui.icons={
  square=love.graphics.newImage('icons/square.png'),
  circle=love.graphics.newImage('icons/circle.png'),
  hand=love.graphics.newImage('icons/hand.png'),
  trashcan=love.graphics.newImage('icons/trashcan.png'),
  area=love.graphics.newImage('icons/area.png'),
  connect=love.graphics.newImage('icons/connect.png'),
  no=love.graphics.newImage('icons/no.png'),
  yes=love.graphics.newImage('icons/yes.png'),
  remconnect=love.graphics.newImage('icons/remconnect.png'),
  add=love.graphics.newImage('icons/add.png'),
  back=love.graphics.newImage('icons/back.png'),
  reload=love.graphics.newImage('icons/reload.png'),
}

gui.modes={
  { name='Spawn Tool',icon=gui.icons.add,onclick=function() ctool='sp' fig='sqr' end,
    buttons={
      {name='Square',icon=gui.icons.square,onclick=function() fig='sqr' end,fade=function() return not(fig=='sqr') end},
      {name='Circle',icon=gui.icons.circle,onclick=function() fig='crc' end,fade=function() return not(fig=='crc') end},
    } 
  },
  { name='Hand',icon=gui.icons.hand,onclick=function() ctool='mv' end  },
  { name='Delete',icon=gui.icons.trashcan,onclick=function() ctool='dl' end,
    buttons={
      {name='Reload',icon=gui.icons.no,onclick=function() reset() end},
    }
  },
  { name='Unweld',icon=gui.icons.remconnect,onclick=function() ctool='uw' end ,
    buttons={
      {name='Cancel weld',icon=gui.icons.back,onclick=function() cancelWeld() end},
    } 
  },
  { name='Select',icon=gui.icons.area,onclick=function() ctool='sl' end,
    buttons={
      {name='Weld',icon=gui.icons.connect,onclick=function() welds[#welds+1]=phyWeldGroup(selection) selection={} end},
      {name='Unweld',icon=gui.icons.remconnect,onclick=function() phyUnweldGroup2(selection) selection={} end},
      {name='Delete',icon=gui.icons.trashcan,onclick=function() phyDestroyGroup(selection) selection={} end},
      {name='Clear selection',icon=gui.icons.no,onclick=function() selection={} end},
    } 
  },
}

function gui.vclick(i)
  gui.selected=i
  gui.modes[i].onclick()
end

function gui.draw() local g=love.graphics
  local function oof(t)
    return #t*34+2
  end
  
  gui.panel={x=w-36,y=0,w=36,h=oof(gui.modes),s=34}
  g.outlRect(gui.panel.x,gui.panel.y,gui.panel.w,gui.panel.h,{1,1,1,0.5})
  for i,v in ipairs(gui.modes)do
    if i==gui.selected then g.setColor(1,1,1) else g.setColor(1,1,1,0.5) end
    g.draw(v.icon,w-34,(i-1)*gui.panel.s)
  end
  
  g.setColor(1,1,1)
  local sp=gui.modes[gui.selected].buttons
  
  if(sp)then
    gui.subpanel={x=gui.panel.x,y=gui.panel.y+gui.panel.h+3,w=gui.panel.w,h=oof(sp)}
    g.outlRect(gui.subpanel.x,gui.subpanel.y,gui.subpanel.w,gui.subpanel.h,{1,1,1,0.5})
    for i,v in ipairs(sp)do
      g.setColor(1,1,1,1)
      if(v.fade)then
        if(v.fade())then
          g.setColor(1,1,1,0.5)
        end
      end
      g.draw(v.icon,w-34,gui.subpanel.y+((i-1)*gui.panel.s))
    end
  end
  local text=gui.modes[gui.selected].name
  g.print(text,w-(text:len()*8),h-15)
  g.print(gui.text2,w-(gui.text2:len()*8),h-30)
end

function gui.click(x,y,b)
  gui.text2=''
  if(x>w-gui.panel.w)then
    local sep=gui.panel.s
    if(y<gui.subpanel.y)then
      for i,v in ipairs(gui.modes)do
        local i2=i-1
        if (y>i2*sep) and (y<(i2+1)*sep) then
          if b==1 then
            gui.selected=i
            v.onclick()
          end
        end
      end
    elseif(y<gui.subpanel.y+gui.subpanel.h)then local py=gui.panel.y+gui.panel.h
      local sp=gui.modes[gui.selected].buttons
      for i,v in ipairs(sp) do
        local i2=i-1
        if (y-py>(i2*sep)) and (y-py<(i2+1)*sep) then
          if b==1 then
            sp[i].onclick()
          end
          gui.text2=v.name
        end
      end
    end
    return true
  end
end

--[[
function gui.loop()
  
end]]