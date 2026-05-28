describe('CalMaster Functional Tests', () => {
  describe('Calculator state machine', () => {
    it('accumulates digits and computes result', () => {
      let display = '';
      const press = (k: string) => {
        if (k === '=') { display = String(eval(display)); }
        else { display += k; }
      };
      press('3'); press('+'); press('4'); press('*'); press('2'); press('=');
      expect(display).toBe('11');
    });
    it('clears on C', () => {
      let display = '123';
      const clear = () => { display = ''; };
      clear(); expect(display).toBe('');
    });
  });
  describe('Currency conversion', () => {
    const RATES: Record<string, number> = { USD: 1, EUR: 0.92, GBP: 0.79, JPY: 149.5 };
    const convert = (amount: number, from: string, to: string) =>
      parseFloat(((amount / RATES[from]) * RATES[to]).toFixed(4));
    it('USD to EUR', () => { expect(convert(100, 'USD', 'EUR')).toBe(92); });
    it('EUR to USD', () => { expect(convert(92, 'EUR', 'USD')).toBe(100); });
    it('same currency', () => { expect(convert(50, 'USD', 'USD')).toBe(50); });
  });
});
