import { DataTypes } from 'sequelize';
import sequelize from '../database.js';
import Usuario from './Usuario.js';

const Publicacion = sequelize.define('Publicacion', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  titulo: { type: DataTypes.STRING(200), allowNull: false },
  contenido: { type: DataTypes.TEXT, allowNull: false },
  imagen: DataTypes.STRING(255),
  publicado_por: { type: DataTypes.INTEGER, allowNull: false },
}, {
  tableName: 'Publicacion',
  timestamps: true,
});

Publicacion.belongsTo(Usuario, { foreignKey: 'publicado_por', as: 'autor' });
Usuario.hasMany(Publicacion, { foreignKey: 'publicado_por' });

export default Publicacion;