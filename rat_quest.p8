pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
function _init()
 debug={}

 particles={}
 p_colors = {5,6,7,10,9,5}
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
 t=0
 shake=0
 saved_map={}
 dpal=explodeval("0,1,1,2,1,13,6,4,4,9,3,13,1,13,14")
 
 dirx=explodeval("-1,1,0,0,1,1,-1,-1")
 diry=explodeval("0,0,-1,1,-1,1,1,-1")
 
 itm_name=explode("butter knife,cheese knife,paring knife,utility knife,chef's knife,meat cleaver,paper apron,cotton apron,rubber apron,leather apron,chef's apron,butcher's apron,food 1,food 2,food 3,food 4,food 5,food 6,spork,salad fork,fish fork,dinner fork")
 itm_type=explode("wep,wep,wep,wep,wep,wep,arm,arm,arm,arm,arm,arm,fud,fud,fud,fud,fud,fud,thr,thr,thr,thr")
 itm_stat1=explodeval("1,2,3,4,5,6,0,0,0,0,1,2,1,2,3,4,5,6,1,2,3,4")
 itm_stat2=explodeval("0,0,0,0,0,0,1,2,3,4,3,3,0,0,0,0,0,0,0,0,0,0")
 itm_minf=explodeval("1,2,3,4,5,6,1,2,3,4,5,6,1,1,1,1,1,1,1,2,3,4")
 itm_maxf=explodeval("3,4,5,6,7,8,3,4,5,6,7,8,8,8,8,8,8,8,4,6,7,8")
 itm_desc=explode(",,,,,,,,,,,, heals, heals a lot, increases hp, stuns, is cursed, is blessed,,,,")

 mob_name=explode("player,slime,melt,shoggoth,mantis-man,giant scorpion,ghost,golem,drake")
 mob_ani=explodeval("240,192,196,200,204,208,212,216,220")
 mob_atk=explodeval("1,1,2,1,2,3,3,5,5")
 mob_push=explodeval("3,0,2,1,2,3,3,5,5")

 mob_hp=explodeval("90,20,2,3,3,4,5,14,8")
 mob_los=explodeval("4,4,4,4,4,4,4,4,4")
 mob_minf=explodeval("0,1,2,3,4,5,6,7,8")
 mob_maxf=explodeval("0,3,4,5,6,7,8,8,8")
 mob_spec=explode(",,,spawn?,fast?,stun,ghost,slow,")
 
 crv_sig=explodeval("255,214,124,179,233")
 crv_msk=explodeval("0,9,3,12,6")

 free_sig=explodeval("0,0,0,0,16,64,32,128,161,104,84,146")
 free_msk=explodeval("8,4,2,1,6,12,9,3,10,5,10,5")

 wall_sig=explodeval("251,233,253,84,146,80,16,144,112,208,241,248,210,177,225,120,179,0,124,104,161,64,240,128,224,176,242,244,116,232,178,212,247,214,254,192,48,96,32,160,245,250,243,249,246,252")
 wall_msk=explodeval("0,6,0,11,13,11,15,13,3,9,0,0,9,12,6,3,12,15,3,7,14,15,0,15,6,12,0,0,3,6,12,9,0,9,0,15,15,7,15,14,0,0,0,0,0,0")

 debug={}
 startgame()
end

function _update60()
 t+=1

 _upd()
 dofloats()
 dohpwind()
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
end

function _draw()
  
 doshake()
 _drw()
 drawind()
 drawlogo()
 --fadeperc=0
 checkfade()
 --★
 cursor(4,4)
 color(8)
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
 for txt in all(debug) do
  print(txt)
 end
end

function startgame(relod)
 poke(0x3101,194)
 music(0)
 tani=0
 fadeperc=1
 buttbuff=-1

 logo_t=240
 logo_y=35
 
 skipai=false
 win=false
 winfloor=9
 --★
 mob={}
 dmob={}
 p_mob=addmob(1,1,1)
 
 p_t=0
 
 inv,eqp={},{}

 foodnames()
 takeitem(19)
 takeitem(19)
 takeitem(19)
 takeitem(19)
 takeitem(19)
 
 wind={}
 float={}

 talkwind=nil
 
 hpwind=addwind(5,5,28,13,{})

 fog=blankmap(1)
 floor=0
 floorx=0
 floory=0
 
-- makeipool()
 -- makefipool()
 thrdx,thrdy=0,-1
 
 _upd=update_game
 _drw=draw_game
 
 st_steps,st_kills,st_meals,st_killer=0,0,0,""
 copymap(0,0,relod)
--genfloor(0)
 
end
-->8
--updates
function update_game()
 if talkwind then
  if getbutt()==5 then
   sfx(53)
   talkwind.dur=0
   talkwind=nil
  end
 else
  dobuttbuff()
  dobutt(buttbuff)
  buttbuff=-1
 end
end

function update_inv()
 --inventory
 if move_mnu(curwind) and curwind==invwind then
  showhint()
 end
 if btnp(4) then
  sfx(53)
  if curwind==invwind then
   _upd=update_game
   invwind.dur=0
   statwind.dur=0
   if hintwind then
    hintwind.dur=0
   end
  --★
  elseif curwind==usewind then
   usewind.dur=0
   curwind=invwind
  end
 elseif btnp(5) then
  sfx(54)
  if curwind==invwind and invwind.cur!=3 then
   showuse()
   --★
  elseif curwind==usewind then
   -- use window confirm 
   triguse() 
  end
 end
end

function update_throw()
 local b=getbutt()
 if b>=0 and  b<=3 then
  thrdx=dirx[b+1]
  thrdy=diry[b+1]
 end
 if b==4 then
  _upd=update_game
 elseif b==5 then
  throw()
 end
end

function move_mnu(wnd)
 local moved=false
 if btnp(2) then
  sfx(56)
  wnd.cur-=1
  moved=true
 elseif btnp(3) then
  sfx(56)
  wnd.cur+=1
  moved=true
 end
 wnd.cur=(wnd.cur-1)%#wnd.txt+1
 return moved
end


function update_pturn()
 dobuttbuff()
 p_t=min(p_t+0.125,1)
 
 if p_mob.mov then
  p_mob:mov()
 end
 
 if p_t==1 then
  _upd=update_game
  if trig_step() then return end

  if checkend() and not skipai then
   doai()
  end
  skipai=false
 end
end

function update_aiturn()
 dobuttbuff()
 p_t=min(p_t+0.125,1)
 for m in all(mob) do
  if m!=p_mob and m.mov then
   m:mov()
  end
 end
 if p_t==1 then
  _upd=update_game
  if checkend() then
   if p_mob.stun then
    p_mob.stun=false
    doai()
   end
  end
 end
end

function update_gover()
 if btnp(❎) then
  sfx(54)
  fadeout()
  startgame(true)
 end
end

function dobuttbuff()
 if buttbuff==-1 then
  buttbuff=getbutt()
 end
end

function getbutt()
 for i=0,5 do
  if btnp(i) then
   return i
  end
 end
 return -1
end

function dobutt(butt)
 if butt<0 then return end
 if logo_t>0 then logo_t=0 end
 if butt<4 then
  moveplayer(dirx[butt+1],diry[butt+1])
 elseif butt==5 then
  showinv()
  sfx(54)
-- elseif butt==4 then
  --win=true
  --p_mob.hp=0
  --st_killer="slime"
  --genfloor(floor+1)
  --prettywalls()
 end
