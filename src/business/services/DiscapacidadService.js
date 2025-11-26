import Discapacidad from '../../data/models/Discapacidad.js';
import Usuario from '../../data/models/Usuario.js';

class DiscapacidadService {
  static async crear(userId, data, fileUrl) {
    const existe = await Discapacidad.findOne({ where: { estudiante_id: userId } });
    if (existe) throw new Error('Ya tienes discapacidad registrada');
    return await Discapacidad.create({ estudiante_id: userId, ...data, informe_medico: fileUrl });
  }

  static async obtener(userId, rol) {
    if (rol === 'administrador' || rol === 'bienestar') {
      return await Discapacidad.findAll({ include: [{ model: Usuario, as: 'estudiante' }] });
    }
    return await Discapacidad.findOne({ where: { estudiante_id: userId } });
  }
}
export default DiscapacidadService;