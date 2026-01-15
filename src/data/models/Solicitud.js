import { DataTypes } from 'sequelize';
import sequelize from '../database.js';
import Usuario from './Usuario.js';
import SubtipoSolicitud from './SubtipoSolicitud.js';

const Solicitud = sequelize.define('Solicitud', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  estudiante_id: { type: DataTypes.INTEGER, allowNull: false },
  subtipo_id: { type: DataTypes.INTEGER, allowNull: false },
  fecha_solicitud: { type: DataTypes.DATEONLY, defaultValue: DataTypes.NOW },
  estado_actual: {
    type: DataTypes.ENUM('Pendiente', 'Aprobado', 'Rechazado', 'En espera'),
    defaultValue: 'Pendiente',
  },
  nivel_urgencia: {
    type: DataTypes.ENUM('Normal', 'Alta', 'Crítica'),
    defaultValue: 'Normal',
  },
  observaciones: DataTypes.TEXT,
  comentario: DataTypes.TEXT,
}, {
  tableName: 'solicitud',
  timestamps: true,
  updatedAt: false,
});

Solicitud.belongsTo(Usuario, { foreignKey: 'estudiante_id', as: 'estudiante' });
Solicitud.belongsTo(SubtipoSolicitud, { foreignKey: 'subtipo_id', as: 'subtipo' });
Usuario.hasMany(Solicitud, { foreignKey: 'estudiante_id', as: 'solicitudes' });

export default Solicitud;