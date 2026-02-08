import { useState, useEffect, useCallback } from "react";
import TopBar from "../components/layout/TopBar";
import ProtectedLayout from "../components/layout/ProtectedLayout";
import PageHeader from "../components/layout/PageHeader";

import AvisosGrid from "../components/avisos/AvisosGrid";
import AvisosPagination from "../components/avisos/AvisosPagination";
import ModalNuevoAviso from "../components/avisos/ModalNuevoAviso";
import ConfirmationModal from "../components/common/ConfirmationModal"; // Import
import publicacionesService from "../services/publicacionesService";

export default function Avisos() {
  const [avisos, setAvisos] = useState([]);
  const [page, setPage] = useState(1);
  const [showModal, setShowModal] = useState(false);
  const [avisoToEdit, setAvisoToEdit] = useState(null);
  const [totalPages, setTotalPages] = useState(1);
  const [loading, setLoading] = useState(true);

  // Estados para modal de confirmación
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [avisoToDelete, setAvisoToDelete] = useState(null);

  // Estados para modal de éxito
  const [showSuccessModal, setShowSuccessModal] = useState(false);
  const [successMessage, setSuccessMessage] = useState("");

  const fetchAvisos = useCallback(async () => {
    try {
      setLoading(true);
      const data = await publicacionesService.getAll(page, 8);
      if (data.data && Array.isArray(data.data)) {
        setAvisos(data.data);
        // Backend returns meta: { page, limit, total }
        if (data.meta) {
           const total = data.meta.total || 0;
           const limit = data.meta.limit || 8;
           setTotalPages(Math.ceil(total / limit) || 1);
        } else {
           setTotalPages(data.totalPages || 1);
        }
      } else if (Array.isArray(data)) {
        setAvisos(data);
      } else {
        setAvisos([]);
      }
    } catch (error) {
      console.error("Error cargando avisos", error);
    } finally {
      setLoading(false);
    }
  }, [page]);

  useEffect(() => {
    fetchAvisos();
  }, [fetchAvisos, page]);

  // Abrir modal para nuevo aviso
  const openNewModal = () => {
    setAvisoToEdit(null);
    setShowModal(true);
  };

  // Abrir modal para editar
  const openEditModal = (aviso) => {
    setAvisoToEdit(aviso);
    setShowModal(true);
  };

  // Guardar (nuevo o edición)
  const handleSaveAviso = async (avisoData) => {
    try {
      if (avisoToEdit) {
        // Editar 
        const formData = new FormData();
        if (avisoData.titulo) formData.append("titulo", avisoData.titulo);
        if (avisoData.contenido) formData.append("contenido", avisoData.contenido);
        if (avisoData.file) {
          formData.append("imagen", avisoData.file);
        }

        await publicacionesService.update(avisoToEdit.id, formData);
        fetchAvisos(); // Reload
        setShowModal(false);
        setSuccessMessage("¡El aviso ha sido actualizado exitosamente!");
        setShowSuccessModal(true);
      } else {
        // Nuevo
        const formData = new FormData();
        formData.append("titulo", avisoData.titulo);
        formData.append("contenido", avisoData.contenido);
        if (avisoData.file) {
          formData.append("imagen", avisoData.file);
        }

        await publicacionesService.create(formData);
        fetchAvisos(); // Reload
        setShowModal(false);
        setSuccessMessage("¡El aviso ha sido publicado exitosamente!");
        setShowSuccessModal(true);
      }
    } catch (error) {
      console.error("Error guardando aviso", error);
      alert("Error al guardar aviso");
    }
  };

  // Iniciar proceso de eliminar
  const confirmDelete = (id) => {
    setAvisoToDelete(id);
    setShowDeleteModal(true);
  };

  // Confirmar eliminación
  const handleDelete = async () => {
    if (!avisoToDelete) return;
    try {
      await publicacionesService.delete(avisoToDelete);
      fetchAvisos(); // Reload
      setShowDeleteModal(false);
      setAvisoToDelete(null);
    } catch (error) {
      console.error("Error eliminando aviso", error);
      alert("Error al eliminar aviso");
      setShowDeleteModal(false);
    }
  };

  // Tres puntos (placeholder)
  const handleMoreOptions = (aviso) => {
    alert(
      `Opciones adicionales para "${aviso.titulo}"`
    );
  };

  return (
    <>
      <TopBar />
      <div className="contenedor">
        <h1>Gestión de Avisos</h1>

        {/* Controles superiores */}
        <div className="header-actions">
          <div className="contador-pendientes">
             {loading ? (
                <span>Cargando...</span>
             ) : (
                <span>Tienes <strong>{avisos.length} avisos</strong> publicados en esta vista</span>
             )}
          </div>

          <button 
            className="btn-nuevo-aviso" 
            onClick={openNewModal}
            style={{
              background: '#8b0038', // Solid primary color or theme var
              color: 'white',
              border: 'none',
              padding: '12px 24px',
              borderRadius: '12px', // Standard rounded corners
              fontSize: '1rem',
              fontWeight: '600',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              boxShadow: '0 4px 6px rgba(139, 0, 56, 0.2)', // Softer shadow
              transition: 'all 0.2s ease',
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
            <span className="plus-icon" style={{ fontSize: '1.2rem', fontWeight: 'bold' }}>+</span>
            Nuevo aviso
          </button>
        </div>

        {loading ? (
          <div>Cargando avisos...</div>
        ) : (
          <AvisosGrid
            avisos={avisos}
            onEdit={openEditModal}
            onDelete={confirmDelete} // Pass confirmDelete instead of direct delete
            onMore={handleMoreOptions}
          />
        )}

        <div className="paginacion-wrapper">
          <AvisosPagination
            page={page}
            setPage={setPage}
            total={totalPages}
          />
        </div>

        <div className="footer-info">
          Mostrando {avisos.length} avisos
        </div>

        {showModal && (
          <ModalNuevoAviso
            avisoInicial={avisoToEdit}
            onClose={() => setShowModal(false)}
            onSave={handleSaveAviso}
          />
        )}

        {/* Modal de Confirmación Eliminar */}
        <ConfirmationModal 
          isOpen={showDeleteModal}
          onClose={() => setShowDeleteModal(false)}
          onConfirm={handleDelete}
          title="¿Eliminar Aviso?"
          message="¿Estás seguro de que deseas eliminar este aviso permanentemente? Esta acción no se puede deshacer."
          confirmText="Sí, Eliminar"
          cancelText="Cancelar"
          type="danger"
        />

        {/* Modal de Éxito */}
        <ConfirmationModal 
          isOpen={showSuccessModal}
          onClose={() => setShowSuccessModal(false)}
          onConfirm={() => setShowSuccessModal(false)}
          title="¡Éxito!"
          message={successMessage}
          confirmText="Aceptar"
          cancelText={null} // No cancel button
          type="success"
        />
      </div>
    </>
  );
}
