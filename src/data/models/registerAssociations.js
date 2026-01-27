// src/data/models/registerAssociations.js
import TipoSolicitud from './TipoSolicitud.js';
import SubtipoSolicitud from './SubtipoSolicitud.js';
import Usuario from './Usuario.js';
import UserDevice from './UserDevice.js';

// Aquí se definen TODAS las asociaciones del proyecto (sin ciclos)

// TipoSolicitud ↔ SubtipoSolicitud
TipoSolicitud.hasMany(SubtipoSolicitud, {
  foreignKey: 'tipo_id',
});

SubtipoSolicitud.belongsTo(TipoSolicitud, {
  foreignKey: 'tipo_id',
});

// Usuario ↔ UserDevice
UserDevice.belongsTo(Usuario, {
  foreignKey: 'userId',
  as: 'usuario',
});

Usuario.hasMany(UserDevice, {
  foreignKey: 'userId',
  as: 'devices',
});

// Agrega aquí las demás relaciones cuando las necesites (Solicitud, Notificacion, etc.)

console.log('Asociaciones registradas OK');
