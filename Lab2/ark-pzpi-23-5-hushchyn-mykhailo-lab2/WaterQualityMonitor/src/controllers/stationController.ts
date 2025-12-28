import { Response } from 'express';
import { StationRepository } from '../repositories/stationRepository';
import { AuthRequest } from '../middlewares/authMiddleware';
import { z } from 'zod';

const stationRepo = new StationRepository();

const stationSchema = z.object({
  name: z.string().min(2, 'Name must contain at least 2 characters'),
  latitude: z.number().optional(),
  longitude: z.number().optional(),
  status: z.enum(['active', 'offline', 'maintenance']).optional(),
});

const assignSchema = z.object({
  userId: z.string().uuid(),
  stationId: z.string().uuid(),
});

export class StationController {
  async create(req: AuthRequest, res: Response) {
    try {
      const data = stationSchema.parse(req.body);
      const newStation = await stationRepo.create(data);
      res.status(201).json(newStation);
    } catch (e) {
      res.status(400).json({ error: 'Invalid data' });
    }
  }

  async getAll(req: AuthRequest, res: Response) {
    try {
      const result = await stationRepo.findAll();
      res.json(result);
    } catch (e) {
      res.status(500).json({ error: 'Failed to load stations' });
    }
  }

  async getMyStations(req: AuthRequest, res: Response) {
    try {
      const userId = req.user!.id;
      if (req.user!.role === 'admin') {
        const all = await stationRepo.findAll();
        return res.json(all);
      }
      const my = await stationRepo.findByUserId(userId);
      res.json(my);
    } catch (e) {
      res.status(500).json({ error: 'Failed to load assigned stations' });
    }
  }

  async getById(req: AuthRequest, res: Response) {
    try {
      const station = await stationRepo.findById(req.params.id);
      if (!station) return res.status(404).json({ error: 'Station not found' });
      res.json(station);
    } catch (e) {
      res.status(500).json({ error: 'Server error' });
    }
  }

  async update(req: AuthRequest, res: Response) {
    try {
      const data = stationSchema.partial().parse(req.body);
      const updated = await stationRepo.update(req.params.id, data);
      if (!updated) return res.status(404).json({ error: 'Station not found' });
      res.json(updated);
    } catch (e) {
      res.status(400).json({ error: 'Validation failed' });
    }
  }

  async delete(req: AuthRequest, res: Response) {
    try {
      const deleted = await stationRepo.delete(req.params.id);
      if (!deleted) return res.status(404).json({ error: 'Station not found' });
      res.json({ message: 'Deleted successfully', id: req.params.id });
    } catch (e) {
      res.status(500).json({ error: 'Failed to delete station' });
    }
  }

  async assignUser(req: AuthRequest, res: Response) {
    try {
      const { userId, stationId } = assignSchema.parse(req.body);
      const alreadyAssigned = await stationRepo.isUserAssigned(userId, stationId);
      if (alreadyAssigned) return res.status(409).json({ error: 'User already assigned' });
      
      await stationRepo.assignUser(userId, stationId);
      res.status(201).json({ message: 'User assigned successfully' });
    } catch (e) {
      res.status(400).json({ error: 'Invalid assignment data' });
    }
  }

  async unassignUser(req: AuthRequest, res: Response) {
    try {
      const { userId, stationId } = assignSchema.parse(req.body);
      const deleted = await stationRepo.unassignUser(userId, stationId);
      if (deleted.length === 0) return res.status(404).json({ error: 'Assignment not found' });
      res.json({ message: 'User unassigned successfully' });
    } catch (e) {
      res.status(400).json({ error: 'Invalid data' });
    }
  }
}