import { useEffect } from 'react';
import { FaExclamationTriangle, FaCheckCircle, FaTimes, FaTrash } from 'react-icons/fa';

export default function ConfirmationModal({ 
  isOpen, 
  onClose, 
  onConfirm, 
  title = "Confirmar acción", 
  message = "¿Estás seguro de continuar?", 
  confirmText = "Confirmar", 
  cancelText = "Cancelar",
  type = "danger" // danger | success | info
}) {
  
  useEffect(() => {
    const handleEsc = (e) => {
      if (e.key === 'Escape') onClose();
    };
    if (isOpen) window.addEventListener('keydown', handleEsc);
    return () => window.removeEventListener('keydown', handleEsc);
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  const isDanger = type === 'danger';
  const iconColor = isDanger ? '#ef4444' : '#10b981'; // red-500 : green-500
  const btnBg = isDanger ? '#ef4444' : '#10b981';
  const icon = isDanger ? <FaExclamationTriangle size={40} color={iconColor} /> : <FaCheckCircle size={40} color={iconColor} />;

  return (
    <div className="modal-overlay" onClick={onClose} style={{
      position: 'fixed',
      top: 0, left: 0, right: 0, bottom: 0,
      backgroundColor: 'rgba(0,0,0,0.5)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      zIndex: 1100, // Higher than other modals
      backdropFilter: 'blur(3px)'
    }}>
      <div className="modal-content" onClick={e => e.stopPropagation()} style={{
        backgroundColor: 'white',
        borderRadius: '16px',
        width: '90%',
        maxWidth: '400px',
        boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
        padding: '30px',
        textAlign: 'center',
        animation: 'popIn 0.2s cubic-bezier(0.175, 0.885, 0.32, 1.275)'
      }}>
        
        <div style={{ marginBottom: '20px', display: 'flex', justifyContent: 'center' }}>
            <div style={{ 
                width: '80px', height: '80px', borderRadius: '50%', 
                backgroundColor: isDanger ? '#fee2e2' : '#d1fae5', 
                display: 'flex', alignItems: 'center', justifyContent: 'center' 
            }}>
                {icon}
            </div>
        </div>

        <h3 style={{ margin: '0 0 10px 0', color: '#111827', fontSize: '1.25rem', fontWeight: '700' }}>
            {title}
        </h3>
        
        <p style={{ margin: '0 0 24px 0', color: '#6b7280', fontSize: '0.95rem', lineHeight: '1.5' }}>
            {message}
        </p>

        <div style={{ display: 'flex', gap: '12px', justifyContent: 'center' }}>
            {cancelText && (
              <button onClick={onClose} style={{
                  flex: 1,
                  padding: '12px 20px',
                  borderRadius: '10px',
                  border: '1px solid #e5e7eb',
                  backgroundColor: 'white',
                  color: '#374151',
                  fontWeight: '600',
                  cursor: 'pointer',
                  fontSize: '0.95rem',
                  transition: 'all 0.2s'
              }}
              onMouseOver={e => e.currentTarget.style.backgroundColor = '#f9fafb'}
              onMouseOut={e => e.currentTarget.style.backgroundColor = 'white'}
              >
                  {cancelText}
              </button>
            )}
            <button onClick={onConfirm} style={{
                flex: 1,
                padding: '12px 20px',
                borderRadius: '10px',
                border: 'none',
                backgroundColor: btnBg,
                color: 'white',
                fontWeight: '600',
                cursor: 'pointer',
                fontSize: '0.95rem',
                boxShadow: `0 4px 12px ${isDanger ? 'rgba(239, 68, 68, 0.3)' : 'rgba(16, 185, 129, 0.3)'}`,
                transition: 'all 0.2s',
                display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px'
            }}
            onMouseOver={e => {
                e.currentTarget.style.transform = 'translateY(-1px)';
                e.currentTarget.style.boxShadow = `0 6px 16px ${isDanger ? 'rgba(239, 68, 68, 0.4)' : 'rgba(16, 185, 129, 0.4)'}`;
            }}
            onMouseOut={e => {
                e.currentTarget.style.transform = 'translateY(0)';
                e.currentTarget.style.boxShadow = `0 4px 12px ${isDanger ? 'rgba(239, 68, 68, 0.3)' : 'rgba(16, 185, 129, 0.3)'}`;
            }}
            >
                {isDanger && <FaTrash size={14} />} {(!isDanger && type!=='info') && <FaCheckCircle size={14} />} {confirmText}
            </button>
        </div>

      </div>
      <style>{`
        @keyframes popIn {
          0% { opacity: 0; transform: scale(0.9); }
          100% { opacity: 1; transform: scale(1); }
        }
      `}</style>
    </div>
  );
}
