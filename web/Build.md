# NUI Build Instructions

This shop system uses a premium React-based NUI. To use it, you must build the project:

1. Open a terminal in this directory (`web/`).
2. Run `npm install` to install dependencies.
3. Run `npm run build` to generate the `ui/` folder used by FiveM.

The script is already configured to serve the files from the `ui/` directory.

## 🗄️ Database Migration (V5 Update)

If you are upgrading from an older version, run these SQL commands in your database to add the new columns and tables:

```sql
-- Fix missing table error
CREATE TABLE IF NOT EXISTS `djonstnix_shops_stock` (
    `shop_index` INT NOT NULL,
    `item_name` VARCHAR(50) NOT NULL,
    `current_stock` INT DEFAULT 0,
    PRIMARY KEY (`shop_index`, `item_name`)
);

-- Fix 'Unknown column advertised' error
ALTER TABLE `djonstnix_shops_franchises` ADD COLUMN IF NOT EXISTS `advertised` TINYINT(1) DEFAULT 0;
```
