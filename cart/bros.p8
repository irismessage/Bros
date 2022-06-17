pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
-- bros
-- je-soft

-- 0 bros
-- 1 movement
-- 2 entities
-- 3 levels
-- 4 hiscores
-- 5 font
-- 6 swap
-- 7 encoded

-- sprite flags
f = {
	coll=0,
	brks=1,
	bonk=4,
	coin=5,
	powr=6,
}

-- game
g = {
	score=0,
	coins=0,
	lives=3,
	timer=0,
	fungus=false,
	wep=0,
}

-- sprite codes
s = {
	bg=1,
	bro=2,
	bbro=7,
	timer=14,
	fguy=17,
	emptyblock=42,
	coin=59,
	shroom=61,
}

-- state
staupdate = nil
stadraw = nil

sndp = {
	snd=nil,
	len=0,
	sam=1,
	adr=usrdta,
	done=false,
	play=false,
	stime=0,
}

wait = {
	f=0,
	call=nil,
}
-- bg colour
bc = 12
-- text colour
tc = 9
-- sound memory block
usrdta = 0x4300
dtalen = 2048
dtaend = usrdta+dtalen
amp = {
	[0]=159,
	[1]=143,
	[2]=127,
	[3]=111,
}

function _init()
	bbs = false
	if not bbs then
		extcmd("set_title","BROS")
	end
	palt(0,false)
	color(tc)
	menuinit()
	loadfont()
	initscores()
	unpacksnds()
	mainscreen()
end

function _update60()
--	debugstats()
	if sndplaying()
			or updatewait() then
		return
	end
	updatecode()
	staupdate()
end

function _draw()
	stadraw()
end

function debugstats()
	printh("")
	printh(time())
	printh("p.x"..pad(p.x,3))
	printh("p.y"..pad(p.y,3))
	printh("p.jump"..p.jump)
	printh("p.jtick"..p.jtick)
end

function menuinit()
	menuitem(
		1,
		"! delete save",
		function ()
			resetgame()
			savegame()
			mainscreen()
		end
	)
	menuitem(
		2,
		"? bros tutorial",
		helpscreen
	)
end

function updatewait()
	if wait.f > 0 then
		if wait.f == 1 then
			wait.f = 0
		 wait.call()
		elseif btnp(❎) or btnp(🅾️) then
			wait.f = 1
		else
			wait.f -= 1
		end
		return true
	end
	return false
end

