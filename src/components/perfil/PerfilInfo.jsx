import Badge from "../ui/Badge"; // asumo que lo tienes, si no, reemplaza con span + clase

export default function PerfilInfo({ perfil }) {
  return (
    <div className="perfil-card">
      {/* Header con avatar y badge */}
      <div className="perfil-header">
        <div className="avatar-container">
          <img 
            src={perfil.avatar} 
            alt={perfil.nombre} 
            className="perfil-avatar" 
          />
          <Badge 
            variant="success" 
            className="avatar-badge"
          >
            {perfil.estado}
          </Badge>
        </div>

        <div className="perfil-info-text">
          <h2 className="perfil-nombre">{perfil.nombre}</h2>
          <p className="perfil-cargo">{perfil.rol}</p>
          <div className="perfil-tags">
            <span className="tag-item">Cédula: {perfil.cedula}</span>
            <span className="tag-item">Teléfono: {perfil.telefono}</span>
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="perfil-tabs">
        <button className="tab-btn active">Información Personal</button>
      </div>

      {/* Contenido */}
      <div className="perfil-section">
        {/* Datos de Contacto */}
        <div className="section-card">
          <h3 className="section-title">✉ Datos de Contacto</h3>
          <div className="info-row">
            <span className="label">Correo institucional</span>
            <span className="value">{perfil.correo}</span>
          </div>
          <div className="info-row">
            <span className="label">Teléfono oficina</span>
            <span className="value">{perfil.telefono}</span>
          </div>
        </div>

        {/* Detalles de Cuenta */}
        <div className="section-card">
          <h3 className="section-title">🔐 Detalles de Cuenta</h3>
          <div className="info-row">
            <span className="label">Rol de Sistema</span>
            <span className="value badge-rol">{perfil.rol}</span>
          </div>
          <button className="btn-registro">Ver Registro de Actividad →</button>
        </div>

        {/* Perfil Profesional (ejemplo, puedes extenderlo) */}
        <div className="section-card full-width">
          <h3 className="section-title">👨‍🎓 Perfil Profesional</h3>
          <p className="breve-resena">
            Administrador con experiencia en gestión de plataformas educativas y bienestar estudiantil.
          </p>
          <p className="nota-publica">
            Esta información será visible en el directorio institucional.
          </p>
        </div>
      </div>
    </div>
  );
}