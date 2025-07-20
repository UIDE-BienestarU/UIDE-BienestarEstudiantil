import DocumentoService from '../../business/services/DocumentoService.js';

class DocumentoController {
  static async getDocumentosBySolicitud(req, res) {
    try {
      const documentos = await DocumentoService.getDocumentosBySolicitud(req.params.solicitudId, req.user.userId, req.user.rol);
      res.status(200).json({
        message: 'Documentos obtenidos exitosamente',
        data: documentos,
      });
    } catch (error) {
      res.status(422).json({
        error: 'Error al obtener documentos',
        code: 'DOCUMENTO_ERROR',
        message: error.message,
        details: [],
      });
    }
  }

  static async addDocumento(req, res) {
    try {
      if (req.user.rol !== 'estudiante') {
        return res.status(403).json({
          error: 'No autorizado',
          code: 'FORBIDDEN',
          message: 'Solo los estudiantes pueden añadir documentos',
          details: [],
        });
      }
      const documento = await DocumentoService.addDocumento(req.params.solicitudId, req.body, req.user.userId, req.user.rol);
      res.status(201).json({
        message: 'Documento añadido exitosamente',
        data: documento,
      });
    } catch (error) {
      res.status(422).json({
        error: 'Error al añadir documento',
        code: 'DOCUMENTO_ERROR',
        message: error.message,
        details: [],
      });
    }
  }
}

export default DocumentoController;