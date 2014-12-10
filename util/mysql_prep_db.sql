CREATE TABLE `mw`.`votes` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `story_id` INT NOT NULL,
  `action_type` VARCHAR(32) NOT NULL,
  `action_metadata` TEXT,
  `uuid` VARCHAR(38) NOT NULL,
  PRIMARY KEY (`id`));
CREATE TABLE `mw`.`actions` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `story_id` INT NOT NULL,
  `type` VARCHAR(32) NOT NULL,
  `metadata` TEXT,
  PRIMARY KEY (`id`));
CREATE TABLE `mw`.`stories` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `date_created` INT NOT NULL,
  `date_completed` INT,
  `completed` INT NOT NULL,
  `archive_votes` INT NOT NULL,
  PRIMARY KEY (`id`));
