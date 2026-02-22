<p align="center">
  <img src="https://img.shields.io/badge/DEVELOPED%20BY-DjonStNix-blue?style=for-the-badge&logo=github" alt="DjonStNix" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square" alt="MIT License" />
  <img src="https://img.shields.io/badge/Built%20With-React-61DAFB?style=flat-square&logo=react" alt="Built With React" />
  <img src="https://img.shields.io/badge/Platform-FiveM-orange?style=flat-square" alt="FiveM" />
  <img src="https://img.shields.io/badge/Framework-QBCore%20%7C%20ESX-green?style=flat-square" alt="Framework" />
  <img src="https://img.shields.io/badge/Maintained-Yes-brightgreen?style=flat-square" alt="Maintained" />
  <a href="https://discord.gg/s7GPUHWrS7"><img src="https://img.shields.io/badge/Discord-Join%20Us-5865F2?style=flat-square&logo=discord&logoColor=white" alt="Discord" /></a>
</p>

---

---

# 🏪 DjonStNix Shops

> **A premium, dynamic shop ecosystem for FiveM with real-time economy simulation, transparent NUI interface, and multi-framework support.**

## 📸 Showcase

![DjonStNix Shops UI Showcase](https://raw.githubusercontent.com/Djonluc/DjonStNix-Shops/master/assets/showcase.png)
*(Note: Upload the provided screenshot to an assets folder in your repo to see this live on GitHub!)*

---

## ✨ Features

| Feature | Description |
|---|---|
| 🎨 **Premium NUI** | Transparent glassmorphism React UI with animated DjonStNix branding |
| 🔄 **Dynamic Economy** | Real-time inflation, demand-based pricing, and scarcity multipliers |
| 🔫 **Weapons License** | Armory shops display license warnings; server enforces license checks |
| 🛒 **Cart System** | Multi-item checkout with quantity controls and live total |
| 🌐 **Multi-Framework** | Auto-detects QBCore or ESX — no manual setup needed |
| 📦 **Universal Inventory** | Works with qb-inventory, ox_inventory, and qs-inventory |
| 🎯 **Target Support** | Native qb-target, ox_target, or fallback 3D Text interaction |
| 🗺️ **Map Blips** | Auto-generated blips for all shop locations |
| 📊 **Area Pricing** | Premium, city, suburban, rural, and blackmarket price zones |
| ⌨️ **Escape to Close** | Press ESC or click X to close the shop UI |

---

## 📋 Dependencies

- [qb-core](https://github.com/qbcore-framework/qb-core) or [es_extended](https://github.com/esx-framework/esx-legacy)
- [oxmysql](https://github.com/overextended/oxmysql)
- [PolyZone](https://github.com/mkafrin/PolyZone)
- [qb-target](https://github.com/qbcore-framework/qb-target) or [ox_target](https://github.com/overextended/ox_target)
- [qb-menu](https://github.com/qbcore-framework/qb-menu)
- [qb-input](https://github.com/qbcore-framework/qb-input)

---

## 🚀 Installation

### 1. Download & Place
```
resources/[addons]/DjonStNix-Shops/
```

### 2. Import Database
```sql
-- Import the schema into your MySQL database
mysql -u root -p your_database < database.sql
```
Or copy the contents of `database.sql` and run it in your database manager (HeidiSQL, phpMyAdmin, etc).

### 3. Add to Server Config
```cfg
ensure DjonStNix-Shops
```
> **Note:** Make sure all dependencies (`oxmysql`, `PolyZone`, `qb-target`, etc.) are started **before** this resource.

### 4. Configure (Optional)
Edit `config.lua` to customize:
- Shop locations, names, and NPC models
- Product catalogs and pricing
- Economy engine settings (inflation, demand, volatility)
- Branding (shop name prefix, currency symbol)

---

## 🏗️ Project Structure

```
DjonStNix-Shops/
├── client/
│   ├── blips.lua          # Map blip generation
│   ├── main.lua           # Client-side logic
│   ├── npc.lua            # NPC spawning & target interaction
│   └── nui.lua            # NUI communication bridge
├── server/
│   ├── economy.lua        # Dynamic pricing engine
│   ├── franchise.lua      # Franchise system (disabled)
│   └── main.lua           # Purchase handling & callbacks
├── shared/
│   ├── bridge.lua         # Framework abstraction layer
│   └── products.lua       # Centralized product data
├── web/                   # React NUI source (Vite + TypeScript)
│   └── src/
│       ├── App.tsx        # Main shop UI component
│       └── index.css      # Glassmorphism & animation styles
├── ui/                    # Compiled NUI (auto-generated)
├── config.lua             # All configuration
├── shared.lua             # Shared utilities
├── database.sql           # MySQL schema
└── fxmanifest.lua         # Resource manifest
```

---

## 🛍️ Shop Types

| Type | Products | Area |
|---|---|---|
| **24/7 Supermarkets** | Food, drinks, medical, tech | City / Suburban / Rural |
| **LTD Gasoline** | General goods | Various |
| **Liquor Stores** | General goods | Various |
| **Armory (Ammu-Nation)** | Weapons, ammo, knives | Premium / City / Rural |
| **Clandestine** | Illegal items (lockpicks, scanners) | Blackmarket |
| **Supply Shops** | Tools, repair kits, binoculars | City / Rural |

---

## 💰 Economy Engine

The dynamic economy engine adjusts prices based on:

- **Demand** — Prices increase with purchases, decay over time
- **Inflation** — Global money supply affects all prices
- **Area Type** — Premium areas cost 30% more, rural areas 20% less
- **Volatility** — Standard (5%), volatile (15%), or extreme (30%) price jitter
- **Elasticity** — Each product has its own price sensitivity

---

## 🔧 Building the NUI (Development)

If you need to modify the React UI:

```bash
cd web
npm install
npm run build    # Outputs to ../ui/
```

The compiled `ui/` folder is included in the repo so end-users don't need Node.js.

---

## 🗺️ Roadmap

- [ ] Player franchise ownership system
- [ ] Shop robbery integration
- [ ] Custom product categories with tabs
- [ ] Item preview animations
- [ ] Sales history & analytics dashboard

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---



<p align="center">
  <b>DjonStNix</b> — Digital Creator & Software Developer<br/>
  <a href="https://www.youtube.com/@Djonluc">YouTube</a> •
  <a href="https://github.com/Djonluc">GitHub</a> •
  <a href="https://discord.gg/s7GPUHWrS7">Discord</a> •
  <a href="mailto:djonstnix@gmail.com">Email</a>
</p>
