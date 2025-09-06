import 'package:flutter/material.dart';
import '../models/orden_trabajo.dart';
import 'confirmacion_screen.dart';

class OperacionesScreen extends StatelessWidget {
  final OrdenTrabajo orden;

  const OperacionesScreen({
    super.key,
    required this.orden,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orden ${orden.id}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Información de la orden
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información de la Orden',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Pedido Cliente:',
                    value: '${orden.pedidoCliente} - Pos: ${orden.posicion}',
                  ),
                  _InfoRow(
                    label: 'Material:',
                    value: orden.material,
                  ),
                  _InfoRow(
                    label: 'Cantidad:',
                    value: '${orden.cantidadPlanificada} ${orden.unidadMedida}',
                  ),
                  _InfoRow(
                    label: 'Centro/Planta:',
                    value: '${orden.centro} - ${orden.planta}',
                  ),
                  _InfoRow(
                    label: 'Estado:',
                    value: _getEstadoTexto(orden.estado),
                  ),
                  _InfoRow(
                    label: 'Fechas:',
                    value: '${_formatearFecha(orden.fechaInicio)} - ${_formatearFecha(orden.fechaFin)}',
                  ),
                ],
              ),
            ),
          ),
          
          // Lista de operaciones
          Expanded(
            child: orden.operaciones.isEmpty
                ? const Center(
                    child: Text('No hay operaciones para esta orden'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: orden.operaciones.length,
                    itemBuilder: (context, index) {
                      final operacion = orden.operaciones[index];
                      return _OperacionCard(
                        operacion: operacion,
                        orden: orden,
                        onConfirmar: () => _abrirConfirmacion(context, orden, operacion),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _abrirConfirmacion(BuildContext context, OrdenTrabajo orden, Operacion operacion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmacionScreen(
          orden: orden,
          operacion: operacion,
        ),
      ),
    );
  }

  String _getEstadoTexto(EstadoOrden estado) {
    switch (estado) {
      case EstadoOrden.liberada:
        return 'Liberada';
      case EstadoOrden.parcialmenteConfirmada:
        return 'Parcialmente Confirmada';
      case EstadoOrden.completada:
        return 'Completada';
      case EstadoOrden.cerrada:
        return 'Cerrada';
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _OperacionCard extends StatelessWidget {
  final Operacion operacion;
  final OrdenTrabajo orden;
  final VoidCallback onConfirmar;

  const _OperacionCard({
    required this.operacion,
    required this.orden,
    required this.onConfirmar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Operación ${operacion.codigo}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(_getEstadoOperacionTexto(operacion.estado)),
                  backgroundColor: _getEstadoOperacionColor(context, operacion.estado),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              operacion.descripcion,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text('Puesto de Trabajo: ${operacion.puestoTrabajo}'),
            
            if (operacion.fechaInicio != null || operacion.fechaFin != null) ...[
              const SizedBox(height: 8),
              if (operacion.fechaInicio != null)
                Text('Inicio: ${_formatearFechaHora(operacion.fechaInicio!)}'),
              if (operacion.fechaFin != null)
                Text('Fin: ${_formatearFechaHora(operacion.fechaFin!)}'),
            ],
            
            const SizedBox(height: 12),
            
            // Actividades
            if (operacion.actividades.isNotEmpty) ...[
              Text(
                'Actividades/Tarifas:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...operacion.actividades.map((actividad) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${actividad.descripcion} (${actividad.codigo})',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Text(
                      '${actividad.cantidadPlanificada} ${actividad.unidadMedida} @ \$${actividad.tarifa.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 8),
            ],
            
            // Componentes
            if (operacion.componentes.isNotEmpty) ...[
              Text(
                'Componentes requeridos:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...operacion.componentes.take(3).map((componente) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${componente.descripcion} (${componente.codigo})',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Text(
                      '${componente.cantidadRequerida} ${componente.unidadMedida}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )),
              if (operacion.componentes.length > 3)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '... y ${operacion.componentes.length - 3} más',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
            ],
            
            // Botón de confirmación
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _puedeConfirmar() ? onConfirmar : null,
                icon: const Icon(Icons.check_circle),
                label: const Text('Confirmar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _puedeConfirmar() {
    return operacion.estado == EstadoOperacion.liberada || 
           operacion.estado == EstadoOperacion.enProceso ||
           operacion.estado == EstadoOperacion.parcialmenteConfirmada;
  }

  String _getEstadoOperacionTexto(EstadoOperacion estado) {
    switch (estado) {
      case EstadoOperacion.planificada:
        return 'Planificada';
      case EstadoOperacion.liberada:
        return 'Liberada';
      case EstadoOperacion.enProceso:
        return 'En Proceso';
      case EstadoOperacion.parcialmenteConfirmada:
        return 'Parcial';
      case EstadoOperacion.completada:
        return 'Completada';
    }
  }

  Color _getEstadoOperacionColor(BuildContext context, EstadoOperacion estado) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (estado) {
      case EstadoOperacion.planificada:
        return colorScheme.surfaceContainerHighest;
      case EstadoOperacion.liberada:
        return colorScheme.primaryContainer;
      case EstadoOperacion.enProceso:
        return colorScheme.secondaryContainer;
      case EstadoOperacion.parcialmenteConfirmada:
        return colorScheme.tertiaryContainer;
      case EstadoOperacion.completada:
        return colorScheme.surfaceContainerHigh;
    }
  }

  String _formatearFechaHora(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}