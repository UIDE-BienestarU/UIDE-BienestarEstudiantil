import ObjetosCard from './ObjetosCard';

export default function ObjetosGrid({ objetos = [], onVerDetalles, onEntregar }) {
  // Si objetos es undefined o null, usamos array vacío por defecto
  const objetosSeguros = Array.isArray(objetos) ? objetos : [];

  return (
    <div className="objetos-grid">
      {objetosSeguros.length > 0 ? (
        objetosSeguros.map((objeto) => (
          <ObjetosCard
            key={objeto.id}
            objeto={objeto}
            onVerDetalles={onVerDetalles}
            onEntregar={onEntregar}
          />
        ))
      ) : (
        <div className="no-resultados">
          No hay objetos para mostrar
        </div>
      )}
    </div>
  );
}