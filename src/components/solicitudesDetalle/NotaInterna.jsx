const NotaInterna = () => {
  return (
    <div className="card nota-interna">
      <div className="card-header">
        <span className="card-icon">✏️</span>
        Agregar Nota Interna / Comentario
      </div>
      <div className="card-body">
        <textarea
          className="nota-textarea"
          placeholder="Escribe aquí una nota interna o comentario adicional..."
          rows={5}
        />
        <div className="nota-actions">
          <button className="btn-post">Enviar Comentario</button>
        </div>
      </div>
    </div>
  );
};

export default NotaInterna;