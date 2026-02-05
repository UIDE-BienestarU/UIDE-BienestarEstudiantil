import { FiEye, FiEdit2, FiTrash2, FiMoreVertical } from 'react-icons/fi';

export default function AvisoCard({ aviso, onEdit, onDelete, onMore }) {
  const estadoClase = `estado-${aviso.estado.toLowerCase().replace(' ', '-')}`;
  const tipoClase = `tipo-${aviso.tipo.toLowerCase().replace(/ /g, '-')}`;

  return (
    <div className="aviso-card">
      <div className="aviso-imagen-container">
        <img
          src={aviso.imagen || 'https://via.placeholder.com/800x480?text=Sin+Imagen'}
          alt={aviso.titulo}
          className="aviso-imagen"
        />
        <span className={`estado-badge ${estadoClase}`}>
          {aviso.estado}
        </span>
      </div>

      <div className="aviso-contenido">
        <span className={`tipo-tag ${tipoClase}`}>
          {aviso.tipo}
        </span>

        <h3 className="aviso-titulo">{aviso.titulo}</h3>
        <p className="aviso-desc">{aviso.descripcion}</p>

        <div className="aviso-footer">
          <div className="aviso-info-izq">
            <span className="aviso-fecha">{aviso.fecha}</span>
            {aviso.vistas && (
              <span className="aviso-vistas">
                <FiEye size={14} /> {aviso.vistas}
              </span>
            )}
          </div>

          <div className="aviso-acciones">
            <button 
              className="accion-btn edit" 
              onClick={onEdit}
              title="Editar aviso"
            >
              <FiEdit2 size={16} />
            </button>
            <button 
              className="accion-btn delete" 
              onClick={onDelete}
              title="Eliminar aviso"
            >
              <FiTrash2 size={16} />
            </button>
            <button 
              className="accion-btn more" 
              onClick={onMore}
              title="Más opciones"
            >
              <FiMoreVertical size={16} />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}