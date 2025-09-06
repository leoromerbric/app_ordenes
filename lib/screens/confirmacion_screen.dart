import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/orden_trabajo.dart';
import '../services/orden_service.dart';
import 'componentes_screen.dart';

class ConfirmacionScreen extends StatefulWidget {
  final OrdenTrabajo orden;
  final Operacion operacion;

  const ConfirmacionScreen({
    super.key,
    required this.orden,
    required this.operacion,
  });

  @override
  State<ConfirmacionScreen> createState() => _ConfirmacionScreenState();
}

class _ConfirmacionScreenState extends State<ConfirmacionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cantidadBuenaController = TextEditingController();
  final _cantidadRechazoController = TextEditingController();
  final _cantidadReprocesoController = TextEditingController();
  
  bool _compensarReservas = false;
  List<Actividad> _actividades = [];
  List<ComponenteMaterial> _componentes = [];
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _inicializarDatos();
  }

  void _inicializarDatos() {
    // Inicializar actividades con valores por defecto
    _actividades = widget.operacion.actividades.map((actividad) => Actividad(
      id: actividad.id,
      codigo: actividad.codigo,
      descripcion: actividad.descripcion,
      tipo: actividad.tipo,
      cantidadPlanificada: actividad.cantidadPlanificada,
      cantidadConfirmada: actividad.cantidadConfirmada,
      unidadMedida: actividad.unidadMedida,
      tarifa: actividad.tarifa,
    )).toList();

    // Inicializar componentes con valores sugeridos
    _componentes = widget.operacion.componentes.map((componente) => ComponenteMaterial(
      id: componente.id,
      codigo: componente.codigo,
      descripcion: componente.descripcion,
      cantidadRequerida: componente.cantidadRequerida,
      cantidadConsumida: componente.cantidadConsumida,
      unidadMedida: componente.unidadMedida,
      almacen: componente.almacen,
      lote: componente.lote,
      claseValoracion: componente.claseValoracion,
      tipoMovimiento: componente.tipoMovimiento,
      noConsumido: componente.noConsumido,
    )).toList();

    // Valores por defecto para cantidades
    _cantidadBuenaController.text = widget.orden.cantidadPlanificada.toString();
    _cantidadRechazoController.text = '0';
    _cantidadReprocesoController.text = '0';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmación'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _abrirComponentes,
            icon: const Icon(Icons.inventory_2),
            tooltip: 'Componentes',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Encabezado
                    _EncabezadoCard(
                      orden: widget.orden,
                      operacion: widget.operacion,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Cantidades
                    _CantidadesCard(
                      cantidadBuenaController: _cantidadBuenaController,
                      cantidadRechazoController: _cantidadRechazoController,
                      cantidadReprocesoController: _cantidadReprocesoController,
                      unidadMedida: widget.orden.unidadMedida,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Toggle compensar reservas
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SwitchListTile(
                          title: const Text('Compensar reservas abiertas'),
                          subtitle: const Text('Ajustar automáticamente las reservas de material'),
                          value: _compensarReservas,
                          onChanged: (value) => setState(() => _compensarReservas = value),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Actividades
                    _ActividadesCard(
                      actividades: _actividades,
                      onActividadChanged: _actualizarActividad,
                    ),
                  ],
                ),
              ),
            ),
            
            // Botones de acción
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _abrirComponentes,
                      icon: const Icon(Icons.inventory_2),
                      label: const Text('Componentes'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _guardando ? null : _confirmarOperacion,
                      icon: _guardando 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle),
                      label: Text(_guardando ? 'Confirmando...' : 'Revisar y Confirmar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _actualizarActividad(int index, double cantidadConfirmada) {
    setState(() {
      _actividades[index] = Actividad(
        id: _actividades[index].id,
        codigo: _actividades[index].codigo,
        descripcion: _actividades[index].descripcion,
        tipo: _actividades[index].tipo,
        cantidadPlanificada: _actividades[index].cantidadPlanificada,
        cantidadConfirmada: cantidadConfirmada,
        unidadMedida: _actividades[index].unidadMedida,
        tarifa: _actividades[index].tarifa,
      );
    });
  }

  void _abrirComponentes() async {
    final componentesActualizados = await Navigator.push<List<ComponenteMaterial>>(
      context,
      MaterialPageRoute(
        builder: (context) => ComponentesScreen(
          orden: widget.orden,
          operacion: widget.operacion,
          componentes: _componentes,
        ),
      ),
    );

    if (componentesActualizados != null) {
      setState(() => _componentes = componentesActualizados);
    }
  }

  Future<void> _confirmarOperacion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      final confirmacion = ConfirmacionOperacion(
        operacionId: widget.operacion.id,
        cantidadBuena: double.parse(_cantidadBuenaController.text),
        cantidadRechazo: double.parse(_cantidadRechazoController.text),
        cantidadReproceso: double.parse(_cantidadReprocesoController.text),
        compensarReservasAbiertas: _compensarReservas,
        actividades: _actividades,
        componentes: _componentes,
        fechaConfirmacion: DateTime.now(),
      );

      final exito = await OrdenService.confirmarOperacion(confirmacion);

      if (exito && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Operación confirmada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al confirmar operación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  void dispose() {
    _cantidadBuenaController.dispose();
    _cantidadRechazoController.dispose();
    _cantidadReprocesoController.dispose();
    super.dispose();
  }
}

