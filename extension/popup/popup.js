const UNITS = {
  distance: {
    units: ['m','km','mi','ft','in','cm','mm','yd'],
    labels: {m:'Meter',km:'Kilometer',mi:'Mile',ft:'Foot',in:'Inch',cm:'Centimeter',mm:'Millimeter',yd:'Yard'},
    toBase: {m:1,km:1000,mi:1609.344,ft:0.3048,in:0.0254,cm:0.01,mm:0.001,yd:0.9144}
  },
  weight: {
    units: ['kg','g','lb','oz','mg','t'],
    labels: {kg:'Kilogram',g:'Gram',lb:'Pound',oz:'Ounce',mg:'Milligram',t:'Metric Ton'},
    toBase: {kg:1,g:0.001,lb:0.453592,oz:0.0283495,mg:0.000001,t:1000}
  },
  temperature: {
    units: ['C','F','K'],
    labels: {C:'Celsius',F:'Fahrenheit',K:'Kelvin'},
    toBase: null
  },
  volume: {
    units: ['L','mL','gal','qt','pt','cup','floz'],
    labels: {L:'Liter',mL:'Milliliter',gal:'Gallon',qt:'Quart',pt:'Pint',cup:'Cup',floz:'Fl Oz'},
    toBase: {L:1,mL:0.001,gal:3.78541,qt:0.946353,pt:0.473176,cup:0.236588,floz:0.0295735}
  },
  speed: {
    units: ['m/s','km/h','mph','kn'],
    labels: {'m/s':'m/s','km/h':'km/h',mph:'mph',kn:'Knot'},
    toBase: {'m/s':1,'km/h':0.277778,mph:0.44704,kn:0.514444}
  },
  area: {
    units: ['m²','km²','ft²','ac','ha'],
    labels: {'m²':'Sq Meter','km²':'Sq Km','ft²':'Sq Foot',ac:'Acre',ha:'Hectare'},
    toBase: {'m²':1,'km²':1e6,'ft²':0.092903,ac:4046.86,ha:10000}
  },
  data: {
    units: ['B','KB','MB','GB','TB'],
    labels: {B:'Byte',KB:'Kilobyte',MB:'Megabyte',GB:'Gigabyte',TB:'Terabyte'},
    toBase: {B:1,KB:1024,MB:1048576,GB:1073741824,TB:1099511627776}
  },
  pressure: {
    units: ['Pa','kPa','bar','atm','psi'],
    labels: {Pa:'Pascal',kPa:'Kilopascal',bar:'Bar',atm:'Atmosphere',psi:'PSI'},
    toBase: {Pa:1,kPa:1000,bar:100000,atm:101325,psi:6894.76}
  },
  energy: {
    units: ['J','kJ','cal','kcal','Wh','kWh'],
    labels: {J:'Joule',kJ:'Kilojoule',cal:'Calorie',kcal:'Kilocalorie',Wh:'Watt-hour',kWh:'Kilowatt-hour'},
    toBase: {J:1,kJ:1000,cal:4.184,kcal:4184,Wh:3600,kWh:3600000}
  }
};

function convertTemp(val, from, to) {
  let c;
  if (from === 'C') c = val;
  else if (from === 'F') c = (val - 32) * 5 / 9;
  else c = val - 273.15;
  if (to === 'C') return c;
  if (to === 'F') return c * 9 / 5 + 32;
  return c + 273.15;
}

function convert(val, from, to, cat) {
  if (cat === 'temperature') return convertTemp(val, from, to);
  const data = UNITS[cat];
  return val * data.toBase[from] / data.toBase[to];
}

// Calculator state
let expr = '';
let lastResult = '';

function updateDisplay() {
  document.getElementById('calc-expr').textContent = expr;
  try {
    if (expr.length > 0) {
      const safe = expr.replace(/[^0-9+\-*/.()%]/g, '');
      const result = Function('"use strict"; return (' + safe + ')')();
      if (isFinite(result)) {
        lastResult = Number(result.toPrecision(12)).toString();
        document.getElementById('calc-result').textContent = lastResult;
      }
    } else {
      document.getElementById('calc-result').textContent = '0';
    }
  } catch { /* incomplete expression */ }
}

// Tab switching
document.querySelectorAll('.tab').forEach(tab => {
  tab.addEventListener('click', () => {
    document.querySelectorAll('.tab').forEach(t => { t.classList.remove('active'); t.setAttribute('aria-selected', 'false'); });
    document.querySelectorAll('.panel').forEach(p => p.classList.remove('active'));
    tab.classList.add('active');
    tab.setAttribute('aria-selected', 'true');
    document.getElementById('panel-' + tab.dataset.panel).classList.add('active');
  });
});

// Calculator keys
document.querySelectorAll('.key').forEach(key => {
  key.addEventListener('click', () => {
    const action = key.dataset.action;
    if (action === 'input') {
      expr += key.dataset.val;
      updateDisplay();
    } else if (action === 'clear') {
      expr = '';
      updateDisplay();
    } else if (action === 'backspace') {
      expr = expr.slice(0, -1);
      updateDisplay();
    } else if (action === 'percent') {
      try {
        const safe = expr.replace(/[^0-9+\-*/.()]/g, '');
        const result = Function('"use strict"; return (' + safe + ')')();
        expr = (result / 100).toString();
        updateDisplay();
      } catch { /* ignore */ }
    } else if (action === 'equals') {
      try {
        const safe = expr.replace(/[^0-9+\-*/.()]/g, '');
        const result = Function('"use strict"; return (' + safe + ')')();
        if (isFinite(result)) {
          expr = Number(result.toPrecision(12)).toString();
          updateDisplay();
        }
      } catch { /* ignore */ }
    }
  });
});

