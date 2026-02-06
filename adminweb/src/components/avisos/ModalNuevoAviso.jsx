// src/components/avisos/ModalNuevoAviso.jsx
import { useState, useEffect } from 'react';

export default function ModalNuevoAviso({ avisoInicial, onClose, onSave }) {
  const [formData, setFormData] = useState({
    titulo: '',
    descripcion: '',
    tipo: 'INSTITUCIÓN',
    estado: 'BORRADOR',
    imagenPreview: '',
    imagenBase64: ''
  });

  // Cargar datos cuando cambia avisoInicial (nuevo o edición)
  useEffect(() => {
    if (avisoInicial) {
      console.log('Cargando aviso para editar:', avisoInicial); // ← para depurar
      setFormData({
        titulo: avisoInicial.titulo || '',
        descripcion: avisoInicial.descripcion || '',
        tipo: avisoInicial.tipo || 'INSTITUCIÓN',
        estado: avisoInicial.estado || 'BORRADOR',
        imagenPreview: avisoInicial.imagen || '',
        imagenBase64: avisoInicial.imagen || ''
      });
    } else {
      console.log('Modal en modo NUEVO'); // ← depuración
      setFormData({
        titulo: '',
        descripcion: '',
        tipo: 'INSTITUCIÓN',
        estado: 'BORRADOR',
        imagenPreview: '',
        imagenBase64: ''
      });
    }
  }, [avisoInicial]);  // Dependencia crítica: se ejecuta cada vez que avisoInicial cambia

  const handleTextChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleImageChange = (e) => {
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
    if (!formData.titulo.trim() || !formData.descripcion.trim()) {
      alert("El título y la descripción son obligatorios");
      return;
    }

    onSave(formData); // Enviamos todo el formData
    onClose();
  };

  const isEditMode = !!avisoInicial;

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={e => e.stopPropagation()}>
        <h2 className="modal-title">
          {isEditMode ? "Editar Aviso" : "Crear Nuevo Aviso"}
        </h2>
        <button className="modal-close-btn" onClick={onClose}>×</button>

        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>Título *</label>
            <input
              type="text"
              name="titulo"
              value={formData.titulo}
              onChange={handleTextChange}
              required
              placeholder="Ej: Convocatoria Becas 2025"
            />
          </div>

          <div className="form-group">
            <label>Descripción *</label>
            <textarea
              name="descripcion"
              value={formData.descripcion}
              onChange={handleTextChange}
              required
              rows={5}
              placeholder="Escribe los detalles del aviso aquí..."
            />
          </div>

          <div className="form-row">
            <div className="form-group half">
              <label>Tipo</label>
              <select name="tipo" value={formData.tipo} onChange={handleTextChange}>
                <option value="INSTITUCIÓN">Institución</option>
                <option value="DEPORTES">Deportes</option>
                <option value="CULTURA">Cultura</option>
                <option value="SALUD">Salud</option>
                <option value="ACADÉMICO">Académico</option>
              </select>
            </div>

            <div className="form-group half">
              <label>Estado inicial</label>
              <select name="estado" value={formData.estado} onChange={handleTextChange}>
                <option value="BORRADOR">Borrador</option>
                <option value="PENDIENTE REVISIÓN">Pendiente revisión</option>
                <option value="PROGRAMADO">Programado</option>
                <option value="PUBLICADO">Publicado</option>
              </select>
            </div>
          </div>

          <div className="form-group">
            <label>Imagen (opcional - haz clic para subir o cambiar)</label>
            <div className="image-upload-area">
              <input
                type="file"
                accept="image/*"
                onChange={handleImageChange}
                className="file-input"
              />
              {formData.imagenPreview ? (
                <img
                  src={formData.imagenPreview}
                  alt="Vista previa"
                  className="image-preview"
                />
              ) : (
                <div className="upload-placeholder">
                  <span>Haz clic o arrastra una imagen aquí</span>
                  <small>PNG, JPG, máx. 5MB recomendado</small>
                </div>
              )}
            </div>
          </div>

          <div className="modal-actions">
            <button type="button" className="btn-cancelar" onClick={onClose}>
              Cancelar
            </button>
            <button type="submit" className="btn-guardar">
              {isEditMode ? "Guardar Cambios" : "Crear Aviso"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}