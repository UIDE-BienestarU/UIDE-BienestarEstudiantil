import TipoSolicitud from '../../data/models/TipoSolicitud.js';
import SubtipoSolicitud from '../../data/models/SubtipoSolicitud.js';

class TipoSolicitudService {
  static async getTiposSolicitud() {
    return await TipoSolicitud.findAll({
      include: SubtipoSolicitud,   // ← SIN objeto, SIN 'as' — deja que Sequelize use la asociación por defecto
      order: [
        ['nombre', 'ASC'],
        [SubtipoSolicitud, 'nombre_sub', 'ASC']
      ]
    });
  }
}

export default TipoSolicitudService;