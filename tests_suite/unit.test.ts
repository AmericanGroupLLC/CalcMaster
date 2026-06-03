export {};
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


describe('CalMaster — Unit Tests', () => {

  describe('Input validation', () => {
    test('valid email', () => expect(isValidEmail('user@example.com')).toBe(true));
    test('invalid email', () => expect(isValidEmail('bad')).toBe(false));
    test('empty string invalid', () => expect(isValidEmail('')).toBe(false));
    test('valid https URL', () => expect(isValidUrl('https://api.americangroupllc.com')).toBe(true));
    test('invalid URL', () => expect(isValidUrl('ftp://bad')).toBe(false));
  });

  describe('Currency formatting', () => {
    test('USD format', () => expect(formatCurrency(9.99)).toBe('$9.99'));
    test('rounds to 2dp', () => expect(formatCurrency(1.999)).toBe('$2.00'));
    test('zero', () => expect(formatCurrency(0)).toBe('$0.00'));
    test('custom symbol', () => expect(formatCurrency(5, '€')).toBe('€5.00'));
    test('large amount', () => expect(formatCurrency(99999.99)).toBe('$99999.99'));
  });

  describe('Clamp', () => {
    test('within range', () => expect(clamp(5, 0, 10)).toBe(5));
    test('below min', () => expect(clamp(-1, 0, 10)).toBe(0));
    test('above max', () => expect(clamp(15, 0, 10)).toBe(10));
    test('at boundary min', () => expect(clamp(0, 0, 10)).toBe(0));
    test('at boundary max', () => expect(clamp(10, 0, 10)).toBe(10));
  });

  describe('Truncation', () => {
    test('short text unchanged', () => expect(truncate('hi', 10)).toBe('hi'));
    test('long text truncated', () => expect(truncate('hello world', 5)).toBe('hello...'));
    test('exact length unchanged', () => expect(truncate('hello', 5)).toBe('hello'));
  });

  describe('Slug generation', () => {
    test('lowercase', () => expect(toSlug('Hello World')).toBe('hello-world'));
    test('special chars', () => expect(toSlug('C++ & Java!')).toBe('c-java'));
    test('numbers preserved', () => expect(toSlug('App v2.0')).toBe('app-v2-0'));
  });

  describe('Date utilities', () => {
    test('past date detected', () => expect(isPastDate(new Date('2020-01-01'))).toBe(true));
    test('future date not past', () => expect(isPastDate(new Date('2099-01-01'))).toBe(false));
    test('days between', () => expect(daysBetween(new Date('2026-01-01'), new Date('2026-01-11'))).toBe(10));
    test('same day is 0', () => expect(daysBetween(new Date('2026-05-28'), new Date('2026-05-28'))).toBe(0));
    test('format date', () => expect(formatDate(new Date('2026-05-28T00:00:00Z'))).toBe('2026-05-28'));
  });

  describe('Utilities', () => {
    test('deepEqual same objects', () => expect(deepEqual({a:1}, {a:1})).toBe(true));
    test('deepEqual different objects', () => expect(deepEqual({a:1}, {a:2})).toBe(false));
    test('paginate first page', () => expect(paginate([1,2,3,4,5], 0, 2)).toEqual([1,2]));
    test('paginate second page', () => expect(paginate([1,2,3,4,5], 1, 2)).toEqual([3,4]));
    test('paginate out of range', () => expect(paginate([1,2,3], 5, 2)).toEqual([]));
  });
});
