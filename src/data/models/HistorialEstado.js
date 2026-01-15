import { DataTypes } from 'sequelize';
import sequelize from '../database.js';
import Solicitud from './Solicitud.js';
import Usuario from './Usuario.js';

const HistorialEstado = sequelize.define('HistorialEstado', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  solicitud_id: { type: DataTypes.INTEGER, allowNull: false },
  admin_id: { type: DataTypes.INTEGER, allowNull: false },
  estado: {
    type: DataTypes.ENUM('Aprobado', 'En progreso', 'Por revisar'),
    allowNull: false,
  },
  comentario: DataTypes.TEXT,
}, {
  tableName: 'historialestado',
  timestamps: true,
  createdAt: 'fecha',
  updatedAt: false,
});

HistorialEstado.belongsTo(Solicitud);
HistorialEstado.belongsTo(Usuario, { foreignKey: 'admin_id', as: 'administrador' });

export default HistorialEstado;