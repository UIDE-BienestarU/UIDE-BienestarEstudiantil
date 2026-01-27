import { DataTypes } from 'sequelize';
import sequelize from '../database.js';

const SolicitudDraft = sequelize.define('SolicitudDraft', {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    user_id: { type: DataTypes.INTEGER, allowNull: false },
    payload: { type: DataTypes.TEXT, allowNull: false },
    status: { type: DataTypes.ENUM('draft', 'submitted', 'discarded'), defaultValue: 'draft' },
}, {
    tableName: 'SolicitudDraft',
    timestamps: true,
});

export default SolicitudDraft;
