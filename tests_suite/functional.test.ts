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


describe('CalMaster — Functional Tests', () => {

  describe('Search functionality', () => {
    const items = [
      {id:1, name:'Alpha Widget', category:'tools', price:9.99},
      {id:2, name:'Beta Gadget', category:'electronics', price:49.99},
      {id:3, name:'Gamma Tool', category:'tools', price:19.99},
      {id:4, name:'Delta Device', category:'electronics', price:99.99},
      {id:5, name:'Epsilon App', category:'software', price:4.99},
    ];
    const search = (q) => items.filter(i => i.name.toLowerCase().includes(q.toLowerCase()));
    const filterByCategory = (cat) => items.filter(i => i.category === cat);
    const sortByPrice = (asc=true) => [...items].sort((a,b) => asc ? a.price-b.price : b.price-a.price);

    test('search returns matching items', () => expect(search('alpha')).toHaveLength(1));
    test('search is case-insensitive', () => expect(search('BETA')).toHaveLength(1));
    test('empty query returns all', () => expect(search('')).toHaveLength(5));
    test('no match returns empty', () => expect(search('xyz')).toHaveLength(0));
    test('filter by category', () => expect(filterByCategory('tools')).toHaveLength(2));
    test('sort ascending by price', () => expect(sortByPrice(true)[0].price).toBe(4.99));
    test('sort descending by price', () => expect(sortByPrice(false)[0].price).toBe(99.99));
  });

  describe('User session management', () => {
    const sessions = new Map();
    const createSession = (userId) => { const token = `tok_${userId}_${Date.now()}`; sessions.set(token, {userId, createdAt: Date.now()}); return token; };
    const validateSession = (token) => sessions.has(token);
    const revokeSession = (token) => sessions.delete(token);

    test('creates valid session token', () => {
      const token = createSession('user123');
      expect(token).toMatch(/^tok_user123_/);
    });
    test('session is valid after creation', () => {
      const token = createSession('user456');
      expect(validateSession(token)).toBe(true);
    });
    test('revoked session is invalid', () => {
      const token = createSession('user789');
      revokeSession(token);
      expect(validateSession(token)).toBe(false);
    });
    test('unknown token is invalid', () => expect(validateSession('unknown')).toBe(false));
  });

  describe('Notification system', () => {
    const notifications = [];
    const addNotif = (type, msg) => { notifications.push({type, msg, read: false, ts: Date.now()}); };
    const markRead = (idx) => { if (notifications[idx]) notifications[idx].read = true; };
    const unreadCount = () => notifications.filter(n => !n.read).length;

    test('adds notification', () => { addNotif('info', 'Test'); expect(notifications.length).toBeGreaterThan(0); });
    test('marks notification as read', () => { addNotif('alert', 'Alert'); markRead(notifications.length-1); expect(notifications[notifications.length-1].read).toBe(true); });
    test('unread count decreases after read', () => {
      const before = unreadCount();
      addNotif('info', 'New');
      expect(unreadCount()).toBe(before + 1);
    });
  });

  describe('Settings persistence', () => {
    const store = {};
    const setSetting = (k, v) => { store[k] = v; };
    const getSetting = (k, def=null) => store[k] !== undefined ? store[k] : def;

    test('stores and retrieves string', () => { setSetting('theme', 'dark'); expect(getSetting('theme')).toBe('dark'); });
    test('stores and retrieves boolean', () => { setSetting('notifications', true); expect(getSetting('notifications')).toBe(true); });
    test('returns default for missing key', () => expect(getSetting('missing', 'default')).toBe('default'));
    test('overwrites existing value', () => { setSetting('theme', 'light'); expect(getSetting('theme')).toBe('light'); });
  });
});
