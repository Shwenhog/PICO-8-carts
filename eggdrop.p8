pico-8 cartridge // http://www.pico-8.com
version 1.2
__lua__
--eggdrop
--shwenhog
--[[ todo
    complete menu functionality
    add local score board
    add bomb game mode
    fix music
    try adding walking sfx
]]------------------------------

--[[ tab 0
    initialisation
]]------------------------------

function _init()
  init_state()
  init_boundary()
  init_player()
  init_eggs()
  init_sprites()
end

function init_state()
  state = {}
  state.menu = true
  state.time = 0
  state.time_end = 1200
  state.gravity = 2.2
  state.speedup = 0.001
  state.egg_interval = 25
end

--boundary for eggs
function init_boundary()
  boundary = {}
  boundary.l = 7
  boundary.r = 119
  boundary.u = -8
  boundary.d = 112
end

function init_player()
  player = {}
  player.x = 60
  player.y = 112
  player.scr = 0
  player.tmr = 0
  player.flp = false
end

function init_eggs()
  eggs = {}
  eggs.coll = {}
end

--set sprites
function init_sprites()
  player.sprt = 1
  player.sprt_dflt = 1
  player.sprt_animf = 2
  player.sprt_animl = 3
  player.sprt_win = 4

  eggs.sprt_dflt = 32
  eggs.sprt_animf = 33
  eggs.sprt_animl = 38
end

-->8
--[[ tab 1
    menu
]]------------------------------

function draw_menu()
  --title
  x = (127/2-(8*12)/2)
  y = (127/2-(8*4))
  spr(64, x, y, 12, 4)
  --each char is 4 w 6 h 
  --options
  print(">start", (127/2 - 6*2), (127/2 - 6*2))
  print("time's up!", (127/2 - 10*2), (127/2 - 6*2))
end
-->8
--[[ tab 2
    update
    draw
    player
]]------------------------------

function _update()
  if (not state.menu and
      state.time <= state.time_end) then
    state.time += 1
    state.gravity += state.speedup
    move_player()
    make_egg()
    foreach(eggs, move_egg)
  end
end

function _draw()
  map(0,0,0,0,127,127,0) --draw stage
  if (state.menu) then
    draw_menu()
  elseif (state.time <= state.time_end) then
    map(0,0,0,0,127,127,0)
    spr(player.sprt, player.x, player.y, 1, 1, player.flp)
    foreach(eggs, draw_egg)
  else
    spr(player.sprt_win, player.x, player.y, 1, 1, player.flp)
    print("time's up!", (127/2 - 10*2), (127/2 - 6*2))
    print("you collected", (127/2 - 13*2), (127/2 - 6))
    print(player.scr.." eggs", (127/2 - 7*2), (127/2))
  end
end

--actor, interval
function anim_sprite(a, i)
  if (a.tmr > i) then
    a.tmr = 0
    a.sprt += 1
    if (a.sprt > a.sprt_animl) a.sprt = a.sprt_animf
  else
    a.tmr += 1
  end
end

function move_player()
  --0123 : LRUD
  if (btn(0)) then
    player.flp = false
    player.x -= 2
    anim_sprite(player, 1)
  elseif (btn(1)) then
    player.flp = true
    player.x += 2
    anim_sprite(player, 1)
  else
    player.sprt = player.sprt_dflt
  end
end

-->8
--[[ tab 3
    eggs
]]------------------------------

function make_egg()
  if (state.time%state.egg_interval == 0) then
    rndX = flr( rnd(boundary.r-boundary.l) + boundary.l )
    local egg = {}
    egg.x = rndX
    egg.y = boundary.u
    egg.sprt = eggs.sprt_dflt
    egg.sprt_animf = eggs.sprt_animf
    egg.sprt_animl = eggs.sprt_animl
    egg.tmr = 0
    egg.broken = false
    add(eggs, egg)
  end
end

function move_egg(egg)
  --L1R1U1B0 -> L1R6T1B7
  --egg falls until it reaches the ground
  if (egg.y < boundary.d) then
    egg.y += state.gravity
    --check if player can collect egg
    local lowY = egg.y + 7 --B7
    local lowX = egg.x + 1 --L1
    local highX = egg.x + 6 --R6

    if (player.y <= lowY and
        player.x+7 >= lowX and
        player.x <= highX ) then
      del(eggs, egg)
      sfx(5, 2)
      player.scr += 1
    end
  elseif(not egg.broken) then
    egg.broken = true
    sfx(6, 3)
  end
end

function draw_egg(egg)
  if(not egg.broken) then
    spr(egg.sprt, egg.x, egg.y)
  else
    if (egg.tmr%2==0) then
      egg.sprt += 1
      if (egg.sprt > 38) then
        del(eggs, egg)
      else
        spr(egg.sprt, egg.x, egg.y)
      end
    else
      spr(egg.sprt, egg.x, egg.y)
    end
  end
