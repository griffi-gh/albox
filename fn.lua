function ins(t,v)
  t[#t+1]=v
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
