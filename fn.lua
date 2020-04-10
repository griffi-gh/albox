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
