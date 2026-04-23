CREATE UNIQUE INDEX "Unique_Project_TopicAlias_Active" 
ON "Topic" ("projectId", "alias") 
WHERE ("isDeleted" IS FALSE);
