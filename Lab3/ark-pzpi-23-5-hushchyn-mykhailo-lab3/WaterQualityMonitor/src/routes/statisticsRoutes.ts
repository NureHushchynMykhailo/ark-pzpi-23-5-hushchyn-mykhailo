import { Router } from 'express';
import { StatisticsController } from '../controllers/statisticsController';
import { authenticateToken, authorizeRole } from '../middlewares/authMiddleware';

const router = Router();
const controller = new StatisticsController();

const ALLOWED_ROLES = ['admin', 'manager', 'analyst'];

/**
 * @swagger
 * tags:
 *   name: Statistics
 *   description: Analytical reports and aggregations
 */

/**
 * @swagger
 * /statistics/station/{stationId}/sensors:
 *   get:
 *     summary: Get aggregated sensor data (Min/Max/Avg)
 *     tags: [Statistics]
 *     security: [{ bearerAuth: [] }]
 *     parameters:
 *       - in: path
 *         name: stationId
 *         required: true
 *         schema: { type: string, format: uuid }
 *       - in: query
 *         name: from
 *         schema: { type: string, format: date-time }
 *         description: Start date (default 24h ago)
 *       - in: query
 *         name: to
 *         schema: { type: string, format: date-time }
 *         description: End date (default now)
 *     responses:
 *       200:
 *         description: Statistical data
 */
router.get(
  '/station/:stationId/sensors',
  authenticateToken,
  authorizeRole(ALLOWED_ROLES),
  controller.getSensorStats
);

/**
 * @swagger
 * /statistics/station/{stationId}/alerts:
 *   get:
 *     summary: Get alert counts by type and status
 *     tags: [Statistics]
 *     security: [{ bearerAuth: [] }]
 *     parameters:
 *       - in: path
 *         name: stationId
 *         required: true
 *         schema: { type: string, format: uuid }
 *       - in: query
 *         name: from
 *         schema: { type: string, format: date-time }
 *       - in: query
 *         name: to
 *         schema: { type: string, format: date-time }
 *     responses:
 *       200:
 *         description: Alert summary
 */
router.get(
  '/station/:stationId/alerts',
  authenticateToken,
  authorizeRole(ALLOWED_ROLES),
  controller.getAlertStats
);

/**
 * @swagger
 * /statistics/station/{stationId}/actuators:
 *   get:
 *     summary: Get actuator efficiency (Average Load %)
 *     tags: [Statistics]
 *     security: [{ bearerAuth: [] }]
 *     parameters:
 *       - in: path
 *         name: stationId
 *         required: true
 *         schema: { type: string, format: uuid }
 *       - in: query
 *         name: from
 *         schema: { type: string, format: date-time }
 *       - in: query
 *         name: to
 *         schema: { type: string, format: date-time }
 *     responses:
 *       200:
 *         description: Actuator load statistics
 */
router.get(
  '/station/:stationId/actuators',
  authenticateToken,
  authorizeRole(ALLOWED_ROLES),
  controller.getActuatorStats
);

export default router;
