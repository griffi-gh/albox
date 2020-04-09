APPNAME='ALBOX'
VERSION='alpha 0.1'
---------------------
require'fn'
require'phy'
require'gui'

function reset()
  objects={}
  toweld={}
  welds={}
  spawnsize=25
  stop=false
  love.physics.setMeter(64)
  world = love.physics.newWorld(0,9.81*love.physics.getMeter(),true)
  ins(objects,phyObject(world,400/2+200,500,400,25))
end

function love.load(arg)
  love.window.setTitle(APPNAME..' '..VERSION)
  love.window.setMode(800,600,{msaa=3,vsync=0,resizable=true,minwidth=650,minheight=570})--fullscreentype='exclusive',fullscreen=true
  reset()
end

function love.update(dt) gc_=(gc_ or -1)+1 if gc_>120 then collectgarbage('collect') gc_=nil end
  mx,my=love.mouse.getX(),love.mouse.getY()
  m1=love.mouse.isDown(1)
  local slowmo=1;if love.keyboard.isDown('t') then slowmo=5 end;if(stop)then slowmo=math.huge end
  world:update(dt/slowmo)
  if(hover and phyExists(objects[hover]) and m1)then
    phyTeleport(objects[hover],mx,my)
    phyVCancel(objects[hover])
  end
end

function love.draw() local g=love.graphics g.setColor(1,1,1,1) love.graphics.reset()
  w,h=g.getWidth(),g.getHeight()
  hover=nil
  for i,v in ipairs(objects) do
    if phyExists(v) then
      g.polygon("fill",phyPoly(v))
      local ish=v.fixture:testPoint(mx,my)
      if ish then hover=i 
        g.setColor(1,0,0,0.8)
        love.graphics.setLineWidth(2)
        g.polygon("line",phyPoly(v))
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
  if not hover then
    g.outlRect(curx,cury,spawnsize)
  end
  g.print('FPS:'..love.timer.getFPS()..'\nRAM:'..math.ceil(collectgarbage('count'))..'kb'..'\nF1-HELP')
  if love.keyboard.isDown('f1') then
   g.print('WHEEL-Size\nLMB-SPAWN/MOVE\nRMB-SPAWN STATIC/DELETE\nSPACE-PAUSE\nT-Slowmo\nR-RESET\nW-ADD TO SELECTION\nQ-WELD SELECTED',w/2)
   g.rectangle('line',w/2-15,0,w,125)
  end
end

function love.keypressed(key)
  if key=='r' then --reload
    --love.load('reload')
    reset()
  end
  if key=='w' then --add to weld
    phyAddToGroup(toweld,objects[hover],hover)
  end
  if key=='q' then --confirm weld
    ins(welds,phyWeldGroup(toweld))
    toweld={}
  end
  if key=='u' then --unweld latest
    if(#welds>0)then
      phyUnweldGroup(welds[#welds])
      welds[#welds]=nil
    end
  end
  if key=='space' then
    stop=not(stop)
  end
end

function love.mousepressed(x,y,b)
  if not hover then
    local m
    if b==1 then m='d' elseif b==2 then m='s' end
    ins(objects,phyObject(world,x,y,spawnsize,spawnsize,m,1))
  elseif(b==2)then
    phyDestroy(objects[hover])
  end
end

function love.wheelmoved(x,y)
  spawnsize=math.max(spawnsize+y*2,1)
end