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


describe('CalMaster — Performance Tests', () => {

  describe('Computation benchmarks', () => {
    test('paginate 10k items 100x under 50ms', () => {
      const items = Array.from({length: 10000}, (_, i) => i);
      const start = Date.now();
      for (let i = 0; i < 100; i++) paginate(items, i % 100, 100);
      expect(Date.now() - start).toBeLessThan(50);
    });
    test('slug generation 5k times under 100ms', () => {
      const start = Date.now();
      for (let i = 0; i < 5000; i++) toSlug(`Hello World ${i}`);
      expect(Date.now() - start).toBeLessThan(100);
    });
    test('currency format 10k times under 50ms', () => {
      const start = Date.now();
      for (let i = 0; i < 10000; i++) formatCurrency(Math.random() * 1000);
      expect(Date.now() - start).toBeLessThan(50);
    });
    test('deep equal 1k comparisons under 20ms', () => {
      const obj = {a: 1, b: {c: 2, d: [1,2,3]}};
      const start = Date.now();
      for (let i = 0; i < 1000; i++) deepEqual(obj, {...obj});
      expect(Date.now() - start).toBeLessThan(20);
    });
  });

  describe('Memory efficiency', () => {
    test('paginate does not mutate original array', () => {
      const original = [1, 2, 3, 4, 5];
      const copy = [...original];
      paginate(original, 0, 2);
      expect(original).toEqual(copy);
    });
    test('large dataset pagination is O(n) not O(n²)', () => {
      const small = Array.from({length: 100}, (_, i) => i);
      const large = Array.from({length: 10000}, (_, i) => i);
      const t1 = Date.now(); for (let i=0;i<100;i++) paginate(small, 0, 10); const d1 = Date.now()-t1;
      const t2 = Date.now(); for (let i=0;i<100;i++) paginate(large, 0, 10); const d2 = Date.now()-t2;
      // Large should not be more than 50x slower than small
      expect(d2).toBeLessThan(d1 * 50 + 50);
    });
  });

  describe('UI render simulation', () => {
    test('list of 100 items renders under 16ms budget', () => {
      const items = Array.from({length: 100}, (_, i) => ({id: i, name: `Item ${i}`, price: i * 9.99}));
      const start = Date.now();
      const rendered = items.map(i => `<div id="${i.id}">${truncate(i.name, 20)} — ${formatCurrency(i.price)}</div>`).join('');
      expect(Date.now() - start).toBeLessThan(16);
      expect(rendered).toContain('Item 0');
    });
    test('search filter on 1k items under 10ms', () => {
      const items = Array.from({length: 1000}, (_, i) => ({name: `Product ${i}`}));
      const start = Date.now();
      const results = items.filter(i => i.name.includes('Product 5'));
      expect(Date.now() - start).toBeLessThan(10);
      expect(results.length).toBeGreaterThan(0);
    });
  });
});
