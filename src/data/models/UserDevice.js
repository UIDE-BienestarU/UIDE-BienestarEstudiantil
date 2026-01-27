import { DataTypes } from 'sequelize';
import sequelize from '../database.js';

const UserDevice = sequelize.define('UserDevice', {
    id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
    userId: { type: DataTypes.INTEGER, allowNull: false },
    fcmToken: { type: DataTypes.STRING(512), allowNull: false },
    platform: { type: DataTypes.STRING(20), allowNull: false }, // android/ios
    deviceId: { type: DataTypes.STRING(128), allowNull: true },
    isActive: { type: DataTypes.BOOLEAN, defaultValue: true },
    lastSeenAt: { type: DataTypes.DATE, allowNull: false, defaultValue: DataTypes.NOW },
}, {
    tableName: 'UserDevice',
    timestamps: false,
    indexes: [
        { fields: ['userId'] },
        { fields: ['fcmToken'] },
    ],
});

export default UserDevice;
