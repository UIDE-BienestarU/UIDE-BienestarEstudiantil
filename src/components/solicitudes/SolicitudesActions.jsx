import { useNavigate } from "react-router-dom";

const SolicitudesActions = ({ solicitud }) => {
  const navigate = useNavigate();

  if (!solicitud) return null;

  return (
    <div className="acciones">
      <button
        className="btn-ver-detalle"
        onClick={() => navigate(`/solicitudes/${solicitud.id}`)}
        title="Ver detalle de la solicitud"
        aria-label="Ver detalle"
      >
        <span className="icon-eye">👁</span>
      </button>
    </div>
  );
};

export default SolicitudesActions;