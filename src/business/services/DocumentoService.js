import Documento from '../../data/models/Documento.js';
import Solicitud from '../../data/models/Solicitud.js';
import Usuario from '../../data/models/Usuario.js';

class DocumentoService {
  static async getDocumentosBySolicitud(solicitudId, userId, rol) {
    const solicitud = await Solicitud.findByPk(solicitudId, {
      include: [{ model: Usuario, as: 'estudiante' }]
    });

    if (!solicitud) throw new Error('Solicitud no encontrada');
    if (rol !== 'administrador' && rol !== 'bienestar' && solicitud.estudiante_id !== userId) {
      throw new Error('No tienes permiso');
    }

    return await Documento.findAll({ where: { solicitud_id: solicitudId } });
  }
}

export default DocumentoService;