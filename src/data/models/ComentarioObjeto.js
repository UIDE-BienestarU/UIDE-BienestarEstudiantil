// ComentarioObjeto.js
import { DataTypes } from 'sequelize';
import sequelize from '../database.js';
import ObjetoPerdido from './ObjetoPerdido.js';
import Usuario from './Usuario.js';

const ComentarioObjeto = sequelize.define('ComentarioObjeto', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  mensaje: { type: DataTypes.TEXT, allowNull: false },
  es_reclamo: { type: DataTypes.BOOLEAN, defaultValue: false },
}, {
  tableName: 'comentarioobjeto',
  timestamps: true,
});

ComentarioObjeto.belongsTo(ObjetoPerdido);
ComentarioObjeto.belongsTo(Usuario, { as: 'autor' });
ObjetoPerdido.hasMany(ComentarioObjeto, { as: 'comentarios' });

export default ComentarioObjeto;