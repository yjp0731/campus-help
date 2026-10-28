-- Campus Help Platform
-- MySQL 8.x schema script
-- Recommended database name: campus_help

CREATE DATABASE IF NOT EXISTS `campus_help`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `campus_help`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `task_reviews`;
DROP TABLE IF EXISTS `task_applications`;
DROP TABLE IF EXISTS `help_tasks`;
DROP TABLE IF EXISTS `user_sessions`;
DROP TABLE IF EXISTS `notices`;
DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  `username` VARCHAR(40) NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `display_name` VARCHAR(60) NOT NULL,
  `email` VARCHAR(120) DEFAULT NULL,
  `phone` VARCHAR(32) DEFAULT NULL,
  `campus` VARCHAR(60) DEFAULT NULL,
  `department` VARCHAR(60) DEFAULT NULL,
  `role` VARCHAR(16) NOT NULL DEFAULT 'USER',
  `credit_score` INT NOT NULL DEFAULT 100,
  `active` BIT(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_users_username` (`username`),
  KEY `idx_users_role_active` (`role`, `active`),
  CONSTRAINT `chk_users_role` CHECK (`role` IN ('USER', 'ADMIN')),
  CONSTRAINT `chk_users_credit_score` CHECK (`credit_score` BETWEEN 0 AND 100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `user_sessions` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  `token` VARCHAR(80) NOT NULL,
  `user_id` BIGINT NOT NULL,
  `expires_at` DATETIME(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_sessions_token` (`token`),
  KEY `idx_user_sessions_user_id` (`user_id`),
  KEY `idx_user_sessions_expires_at` (`expires_at`),
  CONSTRAINT `fk_user_sessions_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `help_tasks` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  `title` VARCHAR(120) NOT NULL,
  `description` VARCHAR(2000) NOT NULL,
  `category` VARCHAR(24) NOT NULL,
  `reward` DECIMAL(10, 2) NOT NULL,
  `location` VARCHAR(120) NOT NULL,
  `contact` VARCHAR(120) NOT NULL,
  `deadline` DATETIME(6) NOT NULL,
  `urgent` BIT(1) NOT NULL DEFAULT b'0',
  `min_helper_credit` INT NOT NULL DEFAULT 60,
  `requires_proof` BIT(1) NOT NULL DEFAULT b'1',
  `requires_completion_code` BIT(1) NOT NULL DEFAULT b'1',
  `completion_code` VARCHAR(16) DEFAULT NULL,
  `proof_note` VARCHAR(500) DEFAULT NULL,
  `proof_image_url` VARCHAR(255) DEFAULT NULL,
  `proof_submitted_at` DATETIME(6) DEFAULT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'OPEN',
  `publisher_id` BIGINT NOT NULL,
  `accepted_helper_id` BIGINT DEFAULT NULL,
  `completed_at` DATETIME(6) DEFAULT NULL,
  `confirmed_at` DATETIME(6) DEFAULT NULL,
  `dispute_reason` VARCHAR(500) DEFAULT NULL,
  `disputed_at` DATETIME(6) DEFAULT NULL,
  `resolution_note` VARCHAR(500) DEFAULT NULL,
  `resolved_at` DATETIME(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_help_tasks_publisher_id` (`publisher_id`),
  KEY `idx_help_tasks_accepted_helper_id` (`accepted_helper_id`),
  KEY `idx_help_tasks_status_deadline` (`status`, `deadline`),
  KEY `idx_help_tasks_category_status` (`category`, `status`),
  KEY `idx_help_tasks_urgent_status` (`urgent`, `status`),
  KEY `idx_help_tasks_credit_status` (`min_helper_credit`, `status`),
  CONSTRAINT `fk_help_tasks_publisher`
    FOREIGN KEY (`publisher_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_help_tasks_accepted_helper`
    FOREIGN KEY (`accepted_helper_id`) REFERENCES `users` (`id`),
  CONSTRAINT `chk_help_tasks_category`
    CHECK (`category` IN ('DELIVERY', 'STUDY', 'DAILY', 'LOST_FOUND', 'OTHER')),
  CONSTRAINT `chk_help_tasks_status`
    CHECK (`status` IN ('OPEN', 'MATCHED', 'IN_PROGRESS', 'AWAITING_CONFIRMATION', 'DISPUTED', 'COMPLETED', 'CANCELLED')),
  CONSTRAINT `chk_help_tasks_reward`
    CHECK (`reward` >= 0),
  CONSTRAINT `chk_help_tasks_min_helper_credit`
    CHECK (`min_helper_credit` BETWEEN 0 AND 100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `task_applications` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  `task_id` BIGINT NOT NULL,
  `applicant_id` BIGINT NOT NULL,
  `message` VARCHAR(500) NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'PENDING',
  `decided_at` DATETIME(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_task_applications_task_applicant` (`task_id`, `applicant_id`),
  KEY `idx_task_applications_applicant_id` (`applicant_id`),
  KEY `idx_task_applications_status` (`status`),
  CONSTRAINT `fk_task_applications_task`
    FOREIGN KEY (`task_id`) REFERENCES `help_tasks` (`id`),
  CONSTRAINT `fk_task_applications_applicant`
    FOREIGN KEY (`applicant_id`) REFERENCES `users` (`id`),
  CONSTRAINT `chk_task_applications_status`
    CHECK (`status` IN ('PENDING', 'ACCEPTED', 'REJECTED', 'CANCELLED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `task_reviews` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  `task_id` BIGINT NOT NULL,
  `reviewer_id` BIGINT NOT NULL,
  `reviewee_id` BIGINT NOT NULL,
  `score` INT NOT NULL,
  `comment` VARCHAR(500) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_task_reviews_task_reviewer` (`task_id`, `reviewer_id`),
  KEY `idx_task_reviews_reviewee_id` (`reviewee_id`),
  CONSTRAINT `fk_task_reviews_task`
    FOREIGN KEY (`task_id`) REFERENCES `help_tasks` (`id`),
  CONSTRAINT `fk_task_reviews_reviewer`
    FOREIGN KEY (`reviewer_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_task_reviews_reviewee`
    FOREIGN KEY (`reviewee_id`) REFERENCES `users` (`id`),
  CONSTRAINT `chk_task_reviews_score`
    CHECK (`score` BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `notices` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  `title` VARCHAR(120) NOT NULL,
  `content` VARCHAR(4000) NOT NULL,
  `pinned` BIT(1) NOT NULL DEFAULT b'0',
  `created_by` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_notices_created_by` (`created_by`),
  KEY `idx_notices_pinned_created_at` (`pinned`, `created_at`),
  CONSTRAINT `fk_notices_created_by`
    FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
