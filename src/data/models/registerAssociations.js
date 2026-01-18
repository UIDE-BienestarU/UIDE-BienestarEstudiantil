// src/data/models/registerAssociations.js
import TipoSolicitud from './TipoSolicitud.js';
import SubtipoSolicitud from './SubtipoSolicitud.js';

// Aquí se definen TODAS las asociaciones del proyecto (sin ciclos)
TipoSolicitud.hasMany(SubtipoSolicitud, {
  foreignKey: 'tipo_id',
});

SubtipoSolicitud.belongsTo(TipoSolicitud, {
  foreignKey: 'tipo_id',
});

// Agrega aquí las demás relaciones cuando las necesites (Solicitud, Notificacion, etc.)

console.log('Asociaciones registradas OK');