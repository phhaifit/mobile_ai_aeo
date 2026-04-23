import { Injectable, Logger } from '@nestjs/common';
import type { Response } from 'express';

type StreamSession = {
  userId: string;
  createdAt: number;
  res?: Response;
  heartbeatTimer?: NodeJS.Timeout;
};

@Injectable()
export class SseService {
  private readonly logger = new Logger(SseService.name);
  private readonly sessions = new Map<string, StreamSession>();

  createChannel(channelId: string, userId: string) {
    this.sessions.set(channelId, { userId, createdAt: Date.now() });
  }

  attach(
    channelId: string,
    userId: string,
    res: Response,
  ): 'ok' | 'not_found' | 'forbidden' {
    const session = this.sessions.get(channelId);
    if (!session) return 'not_found';
    if (session.userId !== userId) return 'forbidden';

    this.prepareStream(res);
    session.res = res;

    res.on('close', () => {
      this.logger.log(`SSE closed for channel ${channelId}`);
      const current = this.sessions.get(channelId);
      if (current) {
        clearInterval(current.heartbeatTimer);
        current.heartbeatTimer = undefined;
        current.res = undefined;
      }
    });

    session.heartbeatTimer = setInterval(() => {
      try {
        session.res?.write(': ping\n\n');
      } catch {
        // Client disconnected; close handler will clean up
      }
    }, 15000);

    this.send(channelId, 'ready', { channelId });
    return 'ok';
  }

  send(channelId: string, event: string, data: unknown) {
    const session = this.sessions.get(channelId);
    if (!session?.res) return;

    try {
      session.res.write(`event: ${event}\n`);
      session.res.write(`data: ${JSON.stringify(data)}\n\n`);
    } catch (error) {
      this.logger.warn(
        `Failed to write SSE event for channel ${channelId}: ${String(error)}`,
      );
    }
  }

  close(channelId: string) {
    const session = this.sessions.get(channelId);
    if (!session) return;
    clearInterval(session.heartbeatTimer);
    if (session.res) {
      session.res.end();
    }
    this.sessions.delete(channelId);
  }

  private prepareStream(res: Response) {
    res.status(200);
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache, no-transform');
    res.setHeader('Connection', 'keep-alive');
    res.setHeader('X-Accel-Buffering', 'no');
    res.flushHeaders?.();
  }
}
