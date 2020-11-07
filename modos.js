const monedas = [1, 2, 5, 10];

function modos(monto) {
  const aux = new Array(monto + 1);
  for (let i = 0; i <= monto; i++) {
    aux[i] = new Array(monedas.length).fill(-1);
  }

  function m(i, j) {
    if (i < 0 || j <= 0) {
      return 0;
    }

    if (aux[i][j - 1] !== -1) return aux[i][j - 1];

    if (i === 0) {
      aux[i][j - 1] = 1;
      return 1;
    }

    aux[i][j - 1] = m(i, j - 1) + m(i - monedas[j - 1], j);
    return aux[i][j - 1];
  }

  const v = m(monto, monedas.length);
  console.log(aux);
  return v;
}

console.log(modos(76));
