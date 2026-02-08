const EstadoBadge = ({ estado }) => {
  const estadoMap = {
    'por revisar': { class: 'por-revisar', text: 'POR REVISAR' },
    'en progreso': { class: 'en-progreso', text: 'EN PROGRESO' },
    'aprobada':    { class: 'aprobada', text: 'APROBADA' },
    'pendiente':   { class: 'por-revisar', text: 'PENDIENTE' },
    'borrador':    { class: 'borrador', text: 'BORRADOR' },
    'publicado':   { class: 'publicado', text: 'PUBLICADO' }
  };

  const lower = (estado || "").toLowerCase();
  const config = estadoMap[lower] || { class: 'default', text: estado || "?" };

  return <span className={`badge ${config.class}`}>{config.text}</span>;
};

export default EstadoBadge;