end

__gfx__
00000000008800000088000000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000075700000757000007570000008800000088000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700997700009977000099770000075700000757000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000877777708777777087777779977000099c7000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000077777770777777707777777087777770877777700000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700077777770777777707777777077777770777777700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777700777777007777770077777770777777700000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000a0a00000a000000000a000077777700777777000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333331111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333331111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
34333333333333331111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
34433443333433341111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444441111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444441111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444441111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444441111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777700007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777700007779000077790000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770077779970777990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770077797770777999007779990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770077977777779779777997997000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777700009997709999997997999979079997900099970000099000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ee0ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00eeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000eee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000077700000000000000000000000000000000000000000000000000000000000
00000000000000777700000000000000000000000000000000000000000000000777970000000000000000000000000000000000000000000000000000000000
00000000000077777777000000000000000000000000000000000000000000000777977000000000000000000000000000000000000000000000000000000000
00000000000777777777700000000000000000000000000000000000000000000079977000000000000000000000000000000000000000000000000000000000
00000000007777777777770000000000000000000000000000000000000000000009970000000000000000000000000000000000000000000000000000000000
00000000077777999977777000000000000000000000000000000000000000000009900000000000000000000000000000000000000000000000000000000000
00000000777799999999777700000007777700000000000777700000000000000009900000000000000000000000000000000000000000000000000000000000
00000000777999999999977700000777777777000000077777777000000000000009900000000000000000000000000000000000000000000000000000000000
00000007777999999999977770007777777777770000777777777700000000000009900000000000000077777777700000000000000000000000000000000000
00000007779999999999997770007777777777777000777777777700000000000009900000000000000077777777700000000000000000000000000000000000
00000007779999999999997770077777777777777007777777777770000000000009900007777777700077777777700000000000000000000000000000000000
00000077779999999999997777077777777777777707777777777770000000000009900077777777700077777777700000000000000000000000000000000000
00000077777777777777777777077777777777777707777777777777000000000009900777799999770077777777700000000000000000000000000000000000
00000077777777777777777777077777777777777707777777777777000777777009900777999999970077777777700000000000000000000000000000000000
00000077777777777777777770077777777777779707777777797777007777777779907777999999970077777777700000000000000000000000000000000000
00000077770000000000000000077777777777777900777777779777077777777777907779999999990077000000000000000000000000000000000000000000
00000077770000000000000000007777777777777900777777779979077777777777707779999999990077000000000000000000000000000000000000000000
00000077770000000000007777007777777777779900077777777999077777777777707799999999990077000000000000000000000000000000000000000000
00000077770000000000007777000777777777009900000777777999077777777777707799999999999077000000000000000000000000000000000000000000
00000007777000000000077770000007777700009900000000000099077777777777707799999999999077000000000000000000000000000000000000000000
00000007777700000000777770000000000000009900000000000099077777777777707799999999999077000000000000000000000000000000000000000000
00000000077777777777777000000000000000009900000000000099077777777777907799999999999077000000000000000000000000000000000000000000
00000000077777777777777000099999999999999999999999999999907777777779907799999999999077000000000000000000000000000000000000000000
00000000000777777777700009999999999999999999999999999999990777777009000779999999990077000000000000000000000000000000000000000000
__map__
1212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1110111110101111101110111110101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
01140000181101870018700181001810018100181001870018100187001810018700187001870018700187001810018700181001870018100187001d5001f5001f50000000000000000000000000000000000000
0114000021520215202352024520245202452530700267002352023520215201f5201f5201f52500000185001f5201f520215201a5201a520185201a5201a5201c52018520185201852518700000000000000000
011000001c5201c5201c5201c5201c5201c5201c5201c5251a5201a5201a5201a5201a5201a5201a520185201852018520185201852018520185251d5001d5001d5001d5001d5001d5001d5001d5000000000000
011000001d5201d5201d5201d5201d5201d5201d5201d5251c5201c5201c5201c5201c5201c5201c5201c5251f5201f5201f5201f5201f5201f52518500185001850018500185001850018500000000000000000
011000001c5201c5201c5201c5201c5201c5201c5201c5251f5201f5201f5201f5201f5201f5201f5201f52518520185201852018520185201852500000000000000000000000000000000000000000000000000
010a0000340511830018400185001860018700180001a00024000181001a100000002d0002f0002d0002f0002f000300002f00030000000000000000000000000000000000000000000000000000000000000000
010800003074330100301003020030300303003040030200305003050030400303003020030100300003000030600306003060030600306003060030600306003060030600306003060030600306000000000000
__music__
00 41410102
00 41414103
00 41410204
00 41414140

