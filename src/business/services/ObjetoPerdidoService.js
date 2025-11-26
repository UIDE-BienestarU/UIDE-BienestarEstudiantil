import ObjetoPerdido from '../../data/models/ObjetoPerdido.js';
import ComentarioObjeto from '../../data/models/ComentarioObjeto.js';

class ObjetoPerdidoService {
  static async reportar(data, userId) {
    return await ObjetoPerdido.create({ ...data, reportado_por: userId });
  }

  static async obtenerTodos() {
    return await ObjetoPerdido.findAll({
      order: [['createdAt', 'DESC']],
      include: ['reportador', { model: ComentarioObjeto, as: 'comentarios', include: ['autor'] }]
    });
  }

  static async comentar(objetoId, mensaje, userId, es_reclamo = false) {
    return await ComentarioObjeto.create({ objeto_id: objetoId, usuario_id: userId, mensaje, es_reclamo });
  }
}
export default ObjetoPerdidoService;