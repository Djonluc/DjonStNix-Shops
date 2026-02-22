-- ==================================================
-- DJONSTNIX SHOPS - DATABASE SCHEMA (V5)
-- ==================================================

-- Core Economy State
CREATE TABLE IF NOT EXISTS `djonstnix_shops_economy` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `inflation` FLOAT DEFAULT 1.0,
    `last_updated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Item Demand Tracking
CREATE TABLE IF NOT EXISTS `djonstnix_shops_demand` (
    `item_name` VARCHAR(50) PRIMARY KEY,
    `demand_multiplier` FLOAT DEFAULT 1.0
);

-- Franchise Ownership
CREATE TABLE IF NOT EXISTS `djonstnix_shops_franchises` (
    `shop_index` INT PRIMARY KEY,
    `owner_identifier` VARCHAR(100) NOT NULL, -- Increased size for long identifiers
    `level` INT DEFAULT 1,
    `markup` FLOAT DEFAULT 0.0,
    `profit` BIGINT DEFAULT 0,                 -- Support for large profit margins
    `advertised` TINYINT(1) DEFAULT 0
);

-- Per-Shop Stock Levels
CREATE TABLE IF NOT EXISTS `djonstnix_shops_stock` (
    `shop_index` INT NOT NULL,
    `item_name` VARCHAR(50) NOT NULL,
    `current_stock` INT DEFAULT 0,
    PRIMARY KEY (`shop_index`, `item_name`)
);

-- Initialize economy state
INSERT IGNORE INTO `djonstnix_shops_economy` (id, inflation) VALUES (1, 1.0);

-- ==================================================
-- MIGRATION COMMANDS (For V4 -> V5 Upgrades)
-- ==================================================
-- If you are already using DjonStNix-Shops, run these commands:
-- ALTER TABLE `djonstnix_shops_franchises` ADD COLUMN IF NOT EXISTS `advertised` TINYINT(1) DEFAULT 0;
-- ALTER TABLE `djonstnix_shops_franchises` MODIFY COLUMN `owner_identifier` VARCHAR(100);
-- ALTER TABLE `djonstnix_shops_franchises` MODIFY COLUMN `profit` BIGINT DEFAULT 0;
