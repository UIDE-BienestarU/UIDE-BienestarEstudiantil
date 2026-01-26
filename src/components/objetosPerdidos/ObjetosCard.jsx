import ObjetosEstadoBadge from './ObjetoEstadoBadge';

export default function ObjetosCard({ objeto, onVerDetalles, onEntregar }) {
  return (
    <div className="objetos-card group">
      <div className="objetos-imagen-container">
        <img
          src={objeto.imagen || 'https://via.placeholder.com/400x300?text=Sin+Foto'}
          alt={objeto.nombre}
          className="objetos-imagen"
        />
        <div className="badge-wrapper">
          <ObjetosEstadoBadge estado={objeto.estado} />
        </div>
      </div>

      <div className="objetos-body">
        <div className="objetos-header">
          <h3 className="objetos-title">{objeto.nombre}</h3>
          <span className="objetos-codigo">{objeto.codigo}</span>
        </div>

        <p className="objetos-desc line-clamp-2">{objeto.descripcion}</p>

        <div className="objetos-meta">
          <span className="objetos-fecha">{objeto.fecha}</span>
          <span className="objetos-ubicacion">📍 {objeto.ubicacion}</span>
        </div>

        <div className="objetos-actions">
          <button 
            className="btn-detalles"
            onClick={() => onVerDetalles(objeto)}
          >
            VER DETALLES →
          </button>
          {objeto.estado !== "ENTREGADO" && (
            <button 
              className="btn-entregar"
              onClick={() => onEntregar(objeto.id)}
            >
              Entregar
            </button>
          )}
        </div>
      </div>
    </div>
  );
}