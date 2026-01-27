// src/server.js
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import sequelize, { testConnection } from './data/database.js';
import path from 'path';
import { fileURLToPath } from 'url';
import helmet from 'helmet';
import http from 'http';
import { initSocket } from './realtime/socket.js';
import { notFoundHandler, errorHandler } from './presentation/middleware/errorHandler.js';

// 🔹 Swagger
import swaggerUi from 'swagger-ui-express';
import { swaggerSpec } from './config/swagger.js';

// Middlewares extra (Prioridad B)
import { requestId } from './presentation/middleware/requestId.js';
import { logger } from './presentation/middleware/logger.js';
import { generalLimiter } from './presentation/middleware/rateLimiters.js';

import usuarioRoutes from './presentation/routes/usuarios.js';
import solicitudRoutes from './presentation/routes/solicitudes.js';
import notificacionRoutes from './presentation/routes/notificaciones.js';
import tipoSolicitudRoutes from './presentation/routes/tiposolicitudes.js';
import subtipoSolicitudRoutes from './presentation/routes/subtiposolicitudes.js';
import documentoRoutes from './presentation/routes/documentos.js';
import discapacidadRoutes from './presentation/routes/discapacidades.js';
import estadisticasRouter from './presentation/routes/estadisticas.js';
import uploadRoutes from './presentation/routes/upload.js';

import './data/models/registerAssociations.js';

// Rutas funcionales
import publicacionesRoutes from './presentation/routes/publicaciones.js';
import objetosPerdidosRoutes from './presentation/routes/objetos-perdidos.js';
import sugerenciasRoutes from './presentation/routes/sugerencias.js';

// Devices
import devicesRoutes from './presentation/routes/devices.js';

// Drafts
import draftRoutes from './presentation/routes/solicitudes-draft.js';

// Me summary
import meRoutes from './presentation/routes/me.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config();
const app = express();
const PORT = process.env.PORT || 3000;

// ✅ Trust proxy
app.set('trust proxy', 1);

// ✅ requestId + logger
app.use(requestId);
app.use(logger);

// ✅ helmet
app.use(helmet({
  crossOriginResourcePolicy: { policy: 'cross-origin' },
}));

// ✅ rate limit global
app.use(generalLimiter);

// ✅ CORS
const allowedOrigins = (process.env.CORS_ORIGINS || '')
  .split(',')
  .map(s => s.trim())
  .filter(Boolean);

app.use(cors({
  origin: (origin, cb) => {
    if (!origin) return cb(null, true);
    if (allowedOrigins.length === 0) {
      if (origin.startsWith('http://localhost')) return cb(null, true);
      return cb(null, false);
    }
    return cb(null, allowedOrigins.includes(origin));
  },
  credentials: false,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Idempotency-Key', 'X-Request-Id'],
  exposedHeaders: ['X-Request-Id'],
}));

// ✅ Parsers
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// ✅ Static uploads
app.use('/Uploads', express.static(path.join(__dirname, 'Uploads'), {
  maxAge: '7d',
  immutable: true,
}));

// ==================== RUTAS API ====================

app.use('/api', usuarioRoutes);
app.use('/api/me', meRoutes);
app.use('/api/solicitudes', draftRoutes);
app.use('/api', solicitudRoutes);
app.use('/api', notificacionRoutes);
app.use('/api', tipoSolicitudRoutes);
app.use('/api', subtipoSolicitudRoutes);
app.use('/api', documentoRoutes);
app.use('/api', discapacidadRoutes);
app.use('/api', estadisticasRouter);
app.use('/api/upload', uploadRoutes);

app.use('/api/publicaciones', publicacionesRoutes);
app.use('/api/objetos-perdidos', objetosPerdidosRoutes);
app.use('/api/sugerencias', sugerenciasRoutes);
app.use('/api/devices', devicesRoutes);

// 🔹 API DOCS (DEBE IR ANTES DE notFoundHandler)
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// ✅ Test DB
app.get('/api/testmysql', async (req, res) => {
  try {
    await testConnection();
    res.json({ success: true, message: 'DB conectada correctamente' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ==================== HANDLERS FINALES ====================
app.use(notFoundHandler);
app.use(errorHandler);

// ==================== START ====================
const startServer = async () => {
  try {
    await testConnection();
    await sequelize.sync({ alter: false, force: false });

    const server = http.createServer(app);

    const corsOrigins = (process.env.CORS_ORIGINS || '')
      .split(',')
      .map(s => s.trim())
      .filter(Boolean);

    initSocket(server, { corsOrigins });

    console.log('Base de datos sincronizada');
    server.listen(PORT, () => {
      console.log(`SERVIDOR CORRIENDO EN http://localhost:${PORT}`);
      console.log(`Swagger: http://localhost:${PORT}/api-docs`);
    });
  } catch (error) {
    console.error('Error fatal:', error);
    process.exit(1);
  }
};

startServer();
