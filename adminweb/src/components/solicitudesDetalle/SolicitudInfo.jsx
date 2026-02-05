import NotaInterna from "./NotaInterna"; // ← agregado para la nota interna

const SolicitudInfo = ({ solicitud }) => {
  if (!solicitud) {
    return <div className="card"><p>No se encontró la solicitud</p></div>;
  }

  const est = solicitud.estudiante || {};

  return (
    <div className="info-container">
      {/* Información del Estudiante */}
      <div className="card info-estudiante">
        <div className="card-header">
          <span className="card-icon">👤</span>
          Información del Estudiante
        </div>
        <div className="card-body">
          <div className="avatar-container">
            <img
              src={
                est.avatar ||
                `https://ui-avatars.com/api/?name=${encodeURIComponent(est.nombre || "Estudiante")}&background=6b21a8&color=fff&size=128`
              }
              alt={est.nombre || "Estudiante"}
              className="avatar-img"
            />
          </div>

          <div className="datos-estudiante">
            <h3>{est.nombre || "Nombre no disponible"}</h3>
            <p><strong>Carrera:</strong> {est.carrera || "—"}</p>
            <p><strong>Cédula:</strong> {est.cedula || est.idEstudiante || "—"}</p>
            <p>
              <strong>Estado:</strong>{" "}
              <span className={est.activo ? "estado-activo" : "estado-inactivo"}>
                {est.activo ? "Activo" : "Inactivo"}
              </span>
            </p>
          </div>
        </div>
      </div>

      {/* Detalle de la Solicitud */}
      <div className="card detalle-solicitud">
        <div className="card-header">
          <span className="card-icon">📄</span>
          Detalle de la Solicitud
        </div>
        <div className="card-body">
          <p><strong>Tipo de trámite:</strong> {solicitud.tipo || "—"}</p>
          <p><strong>Motivo:</strong></p>
          <div className="descripcion">
            {solicitud.detalle?.descripcion || "No se proporcionó descripción"}
          </div>
        </div>
      </div>

      {/* Documentos adjuntos */}
      <div className="card documentos">
        <div className="card-header">
          <span className="card-icon">📎</span>
          Documentos Adjuntos
        </div>
        <div className="card-body">
          {solicitud.documentos?.length > 0 ? (
            <ul className="lista-documentos">
              {solicitud.documentos.map((doc, i) => (
                <li key={i} className="documento-item">
                  <span className="doc-nombre">{doc.nombre}</span>
                  <span className="doc-tamano">{doc.tamaño || "?"}</span>
                  <button className="btn-descargar">Descargar</button>
                </li>
              ))}
            </ul>
          ) : (
            <p className="sin-documentos">No se adjuntaron documentos</p>
          )}
        </div>
      </div>

      {/* Campo para agregar nota interna (como en la captura) */}
      <NotaInterna />
    </div>
  );
};

export default SolicitudInfo;