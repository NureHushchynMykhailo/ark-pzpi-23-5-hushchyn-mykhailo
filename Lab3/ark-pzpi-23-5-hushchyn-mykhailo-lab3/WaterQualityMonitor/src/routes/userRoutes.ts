import { Router } from 'express';
import { UserController } from '../controllers/userController';
import { authenticateToken, authorizeRole } from '../middlewares/authMiddleware';

const router = Router();
const controller = new UserController();

/**
 * @swagger
 * tags:
 *   name: Users
 *   description: User Management and Authentication
 */


/**
 * @swagger
 * /users/profile:
 *   get:
 *     summary: Get current user profile
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: User profile data
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: User not found
 */
router.get(
    '/profile',
    authenticateToken,
    controller.getProfile
);

/**
 * @swagger
 * /users:
 *   get:
 *     summary: Get all users (Admin only)
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of all users
 *       403:
 *         description: Forbidden - Admin access required
 */
router.get(
    '/',
    authenticateToken,
    authorizeRole(['admin']),
    controller.getAllUsers
);

/**
 * @swagger
 * /users/{id}:
 *   delete:
 *     summary: Delete a user by ID (Admin only)
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: The user ID
 *     responses:
 *       200:
 *         description: User deleted successfully
 *       403:
 *         description: Forbidden - Admin access required
 *       404:
 *         description: User not found
 */
router.delete(
    '/:id',
    authenticateToken,
    authorizeRole(['admin']),
    controller.deleteUser
);

export default router;
