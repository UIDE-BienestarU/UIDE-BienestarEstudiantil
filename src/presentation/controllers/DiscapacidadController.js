import DiscapacidadService from '../../business/services/DiscapacidadService.js';

class DiscapacidadController {
  static async createDiscapacidad(req, res) {
    try {
      if (req.user.rol !== 'estudiante') {
        return res.status(403).json({
          error: 'No autorizado',
          code: 'FORBIDDEN',
          message: 'Solo los estudiantes pueden registrar discapacidades',
          details: [],
        });
      }
      const fileUrl = req.file ? `/Uploads/${req.file.filename}` : null;
      const discapacidad = await DiscapacidadService.createDiscapacidad(req.user.userId, req.body, fileUrl);
      res.status(201).json({
        message: 'Discapacidad registrada exitosamente',
        data: discapacidad,
      });
    } catch (error) {
      res.status(422).json({
        error: 'Error al registrar discapacidad',
        code: 'DISCAPACIDAD_ERROR',
        message: error.message,
        details: [],
      });
    }
  }

  static async getDiscapacidad(req, res) {
    try {
      const discapacidad = await DiscapacidadService.getDiscapacidad(req.user.userId, req.user.rol);
      res.status(200).json({
        message: 'Discapacidad obtenida exitosamente',
        data: discapacidad,
      });
    } catch (error) {
      res.status(422).json({
        error: 'Error al obtener discapacidad',
        code: 'DISCAPACIDAD_ERROR',
        message: error.message,
        details: [],
      });
    }
  }

  static async getAllDiscapacidades(req, res) {
    try {
      if (req.user.rol !== 'administrador') {
        return res.status(403).json({
          error: 'No autorizado',
          code: 'FORBIDDEN',
          message: 'Solo los administradores pueden ver todas las discapacidades',
          details: [],
        });
      }
      const discapacidades = await DiscapacidadService.getDiscapacidad(null, 'administrador');
      res.status(200).json({
        message: 'Discapacidades obtenidas exitosamente',
        data: discapacidades,
      });
    } catch (error) {
      res.status(422).json({
        error: 'Error al obtener discapacidades',
        code: 'DISCAPACIDAD_ERROR',
        message: error.message,
        details: [],
      });
    }
  }

  static async updateDiscapacidad(req, res) {
  try {
    if (req.user.rol !== 'estudiante') {
      return res.status(403).json({ error: 'No autorizado' });
    }

    const discapacidadId = req.params.id;  // si usas :id en la ruta
    const fileUrl = req.file ? `/Uploads/${req.file.filename}` : null;

    const discapacidad = await DiscapacidadService.updateDiscapacidad(
      discapacidadId,               // 1: ID del registro
      req.user.userId,              // 2: userId del estudiante
      req.user.rol,                 // 3: rol
      req.body,                     // 4: datos a actualizar
      fileUrl                       // 5: fileUrl
    );

    res.status(200).json({
      message: 'Discapacidad actualizada exitosamente',
      data: discapacidad,
    });
  } catch (error) {
    console.error('Error al actualizar discapacidad:', error);
    res.status(422).json({
      error: 'Error al actualizar discapacidad',
      code: 'DISCAPACIDAD_ERROR',
      message: error.message,
      details: [],
    });
  }
}
}

export default DiscapacidadController;
