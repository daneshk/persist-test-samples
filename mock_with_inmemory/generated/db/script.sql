-- AUTO-GENERATED FILE.

-- This file is an auto-generated file by Ballerina persistence layer for model.
-- Please verify the generated scripts and execute them against the target DB server.

DROP TABLE IF EXISTS `Doctor`;

CREATE TABLE `Doctor` (
	`id` INT NOT NULL,
	`name` VARCHAR(191) NOT NULL,
	`specialty` VARCHAR(191) NOT NULL,
	`phoneNumber` VARCHAR(191) NOT NULL,
	PRIMARY KEY(`id`)
);
