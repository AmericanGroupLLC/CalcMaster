describe('CalMaster Integration Tests', () => {
  describe('i18n completeness', () => {
    const REQUIRED = ['calculator', 'converter', 'history', 'settings', 'clear'];
    const locales: Record<string, Record<string, string>> = {
      en: { calculator: 'Calculator', converter: 'Converter', history: 'History', settings: 'Settings', clear: 'Clear' },
      es: { calculator: 'Calculadora', converter: 'Convertidor', history: 'Historial', settings: 'Ajustes', clear: 'Borrar' },
    };
    it('EN has all keys', () => { REQUIRED.forEach(k => expect(locales.en).toHaveProperty(k)); });
    it('ES has all keys', () => { REQUIRED.forEach(k => expect(locales.es).toHaveProperty(k)); });
    it('no value is empty', () => {
      Object.values(locales).forEach(l => Object.values(l).forEach(v => expect(v.length).toBeGreaterThan(0)));
    });
  });
  describe('Tax bracket lookup', () => {
    const brackets = [
      { min: 0, max: 11000, rate: 10 },
      { min: 11001, max: 44725, rate: 12 },
      { min: 44726, max: 95375, rate: 22 },
    ];
    const getBracket = (income: number) => brackets.find(b => income >= b.min && income <= b.max);
    it('income 5000 is in 10% bracket', () => { expect(getBracket(5000)?.rate).toBe(10); });
    it('income 30000 is in 12% bracket', () => { expect(getBracket(30000)?.rate).toBe(12); });
    it('income 60000 is in 22% bracket', () => { expect(getBracket(60000)?.rate).toBe(22); });
  });
});
