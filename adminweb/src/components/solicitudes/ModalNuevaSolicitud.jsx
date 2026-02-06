import { useState } from 'react';
import './ModalNuevaSolicitud.css';

export default function ModalNuevaSolicitud({ isOpen, onClose, onSubmit }) {
  const [formData, setFormData] = useState({
    estudiante: '',
    carrera: '',
    correo: '',
    tipo: 'académico',
    subtipo: '',
    descripcion: '',
    documentos: [],
    tramite: ''
  });

  const [errors, setErrors] = useState({});
  const [documentPreview, setDocumentPreview] = useState([]);

  const tiposSubtipos = {
    académico: ['cambio_asignatura', 'justificacion_inasistencia', 'reemplazo_nota', 'convalidacion'],
    administrativo: ['certificado_academico', 'credencial_digital', 'copia_documento', 'solicitud_copia'],
    bienestar: ['apoyo_economico', 'orientacion_psicologica', 'ayuda_alimentaria', 'otro']
  };

  const carreras = [
    'Ingeniería Sistemas',
    'Administración de Empresas',
    'Derecho',
    'Enfermería',
    'Psicología',
    'Contabilidad'
  ];

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

  const handleTipoChange = (e) => {
    const tipo = e.target.value;
    setFormData(prev => ({
      ...prev,
      tipo,
      subtipo: ''
    }));
  };

  const handleDocumentChange = (e) => {
    const files = Array.from(e.target.files);
    const fileNames = files.map(file => file.name);
    setFormData(prev => ({
      ...prev,
      documentos: fileNames
    }));
    setDocumentPreview(fileNames);
  };

  const removeDocument = (index) => {
    setFormData(prev => ({
      ...prev,
      documentos: prev.documentos.filter((_, i) => i !== index)
    }));
    setDocumentPreview(prev => prev.filter((_, i) => i !== index));
  };

  const validateEmail = (email) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  };

  const validateForm = () => {
    const newErrors = {};
    if (!formData.estudiante.trim()) newErrors.estudiante = 'El nombre del estudiante es obligatorio';
    if (!formData.carrera) newErrors.carrera = 'Seleccione una carrera';
    if (!formData.correo.trim()) {
      newErrors.correo = 'El correo es obligatorio';
    } else if (!validateEmail(formData.correo)) {
      newErrors.correo = 'Ingrese un correo válido';
    }
    if (!formData.tipo) newErrors.tipo = 'Seleccione un tipo de solicitud';
    if (!formData.subtipo) newErrors.subtipo = 'Seleccione un subtipo de solicitud';
    return newErrors;
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    const newErrors = validateForm();
    
    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }

    const nuevaSolicitud = {
      id: Date.now(),
      ...formData,
      fecha: new Date().toISOString().split('T')[0],
      estado: 'pendiente',
      tramite: formData.subtipo.replace(/_/g, ' ').toUpperCase()
    };

    onSubmit(nuevaSolicitud);
    resetForm();
  };

  const resetForm = () => {
    setFormData({
      estudiante: '',
      carrera: '',
      correo: '',
      tipo: 'académico',
      subtipo: '',
      descripcion: '',
      documentos: [],
      tramite: ''
    });
    setErrors({});
    setDocumentPreview([]);
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
          <h2>Crear Nueva Solicitud</h2>
          <button className="close-btn" onClick={handleClose}>✕</button>
        </div>

        <form onSubmit={handleSubmit} className="modal-form">
          <div className="form-group">
            <label htmlFor="estudiante">Nombre del Estudiante *</label>
            <input
              type="text"
              id="estudiante"
              name="estudiante"
              value={formData.estudiante}
              onChange={handleChange}
              placeholder="Ingrese nombre completo"
              className={errors.estudiante ? 'input-error' : ''}
            />
            {errors.estudiante && <span className="error-text">{errors.estudiante}</span>}
          </div>

          <div className="form-group">
            <label htmlFor="carrera">Carrera *</label>
            <select
              id="carrera"
              name="carrera"
              value={formData.carrera}
              onChange={handleChange}
              className={errors.carrera ? 'input-error' : ''}
            >
              <option value="">-- Seleccione una carrera --</option>
              {carreras.map(carrera => (
                <option key={carrera} value={carrera}>{carrera}</option>
              ))}
            </select>
            {errors.carrera && <span className="error-text">{errors.carrera}</span>}
          </div>

          <div className="form-group">
            <label htmlFor="correo">Correo Institucional *</label>
            <input
              type="email"
              id="correo"
              name="correo"
              value={formData.correo}
              onChange={handleChange}
              placeholder="estudiante@uide.edu.ec"
              className={errors.correo ? 'input-error' : ''}
            />
            {errors.correo && <span className="error-text">{errors.correo}</span>}
          </div>

          <div className="form-group">
            <label htmlFor="tipo">Tipo de Solicitud *</label>
            <select
              id="tipo"
              name="tipo"
              value={formData.tipo}
              onChange={handleTipoChange}
              className={errors.tipo ? 'input-error' : ''}
            >
              <option value="académico">Académico</option>
              <option value="administrativo">Administrativo</option>
              <option value="bienestar">Bienestar</option>
            </select>
            {errors.tipo && <span className="error-text">{errors.tipo}</span>}
          </div>

          <div className="form-group">
            <label htmlFor="subtipo">Subtipo de Solicitud *</label>
            <select
              id="subtipo"
              name="subtipo"
              value={formData.subtipo}
              onChange={handleChange}
              className={errors.subtipo ? 'input-error' : ''}
            >
              <option value="">-- Seleccione un subtipo --</option>
              {tiposSubtipos[formData.tipo].map(subtipo => (
                <option key={subtipo} value={subtipo}>
                  {subtipo.replace(/_/g, ' ').toUpperCase()}
                </option>
              ))}
            </select>
            {errors.subtipo && <span className="error-text">{errors.subtipo}</span>}
          </div>

          <div className="form-group">
            <label htmlFor="descripcion">Descripción (Opcional)</label>
            <textarea
              id="descripcion"
              name="descripcion"
              value={formData.descripcion}
              onChange={handleChange}
              placeholder="Proporcione detalles adicionales sobre su solicitud"
              rows="4"
            />
          </div>

          <div className="form-group">
            <label htmlFor="documentos">Adjuntar Documentos (Opcional)</label>
            <input
              type="file"
              id="documentos"
              multiple
              onChange={handleDocumentChange}
              accept=".pdf,.doc,.docx,.jpg,.png,.xlsx"
            />
            {documentPreview.length > 0 && (
              <div className="document-list">
                <p className="document-label">Documentos adjuntos:</p>
                <ul>
                  {documentPreview.map((doc, index) => (
                    <li key={index}>
                      {doc}
                      <button
                        type="button"
                        className="remove-doc-btn"
                        onClick={() => removeDocument(index)}
                      >
                        ✕
                      </button>
                    </li>
                  ))}
                </ul>
              </div>
            )}
          </div>

          <div className="modal-footer">
            <button type="button" className="btn-cancel" onClick={handleClose}>
              Cancelar
            </button>
            <button type="submit" className="btn-submit">
              Crear Solicitud
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
