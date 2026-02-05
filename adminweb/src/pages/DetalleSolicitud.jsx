import { useParams, useNavigate } from "react-router-dom";
import { useState } from "react";
import solicitudDetalleMock from "../mock/solicitudDetalleMock";
import SolicitudInfo from "../components/solicitudesDetalle/SolicitudInfo";
import HistorialTramites from "../components/solicitudesDetalle/HistorialTramites";
import TopBar from "../components/layout/TopBar";

const DetalleSolicitud = () => {
  const { id } = useParams();
  const navigate = useNavigate();

  const solicitudInicial = solicitudDetalleMock.find(s => s.id === id) || solicitudDetalleMock[0];

  // Estado local para la solicitud (simula actualización)
  const [solicitud, setSolicitud] = useState(solicitudInicial);

  // Estado para mostrar notificación toast
  const [toast, setToast] = useState(null);

  const showToast = (mensaje, tipo = "success") => {
    setToast({ mensaje, tipo });
    setTimeout(() => setToast(null), 3000); // desaparece después de 3 segundos
  };

  const handleAprobar = () => {
    setSolicitud(prev => ({
      ...prev,
      estado: "APROBADO",
      historial: [
        ...prev.historial,
        {
          fecha: "Hoy " + new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
          accion: "Solicitud Aprobada",
          detalle: "Aprobada por revisión administrativa.",
          usuario: "admin_actual",
          icon: "✅",
          color: "#10b981"
        }
      ]
    }));
    showToast("Solicitud aprobada exitosamente", "success");
  };

  const handleDerivar = () => {
    setSolicitud(prev => ({
      ...prev,
      estado: "EN TRÁMITE",
      historial: [
        ...prev.historial,
        {
          fecha: "Hoy " + new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
          accion: "Solicitud Derivada",
          detalle: "Derivada a otra unidad para revisión adicional.",
          usuario: "admin_actual",
          icon: "↪️",
          color: "#3b82f6"
        }
      ]
    }));
    showToast("Solicitud derivada exitosamente", "info");
  };

  const handlePendiente = () => {
    setSolicitud(prev => ({
      ...prev,
      estado: "PENDIENTE",
      historial: [
        ...prev.historial,
        {
          fecha: "Hoy " + new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
          accion: "Marcada como Pendiente",
          detalle: "Estado regresado a pendiente para revisión adicional.",
          usuario: "admin_actual",
          icon: "⏳",
          color: "#fbbf24"
        }
      ]
    }));
    showToast("Solicitud marcada como Pendiente", "warning");
  };

  return (
    <>
      <TopBar />

      <div className="detalle-container">
        {/* Notificación Toast (card emergente) */}
        {toast && (
          <div className={`toast ${toast.tipo}`}>
            {toast.mensaje}
          </div>
        )}

        <div className="detalle-header">
          <div className="breadcrumbs">
            Solicitudes <span className="separator">›</span> Detalle de Trámite
          </div>

          <div className="acciones-principales">
            <button className="btn-volver" onClick={() => navigate(-1)}>
              ← Volver al listado
            </button>

            {/* Botones según estado actual */}
            {solicitud.estado === "PENDIENTE" && (
              <>
                <button className="btn-derivar" onClick={handleDerivar}>
                  Derivar
                </button>
                <button className="btn-aprobar" onClick={handleAprobar}>
                  Aprobar
                </button>
              </>
            )}

            {solicitud.estado === "EN TRÁMITE" && (
              <>
                <button className="btn-aprobar" onClick={handleAprobar}>
                  Aprobar
                </button>
                <button className="btn-pendiente" onClick={handlePendiente}>
                  Marcar como Pendiente
                </button>
              </>
            )}

            {solicitud.estado === "APROBADO" && (
              <button className="btn-pendiente" onClick={handlePendiente}>
                Marcar como Pendiente
              </button>
            )}
          </div>
        </div>

        <h1 className="detalle-titulo">
          Solicitud #{solicitud.id}{" "}
          <span className={`estado-badge ${solicitud.estado.toLowerCase().replace(" ", "-")}`}>
            {solicitud.estado}
          </span>
        </h1>

        <div className="detalle-grid">
          <div className="columna-principal">
            <SolicitudInfo solicitud={solicitud} />
          </div>

          <div className="columna-historial">
            <HistorialTramites historial={solicitud.historial || []} />
          </div>
        </div>

        <footer className="detalle-footer">
          Sistema de Bienestar Universitario 
        </footer>
      </div>
    </>
  );
};

export default DetalleSolicitud;