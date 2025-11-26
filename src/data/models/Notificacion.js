import { DataTypes } from 'sequelize';
import sequelize from '../database.js';
import Solicitud from './Solicitud.js';
import Usuario from './Usuario.js';

const Notificacion = sequelize.define('Notificacion', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  solicitud_id: { type: DataTypes.INTEGER, allowNull: true },
  usuario_id: { type: DataTypes.INTEGER, allowNull: false },
  mensaje: { type: DataTypes.STRING(255), allowNull: false },
  tipo: {
    type: DataTypes.ENUM('Alerta', 'Actualización', 'Recordatorio', 'Confirmación'),
    defaultValue: 'Actualización',
  },
  leido: { type: DataTypes.BOOLEAN, defaultValue: false },
}, {
  tableName: 'notificaciones',
  timestamps: true,
  createdAt: 'fecha_envio',
});

Notificacion.belongsTo(Solicitud);
Notificacion.belongsTo(Usuario, { foreignKey: 'usuario_id', as: 'destinatario' });

export default Notificacion;