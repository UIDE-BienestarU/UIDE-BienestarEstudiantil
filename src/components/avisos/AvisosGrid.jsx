import AvisoCard from './AvisoCard';

export default function AvisosGrid({ avisos, onEdit, onDelete, onMore }) {
  return (
    <div className="avisos-grid" style={{
      display: 'grid',
      gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))',
      gap: '30px',
      padding: '20px 0'
    }}>
      {avisos.map((aviso) => (
        <AvisoCard 
          key={aviso.id} 
          aviso={aviso}
          onEdit={() => onEdit(aviso)}
          onDelete={() => onDelete(aviso.id)}
          onMore={() => onMore(aviso)}
        />
      ))}
    </div>
  );
}