// Keyboard input
document.addEventListener('keydown', (e) => {
  if (document.querySelector('#panel-calc.active')) {
    if (/^[0-9+\-*/.()]$/.test(e.key)) {
      expr += e.key;
      updateDisplay();
    } else if (e.key === 'Enter') {
      document.querySelector('.key.eq').click();
    } else if (e.key === 'Backspace') {
      expr = expr.slice(0, -1);
      updateDisplay();
    } else if (e.key === 'Escape') {
      expr = '';
      updateDisplay();
    }
  }
});

// Converter
const catSelect = document.getElementById('convert-category');
const fromUnit = document.getElementById('convert-from-unit');
const toUnit = document.getElementById('convert-to-unit');
const fromVal = document.getElementById('convert-from-val');
const toVal = document.getElementById('convert-to-val');

function populateUnits() {
  const cat = catSelect.value;
  const data = UNITS[cat];
  fromUnit.innerHTML = '';
  toUnit.innerHTML = '';
  data.units.forEach((u, i) => {
    fromUnit.add(new Option(data.labels[u], u, i === 0, i === 0));
    toUnit.add(new Option(data.labels[u], u, i === 1, i === 1));
  });
  doConvert();
}

function doConvert() {
  const val = parseFloat(fromVal.value) || 0;
  const result = convert(val, fromUnit.value, toUnit.value, catSelect.value);
  toVal.value = Number(result.toPrecision(10)).toString();
}

catSelect.addEventListener('change', populateUnits);
fromUnit.addEventListener('change', doConvert);
toUnit.addEventListener('change', doConvert);
fromVal.addEventListener('input', doConvert);
document.getElementById('convert-swap').addEventListener('click', () => {
  const temp = fromUnit.value;
  fromUnit.value = toUnit.value;
  toUnit.value = temp;
  doConvert();
});
populateUnits();

// Finance tools
const financeMode = document.getElementById('finance-mode');
const financeFields = document.getElementById('finance-fields');
const financeResult = document.getElementById('finance-result');

function setupFinance() {
  const mode = financeMode.value;
  financeResult.textContent = '';
  if (mode === 'tip') {
    financeFields.innerHTML = `
      <div><label for="f-bill">Bill Amount</label><input id="f-bill" type="number" placeholder="0.00" step="0.01"></div>
      <div><label for="f-tip">Tip %</label><input id="f-tip" type="number" value="15" step="1"></div>
      <div><label for="f-split">Split Between</label><input id="f-split" type="number" value="1" min="1" step="1"></div>
    `;
  } else if (mode === 'discount') {
    financeFields.innerHTML = `
      <div><label for="f-price">Original Price</label><input id="f-price" type="number" placeholder="0.00" step="0.01"></div>
      <div><label for="f-disc">Discount %</label><input id="f-disc" type="number" value="10" step="1"></div>
    `;
  } else {
    financeFields.innerHTML = `
      <div><label for="f-base">Base Value</label><input id="f-base" type="number" placeholder="0" step="any"></div>
      <div><label for="f-pct">Percentage</label><input id="f-pct" type="number" value="10" step="any"></div>
    `;
  }
  financeFields.querySelectorAll('input').forEach(i => i.addEventListener('input', calcFinance));
}

function calcFinance() {
  const mode = financeMode.value;
  if (mode === 'tip') {
    const bill = parseFloat(document.getElementById('f-bill')?.value) || 0;
    const tip = parseFloat(document.getElementById('f-tip')?.value) || 0;
    const split = parseInt(document.getElementById('f-split')?.value) || 1;
    const tipAmt = bill * tip / 100;
    const total = bill + tipAmt;
    const perPerson = total / split;
    financeResult.textContent = `Tip: $${tipAmt.toFixed(2)} · Total: $${total.toFixed(2)} · Each: $${perPerson.toFixed(2)}`;
  } else if (mode === 'discount') {
    const price = parseFloat(document.getElementById('f-price')?.value) || 0;
    const disc = parseFloat(document.getElementById('f-disc')?.value) || 0;
    const savings = price * disc / 100;
    const final_ = price - savings;
    financeResult.textContent = `Save: $${savings.toFixed(2)} · Final: $${final_.toFixed(2)}`;
  } else {
    const base = parseFloat(document.getElementById('f-base')?.value) || 0;
    const pct = parseFloat(document.getElementById('f-pct')?.value) || 0;
    const result = base * pct / 100;
    financeResult.textContent = `${pct}% of ${base} = ${Number(result.toPrecision(10))}`;
  }
}

financeMode.addEventListener('change', setupFinance);
setupFinance();

// Open full app link
document.getElementById('open-full-app').addEventListener('click', (e) => {
  e.preventDefault();
  chrome.tabs.create({ url: 'https://calcmaster.app/web/' });
});

// Save/restore state
function saveState() {
  chrome.storage.local.set({
    calcExpr: expr,
    convertCat: catSelect.value,
    convertFrom: fromUnit.value,
    convertTo: toUnit.value,
    convertVal: fromVal.value,
    financeMode: financeMode.value
  });
}

function restoreState() {
  chrome.storage.local.get(
    ['calcExpr', 'convertCat', 'convertFrom', 'convertTo', 'convertVal', 'financeMode'],
    (data) => {
      if (data.calcExpr) { expr = data.calcExpr; updateDisplay(); }
      if (data.convertCat) { catSelect.value = data.convertCat; populateUnits(); }
      if (data.convertFrom) fromUnit.value = data.convertFrom;
      if (data.convertTo) toUnit.value = data.convertTo;
      if (data.convertVal) { fromVal.value = data.convertVal; doConvert(); }
      if (data.financeMode) { financeMode.value = data.financeMode; setupFinance(); }
    }
  );
}

restoreState();
setInterval(saveState, 2000);
