class OrdenTrabajo {
  final String id;
  final String pedidoCliente;
  final String posicion;
  final String centro;
  final String planta;
  final String puestoTrabajo;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final EstadoOrden estado;
  final String material;
  final double cantidadPlanificada;
  final String unidadMedida;
  final List<Operacion> operaciones;

  const OrdenTrabajo({
    required this.id,
    required this.pedidoCliente,
    required this.posicion,
    required this.centro,
    required this.planta,
    required this.puestoTrabajo,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    required this.material,
    required this.cantidadPlanificada,
    required this.unidadMedida,
    required this.operaciones,
  });
}

enum EstadoOrden {
  liberada,
  parcialmenteConfirmada,
  completada,
  cerrada,
}

class Operacion {
  final String id;
  final String codigo;
  final String descripcion;
  final String puestoTrabajo;
  final EstadoOperacion estado;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final List<Actividad> actividades;
  final List<ComponenteMaterial> componentes;

  const Operacion({
    required this.id,
    required this.codigo,
    required this.descripcion,
    required this.puestoTrabajo,
    required this.estado,
    this.fechaInicio,
    this.fechaFin,
    required this.actividades,
    required this.componentes,
  });
}

enum EstadoOperacion {
  planificada,
  liberada,
  enProceso,
  parcialmenteConfirmada,
  completada,
}

class Actividad {
  final String id;
  final String codigo;
  final String descripcion;
  final TipoActividad tipo;
  final double cantidadPlanificada;
  final double cantidadConfirmada;
  final String unidadMedida;
  final double tarifa;

  const Actividad({
    required this.id,
    required this.codigo,
    required this.descripcion,
    required this.tipo,
    required this.cantidadPlanificada,
    this.cantidadConfirmada = 0.0,
    required this.unidadMedida,
    required this.tarifa,
  });
}

enum TipoActividad {
  manoObraDirecta,
  indirectos,
  energia,
  depreciacion,
}

class ComponenteMaterial {
  final String id;
  final String codigo;
  final String descripcion;
  final double cantidadRequerida;
  final double cantidadConsumida;
  final String unidadMedida;
  final String almacen;
  final String? lote;
  final String claseValoracion;
  final TipoMovimiento tipoMovimiento;
  final bool noConsumido;

  const ComponenteMaterial({
    required this.id,
    required this.codigo,
    required this.descripcion,
    required this.cantidadRequerida,
    this.cantidadConsumida = 0.0,
    required this.unidadMedida,
    required this.almacen,
    this.lote,
    required this.claseValoracion,
    this.tipoMovimiento = TipoMovimiento.egreso,
    this.noConsumido = false,
  });
}

enum TipoMovimiento {
  egreso,
  devolucion,
  recepcion,
}

class ConfirmacionOperacion {
  final String operacionId;
  final double cantidadBuena;
  final double cantidadRechazo;
  final double cantidadReproceso;
  final bool compensarReservasAbiertas;
  final List<Actividad> actividades;
  final List<ComponenteMaterial> componentes;
  final DateTime fechaConfirmacion;

  const ConfirmacionOperacion({
    required this.operacionId,
    required this.cantidadBuena,
    this.cantidadRechazo = 0.0,
    this.cantidadReproceso = 0.0,
    this.compensarReservasAbiertas = false,
    required this.actividades,
    required this.componentes,
    required this.fechaConfirmacion,
  });

  double get cantidadTotal => cantidadBuena + cantidadRechazo + cantidadReproceso;
}