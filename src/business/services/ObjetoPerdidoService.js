import ObjetoPerdido from '../../data/models/ObjetoPerdido.js';
import Usuario from '../../data/models/Usuario.js';
import { Op } from 'sequelize';
import { parsePagination } from '../utils/pagination.js';

class ObjetoPerdidoService {
  static async list(query = {}) {
    const { page, limit, offset } = parsePagination(query);

    const where = {};

    // filtros
    if (query.estado) where.estado = query.estado; // perdido/encontrado/devuelto

    if (query.q) {
      where[Op.or] = [
        { titulo: { [Op.like]: `%${query.q}%` } },
        { descripcion: { [Op.like]: `%${query.q}%` } },
        { lugar_encontrado: { [Op.like]: `%${query.q}%` } },
      ];
    }

    if (query.reportadoPor) where.reportado_por = Number(query.reportadoPor);

    if (query.fechaDesde || query.fechaHasta) {
      where.createdAt = {};
      if (query.fechaDesde) where.createdAt[Op.gte] = new Date(query.fechaDesde);
      if (query.fechaHasta) where.createdAt[Op.lte] = new Date(query.fechaHasta);
    }

    const { rows, count } = await ObjetoPerdido.findAndCountAll({
      where,
      include: [{ model: Usuario, as: 'reportador', attributes: ['id', 'nombre_completo', 'rol'] }],
      order: [['createdAt', 'DESC']],
      limit,
      offset,
      distinct: true,
    });

    return { rows, total: count, page, limit };
  }

  static async create(data) {
    return await ObjetoPerdido.create(data);
  }

  static async updateEstado(id, estado) {
    const obj = await ObjetoPerdido.findByPk(id);
    if (!obj) throw new Error('NOT_FOUND');
    await obj.update({ estado });
    return obj;
  }

  static async actualizarEstado(id, estado) {
    const obj = await ObjetoPerdido.findByPk(id);
    if (!obj) throw new Error('Objeto no encontrado');

    await obj.update({ estado });
    return obj;
  }
}

export default ObjetoPerdidoService;
