BEGIN TRANSACTION;
CREATE TABLE `votes` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `story_id` INTEGER NOT NULL,
  `action_type` TEXT NOT NULL,
  `action_metadata` TEXT,
  `uuid` TEXT NOT NULL
);
CREATE TABLE `story_actions` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `story_id` INTEGER NOT NULL,
  `type` TEXT NOT NULL,
  `metadata` TEXT
);
CREATE TABLE `story_metadata` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `date_created` INTEGER NOT NULL,
  `date_completed` INTEGER,
  `completed` INTEGER NOT NULL,
  `archive_votes` INTEGER NOT NULL
);
COMMIT;
