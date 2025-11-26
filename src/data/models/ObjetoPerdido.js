import { DataTypes } from 'sequelize';
import sequelize from '../database.js';
import Usuario from './Usuario.js';

const ObjetoPerdido = sequelize.define('ObjetoPerdido', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  titulo: { type: DataTypes.STRING(150), allowNull: false },
  descripcion: { type: DataTypes.TEXT, allowNull: false },
  imagen: DataTypes.STRING(255),
  lugar_encontrado: DataTypes.STRING(100),
  estado: {
    type: DataTypes.ENUM('perdido', 'encontrado', 'devuelto'),
    defaultValue: 'encontrado',
  },
  reportado_por: { type: DataTypes.INTEGER, allowNull: false },
}, {
  tableName: 'objetos_perdidos',
  timestamps: true,
});

ObjetoPerdido.belongsTo(Usuario, { foreignKey: 'reportado_por', as: 'reportador' });
Usuario.hasMany(ObjetoPerdido, { foreignKey: 'reportado_por' });

export default ObjetoPerdido;