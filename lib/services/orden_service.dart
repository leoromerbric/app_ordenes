import '../models/orden_trabajo.dart';

class OrdenService {
  static Future<List<OrdenTrabajo>> obtenerOrdenes({
    String? pedidoCliente,
    String? posicion,
    String? centro,
    String? puestoTrabajo,
    EstadoOrden? estado,
    DateTimeRange? rangoFechas,
  }) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Datos de ejemplo
    final ordenesEjemplo = [
      OrdenTrabajo(
        id: 'ORD-001',
        pedidoCliente: 'PED-2024-001',
        posicion: '10',
        centro: 'P100',
        planta: 'Planta Norte',
        puestoTrabajo: 'PT-001',
        fechaInicio: DateTime.now().subtract(const Duration(days: 2)),
        fechaFin: DateTime.now().add(const Duration(days: 5)),
        estado: EstadoOrden.liberada,
        material: 'MAT-ABC123',
        cantidadPlanificada: 100.0,
        unidadMedida: 'UN',
        operaciones: [
          Operacion(
            id: 'OP-001',
            codigo: '0010',
            descripcion: 'Preparación de material',
            puestoTrabajo: 'PT-001',
            estado: EstadoOperacion.liberada,
            actividades: [
              Actividad(
                id: 'ACT-001',
                codigo: 'MOD',
                descripcion: 'Mano de obra directa',
                tipo: TipoActividad.manoObraDirecta,
                cantidadPlanificada: 2.0,
                unidadMedida: 'H',
                tarifa: 25.50,
              ),
              Actividad(
                id: 'ACT-002',
                codigo: 'IND',
                descripcion: 'Indirectos',
                tipo: TipoActividad.indirectos,
                cantidadPlanificada: 0.5,
                unidadMedida: 'H',
                tarifa: 15.00,
              ),
            ],
            componentes: [
              ComponenteMaterial(
                id: 'COMP-001',
                codigo: 'MAT-001',
                descripcion: 'Materia prima A',
                cantidadRequerida: 50.0,
                unidadMedida: 'KG',
                almacen: 'ALM-001',
                lote: 'LOTE-001',
                claseValoracion: 'FIFO',
              ),
              ComponenteMaterial(
                id: 'COMP-002',
                codigo: 'MAT-002',
                descripcion: 'Componente B',
                cantidadRequerida: 25.0,
                unidadMedida: 'UN',
                almacen: 'ALM-002',
                claseValoracion: 'STD',
              ),
            ],
          ),
          Operacion(
            id: 'OP-002',
            codigo: '0020',
            descripcion: 'Proceso de fabricación',
            puestoTrabajo: 'PT-002',
            estado: EstadoOperacion.planificada,
            actividades: [
              Actividad(
                id: 'ACT-003',
                codigo: 'MOD',
                descripcion: 'Mano de obra directa',
                tipo: TipoActividad.manoObraDirecta,
                cantidadPlanificada: 4.0,
                unidadMedida: 'H',
                tarifa: 28.00,
              ),
              Actividad(
                id: 'ACT-004',
                codigo: 'ENE',
                descripcion: 'Energía',
                tipo: TipoActividad.energia,
                cantidadPlanificada: 10.0,
                unidadMedida: 'KWH',
                tarifa: 0.15,
              ),
            ],
            componentes: [],
          ),
        ],
      ),
      OrdenTrabajo(
        id: 'ORD-002',
        pedidoCliente: 'PED-2024-002',
        posicion: '20',
        centro: 'P100',
        planta: 'Planta Norte',
        puestoTrabajo: 'PT-003',
        fechaInicio: DateTime.now().subtract(const Duration(days: 1)),
        fechaFin: DateTime.now().add(const Duration(days: 3)),
        estado: EstadoOrden.parcialmenteConfirmada,
        material: 'MAT-XYZ789',
        cantidadPlanificada: 200.0,
        unidadMedida: 'M³',
        operaciones: [
          Operacion(
            id: 'OP-003',
            codigo: '0010',
            descripcion: 'Mezclado',
            puestoTrabajo: 'PT-003',
            estado: EstadoOperacion.completada,
            actividades: [
              Actividad(
                id: 'ACT-005',
                codigo: 'MOD',
                descripcion: 'Mano de obra directa',
                tipo: TipoActividad.manoObraDirecta,
                cantidadPlanificada: 1.5,
                cantidadConfirmada: 1.5,
                unidadMedida: 'H',
                tarifa: 25.50,
              ),
            ],
            componentes: [
              ComponenteMaterial(
                id: 'COMP-003',
                codigo: 'MAT-003',
                descripcion: 'Componente líquido',
                cantidadRequerida: 150.0,
                cantidadConsumida: 150.0,
                unidadMedida: 'L',
                almacen: 'ALM-003',
                lote: 'LOTE-002',
                claseValoracion: 'FIFO',
              ),
            ],
          ),
        ],
      ),
      OrdenTrabajo(
        id: 'ORD-003',
        pedidoCliente: 'PED-2024-003',
        posicion: '10',
        centro: 'P200',
        planta: 'Planta Sur',
        puestoTrabajo: 'PT-004',
        fechaInicio: DateTime.now(),
        fechaFin: DateTime.now().add(const Duration(days: 7)),
        estado: EstadoOrden.liberada,
        material: 'MAT-DEF456',
        cantidadPlanificada: 50.0,
        unidadMedida: 'KG',
        operaciones: [
          Operacion(
            id: 'OP-004',
            codigo: '0010',
            descripcion: 'Pesado y dosificación',
            puestoTrabajo: 'PT-004',
            estado: EstadoOperacion.liberada,
            actividades: [
              Actividad(
                id: 'ACT-006',
                codigo: 'MOD',
                descripcion: 'Mano de obra directa',
                tipo: TipoActividad.manoObraDirecta,
                cantidadPlanificada: 1.0,
                unidadMedida: 'H',
                tarifa: 24.00,
              ),
              Actividad(
                id: 'ACT-007',
                codigo: 'DEP',
                descripcion: 'Depreciación',
                tipo: TipoActividad.depreciacion,
                cantidadPlanificada: 1.0,
                unidadMedida: 'H',
                tarifa: 50.00,
              ),
            ],
            componentes: [
              ComponenteMaterial(
                id: 'COMP-004',
                codigo: 'MAT-004',
                descripcion: 'Polvo base',
                cantidadRequerida: 40.0,
                unidadMedida: 'KG',
                almacen: 'ALM-001',
                claseValoracion: 'STD',
              ),
              ComponenteMaterial(
                id: 'COMP-005',
                codigo: 'MAT-005',
                descripcion: 'Aditivo especial',
                cantidadRequerida: 10.0,
                unidadMedida: 'KG',
                almacen: 'ALM-004',
                lote: 'LOTE-003',
                claseValoracion: 'FIFO',
              ),
            ],
          ),
        ],
      ),
    ];

