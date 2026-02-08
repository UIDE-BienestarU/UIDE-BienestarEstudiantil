import ObjetosCard from './ObjetosCard';

export default function ObjetosGrid({ objetos = [], onVerDetalles, onEntregar, onEliminar }) {
  // Si objetos es undefined o null, usamos array vacío por defecto
  const objetosSeguros = Array.isArray(objetos) ? objetos : [];

  return (
    <div className="objetos-grid" style={{
      display: 'grid',
      gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))',
      gap: '30px',
      padding: '20px 0'
    }}>
      {objetosSeguros.length > 0 ? (
        objetosSeguros.map((objeto) => (
          <ObjetosCard
            key={objeto.id}
            objeto={objeto}
            onVerDetalles={onVerDetalles}
            onEntregar={onEntregar}
            onEliminar={onEliminar}
          />
        ))
      ) : (
        <div className="no-resultados" style={{ gridColumn: '1 / -1', textAlign: 'center', padding: '40px', color: '#666', fontSize: '1.1rem' }}>
          No hay objetos para mostrar
        </div>
      )}
    </div>
  );
}