import { useState } from 'react';
import './ModalNuevoAviso.css';

export default function ModalNuevoAviso({ isOpen, onClose, onSubmit }) {
  const [formData, setFormData] = useState({
    titulo: '',
    descripcion: '',
    tipo_aviso: 'general',
    estado: 'activo',
    prioridad: 'media',
    fecha_expiracion: '',
    imagenPreview: '',
    imagenBase64: ''
  });

  const [errors, setErrors] = useState({});

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    if (errors[name]) {
      setErrors(prev => ({
        ...prev,
        [name]: ''
      }));
    }
  };

  const handleImageChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setFormData(prev => ({
          ...prev,
          imagenBase64: reader.result,
          imagenPreview: reader.result
        }));
      };
      reader.readAsDataURL(file);
    }
  };

  const validateForm = () => {
    const newErrors = {};
    if (!formData.titulo.trim()) newErrors.titulo = 'El título es obligatorio';
    if (!formData.descripcion.trim()) newErrors.descripcion = 'La descripción es obligatoria';
    return newErrors;
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    const newErrors = validateForm();
    
    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }

    const nuevoAviso = {
      id: Date.now(),
      ...formData,
      fecha_publicacion: new Date(),
      creado_por: 'admin_actual',
      imagen_url: formData.imagenBase64
    };

    onSubmit(nuevoAviso);
    resetForm();
  };

  const resetForm = () => {
    setFormData({
      titulo: '',
      descripcion: '',
      tipo_aviso: 'general',
      estado: 'activo',
      prioridad: 'media',
      fecha_expiracion: '',
      imagenPreview: '',
      imagenBase64: ''
    });
    setErrors({});
  };

  const handleClose = () => {
    resetForm();
    onClose();
  };

  if (!isOpen) return null;

  return (
    <div className="modal-overlay" onClick={handleClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <h2>Crear Nuevo Aviso</h2>
          <button className="close-btn" onClick={handleClose}>✕</button>
        </div>

        <form onSubmit={handleSubmit} className="modal-form">
          <div className="form-group">
            <label htmlFor="titulo">Título *</label>
            <input
              type="text"
              id="titulo"
              name="titulo"
              value={formData.titulo}
              onChange={handleChange}
              placeholder="Ingrese el título del aviso"
              className={errors.titulo ? 'input-error' : ''}
            />
            {errors.titulo && <span className="error-text">{errors.titulo}</span>}
          </div>

          <div className="form-group">
            <label htmlFor="descripcion">Descripción *</label>
            <textarea
              id="descripcion"
              name="descripcion"
              value={formData.descripcion}
              onChange={handleChange}
              placeholder="Ingrese la descripción del aviso"
              rows="4"
              className={errors.descripcion ? 'input-error' : ''}
            />
            {errors.descripcion && <span className="error-text">{errors.descripcion}</span>}
          </div>

          <div className="form-group">
            <label htmlFor="tipo_aviso">Tipo de Aviso</label>
            <select
              id="tipo_aviso"
              name="tipo_aviso"
              value={formData.tipo_aviso}
              onChange={handleChange}
            >
              <option value="académico">Académico</option>
              <option value="administrativo">Administrativo</option>
              <option value="general">General</option>
              <option value="evento">Evento</option>
            </select>
          </div>

          <div className="form-group">
            <label htmlFor="prioridad">Prioridad</label>
            <select
              id="prioridad"
              name="prioridad"
              value={formData.prioridad}
              onChange={handleChange}
            >
              <option value="baja">Baja</option>
              <option value="media">Media</option>
              <option value="alta">Alta</option>
            </select>
          </div>

          <div className="form-group">
            <label htmlFor="estado">Estado</label>
            <select
              id="estado"
              name="estado"
              value={formData.estado}
              onChange={handleChange}
            >
              <option value="activo">Activo</option>
              <option value="inactivo">Inactivo</option>
              <option value="expirado">Expirado</option>
            </select>
          </div>

          <div className="form-group">
            <label htmlFor="fecha_expiracion">Fecha de Expiración (Opcional)</label>
            <input
              type="date"
              id="fecha_expiracion"
              name="fecha_expiracion"
              value={formData.fecha_expiracion}
              onChange={handleChange}
            />
          </div>

          <div className="form-group">
            <label htmlFor="imagen">Imagen (Opcional)</label>
            <input
              type="file"
              id="imagen"
              accept="image/*"
              onChange={handleImageChange}
            />
            {formData.imagenPreview && (
              <div className="image-preview">
                <img src={formData.imagenPreview} alt="Preview" />
              </div>
            )}
          </div>

          <div className="modal-footer">
            <button type="button" className="btn-cancel" onClick={handleClose}>
              Cancelar
            </button>
            <button type="submit" className="btn-submit">
              Crear Aviso
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
