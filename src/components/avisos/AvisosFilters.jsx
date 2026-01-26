export default function AvisosFilter({ value, onChange }) {
  const categorias = [
    { label: 'All News', value: '' },
    { label: 'Academic', value: 'ACADÉMICO' },
    { label: 'Sports', value: 'DEPORTES' },
    { label: 'Culture', value: 'CULTURA' },
    { label: 'Salud', value: 'SALUD' }
  ];

  return (
    <div className="avisos-tabs">
      {categorias.map((cat) => (
        <button
          key={cat.value}
          className={`tab-btn ${value === cat.value ? 'active' : ''}`}
          onClick={() => onChange(cat.value)}
        >
          {cat.label}
        </button>
      ))}
    </div>
  );
}