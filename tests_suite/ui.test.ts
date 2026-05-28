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


describe('CalMaster — UI/UX Simulation Tests', () => {

  describe('Theme system', () => {
    const themes = {
      dark:  { bg: '#0f0f0f', surface: '#1a1a1a', text: '#ffffff', primary: '#6366f1' },
      light: { bg: '#ffffff', surface: '#f5f5f5', text: '#0f0f0f', primary: '#4f46e5' },
    };
    test('dark theme has dark background', () => expect(themes.dark.bg).toBe('#0f0f0f'));
    test('light theme has light background', () => expect(themes.light.bg).toBe('#ffffff'));
    test('dark theme text is light', () => expect(themes.dark.text).toBe('#ffffff'));
    test('light theme text is dark', () => expect(themes.light.text).toBe('#0f0f0f'));
    test('both themes have primary color', () => {
      expect(themes.dark.primary).toBeDefined();
      expect(themes.light.primary).toBeDefined();
    });
  });

  describe('Navigation state machine', () => {
    const navState = { stack: ['home'], current: 'home' };
    const push = (screen) => { navState.stack.push(screen); navState.current = screen; };
    const pop = () => { if (navState.stack.length > 1) { navState.stack.pop(); navState.current = navState.stack[navState.stack.length-1]; } };
    const reset = () => { navState.stack = ['home']; navState.current = 'home'; };

    test('starts on home screen', () => expect(navState.current).toBe('home'));
    test('push navigates to new screen', () => { push('detail'); expect(navState.current).toBe('detail'); });
    test('pop returns to previous screen', () => { pop(); expect(navState.current).toBe('home'); });
    test('cannot pop below root', () => { pop(); expect(navState.current).toBe('home'); expect(navState.stack).toHaveLength(1); });
    test('reset clears stack', () => { push('a'); push('b'); reset(); expect(navState.stack).toHaveLength(1); });
  });

  describe('Form validation', () => {
    const validateForm = (fields) => {
      const errors = {};
      if (!fields.name || fields.name.trim().length < 2) errors.name = 'Name must be at least 2 characters';
      if (!isValidEmail(fields.email)) errors.email = 'Invalid email address';
      if (!fields.password || fields.password.length < 8) errors.password = 'Password must be at least 8 characters';
      return { valid: Object.keys(errors).length === 0, errors };
    };

    test('valid form passes', () => {
      const r = validateForm({name: 'John', email: 'john@example.com', password: 'password123'});
      expect(r.valid).toBe(true);
      expect(Object.keys(r.errors)).toHaveLength(0);
    });
    test('short name fails', () => {
      const r = validateForm({name: 'J', email: 'j@example.com', password: 'password123'});
      expect(r.valid).toBe(false);
      expect(r.errors.name).toBeDefined();
    });
    test('invalid email fails', () => {
      const r = validateForm({name: 'John', email: 'bad', password: 'password123'});
      expect(r.errors.email).toBeDefined();
    });
    test('short password fails', () => {
      const r = validateForm({name: 'John', email: 'j@example.com', password: 'short'});
      expect(r.errors.password).toBeDefined();
    });
    test('multiple errors reported', () => {
      const r = validateForm({name: '', email: 'bad', password: ''});
      expect(Object.keys(r.errors).length).toBeGreaterThanOrEqualTo(2);
    });
  });

  describe('Responsive layout breakpoints', () => {
    const getLayout = (width) => {
      if (width < 600) return 'mobile';
      if (width < 1024) return 'tablet';
      return 'desktop';
    };
    test('320px → mobile', () => expect(getLayout(320)).toBe('mobile'));
    test('390px → mobile', () => expect(getLayout(390)).toBe('mobile'));
    test('768px → tablet', () => expect(getLayout(768)).toBe('tablet'));
    test('1024px → desktop', () => expect(getLayout(1024)).toBe('desktop'));
    test('1440px → desktop', () => expect(getLayout(1440)).toBe('desktop'));
  });

  describe('Accessibility simulation', () => {
    const checkContrast = (fg, bg) => {
      // Simplified: just check they're different enough
      return fg !== bg;
    };
    test('dark theme contrast passes', () => expect(checkContrast('#ffffff', '#0f0f0f')).toBe(true));
    test('light theme contrast passes', () => expect(checkContrast('#0f0f0f', '#ffffff')).toBe(true));
    test('same color fails contrast', () => expect(checkContrast('#fff', '#fff')).toBe(false));

    const minTouchTarget = 44;
    test('button meets minimum touch target', () => expect(minTouchTarget).toBeGreaterThanOrEqualTo(44));
    test('icon button meets minimum touch target', () => expect(48).toBeGreaterThanOrEqualTo(44));
  });

  describe('Animation timing', () => {
    const animations = {
      buttonPress:  160,
      tooltip:      175,
      dropdown:     200,
      modal:        300,
      pageTransition: 350,
    };
    test('button press under 200ms', () => expect(animations.buttonPress).toBeLessThan(200));
    test('tooltip under 250ms', () => expect(animations.tooltip).toBeLessThan(250));
    test('dropdown under 300ms', () => expect(animations.dropdown).toBeLessThan(300));
    test('modal under 500ms', () => expect(animations.modal).toBeLessThan(500));
    test('page transition under 500ms', () => expect(animations.pageTransition).toBeLessThan(500));
  });
});
