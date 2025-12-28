import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import swaggerUi from 'swagger-ui-express';
import swaggerJsdoc from 'swagger-jsdoc';

// Імпорт маршрутів
import stationRoutes from './routes/stationRoutes';
import statisticsRoutes from './routes/statisticsRoutes';
import userRoutes from './routes/userRoutes';
import authRoutes from './routes/authRoutes'; 
import parametersRoutes from './routes/parametersRoutes'; 
import sensorsRoutes from './routes/sensorsRoutes'; 
import telemetryRoutes from './routes/telemetryRoutes'; 
import thresholds from './routes/thresholdsRoutes'; 
import actuatorRoutes from './routes/actuatorRoutes'; 
import alertsRoutes from './routes/alertsRoutes'; 
import backupRoutes from './routes/backupRoutes'; 

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(helmet());
app.use(cors());
app.use(express.json());

// --- API Router для всіх /api/v1 ендпоінтів ---
const apiRouter = express.Router();

apiRouter.use('/auth', authRoutes);
apiRouter.use('/users', userRoutes);
apiRouter.use('/stations', stationRoutes);
apiRouter.use('/parameters', parametersRoutes);
apiRouter.use('/sensors', sensorsRoutes);
apiRouter.use('/telemetry', telemetryRoutes);
apiRouter.use('/thresholds', thresholds);
apiRouter.use('/actuators', actuatorRoutes);
apiRouter.use('/alerts', alertsRoutes);
apiRouter.use('/backups', backupRoutes);
apiRouter.use('/statistics', statisticsRoutes);

app.use('/api/v1', apiRouter);


const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Water Monitor System API',
      version: '1.0.0',
      description: 'API for managing IoT Stations, Users, and Telemetry',
    },
    servers: [{ url: '/api/v1' }],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
    },
    security: [{ bearerAuth: [] }],
  },
  apis: ['./src/routes/*.ts'], 
  
};

const swaggerSpecs = swaggerJsdoc(swaggerOptions);

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpecs));


app.get('/api-docs.json', (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.send(swaggerSpecs);
});


app.get('/', (req, res) => {
  res.json({ 
    message: 'IoT API is running 🚀', 
    docs: `http://localhost:${PORT}/api-docs`,
    apiBase: `http://localhost:${PORT}/api/v1`
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📄 Swagger Docs: http://localhost:${PORT}/api-docs`);
  console.log(`🌐 API Base: http://localhost:${PORT}/api/v1`);
});
