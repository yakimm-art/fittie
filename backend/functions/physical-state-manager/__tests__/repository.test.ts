/**
 * Unit tests for Physical State Repository
 * Tests DynamoDB operations with mocked client
 */

import { mockClient } from 'aws-sdk-client-mock';
import { DynamoDBDocumentClient, PutCommand, QueryCommand, DeleteCommand } from '@aws-sdk/lib-dynamodb';
import { PhysicalStateRepository, RepositoryError } from '../repository';
import { PhysicalStateRecord, BodyPart, EquipmentType } from '../types';

// Mock the DynamoDB Document Client
const ddbMock = mockClient(DynamoDBDocumentClient);

describe('PhysicalStateRepository', () => {
  let repository: PhysicalStateRepository;

  const mockStateRecord: PhysicalStateRecord = {
    userId: 'user-123',
    timestamp: 1704067200000,
    painPoints: [BodyPart.LOWER_BACK],
    energyLevel: 3,
    equipment: [EquipmentType.DUMBBELLS],
    location: 'gym',
    activityMode: 'active',
    sourceEvent: 'voice',
    ttl: 1711929600,
  };

  beforeEach(() => {
    ddbMock.reset();
    repository = new PhysicalStateRepository();
  });

  describe('saveState', () => {
    it('should save a state record successfully', async () => {
      ddbMock.on(PutCommand).resolves({});

      const result = await repository.saveState(mockStateRecord);

      expect(result).toEqual(mockStateRecord);
      expect(ddbMock.calls()).toHaveLength(1);
    });

    it('should throw RepositoryError on DynamoDB failure', async () => {
      ddbMock.on(PutCommand).rejects(new Error('DynamoDB error'));

      await expect(repository.saveState(mockStateRecord)).rejects.toThrow(RepositoryError);
    });

    it('should handle DynamoDB errors gracefully', async () => {
      // Test that errors are wrapped in RepositoryError
      ddbMock.on(PutCommand).rejects(new Error('Connection failed'));

      await expect(repository.saveState(mockStateRecord)).rejects.toThrow(RepositoryError);
      await expect(repository.saveState(mockStateRecord)).rejects.toMatchObject({
        operation: 'saveState',
      });
    });
  });

  describe('getLatestState', () => {
    it('should return the latest state for a user', async () => {
      ddbMock.on(QueryCommand).resolves({
        Items: [mockStateRecord],
      });

      const result = await repository.getLatestState('user-123');

      expect(result).toEqual(mockStateRecord);
      expect(ddbMock.calls()).toHaveLength(1);
    });

    it('should return null when no state exists', async () => {
      ddbMock.on(QueryCommand).resolves({
        Items: [],
      });

      const result = await repository.getLatestState('user-123');

      expect(result).toBeNull();
    });

    it('should throw RepositoryError on DynamoDB failure', async () => {
      ddbMock.on(QueryCommand).rejects(new Error('DynamoDB error'));

      await expect(repository.getLatestState('user-123')).rejects.toThrow(RepositoryError);
    });
  });

  describe('getStateHistory', () => {
    const mockHistory: PhysicalStateRecord[] = [
      { ...mockStateRecord, timestamp: 1704153600000 },
      { ...mockStateRecord, timestamp: 1704067200000 },
    ];

    it('should return state history for a user', async () => {
      ddbMock.on(QueryCommand).resolves({
        Items: mockHistory,
      });

      const result = await repository.getStateHistory({ userId: 'user-123' });

      expect(result).toEqual(mockHistory);
      expect(result).toHaveLength(2);
    });

    it('should filter by timestamp range', async () => {
      ddbMock.on(QueryCommand).resolves({
        Items: [mockHistory[0]],
      });

      const result = await repository.getStateHistory({
        userId: 'user-123',
        fromTimestamp: 1704100000000,
        toTimestamp: 1704200000000,
      });

      expect(result).toHaveLength(1);
      expect(ddbMock.calls()).toHaveLength(1);
    });

    it('should filter by fromTimestamp only', async () => {
      ddbMock.on(QueryCommand).resolves({
        Items: mockHistory,
      });

      const result = await repository.getStateHistory({
        userId: 'user-123',
        fromTimestamp: 1704000000000,
      });

      expect(result).toHaveLength(2);
    });

    it('should filter by toTimestamp only', async () => {
      ddbMock.on(QueryCommand).resolves({
        Items: mockHistory,
      });

      const result = await repository.getStateHistory({
        userId: 'user-123',
        toTimestamp: 1704200000000,
      });

      expect(result).toHaveLength(2);
    });

    it('should respect limit parameter', async () => {
      ddbMock.on(QueryCommand).resolves({
        Items: [mockHistory[0]],
      });

      const result = await repository.getStateHistory({
        userId: 'user-123',
        limit: 10,
      });

      expect(result).toHaveLength(1);
    });

    it('should return empty array when no history exists', async () => {
      ddbMock.on(QueryCommand).resolves({
        Items: [],
      });

      const result = await repository.getStateHistory({ userId: 'user-123' });

      expect(result).toEqual([]);
    });

    it('should throw RepositoryError on DynamoDB failure', async () => {
      ddbMock.on(QueryCommand).rejects(new Error('DynamoDB error'));

      await expect(repository.getStateHistory({ userId: 'user-123' })).rejects.toThrow(RepositoryError);
    });
  });

  describe('deleteState', () => {
    it('should delete a state record successfully', async () => {
      ddbMock.on(DeleteCommand).resolves({});

      await expect(repository.deleteState('user-123', 1704067200000)).resolves.not.toThrow();
      expect(ddbMock.calls()).toHaveLength(1);
    });

    it('should throw RepositoryError on DynamoDB failure', async () => {
      ddbMock.on(DeleteCommand).rejects(new Error('DynamoDB error'));

      await expect(repository.deleteState('user-123', 1704067200000)).rejects.toThrow(RepositoryError);
    });
  });

  describe('retry logic', () => {
    it('should not retry on non-retryable errors', async () => {
      const validationError = new Error('Validation failed');
      validationError.name = 'ValidationException';

      ddbMock.on(PutCommand).rejects(validationError);

      await expect(repository.saveState(mockStateRecord)).rejects.toThrow();
      expect(ddbMock.calls()).toHaveLength(1);
    });

    it('should wrap errors with RepositoryError containing operation name', async () => {
      ddbMock.on(PutCommand).rejects(new Error('Some error'));

      try {
        await repository.saveState(mockStateRecord);
        fail('Expected error to be thrown');
      } catch (error) {
        expect(error).toBeInstanceOf(RepositoryError);
        expect((error as RepositoryError).operation).toBe('saveState');
        expect((error as RepositoryError).cause).toBeDefined();
      }
    });

    it('should preserve original error as cause', async () => {
      const originalError = new Error('Original DynamoDB error');
      ddbMock.on(QueryCommand).rejects(originalError);

      try {
        await repository.getLatestState('user-123');
        fail('Expected error to be thrown');
      } catch (error) {
        expect(error).toBeInstanceOf(RepositoryError);
        expect((error as RepositoryError).cause?.message).toBe('Original DynamoDB error');
      }
    });
  });
});
