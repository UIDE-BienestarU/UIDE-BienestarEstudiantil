const SolicitudesFilters = ({ filtro, setFiltro }) => {
  return (
    <div className="filtros" style={{ display: 'flex', gap: '10px', padding: '10px 0', overflowX: 'auto' }}>
      <button
        className={filtro === "todos" ? "activo" : ""}
        onClick={() => setFiltro("todos")}
        style={{ borderRadius: '20px', padding: '8px 20px', border: '1px solid #ddd', background: filtro === "todos" ? '#8b0038' : '#fff', color: filtro === "todos" ? '#fff' : '#555', cursor: 'pointer', transition: 'all 0.2s', fontWeight: '500' }}
      >
        Todos
      </button>

      <button
        className={filtro === "Por revisar" ? "activo" : ""}
        onClick={() => setFiltro("Por revisar")}
        style={{ borderRadius: '20px', padding: '8px 20px', border: '1px solid #ddd', background: filtro === "Por revisar" ? '#8b0038' : '#fff', color: filtro === "Por revisar" ? '#fff' : '#555', cursor: 'pointer', transition: 'all 0.2s', fontWeight: '500' }}
      >
        <span className="dot pendiente" style={{ display: 'inline-block', width: '8px', height: '8px', borderRadius: '50%', backgroundColor: filtro === "Por revisar" ? '#fff' : 'orange', marginRight: '6px' }}></span>
        Por revisar
      </button>

      <button
        className={filtro === "En progreso" ? "activo" : ""}
        onClick={() => setFiltro("En progreso")}
        style={{ borderRadius: '20px', padding: '8px 20px', border: '1px solid #ddd', background: filtro === "En progreso" ? '#8b0038' : '#fff', color: filtro === "En progreso" ? '#fff' : '#555', cursor: 'pointer', transition: 'all 0.2s', fontWeight: '500' }}
      >
        <span className="dot enProgreso" style={{ display: 'inline-block', width: '8px', height: '8px', borderRadius: '50%', backgroundColor: filtro === "En progreso" ? '#fff' : 'blue', marginRight: '6px' }}></span>
        En progreso
      </button>

      <button
        className={filtro === "Aprobada" ? "activo" : ""}
        onClick={() => setFiltro("Aprobada")}
        style={{ borderRadius: '20px', padding: '8px 20px', border: '1px solid #ddd', background: filtro === "Aprobada" ? '#8b0038' : '#fff', color: filtro === "Aprobada" ? '#fff' : '#555', cursor: 'pointer', transition: 'all 0.2s', fontWeight: '500' }}
      >
        <span className="dot aprobado" style={{ display: 'inline-block', width: '8px', height: '8px', borderRadius: '50%', backgroundColor: filtro === "Aprobada" ? '#fff' : 'green', marginRight: '6px' }}></span>
        Aprobados
      </button>
    </div>
  );
};

export default SolicitudesFilters;