    // Aplicar filtros
    var ordenesFiltradas = ordenesEjemplo.where((orden) {
      bool cumpleFiltros = true;

      if (pedidoCliente != null && pedidoCliente.isNotEmpty) {
        cumpleFiltros &= orden.pedidoCliente.toLowerCase().contains(pedidoCliente.toLowerCase());
      }

      if (posicion != null && posicion.isNotEmpty) {
        cumpleFiltros &= orden.posicion.contains(posicion);
      }

      if (centro != null && centro.isNotEmpty) {
        cumpleFiltros &= orden.centro.toLowerCase().contains(centro.toLowerCase()) ||
                        orden.planta.toLowerCase().contains(centro.toLowerCase());
      }

      if (puestoTrabajo != null && puestoTrabajo.isNotEmpty) {
        cumpleFiltros &= orden.puestoTrabajo.toLowerCase().contains(puestoTrabajo.toLowerCase());
      }

      if (estado != null) {
        cumpleFiltros &= orden.estado == estado;
      }

      if (rangoFechas != null) {
        cumpleFiltros &= orden.fechaInicio.isAfter(rangoFechas.start.subtract(const Duration(days: 1))) &&
                        orden.fechaInicio.isBefore(rangoFechas.end.add(const Duration(days: 1)));
      }

      return cumpleFiltros;
    }).toList();

    return ordenesFiltradas;
  }

  static Future<List<Operacion>> obtenerOperacionesDelDia({
    String? puestoTrabajo,
    String? centro,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final ordenes = await obtenerOrdenes();
    final operacionesDelDia = <Operacion>[];
    
    for (final orden in ordenes) {
      for (final operacion in orden.operaciones) {
        if (operacion.estado == EstadoOperacion.liberada || 
            operacion.estado == EstadoOperacion.enProceso) {
          operacionesDelDia.add(operacion);
        }
      }
    }
    
    return operacionesDelDia;
  }

  static Future<bool> confirmarOperacion(ConfirmacionOperacion confirmacion) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Simular validaciones y confirmación
    if (confirmacion.cantidadTotal <= 0) {
      throw Exception('La cantidad total debe ser mayor a cero');
    }
    
    // Simular éxito en la confirmación
    return true;
  }
}