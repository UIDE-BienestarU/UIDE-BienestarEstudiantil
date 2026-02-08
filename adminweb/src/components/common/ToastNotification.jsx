import { useEffect, useState } from 'react';
import { FaCheckCircle, FaExclamationCircle, FaInfoCircle, FaTimes } from 'react-icons/fa';

export default function ToastNotification({ message, type = 'success', onClose, duration = 3000 }) {
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    setIsVisible(true);
    const timer = setTimeout(() => {
      setIsVisible(false);
      setTimeout(onClose, 300); // Wait for exit animation
    }, duration);

    return () => clearTimeout(timer);
  }, [duration, onClose]);

  const getIcon = () => {
    switch (type) {
      case 'success': return <FaCheckCircle size={20} color="#10b981" />;
      case 'error': return <FaExclamationCircle size={20} color="#ef4444" />;
      case 'info': return <FaInfoCircle size={20} color="#3b82f6" />;
      default: return <FaCheckCircle size={20} color="#10b981" />;
    }
  };

  const getBorderColor = () => {
    switch (type) {
        case 'success': return '#10b981';
        case 'error': return '#ef4444';
        case 'info': return '#3b82f6';
        default: return '#10b981';
    }
  };

  if (!message) return null;

  return (
    <>
      <div style={{
        position: 'fixed',
        top: '24px',
        right: '24px',
        backgroundColor: 'white',
        borderRadius: '12px',
        boxShadow: '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)',
        padding: '16px 20px',
        display: 'flex',
        alignItems: 'center',
        gap: '12px',
        zIndex: 2000,
        minWidth: '300px',
        maxWidth: '400px',
        borderLeft: `4px solid ${getBorderColor()}`,
        transform: isVisible ? 'translateX(0)' : 'translateX(120%)',
        opacity: isVisible ? 1 : 0,
        transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
        overflow: 'hidden'
      }}>
        <div style={{ flexShrink: 0 }}>
            {getIcon()}
        </div>
        
        <div style={{ flex: 1 }}>
            <p style={{ margin: 0, color: '#1f2937', fontWeight: '500', fontSize: '0.95rem' }}>
                {message}
            </p>
        </div>

        <button 
            onClick={() => {
                setIsVisible(false);
                setTimeout(onClose, 300);
            }}
            style={{
                background: 'transparent',
                border: 'none',
                color: '#9ca3af',
                cursor: 'pointer',
                padding: '4px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                borderRadius: '50%',
                transition: 'background-color 0.2s'
            }}
            onMouseOver={e => { e.currentTarget.style.backgroundColor = '#f3f4f6'; e.currentTarget.style.color = '#4b5563'; }}
            onMouseOut={e => { e.currentTarget.style.backgroundColor = 'transparent'; e.currentTarget.style.color = '#9ca3af'; }}
        >
            <FaTimes size={14} />
        </button>
      </div>
    </>
  );
}
