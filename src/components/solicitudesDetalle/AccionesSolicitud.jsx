const HistorialTramites = ({ historial = [] }) => {
  if (!historial.length) {
    return (
      <div className="card historial">
        <div className="card-header">
          <span className="card-icon">🕒</span>
          Historial de Trámites
        </div>
        <div className="card-body">
          <p>No hay movimientos registrados aún.</p>
        </div>
      </div>
    );
  }

  return (
    <div className="card historial">
      <div className="card-header">
        <span className="card-icon">🕒</span>
        Historial de Trámites ({historial.length})
      </div>
      <div className="timeline">
        {historial.map((item, index) => (
          <div key={index} className="timeline-item">
            <div className="timeline-dot" style={{ backgroundColor: item.color || "#6b7280" }}>
              {item.icon || "•"}
            </div>
            <div className="timeline-content">
              <div className="timeline-fecha">{item.fecha}</div>
              <div className="timeline-accion">{item.accion}</div>
              <div className="timeline-detalle">{item.detalle}</div>
              {item.usuario && (
                <div className="timeline-usuario">por {item.usuario}</div>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default HistorialTramites;