import Publicacion from '../../data/models/Publicacion.js';
import Usuario from '../../data/models/Usuario.js';

class PublicacionService {
  static async crear(titulo, contenido, imagen, userId) {
    return await Publicacion.create({ titulo, contenido, imagen, publicado_por: userId });
  }

  static async obtenerTodas() {
    return await Publicacion.findAll({
      order: [['createdAt', 'DESC']],
      include: [{ model: Usuario, as: 'autor', attributes: ['nombre_completo'] }]
    });
  }
}
export default PublicacionService;