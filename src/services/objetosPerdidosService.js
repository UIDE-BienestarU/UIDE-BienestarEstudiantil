import api from '../api/axios';

const objetosPerdidosService = {
  getAll: async (page = 1, limit = 20, estado = '') => {
    const params = { page, limit };
    if (estado) params.estado = estado;
    
    const response = await api.get('/objetos-perdidos/ver-objetos', { params });
    return response.data;
  },

  create: async (formData) => {
    const response = await api.post('/objetos-perdidos/reportar-objetos-perdidos', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  },

  updateEstado: async (id, estado) => {
    const response = await api.put(`/objetos-perdidos/${id}/estado`, { estado });
    return response.data;
  },

  getComentarios: async (id, page = 1) => {
    const response = await api.get(`/objetos-perdidos/${id}/comentarios`, {
      params: { page }
    });
    return response.data;
  },

  delete: async (id) => {
      const response = await api.delete(`/objetos-perdidos/${id}`);
      return response.data;
  }
};

export default objetosPerdidosService;
