import api from '../api/axios';

const publicacionesService = {
  getAll: async (page = 1, limit = 10) => {
    const response = await api.get('/publicaciones/ver-publicaciones', {
      params: { page, limit }
    });
    return response.data;
  },

  create: async (formData) => {
    // Expects FormData object for file upload
    const response = await api.post('/publicaciones/publicaciones-crear', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  },

  delete: async (id) => {
    const response = await api.delete(`/publicaciones/${id}`);
    return response.data;
  },

  update: async (id, formData) => {
     const response = await api.put(`/publicaciones/${id}`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    return response.data;
  }
};

export default publicacionesService;
