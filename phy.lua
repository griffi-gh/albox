
function phyObject(wrl,x,y,w,h,t,m)
  m=m or 1
  if(t=='d')then t='dynamic' elseif(t=='k') then t='kinematic' elseif(t=='s') then t='static' end
  local body = love.physics.newBody(wrl,x,y,t)
  local shape = love.physics.newRectangleShape(w,h)
  local fixture = love.physics.newFixture(body,shape,m)
  return{body=body,shape=shape,fixture=fixture,exists=true}
end

function phyReq(obj,part)
  if type(obj)=='userdata' then 
    return obj 
  elseif type(obj)=='table' then 
    return obj[part]
  end
end

function phyTeleport(obj,x,y)
  local bdy2=phyReq(obj,'body')
  bdy2:setPosition(x,y)
  phyVCancel(obj)
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
  return v.body:getWorldPoints(v.shape:getPoints())
end

function phyWeld(o1,o2,noCollide)
  local bdy2=phyReq(obj,'body')
  return love.physics.newWeldJoint(o1.body,o2.body,o1.body:getX(),o1.body:getY(),not(noCollide))
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

function phyWeldGroup(toweld,noCollide)
  local con={}
  if(#toweld>1)then
    for i,v in ipairs(toweld) do
      if i~=1 then
        local wa,wb=toweld[1],v
        con[#con+1]=phyWeld(wa.o,wb.o,noCollide)
      end
    end
  end
  return con
end

--[[
function phyDestroyGroup(group)
  for i,v in ipairs(group) do
    phyDestroy(v.o)
  end
end
]]

function phyUnweldGroup(con)
  if con and type(con)=='table' then
    for i,v in ipairs(con) do 
      v:destroy()
    end
  end
end

function phyExists(v)
  return v and v.exists and v.body and v.fixture and v.shape
end