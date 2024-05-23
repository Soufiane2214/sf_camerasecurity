# We have a goal to complete 1000 member in discord.
# [Join Discord](https://discord.gg/WQNGvFY8)

# SF Camera Security
For all support questions, ask in our [Discord](https://discord.gg/WQNGvFY8) support chat. Do not create issues if you need help. Issues are for bug reporting and new features only.

# Preview
- [Youtube Link](https://youtu.be/lK5qils5oCA?si=aGbLCtcj-wX7Kpxx)

## Dependencies
- [qb-core](https://github.com/qbcore-framework/qb-core)
- [oxmysql](https://github.com/overextended/oxmysql/releases)
- [ox_lib](https://github.com/overextended/ox_lib/releases)

## Installation
- Download ZIP and UNZIP.
- Drag and drop resource into your server files, make sure to remove -main in the folder name.
- SQL Automatic added to your database no need to add manually.
- add images from folder **(install/item-images)** to **(qb-inventory/html/images)**.

### Add Items to **(qb-core/shared/items.lua)**
```language
-- // Cameras
camera_pd = {name = 'camera_pd', label = 'PD Camera', weight = 3000,	type = 'item', image = 'camera_pd.png',	unique = true, useable = true, shouldClose = true, combinable = nil, description = ''},
camera_ems = { name = 'camera_ems', label = 'EMS Camera', weight = 3000, type = 'item', image = 'camera_ems.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = '' },
camera_citizen = { name = 'camera_citizen', label = 'Camera', weight = 3000, type = 'item', image = 'camera_citizen.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = '' },
camera_viewer = { name = 'camera_viewer', label = 'Camera Viewer', weight = 1000, type = 'item', image = 'camera_viewer.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = '' },
camera_paper = { name = 'camera_paper', label = 'Camera Signal Paper', weight = 200, type = 'item', image = 'camera_paper.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = '' },
camera_tablet = { name = 'camera_tablet', label = 'CamView Tablet', weight = 2000, type = 'item', image = 'camera_tablet.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = '' },
vpn = {name = 'vpn', label = 'VPN Router', weight = 1000, type = 'item', image = 'vpn.png', unique = true, useable = false, shouldClose = false, combinable = nil, description = ''},
```
**This item comming default in qb-core check before add please**
```language
screwdriverset               = { name = 'screwdriverset', label = 'Toolkit', weight = 1000, type = 'item', image = 'screwdriverset.png', unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Very useful to screw... screws...' },
```
- Final step check the **config.lua** if you want modify some config.
