pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
function _update()
	if (done) stop("done")
	sndplaying()
end

rate = 5512

period = 256
hz = 31960.4 / period
lcn = hz / rate
i = 1
duration = 400

usrdta = 0x4300
dtalen = 2048
dtaend = usrdta+dtalen
done = false
final = false


function sndplaying()
	-- update playing sample snd
	-- returns true if snd playing
	-- skip by pressing ❎
	-- uses sndp table
	
	local buffer = stat(108)
	-- wait for buffer
	if final then
		if buffer == 0 then
			done = true
		end
		return
	end
	
	local todo = dtalen - buffer
	local memend = min(todo,dtaend)
	local frlen = memend - adr
	local fradr = adr
	
	-- fill memory
	while 0 < period do
		while i < duration do
			local sign = sgn(sin(lcn*i))
			local sam = sign*63 + 128
			i += 1
			poke(adr,sam)
			adr += 1
			if adr == memend then
				adr = usrdta
				-- play if full
				serial(0x808,fradr,frlen)
				return
			end
		end

		period -= 1
		hz = 31960.4 / period
		lcn = hz / rate
		i = 0
	end

	local remains = adr-fradr
	serial(0x808,fradr,remains)
	done = true
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
