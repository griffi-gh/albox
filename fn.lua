function ins(t,v)
  t[#t+1]=v
end

function pal(code)
  return pcall(assert(loadstring(code)))
end

function love.graphics.outlRect(x,y,w,h,colA,colB)
  local g=love.graphics
  colA=colA or {1,1,1,0.15}
  colB=colB or {1,1,1,1}
  h=h or w
  g.setColor(unpack(colA))
  g.rectangle('fill',x,y,w,h)
  g.setColor(unpack(colB))
  g.rectangle('line',x,y,w,h)
end

function love.graphics.outlCirc(x,y,r,colA,colB)
  local g=love.graphics
  colA=colA or {1,1,1,0.15}
  colB=colB or {1,1,1,1}
  g.setColor(unpack(colA))
  g.circle('fill',x+r/2,y+r/2,r)
  g.setColor(unpack(colB))
  g.circle('line',x+r/2,y+r/2,r)
end

function copyt(t,fast)
  local t2={}
  local inw=pairs
  if(fast)then inw=ipairs end
  for i,v in inw(t) do
    t2[i]=v
  end
  inw=nil
  return t2
end

function lrud_control(dt,S,u,d,l,r)
  u=u or 'up'
  d=d or 'down'
  l=l or 'left'
  r=r or 'right'
  local SPD=dt/(1/60)
  local kp=false
  local isd=love.keyboard.isDown
  local cx,cy=0,0
  if isd('up') then
    cy=cy-SPD*S kp=true
  end
  if isd('down') then
    cy=cy+SPD*S kp=true
  end
  if isd('left') then
    cx=cx-SPD*S kp=true
  end
  if isd('right') then
    cx=cx+SPD*S kp=true
  end
  return cx,cy,kp
end