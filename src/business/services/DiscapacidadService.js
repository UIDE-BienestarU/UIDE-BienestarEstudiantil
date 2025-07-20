import Discapacidad from '../../data/models/Discapacidad.js';
import Estudiante from '../../data/models/Estudiante.js';

class DiscapacidadService {
  static async createDiscapacidad(userId, discapacidadData) {
    const estudiante = await Estudiante.findByPk(userId);
    if (!estudiante) {
      throw new Error('Estudiante no encontrado');
    }
    return await Discapacidad.create({
      estudiante_id: userId,
      tipo: discapacidadData.tipo,
      carnet_conadis: discapacidadData.carnet_conadis,
      informe_medico: discapacidadData.informe_medico,
    });
  }

  static async getDiscapacidad(userId, rol) {
    if (rol === 'administrador') {
      return await Discapacidad.findAll({ include: [Estudiante] });
    }
    return await Discapacidad.findOne({ where: { estudiante_id: userId } });
  }

  static async updateDiscapacidad(userId, discapacidadData) {
    const discapacidad = await Discapacidad.findOne({ where: { estudiante_id: userId } });
    if (!discapacidad) {
      throw new Error('Discapacidad no encontrada');
    }
    await discapacidad.update({
      tipo: discapacidadData.tipo,
      carnet_conadis: discapacidadData.carnet_conadis,
      informe_medico: discapacidadData.informe_medico,
    });
    return discapacidad;
  }
}

export default DiscapacidadService;