import { DataTypes } from 'sequelize';
import sequelize from '../database.js';
import Solicitud from './Solicitud.js';
import Usuario from './Usuario.js';

const SolicitudHistorial = sequelize.define('SolicitudHistorial', {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    solicitud_id: { type: DataTypes.INTEGER, allowNull: false },
    actor_user_id: { type: DataTypes.INTEGER, allowNull: false },
    action: { type: DataTypes.STRING(50), allowNull: false }, // CREATE, UPDATE_STATUS
    from_status: { type: DataTypes.STRING(50), allowNull: true },
    to_status: { type: DataTypes.STRING(50), allowNull: true },
    comentario: { type: DataTypes.TEXT, allowNull: true },
    createdAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW }
}, {
    tableName: 'SolicitudHistorial',
    timestamps: false,
});

SolicitudHistorial.belongsTo(Solicitud, { foreignKey: 'solicitud_id' });
SolicitudHistorial.belongsTo(Usuario, { foreignKey: 'actor_user_id', as: 'actor' });

export default SolicitudHistorial;
