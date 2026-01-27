import { ok } from '../middleware/apiResponse.js';
import Solicitud from '../../data/models/Solicitud.js';
import Notificacion from '../../data/models/Notificacion.js';
import { Sequelize } from 'sequelize';

class MeController {
    static async summary(req, res) {
        const userId = req.user.userId;

        const counts = await Solicitud.findAll({
            where: { estudiante_id: userId },
            attributes: ['estado_actual', [Sequelize.fn('COUNT', Sequelize.col('estado_actual')), 'count']],
            group: ['estado_actual'],
        });

        const notis = await Notificacion.findAll({
            where: { usuario_id: userId },
            order: [['fecha_envio', 'DESC']],
            limit: 5,
        });

        const unreadCount = await Notificacion.count({
            where: { usuario_id: userId, leido: false }
        });

        return ok(res, {
            message: 'Resumen',
            data: {
                solicitudesPorEstado: counts.map(c => ({
                    estado: c.get('estado_actual'),
                    count: Number(c.get('count')),
                })),
                notificacionesRecientes: notis,
                notificacionesNoLeidas: unreadCount,
            }
        });
    }
}

export default MeController;
