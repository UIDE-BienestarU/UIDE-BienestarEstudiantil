import PublicacionService from '../../business/services/PublicacionService.js';

class PublicacionController {
  static async crear(req, res) {
    try {
      if (!['administrador', 'bienestar'].includes(req.user.rol)) {
        return res.status(403).json({ error: 'No autorizado' });
      }
      const { titulo, contenido } = req.body;
      const imagen = req.file ? `/uploads/${req.file.filename}` : null;
      const pub = await PublicacionService.crear(titulo, contenido, imagen, req.user.userId);
      res.status(201).json({ message: 'Publicación creada', data: pub });
    } catch (error) {
      res.status(422).json({ error: error.message });
    }
  }

  static async obtenerTodas(req, res) {
    try {
      const pubs = await PublicacionService.obtenerTodas();
      res.status(200).json({ message: 'OK', data: pubs });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
}

export default PublicacionController;