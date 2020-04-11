APPNAME='ALBOX'
VERSION='alpha 0.6'
---------------------
require'fn'
require'phy'
require'gui'

local lv1,lv2=love.getVersion()
lver='LÖVE '..lv1..'.'..lv2
if not(love.isVersionCompatible('11.3')) then warning_love2d=true end

--OLDHELP='WHEEL-Size\nLMB-SPAWN/MOVE\nRMB-SPAWN STATIC/DELETE\nSPACE-PAUSE\nT-Slowmo\nR-RESET\nW-ADD TO SELECTION\nQ-WELD SELECTED\nU-CANCEL WELD'
HELP='WHEEL(or [ ])-Brush size\nLMB-Spawn dynamic/Select/Primary action\nRMB-Spawn static/secondary action\nSPACE-PAUSE\nT-Slowmo\nNumber keys(1-9)-Switch mode shortcut\nTODO:Better help\nARROW KEYS-Move Selected (Selection mode)'

function cancelWeld()
  if(#welds>0)then
    phyUnweldGroup(welds[#welds])
    welds[#welds]=nil
  end
end

function reset()
  gui.text2=''
  gui.selected=1
  ctool='sp'
  fig='sqr'
  objects={}
  selection={}
  toweld={}
  welds={}
  spawnsize=25
  stop=false
  movetmp=nil
  love.physics.setMeter(64)
  world = love.physics.newWorld(0,9.81*love.physics.getMeter(),true)
  ins(objects,phyObject(world,400/2+200,500,400,25))
end

function love.load(arg)
  love.window.setTitle(APPNAME..' '..VERSION..' ('..lver..'/'..jit.version..'/'..jit.os..' '..jit.arch..')')
  love.window.setMode(800,600,{msaa=3,vsync=0,resizable=true,minwidth=650,minheight=570})--fullscreentype='exclusive',fullscreen=true
  reset()
end

function love.update(dt) gc_=(gc_ or -1)+1 if gc_>120 then collectgarbage('collect') gc_=nil end
  --local dts=1/dt
  SPD=dt/(1/60)
  mx,my=love.mouse.getX(),love.mouse.getY()
  m1=love.mouse.isDown(1)
  local slowmo=1;if love.keyboard.isDown('t') then slowmo=5 end;if(stop)then slowmo=math.huge end
  world:update(dt/slowmo)
  
  if(hover and m1 and ctool=='mv')then
    if(phyExists(objects[movetmp]))then
      phyTeleport(objects[movetmp],mx,my)
      phyFix(objects)
    end
  else
    movetmp=hover
  end
  
  if ctool=='sl' then
    local ofx,ofy,p=lrud_control(dt,2)
    if p then
      phyPushGroup(selection,ofx,ofy) 
    end
  end
  
  --if love.keyboard.isDown('v')then love.window.setVSync(1) end
  --if love.keyboard.isDown('b')then love.window.setVSync(0) end
end

function love.draw() 
  local g=love.graphics 
  love.graphics.reset()
  ----------------------------------------------------------
  w,h=g.getWidth(),g.getHeight()
  hover=nil
  for i,v in ipairs(objects) do
    if phyExists(v) then
      phyDraw(v)
      
      local ishs=false
      if(#selection>0)then --check if in selection
        for i2,v2 in ipairs(selection) do
          if v2.i==i then             
            ishs=true
            break
          end
        end
      end
      
      local ish=v.fixture:testPoint(mx,my) 
      if ish then --if mousehover
        hover=i 
        g.setColor(1,0,0,0.8) 
      end
      if ishs then --if in selection
        g.setColor(0,1,0,0.8) 
      end
      
      if ish or ishs then
        love.graphics.setLineWidth(2)
        phyDraw(v,'line')
        love.graphics.setLineWidth(1)
        g.setColor(1,1,1)
      end
      
      local ox,oy=v.body:getPosition()
      if(oy>w*2)then
        phyDestroy(v)
      end
    end
  end
  local curx,cury=mx-spawnsize/2,my-spawnsize/2
  if not hover and ctool=='sp' then
    if fig=='crc' then
      g.outlCirc(curx,cury,spawnsize)
    elseif fig=='sqr'then
      g.outlRect(curx,cury,spawnsize)
    end
  end
  ----------------------------------------------------------
  g.print('FPS:'..love.timer.getFPS()..'\nRAM:'..math.ceil(collectgarbage('count'))..'kb'..'\nF1-HELP')
  if love.keyboard.isDown('f1') then
   g.print(HELP,w/2)
   g.rectangle('line',w/2-15,0,w,135)
  end
  if warning_love2d then
    g.setColor(1,0,0)
    g.print('Warning! Incompatible LÖVE version',0,h-14)
  end
  gui.draw()
end

function love.keypressed(key)
  if key=='r' then --reload
    reset()
  end
  if key=='space' then --pause
    stop=not(stop)
  end
  
  if key=='[' then
    love.wheelmoved(0,-3)
  elseif key==']'then
    love.wheelmoved(0,3)
  end
  
  local ton=tonumber(key)
  if ton and ton<=#gui.modes then --add to weld
    gui.vclick(ton)
  end
end

function love.mousepressed(x,y,b)
  if not gui.click(x,y,b) then
    if ctool=='sp' then
      if not hover then
        local m
        if b==1 then m='d' elseif b==2 then m='s' end
        ins(objects,phyObject(world,x,y,spawnsize,spawnsize,m,fig))
      end
    elseif ctool=='sl' then
      if b==1 then
        if hover and objects[hover] then
          phyAddToGroup(selection,objects[hover],hover)
        end
      elseif b==2 then
        local tmp={}
        for i,v in ipairs(selection) do
          if not(v.i==hover) then ins(tmp,v) end
        end
        selection=tmp
      end
    elseif ctool=='dl' then
      if b==1 and phyExists(objects[hover]) then
        phyDestroy(objects[hover])
      end
    elseif ctool=='uw' then
      phyUnweldBody(objects[hover])
    end
  end
end

function love.wheelmoved(x,y)
  spawnsize=math.max(spawnsize+y*2,1)
end