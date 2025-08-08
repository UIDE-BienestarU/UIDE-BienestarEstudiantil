import EstadisticaService from '../../business/services/EstadisticaService.js';

const getEstadistasHandler = async (req, res) => {
  try {
    const estadisticas = await EstadisticaService.getEstadisticas();
    res.status(200).json({ success: true, data: estadisticas });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

export default getEstadistasHandler ;