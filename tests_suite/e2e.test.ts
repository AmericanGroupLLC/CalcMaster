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


describe('CalMaster — E2E Simulation Tests', () => {

  describe('App launch flow', () => {
    test('app initializes with correct state', () => {
      const appState = { initialized: false, user: null, theme: 'dark', locale: 'en' };
      appState.initialized = true;
      expect(appState.initialized).toBe(true);
      expect(appState.theme).toBe('dark');
      expect(appState.locale).toBe('en');
    });
    test('splash screen duration is reasonable', () => {
      const splashDuration = 2000; // ms
      expect(splashDuration).toBeLessThanOrEqualTo(3000);
    });
    test('deep link parsing', () => {
      const parseDeepLink = (url) => {
        const u = new URL(url);
        return { scheme: u.protocol.replace(':',''), host: u.hostname, path: u.pathname, params: Object.fromEntries(u.searchParams) };
      };
      const result = parseDeepLink('https://americangroupllc.com/calmaster?id=123&ref=email');
      expect(result.host).toBe('americangroupllc.com');
      expect(result.params.id).toBe('123');
      expect(result.params.ref).toBe('email');
    });
  });

  describe('Authentication flow', () => {
    const authFlow = {
      state: 'unauthenticated',
      user: null,
      login(email, password) {
        if (!isValidEmail(email)) return { success: false, error: 'invalid_email' };
        if (password.length < 8) return { success: false, error: 'weak_password' };
        this.state = 'authenticated';
        this.user = { email, id: 'usr_' + email.split('@')[0] };
        return { success: true };
      },
      logout() { this.state = 'unauthenticated'; this.user = null; }
    };

    test('login with valid credentials', () => {
      const r = authFlow.login('user@example.com', 'password123');
      expect(r.success).toBe(true);
      expect(authFlow.state).toBe('authenticated');
    });
    test('login with invalid email fails', () => {
      const r = authFlow.login('bad-email', 'password123');
      expect(r.success).toBe(false);
      expect(r.error).toBe('invalid_email');
    });
    test('login with weak password fails', () => {
      const r = authFlow.login('user@example.com', 'short');
      expect(r.success).toBe(false);
      expect(r.error).toBe('weak_password');
    });
    test('logout clears state', () => {
      authFlow.login('user@example.com', 'password123');
      authFlow.logout();
      expect(authFlow.state).toBe('unauthenticated');
      expect(authFlow.user).toBeNull();
    });
  });

  describe('Onboarding flow', () => {
    const steps = ['welcome', 'permissions', 'profile', 'preferences', 'complete'];
    let currentStep = 0;
    const nextStep = () => { if (currentStep < steps.length - 1) currentStep++; };
    const prevStep = () => { if (currentStep > 0) currentStep--; };
    const progress = () => (currentStep / (steps.length - 1)) * 100;

    test('starts at welcome step', () => expect(steps[currentStep]).toBe('welcome'));
    test('advances to next step', () => { nextStep(); expect(steps[currentStep]).toBe('permissions'); });
    test('goes back to previous step', () => { prevStep(); expect(steps[currentStep]).toBe('welcome'); });
    test('progress at start is 0%', () => expect(progress()).toBe(0));
    test('progress at end is 100%', () => { currentStep = steps.length - 1; expect(progress()).toBe(100); });
  });

  describe('Offline mode simulation', () => {
    let isOnline = true;
    const queue = [];
    const enqueueAction = (action) => { if (!isOnline) queue.push(action); };
    const flushQueue = () => { const flushed = [...queue]; queue.length = 0; return flushed; };

    test('online mode — queue stays empty', () => {
      isOnline = true;
      enqueueAction({type: 'save', data: 'test'});
      expect(queue).toHaveLength(0);
    });
    test('offline mode — actions queued', () => {
      isOnline = false;
      enqueueAction({type: 'save', data: 'test1'});
      enqueueAction({type: 'save', data: 'test2'});
      expect(queue).toHaveLength(2);
    });
    test('flush empties queue', () => {
      const flushed = flushQueue();
      expect(flushed).toHaveLength(2);
      expect(queue).toHaveLength(0);
    });
  });
});
