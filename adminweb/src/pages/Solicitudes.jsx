import { useState } from "react";
import solicitudesMock from "../mock/solicitudesMock";
import SolicitudesTable from "../components/solicitudes/SolicitudesTable";
import SolicitudesFilters from "../components/solicitudes/SolicitudesFilters";
import TopBar from "../components/layout/TopBar";

const Solicitudes = () => {
  const [filtro, setFiltro] = useState("todos");
  const [solicitudes] = useState(solicitudesMock ?? []);

  const pendientesHoy = solicitudes.filter(
    (s) => s.estado.toLowerCase() === "pendiente"
  ).length;

  const solicitudesFiltradas =
    filtro === "todos"
      ? solicitudes
      : solicitudes.filter((s) => s.estado.toLowerCase() === filtro);

  return (
    <>
      <TopBar />

      <div className="contenedor">
        <h1>Gestión de Solicitudes</h1>

        <div className="header-actions">
          <div className="contador-pendientes">
            Tienes <strong>{pendientesHoy} solicitudes</strong> pendientes de
            revisión hoy
          </div>
          <div className="botones-accion">
            <button className="btn-export">↓ Exportar CSV</button>
          </div>
        </div>

        <SolicitudesFilters filtro={filtro} setFiltro={setFiltro} />

        {/* Wrapper que crece para ocupar espacio vertical */}
        <div className="tabla-wrapper">
          <SolicitudesTable solicitudes={solicitudesFiltradas} />
        </div>

        {/* Paginación al final */}
        <div className="paginacion">
          <div>
            Mostrando 1-3 de {solicitudes.length} resultados
          </div>
          <div className="pag-botones">
            <button className="active">1</button>
            <button>2</button>
            <button>3</button>
            <button>→</button>
          </div>
        </div>
      </div>
    </>
  );
};

export default Solicitudes;