import Documento from '../../data/models/Documento.js';
import Solicitud from '../../data/models/Solicitud.js';

class DocumentoService {
  static async getDocumentosBySolicitud(solicitudId, userId, rol) {
    const solicitud = await Solicitud.findByPk(solicitudId);
    if (!solicitud) {
      throw new Error('Solicitud no encontrada');
    }
    if (rol !== 'administrador' && solicitud.estudiante_id !== userId) {
      throw new Error('No tienes permiso para ver estos documentos');
    }
    return await Documento.findAll({ where: { solicitud_id: solicitudId } });
  }

  static async addDocumento(solicitudId, documentoData, userId, rol) {
    const solicitud = await Solicitud.findByPk(solicitudId);
    if (!solicitud) {
      throw new Error('Solicitud no encontrada');
    }
    if (rol !== 'administrador' && solicitud.estudiante_id !== userId) {
      throw new Error('No tienes permiso para añadir documentos');
    }
    return await Documento.create({
      solicitud_id: solicitudId,
      nombre_documento: documentoData.nombre_documento,
      url_archivo: documentoData.url_archivo,
      obligatorio: documentoData.obligatorio,
    });
  }
}

export default DocumentoService;