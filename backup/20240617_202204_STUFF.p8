pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--init
animatedtiles={}
pixles={}
function _init()
 -- hold debug messages
 debug={}
positions={}
 particles={}
 p_colors = {5,6,7,10,9,5}
 for f=0,8 do
add(positions,f)
 end
 for tx=0,16 do
    for ty=0,16 do
    if(mget(tx,ty)==1) then 
    add(animatedtiles,{tx,ty})
    for i=0,8 do
    pos=rnd(positions)
    del(positions,pos)
    add(pixles,{x=i+(tx*8),y=pos,vely=1,ystart=ty})
    end
    end
    end
    end
 -- seed particles to 200 
 for i=1,200 do
  add(particles, {
   x=0,
   y=0,
   velx=0,
   vely=0,
   r=0,
   r_i=0,
   alive=false
  })
 end
end
-->8
--update
function _update()


 for part in all(particles) do
  if part.alive then
   part.x += part.velx / part.mass*2
   part.y += part.vely / part.mass
   part.r -= 0.1
   if part.r < 0.1 then
    part.alive = false
   end
  end
 end
 if btnp(5) then
  explode(rnd(127),rnd(127),5,100)
 end
end
-->8
--draw
function _draw()
    cls(1)
    p=0
for i in all(pixles) do 
    p+=1
pset(p+i.x,i.y,10)
i.y+=1
if i.y > (i.ystart+8) then
    i.y=i.ystart
end
end




end
-->8
--tools
function explode(x,y,r,num_particles)
 local p_count = 0
 for part in all(particles) do
  if not part.alive then
   part.x = x
   part.y = y
   part.velx = -1 + rnd(2)
   part.vely = -1 + rnd(2)
   part.mass = 0.5 + rnd(2)
   part.r = 0.5 + rnd(r)
   part.r_i = part.r
   part.alive = true

   p_count += 1
   if p_count == num_particles then
    break
   end
  end
 end
end

function printo(str, x, y, c1, c2)
 c2 = c2 or 0
 for xo=-1,1 do
  for yo=-1,1 do
   print(str,x+xo,y+yo,c2)
  end
 end
 print(str,x,y,c1) 
end
__gfx__
00000000999999995555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999999995555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999999995555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999999995555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999999995555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999999995555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999999995555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999999995555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202010202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
