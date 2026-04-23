import { Injectable, NotFoundException } from '@nestjs/common';
import { UserRepository } from './user.repository';
import { UserProfileResponseDTO } from './dto/user-profile-response.dto';

@Injectable()
export class UserService {
  constructor(private readonly userRepository: UserRepository) {}

  async getUserProfile(id: string): Promise<UserProfileResponseDTO> {
    const user = await this.userRepository.findById(id);

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return {
      id: user.id,
      fullname: user.fullname,
      email: user.email,
      avatar: user.avatar,
      hasSeenTour: (user as any).hasSeenTour ?? false,
    };
  }

  async markTourSeen(id: string): Promise<void> {
    await this.userRepository.updateById(id, { hasSeenTour: true } as any);
  }
}
