-- Create Task table

CREATE TABLE "Task" (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "taskType" VARCHAR(50) NOT NULL,
  status VARCHAR(20) DEFAULT 'PENDING',
  
  -- References
  "projectId" UUID REFERENCES "Project"(id) ON DELETE CASCADE,
  
  -- Task Configuration (JSONB for flexibility)
  payload JSONB NOT NULL,
  result JSONB,
  
  -- Timestamps
  "createdAt" TIMESTAMP DEFAULT NOW(),
  "startedAt" TIMESTAMP,
  "finishedAt" TIMESTAMP
);

-- Indexes for query performance
CREATE INDEX idx_task_status ON "Task"(status);
CREATE INDEX idx_task_project ON "Task"("projectId");
CREATE INDEX idx_task_type ON "Task"("taskType");
