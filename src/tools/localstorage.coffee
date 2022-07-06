NodeCache = require "node-cache";

class LocalStorage
  # /** @type {import('node-cache')} */
  @localStorage;

  constructor:() ->
    @localStorage = new NodeCache();

  # /**
  #  * 
  #  * @param {string} key 
  #  * @param {object} obj 
  #  * @param {number | string} ttl 
  #  * @returns {boolean}
  #  */
  set: (key, obj, ttl) ->
    return @localStorage.set(key, obj, ttl);

  # /**
  #  * 
  #  * @param {Array<{key:string, val:object, ttl: number | string}>} array 
  #  * @returns {void}
  #  */
  mset: (array) ->
    @localStorage.mset(array);

  # /**
  #  * 
  #  * @param {Array<string> | string} key 
  #  * @returns {{[key: string]: any}}
  #  */
  get:(key) ->
    if(Array.isArray(key))
      return @localStorage.mget(key);

    return
      [key]: @localStorage.get(key)

  # /**
  #  * @param {Array<string> | string} key
  #  * @returns {number} 
  #  */
  del:(key) ->
    return @localStorage.del(key);

  # /**
  #  * @param {string} key
  #  * @returns {boolean} 
  #  */
  exist:(key) ->
    return @localStorage.has(key);

  # /**
  #  * @param {string} key
  #  * @returns {number} 
  #  */
  getTtl:(key) ->
    return @localStorage.getTtl(key);

  # /**
  #  * 
  #  * @param {string} key 
  #  * @param {number} time 
  #  * @returns {boolean}
  #  */
  changeTtl:(key, time) ->
    return @localStorage.ttl(key, time);

  # /**
  #  * 
  #  * @returns {{keys: number, hits:number, misses:number, ksize:number, vsize:number}}
  #  */
  getStatus:() ->
    return @localStorage.getStatus();

  # /**
  #  * @returns {void}
  #  */
  clear:() ->
    @localStorage.close();

  # /**
  #  * 
  #  * @param {'set' | 'del' | 'expired' | 'flush' | 'flush_stats'} key 
  #  * @param {function(key, value)} callback 
  #  */
  observable: (key, callback) ->
    @localStorage.on(key, callback);

@localStorage =  new LocalStorage();