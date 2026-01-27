// src/business/services/PublicacionService.js
import Publicacion from '../../data/models/Publicacion.js';
import Usuario from '../../data/models/Usuario.js';

const parsePage = (q) => {
  const page = Math.max(parseInt(q.page || '1', 10), 1);
  const limit = Math.min(Math.max(parseInt(q.limit || '20', 10), 1), 50);
  const offset = (page - 1) * limit;
  return { page, limit, offset };
};

class PublicacionService {
  static async create(data) {
    return await Publicacion.create(data);
  }

  static async list(query) {
    const { page, limit, offset } = parsePage(query);

    const { rows, count } = await Publicacion.findAndCountAll({
      include: [{ model: Usuario, as: 'autor', attributes: ['id', 'nombre_completo', 'rol'] }],
      order: [['createdAt', 'DESC']],
      limit,
      offset,
    });

    return { rows, total: count, page, limit };
  }
}

export default PublicacionService;
