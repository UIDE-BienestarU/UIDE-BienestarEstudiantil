import Sugerencia from '../../data/models/Sugerencia.js';

class SugerenciaService {
  static async enviar(mensaje, userId = null, anonima = true) {
    return await Sugerencia.create({ mensaje, estudiante_id: userId, es_anonima: anonima });
  }

  static async obtenerTodas() {
    return await Sugerencia.findAll({ order: [['createdAt', 'DESC']] });
  }

  static async marcarLeida(id) {
    const s = await Sugerencia.findByPk(id);
    if (s) { s.leida = true; await s.save(); }
  }
}
export default SugerenciaService;