import { DataTypes } from 'sequelize';
import sequelize from '../database.js';

const IdempotencyKey = sequelize.define('IdempotencyKey', {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    user_id: { type: DataTypes.INTEGER, allowNull: false },
    idem_key: { type: DataTypes.STRING(80), allowNull: false },
    route: { type: DataTypes.STRING(120), allowNull: false },
    response_code: { type: DataTypes.INTEGER, allowNull: false },
    response_body: { type: DataTypes.TEXT, allowNull: false },
}, {
    tableName: 'IdempotencyKey',
    timestamps: true,
    updatedAt: false,
});

export default IdempotencyKey;
