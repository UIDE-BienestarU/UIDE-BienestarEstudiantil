import SolicitudDraft from '../../data/models/SolicitudDraft.js';

class SolicitudDraftService {
    static async createDraft(userId, payloadObj) {
        return await SolicitudDraft.create({
            user_id: userId,
            payload: JSON.stringify(payloadObj || {}),
            status: 'draft',
        });
    }

    static async updateDraft(userId, draftId, payloadObj) {
        const draft = await SolicitudDraft.findByPk(draftId);
        if (!draft || draft.user_id !== userId) throw new Error('DRAFT_NOT_FOUND');

        await draft.update({ payload: JSON.stringify(payloadObj || {}) });
        return draft;
    }

    static async getMyDrafts(userId) {
        const drafts = await SolicitudDraft.findAll({
            where: { user_id: userId, status: 'draft' },
            order: [['updatedAt', 'DESC']],
        });
        return drafts.map(d => ({ ...d.toJSON(), payload: safeJson(d.payload) }));
    }

    static async getDraft(userId, draftId) {
        const draft = await SolicitudDraft.findByPk(draftId);
        if (!draft || draft.user_id !== userId) throw new Error('DRAFT_NOT_FOUND');
        const obj = draft.toJSON();
        obj.payload = safeJson(obj.payload);
        return obj;
    }

    static async markSubmitted(userId, draftId) {
        const draft = await SolicitudDraft.findByPk(draftId);
        if (!draft || draft.user_id !== userId) throw new Error('DRAFT_NOT_FOUND');
        await draft.update({ status: 'submitted' });
    }
}

function safeJson(text) {
    try { return text ? JSON.parse(text) : {}; } catch { return {}; }
}

export default SolicitudDraftService;
