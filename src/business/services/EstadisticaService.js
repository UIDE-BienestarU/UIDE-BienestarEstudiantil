import Solicitud from '../../data/models/Solicitud.js';
import SubtipoSolicitud from '../../data/models/SubtipoSolicitud.js';
import Usuario from '../../data/models/Usuario.js';

class EstadisticaService {
  static async getEstadisticas() {
    const total = await Solicitud.count();

    const porEstado = await Solicitud.findAll({
      attributes: ['estado_actual', [Solicitud.sequelize.fn('COUNT', 'estado_actual'), 'count']],
      group: ['estado_actual']
    });

    const porSubtipoRaw = await Solicitud.findAll({
      attributes: [
        [Solicitud.sequelize.col('subtipo.nombre_sub'), 'nombre_sub'],
        [Solicitud.sequelize.fn('COUNT', 'subtipo_id'), 'count']
      ],
      include: [{ model: SubtipoSolicitud, attributes: ['nombre_sub'] }],
      group: ['subtipo.nombre_sub', 'subtipo_id']
    });

    const porSubtipo = porSubtipoRaw.reduce((acc, item) => {
      const nombre = item.get('nombre_sub') || 'Sin subtipo';
      acc[nombre] = (acc[nombre] || 0) + parseInt(item.get('count'));
      return acc;
    }, {});

    return {
      total,
      porEstado: Object.fromEntries(porEstado.map(s => [s.estado_actual, parseInt(s.get('count'))])),
      porSubtipo
    };
  }
}

export default EstadisticaService;