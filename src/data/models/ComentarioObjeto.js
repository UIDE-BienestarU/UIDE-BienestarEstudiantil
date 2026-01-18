import { DataTypes } from 'sequelize';
import sequelize from '../database.js';
import ObjetoPerdido from './ObjetoPerdido.js';
import Usuario from './Usuario.js';

const ComentarioObjeto = sequelize.define('ComentarioObjeto', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  objeto_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: ObjetoPerdido, key: 'id' },
    onDelete: 'CASCADE'
  },
  usuario_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: Usuario, key: 'id' },
    onDelete: 'SET NULL'  
  },
  mensaje: { type: DataTypes.TEXT, allowNull: false },
  es_reclamo: { type: DataTypes.BOOLEAN, defaultValue: false },
}, {
  tableName: 'ComentarioObjeto',
  timestamps: true,
});

// Asociaciones 
ComentarioObjeto.belongsTo(ObjetoPerdido, { foreignKey: 'objeto_id', as: 'objeto' });
ComentarioObjeto.belongsTo(Usuario, { foreignKey: 'usuario_id', as: 'autor' });
ObjetoPerdido.hasMany(ComentarioObjeto, { foreignKey: 'objeto_id', as: 'comentarios' });

export default ComentarioObjeto;