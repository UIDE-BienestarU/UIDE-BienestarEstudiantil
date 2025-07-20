import TipoSolicitud from '../../data/models/TipoSolicitud.js';
import SubtipoSolicitud from '../../data/models/SubtipoSolicitud.js';

class TipoSolicitudService {
  static async getTiposSolicitud() {
    return await TipoSolicitud.findAll({
      include: [SubtipoSolicitud],
    });
  }
}

export default TipoSolicitudService;