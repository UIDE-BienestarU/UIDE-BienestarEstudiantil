import Solicitud from '../../data/models/Solicitud.js';
import SubtipoSolicitud from '../../data/models/SubtipoSolicitud.js';
import Usuario from '../../data/models/Usuario.js';

class EstadisticaService {
  static async getEstadisticas() {
    const total = await Solicitud.count();

    const porEstado = await Solicitud.findAll({
      attributes: ['estado_actual', [Solicitud.sequelize.fn('COUNT', Solicitud.sequelize.col('estado_actual')), 'count']],
      group: ['estado_actual'],
      raw: true, // para obtener resultados planos
    });

    // Consulta de subtipos con alias correcto
    const porSubtipoRaw = await Solicitud.findAll({
      attributes: [
        [Solicitud.sequelize.col('subtipo.nombre_sub'), 'nombre_sub'],
        [Solicitud.sequelize.fn('COUNT', Solicitud.sequelize.col('subtipo_id')), 'count']
      ],
      include: [
        {
          model: SubtipoSolicitud,
          as: 'subtipo',                
          attributes: []                
        }
      ],
      group: ['subtipo.nombre_sub', 'subtipo_id'],
      raw: true,
    });

    const porSubtipo = porSubtipoRaw.reduce((acc, item) => {
      const nombre = item.nombre_sub || 'Sin subtipo';
      acc[nombre] = (acc[nombre] || 0) + parseInt(item.count);
      return acc;
    }, {});

    return {
      total,
      porEstado: Object.fromEntries(
        porEstado.map(s => [s.estado_actual, parseInt(s.count)])
      ),
      porSubtipo
    };
  }
}

export default EstadisticaService;