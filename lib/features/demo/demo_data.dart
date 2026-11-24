const demoDashboardSummary = <String, Object>{
  'Ventas de hoy': '\$8,450.00',
  'Transacciones': 36,
  'Productos activos': 128,
  'Por reabastecer': 5,
};

const demoRecentSales = <Map<String, String>>[
  {
    'code': 'Venta #1042',
    'customer': 'Venta de mostrador',
    'amount': '\$186.50',
  },
  {'code': 'Venta #1041', 'customer': 'María López', 'amount': '\$92.00'},
  {
    'code': 'Venta #1040',
    'customer': 'Venta de mostrador',
    'amount': '\$245.00',
  },
];

List<Map<String, Object>> demoRowsFor(String endpoint) {
  return switch (endpoint) {
    'products' => [
      {'Producto': 'Leche entera 1 L', 'Precio': '\$28.00', 'Existencia': 24},
      {'Producto': 'Arroz 1 kg', 'Precio': '\$32.50', 'Existencia': 18},
      {'Producto': 'Frijol negro 1 kg', 'Precio': '\$39.00', 'Existencia': 12},
    ],
    'categories' => [
      {'Categoría': 'Abarrotes', 'Productos': 48},
      {'Categoría': 'Bebidas', 'Productos': 32},
      {'Categoría': 'Lácteos', 'Productos': 16},
    ],
    'price-rules' => [
      {'Producto': 'Leche entera 1 L', 'Precio': '\$28.00'},
      {'Producto': 'Arroz 1 kg', 'Precio': '\$32.50'},
    ],
    'promotions' => [
      {'Promoción': '2 refrescos por \$35', 'Estado': 'Activa'},
      {'Promoción': '10% en galletas', 'Estado': 'Activa'},
    ],
    'inventory' => [
      {'Producto': 'Leche entera 1 L', 'Existencia': 24, 'Mínimo': 10},
      {'Producto': 'Arroz 1 kg', 'Existencia': 18, 'Mínimo': 8},
      {'Producto': 'Frijol negro 1 kg', 'Existencia': 12, 'Mínimo': 10},
    ],
    'inventory/movements' => [
      {'Movimiento': 'Entrada de mercancía', 'Producto': 'Leche entera 1 L'},
      {'Movimiento': 'Venta', 'Producto': 'Arroz 1 kg'},
    ],
    'sales' => [
      {'Folio': 'V-1042', 'Total': '\$186.50', 'Estado': 'Completada'},
      {'Folio': 'V-1041', 'Total': '\$92.00', 'Estado': 'Completada'},
      {'Folio': 'V-1040', 'Total': '\$245.00', 'Estado': 'Completada'},
    ],
    'payment-methods' => [
      {'Método': 'Efectivo', 'Estado': 'Activo'},
      {'Método': 'Tarjeta', 'Estado': 'Activo'},
    ],
    'returns' => [
      {'Folio': 'D-008', 'Motivo': 'Producto dañado', 'Estado': 'Revisada'},
    ],
    'cancellations' => [
      {
        'Folio': 'V-1038',
        'Motivo': 'Captura incorrecta',
        'Estado': 'Cancelada',
      },
    ],
    'cash-sessions' => [
      {'Caja': 'Caja principal', 'Estado': 'Abierta', 'Fondo': '\$1,000.00'},
    ],
    'cash-movements' => [
      {'Movimiento': 'Fondo inicial', 'Monto': '\$1,000.00'},
      {'Movimiento': 'Retiro', 'Monto': '\$200.00'},
    ],
    'customers' => [
      {'Cliente': 'María López', 'Teléfono': '555 010 2040'},
      {'Cliente': 'Carlos Ruiz', 'Teléfono': '555 010 2078'},
    ],
    'credit-accounts' => [
      {'Cliente': 'María López', 'Saldo': '\$320.00'},
      {'Cliente': 'Carlos Ruiz', 'Saldo': '\$185.00'},
    ],
    'credits' => [
      {'Cliente': 'María López', 'Total': '\$320.00', 'Estado': 'Pendiente'},
    ],
    'payments' => [
      {'Cliente': 'Carlos Ruiz', 'Abono': '\$100.00', 'Fecha': 'Hoy'},
    ],
    'returnable-containers' => [
      {'Envase': 'Garrafa 20 L', 'En tienda': 8, 'Con clientes': 4},
    ],
    'container-movements' => [
      {'Movimiento': 'Devolución', 'Envase': 'Garrafa 20 L', 'Cantidad': 2},
    ],
    _ => const [],
  };
}
