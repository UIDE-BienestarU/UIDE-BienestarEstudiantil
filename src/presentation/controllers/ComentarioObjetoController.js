import ComentarioObjetoService from '../../business/services/ComentarioObjetoService.js';
import { ok } from '../middleware/apiResponse.js';
import { ApiError } from '../middleware/errorHandler.js';
import { emitComentarioObjeto } from '../../realtime/socket.js';
import Usuario from '../../data/models/Usuario.js';

class ComentarioObjetoController {
    static async list(req, res) {
        const objetoId = Number(req.params.id);
        if (!objetoId) throw new ApiError(400, 'BAD_REQUEST', 'id inválido');

        const result = await ComentarioObjetoService.listByObjeto(objetoId, req.query);
        return ok(res, {
            message: 'Comentarios',
            data: result.rows,
            meta: { page: result.page, limit: result.limit, total: result.total }
        });
    }

    static async create(req, res) {
        const objetoId = Number(req.params.id);
        if (!objetoId) throw new ApiError(400, 'BAD_REQUEST', 'id inválido');

        try {
            const comment = await ComentarioObjetoService.create(objetoId, req.user.userId, req.body);

            // Trae autor para que Flutter renderice sin otra llamada
            const autor = await Usuario.findByPk(req.user.userId, {
                attributes: ['id', 'nombre_completo', 'rol']
            });

            emitComentarioObjeto(objetoId, {
                id: comment.id,
                objeto_id: objetoId,
                mensaje: comment.mensaje,
                es_reclamo: comment.es_reclamo,
                createdAt: comment.createdAt,
                autor,
            });

            return ok(res, { status: 201, message: 'Comentario creado', data: comment });
        } catch (e) {
            if (e.message === 'OBJETO_NOT_FOUND') throw new ApiError(404, 'NOT_FOUND', 'Objeto no encontrado');
            if (e.message === 'COMMENT_EMPTY') throw new ApiError(400, 'VALIDATION_ERROR', 'Comentario vacío');
            if (e.message === 'COMMENT_TOO_LONG') throw new ApiError(400, 'VALIDATION_ERROR', 'Máximo 800 caracteres');
            throw e;
        }
    }
}

export default ComentarioObjetoController;
