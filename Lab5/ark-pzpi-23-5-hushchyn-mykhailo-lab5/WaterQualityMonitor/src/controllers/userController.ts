import { Request, Response } from 'express';
import { UserRepository } from '../repositories/userRepository';
import { AuthRequest } from '../middlewares/authMiddleware';

const userRepo = new UserRepository();

export class UserController {
  async getProfile(req: AuthRequest, res: Response) {
    try {
      const user = await userRepo.findById(req.user!.id);
      if (!user) return res.status(404).json({ error: 'User not found' });

      res.json({ 
        id: user.id, 
        email: user.email, 
        fullName: user.fullName, 
        role: user.role,
        createdAt: user.createdAt 
      });
    } catch (e) {
      res.status(500).json({ error: 'Server error' });
    }
  }

  async getAllUsers(req: Request, res: Response) {
    try {
      const all = await userRepo.findAll();
      res.json(all);
    } catch (e) {
      res.status(500).json({ error: 'Failed to fetch users' });
    }
  }

  async deleteUser(req: Request, res: Response) {
    try {
      const deleted = await userRepo.delete(req.params.id);
      if (!deleted) return res.status(404).json({ error: 'User not found' });
      res.json({ message: 'User deleted successfully' });
    } catch (e) {
      res.status(500).json({ error: 'Delete failed' });
    }
  }
}