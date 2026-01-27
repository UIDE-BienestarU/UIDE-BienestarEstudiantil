// src/presentation/controllers/PublicacionController.js
import PublicacionService from '../../business/services/PublicacionService.js';
import { ok } from '../middleware/apiResponse.js';
import { ApiError } from '../middleware/errorHandler.js';

class PublicacionController {
  static async crear(req, res) {
    const { titulo, contenido } = req.body;

    if (!titulo || !contenido) {
      throw new ApiError(400, 'VALIDATION_ERROR', 'titulo y contenido son requeridos');
    }

    const imagen = req.file ? `/Uploads/${req.file.filename}` : null;

    const pub = await PublicacionService.create({
      titulo: String(titulo).trim(),
      contenido: String(contenido).trim(),
      imagen,
      publicado_por: req.user.userId,
    });

    return ok(res, { status: 201, message: 'Publicación creada', data: pub });
  }

  static async obtenerTodas(req, res) {
    const result = await PublicacionService.list(req.query);
    return ok(res, {
      message: 'Publicaciones',
      data: result.rows,
      meta: { page: result.page, limit: result.limit, total: result.total },
    });
  }
}

export default PublicacionController;
