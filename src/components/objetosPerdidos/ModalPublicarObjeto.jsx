import { useState } from 'react';
import { FaTimes, FaCloudUploadAlt, FaSave } from 'react-icons/fa';

export default function ModalPublicarObjeto({ onClose, onPublicar }) {
  const [formData, setFormData] = useState({
    titulo: '',
    descripcion: '',
    estado: 'encontrado',
    lugar_encontrado: '',
    file: null,
    imagenPreview: ''
  });

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleImage = (e) => {
    const file = e.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setFormData(prev => ({
          ...prev,
          file: file,
          imagenPreview: reader.result
        }));
      };
      reader.readAsDataURL(file);
    }
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!formData.titulo.trim() || !formData.descripcion.trim()) {
      alert("Título y descripción son obligatorios");
      return;
    }
    onPublicar(formData);
  };

  return (
    <div className="modal-overlay" style={{
      position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
      backgroundColor: 'rgba(0,0,0,0.6)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 1000,
      backdropFilter: 'blur(5px)'
    }} onClick={onClose}>
      <div className="modal-content" style={{
        backgroundColor: 'white', borderRadius: '20px', width: '90%', maxWidth: '850px',
        boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)', overflow: 'hidden', animation: 'fadeIn 0.3s ease-out',
        border: '1px solid rgba(0,0,0,0.05)', display: 'flex', flexDirection: 'column', maxHeight: '90vh'
      }} onClick={e => e.stopPropagation()}>
        
        {/* Header - Premium Minimalist */}
        <div style={{
          padding: '24px 30px', 
          borderBottom: '1px solid #f3f4f6', 
          display: 'flex', 
          justifyContent: 'space-between', 
          alignItems: 'center',
          background: '#fff'
        }}>
          <div>
              <span style={{ 
                  display: 'block', 
                  fontSize: '0.8rem', 
                  color: '#8b0038', 
                  fontWeight: 'bold', 
                  textTransform: 'uppercase', 
                  letterSpacing: '1px',
                  marginBottom: '4px'
              }}>Nueva Publicación</span>
              <h2 style={{ margin: 0, color: '#111', fontSize: '1.5rem', fontWeight: '800', letterSpacing: '-0.5px' }}>Objeto Perdido</h2>
          </div>
          <button onClick={onClose} style={{ 
            background: '#f9fafb', border: 'none', cursor: 'pointer', color: '#9ca3af', fontSize: '1.2rem', 
            padding: '10px', borderRadius: '50%', transition: 'all 0.2s', display: 'flex', alignItems: 'center', justifyContent: 'center' 
          }}
            onMouseOver={e => { e.currentTarget.style.backgroundColor = '#f3f4f6'; e.currentTarget.style.color = '#374151'; }}
            onMouseOut={e => { e.currentTarget.style.backgroundColor = '#f9fafb'; e.currentTarget.style.color = '#9ca3af'; }}>
            <FaTimes />
          </button>
        </div>

        <form onSubmit={handleSubmit} style={{ padding: '0', display: 'flex', flexDirection: 'column', flex: 1, overflow: 'hidden' }}>
          
          <div style={{ padding: '30px', overflowY: 'auto', flex: 1 }}>
              <div style={{ display: 'grid', gridTemplateColumns: '1.2fr 0.8fr', gap: '30px' }}>
                  
                  {/* Columna Izquierda: Datos */}
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
                      <div>
                        <label style={{ display: 'block', marginBottom: '8px', fontWeight: '700', color: '#374151', fontSize: '0.9rem' }}>Título del objeto *</label>
                        <input 
                            type="text" 
                            name="titulo" 
                            value={formData.titulo} 
                            onChange={handleChange} 
                            required 
                            placeholder="Ej. Botella azul de agua"
                            style={{ 
                                width: '100%', padding: '14px 16px', borderRadius: '12px', border: '1px solid #e5e7eb', fontSize: '1rem', outline: 'none', 
                                boxSizing: 'border-box', transition: 'all 0.2s', backgroundColor: '#f9fafb' 
                            }}
                            onFocus={e => { e.target.style.borderColor = '#8b0038'; e.target.style.backgroundColor = '#fff'; e.target.style.boxShadow = '0 0 0 4px rgba(139, 0, 56, 0.1)'; }}
                            onBlur={e => { e.target.style.borderColor = '#e5e7eb'; e.target.style.backgroundColor = '#f9fafb'; e.target.style.boxShadow = 'none'; }}
                        />
                      </div>

                      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px' }}>
                        <div>
                            <label style={{ display: 'block', marginBottom: '8px', fontWeight: '700', color: '#374151', fontSize: '0.9rem' }}>Ubicación</label>
                            <input 
                                type="text" 
                                name="lugar_encontrado" 
                                value={formData.lugar_encontrado} 
                                onChange={handleChange} 
                                placeholder="Ej. Biblioteca"
                                style={{ 
                                    width: '100%', padding: '14px 16px', borderRadius: '12px', border: '1px solid #e5e7eb', fontSize: '1rem', outline: 'none', 
                                    boxSizing: 'border-box', transition: 'all 0.2s', backgroundColor: '#f9fafb'
                                }}
                                onFocus={e => { e.target.style.borderColor = '#8b0038'; e.target.style.backgroundColor = '#fff'; e.target.style.boxShadow = '0 0 0 4px rgba(139, 0, 56, 0.1)'; }}
                                onBlur={e => { e.target.style.borderColor = '#e5e7eb'; e.target.style.backgroundColor = '#f9fafb'; e.target.style.boxShadow = 'none'; }}
                            />
                        </div>
                        <div>
                            <label style={{ display: 'block', marginBottom: '8px', fontWeight: '700', color: '#374151', fontSize: '0.9rem' }}>Estado</label>
                            <div style={{ position: 'relative' }}>
                                <select 
                                    name="estado" 
                                    value={formData.estado} 
                                    onChange={handleChange}
                                    style={{ 
                                        width: '100%', padding: '14px 16px', borderRadius: '12px', border: '1px solid #e5e7eb', fontSize: '1rem', outline: 'none', 
                                        boxSizing: 'border-box', backgroundColor: '#f9fafb', cursor: 'pointer', appearance: 'none'
                                    }}
                                >
                                <option value="encontrado">Encontrado</option>
                                <option value="perdido">Perdido</option>
                                <option value="devuelto">Devuelto</option>
                                </select>
                                <div style={{ position: 'absolute', right: '16px', top: '50%', transform: 'translateY(-50%)', pointerEvents: 'none', color: '#6b7280', fontSize: '0.8rem' }}>▼</div>
                            </div>
                        </div>
                      </div>

                      <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
                        <label style={{ display: 'block', marginBottom: '8px', fontWeight: '700', color: '#374151', fontSize: '0.9rem' }}>Descripción detallada *</label>
                        <textarea 
                            name="descripcion" 
                            value={formData.descripcion} 
                            onChange={handleChange} 
                            required 
                            placeholder="Detalles adicionales del objeto, color, marca, condición..."
                            style={{ 
                                width: '100%', padding: '14px 16px', borderRadius: '12px', border: '1px solid #e5e7eb', fontSize: '1rem', outline: 'none', resize: 'none', 
                                boxSizing: 'border-box', minHeight: '120px', transition: 'all 0.2s', backgroundColor: '#f9fafb', fontFamily: 'inherit', flex: 1
                            }}
                            onFocus={e => { e.target.style.borderColor = '#8b0038'; e.target.style.backgroundColor = '#fff'; e.target.style.boxShadow = '0 0 0 4px rgba(139, 0, 56, 0.1)'; }}
                            onBlur={e => { e.target.style.borderColor = '#e5e7eb'; e.target.style.backgroundColor = '#f9fafb'; e.target.style.boxShadow = 'none'; }}
                        />
                      </div>
                  </div>

                  {/* Columna Derecha: Foto */}
                  <div style={{ display: 'flex', flexDirection: 'column' }}>
                        <label style={{ display: 'block', marginBottom: '8px', fontWeight: '700', color: '#374151', fontSize: '0.9rem' }}>Evidencia Fotográfica</label>
                        <div 
                            style={{ 
                                border: '2px dashed #e5e7eb', borderRadius: '16px', padding: '0', textAlign: 'center', cursor: 'pointer', backgroundColor: '#f9fafb', 
                                transition: 'all 0.2s', position: 'relative', overflow: 'hidden', flex: 1, minHeight: '200px',
                                display: 'flex', alignItems: 'center', justifyContent: 'center'
                            }}
                            onMouseOver={e => { e.currentTarget.style.borderColor = '#8b0038'; e.currentTarget.style.backgroundColor = '#fff'; }}
                            onMouseOut={e => { e.currentTarget.style.borderColor = '#e5e7eb'; e.currentTarget.style.backgroundColor = '#f9fafb'; }}
                        >
                        <input 
                            type="file" 
                            accept="image/*" 
                            onChange={handleImage} 
                            style={{ position: 'absolute', top: 0, left: 0, width: '100%', height: '100%', opacity: 0, cursor: 'pointer', zIndex: 10 }}
                        />
                        {formData.imagenPreview ? (
                            <div style={{ position: 'relative', width: '100%', height: '100%' }}>
                                <img src={formData.imagenPreview} alt="Preview" style={{ width: '100%', height: '100%', objectFit: 'cover', display: 'block' }} />
                                <div style={{ position: 'absolute', bottom: 0, left: 0, right: 0, background: 'linear-gradient(to top, rgba(0,0,0,0.7), transparent)', color: 'white', padding: '15px', fontSize: '0.9rem', fontWeight: '500' }}>Clic para cambiar imagen</div>
                            </div>
                        ) : (
                            <div style={{ color: '#9ca3af', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
                            <div style={{ width: '60px', height: '60px', borderRadius: '50%', background: '#f3f4f6', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '15px' }}>
                                <FaCloudUploadAlt size={28} style={{ color: '#6b7280' }} />
                            </div>
                            <p style={{ margin: 0, fontWeight: '600', color: '#4b5563', fontSize: '1rem' }}>Subir foto</p>
                            <small style={{ color: '#9ca3af', fontSize: '0.85rem' }}>JPG, PNG máx 5MB</small>
                            </div>
                        )}
                        </div>
                  </div>
              </div>
          </div>

          <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', padding: '24px 30px', borderTop: '1px solid #f3f4f6', backgroundColor: '#fff' }}>
            <button type="button" onClick={onClose} style={{ 
                padding: '12px 24px', borderRadius: '12px', border: '1px solid #e5e7eb', background: 'white', color: '#4b5563', cursor: 'pointer', fontWeight: '600', fontSize: '0.95rem',
                transition: 'all 0.2s' // Removed uppercase
            }}
            onMouseOver={e => { e.currentTarget.style.backgroundColor = '#f9fafb'; e.currentTarget.style.borderColor = '#d1d5db'; }}
            onMouseOut={e => { e.currentTarget.style.backgroundColor = 'white'; e.currentTarget.style.borderColor = '#e5e7eb'; }}>
                Cancelar
            </button>
            <button type="submit" style={{ 
                padding: '12px 28px', borderRadius: '12px', border: 'none', 
                background: '#8b0038', // Solid primary
                color: 'white', cursor: 'pointer', fontWeight: '600', fontSize: '0.95rem', display: 'flex', alignItems: 'center', gap: '8px', 
                boxShadow: '0 4px 6px rgba(139, 0, 56, 0.2)', transition: 'all 0.2s' // Removed uppercase
            }}
            onMouseOver={e => { e.currentTarget.style.backgroundColor = '#6f002c'; e.currentTarget.style.transform = 'translateY(-1px)'; }}
            onMouseOut={e => { e.currentTarget.style.backgroundColor = '#8b0038'; e.currentTarget.style.transform = 'translateY(0)'; }}>
                <FaSave /> Publicar Objeto
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}