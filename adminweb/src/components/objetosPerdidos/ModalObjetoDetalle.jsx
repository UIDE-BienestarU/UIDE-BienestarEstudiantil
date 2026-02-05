export default function ModalObjetoDetalle({ objeto, onClose, onEntregar }) {
  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={e => e.stopPropagation()}>
        <h2 className="modal-title">Detalle del Objeto</h2>
        <button className="modal-close-btn" onClick={onClose}>×</button>

        <div className="detalle-imagen">
          <img src={objeto.imagen} alt={objeto.nombre} />
        </div>

        <div className="detalle-info">
          <h3>{objeto.nombre}</h3>
          <p className="detalle-codigo">{objeto.codigo}</p>
          <p>{objeto.descripcion}</p>
          <p><strong>Fecha:</strong> {objeto.fecha}</p>
          <p><strong>Ubicación:</strong> {objeto.ubicacion}</p>
          <p><strong>Estado:</strong> {objeto.estado}</p>

          <div className="detalle-actions">
            {objeto.estado !== "ENTREGADO" && (
              <button 
                className="btn-entregar"
                onClick={() => {
                  onEntregar(objeto.id);
                  onClose();
                }}
              >
                Marcar como Entregado
              </button>
            )}
            <button className="btn-cancelar" onClick={onClose}>
              Cerrar
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}