-- if ip not exist, record and pass
local v_keys1 = KEYS[1]
local v_keys2 = tonumber(ARGV[1])
local v_argv1 = tonumber(ARGV[2])
local v_argv2 = tonumber(ARGV[3])

local exist = redis.call('exists', v_keys1)
if (exist == 0) then
  redis.call('rpush', v_keys1, v_argv1);
  return 1
end

-- if list len < limit, push new one and pass
local len = redis.call('llen', v_keys1)
if (len < tonumber(v_keys2)) then
  redis.call('rpush', v_keys1, v_argv1);
  return 1
end

-- if list len > limit, caused by limit changing, use ltrim to fix
if (len > tonumber(v_keys2)) then
  redis.call('ltrim', v_keys1, -(tonumber(v_keys2)), -1)
end

local time = redis.call('lindex', v_keys1, 0)

-- if current time - oldest timestamp > window, pass 
if (tonumber(v_argv1) - time > tonumber(v_argv2)) then
  redis.call('rpush', v_keys1, v_argv1);
  redis.call('lpop', v_keys1);
  return 1
else
  redis.call('rpush', v_keys1, v_argv1);
  redis.call('lpop', v_keys1);
  return 0
end