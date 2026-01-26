import { useState } from 'react';

export default function ModalPublicarObjeto({ onClose, onPublicar }) {
  const [formData, setFormData] = useState({
    nombre: '',
    descripcion: '',
    estado: 'POR RECLAMAR',
    ubicacion: '',
    imagenPreview: '',
    imagenBase64: ''
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
          imagenPreview: reader.result,
          imagenBase64: reader.result
        }));
      };
      reader.readAsDataURL(file);
    }
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!formData.nombre.trim() || !formData.descripcion.trim()) {
      alert("Nombre y descripción son obligatorios");
      return;
    }

    const nuevo = {
      id: Date.now(),
      ...formData,
      fecha: `Encontrado ${new Date().toLocaleDateString('es-EC', { day: 'numeric', month: 'short' })} 2025`,
      codigo: `#${Math.floor(Math.random() * 1000).toString().padStart(3, '0')}-${Math.floor(Math.random() * 1000)}`,
      imagen: formData.imagenBase64 || null,
    };

    onPublicar(nuevo);
    onClose();
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={e => e.stopPropagation()}>
        <h2 className="modal-title">Publicar Objeto Perdido</h2>
        <button className="modal-close-btn" onClick={onClose}>×</button>

        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>Nombre del objeto *</label>
            <input type="text" name="nombre" value={formData.nombre} onChange={handleChange} required />
          </div>

          <div className="form-group">
            <label>Descripción *</label>
            <textarea name="descripcion" value={formData.descripcion} onChange={handleChange} required rows={4} />
          </div>

          <div className="form-group">
            <label>Ubicación donde se encontró</label>
            <input type="text" name="ubicacion" value={formData.ubicacion} onChange={handleChange} />
          </div>

          <div className="form-group">
            <label>Estado inicial</label>
            <select name="estado" value={formData.estado} onChange={handleChange}>
              <option value="POR RECLAMAR">Por reclamar</option>
              <option value="VERIFICADO">Verificado</option>
              <option value="EN BODEGA">En bodega</option>
            </select>
          </div>

          <div className="form-group">
            <label>Foto del objeto </label>
            <div className="image-upload-area">
              <input type="file" accept="image/*" onChange={handleImage} className="file-input" />
              {formData.imagenPreview ? (
                <img src={formData.imagenPreview} alt="Preview" className="image-preview" />
              ) : (
                <div className="upload-placeholder">
                  <span>Haz clic para subir foto</span>
                  <small>JPG, PNG - máx 5MB</small>
                </div>
              )}
            </div>
          </div>

          <div className="modal-actions">
            <button type="button" className="btn-cancelar" onClick={onClose}>Cancelar</button>
            <button type="submit" className="btn-guardar">Publicar</button>
          </div>
        </form>
      </div>
    </div>
  );
}