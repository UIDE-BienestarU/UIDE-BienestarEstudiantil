import Solicitud from '../../data/models/Solicitud.js';
import SubtipoSolicitud from '../../data/models/SubtipoSolicitud.js';

class EstadisticaService {
  static async getEstadisticas() {
    try {
      // Total de solicitudes
      const total = await Solicitud.count();
      console.log('Total de solicitudes:', total);

      // Solicitudes por estado
      const porEstado = await Solicitud.findAll({
        attributes: ['estado_actual', [Solicitud.sequelize.fn('COUNT', Solicitud.sequelize.col('estado_actual')), 'count']],
        group: ['estado_actual'],
      });
      console.log('Por estado:', porEstado);

      const porSubtipoRaw = await Solicitud.findAll({
        attributes: [
          [Solicitud.sequelize.col('SubtipoSolicitud.nombre_sub'), 'nombre_sub'],
          [Solicitud.sequelize.fn('COUNT', Solicitud.sequelize.col('subtipo_id')), 'count'],
        ],
        include: [
          {
            model: SubtipoSolicitud,
            attributes: ['nombre_sub'],
            required: true, 
          },
        ],
        group: ['SubtipoSolicitud.nombre_sub', 'subtipo_id'],
      });
      console.log('Por subtipo raw:', porSubtipoRaw);

      const porSubtipo = porSubtipoRaw.reduce((acc, item) => {
        const nombreSub = item.get('nombre_sub') || 'Sin subtipo';
        acc[nombreSub] = parseInt(item.get('count'));
        return acc;
      }, {});

      console.log('Por subtipo procesado:', porSubtipo);

      return {
        total,
        porEstado: porEstado.reduce((acc, item) => {
          acc[item.estado_actual] = parseInt(item.get('count'));
          return acc;
        }, {}),
        porSubtipo,
      };
    } catch (error) {
      console.error('Error en getEstadisticas:', error);
      throw new Error('Error al obtener estadísticas: ' + error.message);
    }
  }
}

export default EstadisticaService;