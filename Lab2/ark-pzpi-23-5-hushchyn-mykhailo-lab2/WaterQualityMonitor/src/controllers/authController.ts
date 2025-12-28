import { Request, Response } from 'express';
import { UserRepository } from '../repositories/userRepository';
import { hashPassword, comparePasswords, generateToken } from '../utils/jwt';
import { z } from 'zod';

const userRepo = new UserRepository();

const registerSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
  fullName: z.string().optional(),
  role: z.enum(['admin', 'manager', 'technician', 'analyst', 'viewer']).optional()
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string()
});

export class AuthController {
  async register(req: Request, res: Response) {
    try {
      const data = registerSchema.parse(req.body);
      const existing = await userRepo.findByEmail(data.email);
      if (existing) return res.status(400).json({ error: 'Email already in use' });

      const hashedPassword = await hashPassword(data.password);
      const user = await userRepo.create({
        ...data,
        passwordHash: hashedPassword
      });

      res.status(201).json({ id: user.id, email: user.email, role: user.role });
    } catch (e) {
      res.status(400).json({ error: 'Registration failed or invalid data' });
    }
  }

  async login(req: Request, res: Response) {
    try {
      const { email, password } = loginSchema.parse(req.body);
      const user = await userRepo.findByEmail(email);
      if (!user) return res.status(401).json({ error: 'Invalid credentials' });

      const isMatch = await comparePasswords(password, user.passwordHash);
      if (!isMatch) return res.status(401).json({ error: 'Invalid credentials' });

      const token = generateToken({ id: user.id, role: user.role || 'viewer' });
      res.json({ token, user: { id: user.id, email: user.email, role: user.role } });
    } catch (e) {
      res.status(400).json({ error: 'Login failed' });
    }
  }
}