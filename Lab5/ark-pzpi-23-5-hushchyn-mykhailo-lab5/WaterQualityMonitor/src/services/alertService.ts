import { db } from '../config/db';
import { alerts, stationThresholds, sensors, parameters } from '../db/schema';
import { eq, and, like, isNull } from 'drizzle-orm';

export class AlertService {

  /**
   * Головний метод: Перевірка значення, створення АБО закриття алерту
   */
  async checkAndCreateAlert(sensorId: string, value: number) {
  
    const sensorContext = await db
      .select({
        stationId: sensors.stationId,
        parameterId: sensors.parameterId,
        paramName: parameters.name,
        paramUnit: parameters.unit
      })
      .from(sensors)
      .innerJoin(parameters, eq(sensors.parameterId, parameters.id))
      .where(eq(sensors.id, sensorId))
      .limit(1);

    if (!sensorContext.length) return;
    const { stationId, parameterId, paramName, paramUnit } = sensorContext[0];

    const rulesData = await db
      .select()
      .from(stationThresholds)
      .where(
        and(
          eq(stationThresholds.stationId, stationId),
          eq(stationThresholds.parameterId, parameterId)
        )
      )
      .limit(1);

    if (!rulesData.length) return;
    const rules = rulesData[0];

    const isLow = rules.minWarning !== null && value < rules.minWarning;
    const isHigh = rules.maxWarning !== null && value > rules.maxWarning;
    const isNormal = !isLow && !isHigh;

    if (isNormal) {
      await this.resolveActiveAlerts(stationId, paramName);
      return; 
    }

    let type: 'critical' | 'warning' | null = null;
    let message = '';
    let role: 'admin' | 'technician' = 'technician';

    if (rules.minCritical !== null && value <= rules.minCritical) {
      type = 'critical';
      role = 'admin';
      message = `CRITICAL LOW: ${paramName} is ${value} ${paramUnit} (Limit: ${rules.minCritical})`;
    } 
    else if (rules.maxCritical !== null && value >= rules.maxCritical) {
      type = 'critical';
      role = 'admin';
      message = `CRITICAL HIGH: ${paramName} is ${value} ${paramUnit} (Limit: ${rules.maxCritical})`;
    }
    else if (isLow) {
      type = 'warning';
      message = `Warning Low: ${paramName} is ${value} ${paramUnit} (Limit: ${rules.minWarning})`;
    }
    else if (isHigh) {
      type = 'warning';
      message = `Warning High: ${paramName} is ${value} ${paramUnit} (Limit: ${rules.maxWarning})`;
    }

    if (type && message) {
      await this.createAlertIfNotExists(stationId, type, role, message);
    }
  }


  private async resolveActiveAlerts(stationId: string, paramName: string) {
    
    const alertsToResolve = await db
      .select()
      .from(alerts)
      .where(
        and(
          eq(alerts.stationId, stationId),
          eq(alerts.isResolved, false),
          like(alerts.message, `%${paramName}%`) 
        )
      );

    if (alertsToResolve.length > 0) {
      console.log(` Auto-resolving ${alertsToResolve.length} alerts for ${paramName}`);
      
      await db
        .update(alerts)
        .set({
          isResolved: true,
          resolvedAt: new Date(),
        })
        .where(
          and(
            eq(alerts.stationId, stationId),
            eq(alerts.isResolved, false),
            like(alerts.message, `%${paramName}%`)
          )
        );
    }
  }

  /**
   * Створення алерту з захистом від дублікатів
   */
  private async createAlertIfNotExists(
    stationId: string, 
    type: 'critical' | 'warning', 
    targetRole: 'admin' | 'technician', 
    message: string
  ) {
    const existing = await db
      .select()
      .from(alerts)
      .where(
        and(
          eq(alerts.stationId, stationId),
          eq(alerts.isResolved, false),
          eq(alerts.message, message)
        )
      )
      .limit(1);

    if (existing.length === 0) {
      console.log(` New Alert: [${type.toUpperCase()}] ${message}`);
      
      await db.insert(alerts).values({
        stationId,
        type,
        targetRole,
        message,
        isResolved: false,
        createdAt: new Date()
      });
    }
  }
}