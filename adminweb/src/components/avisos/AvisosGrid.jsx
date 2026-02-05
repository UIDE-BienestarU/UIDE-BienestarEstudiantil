import AvisoCard from './AvisoCard';

export default function AvisosGrid({ avisos, onEdit, onDelete, onMore }) {
  return (
    <div className="avisos-grid">
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