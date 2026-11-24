import 'package:flutter/material.dart';

class ModuleEndpoint {
  const ModuleEndpoint({required this.label, required this.path});

  final String label;
  final String path;
}

class PoslyModule {
  const PoslyModule({
    required this.title,
    required this.description,
    required this.icon,
    required this.endpoints,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<ModuleEndpoint> endpoints;
}

const poslyModules = <PoslyModule>[
  PoslyModule(
    title: 'Productos y categorías',
    description: 'Consulta el catálogo y organiza los productos de tu tienda.',
    icon: Icons.inventory_2_outlined,
    endpoints: [
      ModuleEndpoint(label: 'Productos', path: 'products'),
      ModuleEndpoint(label: 'Categorías', path: 'categories'),
    ],
  ),
  PoslyModule(
    title: 'Precios y promociones',
    description: 'Revisa precios vigentes y promociones registradas.',
    icon: Icons.sell_outlined,
    endpoints: [
      ModuleEndpoint(label: 'Precios', path: 'price-rules'),
      ModuleEndpoint(label: 'Promociones', path: 'promotions'),
    ],
  ),
  PoslyModule(
    title: 'Inventario y movimientos',
    description: 'Consulta existencias y movimientos de inventario.',
    icon: Icons.warehouse_outlined,
    endpoints: [
      ModuleEndpoint(label: 'Inventario', path: 'inventory'),
      ModuleEndpoint(label: 'Movimientos', path: 'inventory/movements'),
    ],
  ),
  PoslyModule(
    title: 'Ventas',
    description: 'Consulta las ventas registradas en el punto de venta.',
    icon: Icons.point_of_sale_rounded,
    endpoints: [ModuleEndpoint(label: 'Ventas', path: 'sales')],
  ),
  PoslyModule(
    title: 'Métodos de pago',
    description: 'Consulta las formas de pago habilitadas para el comercio.',
    icon: Icons.payments_outlined,
    endpoints: [
      ModuleEndpoint(label: 'Métodos de pago', path: 'payment-methods'),
    ],
  ),
  PoslyModule(
    title: 'Devoluciones y cancelaciones',
    description: 'Consulta devoluciones y cancelaciones registradas.',
    icon: Icons.assignment_return_outlined,
    endpoints: [
      ModuleEndpoint(label: 'Devoluciones', path: 'returns'),
      ModuleEndpoint(label: 'Cancelaciones', path: 'cancellations'),
    ],
  ),
  PoslyModule(
    title: 'Caja y sesiones de efectivo',
    description: 'Consulta las sesiones y movimientos de caja.',
    icon: Icons.account_balance_wallet_outlined,
    endpoints: [
      ModuleEndpoint(label: 'Sesiones de caja', path: 'cash-sessions'),
      ModuleEndpoint(label: 'Movimientos', path: 'cash-movements'),
    ],
  ),
  PoslyModule(
    title: 'Clientes',
    description: 'Consulta la cartera de clientes del comercio.',
    icon: Icons.groups_outlined,
    endpoints: [ModuleEndpoint(label: 'Clientes', path: 'customers')],
  ),
  PoslyModule(
    title: 'Fiados y cuentas de crédito',
    description: 'Consulta cuentas de crédito y saldos registrados.',
    icon: Icons.credit_score_outlined,
    endpoints: [
      ModuleEndpoint(label: 'Cuentas de crédito', path: 'credit-accounts'),
      ModuleEndpoint(label: 'Fiados', path: 'credits'),
    ],
  ),
  PoslyModule(
    title: 'Abonos',
    description: 'Consulta los abonos aplicados a cuentas de crédito.',
    icon: Icons.receipt_long_outlined,
    endpoints: [ModuleEndpoint(label: 'Abonos', path: 'payments')],
  ),
  PoslyModule(
    title: 'Envases retornables',
    description: 'Consulta el control de envases retornables.',
    icon: Icons.recycling_outlined,
    endpoints: [
      ModuleEndpoint(label: 'Envases', path: 'returnable-containers'),
      ModuleEndpoint(label: 'Movimientos', path: 'container-movements'),
    ],
  ),
];
