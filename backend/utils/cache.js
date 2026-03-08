const cache = new Map();

/**
 * Simple in-memory cache with TTL support.
 * Can be swapped for Redis easily by changing get/set implementation.
 */
const cacheService = {
  get: (key) => {
    const data = cache.get(key);
    if (!data) return null;

    if (data.expiry && data.expiry < Date.now()) {
      cache.delete(key);
      return null;
    }
    return data.value;
  },

  set: (key, value, ttlSeconds = 300) => {
    const expiry = ttlSeconds ? Date.now() + ttlSeconds * 1000 : null;
    cache.set(key, { value, expiry });
  },

  del: (key) => {
    cache.delete(key);
  },

  clear: () => {
    cache.clear();
  }
};

module.exports = cacheService;