end
-->8
--draws
function draw_game()
 cls(0)
 if fadeperc==1 then return end
 animap()
 map()
 for m in all(dmob) do
  if sin(time()*8)>0 or m==p_mob then
   drawmob(m)
  end
  m.dur-=1
  if m.dur<=0 and m!=p_mob then
   del(dmob,m)
  end
 end
 
 for i=#mob,1,-1 do
  drawmob(mob[i])
 end
 
 if _upd==update_throw then
  --★
  local tx,ty=throwtile()
  local lx1,ly1=p_mob.x*8+3+thrdx*4,p_mob.y*8+3+thrdy*4
  local lx2,ly2=mid(0,tx*8+3,127),mid(0,ty*8+3,127)
  rectfill(lx1+thrdy,ly1+thrdx,lx2-thrdy,ly2-thrdx,0)
  
  local thrani,mb=flr(t/7)%2==0,getmob(tx,ty)
  if thrani then
   fillp(0b1010010110100101)
  else
   fillp(0b0101101001011010)
  end
  line(lx1,ly1,lx2,ly2,7)
  fillp()
  oprint8("+",lx2-1,ly2-2,7,0)
  
  if mb and thrani then
   mb.flash=1
  end
 end 
 
 for x=0,15 do
  for y=0,15 do
   if fog[x][y]==1 then
    rectfill2(x*8,y*8,8,8,0)
   end
  end
 end
  
 for f in all(float) do
  oprint8(f.txt,f.x,f.y,f.c,0)
 end

end

function drawlogo()
 if logo_y>-24 then
  logo_t-=1
  if logo_t<=0 then
   logo_y+=logo_t/20
  end

  oprint8("rat quest >:)",19,logo_y+20,7,0)
 end
end

function drawmob(m)
 local col=10
 if m.flash>0 then
  m.flash-=1
  col=7
 end
 drawspr(getframe(m.ani),m.x*8+m.ox,m.y*8+m.oy,col,m.flp)
end

--[[function draw_gover()
 cls(2)
 print("y ded",50,50,7)
end

function draw_win()
 cls(2)
 print("u win",50,50,7)
end]]--

function draw_gover()
 cls()
 palt(12,true)
 spr(gover_spr,gover_x,30,gover_w,2)
 if not win then
  print("killed by a "..st_killer,28,43,6)
 end
 palt()
 color(5)
 cursor(40,56)
 if not win then
  print("floor: "..floor)
 end
 print("steps: "..st_steps)
 print("kills: "..st_kills)
 print("meals: "..st_meals) 

 print("press ❎",46,90,5+abs(sin(time()/3)*2))
end

function animap()
 tani+=1
 if (tani<15) return
 tani=0
 for x=0,15 do
  for y=0,15 do
   local tle=mget(x,y)
   if tle==64 or tle==66 then
    tle+=1
   elseif tle==65 or tle==67 then
    tle-=1
   end
   mset(x,y,tle)
  end
 end
end

-->8
--tools