class _EncabezadoCard extends StatelessWidget {
  final OrdenTrabajo orden;
  final Operacion operacion;

  const _EncabezadoCard({
    required this.orden,
    required this.operacion,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información de Confirmación',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'Orden:', value: orden.id),
            _InfoRow(label: 'Operación:', value: '${operacion.codigo} - ${operacion.descripcion}'),
            _InfoRow(label: 'Material:', value: orden.material),
            _InfoRow(label: 'Centro:', value: orden.centro),
            _InfoRow(label: 'Puesto:', value: operacion.puestoTrabajo),
          ],
        ),
      ),
    );
  }
}

class _CantidadesCard extends StatelessWidget {
  final TextEditingController cantidadBuenaController;
  final TextEditingController cantidadRechazoController;
  final TextEditingController cantidadReprocesoController;
  final String unidadMedida;

  const _CantidadesCard({
    required this.cantidadBuenaController,
    required this.cantidadRechazoController,
    required this.cantidadReprocesoController,
    required this.unidadMedida,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cantidades',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: cantidadBuenaController,
                    decoration: InputDecoration(
                      labelText: 'Cantidad Buena',
                      suffixText: unidadMedida,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese la cantidad buena';
                      }
                      final cantidad = double.tryParse(value);
                      if (cantidad == null || cantidad < 0) {
                        return 'Ingrese un valor válido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: cantidadRechazoController,
                    decoration: InputDecoration(
                      labelText: 'Rechazo',
                      suffixText: unidadMedida,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final cantidad = double.tryParse(value);
                        if (cantidad == null || cantidad < 0) {
                          return 'Valor inválido';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: cantidadReprocesoController,
              decoration: InputDecoration(
                labelText: 'Reproceso',
                suffixText: unidadMedida,
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final cantidad = double.tryParse(value);
                  if (cantidad == null || cantidad < 0) {
                    return 'Ingrese un valor válido';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActividadesCard extends StatelessWidget {
  final List<Actividad> actividades;
  final Function(int, double) onActividadChanged;

  const _ActividadesCard({
    required this.actividades,
    required this.onActividadChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (actividades.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Actividades',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Total: \$${_calcularTotal().toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...actividades.asMap().entries.map((entry) {
              final index = entry.key;
              final actividad = entry.value;
              return _ActividadRow(
                actividad: actividad,
                onChanged: (cantidad) => onActividadChanged(index, cantidad),
              );
            }),
          ],
        ),
      ),
    );
  }

  double _calcularTotal() {
    return actividades.fold(0.0, (total, actividad) => 
      total + (actividad.cantidadConfirmada * actividad.tarifa));
  }
}

class _ActividadRow extends StatefulWidget {
  final Actividad actividad;
  final Function(double) onChanged;

  const _ActividadRow({
    required this.actividad,
    required this.onChanged,
  });

  @override
  State<_ActividadRow> createState() => _ActividadRowState();
}

class _ActividadRowState extends State<_ActividadRow> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.actividad.cantidadConfirmada > 0 
        ? widget.actividad.cantidadConfirmada.toString()
        : widget.actividad.cantidadPlanificada.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.actividad.descripcion} (${widget.actividad.codigo})',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Cantidad',
                    suffixText: widget.actividad.unidadMedida,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  onChanged: (value) {
                    final cantidad = double.tryParse(value) ?? 0.0;
                    widget.onChanged(cantidad);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tarifa:\n\$${widget.actividad.tarifa.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'Subtotal:\n\$${(widget.actividad.cantidadConfirmada * widget.actividad.tarifa).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}