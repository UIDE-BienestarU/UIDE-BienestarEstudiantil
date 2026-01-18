import Discapacidad from '../../data/models/Discapacidad.js';
import Usuario from '../../data/models/Usuario.js';

class DiscapacidadService {
  /**
   * Crea un nuevo registro de discapacidad para un estudiante
   * @param {number} userId - ID del estudiante autenticado
   * @param {object} data - Datos enviados en el body (tipo, carnet_conadis, informe_medico)
   * @param {string|null} fileUrl - URL del archivo subido (opcional)
   * @returns {Promise<Discapacidad>} Registro creado
   */
  static async createDiscapacidad(userId, data, fileUrl = null) {
    // 1. Validar que el usuario sea estudiante (opcional, si no lo haces en middleware)
    const usuario = await Usuario.findByPk(userId);
    if (!usuario || usuario.rol !== 'estudiante') {
      throw new Error('Solo estudiantes pueden registrar discapacidad');
    }

    // 2. Verificar si ya existe un registro para este estudiante
    const existe = await Discapacidad.findOne({
      where: { estudiante_id: userId }
    });

    if (existe) {
      throw new Error('Ya tienes un registro de discapacidad. Contacta a bienestar para actualizarlo.');
    }

    // 3. Crear el registro
    const discapacidad = await Discapacidad.create({
      estudiante_id: userId,
      tipo: data.tipo || null,
      carnet_conadis: data.carnet_conadis || null,
      informe_medico: fileUrl || data.informe_medico || null
    });

    return discapacidad;
  }

  /**
   * Obtiene el registro de discapacidad de un estudiante (o todos si es admin/bienestar)
   * @param {number} userId - ID del usuario autenticado
   * @param {string} rol - Rol del usuario autenticado
   * @returns {Promise<Discapacidad|Discapacidad[]>}
   */
  static async getDiscapacidad(userId, rol) {
    if (rol === 'administrador' || rol === 'bienestar') {
      return await Discapacidad.findAll({
        include: [{
          model: Usuario,
          as: 'estudiante',
          attributes: ['id', 'nombre_completo', 'correo_institucional', 'matricula']
        }]
      });
    }

    // Para estudiante normal: solo su propio registro
    return await Discapacidad.findOne({
      where: { estudiante_id: userId },
      include: [{
        model: Usuario,
        as: 'estudiante',
        attributes: ['id', 'nombre_completo']
      }]
    });
  }

  /**
   * Actualiza el registro de discapacidad de un estudiante (solo el propio o admin/bienestar)
   * @param {number} discapacidadId - ID del registro a actualizar
   * @param {number} userId - ID del usuario autenticado
   * @param {string} rol - Rol del usuario
   * @param {object} data - Campos a actualizar
   * @param {string|null} fileUrl - Nueva URL de archivo (opcional)
   */
  static async updateDiscapacidad(discapacidadId, userId, rol, data, fileUrl = null) {
  const discapacidad = await Discapacidad.findByPk(discapacidadId);

  if (!discapacidad) {
    throw new Error('Registro de discapacidad no encontrado');
  }

  // Solo el estudiante dueño puede editar
  if (Number(discapacidad.estudiante_id) !== Number(userId)) {
    throw new Error('No tienes permiso para actualizar este registro');
  }

  // Actualizar
  await discapacidad.update({
    tipo: data.tipo !== undefined ? data.tipo : discapacidad.tipo,
    carnet_conadis: data.carnet_conadis !== undefined ? data.carnet_conadis : discapacidad.carnet_conadis,
    informe_medico: fileUrl || data.informe_medico || discapacidad.informe_medico
  });

  return discapacidad;
}
  /**
   * Elimina un registro de discapacidad (solo admin/bienestar o el propio estudiante)
   * @param {number} discapacidadId
   * @param {number} userId
   * @param {string} rol
   */
  static async deleteDiscapacidad(discapacidadId, userId, rol) {
    const discapacidad = await Discapacidad.findByPk(discapacidadId);

    if (!discapacidad) {
      throw new Error('Registro no encontrado');
    }

    if (discapacidad.estudiante_id !== userId && rol !== 'administrador' && rol !== 'bienestar') {
      throw new Error('No autorizado');
    }

    await discapacidad.destroy();
    return { message: 'Registro eliminado' };
  }
}

export default DiscapacidadService;