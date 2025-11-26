import ObjetoPerdidoService from '../../business/services/ObjetoPerdidoService.js';

class ObjetoPerdidoController {
  static async reportar(req, res) {
    try {
      const { descripcion, lugar, fecha } = req.body;
      const foto = req.file ? `/uploads/${req.file.filename}` : null;
      const obj = await ObjetoPerdidoService.reportar({ descripcion, lugar, fecha, foto }, req.user.userId);
      res.status(201).json({ message: 'Objeto reportado', data: obj });
    } catch (error) {
      res.status(422).json({ error: error.message });
    }
  }

  static async obtenerTodos(req, res) {
    try {
      const objetos = await ObjetoPerdidoService.obtenerTodos();
      res.status(200).json({ message: 'OK', data: objetos });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  static async comentar(req, res) {
    try {
      const { mensaje, es_reclamo } = req.body;
      await ObjetoPerdidoService.comentar(req.params.id, mensaje, req.user.userId, es_reclamo);
      res.status(201).json({ message: 'Comentario agregado' });
    } catch (error) {
      res.status(422).json({ error: error.message });
    }
  }
}

export default ObjetoPerdidoController;