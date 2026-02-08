import { useState, useEffect } from 'react';
import { FaTimes, FaCloudUploadAlt, FaSave } from 'react-icons/fa';

export default function ModalNuevoAviso({ avisoInicial, onClose, onSave }) {
  const [formData, setFormData] = useState({
    titulo: '',
    contenido: '',
    imagenPreview: '',
  });
  const [file, setFile] = useState(null);

  useEffect(() => {
    if (avisoInicial) {
      setFormData({
        titulo: avisoInicial.titulo || '',
        contenido: avisoInicial.contenido || avisoInicial.descripcion || '',
        imagenPreview: avisoInicial.imagen || '',
      });
      setFile(null);
    } else {
      setFormData({
        titulo: '',
        contenido: '',
        imagenPreview: '',
      });
      setFile(null);
    }
  }, [avisoInicial]);

  const handleTextChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleImageChange = (e) => {
    const selectedFile = e.target.files[0];
    if (selectedFile) {
      setFile(selectedFile);
      const reader = new FileReader();
      reader.onloadend = () => {
        setFormData(prev => ({
          ...prev,
          imagenPreview: reader.result
        }));
      };
      reader.readAsDataURL(selectedFile);
    }
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!formData.titulo.trim() || !formData.contenido.trim()) {
      alert("El título y el contenido son obligatorios");
      return;
    }
    onSave({ ...formData, file });
    onClose();
  };

  const isEditMode = !!avisoInicial;

  return (
    <div className="modal-overlay" onClick={onClose} style={{
      position: 'fixed',
      top: 0, left: 0, right: 0, bottom: 0,
      backgroundColor: 'rgba(0,0,0,0.6)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      zIndex: 1000,
      backdropFilter: 'blur(5px)'
    }}>
      <div className="modal-content" onClick={e => e.stopPropagation()} style={{
        backgroundColor: '#fff',
        borderRadius: '20px',
        width: '90%',
        maxWidth: '850px',
        boxShadow: '0 25px 50px rgba(0,0,0,0.25)',
        overflow: 'hidden',
        animation: 'slideUp 0.3s ease-out',
        border: '1px solid rgba(0,0,0,0.05)',
        display: 'flex',
        flexDirection: 'column',
        maxHeight: '90vh'
      }}>
        {/* Header Premium Minimalist */}
        <div className="modal-header" style={{
          padding: '24px 30px',
          borderBottom: '1px solid #f3f4f6',
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          backgroundColor: '#fff',
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
              }}>{isEditMode ? "Editar Publicación" : "Nueva Publicación"}</span>
              <h2 style={{ 
                  margin: 0, 
                  color: '#111', 
                  fontSize: '1.5rem', 
                  fontWeight: '800', 
                  letterSpacing: '-0.5px' 
              }}>
                {isEditMode ? "Modificar Aviso" : "Crear Aviso / Noticia"}
              </h2>
           </div>

          <button onClick={onClose} style={{
            background: '#f9fafb',
            border: 'none',
            color: '#9ca3af',
            fontSize: '1.2rem',
            cursor: 'pointer',
            padding: '10px',
            borderRadius: '50%',
            transition: 'all 0.2s',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center'
          }}
          onMouseOver={e => { e.currentTarget.style.backgroundColor = '#f3f4f6'; e.currentTarget.style.color = '#374151'; }}
          onMouseOut={e => { e.currentTarget.style.backgroundColor = '#f9fafb'; e.currentTarget.style.color = '#9ca3af'; }}
          ><FaTimes /></button>
        </div>

        <form onSubmit={handleSubmit} style={{ padding: '0', display: 'flex', flexDirection: 'column', flex: 1, overflow: 'hidden' }}>
          <div style={{ padding: '30px', overflowY: 'auto', flex: 1 }}>
            
            <div style={{ display: 'grid', gridTemplateColumns: '1.2fr 0.8fr', gap: '30px', height: '100%' }}>
                {/* Column 1: Form Inputs */}
                <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
                    
                    <div className="form-group">
                        <label style={{ display: 'block', marginBottom: '8px', fontWeight: '700', color: '#374151', fontSize: '0.9rem' }}>Título del Aviso *</label>
                        <input
                        type="text"
                        name="titulo"
                        value={formData.titulo}
                        onChange={handleTextChange}
                        required
                        placeholder="Ej: Convocatoria Becas 2025"
                        style={{
                            width: '100%',
                            padding: '14px 16px',
                            borderRadius: '12px',
                            border: '1px solid #e5e7eb',
                            fontSize: '1rem',
                            outline: 'none',
                            transition: 'all 0.2s',
                            backgroundColor: '#f9fafb',
                            boxSizing: 'border-box'
                        }}
                        onFocus={(e) => { e.target.style.borderColor = '#8b0038'; e.target.style.backgroundColor = '#fff'; e.target.style.boxShadow = '0 0 0 4px rgba(139, 0, 56, 0.1)'; }}
                        onBlur={(e) => { e.target.style.borderColor = '#e5e7eb'; e.target.style.backgroundColor = '#f9fafb'; e.target.style.boxShadow = 'none'; }}
                        />
                    </div>

                    <div className="form-group" style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
                        <label style={{ display: 'block', marginBottom: '8px', fontWeight: '700', color: '#374151', fontSize: '0.9rem' }}>Contenido / Descripción *</label>
                        <textarea
                        name="contenido"
                        value={formData.contenido}
                        onChange={handleTextChange}
                        required
                        placeholder="Escribe los detalles completos del aviso aquí..."
                        style={{
                            width: '100%',
                            flex: 1,
                            minHeight: '200px',
                            padding: '14px 16px',
                            borderRadius: '12px',
                            border: '1px solid #e5e7eb',
                            fontSize: '0.95rem',
                            outline: 'none',
                            resize: 'none',
                            backgroundColor: '#f9fafb',
                            fontFamily: 'inherit',
                            boxSizing: 'border-box',
                            lineHeight: '1.6'
                        }}
                        onFocus={(e) => { e.target.style.borderColor = '#8b0038'; e.target.style.backgroundColor = '#fff'; e.target.style.boxShadow = '0 0 0 4px rgba(139, 0, 56, 0.1)'; }}
                        onBlur={(e) => { e.target.style.borderColor = '#e5e7eb'; e.target.style.backgroundColor = '#f9fafb'; e.target.style.boxShadow = 'none'; }}
                        />
                    </div>

                </div>

                {/* Column 2: Image Upload */}
                <div style={{ display: 'flex', flexDirection: 'column' }}>
                    <label style={{ display: 'block', marginBottom: '8px', fontWeight: '700', color: '#374151', fontSize: '0.9rem' }}>Imagen Destacada (Opcional)</label>
                    
                    <label style={{
                        flex: 1,
                        display: 'flex',
                        flexDirection: 'column',
                        alignItems: 'center',
                        justifyContent: 'center',
                        padding: '20px',
                        border: '2px dashed #e5e7eb',
                        borderRadius: '16px',
                        cursor: 'pointer',
                        backgroundColor: '#f9fafb',
                        transition: 'all 0.2s',
                        position: 'relative',
                        overflow: 'hidden',
                        minHeight: '250px'
                    }}
                    onMouseOver={(e) => { e.currentTarget.style.borderColor = '#8b0038'; e.currentTarget.style.backgroundColor = '#fff'; }}
                    onMouseOut={(e) => { e.currentTarget.style.borderColor = '#e5e7eb'; e.currentTarget.style.backgroundColor = '#f9fafb'; }}
                    >
                    <input
                        type="file"
                        accept="image/*"
                        onChange={handleImageChange}
                        style={{ display: 'none' }}
                    />
                    
                    {formData.imagenPreview ? (
                        <div style={{ width: '100%', height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'absolute', top: 0, left: 0 }}>
                            <img
                            src={formData.imagenPreview}
                            alt="Vista previa"
                            style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                            />
                            <div style={{
                                position: 'absolute',
                                bottom: '0',
                                left: '0',
                                right: '0',
                                background: 'linear-gradient(to top, rgba(0,0,0,0.8), transparent)',
                                color: 'white',
                                textAlign: 'center',
                                padding: '15px',
                                fontSize: '0.9rem',
                                fontWeight: '500'
                            }}>Click para cambiar imagen</div>
                        </div>
                    ) : (
                        <div style={{ textAlign: 'center', color: '#9ca3af' }}>
                        <div style={{ 
                            width: '60px', height: '60px', borderRadius: '50%', background: '#f3f4f6', 
                            display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 15px' 
                        }}>
                            <FaCloudUploadAlt style={{ fontSize: '28px', color: '#6b7280' }} />
                        </div>
                        <p style={{ margin: '0 0 5px', fontSize: '1rem', fontWeight: '600', color: '#4b5563' }}>Subir imagen</p>
                        <p style={{ margin: 0, fontSize: '0.85rem' }}>Click o arrastra aquí</p>
                        <small style={{ fontSize: '0.75rem', color: '#d1d5db', marginTop: '10px', display: 'block' }}>JPG, PNG máx. 5MB</small>
                        </div>
                    )}
                    </label>
                </div>
            </div>

          </div>

          {/* Footer Actions */}
          <div className="modal-actions" style={{ 
              padding: '24px 30px', 
              borderTop: '1px solid #f3f4f6', 
              display: 'flex', 
              justifyContent: 'flex-end', 
              gap: '12px', 
              backgroundColor: '#fff' 
          }}>
            <button type="button" onClick={onClose} style={{
              padding: '12px 24px',
              borderRadius: '12px', // Standard rounded
              border: '1px solid #e5e7eb',
              backgroundColor: 'white',
              color: '#4b5563',
              fontWeight: '600',
              cursor: 'pointer',
              fontSize: '0.95rem',
              transition: 'all 0.2s'
            }}
            onMouseOver={e => { e.currentTarget.style.backgroundColor = '#f9fafb'; e.currentTarget.style.borderColor = '#d1d5db'; }}
            onMouseOut={e => { e.currentTarget.style.backgroundColor = 'white'; e.currentTarget.style.borderColor = '#e5e7eb'; }}
            >
              Cancelar
            </button>
            <button type="submit" style={{
              padding: '12px 30px',
              borderRadius: '12px', // Standard rounded
              border: 'none',
              background: '#8b0038', // Solid primary
              color: 'white',
              fontWeight: '600',
              cursor: 'pointer',
              fontSize: '0.95rem',
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              boxShadow: '0 4px 6px rgba(139, 0, 56, 0.2)',
              transition: 'all 0.2s'
            }}
            onMouseOver={e => { e.currentTarget.style.backgroundColor = '#6f002c'; e.currentTarget.style.transform = 'translateY(-1px)'; }}
            onMouseOut={e => { e.currentTarget.style.backgroundColor = '#8b0038'; e.currentTarget.style.transform = 'translateY(0)'; }}
            >
              <FaSave /> {isEditMode ? "Guardar Cambios" : "Publicar Aviso"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}