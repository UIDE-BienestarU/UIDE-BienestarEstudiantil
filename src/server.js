import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import sequelize, { testConnection } from './data/database.js';
import path from 'path';
import { fileURLToPath } from 'url';

import usuarioRoutes from './presentation/routes/usuarios.js';
import solicitudRoutes from './presentation/routes/solicitudes.js';
import notificacionRoutes from './presentation/routes/notificaciones.js';
import tipoSolicitudRoutes from './presentation/routes/tiposolicitudes.js';
import subtipoSolicitudRoutes from './presentation/routes/subtiposolicitudes.js';
import documentoRoutes from './presentation/routes/documentos.js';
import discapacidadRoutes from './presentation/routes/discapacidades.js';
import estadisticasRouter from './presentation/routes/estadisticas.js';
import uploadRoutes from './presentation/routes/upload.js';

// NUEVAS RUTAS
import publicacionesRoutes from './presentation/routes/publicaciones.js';
import objetosPerdidosRoutes from './presentation/routes/objetos-perdidos.js';
import sugerenciasRoutes from './presentation/routes/sugerencias.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config();
const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors({
  origin: ['http://localhost:3001', 'http://localhost:3000'], 
  credentials: true,
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Archivos estáticos
app.use('/Uploads', express.static(path.join(__dirname, 'Uploads')));

// RUTAS API
app.use('/api', usuarioRoutes);
app.use('/api', solicitudRoutes);
app.use('/api', notificacionRoutes);
app.use('/api', tipoSolicitudRoutes);
app.use('/api', subtipoSolicitudRoutes);
app.use('/api', documentoRoutes);
app.use('/api', discapacidadRoutes);
app.use('/api', estadisticasRouter);
app.use('/api/upload', uploadRoutes);

// NUEVAS RUTAS (las 3 funcionalidades)
app.use('/api/publicaciones', publicacionesRoutes);
app.use('/api/objetos-perdidos', objetosPerdidosRoutes);
app.use('/api/sugerencias', sugerenciasRoutes);

// Test DB
app.get('/api/testmysql', async (req, res) => {
  try {
    await testConnection();
    res.json({ message: 'DB conectada correctamente' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const startServer = async () => {
  try {
    await testConnection();
    await sequelize.sync({ alter: true });
    console.log('Base de datos sincronizada');
    app.listen(PORT, () => {
      console.log(`SERVIDOR CORRIENDO EN http://localhost:${PORT}`);
      console.log(`Carpeta Uploads: ${path.join(__dirname, 'Uploads')}`);
    });
  } catch (error) {
    console.error('Error fatal:', error);
    process.exit(1);
  }
};

startServer();