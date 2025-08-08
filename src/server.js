import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import sequelize, { testConnection } from './data/database.js';
import usuarioRoutes from './presentation/routes/usuarios.js';
import solicitudRoutes from './presentation/routes/solicitudes.js';
import notificacionRoutes from './presentation/routes/notificaciones.js';
import tipoSolicitudRoutes from './presentation/routes/tiposolicitudes.js';
import subtipoSolicitudRoutes from './presentation/routes/subtiposolicitudes.js';
import documentoRoutes from './presentation/routes/documentos.js';
import discapacidadRoutes from './presentation/routes/discapacidades.js';
import estadisticasRouter from './presentation/routes/estadisticas.js';
import path from 'path';
import { fileURLToPath } from 'url';
import uploadRoutes from './presentation/routes/upload.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config();
const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors({
  origin: 'http://localhost:3001',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json());

// Servir archivos estáticos desde la carpeta Uploads en la raíz del proyecto
app.use('/Uploads', express.static(path.join(__dirname, '../Uploads')));

// Rutas
app.use('/api', usuarioRoutes);
app.use('/api', solicitudRoutes);
app.use('/api', notificacionRoutes);
app.use('/api', tipoSolicitudRoutes);
app.use('/api', subtipoSolicitudRoutes);
app.use('/api', documentoRoutes);
app.use('/api', discapacidadRoutes);
app.use('/api/upload', uploadRoutes);
app.use('/api', estadisticasRouter);

app.get('/api/testmysql', async (req, res) => {
    try {
        const result = await testConnection();
        res.json({
            status: 200,
            message: 'Conexión a la base de datos establecida correctamente.',
            database: process.env.DB_NAME,
            timestamp: new Date().toISOString()
        });
    } catch (error) {
        res.status(500).json({
            status: 500,
            message: 'No se pudo conectar a la base de datos',
            error: error.message || error
        });
    }
});

const startServer = async () => {
    try {
        const dbConnected = await testConnection();
        if (!dbConnected) {
            throw new Error('No se pudo conectar a la base de datos');
        }
        await sequelize.sync({ alter: true });
        console.log('Modelos sincronizados');
        app.listen(PORT, () => {
            console.log(`Servidor escuchando en el puerto ${PORT}`);
        });
    } catch (error) {
        console.error('Error al inicializar el servidor:', error);
        process.exit(1);
    }
};

startServer();
