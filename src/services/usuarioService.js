import api from '../api/axios';

const usuarioService = {
  getPerfil: async () => {
    const response = await api.get('/perfil');
    return response.data;
  },

  updatePerfil: async (data) => {
    const response = await api.put('/perfil', data);
    return response.data;
  }
};

export default usuarioService;
