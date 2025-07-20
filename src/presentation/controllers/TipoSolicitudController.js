import TipoSolicitudService from '../../business/services/TipoSolicitudService.js';

class TipoSolicitudController {
  static async getTiposSolicitud(req, res) {
    try {
      const tipos = await TipoSolicitudService.getTiposSolicitud();
      res.status(200).json({
        message: 'Tipos de solicitud obtenidos exitosamente',
        data: tipos,
      });
    } catch (error) {
      res.status(500).json({
        error: 'Error interno del servidor',
        code: 'SERVER_ERROR',
        message: error.message,
        details: [],
      });
    }
  }
}

export default TipoSolicitudController;