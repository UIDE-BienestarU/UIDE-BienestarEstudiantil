const SolicitudesFilters = ({ filtro, setFiltro }) => {
  return (
    <div className="filtros">
      <button
        className={filtro === "todos" ? "activo" : ""}
        onClick={() => setFiltro("todos")}
      >
        <span className="dot todos"></span> Todos
      </button>

      <button
        className={filtro === "pendiente" ? "activo" : ""}
        onClick={() => setFiltro("pendiente")}
      >
        <span className="dot pendiente"></span> Pendientes
      </button>

      <button
        className={filtro === "aprobado" ? "activo" : ""}
        onClick={() => setFiltro("aprobado")}
      >
        <span className="dot aprobado"></span> Aprobados
      </button>

      <button
        className={filtro === "en progreso" ? "activo" : ""}
        onClick={() => setFiltro("en progreso")}
      >
        <span className="dot enProgreso"></span> En progreso
      </button>
    </div>
  );
};

export default SolicitudesFilters;