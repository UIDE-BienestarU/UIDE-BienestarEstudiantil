
import api from "../api/axios";

const sugerenciasService = {
  getAll: async () => {
    try {
      const response = await api.get("/sugerencias/ver-sugerencias");
      return response.data;
    } catch (error) {
      console.error("Error fetching sugerencias", error);
      throw error; // Let caller handle
    }
  },

  // Admin doesn't create suggestions typically, but keeping structure 
  enviar: async (data) => {
      const response = await api.post("/enviar-sugerencia", data);
      return response.data;
  }
};

export default sugerenciasService;
