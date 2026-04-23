import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { v4 as uuidv4 } from 'uuid';

type SuccessResponse<T> = {
  status: 'success';
  data: T;
};

type ErrorResponse = {
  status: 'error';
  error_message: string;
};

type AgentResponse<T> = SuccessResponse<T> | ErrorResponse;

@Injectable()
export class AgentService {
  private readonly logger = new Logger(AgentService.name);
  private readonly baseUrl: string;

  constructor(private readonly configService: ConfigService) {
    this.baseUrl = this.configService.get<string>('AGENT_BASE_URL')!;
  }

  private getURL(userId: string, agent: string, sessionId: string): string {
    return `${this.baseUrl}/apps/${agent}/users/${userId}/sessions/${sessionId}`;
  }

  public async execute<T>(
    userId: string,
    agent: string,
    prompt: string,
    state?: Record<string, unknown>,
  ): Promise<T> {
    let sessionId: string | null = null;
    try {
      sessionId = await this.createSession(userId, agent, state);
      return await this.sendPrompt<T>(userId, agent, prompt, sessionId);
    } catch (error) {
      this.logger.error(`Error executing agent: ${error.message}`, error.stack);
      throw error;
    } finally {
      if (sessionId) {
        await this.deleteSession(userId, agent, sessionId);
      }
    }
  }

  public async createSession(
    userId: string,
    agent: string,
    state?: Record<string, unknown>,
  ): Promise<string> {
    const sessionId = uuidv4();

    const response = await fetch(this.getURL(userId, agent, sessionId), {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(state ?? {}),
    });

    if (!response.ok) {
      throw new Error(`Failed to create session: ${response.statusText}`);
    }

    return sessionId;
  }

  public async deleteSession(
    userId: string,
    agent: string,
    sessionId: string,
  ): Promise<void> {
    const response = await fetch(this.getURL(userId, agent, sessionId), {
      method: 'DELETE',
    });

    if (!response.ok) {
      throw new Error(`Failed to delete session: ${response.statusText}`);
    }
  }

  public async sendPrompt<T>(
    userId: string,
    agent: string,
    prompt: string,
    sessionId: string,
  ): Promise<T> {
    const response = await fetch(`${this.baseUrl}/run`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        app_name: agent,
        user_id: userId,
        session_id: sessionId,
        new_message: {
          role: 'user',
          parts: [
            {
              text: prompt,
            },
          ],
        },
        streaming: false,
      }),
    });

    if (!response.ok) {
      throw new Error(`Failed to send prompt: ${response.statusText}`);
    }

    const json = (await response.json()) as any[];
    this.logger.log(json);
    this.logger.log('Agent response: ', json[json.length - 1]);

    const data = JSON.parse(
      this.sanitizeJsonString(
        // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
        json[json.length - 1].content.parts[0]?.text as string,
      ),
    ) as AgentResponse<T>;

    if (data.status === 'error') {
      throw new Error(`Agent error: ${data.error_message}`);
    }

    return data.data;
  }

  private sanitizeJsonString(input: string): string {
    return input
      .replace(/```json\s*/g, '')
      .replace(/```/g, '')
      .trim();
  }
}
