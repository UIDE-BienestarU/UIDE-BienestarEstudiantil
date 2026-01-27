import SolicitudDraftService from '../../business/services/SolicitudDraftService.js';
import { ok } from '../middleware/apiResponse.js';
import { ApiError } from '../middleware/errorHandler.js';

class SolicitudDraftController {
    static async create(req, res) {
        const draft = await SolicitudDraftService.createDraft(req.user.userId, req.body);
        return ok(res, { status: 201, message: 'Draft creado', data: draft });
    }

    static async update(req, res) {
        const id = Number(req.params.id);
        if (!id) throw new ApiError(400, 'BAD_REQUEST', 'id inválido');

        const draft = await SolicitudDraftService.updateDraft(req.user.userId, id, req.body);
        return ok(res, { message: 'Draft actualizado', data: draft });
    }

    static async listMine(req, res) {
        const drafts = await SolicitudDraftService.getMyDrafts(req.user.userId);
        return ok(res, { message: 'Drafts', data: drafts });
    }

    static async getOne(req, res) {
        const id = Number(req.params.id);
        const draft = await SolicitudDraftService.getDraft(req.user.userId, id);
        return ok(res, { message: 'Draft', data: draft });
    }
}

export default SolicitudDraftController;
