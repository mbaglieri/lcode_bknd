-- if ip not exist, record and pass
local v_keys1 = KEYS[3]
local v_keys2 = ARGV[1]
local v_argv1 = ARGV[2]
local v_argv2 = ARGV[3]
print(v_keys2)
print(v_argv1)
print(v_argv2)
local windowKey = math.floor(tonumber(v_argv1) / tonumber(v_argv2)) * tonumber(v_argv2)
local noNeed = "[" .. tostring(windowKey - tonumber(v_argv2) - 1)
local minNoNeed = "[0"
redis.call('ZREMRANGEBYLEX', v_keys1, minNoNeed, noNeed)
-- if ip not exist, record and pass
local exist = redis.call('exists', v_keys1)
if (exist == 0) then
  redis.call('zadd', v_keys1, 1, windowKey)
  return 1
end


local preWindowKey = windowKey - tonumber(v_argv2)
local preCount     = tonumber(redis.call('zscore', v_keys1, preWindowKey))
local curCountRaw  = tonumber(redis.call('zscore', v_keys1, windowKey))


if (curCountRaw == nil) then 
  local curCount = 0
  if (preCount == nil) then
  redis.call('zadd', v_keys1, 1, windowKey)
    if (curCount + 1 > tonumber(v_keys2)) then
      return 0
    end
    return 1
  end
  local preWeight = 1 - (tonumber(v_argv1) - windowKey) / tonumber(v_argv2)
  local quota = tonumber(v_keys2) - (preCount * preWeight)
  redis.call('zadd', v_keys1, 1, windowKey)
  if (quota >= 1) then
    return 1
  else 
    return 0
  end

else
  local curCount = curCountRaw
  if (preCount == nil) then
    redis.call('zadd', v_keys1, curCount + 1, windowKey)
    if (curCount + 1 > tonumber(v_keys2)) then
      return 0
    end
    return 1
  end

  local preWeight = 1 - (tonumber(v_argv1) - windowKey) / tonumber(v_argv2)
  local quota = tonumber(v_keys2) - (preCount * preWeight) - curCount
  redis.call('zadd', v_keys1, curCount + 1, windowKey)
  if (quota >= 1) then
    return 1
  else 
    return 0
  end
end
