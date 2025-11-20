-- Skidded from SilentNight Appreciate Yall
local function printF(msg)
  if notify and notify.push then notify.push('Business Manager', msg) end
  if print then print(msg) end
end

local function y(ms)
  if util and util.yield then util.yield(ms) end
end

local function _comma(n)
  n = tonumber(n) or 0
  local s = tostring(math.floor(n))
  local sign = ''
  if s:sub(1,1) == '-' then sign='-'; s=s:sub(2) end
  local parts = {}
  while #s > 3 do
    table.insert(parts, 1, s:sub(#s-2, #s))
    s = s:sub(1, #s-3)
  end
  table.insert(parts, 1, s)
  return sign .. table.concat(parts, ',')
end

local function fmt_money(n)
  return '$' .. _comma(n)
end
_G.fmt_money = fmt_money

function FillAllMCSupplies()
  for x = 1, 7 do
    for i = 1, 5 do
      pcall(function() script.globals(1668007):at(i).int32 = 1 end)
    end
    y(5)
  end
end

function RefillBunkerSupplies()
  for p = 1, 7 do
    pcall(function() script.globals(1668007):at(6).int32 = 1 end)
    y(5)
  end
end

function RefillAcidLabSupplies()
  for p = 1, 7 do
    pcall(function() script.globals(1668007):at(7).int32 = 1 end)
    y(5)
  end
end

local G_SUPPLIES_BUNKER = 1668007 + 5 + 1
local G_TRIG1           = 2708294 + 1 + 5 * 2
local G_TRIG2           = G_TRIG1 + 1
local function BunkerProduction_SingleTick()
  pcall(function() script.globals(G_SUPPLIES_BUNKER).int32 = 1 end)
  pcall(function() script.globals(G_TRIG1).int32 = 0 end)
  pcall(function() script.globals(G_TRIG2).bool  = true end)
end

function InstantBunkerSellEnhanced()
  local ok, loc = pcall(function() return script.locals('gb_gunrunning', 1266) end)
  if not (ok and loc) then return end
  pcall(function() loc:at(774).int32 = 0 end)
end

local function _bunker_set_per_unit(v)
  local TUN = script.globals(262145)
  local OFF = 21258
  pcall(function() TUN:at(OFF).int32 = v end)
end

local __bunker_burst_running = false
local __bunker_burst_pending = nil

function BunkerSale_PerUnit_Burst(per_unit)
  local v = math.max(1000, math.min(50000, math.floor(per_unit or 5000)))

  if __bunker_burst_running then
    __bunker_burst_pending = v
    printF(('Bunker per-unit queued: $%d'):format(v))
    return
  end

  __bunker_burst_running = true
  __bunker_burst_pending = v

  while __bunker_burst_pending do
    local target = __bunker_burst_pending
    __bunker_burst_pending = nil

    for i = 1, 10 do
      _bunker_set_per_unit(target)
      y(80)
    end

    printF(('Bunker per-unit write applied: $%d (10x@%dms)'):format(target, 80))

    if __bunker_burst_pending then
      y(120)
    end
  end

  __bunker_burst_running = false
end

function InstantHangarAirSellEnhanced()
  local ok, loc = pcall(function() return script.locals('gb_smuggler', 1989) end)
  if not (ok and loc) then return end
  pcall(function() loc:at(1035).int32 = 0 end)
  pcall(function() loc:at(1078).int32 = 1 end)
end

local function _hangar_set_per_crate(v)
  local tun = script.tunables(joaat('SMUG_SELL_PRICE_PER_CRATE_MIXED'))
  pcall(function() tun.int32 = v end)
end

local __hangar_burst_running = false
local __hangar_burst_pending = nil

function HangarSale_PerCrate_Burst(per_crate)
  local v = math.max(10000, math.min(200000, math.floor(per_crate or 30000)))

  if __hangar_burst_running then
    __hangar_burst_pending = v
    printF(('Hangar per-crate queued: $%d'):format(v))
    return
  end

  __hangar_burst_running = true
  __hangar_burst_pending = v

  while __hangar_burst_pending do
    local target = __hangar_burst_pending
    __hangar_burst_pending = nil

    for i = 1, 10 do
      _hangar_set_per_crate(target)
      y(80)
    end

    printF(('Hangar per-crate write applied: $%d (10x@%dms)'):format(target, 80))

    if __hangar_burst_pending then
      y(120)
    end
  end

  __hangar_burst_running = false
end

local SET_PACKED_STAT_BOOL_CODE = 0xDB8A58AEAA67CD07
local HANGAR_CARGO_PACKED_IDX   = 36828
local HANGAR_LAPTOP_SCRIPT      = 'appsmuggler'

local __hangar_supplier_on  = false
local __hangar_supplier_job = nil

local function _set_packed_bool(idx, val, slot)
  return pcall(function() invoker.call(SET_PACKED_STAT_BOOL_CODE, idx, val and true or false, slot) end)
end

local function _hangar_supplier_tick()
  _set_packed_bool(HANGAR_CARGO_PACKED_IDX, true, 0)
  _set_packed_bool(HANGAR_CARGO_PACKED_IDX, true, 1)
end

local STAT_SET_PACKED_INT = 0x1581503AE529CD2E
function ReduceFrontHeatToZero()
  local fronts = { 24924, 24925, 24926 }
  for _, idx in ipairs(fronts) do
    pcall(function() invoker.call(STAT_SET_PACKED_INT, idx, 0, 0) end)
    pcall(function() invoker.call(STAT_SET_PACKED_INT, idx, 0, 1) end)
    y(5)
  end
  printF('Money fronts heat set to 0 (Carwash/Smoke/Heli).')
end

local SC_SET_PACKED = 0xDB8A58AEAA67CD07
local SC_FIRST, SC_LAST = 32359, 32363
local SC_CHARS = { 0, 1 }
local SC_INTERVAL = 1000

local __sc_on  = false
local __sc_job = nil

local function _sc_pulse_once()
  for idx = SC_FIRST, SC_LAST do
    for _, ch in ipairs(SC_CHARS) do
      pcall(function() invoker.call(SC_SET_PACKED, idx, true, ch) end)
    end
  end
end

local CR_G = 262145
local CR_DEFAULTS = {10000,11000,12000,13000,13500,14000,14500,15000,15500,16000,16500,17000,17500,17750,18000,18250,18500,18750,19000,19500,20000}
local CR_DIVISORS = {1,2,3,5,7,9,14,19,24,29,34,39,44,49,59,69,79,89,99,110,111}
local CR_BASE = nil
local __cr_running = false
local __cr_pending = nil

local function cr_scripts_busy()
  local busy = { 'gb_contraband_sell','gb_contraband','appsecuroserv','appbusinesshub' }
  for _, s in ipairs(busy) do
    if script and script.is_running and script.is_running(s) then return s end
  end
  return nil
end

local function cr_read(off)
  return pcall(function() return script.globals(CR_G):at(off).int32 end)
end

local function cr_write(off, val)
  pcall(function() script.globals(CR_G):at(off).int32 = val end)
end

local function cr_find_base()
  if CR_BASE then return CR_BASE end
  local base_ptr = script.globals(CR_G); if not base_ptr then return nil end
  local n = #CR_DEFAULTS
  for i = 0, 40000 - n do
    local ok, v = cr_read(i)
    if ok and v == CR_DEFAULTS[1] then
      local match = true
      for k = 2, n do
        local ok2, vk = cr_read(i + k - 1)
        if (not ok2) or (vk ~= CR_DEFAULTS[k]) then match = false break end
      end
      if match then
        CR_BASE = i
        return i
      end
    end
    if util and util.yield and (i % 200 == 0) then util.yield(0) end
  end
  return nil
end

local function _cr_apply_once(top)
  local busy = cr_scripts_busy()
  if busy then
    if notify and notify.push then notify.push('Crate Sale Price','Apply blocked: exit laptop/sell first') end
    print('[Crate Sale Price] Apply blocked: '..busy..' running')
    return false
  end
  top = tonumber(top) or 6000000
  local base = cr_find_base()
  if not base then
    if notify and notify.push then notify.push('Crate Sale Price','Table not found') end
    print('[Crate Sale Price] Table not found')
    return false
  end
  for pass = 1, 10 do
    for idx = 1, #CR_DIVISORS do
      cr_write(base + (idx - 1), math.floor(top / CR_DIVISORS[idx]))
    end
    if util and util.yield then util.yield(80) end
  end
  if notify and notify.push then notify.push('Crate Sale Price',('Applied top=%d (10x@%dms)'):format(top, 80)) end
  print(('[Crate Sale Price] Applied top=%d at base=%d (10x@%dms)'):format(top, base, 80))
  return true
end

function CrateWarehouse_SalePrice_Apply(top_price)
  local top = tonumber(top_price) or 6000000
  __cr_pending = top

  if __cr_running then
    if notify and notify.push then notify.push('Crate Sale Price','Queued '..fmt_money(top)) end
    print('[Crate Sale Price] queued top='..tostring(top))
    return true
  end

  __cr_running = true

  while __cr_pending do
    local t = __cr_pending
    __cr_pending = nil
    _cr_apply_once(t)
    if util and util.yield then util.yield(120) end
  end

  __cr_running = false
  return true
end

local __cr_busy = false

local function cr_reset()
  if __cr_running or __cr_busy then return false end
  local busy = cr_scripts_busy()
  if busy then
    if notify and notify.push then notify.push('Crate Sale Price','Reset blocked: exit laptop/sell first') end
    print('[Crate Sale Price] Reset blocked: '..busy..' running')
    return false
  end
  __cr_busy = true
  local NAMES = {
    'EXEC_CONTRABAND_SALE_VALUE_THRESHOLD1','EXEC_CONTRABAND_SALE_VALUE_THRESHOLD2','EXEC_CONTRABAND_SALE_VALUE_THRESHOLD3',
    'EXEC_CONTRABAND_SALE_VALUE_THRESHOLD4','EXEC_CONTRABAND_SALE_VALUE_THRESHOLD5','EXEC_CONTRABAND_SALE_VALUE_THRESHOLD6',
    'EXEC_CONTRABAND_SALE_VALUE_THRESHOLD7','EXEC_CONTRABAND_SALE_VALUE_THRESHOLD8','EXEC_CONTRABAND_SALE_VALUE_THRESHOLD9',
    'EXEC_CONTRABAND_SALE_VALUE_THRESHOLD10','EXEC_CONTRABAND_SALE_VALUE_THRESHOLD11','EXEC_CONTRABAND_SALE_VALUE_THRESHOLD12',
    'EXEC_CONTRABAND_SALE_VALUE_THRESHOLD13','EXEC_CONTRABAND_SALE_VALUE_THRESHOLD14','EXEC_CONTRABAND_SALE_VALUE_THRESHOLD15',
    'EXEC_CONTRABAND_SALE_VALUE_THRESHOLD16','EXEC_CONTRABAND_SALE_VALUE_THRESHOLD17','EXEC_CONTRABAND_SALE_VALUE_THRESHOLD18',
    'EXEC_CONTRABAND_SALE_VALUE_THRESHOLD19','EXEC_CONTRABAND_SALE_VALUE_THRESHOLD20','EXEC_CONTRABAND_SALE_VALUE_THRESHOLD21'
  }
  for i, name in ipairs(NAMES) do
    pcall(function()
      local t = script.tunables(joaat(name))
      t.int32 = CR_DEFAULTS[i]
    end)
    if util and util.yield then util.yield(40) end
  end
  __cr_busy = false
  CR_BASE = nil
  if notify and notify.push then notify.push('Crate Sale Price','Restored defaults') end
  print('[Crate Sale Price] Restored defaults via tunables')
  return true
end

CrateWarehouse_SalePrice_Reset = function() return cr_reset() end

local function SpecialCargo_InstantSell()
  local ok, loc = pcall(function() return script.locals('gb_contraband_sell', 567) end)
  if not (ok and loc) then return end
  pcall(function()
    loc:at(1).int32 = 67230
    loc:at(7).int32 = 7
  end)
  printF('Instant sell writes sent (567+1=67230, 567+7=7).')
end

local function Salvage_TowTruck_InstantFinish()
  local ok1, loc1 = pcall(function() return script.locals('fm_content_tow_truck_work', 1781) end)
  if ok1 and loc1 then
    pcall(function()
      loc1:at(1).int32 = -1071628608
    end)
  end

  local ok2, loc2 = pcall(function() return script.locals('fm_content_tow_truck_work', 1838) end)
  if ok2 and loc2 then
    pcall(function()
      loc2:at(93).int32 = 3
    end)
  end

  printF('Tow Truck instant-finish writes sent')
end

local CLICK = 0
local root = menu.root()

local CLICK = 0
local root = menu.root()


local MC_TUN_ROOT = 262145

local MC_ENTRIES = {
  { label = 'Fake IDs',          off = 17323, def = 1350 },
  { label = 'Counterfeit Cash',  off = 17324, def = 4725 },
  { label = 'Crack',             off = 17325, def = 27000 },
  { label = 'Meth',              off = 17326, def = 11475 },
  { label = 'Weed',              off = 17327, def = 2025 },
  { label = 'Acid',              off = 17328, def = 1485 },
}

local function _mc_set(off, val)
  pcall(function()
    script.globals(MC_TUN_ROOT):at(off).int32 = val
  end)
end

local function _mc_build_list(def)
  local MIN, MAX, STEP = 1000, 500000, 1000
  local seen, arr = {}, {}

  local function add(v)
    v = math.floor(v)
    if v < MIN or v > MAX then return end
    if not seen[v] then
      seen[v] = true
      arr[#arr + 1] = v
    end
  end

  for v = MIN, MAX, STEP do
    add(v)
  end

  if def and def > 0 then
    local kmax = math.floor(MAX / def)
    for k = 1, kmax do
      add(def * k)
    end
  end

  table.sort(arr)

  local list, def_idx = {}, 1
  for i, v in ipairs(arr) do
    local name = fmt_money(v)
    if def and v == def then
      name = name .. ' (default)'
      def_idx = i
    end
    list[i] = { name, v }
  end

  return list, def_idx
end

local MC_LISTS = {}
for i, e in ipairs(MC_ENTRIES) do
  local list, idx = _mc_build_list(e.def)
  MC_LISTS[i] = { list = list, def_idx = idx }
end

local mc_root = root:submenu('MC Businesses / Acid Lab')

local mc_prod = mc_root:submenu('Production Utility')
local mc_refill_btn = mc_prod:button('Refill MC + Acid Lab Supplies')
mc_refill_btn:event(CLICK, function()
  RefillAcidLabSupplies()
  FillAllMCSupplies()
end)

local mc_sale = mc_root:submenu('Sale Utility')
local mc_sliders = mc_sale:submenu('Modify Per-Unit Prices', 'Adjust per-unit sale price for each MC business. Apply before starting a sell.')


local mc_combo = {}
for i, e in ipairs(MC_ENTRIES) do
  local cfg = MC_LISTS[i]
  local c = mc_sliders:combo_int(e.label, cfg.list, cfg.def_idx)
  c:tooltip(('Default per-unit: %s'):format(fmt_money(e.def)))
  mc_combo[i] = c
end

local mc_apply_btn = mc_sliders:button('Apply All')
mc_apply_btn:tooltip('Applies current MC per-unit selections to all MC businesses.')
mc_apply_btn:event(CLICK, function()
  for pass = 1, 10 do
    for i, e in ipairs(MC_ENTRIES) do
      local cfg = MC_LISTS[i]
      local c = mc_combo[i]
      local idx = c.value or cfg.def_idx
      local sel = cfg.list[idx]
      if sel and sel[2] then
        _mc_set(e.off, sel[2])
      end
    end
    y(80)
  end
  printF('MC per-unit prices applied (all businesses).')
end)

local bunker = root:submenu('Bunker')

local bunk_prod = bunker:submenu('Production Utility')
local btn_bunker_refill = bunk_prod:button('Refill Bunker Supplies')
btn_bunker_refill:event(CLICK, function()
  RefillBunkerSupplies()
end)

local bunk_prod_toggle = bunk_prod:toggle('Fast Production')
bunk_prod_toggle:tooltip('Continuously ticks bunker production while ON. Safe against spam toggling.')

local __bunk_pulse_running = false

bunk_prod_toggle:event(CLICK, function()
  if bunk_prod_toggle.value then
    if __bunk_pulse_running then
      printF('Bunker pulse already running')
      return
    end

    __bunk_pulse_running = true
    printF('Bunker pulse enabled')

    while bunk_prod_toggle.value and __bunk_pulse_running do
      local ok = false
      if type(FastBunkerProduction) == 'function' then
        ok = pcall(function() FastBunkerProduction(50, 50) end)
      end
      if not ok then
        for i = 1, 50 do
          if not bunk_prod_toggle.value or not __bunk_pulse_running then break end
          BunkerProduction_SingleTick()
          y(50)
        end
      end
      y(250)
    end

    __bunk_pulse_running = false
    printF('Bunker pulse stopped')
  else
    printF('Bunker pulse disabling...')
    __bunk_pulse_running = false
  end
end)

local bunk_sale = bunker:submenu('Sale Utility')

local btn_bunker_finish = bunk_sale:button('Instant Finish Bunker Sell')
btn_bunker_finish:tooltip('RUN ONLY during an active Bunker sell mission. If you use this outside a sell, the game WILL crash. WARNING: THIS ISNT INSTANT FINISH FOR AMMO DROPOFF!!!!!')
btn_bunker_finish:event(CLICK, function()
  InstantBunkerSellEnhanced()
end)

local bunk_sale_mod = bunk_sale:submenu('Modify Bunker Sale Price')
local __bunker_price_opts = {}

for v = 1000, 50000, 1000 do table.insert(__bunker_price_opts, {fmt_money(v), v}) end
local per_unit_combo = bunk_sale_mod:combo_int('Per-Unit Price (Default $5000)', __bunker_price_opts, 5)
local btn_apply_price = bunk_sale_mod:button('Apply Per-Unit')
btn_apply_price:event(CLICK, function()
  local idx = per_unit_combo.value or 5
  local sel = __bunker_price_opts[idx] or { '$5000', 5000 }
  BunkerSale_PerUnit_Burst(sel[2])
end)

local hangar = root:submenu('Hangar')

local hang_prod = hangar:submenu('Production Utility')
local hangar_supplier_toggle = hang_prod:toggle('Hangar Resupplier')
hangar_supplier_toggle:tooltip('Must be outside for it to work (do not open the hangar laptop).')

local __hangar_supplier_running = false

hangar_supplier_toggle:event(CLICK, function()
  if hangar_supplier_toggle.value then
    if __hangar_supplier_running then
      printF('Hangar resupplier already running')
      return
    end

    __hangar_supplier_running = true
    printF('Hangar resupplier enabled')

    while hangar_supplier_toggle.value and __hangar_supplier_running do
      local onLaptop = (script and script.is_running and script.is_running(HANGAR_LAPTOP_SCRIPT))
      if not onLaptop then
        _hangar_supplier_tick()
      end
      y(50)
    end

    __hangar_supplier_running = false
    printF('Hangar resupplier stopped')
  else
    printF('Hangar resupplier disabling...')
    __hangar_supplier_running = false
  end
end)

local hang_sale = hangar:submenu('Sale Utility')
local btn_hangar_finish = hang_sale:button('Instant Finish Hangar Sell (Air Only)')
btn_hangar_finish:tooltip('AIR sells only. RUN ONLY during an active Hangar sell mission. If used outside a sell, the game WILL crash.')
btn_hangar_finish:event(CLICK, function()
  InstantHangarAirSellEnhanced()
end)

local hangar_sale_mod = hang_sale:submenu('Modify Hangar Per-Crate Price')
local __hangar_price_opts = {}
for v = 10000, 200000, 2000 do table.insert(__hangar_price_opts, {fmt_money(v), v}) end
local hangar_per_unit_combo = hangar_sale_mod:combo_int('Per-Crate Price (Default $30000)', __hangar_price_opts, 11)

local btn_apply_hangar_price = hangar_sale_mod:button('Apply Per-Crate')
btn_apply_hangar_price:tooltip('Changes Hangar Per-Crate Sell Price. Set BEFORE starting a sell.')
btn_apply_hangar_price:event(CLICK, function()
  local idx = hangar_per_unit_combo.value or 11
  local sel = __hangar_price_opts[idx] or { '$30000', 30000 }
  HangarSale_PerCrate_Burst(sel[2])
end)

local special = root:submenu('Special Cargo (Risky/Detected?)')

local sc_prod = special:submenu('Production Utility')
local sc_toggle = sc_prod:toggle('Warehouse Resupplier')
sc_toggle:tooltip('Auto-fills Special Cargo crates. Toggle OFF to stop. (Runs ~1 pulse/second)')

local __sc_running = false

sc_toggle:event(CLICK, function()
  if sc_toggle.value then
    if __sc_running then
      printF('Special Cargo supplier already running')
      return
    end

    __sc_running = true
    printF('Special Cargo supplier enabled')

    while sc_toggle.value and __sc_running do
      _sc_pulse_once()
      y(SC_INTERVAL)
    end

    __sc_running = false
    printF('Special Cargo supplier stopped')
  else
    printF('Special Cargo supplier disabling...')
    __sc_running = false
  end
end)

local sc_sale = special:submenu('Sale Utility')

local sc_price = sc_sale:submenu('Modify Crate Sell Price')
local sc_top_opts = {}
for v = 0, 6000000, 250000 do table.insert(sc_top_opts, {fmt_money(v), v}) end
local sc_def_idx = 1
for i, p in ipairs(sc_top_opts) do if p[2] == 6000000 then sc_def_idx = i break end end
local sc_top_combo = sc_price:combo_int('Top Price', sc_top_opts, sc_def_idx)
local sc_apply_btn = sc_price:button('Apply Top Price')
sc_apply_btn:tooltip('Writes crate sale thresholds based on selected Top Price. Use before starting a sell.')
sc_apply_btn:event(CLICK, function()
  local idx = sc_top_combo.value or sc_def_idx
  local sel = sc_top_opts[idx] or sc_top_opts[sc_def_idx]
  CrateWarehouse_SalePrice_Apply(sel[2])
end)
local sc_reset_btn = sc_price:button('Reset to Defaults')
sc_reset_btn:event(CLICK, function()
  CrateWarehouse_SalePrice_Reset()
end)

local sc_finish_btn = sc_sale:button('Instant Finish Special Cargo')
sc_finish_btn:tooltip('RUN ONLY during an active Special Cargo sell. Using this outside a sell may crash the game.')
sc_finish_btn:event(CLICK, function()
  SpecialCargo_InstantSell()
end)


local G_WORLD_XP_MULT = 262145 + 1

local function _xp_set(v)
  pcall(function() script.globals(G_WORLD_XP_MULT).float = v end)
end

function SetNoXpGain(enabled)
  if enabled == nil then enabled = true end
  _xp_set(enabled and 0.0 or 1.0)
  if notify and notify.push then
    notify.push('Business Manager', enabled and 'XP gain disabled (multiplier = 0.0)' or 'XP gain enabled (multiplier = 1.0)')
  end
end

local NC_TUN_ROOT = 262145

local NC_MAP = {
  [0] = { name = 'Cargo & Shipments',       base = 23972, spec = 23965 },
  [1] = { name = 'South American Imports',  base = 23967, spec = 23960 },
  [2] = { name = 'Pharmaceutical Research', base = 23968, spec = 23961 },
  [3] = { name = 'Organic Produce',         base = 23969, spec = 23962 },
  [4] = { name = 'Printing & Copying',      base = 23970, spec = 23963 },
  [5] = { name = 'Cash Creation',           base = 23971, spec = 23964 },
  [6] = { name = 'Sporting Goods',          base = 23966, spec = 23959 },
}

local NC_DEFAULTS = {
  [23966] = 5000,
  [23967] = 27000,
  [23968] = 11475,
  [23969] = 2025,
  [23970] = 1350,
  [23971] = 4725,
  [23972] = 10000,
  [23959] = 5000,
  [23960] = 27000,
  [23961] = 11475,
  [23962] = 2025,
  [23963] = 1350,
  [23964] = 4725,
  [23965] = 10000,
}

local function _nc_y(ms)
  if util and util.yield then util.yield(ms) end
end

local function _nc_log(msg)
  if notify and notify.push then notify.push('Business Manager', msg) end
  if print then print(msg) end
end

local NC_CD_TUNABLES = {
  'BB_CLUB_MANAGEMENT_CLUB_MANAGEMENT_MISSION_COOLDOWN',
  'BB_SELL_MISSIONS_MISSION_COOLDOWN',
  'BB_SELL_MISSIONS_DELIVERY_VEHICLE_COOLDOWN_AFTER_SELL_MISSION'
}

local NC_CD_DEFAULT = 300000

local function _nc_cd_set_all(v)
  for _, name in ipairs(NC_CD_TUNABLES) do
    pcall(function()
      local t = script.tunables(joaat(name))
      t.int32 = v
    end)
  end
end

local NC_SETUP_INDICES = { 18161, 22067, 22068 }
local NC_SETUP_CHARS   = { 0, 1 }

local function Nightclub_SkipSetup()
  for _, idx in ipairs(NC_SETUP_INDICES) do
    for _, ch in ipairs(NC_SETUP_CHARS) do
      pcall(function()
        invoker.call(SET_PACKED_STAT_BOOL_CODE, idx, true, ch)
      end)
    end
  end
  _nc_log('Nightclub setup skipped (Staff, Equipment, DJ). Change session to apply.')
end

local function _nc_set(off, val)
  return pcall(function()
    local T = script.globals(NC_TUN_ROOT)
    T:at(off).int32 = val
  end)
end

local function _nc_get_hub_total(idx)
  local k = 'HUB_PROD_TOTAL_' .. tostring(idx)
  local v
  pcall(function()
    v = account and account.stats and account.stats(k).int32
  end)
  return tonumber(v) or 0
end

local function _nc_apply_pass(target)
  for idx = 0, 6 do
    local m = NC_MAP[idx]
    if m then
      local stock = _nc_get_hub_total(idx)
      if stock > 0 then
        local per = math.floor(target / stock)
        _nc_set(m.base, per)
        _nc_set(m.spec, per)
      end
    end
  end
end

function Nightclub_Sale_MaxPrice_Burst(target_total, passes, sleep_ms)
  target_total = tonumber(target_total) or 4000000
  passes = passes or 5
  sleep_ms = sleep_ms or 80
  for i = 1, passes do
    _nc_apply_pass(target_total)
    _nc_y(sleep_ms)
  end
  _nc_log(('Nightclub MaxPrice applied (~$%d/category) x%d @ %dms'):format(target_total, passes, sleep_ms))
end

function Nightclub_Sale_Reset_Defaults(passes, sleep_ms)
  passes = passes or 5
  sleep_ms = sleep_ms or 80
  for i = 1, passes do
    for off, def in pairs(NC_DEFAULTS) do
      _nc_set(off, def)
    end
    _nc_y(sleep_ms)
  end
  _nc_log('Nightclub sale prices reset to defaults.')
end

local __nc_maxprice_on      = false
local __nc_maxprice_running = false

function Nightclub_Sale_MaxPrice_SetEnabled(enabled, target_total)
  target_total = tonumber(target_total) or 4000000

  if enabled then
    if __nc_maxprice_running then
      _nc_log('Nightclub MaxPrice already running')
      return
    end

    __nc_maxprice_on = true
    __nc_maxprice_running = true
    _nc_log('Nightclub MaxPrice enabled (target ~$' .. tostring(target_total) .. '). Avoid "Sell All Goods" while this is ON.')

    while __nc_maxprice_on and __nc_maxprice_running do
      for i = 1, 2 do
        _nc_apply_pass(target_total)
        _nc_y(60)
      end
      _nc_y(400)
    end

    __nc_maxprice_running = false
    _nc_log('Nightclub MaxPrice stopped')
  else
    if __nc_maxprice_on then
      _nc_log('Nightclub MaxPrice disabling...')
    end
    __nc_maxprice_on = false
  end
end

local nightclub = root:submenu('Nightclub')
local nc_sale = nightclub:submenu('Sale Utility')
local nc_sliders = nc_sale:submenu('Modify Per-Unit Sale Price', 'Set per-unit price for each product. Tip: aim for about $4M per product: per_unit ~ 4,000,000 / current stock (HUB_PROD_TOTAL_0..6). Apply before starting a sell.')

local function _build_nc_list(def)
  local MIN, MAX, STEP = 1000, 500000, 2000
  local seen, arr = {}, {}

  local function add(v)
    v = math.floor(v)
    if v < MIN or v > MAX then return end
    if not seen[v] then
      seen[v] = true
      arr[#arr + 1] = v
    end
  end

  for v = MIN, MAX, STEP do
    add(v)
  end

  if def and def > 0 then
    local kmax = math.floor(MAX / def)
    for k = 1, kmax do
      add(def * k)
    end
  end

  table.sort(arr)

  local list, def_idx = {}, 1
  for i, v in ipairs(arr) do
    local name = fmt_money(v)
    if def and v == def then
      name = name .. ' (default)'
      def_idx = i
    end
    list[i] = { name, v }
  end

  return list, def_idx
end

local list_cargo, idx_cargo = _build_nc_list(NC_DEFAULTS[23972])
local list_sa,    idx_sa    = _build_nc_list(NC_DEFAULTS[23967])
local list_meth,  idx_meth  = _build_nc_list(NC_DEFAULTS[23968])
local list_weed,  idx_weed  = _build_nc_list(NC_DEFAULTS[23969])
local list_docs,  idx_docs  = _build_nc_list(NC_DEFAULTS[23970])
local list_cash,  idx_cash  = _build_nc_list(NC_DEFAULTS[23971])
local list_sport, idx_sport = _build_nc_list(NC_DEFAULTS[23966])

local s_cargo = nc_sliders:combo_int('Cargo & Shipments',       list_cargo, idx_cargo)
s_cargo:tooltip(('Default per-unit: %s'):format(fmt_money(NC_DEFAULTS[23972])))
local s_sa    = nc_sliders:combo_int('South American Imports',  list_sa,    idx_sa)
s_sa:tooltip(('Default per-unit: %s'):format(fmt_money(NC_DEFAULTS[23967])))
local s_meth  = nc_sliders:combo_int('Pharmaceutical Research', list_meth,  idx_meth)
s_meth:tooltip(('Default per-unit: %s'):format(fmt_money(NC_DEFAULTS[23968])))
local s_weed  = nc_sliders:combo_int('Organic Produce',         list_weed,  idx_weed)
s_weed:tooltip(('Default per-unit: %s'):format(fmt_money(NC_DEFAULTS[23969])))
local s_docs  = nc_sliders:combo_int('Printing & Copying',      list_docs,  idx_docs)
s_docs:tooltip(('Default per-unit: %s'):format(fmt_money(NC_DEFAULTS[23970])))
local s_cash  = nc_sliders:combo_int('Cash Creation',           list_cash,  idx_cash)
s_cash:tooltip(('Default per-unit: %s'):format(fmt_money(NC_DEFAULTS[23971])))
local s_sport = nc_sliders:combo_int('Sporting Goods',          list_sport, idx_sport)
s_sport:tooltip(('Default per-unit: %s'):format(fmt_money(NC_DEFAULTS[23966])))


local __nc_burst_running = false
local __nc_burst_pending = nil

local function _nc_apply_all_once(vals)
  for pass = 1, 10 do
    for idx = 0, 6 do
      local m = NC_MAP[idx]
      local v = tonumber(vals[idx])
      if m and v and v > 0 then
        _nc_set(m.base, v)
        _nc_set(m.spec, v)
      end
    end
    _nc_y(80)
  end
  _nc_log('Nightclub per-unit prices applied (all categories).')
end

function Nightclub_Sale_ApplyPerUnit_BurstAll(vals, passes, sleep_ms)
  __nc_burst_pending = vals

  if __nc_burst_running then
    _nc_log('Nightclub per-unit apply queued')
    return
  end

  __nc_burst_running = true

  while __nc_burst_pending do
    local t = __nc_burst_pending
    __nc_burst_pending = nil
    _nc_apply_all_once(t)
    _nc_y(120)
  end

  __nc_burst_running = false
end

local btn_nc_apply_sliders = nc_sliders:button('Apply All')
btn_nc_apply_sliders:tooltip('Sell All Goods NOT Recommended. Use before starting a sell. Tip: aim around $3-4M per product.')
btn_nc_apply_sliders:event(0, function()
  local vals = {
    [0] = list_cargo[s_cargo.value][2],
    [1] = list_sa[s_sa.value][2],
    [2] = list_meth[s_meth.value][2],
    [3] = list_weed[s_weed.value][2],
    [4] = list_docs[s_docs.value][2],
    [5] = list_cash[s_cash.value][2],
    [6] = list_sport[s_sport.value][2],
  }
  Nightclub_Sale_ApplyPerUnit_BurstAll(vals, 10, 80)
end)

local __nc_cd_running = false

local nc_cd_toggle = nc_sale:toggle('Kill Sell Cooldowns')
nc_cd_toggle:tooltip('Removes Nightclub management and sell cooldowns while ON.')
nc_cd_toggle:event(CLICK, function()
  if nc_cd_toggle.value then
    if __nc_cd_running then
      _nc_log('Nightclub cooldown loop already running')
      return
    end

    __nc_cd_running = true
    _nc_log('Nightclub cooldowns killed (loop ON)')

    while nc_cd_toggle.value and __nc_cd_running do
      _nc_cd_set_all(0)
      _nc_y(1000)
    end

    __nc_cd_running = false
  else
    _nc_log('Nightclub cooldown loop disabling; restoring defaults')
    __nc_cd_running = false
    _nc_cd_set_all(NC_CD_DEFAULT)
  end
end)

local NC_SAFE_TOP5   = 262145 + 23661
local NC_SAFE_TOP100 = 262145 + 23680
local NC_SAFE_MAX_TUNABLE = joaat('NIGHTCLUBMAXSAFEVALUE')
local NC_SAFE_COLLECT = 2708201

local function _nc_pay_time_set(v)
  pcall(function()
    if account and account.stats then
      account.stats('CLUB_PAY_TIME_LEFT').int32 = v
    end
  end)
end

local function Nightclub_Safe_Fill()
  local maxValue = 250000
  pcall(function()
    local tun = script.tunables(NC_SAFE_MAX_TUNABLE)
    tun.int32 = maxValue
  end)
  for i = NC_SAFE_TOP5, NC_SAFE_TOP100 do
    pcall(function()
      script.globals(i).int32 = maxValue
    end)
  end
  _nc_pay_time_set(-1)
  _nc_log('Nightclub safe fill applied to '..fmt_money(maxValue))
end

local function _nc_safe_value()
  local pid = 0
  local ok_pid, got = pcall(function()
    if players and players.user then
      return players.user()
    end
    if invoker and invoker.call then
      return invoker.call(0x4F8644AF03D0E0D6)
    end
    return 0
  end)
  if ok_pid and type(got) == 'number' then
    pid = got
  end
  local idx = 1845274 + 1 + (pid * 877) + 260 + 358 + 5
  local v
  pcall(function()
    v = script.globals(idx).int32
  end)
  return tonumber(v) or 0
end

local function Nightclub_Safe_Collect()
  local val = _nc_safe_value()
  if val > 0 then
    _nc_log('Nightclub safe collected')
  else
    _nc_log('Nightclub safe collect triggered')
  end
  pcall(function()
    script.globals(NC_SAFE_COLLECT).bool = true
  end)
end

local function Nightclub_Safe_Unbrick()
  for i = NC_SAFE_TOP5, NC_SAFE_TOP100 do
    pcall(function()
      script.globals(i).int32 = 1
    end)
  end
  _nc_pay_time_set(-1)
  _nc_y(3000)
  pcall(function()
    script.globals(NC_SAFE_COLLECT).bool = true
  end)
  _nc_log('Nightclub safe unbrick sequence applied')
end

local function _nc_pop_get()
  local v
  pcall(function()
    if account and account.stats then
      v = account.stats('CLUB_POPULARITY').int32
    end
  end)
  return tonumber(v) or 0
end

local function _nc_pop_set(v)
  pcall(function()
    if account and account.stats then
      account.stats('CLUB_POPULARITY').int32 = math.floor(v)
    end
  end)
end

local function Nightclub_Popularity_Max()
  _nc_pop_set(1000)
  _nc_log('Nightclub popularity set to 100%')
end

local function Nightclub_Popularity_Min()
  _nc_pop_set(0)
  _nc_log('Nightclub popularity set to 0%')
end

local __nc_pop_lock_running = false
local __nc_pop_lock_value = nil

local nc_pop = nightclub:submenu('Popularity Options')

local nc_safe = nightclub:submenu('Safe Options')

local nc_safe_fill_btn = nc_safe:button('Fill Safe')
nc_safe_fill_btn:tooltip('Fills your Nightclub safe to maximum capacity.')
nc_safe_fill_btn:event(CLICK, function()
  Nightclub_Safe_Fill()
end)

local nc_safe_collect_btn = nc_safe:button('Collect Safe')
nc_safe_collect_btn:tooltip('Triggers collection of Nightclub safe cash.')
nc_safe_collect_btn:event(CLICK, function()
  Nightclub_Safe_Collect()
end)

local nc_safe_unbrick_btn = nc_safe:button('Unbrick Safe')
nc_safe_unbrick_btn:tooltip('Fixes the $0 safe bug and forces a collection pulse.')
nc_safe_unbrick_btn:event(CLICK, function()
  Nightclub_Safe_Unbrick()
end)

local nc_pop_max_btn = nc_pop:button('Max Popularity')
nc_pop_max_btn:tooltip('Sets Nightclub popularity to 100%.')
nc_pop_max_btn:event(CLICK, function()
  Nightclub_Popularity_Max()
end)

local nc_pop_min_btn = nc_pop:button('Min Popularity')
nc_pop_min_btn:tooltip('Sets Nightclub popularity to 0%.')
nc_pop_min_btn:event(CLICK, function()
  Nightclub_Popularity_Min()
end)

local nc_pop_lock_toggle = nc_pop:toggle('Lock Popularity')
nc_pop_lock_toggle:tooltip('Locks Nightclub popularity at its current level while ON.')

nc_pop_lock_toggle:event(CLICK, function()
  if nc_pop_lock_toggle.value then
    if __nc_pop_lock_running then
      _nc_log('Nightclub popularity lock already running')
      return
    end

    __nc_pop_lock_running = true
    if not __nc_pop_lock_value then
      __nc_pop_lock_value = _nc_pop_get()
    end

    local pct = (__nc_pop_lock_value ~= 0) and math.floor(__nc_pop_lock_value / 10) or 0
    _nc_log('Nightclub popularity lock enabled at '..tostring(pct)..'%')

    while nc_pop_lock_toggle.value and __nc_pop_lock_running do
      _nc_pop_set(__nc_pop_lock_value)
      _nc_y(1000)
    end

    __nc_pop_lock_running = false
    _nc_log('Nightclub popularity lock stopped')
  else
    __nc_pop_lock_value = nil
    _nc_log('Nightclub popularity lock disabling...')
    __nc_pop_lock_running = false
  end
end)

local nc_skip_setup_btn = nightclub:button('Skip Nightclub Setup')
nc_skip_setup_btn:tooltip('Marks Nightclub setup (Staff, Equipment, DJ) as complete. Change session after running.')
nc_skip_setup_btn:event(CLICK, function()
  Nightclub_SkipSetup()
end)

local salvage = root:submenu('Salvage Yard')
local salvage_missions = salvage:submenu('Service Missions')

local btn_tow_finish = salvage_missions:button('Instant Finish Tow Truck Mission')
btn_tow_finish:tooltip('RUN ONLY during an active Tow Truck Service mission. Using this outside may crash the game.')
btn_tow_finish:event(CLICK, function()
  Salvage_TowTruck_InstantFinish()
end)

local moneyfronts = root:submenu('Money Fronts')
local btn_reduce_heat = moneyfronts:button('Reduce Heat (Carwash/Smoke/Heli) to 0')
btn_reduce_heat:event(CLICK, function()
  ReduceFrontHeatToZero()
end)

local breakdown = root:submenu('Misc')

local t_global_noxp = breakdown:toggle('No XP Gain (Global)')
t_global_noxp:tooltip('Disables all XP awards while ON by setting World XP multiplier to 0.0. Turn OFF to restore 1.0.')
t_global_noxp:event(CLICK, function()
  SetNoXpGain(t_global_noxp.value)
end)
