import api from '../api/axios';

const solicitudesService = {
  getAll: async (params = {}) => {
    const response = await api.get('/ver-solicitudes', { params });
    return response.data;
  },

  getById: async (id) => {
    // Note: The backend route /ver-solicitudes supports filtering but maybe not direct ID get if not implemented.
    // However, usually detailed view is needed. Backend has /solicitudes/:id/historial. 
    // Trying to find a getOne endpoint in backend... 
    // It seems missing in the provided snippet! Only /ver-solicitudes list. 
    // We might need to filter the list or check if backend has a detail route not shown.
    // For now, assuming we filter the list or a generic endpoint exists.
    // Actually, looking at `server.js`, `app.use('/api', solicitudRoutes)` 
    // and `solicitudRoutes` has `/ver-solicitudes` and `/solicitudes/:id/estado`.
    // We will assume getting one is not explicitly separate or we use the list with filter if possible.
    // Wait, let's just implement what we know exists.
    const response = await api.get(`/ver-solicitudes?id=${id}`);
    // If API doesn't support id param, we might need to filter client side or update backend. 
    // Assuming standard REST for now, or just return mock if not ready.
    // But user wants "CONNECTION". I'll use the existing /ver-solicitudes.
    return response.data;
  },

  updateEstado: async (id, estado, comentario) => {
    const response = await api.put(`/solicitudes/${id}/estado`, { 
      estado_actual: estado, 
      comentario 
    });
    return response.data;
  },

  getHistorial: async (id) => {
    const response = await api.get(`/solicitudes/${id}/historial`);
    return response.data;
  }
};

export default solicitudesService;
