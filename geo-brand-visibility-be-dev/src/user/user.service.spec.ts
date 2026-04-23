import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException } from '@nestjs/common';
import { UserService } from './user.service';
import { UserRepository } from './user.repository';

describe('UserService', () => {
  let service: UserService;
  let userRepository: { findById: jest.Mock };

  beforeEach(async () => {
    userRepository = { findById: jest.fn() };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UserService,
        { provide: UserRepository, useValue: userRepository },
      ],
    }).compile();

    service = module.get<UserService>(UserService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('getUserProfile', () => {
    it('should return user profile when user is found', async () => {
      const user = {
        id: '1',
        fullname: 'Test User',
        email: 'test@example.com',
        avatar: 'avatar.png',
      };
      userRepository.findById.mockResolvedValue(user);

      const result = await service.getUserProfile('1');

      expect(result).toEqual({
        id: user.id,
        fullname: user.fullname,
        email: user.email,
        avatar: user.avatar,
      });
      expect(userRepository.findById).toHaveBeenCalledWith('1');
    });

    it('should throw NotFoundException when user is not found', async () => {
      userRepository.findById.mockResolvedValue(null);

      await expect(service.getUserProfile('2')).rejects.toThrow(
        NotFoundException,
      );
      expect(userRepository.findById).toHaveBeenCalledWith('2');
    });
  });
});
