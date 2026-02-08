import { FaEdit, FaTrash, FaCalendarAlt } from 'react-icons/fa';

export default function AvisoCard({ aviso, onEdit, onDelete, onMore }) {
  // Construct image URL properly
  const imageUrl = aviso.imagen 
    ? (aviso.imagen.startsWith('http') ? aviso.imagen : `https://api-prod.uidehub.tech${aviso.imagen.startsWith('/') ? '' : '/'}${aviso.imagen}`)
    : 'https://via.placeholder.com/400x200?text=Aviso+UIDE';

  return (
    <div className="aviso-card" style={{
      backgroundColor: '#fff',
      borderRadius: '16px',
      overflow: 'hidden',
      boxShadow: '0 4px 20px rgba(0,0,0,0.08)',
      display: 'flex',
      flexDirection: 'column',
      transition: 'transform 0.2s, box-shadow 0.2s',
      border: '1px solid #f0f0f0',
      height: '100%',
      position: 'relative'
    }}
    onMouseOver={(e) => {
      e.currentTarget.style.transform = 'translateY(-5px)';
      e.currentTarget.style.boxShadow = '0 10px 25px rgba(0,0,0,0.12)';
    }}
    onMouseOut={(e) => {
      e.currentTarget.style.transform = 'translateY(0)';
      e.currentTarget.style.boxShadow = '0 4px 20px rgba(0,0,0,0.08)';
    }}
    >
      <div className="card-image" style={{ height: '200px', overflow: 'hidden', position: 'relative' }}>
        <img 
          src={imageUrl} 
          alt={aviso.titulo} 
          style={{ width: '100%', height: '100%', objectFit: 'cover' }}
          onError={(e) => e.target.src = 'https://via.placeholder.com/400x200?text=Aviso+UIDE'}
        />
        <div style={{ position: 'absolute', top: '15px', right: '15px' }}>
             <span style={{ 
                 backgroundColor: 'rgba(139, 0, 56, 0.9)', 
                 color: 'white', 
                 padding: '6px 12px', 
                 borderRadius: '30px', 
                 fontSize: '0.75rem', 
                 fontWeight: 'bold',
                 textTransform: 'uppercase',
                 letterSpacing: '0.5px',
                 boxShadow: '0 2px 5px rgba(0,0,0,0.2)'
             }}>
                 Publicado
             </span>
        </div>
      </div>

      <div className="card-content" style={{ padding: '24px', flex: 1, display: 'flex', flexDirection: 'column' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: '#999', fontSize: '0.85rem', marginBottom: '12px', fontWeight: '500' }}>
            <FaCalendarAlt style={{ color: '#8b0038' }} />
            <span>{new Date(aviso.createdAt).toLocaleDateString(undefined, { year: 'numeric', month: 'long', day: 'numeric' })}</span>
        </div>

        <h3 style={{ margin: '0 0 12px 0', fontSize: '1.25rem', color: '#222', lineHeight: '1.4', fontWeight: '700' }}>{aviso.titulo}</h3>
        
        <p style={{ 
            color: '#555', 
            fontSize: '0.95rem', 
            lineHeight: '1.6', 
            flex: 1,
            display: '-webkit-box',
            WebkitLineClamp: 3,
            WebkitBoxOrient: 'vertical',
            overflow: 'hidden',
            margin: '0 0 24px 0'
        }}>
            {aviso.contenido}
        </p>

        <div className="card-actions" style={{ 
            display: 'flex', 
            justifyContent: 'flex-end', 
            gap: '12px', 
            borderTop: '1px solid #f5f5f5', 
            paddingTop: '20px',
            marginTop: 'auto'
        }}>
          <button onClick={onEdit} title="Editar" style={{
              background: '#f8f9fa', border: 'none', color: '#555', cursor: 'pointer', padding: '10px', borderRadius: '50%', fontSize: '1rem', transition: 'all 0.2s', display: 'flex', alignItems: 'center', justifyContent: 'center', width: '40px', height: '40px'
          }} onMouseOver={e => { e.currentTarget.style.backgroundColor = '#e0f2fe'; e.currentTarget.style.color = '#0284c7'; }} onMouseOut={e => { e.currentTarget.style.backgroundColor = '#f8f9fa'; e.currentTarget.style.color = '#555'; }}>
              <FaEdit />
          </button>
          <button onClick={onDelete} title="Eliminar" style={{
              background: '#f8f9fa', border: 'none', color: '#555', cursor: 'pointer', padding: '10px', borderRadius: '50%', fontSize: '1rem', transition: 'all 0.2s', display: 'flex', alignItems: 'center', justifyContent: 'center', width: '40px', height: '40px'
          }} onMouseOver={e => { e.currentTarget.style.backgroundColor = '#fef2f2'; e.currentTarget.style.color = '#dc2626'; }} onMouseOut={e => { e.currentTarget.style.backgroundColor = '#f8f9fa'; e.currentTarget.style.color = '#555'; }}>
              <FaTrash />
          </button>
        </div>
      </div>
    </div>
  );
}