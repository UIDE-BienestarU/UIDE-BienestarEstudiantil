import ComentarioObjeto from '../../data/models/ComentarioObjeto.js';
import ObjetoPerdido from '../../data/models/ObjetoPerdido.js';
import Usuario from '../../data/models/Usuario.js';

const parsePage = (q) => {
    const page = Math.max(parseInt(q.page || '1', 10), 1);
    const limit = Math.min(Math.max(parseInt(q.limit || '20', 10), 1), 50);
    const offset = (page - 1) * limit;
    return { page, limit, offset };
};

class ComentarioObjetoService {
    static async listByObjeto(objetoId, query) {
        const { page, limit, offset } = parsePage(query);

        const { rows, count } = await ComentarioObjeto.findAndCountAll({
            where: { objeto_id: objetoId },
            include: [{ model: Usuario, as: 'autor', attributes: ['id', 'nombre_completo', 'rol'] }],
            order: [['createdAt', 'DESC']],
            limit,
            offset,
        });

        return { rows, total: count, page, limit };
    }

    static async create(objetoId, userId, { mensaje, es_reclamo = false }) {
        const obj = await ObjetoPerdido.findByPk(objetoId);
        if (!obj) throw new Error('OBJETO_NOT_FOUND');

        const clean = String(mensaje || '').trim();
        if (!clean) throw new Error('COMMENT_EMPTY');
        if (clean.length > 800) throw new Error('COMMENT_TOO_LONG'); // móvil friendly

        return await ComentarioObjeto.create({
            objeto_id: objetoId,
            usuario_id: userId,
            mensaje: clean,
            es_reclamo: Boolean(es_reclamo),
        });
    }
}

export default ComentarioObjetoService;