function getframe(ani)
 return ani[flr(t/15)%#ani+1]
end

function drawspr(_spr,_x,_y,_c,_flip)
 palt(0,false)
 pal(6,_c)
 spr(_spr,_x,_y,1,1,_flip)
 pal()
end

function rectfill2(_x,_y,_w,_h,_c)
 --★
 rectfill(_x,_y,_x+max(_w-1,0),_y+max(_h-1,0),_c)
end

function oprint8(_t,_x,_y,_c,_c2)
 for i=1,8 do
  print(_t,_x+dirx[i],_y+diry[i],_c2)
 end 
 print(_t,_x,_y,_c)
end

function dist(fx,fy,tx,ty)
 local dx,dy=fx-tx,fy-ty
 return sqrt(dx*dx+dy*dy)
end
function explodeEffect(x,y,r,num_particles)
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
 
function dofade()
 local p,kmax,col,k=flr(mid(0,fadeperc,1)*100)
 for j=1,15 do
  col = j
  kmax=flr((p+j*1.46)/22)
  for k=1,kmax do
   col=dpal[col]
  end
  pal(j,col,1)
 end
end

function checkfade()
 if fadeperc>0 then
  fadeperc=max(fadeperc-0.04,0)
  dofade()
 end
end

function wait(_wait)
 repeat
  _wait-=1
  flip()
 until _wait<0
end

function fadeout(spd,_wait)
 if (spd==nil) spd=0.04
 if (_wait==nil) _wait=0
 repeat
  fadeperc=min(fadeperc+spd,1)
  dofade()
  flip()
 until fadeperc==1
 wait(_wait)
end

function blankmap(_dflt)
 local ret={} 
 if (_dflt==nil) _dflt=0
 
 for x=0,15 do
  ret[x]={}
  for y=0,15 do
   ret[x][y]=_dflt
  end
 end
 return ret
end

function getrnd(arr)
 return arr[1+flr(rnd(#arr))]
end



function copymap(x,y,relod)
if relod == nil then
relod = false
end
 local tle
 if relod then 
  for _x=0,15 do
  for _y=0,15 do
  mset(_x,_y,saved_map[_x][_y])
  end
  end
  
 end
 saved_map={{}}
 for _x=0,15 do
 saved_map[_x]={}
  for _y=0,15 do
   tle=mget(_x+x,_y+y)
   mset(_x,_y,tle)
  saved_map[_x][_y]=mget(_x+x,_y+y)


   if tle==15 then
    p_mob.x,p_mob.y=_x,_y
   end
   for i= 0,9 do
   if mob_ani[i]==mget(_x,_y)then
   addmob(i,_x,_y)
   mset(_x,_y,1)
   end
			end
  end
 end
 
end

function explode(s)
 local retval,lastpos={},1
 for i=1,#s do
  if sub(s,i,i)=="," then
   add(retval,sub(s, lastpos, i-1))
   i+=1
   lastpos=i
  end
 end
 add(retval,sub(s,lastpos,#s))
 return retval
end

function explodeval(_arr)
 return toval(explode(_arr))
end

function toval(_arr)
 local _retarr={}
 for _i in all(_arr) do
  add(_retarr,flr(tonum(_i)))
 end
 return _retarr
end

function doshake()
 local shakex,shakey=16-rnd(32),16-rnd(32)
 camera(shakex*shake,shakey*shake)
 shake*=0.95
 if (shake<0.05) shake=0
end
-->8
--gameplay

function moveplayer(dx,dy)
 local destx,desty=p_mob.x+dx,p_mob.y+dy
 local tle=mget(destx,desty)
  
 if iswalkable(destx,desty,"checkmobs") then

  --sfx(63)
  mobwalk(p_mob,dx,dy)
  st_steps+=1
  p_t=0
  _upd=update_pturn
 else
  --not walkable
  mobbump(p_mob,dx,dy)
  p_t=0
  _upd=update_pturn
  
  local mob=getmob(destx,desty)
  if mob then
   sfx(58)
   hitmob(p_mob.x,p_mob.y,mob,p_mob.atk,p_mob.push)
  else
   if fget(tle,1) then
    trig_bump(tle,destx,desty)
   else
    skipai=true
    --mset(destx,desty,1)
   end
  end
 end
 unfog()
end

function trig_bump(tle,destx,desty)
  printh(destx..","..desty,"debugs.txt",4)
 if tle==7 or tle==8 then
  --vase
  sfx(59)
  mset(destx,desty,76)
  if rnd(3)<1  then
   if rnd(5)<1 then
   showmsg("im gonna fucking kill you",120)
   -- addmob(getrnd(mobpool),destx,desty)
    sfx(60)
   else
    if freeinvslot()==0 then
     showmsg("inventory full",120)
     sfx(60)
    else
     sfx(61)
     local itm=flr(rnd(#itm_name))+1
     takeitem(itm)
     showmsg(itm_name[itm].."!",60)
    end
   end
  end
 elseif tle==10 or tle==12 then
  --chest
  if freeinvslot()==0 then
   showmsg("inventory full",120)
   skipai=true
   sfx(60)
  else
   local itm=flr(rnd(#itm_name))+1
   if tle==12 then
    itm=flr(rnd(#itm_name))  +1
   end
   sfx(61)
   mset(destx,desty,tle-1)
   takeitem(itm)
  showmsg(itm_name[itm].."!",60)
  end
 elseif tle==13 then
  --door
  sfx(62)
  mset(destx,desty,1)
 elseif tle==6 then
  --stone tablet
  if floor==0 then
   sfx(54)
   showtalk(explode(" yo "))
  end
 elseif tle==110 then
  --kielbasa
  win=true
 end
 --BOMB
 if tle==112 then
  closemobs={}
  for i=1,4 do
    local dx,dy=dirx[i],diry[i]
    local tx,ty=destx+dx,desty+dy
    if(getmob(tx,ty)) then
      add(closemobs,getmob(tx,ty))
    end
  end
  for y in all(closemobs) do
    hitmob(destx,desty,y,2,2)
  end
  explodeEffect(destx*8,desty*8,5,100)
  mset(destx,desty,1)
  
 end
end

function trig_step()
 local tle=mget(p_mob.x,p_mob.y)

 if tle==14 then
  sfx(55)
  p_mob.bless=0
  fadeout()
  genfloor(floor+1)
  floormsg()
  return true
 end
 return false
end

function getmob(x,y)
 for m in all(mob) do
  if m.x==x and m.y==y then
   return m
  end
 end
 return false
end

function iswalkable(x,y,mode)
 local mode = mode or "test"
 
 --sight
 if inbounds(x,y) then
  local tle=mget(x,y)
  if mode=="checkspike" then 
  return not fget(tle,1)
  end
  if mode=="sight" then
   return not fget(tle,2)
  else
   if not fget(tle,0) then
    if mode=="checkmobs" then
     return not getmob(x,y)
    end
    return true
   end

  end
 end
 return false
end

function inbounds(x,y)
 return not (x<0 or y<0 or x>15 or y>15)
end

function hitmob(atkx,atky,defm,dmg,push)


 
 --add curse/bless
 if defm.bless<0 then
  dmg*=2
 elseif defm.bless>0 then
  dmg=flr(dmg/2)
 end
 defm.bless=0
 
 local def=defm.defmin+flr(rnd(defm.defmax-defm.defmin+1))
 dmg-=min(def,dmg)
 --dmg=max(0,dmg)
 
 defm.hp-=dmg
 defm.flash=10
 
 addfloat("-"..dmg,defm.x*8,defm.y*8,9)
 
 shake=defm==p_mob and 0.08 or 0.04
 if push != 0 then
  pushmob(atkx,atky,defm,push)
   end
 if defm.hp<=0 then
  if defm!=p_mob then 
   st_kills+=1 
  else 
  if atkm !=  nil then
   st_killer=atkm.name
   else
   st_killer="who even knows man"
   end
  end

  add(dmob,defm)
  del(mob,defm)
  defm.dur=10
 end
end
function tile_effect(_x,_y,mob)

if mget(_x,_y) == 80 then
hitmob(_x,_y,mob,1,0)
else
mob.last_safe={lx=mob.x,ly=mob.y}

end


end
--[[ function pushmob(atkx,atky,defm,dist)

for i =0,dist-1	do

	if atkx == defm.x and atky < defm.y and iswalkable(defm.x,defm.y+1) then
		defm.y+=1
	end

	if atkx == defm.x and atky > defm.y and iswalkable(defm.x,defm.y-1) then
		defm.y-=1
	end

	if atky== defm.y and atkx < defm.x and iswalkable(defm.x+1,defm.y) then
		defm.x+=1
	end

	if atky== defm.y and atkx  >defm.x  and iswalkable(defm.x-1,defm.y) then
		defm.x-=1
	end
	tile_effect(defm.x,defm.y,defm)
	end
end ]]
function healmob(mb,hp)
 hp=min(mb.hpmax-mb.hp,hp)
 mb.hp+=hp
 mb.flash=10
 
 addfloat("+"..hp,mb.x*8,mb.y*8,7)
 sfx(51)
end

function stunmob(mb)
 mb.stun=true
 mb.flash=10
 addfloat("stun",mb.x*8-3,mb.y*8,7)
 sfx(51)
end

function blessmob(mb,val)
 mb.bless=mid(-1,1,mb.bless+val)
 mb.flash=10
 
 local txt="bless"
 if val<0 then txt="curse" end
 
 addfloat(txt,mb.x*8-6,mb.y*8,7)
 
 if mb.spec=="ghost" and val>0 then
  add(dmob,mb)
  del(mob,mb)
  mb.dur=10 
 end
 sfx(51)
end

function checkend()
 if win then
  music(24)
  gover_spr,gover_x,gover_w=112,15,13
  showgover()
  return false
 elseif p_mob.hp<=0 then
  music(22)  
  gover_spr,gover_x,gover_w=80,28,9
  showgover()
  return false
 end
 return true
end

function showgover()
 wind,_upd,_drw={},update_gover,draw_gover
 fadeout(0.02)
end

--line of sight
function los(x1,y1,x2,y2)
 local frst,sx,sy,dx,dy=true
 --★
 if dist(x1,y1,x2,y2)==1 then return true end
 if y1>y2 then
  x1,x2,y1,y2=x2,x1,y2,y1
 end
 sy,dy=1,y2-y1

 if x1<x2 then
  sx,dx=1,x2-x1
 else
  sx,dx=-1,x1-x2
 end
 
 local err,e2=dx-dy
 
 while not(x1==x2 and y1==y2) do
  if not frst and iswalkable(x1,y1,"sight")==false then return false end
  e2,frst=err+err,false
  if e2>-dy then
   err-=dy
   x1+=sx
  end
  if e2<dx then 
   err+=dx
   y1+=sy
  end
 end
 return true 
end

function unfog()
 local px,py=p_mob.x,p_mob.y
 for x=0,15 do
  for y=0,15 do 
   --★
   if fog[x][y]==1 and dist(px,py,x,y)<=p_mob.los and los(px,py,x,y) then
    unfogtile(x,y)
   end
  end
 end
end

function unfogtile(x,y)
 fog[x][y]=0
 if iswalkable(x,y,"sight") then
  for i=1,4 do
   local tx,ty=x+dirx[i],y+diry[i]
   if inbounds(tx,ty) and not iswalkable(tx,ty) then
    fog[tx][ty]=0
   end
  end  
 end
end

function calcdist(tx,ty)
 local cand,step,candnew={},0
 distmap=blankmap(-1)
 add(cand,{x=tx,y=ty})
 distmap[tx][ty]=0
 repeat
  step+=1
  candnew={} 
  for c in all(cand) do
   for d=1,4 do
    local dx=c.x+dirx[d]
    local dy=c.y+diry[d]
    if inbounds(dx,dy) and distmap[dx][dy]==-1 then
     distmap[dx][dy]=step
     if iswalkable(dx,dy) then
      add(candnew,{x=dx,y=dy})
     end
    end
   end
  end
  cand=candnew
 until #cand==0
end

function updatestats()
 local atk,dmin,dmax=1,0,0
 
 if eqp[1] then
  atk+=itm_stat1[eqp[1]]
 end
 
 if eqp[2] then
  dmin+=itm_stat1[eqp[2]]
  dmax+=itm_stat2[eqp[2]]
 end

 p_mob.atk=atk
 p_mob.defmin=dmin
 p_mob.defmax=dmax 
end

function eat(itm,mb)
 local effect=itm_stat1[itm]
 
 if not itm_known[itm] then
  showmsg(itm_name[itm]..itm_desc[itm],120)
  itm_known[itm]=true
 end  
 
 if mb==p_mob then st_meals+=1 end
 
 if effect==1 then
  --heal
  healmob(mb,1)
 elseif effect==2 then
  --heal a lot
  healmob(mb,3)
 elseif effect==3 then
  --plus maxhp
  mb.hpmax+=1
  healmob(mb,1)
 elseif effect==4 then
  --stun
  stunmob(mb)
 elseif effect==5 then
  --curse
  blessmob(mb,-1)
 elseif effect==6 then  
  --bless
  blessmob(mb,1)
 end
end

function throw()
 local itm,tx,ty=inv[thrslt],throwtile()
 sfx(52)
 if inbounds(tx,ty) then
  trig_bump(mget(tx,ty),tx,ty)
  local mb=getmob(tx,ty)
  if mb then
   if itm_type[itm]=="fud" then
    eat(itm,mb)
   else
    hitmob(p_mob.x,p_mob.y,mb,itm_stat1[itm],-2)
    sfx(58)
   end
  end
 end
 mobbump(p_mob,thrdx,thrdy)
 
 inv[thrslt]=nil
 p_t=0
 _upd=update_pturn
end

function throwtile()
 local tx,ty=p_mob.x,p_mob.y
 repeat
  tx+=thrdx
  ty+=thrdy
 until not iswalkable(tx,ty,"checkmobs")
 return tx,ty
end
-->8
--ui

function addwind(_x,_y,_w,_h,_txt)
 local w={x=_x,
          y=_y,
          w=_w,
          h=_h,
          txt=_txt}
 add(wind,w)
 return w
end

function drawind()
 for w in all(wind) do
  local wx,wy,ww,wh=w.x,w.y,w.w,w.h
  rectfill2(wx,wy,ww,wh,0)
  rect(wx+1,wy+1,wx+ww-2,wy+wh-2,6)
  wx+=4
  wy+=4
  clip(wx,wy,ww-8,wh-8)
  if w.cur then
   wx+=6
  end
  for i=1,#w.txt do
   local txt,c=w.txt[i],6
   if w.col and w.col[i] then
    c=w.col[i]
   end
   print(txt,wx,wy,c)
   if i==w.cur then
    spr(255,wx-5+sin(time()),wy)
   end
   wy+=6
  end
  clip()
 
  if w.dur then
   w.dur-=1
   if w.dur<=0 then
    local dif=w.h/4
    w.y+=dif/2
    w.h-=dif
    if w.h<3 then
     del(wind,w)
    end
   end
  else
   if w.butt then
    oprint8("❎",wx+ww-15,wy-1+sin(time()),6,0)
   end
  end
 end
end

function showmsg(txt,dur)
 local wid=(#txt+2)*4+7
 local w=addwind(63-wid/2,50,wid,13,{" "..txt})
 w.dur=dur
end

function showtalk(txt)
 talkwind=addwind(16,50,94,#txt*6+7,txt)
 talkwind.butt=true
end

function addfloat(_txt,_x,_y,_c)
 add(float,{txt=_txt,x=_x,y=_y,c=_c,ty=_y-10,t=0})
end

function dofloats()
 for f in all(float) do
  f.y+=(f.ty-f.y)/10
  f.t+=1
  if f.t>70 then
   del(float,f)
  end
 end
end

function dohpwind()
 hpwind.txt[1]="♥"..p_mob.hp.."/"..p_mob.hpmax
 local hpy=5
 if p_mob.y<8 then
  hpy=110
 end
 hpwind.y+=(hpy-hpwind.y)/5
end

function showinv()
local window_width=115
 local txt,col,itm,eqt={},{}
 _upd=update_inv
 for i=1,2 do
  itm=eqp[i]
  if itm then
   eqt=itm_name[itm]
   add(col,6)
  else
   eqt= i==1 and "[weapon]" or "[armor]"
   add(col,5)
  end
  add(txt,eqt)
 end
 add(txt,"……………………")
 add(col,6)
 for i=1,6 do
  itm=inv[i]
  if itm then
   add(txt,itm_name[itm])
   add(col,6)
  else
   add(txt,"...")
   add(col,5)
  end
 end
 

 invwind=addwind(5,17,window_width,62,txt)
 invwind.cur=3
 invwind.col=col

 txt="ok    "
 if p_mob.bless<0 then
  txt="curse "
 elseif p_mob.bless>0 then
  txt="bless "
 end
   
 statwind=addwind(5,5,window_width,13,{txt.."atk:"..p_mob.atk.." push:"..p_mob.push.." def:"..p_mob.defmin.."-"..p_mob.defmax})
 
 curwind=invwind
end

function showuse()
 local itm=invwind.cur<3 and eqp[invwind.cur] or inv[invwind.cur-3]
 if itm==nil then return end
 local typ,txt=itm_type[itm],{}
 
 if (typ=="wep" or typ=="arm") and invwind.cur>3 then
  add(txt,"equip")
 end
 if typ=="fud" then
  add(txt,"eat")
 end
 if typ=="thr" or typ=="fud" then
  add(txt,"throw")
 end
 add(txt,"trash")

 usewind=addwind(84,invwind.cur*6+11,36,7+#txt*6,txt)
 usewind.cur=1
 curwind=usewind 
end

function triguse()
 local verb,i,back=usewind.txt[usewind.cur],invwind.cur,true
 local itm=i<3 and eqp[i] or inv[i-3]
 
 if verb=="trash" then
  if i<3 then
   eqp[i]=nil
  else
   inv[i-3]=nil
  end
 elseif verb=="equip" then
  local slot=2
  if itm_type[itm]=="wep" then
   slot=1
  end
  inv[i-3]=eqp[slot]
  eqp[slot]=itm
 elseif verb=="eat" then
  eat(itm,p_mob)
  _upd,inv[i-3],p_mob.mov,p_t,back=update_pturn,nil,nil,0,false
 elseif verb=="throw" then
  _upd,thrslt,back=update_throw,i-3,false
 end
 
 updatestats()
 usewind.dur=0
 
 if back then
  del(wind,invwind)
  del(wind,statwind)
  showinv()
  invwind.cur=i
  showhint()
 else
  invwind.dur=0
  statwind.dur=0
  if hintwind then
   hintwind.dur=0
  end
 end
end

function floormsg()
 if floor==1 then 
 showmsg("floor "..floor,120)
else
 showmsg(":) rat "..floor,120)
end

end

function showhint()
 if hintwind then
  hintwind.dur=0
  hintwind=nil
 end
 
 if invwind.cur>3 then
  local itm=inv[invwind.cur-3]
  
  if itm and itm_type[itm]=="fud" then
   local txt=itm_known[itm] and itm_name[itm]..itm_desc[itm] or "???"
   hintwind=addwind(5,78,#txt*4+7,13,{txt})
  end
 
 end
 
end
-->8
--mobs and items

function addmob(typ,mx,my)
 local m={
  x=mx,
  y=my,
  ox=0,
  oy=0,
  flp=false,
  ani={},
  flash=0,
  stun=false,
  pushed=false,
  bless=0,
  charge=1,
  lastmoved=false,
  last_safe={lx=mx,ly=my},
  spec=mob_spec[typ],
  hp=mob_hp[typ],
  hpmax=mob_hp[typ],
  atk=mob_atk[typ],
  push=mob_push[typ],
  defmin=0,
  defmax=0,
  los=mob_los[typ],
  task=ai_wait,
  name=mob_name[typ],

 }
 for i=0,3 do
  add(m.ani,mob_ani[typ]+i)
 end
 add(mob,m)
 return m
end

function mobwalk(mb,dx,dy)
 mb.x+=dx --?
 mb.y+=dy
tile_effect(mb.x,mb.y,mb)
 mobflip(mb,dx)
 mb.sox,mb.soy=-dx*8,-dy*8
 mb.ox,mb.oy=mb.sox,mb.soy
 
 mb.mov=mov_walk
end

function mobbump(mb,dx,dy)
 mobflip(mb,dx)
 mb.sox,mb.soy=dx*8,dy*8
 mb.ox,mb.oy=0,0
 mb.mov=mov_bump
end

function mobflip(mb,dx)
 mb.flp = dx==0 and mb.flp or dx<0

end


function mov_walk(self)
 local tme=1-p_t 
 self.ox=self.sox*tme
 self.oy=self.soy*tme
end

function mov_bump(self)
 --★ 
 local tme= p_t>0.5 and 1-p_t or p_t
 self.ox=self.sox*tme
 self.oy=self.soy*tme
end

function doai()
 local moving=false
 for m in all(mob) do
  if m!=p_mob then
   m.mov=nil
   if m.stun then
    m.stun=false
   else
    m.lastmoved=m.task(m)
    moving=m.lastmoved or moving
   end
  end
 end
 if moving then
  _upd=update_aiturn
  p_t=0
 else
  p_mob.stun=false
 end
end

function ai_wait(m)
 if cansee(m,p_mob) then
  --aggro
  m.task=ai_attac
  m.tx,m.ty=p_mob.x,p_mob.y
  addfloat("!",m.x*8+2,m.y*8,10)
 end
 return false
end

function ai_attac(m)  
 if dist(m.x,m.y,p_mob.x,p_mob.y)==1 then
  --begin attack player
  local dx,dy=p_mob.x-m.x,p_mob.y-m.y
  mobbump(m,dx,dy)
  if m.spec=="stun" and m.charge>0 then
   stunmob(p_mob)
   m.charge-=1
  elseif m.spec=="ghost" and m.charge>0 then
   hitmob(m.x,m.y,p_mob,m.atk,m.push)
   blessmob(p_mob,-1)
   m.charge-=1   
  else
   hitmob(m.x,m.y,p_mob,m.atk,m.push)
  end
  sfx(57)
  return true
  --end attack player
 else
  --begin move to player
  if cansee(m,p_mob) then
   m.tx,m.ty=p_mob.x,p_mob.y
  end
  
  if m.x==m.tx and m.y==m.ty then
   --de aggro
   m.task=ai_wait
   addfloat("?",m.x*8+2,m.y*8,10)
  else
   if m.spec=="slow" and m.lastmoved then
    return false
   end
   local bdst,cand=999,{}
   calcdist(m.tx,m.ty)
   --start of direction loop
   for i=1,4 do
    local dx,dy=dirx[i],diry[i]
    local tx,ty=m.x+dx,m.y+dy

    if iswalkable(tx,ty,"checkmobs") and iswalkable(tx,ty,"checkspike") then
     local dst=distmap[tx][ty]
     if dst<bdst then
      cand={}
      bdst=dst
     end
     if dst==bdst then
      add(cand,i)
     end
    end
   end
   --end of direction loop
   if #cand>0 then
    local c=getrnd(cand)
    mobwalk(m,dirx[c],diry[c])
    return true
   end 
   if #cand==0 then 
   if(cantmoveallharm) then
   if(m.last_safe["lx"]!=nil)then
    return true
   else
    mobwalk(m,m.last_safe["lx"],m.last_safe["ly"])
   
  end
   end
    return true
   end 
   --todo: re-aquire target?
  end
 end
 return false
end

function cantmoveallharm(mx,my)
	screwed=false
	if(fget(mget(mx+1,my),1) or fget(mget(mx-1,my),1) or fget(mget(mx,my+1),1) or fget(mget(mx,my-1),1))then
	screwed=true
	return screwed
	end
end

function pushmob(atkx,atky,defm,dist)
modif=1
px=0
py=0

if dist<0 then
  modif=-1
  dist*=-1
end
push=modif
printh("modif: "..modif,"debugs")
if atkx == defm.x and atky < defm.y  then
  py=push
end

if atkx == defm.x and atky > defm.y  then
  py=-push
end

if atky== defm.y and atkx < defm.x  then
  px=push
end

if atky== defm.y and atkx  >defm.x   then
  px=-push
end
for i =0,dist-1	do
  defm.x+=px
  defm.y+=py
  printh("stats: "..px..","..py,"debugs")
	tile_effect(defm.x,defm.y,defm)
	end

end
function cansee(m1,m2)
 return dist(m1.x,m1.y,m2.x,m2.y)<=m1.los and los(m1.x,m1.y,m2.x,m2.y)
end

function spawnmobs()
 
 mobpool={}
 for i=2,#mob_name do
  if mob_minf[i]<=floor and mob_maxf[i]>=floor then
   add(mobpool,i)
  end
 end
 
 if #mobpool==0 then return end
 
 local minmons=explodeval("3,5,7,9,10,11,12,13")
 local maxmons=explodeval("6,10,14,18,20,22,24,26")
 
 local placed,rpot=0,{}
 
 for r in all(rooms) do
  add(rpot,r)
 end
 
 repeat
  local r=getrnd(rpot)
  placed+=infestroom(r)
  del(rpot,r)
 until #rpot==0 or placed>maxmons[floor]
 
 if placed<minmons[floor] then
  repeat
   local x,y
   repeat
    x,y=flr(rnd(16)),flr(rnd(16))
   until iswalkable(x,y,"checkmobs") and (mget(x,y)==1 or mget(x,y)==4)
   addmob(getrnd(mobpool),x,y)
   placed+=1
  until placed>=minmons[floor]
 end
end

function infestroom(r)
 if r.nospawn then return 0 end
 local target,x,y=2+flr(rnd((r.w*r.h)/6-1))
 target=min(5,target)
 for i=1,target do
  repeat
   x=r.x+flr(rnd(r.w))
   y=r.y+flr(rnd(r.h))
  until iswalkable(x,y,"checkmobs") and (mget(x,y)==1 or mget(x,y)==4)
  addmob(getrnd(mobpool),x,y)
 end
 return target
end

-------------------------
-- items
-------------------------

function takeitem(itm)
 local i=freeinvslot()
 if i==0 then return false end
 inv[i]=itm
 return true
end

function freeinvslot()
 for i=1,6 do
  if not inv[i] then
   return i
  end
 end
 return 0
end

function makeipool()
 ipool_rar={}
 ipool_com={}
 
 for i=1,#itm_name do
  local t=itm_type[i]
  if t=="wep" or t=="arm" then
   add(ipool_rar,i)
  else
   add(ipool_com,i)  
  end
 end
end

function makefipool()
 fipool_rar={}
 fipool_com={}
 
 for i in all(ipool_rar) do
  if itm_minf[i]<=floor 
   and itm_maxf[i]>=floor then
   add(fipool_rar,i)
  end
 end
 for i in all(ipool_com) do
  if itm_minf[i]<=floor 
   and itm_maxf[i]>=floor then
   add(fipool_com,i)
  end
 end
end

function getitm_rar()
 if #fipool_rar>0 then
  local itm=getrnd(fipool_rar)
  del(fipool_rar,itm)
  del(ipool_rar,itm)
  return itm
 else
  return getrnd(fipool_com)
 end
end

function foodnames()
 local fud,fu=explode("jerky,schnitzel,steak,gyros,fricassee,haggis,mett,kebab,burger,meatball,pizza,calzone,pasticio,chops,hams,ribs,roast,meatloaf,chili,stew,pie,wrap,taco,burrito,rolls,filet,salami,sandwich,casserole,spam,souvlaki")
 local adj,ad=explode("yellow,green,blue,purple,black,sweet,salty,spicy,strange,old,dry,wet,smooth,soft,crusty,pickled,sour,leftover,mom's,steamed,hairy,smoked,mini,stuffed,classic,marinated,bbq,savory,baked,juicy,sloppy,cheesy,hot,cold,zesty") 

 itm_known={}
 for i=1,#itm_name do
  if itm_type[i]=="fud" then
   fu,ad=getrnd(fud),getrnd(adj)
   del(fud,fu)
   del(adj,ad)
   itm_name[i]=ad.." "..fu
   itm_known[i]=false
  end
 end
end
-->8
--gen

function genfloor(f)
 floor=f
 floorx+=1
 makefipool()
 mob={}
 add(mob,p_mob)
 fog=blankmap(1)
 if floor==1 then 
  st_steps=0
  poke(0x3101,66)
 end
 if (floorx%8)==0 then
 floory +=1
 floorx=0
 end
 if true then  
  copymap(16*floorx,floory*16)
 else
  fog=blankmap(1)
  unfog()
 end
end

__gfx__
000000000000000066606660000000006660666066606660aaaaaaaa00aaa00000aaa00000000000000000000000000000aaa000a0aaa0a0a000000055555550
000000000000000000000000000000000000000000000000aaaaaaaa0a000a000a000a00066666600aaaaaa066666660a0aaa0a000000000a0aa000000000000
007007000000000060666060000000006066606060000060a000000a0a000a000a000a00060000600a0000a060000060a00000a0a0aaa0a0a0aa0aa055000000
00077000000000000000000000000000000000000000000000aa0a0000aaa000a0aaa0a0060000600a0aa0a060000060a00a00a000aaa00000aa0aa055055000
000770000000000066606660000000000000000060000060a000000a0a00aa00aa00aaa0066666600aaaaaa066666660aaa0aaa0a0aaa0a0a0000aa055055050
007007000005000000000000000000000005000000000000a0a0aa0a0aaaaa000aaaaa000000000000000000000000000000000000aaa000a0aa000055055050
000000000000000060666060000000000000000060666060a000000a00aaa00000aaa000066666600aaaaaa066666660aaaaaaa0a0aaa0a0a0aa0aa055055050
000000000000000000000000000000000000000000000000aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000006666660666666000666666006666600666666006660666066666660000066606660000066666660000066600000666066600000
00000000000000000000000066666660666666606666666066666660666666606660666066666660000066606660000066666660000066600000666066600000
00000000000000000000000066666660666666606666666066666660666666606660066066666660000006606600000066666660000066600000066066600000
00000000000000000000000066600000000066606660000066606660000066606660000000000000000000000000000000000000000066600000000066600000
00000660666666606600000066600000000066606660666066606660666066606660066066000660660006606600066000000660660066606666666066600660
00006660666666606660000066600000000066606660666066606660666066606660666066606660666066606660666000006660666066606666666066606660
00006660666666606660000066600000000066606660666066606660666066606660666066606660666066606660666000006660666066606666666066606660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006660066666006660000066600000000066600666666066606660666666006660666066606660666066606660666066606660666000006660666066666660
00006660666666606660000066600000000066606666666066606660666666606660666066606660666066606660666066606660666000006660666066666660
00006660666666606660000066600000000066606666666066000660666666606600066066006660660006606600066066600660660000006600666066666660
00006660666066606660000066600000000066606660000000000000000066600000000000006660000000000000000066600000000000000000666000000000
00006660666666606660000066666660666666606666666066000660666666606666666066006660000006606600000066600000666666600000666066000000
00006660666666606660000066666660666666606666666066606660666666606666666066606660000066606660000066600000666666600000666066600000
00006660066666006660000006666660666666000666666066606660666666006666666066606660000066606660000066600000666666600000666066600000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006660666666606660000066666660666066606660666066606660666066600000666066600000000066600000000066606660666000005000000088000088
00006660666666606660000066666660666066606660666066606660666066600000666066600000000066600000000066606660666000005055000080000008
00000660666666606600000066666660666066606660666066606660666066600000066066000000000006600000000066000660660000005055055000000000
00000000000000000000000000000000666066606660000066606660000066600000000000000000000000000000000000000000000000000055055000000000
00000000000000000000000066666660666066606666666066666660666666606600000000000660000006606600066000000000660000005000055000000000
00000000000000000000000066666660666066606666666066666660666666606660000000006660000066606660666000000000666000005055000000000000
00000000000000000000000066666660666066600666666006666600666666006660000000006660000066606660666000000000666000005055055080000008
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088000088
06000000000000000000060000000000505050506660666000000000000550000000000000000000000000000000000000000000000000000000000000000000
60000000060000000000006000000600000000000000000000500500000000500500005005050050005000000000005000500000000000000000000000000000
66000000660000000000066000000660505050506066606000050000055005000500005005000000000005000050055000000500000000000000000000000000
00000000000000000000000000000000000000000000000005050000555050000005000000005000000000000000000005000000000000000000000000000000
66000000660000000000066000000660505050505050505000005050000050500005050000005050000000000000000000055000000000000000000000000000
0005000000050000000500000005000000000000000000000050500000050000050505000500005000050000005500500050050000aaaaa00000000000000000
600000006000000000000060000000605050505050505050000050000005000005000000050500500000000005555000005550000aaaaaaaa000000000aaaa00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa0aaaaaaaa00000aaaaaaa0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a00aaaaaaaaaaaaaaaaaaaaa
06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaa
66600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaa0a
00000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaa0aa
000006680000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaaaaaaa0aa0
0600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaaa0a0a0a0
66600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a00aaa0a0a0a0a0a0a0a0a0a
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0000aaaa0a0a0a0a0aaa00a
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa000000aaaaaaaaaaa000aa
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa000aa000000000000000aa
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa0000aaaaaaaaaa0000aa0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0aa00000000000000aa0a0
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a00aa0000000000aa00a00
099aa990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa00aaaaaaaaaa00aa000
009aa90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa0000000000aa00000
000990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaa0000000
00044440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00848840000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888890000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888890000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
20202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
20f0101010101010101010101010102020f0101010101010101010101010102020f0101010101010101010101010102020f01010101010101010101010101020
20f0101010101010101010101010102020f0101010101010101010101010102020f0101010101010101010101010102020f01010101010101010101010101020
20101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020
20101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020
20101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020
20101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020
20101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020
20101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020
20101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020
20101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020
20101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020
20101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020
20101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020
20101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020
20101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020
20101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020
20101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020
20101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020
20101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020
20101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020
20101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020
20101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020
20101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020
20101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020
20101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020
20101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020
2010101010101010101010101010e0202010101010101010101010101010e0202010101010101010101010101010e0202010101010101010101010101010e020
2010101010101010101010101010e0202010101010101010101010101010e0202010101010101010101010101010e0202010101010101010101010101010e020
20202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
20202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
00000000000000000000000000000000000006000000000006000000000000000000000000060006000000000066006600066600000666000006660000066600
00000000006660000000000000000000006600600006600060066000006600000066006600060006006600660600060000660600006606000066060000660600
00666000060666000066600000000000006660606066600060666000006660600600060000600060060006000600060006666000066660000666606606666066
06066600060666000606660006666660066666006066006006666600600660600066606000666060006660600066606006666666066666660666660606666606
60666660066666006066666060066666600666000666660006660060066666000606660606666606066606060606060606666606006606060660660000660600
66666660066666006666666066666666606660000666600000666060006666000666060606060606060666060660660666066000066000006606600006600000
06666600006660000666660006666660006666000066660006666000066660000606666006606660066606600666666006606600006600000060660000660000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000666000000066000000000000000000000000000000000000000000000666000000000000666600006666000066666600666600
00666600000000000066660006600600000666600000660000000000000066000000000000066600006666660006660000066666000660660006606600066066
06600060006666660660006006000000000606000006666000006600000666600006660000666666006666060066666600666666006666660066660000666666
06660000066600000666000006660000060666660006060000066660000606000066666600666606066666660066660600060000000600000006000000060000
00666600006666000066660000666600066666060606666600060600060666660066660606666666066666000666666600006600060066000000660006006600
06066066060660660606606606066066006660000666660606066666066666060666666606666600066666660666660000006660060066600000666006006660
06060660060606600606066006060660000000000066600006666606006660000666660006666666066606060666666606666600006666000666660000666600
00000000000000000000000000000000000000000000000000666000000000000666666606660606066660000666060600000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000e00e000000000000e00e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000
000dddd0000e00e0000dddd0000e00e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077000000
00442420000dddd000442420000dddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077700000
00444440004424200044444000442420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077000000
00444440004444400044444000444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000
e055aa500e55aa50e055aa500e55aa50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ee4444000e444400ee4444000e44440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000e00e00000ee00000e00e00000ee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
66606660666066606660666000000000666066600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60666060606660606066606000000000606660600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66606660666066606660666000000000666066600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60666060606660606066606000000000606660600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66606660000000000000000000aaa00000aaa00000aaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000e00e0005000000a000a00a0aaa0a0a0aaa0a000000000000000000000000000000000000000000000000000000000000000000000000000000000
60666060000dddd0000005000a000a00a00000a0a00000a000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000044242005000000a0aaa0a0a00a00a0a00a00a000000000000000000000000000000000000000000000000000000000000000000000000000000000
666066600044444000055000aa00aaa0aaa0aaa0aaa0aaa000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000e55aa50005005000aaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6066606000e444400055500000aaa000aaaaaaa0aaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666066600000000000aaa00000aaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000a000a000a000a000aaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60666060000000000a000a000a000a000a0000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000a0aaa0a000aaa0000a0aa0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6660666000000000aa00aaa00a00aa000aaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000500000aaaaa000aaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
606660600000000000aaa00000aaa0000aaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6660666000aaa00000aaa00000aaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000a000a000a000a000a000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
606660600a000a000a000a000a000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000a0aaa0a0a0aaa0a0a0aaa0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66606660aa00aaa0aa00aaa0aa00aaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aaaaa000aaaaa000aaaaa00000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6066606000aaa00000aaa00000aaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6660666000aaa00000aaa00000aaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000a000a000a000a000a000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
606660600a000a000a000a000a000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000a0aaa0a0a0aaa0a0a0aaa0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66606660aa00aaa0aa00aaa0aa00aaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aaaaa000aaaaa000aaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6066606000aaa00000aaa00000aaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66606660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60666060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66606660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60666060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000066666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666000000000
00000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000
00000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000
00000060000006660666000000660066066006600666000006660606006606060666066000660000060606660600060000000606006606060000006000000000
00000060000000600666000006000606060606060606000006000606060006060060060606000000060600600600060000000606060606060000006000000000
00000060000000600606000006000606060606060666000006600606060006600060060606000000066000600600060000000666060606060000006000000000
00000060000000600606000006060606060606060606000006000606060006060060060606060000060600600600060000000006060606060000006000000000
00000060000006660606000006660660060606060606000006000066006606060666060606660000060606660666066600000666066000660000006000000000
00000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000
00000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000
00000066666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000066666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000060000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000060000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000060006606600666000606660006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000060006666600600006006000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000060006666600666006006660006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000060000666000006006000060006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000060000060000666060006660006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000060000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000060000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000066666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000050500050303030103010307020005050505050502050505050505050505050505050505050505050505050505050505050505050505050505050505000000000000000004040000000000010101020000000000000000000000000101010000000000000000000000000001030103000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202
020f02080c0c0c0c0101010101010102020f0101010101010101010101010102020f0101010101010101010101010102020f0101010101010101010101010102020f0101010101010101010101010102020f0101010101010101010101010102020f0101010101010101010101010102020f0101010101010101010101010102
020101070a505001010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102
02010101015050c0010146010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102
02070101010101c0010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102
024601010101010101014a4a4a4a010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102
020101010101010101464a50504a01020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101d801010101010101020201010101010101010101010101010202010101010101010101010101010102
020101010150010101010150500101020201010101010101c801010101010102020101010101010101cc01010101010202010101010101d0010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102
0250010150c05001010101505001010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102
02500101015001010101505050010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101d4d40101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102
0250017001010101010150505001010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102
0250505050505050505050505001010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102
0250505050505050505050505050010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102
0250505050505050505050505001010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102
02505050505050505050505050500e0202010101010101010101010101010e0202010101010101010101010101010e0202010101010101010101010101010e0202010101010101010101010101010e0202010101010101010101010101010e0202010101010101010101010101010e0202010101010101010101010101010e02
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202
020f0101010101010101010101010102020f0101010101010101010101010102020f0101010101010101010101010102020f0101010101010101010101010102020f0101010101010101010101010102020f0101010101010101010101010102020f0101010101010101010101010102020f0101010101010101010101010102
0201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102
0201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102
0201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102
0201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102
0201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102
020101010101dc01010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102
0201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102
0201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102
0201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102
0201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102
0201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102
0201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102020101010101010101010101010101020201010101010101010101010101010202010101010101010101010101010102
02010101010101010101010101010e0202010101010101010101010101010e0202010101010101010101010101010e0202010101010101010101010101010e0202010101010101010101010101010e0202010101010101010101010101010e0202010101010101010101010101010e0202010101010101010101010101010e02
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202
__sfx__
011600000217502705021150200002135000000210402104021250000002105000000215500000000000211401175017050111500105011350010500105001050112500105001050010501135001000000000000
01160000215101d510195251a535215351d520195151a5152151221515215252252521525215150e51511515205141c510195251c535205351c520195151c5152051220515205252152520525205150d51510515
0116000000000215101d510195151a515215151d510195151a5152151221515215152251521515215150e51511515205141c510195151c515205151c510195151c5152051220515205152151520515205150d515
01160000150051d00515015150151a0251a0151d0151d015220252201521025210151d0251d0151502515015140201402214025140151400514004140050d000100140c0100d0201003014030150201401210015
011600000217502705021150200002135000000000000000021250000000000000000215500000000000211405175001050511500105051350010500105001050512500105001050010505135000000000000000
01160000215141d510195251a525215251d520195151a5152151221515215202252021525215150e52511515205141d5101852519525205251d520185151951520512205151c5201d52020525205151052511515
0116000000000215141d510195151a515215151d510195151a5152151221515215102251021515215150e51511515205141d5101851519515205151d510185151951520512205151c5101d510205152051510515
01160000000002000015015150151a0251a0151d0251d015220252201521015210151d0251d01526015260152502025012250152501518000000000000000000100000d02011030140401505014040190301d010
011600000717502005071150200007135000000000000000071250000000000000000715500000000000711403175001050311500105031350010500105001050312500105001050010503155000000000000000
01160000091750200509115020000913500000000000000009125000000000000000091550000000000091140a175001050a115001050a1250010504105001050a125001050910500105041350c1000912500100
01160000225121f5201a5251f515225251f5201a5151f515215122151222525215251f5251f5150e52513515225141f5101b5251f525225251f5201b5151f515215122151222525215251f5251f5150f52513515
01160000215141c510195251d515215251c520195151d5152151222510215201f51021512215150d52510515205141d5101a52516515205151d5201a5151651520522205151d515205251f5251d5151c52519515
0116000000000225121f5101a5151f515225151f5101a5151f515215122151222515215151f5151f5150e51513515225141f5101b5151f515225151f5101b5151f515215122151222515215151f5151f5150f515
0116000000000215141c510195151d515215151c510195151d5152151222510215101f51021510215150d51510515205141d5101a51516515205151d5101a5152051520510205151d515205151f5151d5151c515
01160000000000000022015220151f0251f0151a0151a01522025220151f0151f01519020190221a0251a0151f0201f0221f0151f01518000000000000000000000000f010130201603015030160321502013015
011600001902519015220252201521015210151c0251c015220252201521025210151c0221c0151d0251d01520020200222001520015110051a0151d015220152601226012280102601625010250122501025015
011600000217509035110150203502135090351101502104021250000002105000000212511035110150211401175080351001501035011350803510015001050112500105001050010501135100351001500000
0116000002175090351101502035021350903511015021040212500000021050000002155110351101502114051750c0351401505035051350c03514015001050512500105001050010505135140351401500000
01160000071750e0351601507035071350e0351601502104071250000002105000000715516035160150711403175160351301503035031351603513015001050312500105001050010503135160351601500000
0116000009175100351101509035091351003511015021040912500000021050000009155100350d015091140a17510035110150a0350a1351003511015001050a12500105001050010509135150350d01509020
0116000002215020451a7051a7050e70511705117050e7050e71511725117250e7250e53511535115450e12501215010451a6001a70001205012051a3001a2001071514725147251072510535155351554514515
0116000002215020451a7051a7050e70511705117050e7050e71511725117250e7250e53511535115450e12505215050451a6001a70001205012051a3001a2001171514725147251172511535195351954518515
0116000007215070451a7051a7050e70511705117050e705137151672516725137251353516535165451312503215030451a6001a70001205012051a3001a2001371516725167250d7250f535165351654513515
0116000009215090451a7051a7050e70511705117050e7050d715157251572510725115351653516545157250a2150a0451a6001a70001205012051a3001a2000e71510725117250e7250d5350e5351154510515
0116000021005210051d00515015150151a0151a0151d0151d015220152201521015210151d0151d01515015150151401014012140151401518000000000000000000100100c0100d01010010140101501014010
0116000000000000002000015015150151a0151a0151d0151d015220152201521015210151d0151a01526015260152501019015190151900518000000000000000000000000d0101101014010150101401019010
0116000000000000000000022015220151f0151f0151a0151a01522015220151f0151f01519010190121a0151a0151f0101f012130151300518000000000000000000000000f0101301016010150101601215010
01160000190051901519015220152201521015210151c0151c015220152201521015210151c0121c0151d0151d015200102001220015200051d0051a015220152901029012260102801628010280122801528005
01160000097140e720117300e730097250e7251173502735057240e725117350e735097450e7401174002740087400d740107200d720087350d7351072501725047240d725107250d725087350d7301074001740
01160000097240e720117300e730097450e745117350e735117240e725117350e735097450e740117400e740087400d740117200d720087350d735117250d725117240d725117250d725087350d730117400d740
011600000a7240e720137300e7300a7450e745137350e735137240e725137350e7350a7450e740137400e7400a7400f740137200f7200a7350f735137250f725137240f725137250f7250a7350f730137400f740
0116000010724097201073009730107450974510735097351072409725107350973510745097401074009740117400e740117200e720117350e735117250e725117240e725117250e725097350d730107400d740
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0113000029700297002670026700257002570022700227000000026700217000e7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011300000255011555165501555016555115550d5500a5500e5500e5520e5520e5521400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011300001170015700197001a700117001670019700197001a7001a70025700257002570025700257002570025700197021970219702000000000000000000000000000000000000000000000000000000000000
011300000d2200c2200b220154000000000000000000000029720287302672626745287402173029720217322673026732267350210526702267020e705021050000000000000000000000000000000000000000
0113000000000000000000000000000000000000000000000e1100d1200a1300e1350d135091000a120091300e1220e1200e1200e1000e1020e10200000000000000000000000000000000000000000000000000
0113000000000000000000000000000000000000000000000a14300000000000a060090600a000090000900002072020720207202005020020200500000000000000000000000000000000000000000000000000
011200001b0001f0002200023000220001f0002000022000230002700023000200001f000200001f0001b0001f00022000200002200023000270001d000200001f0001f0001f0001f00000000000000000000000
011200001f5001f5001b5001b50022500225002350023500225002250020500205001f5001f500205002050022500225002350023500255002550023500235002250022500225002250000000000000000000000
01120000030000300003000130000700007000080000800008000170000b0000b0000a0000a0000a0000f00003000030000800008000080001100005000050000300003000030000300003000030000300000000
011200001e0201e0201e032210401a0401e0401f0301f0321f0301f0301e0201e0201f0201f020210302103022030220322902029020290222902228020280202602026020260222602200000000000000000000
011200001a7041a70415534155301a5321a5301c5401c5401c5451a540155401554516532165301a5301a5351f5401f54522544225402254222545215341f5301e5441e5401e5421e54500000000000000000000
01120000110250e000120351500015045150000e0550e00512045150051503515005130251500516035260051a0452100513045210051604526005100251f0050e0500e0520e0520e0500c000000000000000000
0002000031530315302d500315003b5303b5302e5000050031530315302e5002d50039530395302d5000050031530315303153031530315203152000500005000050000500005000050000500005000050000500
000100003101031010300102f0102d0202c0202a02028030270302503023050210501e0501d0501b05018050160501405012050120301103011010110100e0100b01007010000000000000000000000000000000
00010000240102e0202b0202602021010210101a01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000024010337203372033720277103a7103a71000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030000096201163005620056150160000600006001160011600116001160001620006200a6100a6050a6000a6000f6000f6000f6000f6000060000600026100261002615016000160005600056000160001600
00010000145201a520015000150001500015000150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000211102114015140271300f6300f6101c610196001761016600156100f6000c61009600076000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100001b61006540065401963018630116100e6100c610096100861000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001f5302b5302e5302e5303250032500395002751027510285102a510005000050000500275102951029510005000050000500005002451024510245102751029510005000050000500005000050000500
0001000024030240301c0301c0302a2302823025210212101e2101b2101b21016210112100d2100a2100a2100a2100a2100a2100a2100a2100a2100a2100a2100a2100a2100a2100a2100a2100a2100020000200
0001000024030240301c0301c03039010390103a0103001030010300102d010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000210302703025040230301a030190100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000d720137200d7100c40031200312000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
02 00424344
00 00031843
00 04071947
00 080e1a4e
00 090f1b4f
00 10010243
00 11050647
00 120a0c4e
00 130b0d4f
00 001c0344
00 041d0744
00 081e0e44
00 091f0f44
00 00145c44
00 04155d44
00 08165e44
02 13175f44
00 41424344
00 41424344
00 41424344
00 41424344
00 68696744
04 2a2b2c44
00 6d6e6f44
04 70317244

