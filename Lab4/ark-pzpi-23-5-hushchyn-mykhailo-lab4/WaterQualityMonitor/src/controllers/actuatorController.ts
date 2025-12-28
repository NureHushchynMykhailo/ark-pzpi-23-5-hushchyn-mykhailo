import { Request, Response } from 'express';
import { ActuatorRepository } from '../repositories/actuatorRepository';
import { z } from 'zod';

const repo = new ActuatorRepository();

const createSchema = z.object({
  stationId: z.string().uuid(),
  name: z.string().min(2),
  type: z.enum([
    'aerator', 
    'filter', 
    'pump', 
    'dispenser_acid', 
    'dispenser_alkali', 
    'dispenser_chlorine', 
    'valve'
  ]),
  isActive: z.boolean().default(false),
});

const updateSchema = z.object({
  name: z.string().optional(),
  isActive: z.boolean().optional(),
});

const logSchema = z.object({
  controllerId: z.string().uuid(),
  activationPercentage: z.number().min(0).max(100), 
  statusMessage: z.string().optional(),
  timestamp: z.string().datetime().optional(),
});

export class ActuatorController {

  async getByStation(req: Request, res: Response) {
    try {
      const { stationId } = req.params;
      const devices = await repo.findByStation(stationId);
      res.json(devices);
    } catch (e) {
      res.status(500).json({ error: 'Failed to fetch actuators' });
    }
  }

  async create(req: Request, res: Response) {
    try {
      const data = createSchema.parse(req.body);
      const device = await repo.create(data);
      res.status(201).json(device);
    } catch (e) {
      if (e instanceof z.ZodError) return res.status(400).json({ errors: e.issues });
      res.status(500).json({ error: 'Failed to create actuator' });
    }
  }

  async update(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const data = updateSchema.parse(req.body);
      
      const updated = await repo.update(id, data);
      if (!updated) return res.status(404).json({ error: 'Actuator not found' });
      
      res.json(updated);
    } catch (e) {
      if (e instanceof z.ZodError) return res.status(400).json({ errors: e.issues });
      res.status(500).json({ error: 'Update failed' });
    }
  }

  async delete(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const deleted = await repo.delete(id);
      if (!deleted) return res.status(404).json({ error: 'Actuator not found' });
      res.json({ message: 'Actuator deleted' });
    } catch (e) {
      res.status(500).json({ error: 'Delete failed' });
    }
  }

 
  async registerState(req: Request, res: Response) {
    try {
      const data = logSchema.parse(req.body);
      
   
      const device = await repo.findById(data.controllerId);
      if (!device) return res.status(404).json({ error: 'Controller ID not found' });

      const log = await repo.logState({
        controllerId: data.controllerId,
        activationPercentage: data.activationPercentage.toString(),
        statusMessage: data.statusMessage,
        timestamp: data.timestamp ? new Date(data.timestamp) : new Date(),
      });

      res.status(201).json(log);
    } catch (e) {
      if (e instanceof z.ZodError) return res.status(400).json({ errors: e.issues });
      res.status(500).json({ error: 'Failed to log state' });
    }
  }


  async getHistory(req: Request, res: Response) {
    try {
      const { id } = req.params; 
      const logs = await repo.getLogs(id);
      res.json(logs);
    } catch (e) {
      res.status(500).json({ error: 'Failed to fetch history' });
    }
  }
  
  async getLatestStateByStation(req: Request, res: Response) {
    try {
      const { stationId } = req.params;
      
      const result = await repo.findLatestStateByStation(stationId);
      
      res.json(result);
    } catch (e) {
      console.error(e);
      res.status(500).json({ error: 'Failed to fetch actuators state' });
    }
  }
}