-- sampled sound playing
function unpacksnds()
	for k,v in pairs(snd) do
		bytes = {ord(v,1,#v)}
		samples = {}
		for b in all(bytes) do
			for shift=6,0,-2 do
				bits = (b>>shift) & 3
				add(samples,amp[bits])
			end
		end
		snd[k] = samples
	end
end

function sndplaying()
	-- no sound active
	if not sndp.play then
		return false
	end
	-- skip sound
	if btnp(❎) then
		sndp.play = false
		return false
	end

	-- wait for buffer
	if stat(108) != 0 then
		return true
	end

	if sndp.done then
		sndp.done = false
		sndp.play = false
		return false
	end

	-- fill memory
	while sndp.sam < sndp.len do
		local sam = sndp.snd[sndp.sam]
		poke(sndp.adr,sam)
		sndp.adr += 1
		sndp.sam += 1
		if sndp.adr == dtaend then
			sndp.adr = usrdta
			-- play if full
			serial(0x808,usrdta,dtalen)
			return true
		end
	end

	local remains = sndp.adr-usrdta
	sndp.done = true
	serial(0x808,usrdta,remains)
	return true
end

function psnd(snd)
	sndp.snd = snd
	sndp.len = #snd
	sndp.sam = 1
	sndp.adr = usrdta
	sndp.play = true
	sndp.stime = time()
end

-- help screen
function updatehelpscreen()
	if mbtnp(🅾️,❎) then
		mainscreen()
	end
end

function helpscreen()
	staupdate = updatehelpscreen
	stadraw = function() end
	map(0,16)
	music(-1)
	wait.f = 15 * tick
	wait.call = drawhelpscreen
end

function drawhelpscreen()
	map(32,16)
	music(24)
	helptext = {
		{"gameplay",44},
		{"⬅️➡️ : move",36},
		{"⬆️🅾️ : jump",36},
		{"11 coins : 1up",20},
		{"mushroom : break bricks",20},
		{"",0},
		{"hiscore",44},
		{"⬅️➡️ : cursor",36},
		{"⬆️⬇️ : letter",36},
		{"❎ : discard",44},
		{"🅾️ : record",44},
	}
	local y = 16
	for t in all(helptext) do
		print(t[1],t[2],y)
		y += 8
	end
end

-- top bar rendering
function pad(num, digits)
	padded = tostr(num)
	for i=1,digits-#padded do
		padded = "0"..padded
	end
	return padded
end

function drawtimer()
	rectfill(86,8,98,15,bc)
	color(tc)
	print(ceil(g.timer),86,8)
end

function drawtopbar()
	rectfill(0,8,127,15,bc)
	color(tc)
	print(pad(g.score,5),2,8)
	spr(s.coin,22,8)
	print(pad(g.coins,2),32,8)
	spr(s.bbro,40,8)
	print(g.lives,50,8)
	print("lvl",56,8)
	print(l.world..l.stage,68,8)
	spr(s.timer,76,8)
	drawtimer()
	if g.fungus then
		spr(s.shroom,100,8)
	end
	spr(62,110,8)
	print(pad(g.wep,2),118,8)
end

function updatemainscreen()
	enticki(2)
	if btnp(🅾️) then
		levelscreen()
	elseif btnp(❎) then
		scorescreen()
	end
end

function drawmainscreen()
	spr(25+3*enspr,8,48,1,1)
	spr(19+enspr,104,72,1,1,enspr==1)
end

function mainscreen()
	staupdate = updatemainscreen
	stadraw = drawmainscreen
	cls(bc)
	map(0,16)
	music(24)
	drawtopbar()
	spr(2,112,48,1,1,true)
	print("00",90,8)
	print("🅾️:play",4,104)
	print("‖:screen",44,104)
	print("❎:scores",88,104)
	mspr = 0
	mtick = 0
end

-->8
-- movement

tick = 2
-- walk
wtickl = 1 * tick
-- stop walk
stickl = 2 * tick
-- up jump
utickl = 2 * tick
-- down fall
dtickl = 1 * tick
-- refill jump on floor
rtickl = 2 * tick
-- bonk
btickl = 4 * tick
-- apex of jump
atickl = 0 * tick

jumpmax = 5
coyotemax = 2

p = {
	x=0,
	y=0,
	l=false,
	wspr=0,
	wtick=0,
	jtick=0,
	jump=jumpmax,
	coyote=0,
}


function drawbro()
	local sprn = 2
	if 0 < p.jump
			and p.jump < jumpmax then
		sprn = 5
	elseif p.wspr != -1 then
		sprn = 3 + p.wspr
	end
	spr(sprn,p.x,p.y,1,1,p.l)
end

function updatewalk()
	if p.wtick > 0 then
		p.wtick -= 1
		return
	end

	local lb = btn(⬅️)
	local rb = btn(➡️)

	if lb and rb
			or not (lb or rb) then
		p.wspr = -1
		return
	end

	p.wspr += 1
	p.wspr %= 2

	if lb then
		p.l = true
		if lcol() or p.x<4 then
			p.wtick = stickl
		else
			p.wtick = wtickl
			p.x -= 4
		end
	end
	if rb then
		p.l = false
		if rcol() or 124<p.x then
		 p.wtick = stickl
		else
			p.wtick = wtickl
			p.x += 4
		end
	end
end

function updatejump()
	if p.jtick > 0 then
		p.jtick -= 1
		return
	end
	p.y += 8

	p.jtick = dtickl
	dl,dm,dr = ycol(p.x,p.y)
	if yft(dl,dm,dr) then
		p.y -= 8
		p.coyote = coyotemax
		if p.jump == 1 then
			p.jump = jumpmax
			p.jtick = rtickl
			return
		else
			p.jtick = 0
		end
	end

	if 1 < p.jump then
		if btn(⬆️) or btn(🅾️) then
			p.y -= 16
			p.jtick = utickl
			if p.jump == jumpmax then
				p.y += 8
				sfx(56)
			elseif p.jump == 3 then
				p.jtick = atickl
				p.wtick = 0
			end
			p.jump -= 1
			ul,um,ur = ycol(p.x,p.y)
			if yft(ul,um,ur) then
				p.y += 8
				p.jtick = btickl
				bonk(ul,um,ur)
			end
		elseif p.jump < jumpmax then
			p.jump = 1
			sfx(56,-2)
		end
		return
	end

	-- coyote time
	if p.jump==jumpmax and not dcol() then
		if 0 < p.coyote then
			p.coyote -= 1
		else
			p.jump = 1
		end
	end
end

-- collision
function ccollide(x,y)
	return mget(x/8,y/8)
end

function yft(cl,cm,cr)
	if cm != nil then
		return fget(cm,f.coll)
	else
		return fget(cl,f.coll)
			or fget(cr,f.coll)
	end
end

function xft(cx)
	return fget(cx,f.coll)
end

function ycol(x,y)
	-- returns left,middle,right
	if x % 8 == 0 then
		local cm = ccollide(x,y)
		return nil,cm,nil
	else
		local cl = ccollide(x-4,y)
		local cr = ccollide(x+4,y)
		return cl,nil,cr
	end
end

function xcol(x,y)
	if x % 8 != 0 then
		return s.bg
	else
		return ccollide(x,y)
	end
end
function lcol()
	return xft(xcol(p.x-8,p.y))
end
function rcol()
	return xft(xcol(p.x+8,p.y))
end

function checkfall()
	if (p.y > 104) die()
end

function updatemovement()
	updatewalk()
	updatejump()
	checkfall()
end

-->8
-- entities

coin={
	x=0,
	y=0,
	lifet=0,
	show=false,
	sprn=59,
}
fungus={
	x=0,
	x=0,
	show=false,
	sprn=61,
}
fguy={
	x=0,
	y=0,
	l=true,
	wtick=0,
	jtick=0,
	show=false,
	sprn=17,
}

enspr = 0
entick = 0

function enticki(freq)
	if entick == 0 then
		entick = freq * tick
		enspr += 1
		enspr %= 2
	else
		entick -= 1
	end
end

function coinup()
	g.score += 10
	g.coins += 1
	if g.coins >= 11 then
		g.lives += 1
		g.coins = 0
	end
	drawtopbar()
end

function bonk(ul,um,ur)
	-- called in updatejump()
	local cachedjump = p.jump
	p.jump = 1

	-- between two blocks
	-- no bonk interaction
	if um == nil then
		if xft(ul) then
			sprn = ul
		elseif xft(ur) then
			sprn = ur
		end
		if fget(sprn,f.bonk) then
			psnd(snd.bonk)
		end
		return
	end

	-- popout
	sprn = um
	local x = p.x
	local y = p.y - 8
	local mx = x / 8
	local my = y / 8

	if fget(sprn,f.coin) then
		psnd(snd.coin)
		coin.x = p.x
		coin.y = p.y-16
		coin.show = true
		coin.lifet = 5*tick
		mset(mx,my,s.emptyblock)
	elseif fget(sprn,f.powr) then
		psnd(snd.coin)
		fungus.x = p.x
		fungus.y = p.y-16
		fungus.show = true
		g.score += 100
		drawtopbar()
		mset(mx,my,s.emptyblock)
	elseif g.fungus
			and fget(sprn,f.brks) then
		p.jump = cachedjump
		psnd(snd.brks)
		g.score += 25
		drawtopbar()
		mset(mx,my,s.bg)
	elseif fget(sprn,f.bonk) then
		psnd(snd.bonk)
	end
end

function updatecoin()
	if coin.show then
		if coin.lifet == 0 then
			coin.show = false
			coinup()
		else
			coin.lifet -= 1
		end
	end
end

function updatefungus()
	if fungus.show then
		if fungus.x==p.x and fungus.y==p.y then
			g.fungus = true
			fungus.show = false
			drawtopbar()
			psnd(snd.eats)
		end
	end
end

function updatefguy()
	if (not fguy.show) return

	-- player interaction
	if abs(p.x-fguy.x) <= 4 then
		if p.y - fguy.y == 0 then
			if p.jump==1
					or (p.coyote!=0 and not yft(ycol(p.x,p.y))) then
				--stomped on
				fguy.show = false
				g.score += 100
				drawtopbar()
				psnd(snd.kill)
			else
				die()
			end
		end
	end

	-- fall
	if fguy.y > 108 then
		fguy.show = false
	end
	dl,dm,dr = ycol(
		fguy.x,fguy.y+8
	)
	if not yft(dl,dm,dr) then
		if fguy.jtick == 0 then
			fguy.jtick = tick
			fguy.y += 8
		else
			fguy.jtick -= 1
		end
		return
	end

	-- walk
	if fguy.wtick == 0 then
		fguy.wtick = 8*tick
		if fguy.l then
			cl = xcol(fguy.x-8,fguy.y)
			if not xft(cl) then
				fguy.x -= 4
			else
				fguy.l = false
				fguy.x += 4
			end
		else
			cr = xcol(fguy.x+8,fguy.y)
			if not xft(cr) then
				fguy.x += 4
			else
				fguy.l = true
				fguy.x -= 4
			end
		end
	else
		fguy.wtick -=1
	end
end

function drawentities()
	for en in all({coin,fungus}) do
		if en.show then
			spr(en.sprn,en.x,en.y)
		end
	end

	for en in all({fguy}) do
		if en.show then
			local sprn = en.sprn
			sprn += enspr
			spr(sprn,en.x,en.y,1,1,en.l)
		end
	end
end

function checkcoin()
	if xcol(p.x,p.y)==s.coin then
		psnd(snd.coin)
		mset(p.x/8,p.y/8,s.bg)
		coinup()
	end
end

function updateentities()
	enticki(4)
	checkcoin()
	updatecoin()
	updatefungus()
	updatefguy()
end

-->8
-- levels

l = {
	world=1,
	stage=1,
	screen=1,
	scrn=1,
	-- player start coords
	px=0,
	py=0,
}
offset=2

function resetgame()
	g.score = 0
	g.coins = 0
	g.lives = 4
	g.timer = 999
	l.world = 1
	l.stage = 1
	l.screen = 1
	l.scrn = 1
end

function levelscreen()
	loadgame()
	levelmusic()
	loadlevel()
	resetp()
	wait.f = 5 * tick
	wait.call = levelstart
end

function levelstart()
	staupdate = updatelevel
	stadraw = drawlevel
	cls(bc)
	drawtopbar()
end

function decodescreen(scrn)
	scrc = screens[scrn]
	scrd = {ord(scrc,1,#scrc)}
	x = 0
	y = offset
	local i = 1
	while i < #scrd do
		sprn = scrd[i]
		if sprn == s.bg then
		 i += 1
			reps = scrd[i]
			for j=1,reps do
				mset(x,y,s.bg)
				nextm()
			end
		else
			sprn = submtile(sprn,x,y)
			mset(x,y,sprn)
			nextm()
		end
		i += 1
	end

	-- default if no spawn point
	if (l.py == 0) l.py = 96
end

function submtile(sprn,x,y)
	if sprn == s.bro then
		sprn = s.bg
		l.px = 8*x
		l.py = 8*y
	elseif sprn == s.fguy then
		sprn = s.bg
		fguy.x = 8*x
		fguy.y = 8*y
		fguy.l = true
		fguy.show = true
	end
	return sprn
end

function nextm()
	x += 1
	if 15 < x then
		x = 0
		y += 1
	end
end

function mbtnp(...)
	for b in all({...}) do
		if (btnp(b)) return true
	end
	return false
end

function updatewinscreen()
	if mbtnp(❎,🅾️) then
		wait.f = 1
	end
end

function win()
	staupdate = function() end
	stadraw = function() end
	map(48,16)
	spr(20,56,96,1,1,true)
--	local y = 44
--	print("s o r r y",44,y)
--	local t
--	t = "but your brother is in"
--	print(t,16,y+16)
--	print("another castle")
	local y = 44
	print("thank you mario!",24,y)
	local t
	t = "but your \015bros\014 is still"
	print(t,16,y+16)
	print("in development!")
	wait.f = 120 * tick
	wait.call = mainscreen
end

function levelup()
	l.scrn += 1
	if #screens < l.scrn then
		win()
		return
	end

	l.screen += 1
	if l.screen > 5 then
		l.screen = 1
		l.stage += 1
		g.timer = 999
	end
	if l.stage > 4 then
		l.stage = 1
		l.world += 1
	end

	savegame()
	drawtopbar()
	loadlevel()
end

function levelmusic()
	music(((l.stage-1)%3)*8)
end

function loadlevel()
	coin.show = false
	fungus.show = false
	fguy.show = false
	if l.screen == 1 then
		levelmusic()
	end
	decodescreen(l.scrn)
	p.x = l.px
end

function checklevelup()
	if btn(➡️) and p.wtick==0 then
		if 114 < p.x then
			levelup()
		end
	end
end

function resetp()
	p.x = l.px
	p.y = l.py
	p.l = false
end

function die()
	stadraw()
	stadraw = function() end
	spr(6,p.x,p.y)
	flip()
	psnd(snd.dies)
	g.lives -= 1
	g.fungus = false
	wait.f = 1
	wait.call = respawn
end

function respawn()
	g.timer = 999
	drawtopbar()
	if g.lives == 0 then
		gameover()
	else
		stadraw = drawlevel
	 resetp()
	end
end

function gameover()
	map(20,22,32,40,9,5)
	print("game  over",44,56)
	wait.f = 60 * tick
	wait.call = dieforever
end

function dieforever()
 h.rank = rankscore(g.score)
	if h.rank != 11 then
		askname()
	else
		mainscreen()
	end
	resetgame()
	savegame()
end

function updatetimer()
	if g.timer == 0 then
		die()
	else
		g.timer -= 0.5/tick
	end
end

function debugdie()
	if (btnp(❎)) die()
end

function updatelevel()
	debugdie()  -- todo remove
	checklevelup()
	updatetimer()
	updatemovement()
	updateentities()
end

function drawlevel()
	map()
	drawentities()
	drawtimer()
	drawbro()
end

-->8
-- hiscores

-- data layout
-- 01 to 10 top scores
-- 11 to 41 3 nums per name
-- 42 to 50 save game

h = {
	ords={32,32,32},
	chrs={" "," "," "},
	curs=1,
	rank=0,
}

function loadgame()
	g.score,
	g.coins,
	g.lives,
	g.timer,
	l.world,
	l.stage,
	l.screen,
	l.scrn
		= peek4(0x5ea0,8)
	-- 0x5e00 + 40 * 4
end

function savegame()
	poke4(
		0x5ea0,
		g.score,
		g.coins,
		g.lives,
		g.timer,
		l.world,
		l.stage,
		l.screen,
		l.scrn
	)
end

function initscores()
	loaded = cartdata("bros_sorb")
	if not loaded then
		for i=1,10 do
			savename(i,"   ")
		end
		resetgame()
		savegame()
	end
end

function nameaddr(i)
	-- 0x5e00 + 10 * 4
	return 0x5e28 + i * 12
end

function loadname(i)
	addr = nameaddr(i)
	name = chr(peek4(addr,3))
	return name
end

function savename(i,name)
	addr = nameaddr(i)
	n1,n2,n3 = ord(name,1,3)
	poke4(addr,n1,n2,n3)
end

function rankscore(num)
	for i=1,10 do
		if num > dget(i) then
			return i
		end
	end
	return 11
end

function shiftscores(rank)
	for i=10,rank,-1 do
		j = i-1
		score = dget(j)
		dset(i,score)
		name = loadname(j)
		savename(i,name)
	end
end

function savescore()
	hc = h.chrs
	name = hc[1]..hc[2]..hc[3]
	shiftscores(h.rank)
	dset(h.rank,g.score)
	savename(h.rank,name)
end

function askname()
	staupdate = updatenameentry
	stadraw = drawnameentry
	cls(bc)
	drawtopbar()
	print("great score",42,40)
	print("enter your name",34,56)
end

function drawnameentry()
	rectfill(58,72,70,86,bc)
	color(tc)
	for i=1,3 do
		print(h.chrs[i],54+4*i,72)
	end
	print(":",54+4*h.curs,80)
end

function updatenameentry()
	if btnp(🅾️) then
		savescore()
	end
	if btnp(❎) or btnp(🅾️) then
		scorescreen()
	end

	-- cursor
	c = h.curs
	if btnp(➡️) and c < 3 then
		h.curs += 1
	end
	if btnp(⬅️) and 1 < c then
		h.curs -= 1
	end

	-- character
	for b,v in pairs({[2]=1,[3]=-1}) do
		if btnp(b) then
			h.ords[c] += v
			hoc = h.ords[c]
			bounds={[31]=122,[33]=97,[96]=32,[123]=32}
			for f,t in pairs(bounds) do
				if (hoc==f) h.ords[c]=t break
			end
			h.chrs[c] = chr(h.ords[c])
		end
	end
end

function scorescol(x,rank)
	y=48
	print("nr score name",x,y)
	for i=rank,rank+8,2 do
		y += 8
		score = dget(i)
		name = loadname(i)
		print(pad(i,2),x,y)
		print(pad(score,5),x+12,y)
		print(name,x+40,y)
	end
end

function updatescorescreen()
	if btnp(❎) or btnp(🅾️) then
		mainscreen()
		g.score = 0
	end
end

function scorescreen()
	staupdate = updatescorescreen
	stadraw = function() end
	cls(bc)
	drawtopbar()
	print("00",90,8)
	t = "h i g h s c o r e s :"
	print(t, 20, 28)
	scorescol(8,1)
	scorescol(64,2)
end

-->8
-- font

function sprtochar(sprn)
	-- sprn is sprite number
	-- convert sprite n to custom
	-- font format and return
	-- as table of 8 bytes
	char = {}
	x,y = sprnxy(sprn)
	for i=0,7 do
		a = i + 1
		char[a] = 0
		for j=0,7 do
			if sget(x+j, y+i) == 7 then
				char[a] |= 2^j
			end
		end
	end
	return char
end

function fblock(src, dest, len)
	--font copy block
	--src is sprite number
	--dest is p8scii code
	daddr = 0x5600 + dest * 8
	for i=1,len do
		char = sprtochar(src)
		poke(daddr, unpack(char))
		src += 1
		daddr += 8
	end
end

function loadfont()
	-- load custom font from sprite
	-- sheet and activate it

	--letters, numbers
	fblock(64,97,26)
	fblock(96,48,10)
	--symbols
	dests = {21,45,58,131,139,142,145,148,151,33}
	for i=1,#dests do
		fblock(111+i,dests[i],1)
	end

	--switch and metadata
	poke(0x5f58,0x1 | 0x80)
	poke(0x5600,4,8,8)
end

-->8
-- swap

function sprnxy(sprn)
	x = (sprn%16)*8
	y = flr(sprn/16)*8
	return x,y
end

function getspr(sprn)
	x,y = sprnxy(sprn)
	sprite = {}
	for i=0,7 do
		sprite[i] = {}
		for j=0,7 do
			sprite[i][j] = sget(x+i,y+j)
		end
	end
	return sprite
end

function setspr(sprn,sprite)
	x,y = sprnxy(sprn)
	for i=0,7 do
		for j=0,7 do
			sset(x+i,y+j,sprite[i][j])
		end
	end
end

function swapspr(sprna,sprnb)
	spra = getspr(sprna)
	sprb = getspr(sprnb)
	setspr(sprna,sprb)
	setspr(sprnb,spra)
end

function along()
	for i=1,3 do
		swapspr(i,36+i)
	end
	swapspr(10,40)
	music(60)
end

pachinko = {2,2,3,3,0,1,0,1,5,4}
codestep = 1
function updatecode()
	if (btn()==0) return

	req = pachinko[codestep]
	for btnid=0,5 do
		if btnp(btnid) then
			if btnid==req then
				codestep +=1
			else
				codestep = 1
				return
			end
		end
	end

	if codestep > #pachinko then
		codestep = 1
		along()
	end
end

-->8
-- encoded

snd = {
	coin="゛ちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちきヌ▥し[\-0\0\|Pり⬇️\0\f4003クト\015\014,。、やこネクんトあたx8xxkッなエイ🅾️⌂i*ヌすヌヌヒあそ-l8-ちfF@\*\nマnぬ8uくへね➡️Z⌂m,it*★ちタソˇ●hittけすあ⬅️⌂N^mjちほワフフサあYl-)((\|j❎ラ⬇️J웃▮▶h¥う¥!iそゅ⌂◆お^jffけけすちちちiiijちちむヒコサつちちちちちむちたしちちちちた∧ちちちちちちたすちちちちちちちちちちちタ\tちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちち",
	kill="ちちちちちちちちちちちちちちちちちちちちちけ\0\0\0◀◝ワ^○◝◝◝◝ヲ@\0\0\0\0\0■UUVちYˇP\0\0\0\+◝◝◝ュ\0\0\0?◝◝◝ら\0\0\0\0\0\+UUiUUちjちR(@\0\0@ャら\0?ユ\0め◝◝◝◝◝ナ\0\0\0\0\0\0\0\*UZち⧗テTE@\+\*\|\*ほ◝\0゜\0\0C◝◝◝◝◝\0\0\0\0UUjしちUUUUU」d%H\0\0\0Rヤス9\-ム\*█◝◝◝ョ◜fッT\0\0\0\+Tャよ◝◝l%@\0\0\0▮\+\0$か◝◝\-◝○◝◝➡️UA\0\0\0/◝$ツ◝◝P\0◀ちちあˇUUUUち@\0\0\"◝",
	bonk="ちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちˇちちちたUZちつたUZッあホUZたUoョP\*oたjヲcˇョ\aEよ◝⬆️\*eさ?◝ホ\t\0ョ\aマ◝「…\a⬅️◜やZンU@U\#◜に◝@\0Fちみし◝ン\0\0V◝マち◝ン@\0\^◜ちす◝ン@\0[◝ホj◝◜\0\0\v◝みZ◝◜ヘ\0\0つしUo◝ッら\0\+しちい◝◝いˇD\*‖ゆ◝◝◝ッに\0\0Vつ◝にヤ◜U@\0\|Eよに◝◝ミハU\0T*UちつマゆjˇUUちつミ◝よつハi\0P\+Uijちちミすち∧しUUjちちちちしj∧つちたVUたUVちちちちちちち∧しYUiZちちちちちちちッちちちちしUUUちたUeZˇUZちちちちちちちちちちちちちちちˇZちちちちちちちちˇjちちちちちちちちたUUUUZちちちちちちちちちちちちちちちˇZちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちjちちちちちちちちちちちちちちちちちUUUちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちち",
	dies="ちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちたjちちちちちちちちjちちちjあたちたjあちちUちちちしVちちしUoちしZVンちUしoマたZU◜ちˇしoマたZUゆjˇしoちハiFッゆV…よつˇし•ヒン¥AョnAハo∧さo∧ンUVッにˇUoすョ‖AッoニT゜マ◝‖A~つンU\^みよをP¥い◝UAと○ョU\^みヤルT◀ヒよ➡️`[V◜a█jZ◝●Aとgョ‖\+し_ン‖\^しにルUWノ○ケˇ゜Q◝り@nU◝\*Eや\*◝J\*ヲ\vュ‖\vル゜ハさ•ケ○█T/カ◜@Q◝B◜\+\*◜Gヲ\0\#◜[ヲ\|\aン•ホ⁘\aン_ヲX\aレoュ‖\#レ_ヲ\+\*ヲ゜◜A\0ョ•◝\+Aや\a◝▮@~A◝▒P゜🐱よユ\0+ルoンU\aユ\015◝█\*よさよ█し?█○◜P\*◜oョ\0◀◝\0◝ッ@\tQにュ▮\aッ\|◝シ\0.ヌヤョ\-オゆ\#◝ン\0¥レ゜◝\0Qゆ\*◝ン\0\nユ\015◝オ\0゜@よ◝\0\0◝\0◝ャ\*\*ユ•◝ユ\#\aユ\015◝ら\r_ナ゜oナ\|\vオ○◝\0.に\0>よ@$?▒ョ○@to\*ュ◝\0ナよ\*ル◝\*ら○\-ユョ\-らョ\-ラュ\#█ュ\015ネュ\a\0ヲ/んユ゜\-ナ/[ユ\v\vユ?♥ル\v\vユ/Kユ\*\aル゜タュ\#\-ヲ゜クュ\*Aュ\aマョ\0@よ\aル◝\0▮?\aン○\#…>\#ョ○@ひ?\*ュ/ユ\#\015ユ'⬅️◝\0らよ\nルよニ\b\#ユにF◝\0█o\nルにル\*\aユ_⬇️◝ら ▶り~•◜\#\*=\vニ◝ル\0\-ノ○W◝ら\0\v…ゆo◝\*`。🐱レ_◝\0\0むOホ○ュ\0@ま\a➡️○ュ\0\-ち]ロよョ\*█や\+ヨ○ョ\0▮⬇️█<つ◝\0\07わ]○◝ら\*▶ナあ[◝ひ\-さョ▶ゆ◝ョ\0 U\+Yよ◝\0▮&●i○◝ユ@\015uコGよヲ\0A゛uフ◝◝@@\nYV◝◝そB\^maに◝◝T@り■\|j◝H 1\015\\z◝◝|@❎Y^ャよ◜や\*ハOUみャ◝ヲ\0\+ˇUg◝◝キ…‖PˇZつ◝た\|\0わ[ち◝◝◝▥◀VUZˇちつッEナ◀Aさjミ◝か🐱ケ\tUちちめ◝マ}@めあたeつモつf`UU▥あkむ◜.ら&UeUちちたけき\|Qjメめ◝◝◝よ⬆️EYくUjたち_ヲ•\|yくˇieすちッ●サoすしちちすちつくd[ˇiちつたjちよッちjちUUfちUeちˇしiす➡️Vˇちちに◝◝ヤつみVˇ‖UUjˇ▥UUたちちjしZちちちちjちちちよッちちたˇUUUejちちちちちちちちちちちちちちちちちちUしjˇZたZちちちjちちちちちた∧ちちちちちちちちちちちちちちちちたUUVちちちちちちちちちちちちちちちちああたUUUVたjちちちちちちちちちちˇUVちちちちちちちちちちちちちちちちちˇUUUUVZちちちちちちちちちちちしUUUUちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちち",
	brks="|OちハzYnaiあてンz*すmIすd[f∧fZ∧ホ∧jたVたjmWちZ∧▥jfjk◝よよ◜ちP\0\0\0\0@&▥ミャヤ◝モミちハU★ˇIし⌂いjミすソオロ]つあ}めッz&⌂iたちサVャjYUj▥uたiたfちejiふしあいおv]ちJほと*ˇむた∧すサたjちち⬅️jちZちちたちあjZたしてホハ:ZちちよA∧ホすYすちちちあちちちち∧ちたちしちZたZちち0⌂ツZjたfあjしちあちちちすあちち^YすmjちちちjちちjたちちjちちたjちちあすすちちちちちちたすちちちあちあしちしjZあちちちちすすすeちすす∧すjZjすちたああちあち▥∧そjちちたすたたちちjちすちちちしちjすちちあたeちちすあjたちちちZちちちすちちちjjちあちちiちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちち",
	eats="ちちちちちちしちちちちちちちちちたZたちVちちちちちˇちちちちちしち∧たVちち∧ちちちちち▥jˇちVちしちちちたVヲV…たVカな[マよマゆ\*ホ•…iVしちˇUちつYなちちˇちVハjˇちVしちしjしjちなjなZハo▒ゆVしjˇjVちつハoハjUむVたVたjしたEちちちちつ◜たVしUたUZちたVちちちちつッハkノ\^ン\+たZむちちちしちたUUちしUちˇちち◝◝マUUUUVちち◜ちしUUUUZちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちち",
}

screens = {
	"\*v!+!+!+!\*#\#\*\015                                ",
	"\*<■\*\v!+!+!\*:!+!+!+!\*□\#\*\015                                ",
	"\*J■\*\n!+!!-!\**!+!!+!\*\a▶「\*\f\#\*\*'(\*\f  '(         \*\#   '(         \*\# ",
	"\*K!!\*\*!,\*+!+!+!\*\-*\*\#*\*\v**\*\#**\*\b\#***\*\#***\*\^■    \*\#              \*\#          ",
	"\*);;;;\*\f;;;;\*\f;;;;\*\n■\*\*;;;;\*\n*\*\014**\*\r***\*\f****\*\^$%\*\-*****\*\^45        \*\-             \*\-     ",
	"\* !!\*\#!!!!!!!!!!!!!!\*\f!!!!\*\f!!!!\*\|!+!+!\*\-!!!!\*\014!!\*\014!!\*\-!+!+!-!\*\|!!\*\014!!\*\r⁙                                ",
	"\* !!!!!!!!!!!!!!!!!\*\v;;;!!\*\v;;;!!\*\v!!!!\*\^,\*•▶「\*\+▶「\*\a'(\*\+'(\*\a'(\*\|■'(\*\+                                ",
	"\* !!!!!!!!!!!!!!!!!!\*\r!!!\*\|;;;;\*\+!!!\*\r!\*」⁙\*\t*\*\#****\*\-*\*\|**\*\#****\*\-**\*\#***\*\#****\*\-***    \*\#    \*\-       \*\#    \*\-   ",
	"\* !!!!!!!!!!!!!!!!\*\+!!!!!!!!!!!;;;;\*\*!!!\*\b;;;;\*\*!!!\*\r!!,\*\b!!\*\n*\*\#*\*\v**\*\#*\*\n***\*\#*\*\a⁙\*\*****\*\#*   \*\#   \*\*    \*\#    \*\#   \*\*    \*\# ",
	"\* !!!!!!!!!!!!!!!!!!!!!!!!\*\*;;;;;\*\*!\*\^!!\*\*;;;;;\*\*!\*\^,!\*\a!\#\*\+!!!!!!!!!!*\*\014!**\*\r!***\*\v$%****\*\t⁙45     \*\*  \*\#           \*\*  \*\#      ",












































































































}

__gfx__
00000000ccccccccccc222cccc222ccccc222cccccc222ccc99cc99cccc555cccc222222cc222222cc222222cc222222c22cc22ccc555555cc000ccccc333ccc
00000000cccccccccc222222c222222cc222222ccc222222c22cc22ccc555555cc222222cc222222cc22222222222266c22cc22ccc555555c00900cc333333cc
00700700ccccccccccc9099ccc9099cccc9099ccccc9099cc922229cccc9099c22222266222222662222226622222222c222222c555555660009000cc9909ccc
00077000ccccccccccc99ccccc99cccccc99ccccccc99cc9c000000cccc99ccc22222222222222222222222222222222c222222c555555550999050cccc99ccc
00077000ccccccccc000000c0900009cccc009ccc0000000ccc99cccc000000c22222222222222222222222222222222c222222c555555550000000cc000000c
00700700ccccccccc922229cc2222cccccc222ccc92222cccc9999ccc955559c222222222222222222222222cc222222c222222c55555555c00500ccc933339c
00000000ccccccccc22cc22c22cc22cccc922cccc22cc22cc222222cc55cc55ccc22cc22ccc2ccc2cc2ccc2ccc22cc22c226622ccc55cc55cc000cccc33cc33c
00000000ccccccccc99cc99c99cc99ccccc99ccc99cccc99cc2222ccc99cc99ccc22cc22ccc2ccc2cc2ccc2cccccccccc222222ccc55cc55ccccccccc99cc99c
ccccccccccccccccccccccccccccccccccccccccc9cccc9ccccccccc9999494444440400c9cccc9cccccc9cccc9cccccccc9c9ccccccccc9c9cccccc00000000
ccc9c9cccc9cc9ccc9cccc9ccc9ccc9ccc9ccc9c999cc999cccccccc9999494444440400c9cccc9cccccc9cccc9cccccccc9c9ccccccccc9c9cccccc00000000
cc2929cccc9cc9cccc9cc9ccc909c909c909c909c99cc99cc99cc99c9999494444440400c9c9c99cccccc9c9c99cccccc9c9c9ccccccc9c9c9cccccc00000000
c9222229c292292cc292292cc292229cc292229ccc9229cc999229999999494444440400c9c9c99cccccc9c9c99cccccc9c9c99cccccc9c9c99ccccc00000000
c292929c22222222222222222222222222222222ccc22cccc9c22c9c99994944444404009292929ccccc9292929ccccc9292929ccccc9292929ccccc00000000
99222222c222222cc222222cc222222cc222222ccc9cc9cccc9cc9cc999949444444040099292229cccc99292229cccc92222229cccc92222229cccc00000000
22292299cc9cc9cccc9cc9cccc9cc9cccc9cc9ccc9cccc9ccc9cc9cc999949444444040092222929cccc92222929cccc92922299cccc92922299cccc00000000
c222222ccc9cc9ccc9cccc9ccc9cc9ccc9cccc9ccccccccccccccccc000000000000000092929229cccc92929229cccc99222929cccc99222929cccc00000000
4404440440444444000000000000000099999990cccccccc09999999c99994944440400c00000000999999949999999440444444999999944044444400000000
44044404404444444444444400000000999999909999999909999999c99994944440400c00000000900000409444444040444444944444404044444400000000
4040440040444444c0c0c0c000000000999999909999999909999999c99994944440400c00000000904444909449944040444444944994404044444400000000
0444004400000000cccccccc00000000999999909999999909999999c99994944440400c00000000904444909494404000000000949440400000000000000000
0444044444444044cccccccc00000000444444409999999904444444c99994944440400c00000000904444909494404044444044949440404444404400000000
0440044444444044cccccccc00000000999999904444444409999999c99994944440400c00000000904444909440044044444044944004404444404400000000
4004404044444044cccccccc00000000444444409999999904444444c99994944440400c00000000949999909444444044444044944444404444404400000000
4404440400000000cccccccc00000000444444404444444404444444c99994944440400c00000000400000004000000000000000400000000000000000000000
4c4c4c4ccccc4c4c4c4ccccc0000000044444440444444440444444400000000000000000000000000000000cccccccc00000000c292292cccc9cccc00000000
c4c4c4c4ccccc4c4c4c4cccc0000000044444440444444440444444499994944444404000000000000000000cc9944cc0000000092222222cc040ccc00000000
4c4c4c4ccccc4c4c4c4ccccc0000000044444440444444440444444499994944444404000000000000000000c999944c0000000022292229c04440cc00000000
cccccccccccccccccccccccc0000000044444440000000000444444499994944444404000000000000000000c999944c00000000292229229444449c00000000
cccccccccccccccccccccccc0000000000000000444444440000000099994944444404000000000000000000c999944c00000000ccc99cccc04440cc00000000
cccccccccccccccccccccccc0000000044444440000000000444444499994944444404000000000000000000c999944c00000000cc9999cccc040ccc00000000
cccccccccccccccccccccccc0000000000000000000000000000000099994944444404000000000000000000cc9944cc00000000cc9999ccccc9cccc00000000
cccccccccccccccccccccccc0000000000000000cccccccc0000000099994944444404000000000000000000cccccccc00000000ccc99ccccccccccc00000000
07000000770000000770000077000000777000007770000007000000707000007770000077700000707000007000000070700000707000000700000077000000
70700000707000007000000070700000700000007000000070700000707000000700000000700000707000007000000077700000777000007070000070700000
70700000707000007000000070700000700000007000000070000000707000000700000000700000707000007000000077700000777000007070000070700000
77700000770000007000000070700000770000007700000077700000777000000700000000700000770000007000000070700000777000007070000077000000
70700000707000007000000070700000700000007000000070700000707000000700000000700000707000007000000070700000777000007070000070000000
70700000707000007000000070700000700000007000000070700000707000000700000070700000707000007000000070700000777000007070000070000000
70700000770000000770000077000000777000007000000007000000707000007770000007000000707000007770000070700000707000000700000070000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07000000770000000770000077700000707000007070000070700000707000007070000077700000000000000000000000000000000000000000000000000000
70700000707000007000000007000000707000007070000070700000707000007070000000700000000000000000000000000000000000000000000000000000
70700000707000007000000007000000707000007070000070700000707000000700000000700000000000000000000000000000000000000000000000000000
70700000770000000700000007000000707000007070000070700000070000000700000007000000000000000000000000000000000000000000000000000000
70700000707000000070000007000000707000007070000077700000707000000700000070000000000000000000000000000000000000000000000000000000
77000000707000000070000007000000707000000700000077700000707000000700000070000000000000000000000000000000000000000000000000000000
07700000707000007700000007000000070000000700000070700000707000000700000077700000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77700000070000007770000077700000707000007770000077700000777000007770000077700000000000000000000000000000000000000000000000000000
70700000070000000070000000700000707000007000000070000000007000007070000070700000000000000000000000000000000000000000000000000000
70700000070000000070000000700000707000007000000070000000007000007070000070700000000000000000000000000000000000000000000000000000
70700000070000007770000077700000777000007770000077700000007000007770000077700000000000000000000000000000000000000000000000000000
70700000070000007000000000700000007000000070000070700000007000007070000000700000000000000000000000000000000000000000000000000000
70700000070000007000000000700000007000000070000070700000007000007070000000700000000000000000000000000000000000000000000000000000
77700000070000007770000077700000007000007770000077700000007000007770000077700000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70700000000000000700000007777700077777000777770007777700077777000777770007000000000000000000000000000000000000000000000000000000
70700000000000000700000077000770777007707700077077007770777077707707077007000000000000000000000000000000000000000000000000000000
70700000777000000000000077000770770007707707077077000770770007707770777007000000000000000000000000000000000000000000000000000000
70700000000000000700000077707770777007707700077077007770770007707707077007000000000000000000000000000000000000000000000000000000
70700000000000000700000007777700077777000777770007777700077777000777770000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc999c999c999c999c999ccccccccccc999c999cccc555cccc999ccc9ccc9c9c9cccc9ccc9cccc000ccccc999c999c999cccccccccccccccc9cccc999c999ccc
cc9c9c9c9c9c9c9c9c9c9ccc9944cccc9c9c9c9ccc555555cccc9ccc9ccc9c9c9cccc9ccc9ccc00900cccc9c9c9c9c9c9ccccccccccccccc040ccc9c9c9c9ccc
cc9c9c9c9c9c9c9c9c9c9cc999944ccc9c9c9c9cccc9099ccccc9ccc9ccc9c9c9cccc9ccc9cc0009000ccc9c9c9c9c9c9cccccccccccccc04440cc9c9c9c9ccc
cc9c9c9c9c9c9c9c9c9c9cc999944ccc9c9c9c9cccc99ccccc999ccc9ccc9c9c9cccc9ccc9cc0999050ccc9c9c9c9c9c9ccccccccccccc9444449c9c9c9c9ccc
cc9c9c9c9c9c9c9c9c9c9cc999944ccc9c9c9c9cc000000ccccc9ccc9ccc9c9c9cccc9ccc9cc0000000ccc9c9c9c9c9c9cccccccccccccc04440cc9c9c9c9ccc
cc9c9c9c9c9c9c9c9c9c9cc999944ccc9c9c9c9cc955559ccccc9ccc9cccc9cc9cccc9ccc9ccc00500cccc9c9c9c9c9c9ccccccccccccccc040ccc9c9c9c9ccc
cc999c999c999c999c999ccc9944cccc999c999cc55cc55ccc999ccc999cc9cc999cc9ccc9cccc000ccccc999c999c999cccccccccccccccc9cccc999c999ccc
ccccccccccccccccccccccccccccccccccccccccc99cc99ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
9999999499999994cccccccccccccccc9999999499999994cccccccccccccccccccccccc9999999499999994cccccccccccccccccccccccc9999999499999994
9000004090000040cccccccccccccccc9000004090000040cccccccccccccccccccccccc9000004090000040cccccccccccccccccccccccc9000004090000040
9044449090444490cccccccccccccccc9044449090444490cccccccccccccccccccccccc9044449090444490cccccccccccccccccccccccc9044449090444490
9044449090444490cccccccccccccccc9044449090444490cccccccccccccccccccccccc9044449090444490cccccccccccccccccccccccc9044449090444490
9044449090444490cccccccccccccccc9044449090444490cccccccccccccccccccccccc9044449090444490cccccccccccccccccccccccc9044449090444490
9044449090444490cccccccccccccccc9044449090444490cccccccccccccccccccccccc9044449090444490cccccccccccccccccccccccc9044449090444490
9499999094999990cccccccccccccccc9499999094999990cccccccccccccccccccccccc9499999094999990cccccccccccccccccccccccc9499999094999990
4000000040000000cccccccccccccccc4000000040000000cccccccccccccccccccccccc4000000040000000cccccccccccccccccccccccc4000000040000000
99999994cccccccc99999994cccccccc99999994cccccccc99999994cccccccc99999994cccccccccccccccc99999994cccccccc99999994cccccccccccccccc
90000040cccccccc90000040cccccccc90000040cccccccc90000040cccccccc90000040cccccccccccccccc90000040cccccccc90000040cccccccccccccccc
90444490cccccccc90444490cccccccc90444490cccccccc90444490cccccccc90444490cccccccccccccccc90444490cccccccc90444490cccccccccccccccc
90444490cccccccc90444490cccccccc90444490cccccccc90444490cccccccc90444490cccccccccccccccc90444490cccccccc90444490cccccccccccccccc
90444490cccccccc90444490cccccccc90444490cccccccc90444490cccccccc90444490cccccccccccccccc90444490cccccccc90444490cccccccccccccccc
90444490cccccccc90444490cccccccc90444490cccccccc90444490cccccccc90444490cccccccccccccccc90444490cccccccc90444490cccccccccccccccc
94999990cccccccc94999990cccccccc94999990cccccccc94999990cccccccc94999990cccccccccccccccc94999990cccccccc94999990cccccccccccccccc
40000000cccccccc40000000cccccccc40000000cccccccc40000000cccccccc40000000cccccccccccccccc40000000cccccccc40000000cccccccccccccccc
99999994ccc9c9cc99999994cccccccc99999994cccccccc99999994cccccccc99999994cccccccccccccccc99999994cccccccc99999994cc222ccccccccccc
90000040ccc9c9cc90000040cccccccc90000040cccccccc90000040cccccccc90000040cccccccccccccccc90000040cccccccc90000040222222cccccccccc
90444490c9c9c9cc90444490cccccccc90444490cccccccc90444490cccccccc90444490cccccccccccccccc90444490cccccccc90444490c9909ccccccccccc
90444490c9c9c99c90444490cccccccc90444490cccccccc90444490cccccccc90444490cccccccccccccccc90444490cccccccc90444490ccc99ccccccccccc
904444909292929c90444490cccccccc90444490cccccccc90444490cccccccc90444490cccccccccccccccc90444490cccccccc90444490c000000ccccccccc
904444909222222990444490cccccccc90444490cccccccc90444490cccccccc90444490cccccccccccccccc90444490cccccccc90444490c922229ccccccccc
949999909292229994999990cccccccc94999990cccccccc94999990cccccccc94999990cccccccccccccccc94999990cccccccc94999990c22cc22ccccccccc
400000009922292940000000cccccccc40000000cccccccc40000000cccccccc40000000cccccccccccccccc40000000cccccccc40000000c99cc99ccccccccc
9999999499999994cccccccccccccccc9999999499999994cccccccccccccccc99999994cccccccccccccccc99999994cccccccccccccccc99999994cccccccc
9000004090000040cccccccccccccccc9000004090000040cccccccccccccccc90000040cccccccccccccccc90000040cccccccccccccccc90000040cccccccc
9044449090444490cccccccccccccccc9044449090444490cccccccccccccccc90444490cccccccccccccccc90444490cccccccccccccccc90444490cccccccc
9044449090444490cccccccccccccccc9044449090444490cccccccccccccccc90444490cccccccccccccccc90444490cccccccccccccccc90444490cccccccc
9044449090444490cccccccccccccccc9044449090444490cccccccccccccccc90444490cccccccccccccccc90444490cccccccccccccccc90444490cccccccc
9044449090444490cccccccccccccccc9044449090444490cccccccccccccccc90444490cccccccccccccccc90444490cccccccccccccccc90444490cccccccc
9499999094999990cccccccccccccccc9499999094999990cccccccccccccccc94999990cccccccccccccccc94999990cccccccccccccccc94999990cccccccc
4000000040000000cccccccccccccccc4000000040000000cccccccccccccccc40000000cccccccccccccccc40000000cccccccccccccccc40000000cccccccc
99999994cccccccc99999994cccccccc99999994cccccccc99999994cccccccc99999994999949444444040099999994cccccccccccccccccccccccc99999994
90000040cccccccc90000040cccccccc90000040cc9944cc90000040cccccccc90000040999949444444040090000040cccccccccccccccccccccccc90000040
90444490cccccccc90444490cccccccc90444490c999944c90444490cccccccc90444490999949444444040090444490cccccccccccccccccccccccc90444490
90444490cccccccc90444490cccccccc90444490c999944c90444490cccccccc90444490999949444444040090444490cccccccccccccccccccccccc90444490
90444490cccccccc90444490cccccccc90444490c999944c90444490cccccccc90444490999949444444040090444490cccccccccccccccccccccccc90444490
90444490cccccccc90444490cccccccc90444490c999944c90444490cccccccc90444490999949444444040090444490cccccccccccccccccccccccc90444490
94999990cccccccc94999990cccccccc94999990cc9944cc94999990cccccccc94999990999949444444040094999990cccccccccccccccccccccccc94999990
40000000cccccccc40000000cccccccc40000000cccccccc40000000cccccccc40000000000000000000000040000000cccccccccccccccccccccccc40000000
99999994cccccccc99999994cccccccc99999994cccccccc99999994cccccccc99999994c99994944440400c99999994cccccccccccccccccccccccc99999994
90000040cccccccc90000040cccccccc90000040cc9944cc90000040cccccccc90000040c99994944440400c90000040ccccccccc9ccc9cccccccccc90000040
90444490cccccccc90444490cccccccc90444490c999944c90444490cccccccc90444490c99994944440400c90444490cccccccc909c909ccccccccc90444490
90444490cccccccc90444490cccccccc90444490c999944c90444490cccccccc90444490c99994944440400c90444490ccccccccc922292ccccccccc90444490
90444490cccccccc90444490cccccccc90444490c999944c90444490cccccccc90444490c99994944440400c90444490cccccccc22222222cccccccc90444490
90444490cccccccc90444490cccccccc90444490c999944c90444490cccccccc90444490c99994944440400c90444490ccccccccc222222ccccccccc90444490
94999990cccccccc94999990cccccccc94999990cc9944cc94999990cccccccc94999990c99994944440400c94999990cccccccccc9cc9cccccccccc94999990
40000000cccccccc40000000cccccccc40000000cccccccc40000000cccccccc40000000c99994944440400c40000000ccccccccc9cccc9ccccccccc40000000
9999999499999994cccccccccccccccc99999994cccccccc99999994cccccccccccccccc9999999499999994cccccccccccccccc9999999499999994cccccccc
9000004090000040cccccccccccccccc90000040cccccccc90000040cccccccccccccccc9000004090000040cccccccccccccccc9000004090000040cccccccc
9044449090444490cccccccccccccccc90444490cccccccc90444490cccccccccccccccc9044449090444490cccccccccccccccc9044449090444490cccccccc
9044449090444490cccccccccccccccc90444490cccccccc90444490cccccccccccccccc9044449090444490cccccccccccccccc9044449090444490cccccccc
9044449090444490cccccccccccccccc90444490cccccccc90444490cccccccccccccccc9044449090444490cccccccccccccccc9044449090444490cccccccc
9044449090444490cccccccccccccccc90444490cccccccc90444490cccccccccccccccc9044449090444490cccccccccccccccc9044449090444490cccccccc
9499999094999990cccccccccccccccc94999990cccccccc94999990cccccccccccccccc9499999094999990cccccccccccccccc9499999094999990cccccccc
4000000040000000cccccccccccccccc40000000cccccccc40000000cccccccccccccccc4000000040000000cccccccccccccccc4000000040000000cccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc99cc9cccc9cc9c9cccccccccccccccccccccc99cc99c99cc999c999c9c9cccccccccccccccccccccccccc99cc99cc9cc99cc999cc99ccccc
ccccc99999ccc9cc9c9c9ccc9c9c9c9ccccccccccccc9c9cc9cc9ccc9ccc9c9c9ccc9ccc999cccccccccccccc99999ccc9cc9ccc9ccc9c9c9c9c9ccc9ccccccc
cccc99ccc99cc9cc9c9c9ccc9c9cc9cccccccccccccc9c9cc9cc9ccc9ccc9c9c9ccc9ccc999ccccccccccccc99c9c99cc9cc9ccc9ccc9c9c9c9c9ccc9ccccccc
cccc99c9c99ccccc99cc9ccc999cc9cccccccccccccc9c9cccccc9cc9ccc99cc99cc99cc999ccccccccccccc999c999cccccc9cc9ccc9c9c99cc99ccc9cccccc
cccc99ccc99cc9cc9ccc9ccc9c9cc9cccccccccccccc9c9cc9cccc9c9ccc9c9c9ccc9ccc999ccccccccccccc99c9c99cc9cccc9c9ccc9c9c9c9c9ccccc9ccccc
ccccc99999ccc9cc9ccc9ccc9c9cc9cccccccccccccc9c9cc9cccc9c9ccc9c9c9ccc9ccc999cccccccccccccc99999ccc9cccc9c9ccc9c9c9c9c9ccccc9ccccc
cccccccccccccccc9ccc999c9c9cc9cccccccccccccccccccccc99ccc99c9c9c999c999c9c9ccccccccccccccccccccccccc99ccc99cc9cc9c9c999c99cccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccc4404440444044404440444044404440444044404440444044404440444044404440444044404440444044404440444044404440444044404cccccccc
cccccccc4404440444044404440444044404440444044404440444044404440444044404440444044404440444044404440444044404440444044404cccccccc
cccccccc4040440040404400404044004040440040404400404044004040440040404400404044004040440040404400404044004040440040404400cccccccc
cccccccc0444004404440044044400440444004404440044044400440444004404440044044400440444004404440044044400440444004404440044cccccccc
cccccccc0444044404440444044404440444044404440444044404440444044404440444044404440444044404440444044404440444044404440444cccccccc
cccccccc0440044404400444044004440440044404400444044004440440044404400444044004440440044404400444044004440440044404400444cccccccc
cccccccc4004404040044040400440404004404040044040400440404004404040044040400440404004404040044040400440404004404040044040cccccccc
cccccccc4404440444044404440444044404440444044404440444044404440444044404440444044404440444044404440444044404440444044404cccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

__gff__
0100000000000000000000000000000000000000000000111100000000000000131311001111111111001131315151001111110011111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010101010101212b212b212b2101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000010101010101010101010101010101012121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000010101010101010101010101010101010101010101010101010101010101012100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a2a01012a2a0101012a2a0101012a2a00000000000000000000000000000000010101010101010101010101011601010101010101010101010101010101012100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a012a012a012a012a01012a012a010100000000000000000000000000000000010101010101010101010101010101010101010101010101010101010101012100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a192a012a012a012a01012a012a0201000000002a2a2a2a2a2a2a2a00000000260101010101010101010101010101010101010101010101010101010101012100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a2a01012a2a01012a01012a01012a01000000002a0101010101012a00000000361301010101010101010101010101010101010101010101010101010101012100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a012a012a3b2a012a17182a0101012a000000002a0101010101012a00000000010101010101010101010101010101010101010101010101010101010101012100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a012a012a3b2a012a27282a0111012a000000002a0101010101012a00000000010101010101010101010101010101010101010101010101010101010101012100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a2a01012a012a01012a2a01012a2a01000000002a2a2a2a2a2a2a2a00000000010114010101010101010101010101010101010101010101010101010101012100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000010101010101010101010101010101010101010101010101010101010101012100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010101010101010101010101010101010000000000000000000000000000000001010101010101010101013b010101010101020101010114010101010101012100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000010102150f01010101012c2c2c0101012121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0120202020202020202020202020200100000000000000000000000000000000012020202020202020202020202020010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100001036010360103601036010360103601036011350113501135011350113501135011350123401234012340123401234012340123400000000000000000000000000000000000000000000000000000000
010100001333013330133301333013330133301333014320143201432014320143201432014320153101531015310153101531015310153100030000300003000030000300003000030000300003000030000300
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e000026320263201f32021320233202432026320263201f320303001f3201f32028320283202432026320283202a3202b3202b3201f320303001f3201f3202432024320263202432023320213202332023320
010e10002432023320213201f320213202132023320213201f3201e3201f3201f3201f3201f3201f3201f3202f3002f3002b3002d3002f3002b3002d3002d30026300283002a300263002b3002b300283002a300
010e00002f3202f3202b3202d3202f3202b3202d3202d32026320283202a320263202b3202b320283202a3202b3202832025320253202332025320213203030021320233202532026320283202a3202b3202b320
010e00002a3202a32028320283202a3202a3202132021320253202532026320263202632026320263203030026320263201f3201e3201f3201f32028320283201f3201e3201f3201f32026320263202432024320
010e00002332023320213201f3201e3201f32021320213201a3201c3201e3201f320213202332024320243202332023320213202132023320263201f3201f3201e3201e3201f3201f3201f3201f3201f3201f320
010e00001a3101a3101a3101a31015310153101731017310173101731017310173101831018310183101831018310183101731017310173101731017310173101531015310153101531015310153101331013310
010e1000133101331013310133101a3101a310173101731013310133101a3101a3100e31018310173101531018300183001730017300183001730015300133001530015300153001530012300123001330013300
010e00001731017310173101731015310153101331013310173101731013310133101831018310183101831018310183101731017310183101731015310133101531015310153101531012310123101331013310
010e10001331013310173101731018310183101a3101a3100e3100e31013310133101331013310133103030013300133001330013300133001330012300123001230012300123001230010300103001330013300
010e00001331013310133101331013310133101231012310123101231012310123101031010310133101331010310103101531015310153103030015310303001531015310153101531015310153101731017310
010e00001a3101a31019310193101a3101a310123101231015310153101a3101a3100e3100e310183101831017310173101a3101a310173101731018310183101c3101c310183101831017310173101531015310
010e000013310133101a3101a3101a3101a31030300303000e3100e3100e3100e310123101231010310103101331013310123101231013310133100c3100c3100e3100e31013310133100e3100e3101331013310
010e00002e3202e3202d3202d3202b3202b3202d3202d320263203030026320263202b3202b3201f32021320223202432026320263202632026320263202632029320293202b3202932027320263202732027320
010e10002932027320263202432026320263202b3202b3202432024320223202232022320223202232022320223002430026300263002630026300263002630029300293002b3002930027300263002730027300
010e000026320263202232024320263202832029320293202b3202b3202d3202d3202e3202e3202b3202d3202e3202b3202d3202d3202b3202d32029320293201d3201f320213202232024320263202732027320
010e0000263202632024320243202932029320223202232021320213202232022320223202232022320223201f3201f320263202432026320263201f3201f320273202632027320273201f320263201e32024320
010e00001f320223202132021320213202132030300303001a3201c3201e3201f320213202232024320243202232022320213202132022320263201f3201f3201e3201e3201f3201f3201f3201f3201f3201f320
010e00001331013310133101331013310133101131011310113101131011310113100f3100f3100f3100f3100f3100f3100e3100e3101a3101831016310153101631016310163101631015310153101631016310
010e1000163101631013310133101531015310123101231013310133100e3100e3101a310183101631015310163001630013300133001530015300123001230013300133000e3000e3001a300183001630015300
010e00001331013310133101331013310133101131011310113101131011310113100f3100f3100f3100f3100f3100f3100e3100e3101a3101831017310153101731017310173101731013310133101831018310
010e10001531015310113101131016310163100f3100f310153101531016310303001631016310163101630016300163001630016300163001530015300133001330011300113001330013300103001030000000
010e0000163101631016310163101631016310153101531013310133101131011310133101331010310103100c3100c3101131011310113101131030300303001531015310133101331011310113101331013310
010e000011310113100f3100f3100e3100e3100f3100f310113101131016310163101a3101a31018310183101a3101a3101a3101a3101a3101a31018310183101831018310183101831016310163101531015310
010e000013310133101a3101a310153101331012310103100e3100e3100e3100e31030300303000f3100f3100e3100e3100c3100c31016310163100c3100c3100e3100e310133103030013310133101331013310
010e18002532023320213202132021320263202332023320213203030021320213201c32021320253202132025320283202d3202d3202d3202d3202d3202d32028300283002d3002d30028300283002830028300
010e000028320283202d3202d320283202832028320283202a3202c3202d3202d320283202832028320283202a3202c3202d3202d3202b3202a320283202a3202b320283202a3202a32026320263202632021320
010e100023320243202332026320283202a3202b32023320253202632025320283202a3202b3202d320253202630028300263002b3002f3002d3002b3002a3002830026300253002530021300213002130021300
010e00002632028320263202b3202f3202d3202b3202a3202832026320253202532021320213202132021320263202132023320213201f3201e3201f320233202832023320253202132023320253202632028320
010e18002a3202b3202d3202d32026320263202a320283202632025320263202632021320263202a320263202a3202d32030320303203032030320303203032015300153000e3000e3001a300193001a3001a300
010e000024300303001a3101a3101f3101f3101e3101e3101c3101c3101a3101a3101f3101f3101e3101e3101c3101c3101e3101e3101a3101a310193101931015310153100e3100e3101a310193101a3101a310
010e10000e310303000e3100e3101a310193101a3101a3100e310303000e3100e3101a310193101a3101a3100e3000e3000d3000d30012300123000e3000e3001030010300153003030015300103001530010300
010e18000e3100e3100d3100d31012310123100e3100e3101031010310153103030015310103101531010310153101031015310153101c3101c31021310213101030010300153003030015300103001530010300
010e0000303003030021310213102631026310253102531023310233102131021310263102631025310253102331023310213102131023310233102531025310213102131026310263101a3101c3101e3101e310
010e10001a3101a3101f3101f3103030030300303003030020310203102131021310303003030030300303002030020300213002130030300303003030030300223002230023300233001f3001f3001c3001c300
010e0000223102231023310233101f3101f3101c3101c3101f3101f3102131015310213101f3101e3101c3101e3101a3101331013310303003030030300303001f3101f310213102131023300233001f3001f300
010e18001f3101f3101e3101e31023310233101f3101f31021310213101a3101a3100e3101a3100e3101a3100e3101a3100e3100e31015310153101a3101a3100000000000000000000000000000000000000000
011800001f320183001f320303001f32030300243202432026320273202632026320243202432022320213202632026320223202232021320223201f3201f3202232030300223203030022320303002632026320
011810002732029320223202232024320243202132021320213202132022320223202232022320223202232030300303003030030300303003030030300243000000000000000000000000000000000000000000
011800002432030300243202b300243202b30024320243202432022320213202132026320263202432022320213201f3201e3201e3201e3201e3201e3201e3201a3201a3201e3201e32021320213202432024320
011800002632027320263202632022320223201f3201f3201e3201e3201f3201f3201f3201f3201f3201f32024320303002432030300243203030024320243202432022320213202132026320263202432022320
01180000213201f3201e3201e3201e3201e3201e3201e3201a3201a3201e3201e320213202132024320243202632027320263202632022320223201f3201f3201e3201e3201f3201f3201f3201f3201f32000000
0118000013310133101f3101f3101d3101d3101b3101b3101531015310163101631018310183101a3101a3100e3100e31013310133101a3101a3101f3101f3101a310163101b3101d3101f310213102231022310
011810001d3101d3101f3101f3101b3101b3101d3101d3101131011310163101631022310243102631024310153001630015300133001130010300113001130018300183001d3001d30016300163001b3001b300
01180000223102431022310213101f3101d3101b3101b3101531015310163101631018310183101a3101a3100e3100e31013310133101a3101a3101f3101f3101a310163101b3101d3101f310213102231022310
011810001d3101d3101f3101f3101b3101b3101d3101d31011310113101631015310163101a31018310163100e3000e30013300133001a3001a3001f3001f3001a300163001b3001d3001f300213002230022300
01180000153101631015310133101131010310113101131018310183101d3101d31016310163101b3101b31018310183101a310263102431022310213101f3101e31022310213101f3101e3101c3101a3101a310
011800001e3101e3101a3101a3101f3101f31016310163101a3101a310133101231013310153101631013310153101631015310133101131010310113101131018310183101d3101d31016310163101b3101b310
0118000018310183101a310263102431022310213101f3101e31022310213101f3101e3101c3101a3101a3101e3101e3101a3101a3101f3101f31016310163101a3101a310133101331013310133101331000000
011500001885018950000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001f3301f33000000183301833000000000000000024330243300000021330000001f3301f3300000018330183300000000000000001f3301f330000001d330000001c330000001c330000001d33000000
010c00001f330000001833018330000001a3301a330000001c3301c3301c3301c330000001f3001f300003001f3301f330000001833018330003001c3000030024330243300000021330000001f3301f33000000
010c000018330183300000000000000001f3301f330000001d330000001c330000001c330000001d330000001f330000001833018330000001a3301a330000001833018330183301833000000000000000000000
0110080018300183000000000000000001f3001f300000001d300000001c300000001c300000001d300000001f300000001830018300000001a3001a300000001830018300183001830000000000000000000000
__music__
01 080d4344
00 090e4344
00 080f4344
00 09104344
00 0a114344
00 0b124344
02 0c134344
00 7f424344
01 14194344
00 151a4344
00 141b4344
00 151c4344
00 161d4344
00 171e4344
02 181f4344
00 7f424344
01 21254344
00 22264344
00 20274344
00 21284344
00 22294344
00 232a4344
02 242b4344
00 7f424344
01 2c314344
00 2d324344
00 2c334344
00 2d344344
00 2e354344
00 2f364344
02 30374344
00 7f424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
04 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
01 3c424344
00 3d424344
02 3e7f4344

