import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

export interface TokenPayload {
  sub: string;
  email: string;
  iat?: number;
  exp?: number;
}

@Injectable()
export class TokenService {
  constructor(private readonly jwt: JwtService) {}

  private async generateToken(data: {
    userId: string;
    email: string;
  }): Promise<string> {
    const payload: TokenPayload = { sub: data.userId, email: data.email };
    return this.jwt.signAsync(payload);
  }

  // private async generatePerpetualToken(data: {
  //   userId: string;
  //   email: string;
  // }): Promise<string> {
  //   const payload: TokenPayload = { sub: data.userId, email: data.email };
  //   return this.jwt.signAsync(payload);
  // }

  async validateToken(token: string): Promise<TokenPayload> {
    return this.jwt.verifyAsync<TokenPayload>(token);
  }

  async generateTokens(
    userId: string,
    email: string,
  ): Promise<{
    accessToken: string;
  }> {
    const accessToken = await this.generateToken({ userId, email });
    return { accessToken };
  }

  // async generatePerpetualTokens(
  //   userId: string,
  //   email: string,
  // ): Promise<{
  //   accessToken: string;
  // }> {
  //   const accessToken = await this.generatePerpetualToken({ userId, email });
  //   return { accessToken };
  // }
}
