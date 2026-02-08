import { useState, useEffect, useCallback } from "react";
import TopBar from "../components/layout/TopBar";
import ProtectedLayout from "../components/layout/ProtectedLayout";
import PageHeader from "../components/layout/PageHeader";

import ObjetosGrid from "../components/objetosPerdidos/ObjetosGrid";
import ModalObjetoDetalle from "../components/objetosPerdidos/ModalObjetoDetalle";
import ModalPublicarObjeto from "../components/objetosPerdidos/ModalPublicarObjeto";
import ConfirmationModal from "../components/common/ConfirmationModal"; // Import
import objetosPerdidosService from "../services/objetosPerdidosService";

export default function ObjetosPerdidos() {
  const [objetos, setObjetos] = useState([]);
  const [selectedObjeto, setSelectedObjeto] = useState(null);
  const [showPublicarModal, setShowPublicarModal] = useState(false);
  const [loading, setLoading] = useState(true);

  // Estados para modalidades de confirmación
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [itemToDelete, setItemToDelete] = useState(null);

  const [showEntregarModal, setShowEntregarModal] = useState(false);
  const [itemToEntregar, setItemToEntregar] = useState(null);

  // Estados para modal de éxito
  const [showSuccessModal, setShowSuccessModal] = useState(false);
  const [successMessage, setSuccessMessage] = useState("");

  const fetchObjetos = useCallback(async () => {
    try {
      setLoading(true);
      const response = await objetosPerdidosService.getAll();
      // Backend returns { data: { rows: [...], total: ... } }
      if (response.data && response.data.rows) {
        setObjetos(response.data.rows);
      } else if (Array.isArray(response.data)) {
        setObjetos(response.data);
      } else {
        setObjetos([]);
      }
    } catch (error) {
      console.error("Error cargando objetos", error);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchObjetos();
  }, [fetchObjetos]);

  // Publicar nuevo objeto
  const handlePublicar = async (nuevoObjetoData) => {
    try {
        const formData = new FormData();
        formData.append("titulo", nuevoObjetoData.titulo);
        formData.append("descripcion", nuevoObjetoData.descripcion);
        formData.append("lugar_encontrado", nuevoObjetoData.lugar_encontrado);
        formData.append("estado", nuevoObjetoData.estado);
        if (nuevoObjetoData.file) {
            formData.append("foto", nuevoObjetoData.file);
        }
        await objetosPerdidosService.create(formData);
        fetchObjetos();
        setShowPublicarModal(false);
        setSuccessMessage("¡Objeto publicado correctamente!");
        setShowSuccessModal(true);
    } catch (error) {
        console.error("Error publicando objeto", error);
        alert("Error al publicar objeto");
    }
  };

  // Ver detalles
  const handleVerDetalles = (objeto) => {
    setSelectedObjeto(objeto);
  };

  // --- Lógica Entregar ---
  const requestEntregar = (id) => {
    setItemToEntregar(id);
    setShowEntregarModal(true);
  };

  const confirmEntregar = async () => {
    if (!itemToEntregar) return;
    try {
      await objetosPerdidosService.updateEstado(itemToEntregar, "devuelto");
      fetchObjetos();
      if (selectedObjeto?.id === itemToEntregar) {
          // Actualizar el objeto seleccionado si está abierto
          setSelectedObjeto(prev => ({ ...prev, estado: "devuelto" })); 
          // O cerrarlo: setSelectedObjeto(null);
      }
      setShowEntregarModal(false);
      setItemToEntregar(null);
      setSuccessMessage("¡Objeto marcado como devuelto exitosamente!");
      setShowSuccessModal(true);
    } catch (error) {
       console.error("Error actualizando estado", error);
       alert("Error al actualizar estado");
       setShowEntregarModal(false);
    }
  };

  // --- Lógica Eliminar ---
  const requestEliminar = (id) => {
    setItemToDelete(id);
    setShowDeleteModal(true);
  };

  const confirmEliminar = async () => {
    if (!itemToDelete) return;
    try {
        await objetosPerdidosService.delete(itemToDelete);
        fetchObjetos();
        if (selectedObjeto?.id === itemToDelete) {
            setSelectedObjeto(null);
        }
        setShowDeleteModal(false);
        setItemToDelete(null);
    } catch (error) {
        console.error("Error eliminando objeto", error);
        alert("Error al eliminar objeto");
        setShowDeleteModal(false);
    }
  };


  return (
    <>
      <TopBar />
      <div className="contenedor">
        <h1>Objetos Perdidos</h1>

        <div className="header-actions">
          <div className="contador-pendientes">
             {loading ? (
                <span>Cargando...</span>
             ) : (
                <span>Tienes <strong>{objetos.length} objetos</strong> registrados en esta vista</span>
             )}
          </div>
          
          <button 
            className="btn-publicar"
            onClick={() => setShowPublicarModal(true)}
            style={{
              background: '#8b0038', // Solid primary
              color: 'white',
              border: 'none',
              padding: '12px 24px',
              borderRadius: '12px', // Standard rounded
              fontSize: '1rem',
              fontWeight: '600',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              boxShadow: '0 4px 6px rgba(139, 0, 56, 0.2)', // Softer shadow
              transition: 'all 0.2s ease',
              marginLeft: 'auto' // Keep alignment
            }}
            onMouseOver={(e) => {
               e.currentTarget.style.backgroundColor = '#6f002c'; // Darker on hover
               e.currentTarget.style.transform = 'translateY(-1px)';
            }}
            onMouseOut={(e) => {
               e.currentTarget.style.backgroundColor = '#8b0038';
               e.currentTarget.style.transform = 'translateY(0)';
            }}
          >
            <span style={{ fontSize: '1.2rem', fontWeight: 'bold' }}>+</span> Publicar objeto perdido
          </button>
        </div>

        {loading ? (
             <div>Cargando objetos...</div>
        ) : (
            <ObjetosGrid 
            objetos={objetos}
            onVerDetalles={handleVerDetalles}
            onEntregar={requestEntregar} // Pass requestEntregar
            onEliminar={requestEliminar} // Pass requestEliminar
            />
        )}

        <div className="paginacion-info">
          Mostrando {objetos.length} objetos
        </div>

        {selectedObjeto && (
          <ModalObjetoDetalle
            objeto={selectedObjeto}
            onClose={() => setSelectedObjeto(null)}
            onEntregar={requestEntregar} // Pass requestEntregar
            onEliminar={requestEliminar} // Pass requestEliminar
          />
        )}

        {showPublicarModal && (
          <ModalPublicarObjeto
            onClose={() => setShowPublicarModal(false)}
            onPublicar={handlePublicar}
          />
        )}

        {/* Modal Confirmación Eliminar */}
        <ConfirmationModal
            isOpen={showDeleteModal}
            onClose={() => setShowDeleteModal(false)}
            onConfirm={confirmEliminar}
            title="¿Eliminar objeto perdido?"
            message="¿Estás seguro de que deseas eliminar este registro permanentemente? Esta acción no se puede deshacer."
            confirmText="Sí, Eliminar"
            cancelText="Cancelar"
            type="danger"
        />

        {/* Modal Confirmación Entregar */}
        <ConfirmationModal
            isOpen={showEntregarModal}
            onClose={() => setShowEntregarModal(false)}
            onConfirm={confirmEntregar}
            title="Confirmar Entrega"
            message="¿Confirmas que este objeto ha sido devuelto a su dueño? El estado cambiará a 'Devuelto'."
            confirmText="Sí, Marcar Devuelto"
            cancelText="Cancelar"
            type="success"
        />

        {/* Modal de Éxito */}
        <ConfirmationModal 
          isOpen={showSuccessModal}
          onClose={() => setShowSuccessModal(false)}
          onConfirm={() => setShowSuccessModal(false)}
          title="¡Éxito!"
          message={successMessage}
          confirmText="Aceptar"
          cancelText={null}
          type="success"
        />
      </div>
    </>
  );
}