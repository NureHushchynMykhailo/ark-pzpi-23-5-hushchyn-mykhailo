import { db } from '../config/db';
import { stations, userStations } from '../db/schema';
import { eq, and } from 'drizzle-orm';

export class StationRepository {
  async findAll() {
    return await db.select().from(stations);
  }

  async findById(id: string) {
    const result = await db.select().from(stations).where(eq(stations.id, id)).limit(1);
    return result[0] || null;
  }

  async findByUserId(userId: string) {
    return await db
      .select({
        id: stations.id,
        name: stations.name,
        status: stations.status,
        latitude: stations.latitude,
        longitude: stations.longitude,
        assignedAt: userStations.assignedAt,
      })
      .from(stations)
      .innerJoin(userStations, eq(stations.id, userStations.stationId))
      .where(eq(userStations.userId, userId));
  }

  async create(data: any) {
    const result = await db.insert(stations).values(data).returning();
    return result[0];
  }

  async update(id: string, data: any) {
    const result = await db.update(stations).set(data).where(eq(stations.id, id)).returning();
    return result[0];
  }

  async delete(id: string) {
    const result = await db.delete(stations).where(eq(stations.id, id)).returning();
    return result[0];
  }

  async isUserAssigned(userId: string, stationId: string) {
    const result = await db
      .select()
      .from(userStations)
      .where(and(eq(userStations.userId, userId), eq(userStations.stationId, stationId)))
      .limit(1);
    return result.length > 0;
  }

  async assignUser(userId: string, stationId: string) {
    return await db.insert(userStations).values({ userId, stationId }).returning();
  }

  async unassignUser(userId: string, stationId: string) {
    return await db
      .delete(userStations)
      .where(and(eq(userStations.userId, userId), eq(userStations.stationId, stationId)))
      .returning();
  }
}