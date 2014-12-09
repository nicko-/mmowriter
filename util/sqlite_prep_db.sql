BEGIN TRANSACTION;
CREATE TABLE `votes` (
  `story_id` INTEGER NOT NULL,
  `action` TEXT NOT NULL,
  `uuid` TEXT NOT NULL
);
CREATE TABLE `story_actions` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `story_id` INTEGER NOT NULL,
  `action_type` INTEGER NOT NULL,
  `action_metadata` TEXT
);
CREATE TABLE `story_metadata` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `date_created` INTEGER NOT NULL,
  `date_completed` INTEGER,
  `completed` INTEGER NOT NULL,
  `archive_votes` INTEGER NOT NULL
);
COMMIT;
