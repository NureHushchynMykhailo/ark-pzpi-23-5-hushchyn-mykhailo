import { Router } from 'express';
import { StationController } from '../controllers/stationController';
import { 

  checkStationAccess 
} from '../middlewares/stationMiddleware';
import { authenticateToken, authorizeRole } from '../middlewares/authMiddleware';
const router = Router();
const controller = new StationController();

/**
 * @swagger
 * tags:
 *   name: Stations
 *   description: IoT Station Management (CRUD & Assignments)
 */

/**
 * @swagger
 * /stations:
 *   post:
 *     summary: Create a new station
 *     tags: [Stations]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *             properties:
 *               name:
 *                 type: string
 *                 description: The name of the station
 *               latitude:
 *                 type: number
 *                 format: double
 *               longitude:
 *                 type: number
 *                 format: double
 *               status:
 *                 type: string
 *                 enum: [active, offline, maintenance]
 *     responses:
 *       201:
 *         description: Station created successfully
 *       400:
 *         description: Invalid input data
 *       403:
 *         description: Forbidden - Requires Admin or Manager role
 */
router.post(
    '/',
    authenticateToken,
    authorizeRole(['admin', 'manager']),
    controller.create
);

/**
 * @swagger
 * /stations:
 *   get:
 *     summary: Get all stations (Admin/Manager only)
 *     tags: [Stations]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of all stations
 *       403:
 *         description: Forbidden - Requires Admin or Manager role
 */
router.get(
    '/',
    authenticateToken,
    authorizeRole(['admin', 'manager']),
    controller.getAll
);

/**
 * @swagger
 * /stations/my:
 *   get:
 *     summary: Get stations assigned to the current user
 *     tags: [Stations]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of assigned stations
 *       401:
 *         description: Unauthorized
 */
router.get(
    '/my',
    authenticateToken,
    controller.getMyStations
);

/**
 * @swagger
 * /stations/assign:
 *   post:
 *     summary: Assign a user to a station
 *     tags: [Stations]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - userId
 *               - stationId
 *             properties:
 *               userId:
 *                 type: string
 *                 format: uuid
 *               stationId:
 *                 type: string
 *                 format: uuid
 *     responses:
 *       201:
 *         description: User assigned successfully
 *       409:
 *         description: User already assigned to this station
 *       403:
 *         description: Forbidden - Requires Admin or Manager role
 */
router.post(
    '/assign',
    authenticateToken,
    authorizeRole(['admin', 'manager']),
    controller.assignUser
);

/**
 * @swagger
 * /stations/assign:
 *   delete:
 *     summary: Unassign a user from a station
 *     tags: [Stations]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - userId
 *               - stationId
 *             properties:
 *               userId:
 *                 type: string
 *                 format: uuid
 *               stationId:
 *                 type: string
 *                 format: uuid
 *     responses:
 *       200:
 *         description: User unassigned successfully
 *       404:
 *         description: Assignment not found
 *       403:
 *         description: Forbidden - Requires Admin or Manager role
 */
router.delete(
    '/assign',
    authenticateToken,
    authorizeRole(['admin', 'manager']),
    controller.unassignUser
);

/**
 * @swagger
 * /stations/{id}:
 *   patch:
 *     summary: Update station details
 *     tags: [Stations]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: The station ID
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               status:
 *                 type: string
 *                 enum: [active, offline, maintenance]
 *               latitude:
 *                 type: number
 *               longitude:
 *                 type: number
 *     responses:
 *       200:
 *         description: Station updated successfully
 *       404:
 *         description: Station not found
 *       403:
 *         description: Forbidden - Requires Admin or Manager role
 */
router.patch(
    '/:id',
    authenticateToken,
    authorizeRole(['admin', 'manager']),
    controller.update
);

/**
 * @swagger
 * /stations/{id}:
 *   delete:
 *     summary: Delete a station
 *     tags: [Stations]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: The station ID
 *     responses:
 *       200:
 *         description: Station deleted successfully
 *       404:
 *         description: Station not found
 *       403:
 *         description: Forbidden - Requires Admin role
 */
router.delete(
    '/:id',
    authenticateToken,
    authorizeRole(['admin']),
    controller.delete
);

/**
 * @swagger
 * /stations/{id}:
 *   get:
 *     summary: Get station details (Access Checked)
 *     description: >
 *       Returns station details if the user is Admin/Manager
 *       or if the user is assigned to this station.
 *     tags: [Stations]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: The station ID
 *     responses:
 *       200:
 *         description: Station details
 *       403:
 *         description: Forbidden - You are not assigned to this station
 *       404:
 *         description: Station not found
 */
router.get(
    '/:id',
    authenticateToken,
    checkStationAccess,
    controller.getById
);

export default router;
