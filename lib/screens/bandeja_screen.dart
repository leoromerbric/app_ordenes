import 'package:flutter/material.dart';
import '../models/orden_trabajo.dart';
import '../services/orden_service.dart';
import 'operaciones_screen.dart';

class BandejaScreen extends StatefulWidget {
  const BandejaScreen({super.key});

  @override
  State<BandejaScreen> createState() => _BandejaScreenState();
}

class _BandejaScreenState extends State<BandejaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pedidoController = TextEditingController();
  final _posicionController = TextEditingController();
  final _centroController = TextEditingController();
  final _puestoTrabajoController = TextEditingController();
  
  EstadoOrden? _estadoSeleccionado;
  DateTimeRange? _rangoFechas;
  List<OrdenTrabajo> _ordenes = [];
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _cargarOrdenes();
  }

  Future<void> _cargarOrdenes() async {
    setState(() => _cargando = true);
    
    try {
      final ordenes = await OrdenService.obtenerOrdenes(
        pedidoCliente: _pedidoController.text.isEmpty ? null : _pedidoController.text,
        posicion: _posicionController.text.isEmpty ? null : _posicionController.text,
        centro: _centroController.text.isEmpty ? null : _centroController.text,
        puestoTrabajo: _puestoTrabajoController.text.isEmpty ? null : _puestoTrabajoController.text,
        estado: _estadoSeleccionado,
        rangoFechas: _rangoFechas,
      );
      
      setState(() => _ordenes = ordenes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar órdenes: $e')),
        );
      }
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Órdenes de Trabajo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Formulario de filtros
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Filtros de Búsqueda',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _pedidoController,
                            decoration: const InputDecoration(
                              labelText: 'Pedido Cliente',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _posicionController,
                            decoration: const InputDecoration(
                              labelText: 'Posición',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _centroController,
                            decoration: const InputDecoration(
                              labelText: 'Centro/Planta',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _puestoTrabajoController,
                            decoration: const InputDecoration(
                              labelText: 'Puesto de Trabajo',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<EstadoOrden>(
                            value: _estadoSeleccionado,
                            decoration: const InputDecoration(
                              labelText: 'Estado',
                              border: OutlineInputBorder(),
                            ),
                            items: EstadoOrden.values.map((estado) {
                              return DropdownMenuItem(
                                value: estado,
                                child: Text(_getEstadoTexto(estado)),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _estadoSeleccionado = value),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _seleccionarRangoFechas,
                            icon: const Icon(Icons.date_range),
                            label: Text(_rangoFechas == null 
                              ? 'Rango de Fechas' 
                              : '${_formatearFecha(_rangoFechas!.start)} - ${_formatearFecha(_rangoFechas!.end)}'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: _limpiarFiltros,
                          child: const Text('Limpiar'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: _cargarOrdenes,
                          child: const Text('Buscar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Lista de órdenes
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _ordenes.isEmpty
                    ? const Center(
                        child: Text('No se encontraron órdenes con los filtros aplicados'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _ordenes.length,
                        itemBuilder: (context, index) {
                          final orden = _ordenes[index];
                          return _OrdenCard(
                            orden: orden,
                            onTap: () => _abrirOperaciones(orden),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _seleccionarRangoFechas() async {
    final rangoSeleccionado = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _rangoFechas,
    );
    
    if (rangoSeleccionado != null) {
      setState(() => _rangoFechas = rangoSeleccionado);
    }
  }

  void _limpiarFiltros() {
    _pedidoController.clear();
    _posicionController.clear();
    _centroController.clear();
    _puestoTrabajoController.clear();
    setState(() {
      _estadoSeleccionado = null;
      _rangoFechas = null;
    });
    _cargarOrdenes();
  }

  void _abrirOperaciones(OrdenTrabajo orden) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OperacionesScreen(orden: orden),
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

  @override
  void dispose() {
    _pedidoController.dispose();
    _posicionController.dispose();
    _centroController.dispose();
    _puestoTrabajoController.dispose();
    super.dispose();
  }
}

class _OrdenCard extends StatelessWidget {
  final OrdenTrabajo orden;
  final VoidCallback onTap;

  const _OrdenCard({
    required this.orden,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Orden ${orden.id}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Chip(
                    label: Text(_getEstadoTexto(orden.estado)),
                    backgroundColor: _getEstadoColor(context, orden.estado),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Pedido: ${orden.pedidoCliente} - Pos: ${orden.posicion}'),
              Text('Material: ${orden.material}'),
              Text('Centro: ${orden.centro} - ${orden.planta}'),
              Text('Puesto: ${orden.puestoTrabajo}'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cantidad: ${orden.cantidadPlanificada} ${orden.unidadMedida}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${orden.operaciones.length} operaciones',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getEstadoTexto(EstadoOrden estado) {
    switch (estado) {
      case EstadoOrden.liberada:
        return 'Liberada';
      case EstadoOrden.parcialmenteConfirmada:
        return 'Parcial';
      case EstadoOrden.completada:
        return 'Completada';
      case EstadoOrden.cerrada:
        return 'Cerrada';
    }
  }

  Color _getEstadoColor(BuildContext context, EstadoOrden estado) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (estado) {
      case EstadoOrden.liberada:
        return colorScheme.primaryContainer;
      case EstadoOrden.parcialmenteConfirmada:
        return colorScheme.secondaryContainer;
      case EstadoOrden.completada:
        return colorScheme.tertiaryContainer;
      case EstadoOrden.cerrada:
        return colorScheme.surfaceContainerHighest;
    }
  }
}