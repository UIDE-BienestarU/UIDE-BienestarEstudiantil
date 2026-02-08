import { useParams, useNavigate, useLocation } from "react-router-dom";
import { useState, useEffect } from "react";
import SolicitudInfo from "../components/solicitudesDetalle/SolicitudInfo";
import HistorialTramites from "../components/solicitudesDetalle/HistorialTramites";
import TopBar from "../components/layout/TopBar";
import ToastNotification from "../components/common/ToastNotification";
import solicitudesService from "../services/solicitudesService";

const DetalleSolicitud = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const location = useLocation();

  // State from navigation or null
  const initialSolicitud = location.state?.solicitud || null;

  const [solicitud, setSolicitud] = useState(initialSolicitud);
  const [historial, setHistorial] = useState([]);
  const [loading, setLoading] = useState(false);
  
  // Toast State
  const [toast, setToast] = useState(null); // { message, type }

  // Estados para el Panel de Administración (Gestión de Estado)
  const [adminEstado, setAdminEstado] = useState("");
  const [adminComentario, setAdminComentario] = useState("");

  const showToast = (mensaje, tipo = "success") => {
    setToast({ mensaje, tipo });
    // ToastNotification handles its own timer for dismissal via onClose,
    // but we can also auto-clear here if we want to ensure state consistency.
    // However, the component calls onClose which we'll map to clearing state.
  };

  useEffect(() => {
    if (!solicitud) {
        // En un caso real, aquí cargaríamos la solicitud por ID si no viene en el state
        // Por ahora asumimos que viene del listado o implementamos fetch básico
        // showToast("Cargando solicitud...", "info");
    }

    const loadHistorial = async () => {
      try {
        const data = await solicitudesService.getHistorial(id);
        if (data && data.success && data.data) {
           setHistorial(data.data);
        } else if (Array.isArray(data)) {
           setHistorial(data); 
        }
      } catch (error) {
        console.error("Error loading historial", error);
      }
    };

    loadHistorial();
  }, [id, solicitud]);

  // Sincronizar estado del admin panel cuando carga la solicitud
  useEffect(() => {
    if (solicitud && solicitud.estado_actual) {
        setAdminEstado(solicitud.estado_actual);
    }
  }, [solicitud]);

  const handleUpdateEstado = async () => {
    if (!adminEstado) return;
    
    try {
      setLoading(true);
      await solicitudesService.updateEstado(id, adminEstado, adminComentario);
      
      // Update local state
      setSolicitud(prev => ({ ...prev, estado_actual: adminEstado }));
      showToast(`Estado actualizado correctamente a: ${adminEstado}`, "success");
      setAdminComentario(""); // Limpiar comentario tras éxito
      
      // Reload historial
      const hist = await solicitudesService.getHistorial(id);
      if (hist && (hist.data || Array.isArray(hist))) setHistorial(hist.data || hist);

    } catch (error) {
      console.error("Error updating estado", error);
      showToast("Error al actualizar estado. Intente nuevamente.", "error");
    } finally {
      setLoading(false);
    }
  };

  if (!solicitud) {
     return (
       <div className="p-8 text-center">
         <h2>Cargando solicitud o acceso inválido...</h2>
         <button className="btn-volver mt-4" onClick={() => navigate('/solicitudes')}>
           Volver al listado
         </button>
       </div>
     );
  }

  // Normalize status for UI logic
  const estado = solicitud.estado_actual || solicitud.estado;

  return (
    <>
      <TopBar />

      <div className="detalle-container">
        {/* Usar el nuevo componente ToastNotification */}
        {toast && (
          <ToastNotification 
            message={toast.mensaje} 
            type={toast.tipo} 
            onClose={() => setToast(null)} 
          />
        )}

        <div className="detalle-header">
          <div className="breadcrumbs">
            Solicitudes <span className="separator">›</span> Detalle de Trámite
          </div>

          <div className="acciones-principales">
            <button className="btn-volver" onClick={() => navigate('/solicitudes')}>
              ← Volver
            </button>
          </div>
        </div>

        <div className="detalle-grid">
          <div className="columna-principal">
            <SolicitudInfo 
                solicitud={solicitud} 
                adminState={{ estado: adminEstado, comentario: adminComentario }}
                onUpdateEstado={handleUpdateEstado}
                setAdminState={setAdminEstado}
                setAdminComentario={setAdminComentario}
                loading={loading}
            />
          </div>

          <div className="columna-historial">
            <HistorialTramites historial={historial} />
          </div>
        </div>
      </div>
    </>
  );
};

export default DetalleSolicitud;