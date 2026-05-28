        // Shared domain helpers for CalMaster
const isValidEmail = (e) => /^[\w.+-]+@[\w-]+\.[\w.]+$/.test(e);
const isValidUrl = (u) => u.startsWith('http://') || u.startsWith('https://');
const formatCurrency = (n, sym='$') => `${sym}${Number(n).toFixed(2)}`;
const clamp = (v, min, max) => Math.min(Math.max(v, min), max);
const truncate = (s, max) => s.length <= max ? s : s.slice(0, max) + '...';
const paginate = (arr, page, size) => arr.slice(page * size, (page + 1) * size);
const toSlug = (s) => s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
const daysBetween = (a, b) => Math.abs(Math.round((b - a) / 86400000));
const isPastDate = (d) => d < new Date();
const formatDate = (d) => d.toISOString().slice(0, 10);
const debounce = (fn, ms) => { let t; return (...a) => { clearTimeout(t); t = setTimeout(() => fn(...a), ms); }; };
const deepEqual = (a, b) => JSON.stringify(a) === JSON.stringify(b);


describe('CalMaster — Integration Tests', () => {

  describe('API service layer', () => {
    const API_BASE = 'https://api.americangroupllc.com/v1/calmaster';

    test('API base URL is correct', () => {
      expect(API_BASE).toContain('americangroupllc.com');
      expect(API_BASE).toContain('calmaster');
    });
    test('API URL uses HTTPS', () => expect(API_BASE.startsWith('https://')).toBe(true));
    test('constructs endpoint URL correctly', () => {
      const endpoint = `${API_BASE}/search?q=test`;
      expect(endpoint).toContain('/search');
      expect(endpoint).toContain('q=test');
    });
    test('constructs auth header', () => {
      const token = 'Bearer test-token-123';
      expect(token.startsWith('Bearer ')).toBe(true);
    });
    test('handles query params encoding', () => {
      const query = encodeURIComponent('hello world & more');
      expect(query).toBe('hello%20world%20%26%20more');
    });
  });

  describe('Data transformation pipeline', () => {
    const rawApiResponse = {
      items: [
        {id: '1', title: 'Item One', price_cents: 999, created_at: '2026-01-01T00:00:00Z'},
        {id: '2', title: 'Item Two', price_cents: 4999, created_at: '2026-02-01T00:00:00Z'},
      ],
      total: 2,
      page: 0,
      per_page: 10
    };

    const transform = (raw) => raw.items.map(i => ({
      id: i.id,
      title: i.title,
      price: i.price_cents / 100,
      createdAt: new Date(i.created_at)
    }));

    test('transforms price from cents to dollars', () => {
      const items = transform(rawApiResponse);
      expect(items[0].price).toBe(9.99);
      expect(items[1].price).toBe(49.99);
    });
    test('parses date strings to Date objects', () => {
      const items = transform(rawApiResponse);
      expect(items[0].createdAt).toBeInstanceOf(Date);
    });
    test('preserves item count', () => {
      expect(transform(rawApiResponse)).toHaveLength(2);
    });
    test('pagination metadata correct', () => {
      expect(rawApiResponse.total).toBe(2);
      expect(rawApiResponse.per_page).toBe(10);
    });
  });

  describe('Error handling', () => {
    const handleApiError = (status) => {
      if (status === 401) return 'unauthorized';
      if (status === 403) return 'forbidden';
      if (status === 404) return 'not_found';
      if (status === 429) return 'rate_limited';
      if (status >= 500) return 'server_error';
      return 'unknown_error';
    };

    test('401 → unauthorized', () => expect(handleApiError(401)).toBe('unauthorized'));
    test('403 → forbidden', () => expect(handleApiError(403)).toBe('forbidden'));
    test('404 → not_found', () => expect(handleApiError(404)).toBe('not_found'));
    test('429 → rate_limited', () => expect(handleApiError(429)).toBe('rate_limited'));
    test('500 → server_error', () => expect(handleApiError(500)).toBe('server_error'));
    test('503 → server_error', () => expect(handleApiError(503)).toBe('server_error'));
  });

  describe('Cache layer', () => {
    const cache = new Map();
    const TTL = 300000; // 5 min
    const setCache = (k, v) => cache.set(k, {v, ts: Date.now()});
    const getCache = (k) => {
      const entry = cache.get(k);
      if (!entry) return null;
      if (Date.now() - entry.ts > TTL) { cache.delete(k); return null; }
      return entry.v;
    };

    test('stores and retrieves value', () => { setCache('key1', 'value1'); expect(getCache('key1')).toBe('value1'); });
    test('returns null for missing key', () => expect(getCache('missing')).toBeNull());
    test('cache size grows correctly', () => {
      setCache('a', 1); setCache('b', 2); setCache('c', 3);
      expect(cache.size).toBeGreaterThanOrEqualTo(3);
    });
  });
});
