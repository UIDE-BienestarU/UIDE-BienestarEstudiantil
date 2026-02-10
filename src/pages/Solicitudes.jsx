import { useState, useEffect, useCallback } from "react";
import SolicitudesTable from "../components/solicitudes/SolicitudesTable";
import SolicitudesFilters from "../components/solicitudes/SolicitudesFilters";
import TopBar from "../components/layout/TopBar";
import solicitudesService from "../services/solicitudesService";

const Solicitudes = () => {
  const [filtro, setFiltro] = useState("todos");
  const [solicitudes, setSolicitudes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  const fetchSolicitudes = useCallback(async () => {
    try {
      setLoading(true);
      const params = {
        page,
        limit: 10,
      };
      
      if (filtro && filtro.estado && filtro.estado !== 'todos') params.estado = filtro.estado;
      if (filtro && filtro.fechaDesde) params.fechaDesde = filtro.fechaDesde;
      if (filtro && filtro.fechaHasta) params.fechaHasta = filtro.fechaHasta;
      if (filtro && filtro.subtipo) params.subtipo_id = filtro.subtipo;

      // Handle simple string filter if that's what's passed (backward compatibility)
      if (typeof filtro === 'string' && filtro !== 'todos') {
         params.estado = filtro;
         // Map generic filters to backend status if needed
         if (filtro === 'pendientes') params.estado = 'Por revisar';
         if (filtro === 'aprobados') params.estado = 'Aprobada';
      }

      const data = await solicitudesService.getAll(params);
      if (data.data && Array.isArray(data.data)) {
        setSolicitudes(data.data);
        if (data.meta) {
           setTotalPages(Math.ceil(data.meta.total / data.meta.limit));
        } else {
           setTotalPages(data.totalPages || 1);
        }
      } else if (Array.isArray(data)) {
        setSolicitudes(data);
      } else {
        setSolicitudes([]);
      }
    } catch (err) {
      console.error("Error fetching solicitudes", err);
      setError("No se pudieron cargar las solicitudes");
    } finally {
      setLoading(false);
    }
  }, [page, filtro]);

  useEffect(() => {
    fetchSolicitudes();
  }, [fetchSolicitudes, page, filtro]);

  const pendientesHoy = solicitudes.filter(
    (s) => s.estado?.toLowerCase() === "por revisar" // Backend uses "Por revisar" typically
  ).length;

  return (
    <>
      <TopBar />

      <div className="contenedor">
        <h1>Gestión de Solicitudes</h1>

        <div className="header-actions">
          <div className="contador-pendientes">
            {loading ? (
              <span>Cargando...</span>
            ) : (
              <span>Tienes <strong>{pendientesHoy} solicitudes</strong> pendientes en esta vista</span>
            )}
          </div>
        </div>

        <SolicitudesFilters 
          filtro={filtro} 
          setFiltro={(newFiltro) => {
            setFiltro(newFiltro);
            setPage(1); // Reset page on filter change
          }} 
        />

        {/* Wrapper que crece para ocupar espacio vertical */}
        <div className="tabla-wrapper">
          {loading ? (
            <div className="loading-state">Cargando solicitudes...</div>
          ) : error ? (
            <div className="error-state">{error}</div>
          ) : (
            <SolicitudesTable solicitudes={solicitudes} />
          )}
        </div>

        {/* Paginación */}
        <div className="paginacion">
          <div>
            Página {page} de {totalPages}
          </div>
          <div className="pag-botones">
            <button 
              disabled={page === 1} 
              onClick={() => setPage(p => Math.max(1, p - 1))}
            >
              ←
            </button>
            <button className="active">{page}</button>
            <button 
              disabled={page >= totalPages} 
              onClick={() => setPage(p => p + 1)}
            >
              →
            </button>
          </div>
        </div>
      </div>
    </>
  );
};

export default Solicitudes;