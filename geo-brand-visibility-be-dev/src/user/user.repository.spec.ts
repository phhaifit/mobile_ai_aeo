import { Test, TestingModule } from '@nestjs/testing';
import { UserRepository } from './user.repository';
import { SUPABASE } from '../utils/const';
import { PostgrestError } from '@supabase/supabase-js';
import type { Tables } from '../supabase/supabase.types';

type User = Tables<'User'>;

describe('UserRepository', () => {
  let repository: UserRepository;

  const mockUser: User = {
    id: 'user-id',
    email: 'test@example.com',
    fullname: 'Test User',
    passwordHash: 'hashed_password',
    googleId: null,
    isVerified: false,
    avatar: null,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };

  const mockSupabaseClient = {
    from: jest.fn().mockReturnThis(),
    select: jest.fn().mockReturnThis(),
    insert: jest.fn().mockReturnThis(),
    update: jest.fn().mockReturnThis(),
    eq: jest.fn().mockReturnThis(),
    single: jest.fn(),
    maybeSingle: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UserRepository,
        {
          provide: SUPABASE,
          useValue: mockSupabaseClient,
        },
      ],
    }).compile();

    repository = module.get<UserRepository>(UserRepository);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(repository).toBeDefined();
  });

  describe('findById', () => {
    const id = 'user-id';

    it('should find user by id', async () => {
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: mockUser,
        error: null,
      });

      const result = await repository.findById(id);

      expect(result).toEqual(mockUser);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('User');
      expect(mockSupabaseClient.select).toHaveBeenCalledWith('*');
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith('id', id);
    });

    it('should return null when user not found', async () => {
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: null,
        error: null,
      });

      const result = await repository.findById(id);

      expect(result).toBeNull();
    });

    it('should throw error when database operation fails', async () => {
      const error = new Error('Database error') as PostgrestError;
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: null,
        error,
      });

      await expect(repository.findById(id)).rejects.toThrow();
    });
  });

  describe('findByEmail', () => {
    const email = 'test@example.com';

    it('should find user by email', async () => {
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: mockUser,
        error: null,
      });

      const result = await repository.findByEmail(email);

      expect(result).toEqual(mockUser);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('User');
      expect(mockSupabaseClient.select).toHaveBeenCalledWith('*');
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith('email', email);
    });

    it('should return null when user not found', async () => {
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: null,
        error: null,
      });

      const result = await repository.findByEmail(email);

      expect(result).toBeNull();
    });

    it('should throw error when database operation fails', async () => {
      const error = new Error('Database error') as PostgrestError;
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: null,
        error,
      });

      await expect(repository.findByEmail(email)).rejects.toThrow();
    });
  });

  describe('findByGoogleId', () => {
    const googleId = 'google-123';

    it('should find user by Google ID', async () => {
      const googleUser = {
        ...mockUser,
        googleId,
      };

      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: googleUser,
        error: null,
      });

      const result = await repository.findByGoogleId(googleId);

      expect(result).toEqual(googleUser);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('User');
      expect(mockSupabaseClient.select).toHaveBeenCalledWith('*');
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith('googleId', googleId);
    });

    it('should return null when user not found', async () => {
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: null,
        error: null,
      });

      const result = await repository.findByGoogleId(googleId);

      expect(result).toBeNull();
    });

    it('should throw error when database operation fails', async () => {
      const error = new Error('Database error') as PostgrestError;
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: null,
        error,
      });

      await expect(repository.findByGoogleId(googleId)).rejects.toThrow();
    });
  });

  describe('create', () => {
    const newUser = {
      email: 'new@example.com',
      fullname: 'New User',
      passwordHash: 'hashed_new_password',
      isVerified: false,
      avatar: null,
    };

    it('should create user successfully', async () => {
      const createdUser = {
        ...mockUser,
        ...newUser,
        id: 'new-user-id',
      };

      mockSupabaseClient.single.mockResolvedValue({
        data: createdUser,
        error: null,
      });

      const result = await repository.create(newUser);

      expect(result).toEqual(createdUser);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('User');
      expect(mockSupabaseClient.insert).toHaveBeenCalledWith(newUser);
      expect(mockSupabaseClient.select).toHaveBeenCalled();
    });

    it('should throw error when database operation fails', async () => {
      const error = new Error('Database error') as PostgrestError;
      mockSupabaseClient.single.mockResolvedValue({
        data: null,
        error,
      });

      await expect(repository.create(newUser)).rejects.toThrow();
    });
  });

  describe('updateById', () => {
    const userId = 'user-id';
    const updateData = {
      fullname: 'Updated Name',
    };

    it('should update user successfully', async () => {
      const updatedUser = {
        ...mockUser,
        ...updateData,
      };

      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: updatedUser,
        error: null,
      });

      const result = await repository.updateById(userId, updateData);

      expect(result).toEqual(updatedUser);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('User');
      expect(mockSupabaseClient.update).toHaveBeenCalledWith(updateData);
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith('id', userId);
      expect(mockSupabaseClient.select).toHaveBeenCalled();
    });

    it('should return null when user not found', async () => {
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: null,
        error: null,
      });

      const result = await repository.updateById(userId, updateData);

      expect(result).toBeNull();
    });

    it('should throw error when database operation fails', async () => {
      const error = new Error('Database error') as PostgrestError;
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: null,
        error,
      });

      await expect(repository.updateById(userId, updateData)).rejects.toThrow();
    });
  });
});
