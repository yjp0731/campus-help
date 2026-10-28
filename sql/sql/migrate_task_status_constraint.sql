-- 为 help_tasks.status 补充「待签收」「争议中」状态（旧库约束会导致提交凭证/发起争议失败）
USE `campus_help`;

ALTER TABLE `help_tasks` DROP CHECK `chk_help_tasks_status`;

ALTER TABLE `help_tasks`
  ADD CONSTRAINT `chk_help_tasks_status`
    CHECK (`status` IN (
      'OPEN',
      'MATCHED',
      'IN_PROGRESS',
      'AWAITING_CONFIRMATION',
      'DISPUTED',
      'COMPLETED',
      'CANCELLED'
    ));
