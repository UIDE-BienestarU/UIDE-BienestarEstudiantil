import SugerenciaService from '../../business/services/SugerenciaService.js';

class SugerenciaController {
  static async enviar(req, res) {
    try {
      const { mensaje, anonima } = req.body;
      await SugerenciaService.enviar(mensaje, req.user.rol === 'estudiante' ? req.user.userId : null, anonima);
      res.status(201).json({ message: 'Sugerencia enviada' });
    } catch (error) {
      res.status(422).json({ error: error.message });
    }
  }

  static async obtenerTodas(req, res) {
    try {
      if (!['administrador', 'bienestar'].includes(req.user.rol)) {
        return res.status(403).json({ error: 'No autorizado' });
      }
      const sugerencias = await SugerenciaService.obtenerTodas();
      res.status(200).json({ message: 'OK', data: sugerencias });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
}

export default SugerenciaController;