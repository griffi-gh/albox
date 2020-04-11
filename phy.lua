
--local va={}

function phyObject(wrl,x,y,w,h,t,s,m)
  m=m or 1
  s=s or 'sqr'
  if(t=='d')then t='dynamic' elseif(t=='k') then t='kinematic' elseif(t=='s') then t='static' end
  local body = love.physics.newBody(wrl,x,y,t)
  local shape
  if(s=='crc')then
    shape = love.physics.newCircleShape(w or h)
  elseif(s=='sqr')then
    shape = love.physics.newRectangleShape(w,h)
  end
  local fixture = love.physics.newFixture(body,shape,m)
  return{body=body,shape=shape,fixture=fixture,type=s,exists=true}
end

function phyReq(obj,part)
  if type(obj)=='userdata' then 
    return obj 
  elseif type(obj)=='table' then 
    return obj[part]
  end
end

function phyTeleport(obj,x,y,novc)
  local bdy2=phyReq(obj,'body')
  bdy2:setPosition(x,y)
  if not novc then
    phyVCancel(obj)
  end
end

function phyPushGroup(gr,x,y,novc) --GR2 IS XYMAP
  for i,v in ipairs(gr) do
    if phyExists(v.o) then
      local absx,absy=v.o.body:getX(),v.o.body:getY()
      phyTeleport(v.o,x+absx,y+absy,novc)
    end
  end
end

function phyGroup2xymap(gr)
  local xym={}
  local copied=copyt(gr,true)
  for i,v in ipairs(copied) do
    xym[i]={x=v.o.body:getX(),y=v.o.body:getY(),i=v.i}
  end
  return xym
end

function phyFix(obja)
  local fa=0.1
  for i,v in ipairs(obja) do
    local body=phyReq(v,'body')
    if phyExists(v) and body then
      body:applyForce(0,fa)
    end
  end
end

function phyVCancel(obj)
  local function cancel(obj)
    obj:setAngularVelocity(0)
    obj:setLinearVelocity(0,0.1)
  end
  local body=phyReq(obj,'body')
  cancel(body)
  local joints=body:getJoints()
  for i,v in ipairs(joints)do
    local bA,bB=v:getBodies()
    cancel(bA)
    cancel(bB)
  end
end

function phyPoly(v)
  local b = phyReq(v,'body')
  return b:getWorldPoints(v.shape:getPoints())
end

function phyCirc(v)
  local b,b2 = phyReq(v,'shape'),phyReq(v,'body')
  return b2:getX(),b2:getY(),b:getRadius()
end


function phyDraw(v,style)
  local style=style or "fill"
  local g=love.graphics 
  if phyExists(v) then
    if(v.type=='sqr')then
      g.polygon(style,phyPoly(v))
    elseif(v.type=='crc')then
      g.circle(style,phyCirc(v))
    end
  end
end

function phyWeld(o1o,o2o,noCollide)
  local o1,o2=phyReq(o1o,'body'),phyReq(o2o,'body')
  if o1 and o2 then
    return love.physics.newWeldJoint(o1,o2,o1:getX(),o1:getY(),not(noCollide))
  end
end

function phyDestroy(o)
  local function delete(obj)
    obj.body:destroy()
    obj.body=nil
    obj={}
    return obj
  end
  o=delete(o)
end

function phyAddToGroup(group,o,oid,allowDubl,allowNil)
  local safe=true
  if not allowDubl then
    for i,v in ipairs(group) do
      if(v.i)==oid then safe=false end
    end
  end
  if not allowNil then
    if not(o) or not(oid) then safe=false end
  end
  if safe then
    group[#group+1]={i=oid,o=o}
  end
end

function phyWeldGroup(toweld,noCollide,weldto1)
  local con={}
  if(#toweld>1)then
    for i,v in ipairs(toweld) do
      if i~=1 then
        local wa,wb=toweld[i-1],toweld[i]
        if(weldto1)then wa=toweld[1] end
        con[#con+1]=phyWeld(wa.o,wb.o,noCollide)
      end
    end
  end
  return con
end


function phyDestroyGroup(group) --tested
  for i,v in ipairs(group) do
    phyDestroy(v.o)
  end
end

function phyUnweldGroup(con)
  local function unweld(con)
    if con and type(con)=='table' then
      for i,v in ipairs(con) do
        if v then
          v:destroy()
        end
      end
    end
  end
  if not(pcall(unweld,con)) then
    print('error (unable to unweld)')
  end
end

function phyExists(v)
  return v and v.exists and v.body and v.fixture and v.shape
end

function phyUnweldBody(body2)
  body=phyReq(body2,'body')
  if body then
    local joints=body:getJoints()
    for i,v in ipairs(joints) do
      v:destroy()
    end
  end
end

function phyUnweldGroup2(group)
  for i,v in ipairs(group) do
    phyUnweldBody(v.o.body)
  end
end