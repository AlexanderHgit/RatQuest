pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--init
function _init()
 -- hold debug messages
 debug={}

 particles={}
 p_colors = {5,6,7,10,9,5}

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
 for part in all(particles) do
  if part.alive then
   -- color based on size
   local fraction_of_r = part.r_i / #p_colors
   local p_color = flr(part.r * fraction_of_r)+1
   circfill(
    part.x,
    part.y,
    part.r,
    p_colors[p_color]
   )
  end
 end

 if #debug > 0 then
  for i,d in pairs(debug) do
   print(d,10,10*i,7)
  end
 end

 printo("press ❎ or x to make boom", 12, 60, 7)
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