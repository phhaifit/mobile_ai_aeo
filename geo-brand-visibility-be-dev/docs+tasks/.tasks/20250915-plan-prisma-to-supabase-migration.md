# GEO Brand Visibility Backend: Prisma to Supabase Migration Plan

## Overview

This plan outlines the steps to replace Prisma ORM with the Supabase SDK in the GEO Brand Visibility backend application. The codebase is a NestJS application that currently uses Prisma ORM for database operations, and we need to migrate to Supabase SDK.

## 1. Project Setup

- [x] Install and configure required Supabase dependencies
  - [x] Verify Supabase SDK is correctly installed (`@supabase/supabase-js`)
  - [x] Set up environment variables for Supabase connection

- [ ] Update project configuration
  - [ ] Remove Prisma-specific scripts from package.json
  - [x] Add Supabase-specific scripts to package.json

## 2. Backend Foundation

- [x] Complete Supabase service implementation
  - [x] Ensure SupabaseService provides proper access to Supabase client

- [ ] Create type definitions and interfaces
  - [ ] Update Supabase type definitions for all database tables
  - [ ] Create interfaces for all database operations that mirror Prisma client functionality

## 3. Service Migration

- [x] User service migration
  - [x] Update UserService to use SupabaseService instead of PrismaService
  - [x] Refactor findByEmail, create, update, markAsVerified, findById, and findByGoogleId methods

- [x] Brand service migration
  - [x] Update BrandService to use SupabaseService instead of PrismaService
  - [x] Refactor initializeBrandContext, getBrand, updateBrand, and findBrandByProjectId methods
  - [x] Update the raw SQL query execution for vector operations

- [x] Project service migration
  - [x] Update ProjectService to use SupabaseService instead of PrismaService
  - [x] Refactor createProject, findProjectById, findProjectsByUser, updateProject, and deleteProject methods

- [x] Prompt service migration
  - [x] Update PromptService to use SupabaseService instead of PrismaService
  - [x] Refactor generatePrompts, saveSelectedPrompts, getPromptsByProject, and deletePrompt methods

- [x] Auth service migration (if applicable)
  - [x] Update any auth-related services to use SupabaseService
  - [x] Consider leveraging Supabase Auth if appropriate

## 4. Testing

- [ ] Unit testing
  - [ ] Update all unit tests to use SupabaseService mocks instead of PrismaService
  - [ ] Add tests for new Supabase-specific functionality

- [ ] Integration testing
  - [ ] Create test setup for Supabase in test environment
  - [ ] Update integration tests to use Supabase
  - [ ] Test all CRUD operations with the new implementation

- [ ] End-to-end testing
  - [ ] Verify all API endpoints work with Supabase implementation
  - [ ] Test all complex operations like vector searches and transactions

## 5. Documentation

- [x] Update API documentation
  - [x] Document any API changes due to the migration
  - [x] Update Swagger documentation if necessary

- [x] Developer documentation
  - [x] Document the new data access patterns using Supabase
  - [x] Create examples for common operations
  - [x] Document any differences in behavior between Prisma and Supabase implementations

## 6. Deployment

- [ ] Update CI/CD pipeline
  - [ ] Remove Prisma migration steps
  - [ ] Add Supabase-specific environment setup

- [ ] Environment setup
  - [ ] Configure Supabase connection in all environments
  - [ ] Update secrets and environment variables

## 7. Cleanup

- [x] Remove Prisma dependencies
  - [x] Remove Prisma packages from package.json
  - [x] Delete Prisma schema and migration files
  - [x] Remove PrismaModule from app.module.ts

- [x] Code cleanup
  - [x] Remove any unused imports and references to Prisma
  - [x] Format and lint the codebase

## Migration Strategy

1. Ensure the SupabaseService provides proper access to the Supabase client
2. Create documentation for using Supabase client directly in services
3. Migrate one service at a time, beginning with simpler ones like UserService
4. Test each service thoroughly before moving to the next
5. Address complex features like vector search and transactions after basic CRUD operations are working
6. Migrate tests alongside each service
7. Complete a full end-to-end test after all services are migrated
8. Clean up and remove Prisma dependencies only after ensuring everything works
