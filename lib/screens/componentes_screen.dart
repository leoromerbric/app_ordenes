import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/orden_trabajo.dart';

class ComponentesScreen extends StatefulWidget {
  final OrdenTrabajo orden;
  final Operacion operacion;
  final List<ComponenteMaterial> componentes;

  const ComponentesScreen({
    super.key,
    required this.orden,
    required this.operacion,
    required this.componentes,
  });

  @override
  State<ComponentesScreen> createState() => _ComponentesScreenState();
}

class _ComponentesScreenState extends State<ComponentesScreen> {
  late List<ComponenteMaterial> _componentes;
  final _busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _componentes = List.from(widget.componentes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Componentes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _agregarComponente,
            icon: const Icon(Icons.add),
            tooltip: 'Agregar componente',
          ),
        ],
      ),
      body: Column(
        children: [
          // Información de encabezado
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Movimientos de Materiales',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Orden: ${widget.orden.id} - Operación: ${widget.operacion.codigo}'),
                  Text('Material: ${widget.orden.material}'),
                ],
              ),
            ),
          ),

          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _busquedaController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar material por código o descripción',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _escanearCodigoBarras,
                  icon: const Icon(Icons.qr_code_scanner),
                  tooltip: 'Escanear código de barras',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Lista de componentes
          Expanded(
            child: _componentes.isEmpty
                ? const Center(
                    child: Text('No hay componentes agregados'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _componentes.length,
                    itemBuilder: (context, index) {
                      final componente = _componentes[index];
                      return _ComponenteCard(
                        componente: componente,
                        onEdit: () => _editarComponente(index),
                        onDelete: () => _eliminarComponente(index),
                        onToggleNoConsumido: () => _toggleNoConsumido(index),
                        onCantidadChanged: (cantidad) => _actualizarCantidad(index, cantidad),
                      );
                    },
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
                    onPressed: _agregarComponente,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _guardarCambios,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar Cambios'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _actualizarCantidad(int index, double cantidad) {
    setState(() {
      _componentes[index] = ComponenteMaterial(
        id: _componentes[index].id,
        codigo: _componentes[index].codigo,
        descripcion: _componentes[index].descripcion,
        cantidadRequerida: _componentes[index].cantidadRequerida,
        cantidadConsumida: cantidad,
        unidadMedida: _componentes[index].unidadMedida,
        almacen: _componentes[index].almacen,
        lote: _componentes[index].lote,
        claseValoracion: _componentes[index].claseValoracion,
        tipoMovimiento: _componentes[index].tipoMovimiento,
        noConsumido: _componentes[index].noConsumido,
      );
    });
  }

  void _toggleNoConsumido(int index) {
    setState(() {
      _componentes[index] = ComponenteMaterial(
        id: _componentes[index].id,
        codigo: _componentes[index].codigo,
        descripcion: _componentes[index].descripcion,
        cantidadRequerida: _componentes[index].cantidadRequerida,
        cantidadConsumida: _componentes[index].cantidadConsumida,
        unidadMedida: _componentes[index].unidadMedida,
        almacen: _componentes[index].almacen,
        lote: _componentes[index].lote,
        claseValoracion: _componentes[index].claseValoracion,
        tipoMovimiento: _componentes[index].tipoMovimiento,
        noConsumido: !_componentes[index].noConsumido,
      );
    });
  }

  void _editarComponente(int index) {
    showDialog(
      context: context,
      builder: (context) => _ComponenteDialog(
        componente: _componentes[index],
        onSave: (componenteEditado) {
          setState(() => _componentes[index] = componenteEditado);
        },
      ),
    );
  }

  void _eliminarComponente(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Componente'),
        content: Text('¿Está seguro de eliminar ${_componentes[index].descripcion}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              setState(() => _componentes.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _agregarComponente() {
    showDialog(
      context: context,
      builder: (context) => _ComponenteDialog(
        onSave: (nuevoComponente) {
          setState(() => _componentes.add(nuevoComponente));
        },
      ),
    );
  }

  void _escanearCodigoBarras() {
    // Simulación de escaneo de código de barras
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escanear Código'),
        content: const Text('Función de escaneo de código de barras.\n\nEn una implementación real, aquí se abriría la cámara para escanear códigos de barras o QR.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _guardarCambios() {
    Navigator.pop(context, _componentes);
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }
}

class _ComponenteCard extends StatefulWidget {
  final ComponenteMaterial componente;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleNoConsumido;
  final Function(double) onCantidadChanged;

  const _ComponenteCard({
    required this.componente,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleNoConsumido,
    required this.onCantidadChanged,
  });

  @override
  State<_ComponenteCard> createState() => _ComponenteCardState();
}

class _ComponenteCardState extends State<_ComponenteCard> {
  late TextEditingController _cantidadController;

  @override
  void initState() {
    super.initState();
    _cantidadController = TextEditingController(
      text: widget.componente.cantidadConsumida > 0
          ? widget.componente.cantidadConsumida.toString()
          : widget.componente.cantidadRequerida.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.componente.descripcion,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Código: ${widget.componente.codigo}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(_getTipoMovimientoTexto(widget.componente.tipoMovimiento)),
                  backgroundColor: _getTipoMovimientoColor(context, widget.componente.tipoMovimiento),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Almacén: ${widget.componente.almacen}'),
                      if (widget.componente.lote != null)
                        Text('Lote: ${widget.componente.lote}'),
                      Text('Clase: ${widget.componente.claseValoracion}'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Requerido: ${widget.componente.cantidadRequerida} ${widget.componente.unidadMedida}'),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: TextFormField(
                          controller: _cantidadController,
                          decoration: InputDecoration(
                            labelText: 'Consumido',
                            suffixText: widget.componente.unidadMedida,
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                          onChanged: (value) {
                            final cantidad = double.tryParse(value) ?? 0.0;
                            widget.onCantidadChanged(cantidad);
                          },
                          enabled: !widget.componente.noConsumido,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: widget.componente.noConsumido,
                      onChanged: (value) => widget.onToggleNoConsumido(),
                    ),
                    const Text('No consumido'),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: widget.onEdit,
                      icon: const Icon(Icons.edit),
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      onPressed: widget.onDelete,
                      icon: const Icon(Icons.delete),
                      tooltip: 'Eliminar',
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTipoMovimientoTexto(TipoMovimiento tipo) {
    switch (tipo) {
      case TipoMovimiento.egreso:
        return 'Egreso';
      case TipoMovimiento.devolucion:
        return 'Devolución';
      case TipoMovimiento.recepcion:
        return 'Recepción';
    }
  }

  Color _getTipoMovimientoColor(BuildContext context, TipoMovimiento tipo) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (tipo) {
      case TipoMovimiento.egreso:
        return colorScheme.primaryContainer;
      case TipoMovimiento.devolucion:
        return colorScheme.secondaryContainer;
      case TipoMovimiento.recepcion:
        return colorScheme.tertiaryContainer;
    }
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }
}

class _ComponenteDialog extends StatefulWidget {
  final ComponenteMaterial? componente;
  final Function(ComponenteMaterial) onSave;

  const _ComponenteDialog({
    this.componente,
    required this.onSave,
  });

  @override
  State<_ComponenteDialog> createState() => _ComponenteDialogState();
}

class _ComponenteDialogState extends State<_ComponenteDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codigoController;
  late TextEditingController _descripcionController;
  late TextEditingController _cantidadRequeridaController;
  late TextEditingController _cantidadConsumidaController;
  late TextEditingController _almacenController;
  late TextEditingController _loteController;
  late TextEditingController _claseValoracionController;
  
  String _unidadMedida = 'UN';
  TipoMovimiento _tipoMovimiento = TipoMovimiento.egreso;
  bool _noConsumido = false;

  final List<String> _unidadesMedida = ['UN', 'KG', 'L', 'M³', 'M', 'G', 'T'];

  @override
  void initState() {
    super.initState();
    
    if (widget.componente != null) {
      _codigoController = TextEditingController(text: widget.componente!.codigo);
      _descripcionController = TextEditingController(text: widget.componente!.descripcion);
      _cantidadRequeridaController = TextEditingController(text: widget.componente!.cantidadRequerida.toString());
      _cantidadConsumidaController = TextEditingController(text: widget.componente!.cantidadConsumida.toString());
      _almacenController = TextEditingController(text: widget.componente!.almacen);
      _loteController = TextEditingController(text: widget.componente!.lote ?? '');
      _claseValoracionController = TextEditingController(text: widget.componente!.claseValoracion);
      _unidadMedida = widget.componente!.unidadMedida;
      _tipoMovimiento = widget.componente!.tipoMovimiento;
      _noConsumido = widget.componente!.noConsumido;
    } else {
      _codigoController = TextEditingController();
      _descripcionController = TextEditingController();
      _cantidadRequeridaController = TextEditingController(text: '0');
      _cantidadConsumidaController = TextEditingController(text: '0');
      _almacenController = TextEditingController();
      _loteController = TextEditingController();
      _claseValoracionController = TextEditingController(text: 'STD');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.componente == null ? 'Agregar Componente' : 'Editar Componente'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _codigoController,
                  decoration: const InputDecoration(
                    labelText: 'Código Material *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty == true ? 'Ingrese el código' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty == true ? 'Ingrese la descripción' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cantidadRequeridaController,
                        decoration: const InputDecoration(
                          labelText: 'Cantidad Requerida *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value?.isEmpty == true) return 'Ingrese la cantidad';
                          if (double.tryParse(value!) == null) return 'Valor inválido';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _unidadMedida,
                        decoration: const InputDecoration(
                          labelText: 'Unidad',
                          border: OutlineInputBorder(),
                        ),
                        items: _unidadesMedida.map((unidad) {
                          return DropdownMenuItem(value: unidad, child: Text(unidad));
                        }).toList(),
                        onChanged: (value) => setState(() => _unidadMedida = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cantidadConsumidaController,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad Consumida',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value?.isNotEmpty == true && double.tryParse(value!) == null) {
                      return 'Valor inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _almacenController,
                        decoration: const InputDecoration(
                          labelText: 'Almacén *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.isEmpty == true ? 'Ingrese el almacén' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _loteController,
                        decoration: const InputDecoration(
                          labelText: 'Lote',
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
                        controller: _claseValoracionController,
                        decoration: const InputDecoration(
                          labelText: 'Clase Valoración *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.isEmpty == true ? 'Ingrese la clase' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<TipoMovimiento>(
                        value: _tipoMovimiento,
                        decoration: const InputDecoration(
                          labelText: 'Tipo Movimiento',
                          border: OutlineInputBorder(),
                        ),
                        items: TipoMovimiento.values.map((tipo) {
                          return DropdownMenuItem(
                            value: tipo,
                            child: Text(_getTipoMovimientoTexto(tipo)),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _tipoMovimiento = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('No consumido'),
                  value: _noConsumido,
                  onChanged: (value) => setState(() => _noConsumido = value!),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardar,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    final componente = ComponenteMaterial(
      id: widget.componente?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      codigo: _codigoController.text,
      descripcion: _descripcionController.text,
      cantidadRequerida: double.parse(_cantidadRequeridaController.text),
      cantidadConsumida: double.tryParse(_cantidadConsumidaController.text) ?? 0.0,
      unidadMedida: _unidadMedida,
      almacen: _almacenController.text,
      lote: _loteController.text.isNotEmpty ? _loteController.text : null,
      claseValoracion: _claseValoracionController.text,
      tipoMovimiento: _tipoMovimiento,
      noConsumido: _noConsumido,
    );

    widget.onSave(componente);
    Navigator.pop(context);
  }

  String _getTipoMovimientoTexto(TipoMovimiento tipo) {
    switch (tipo) {
      case TipoMovimiento.egreso:
        return 'Egreso';
      case TipoMovimiento.devolucion:
        return 'Devolución';
      case TipoMovimiento.recepcion:
        return 'Recepción';
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _descripcionController.dispose();
    _cantidadRequeridaController.dispose();
    _cantidadConsumidaController.dispose();
    _almacenController.dispose();
    _loteController.dispose();
    _claseValoracionController.dispose();
    super.dispose();
  }
}