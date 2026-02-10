import api from '../api/axios';

const estadisticasService = {
  getResumen: async () => {
    const response = await api.get('/estadisticas');
    return response.data;
  }
};

export default estadisticasService;
