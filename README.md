# Framework Support
## [QBCore](https://github.com/qbcore-framework) | [ESX](https://github.com/esx-framework)

# SF Camera Security
For all support questions, ask in our [Discord](https://discord.gg/dcm4TNtbGQ) support chat. Do not create issues if you need help. Issues are for bug reporting and new features only.

# Preview
- [Youtube Link](https://youtu.be/lK5qils5oCA?si=aGbLCtcj-wX7Kpxx)

## Dependencies
- [qb-core](https://github.com/qbcore-framework/qb-core) or [es_extended](https://github.com/esx-framework/esx_core/tree/main/%5Bcore%5D/es_extended)
- [oxmysql](https://github.com/overextended/oxmysql/releases)
- [ox_lib](https://github.com/overextended/ox_lib/releases)

## Installation
- Download ZIP and UNZIP.
- Drag and drop resource into your server files, make sure to remove -main in the folder name.
- SQL Automatic added to your database no need to add manually.
- add images from folder **(install/item-images)** to **Inventory Images Location**.


### Be careful, if you are use ``ox_inventory`` in QBCore framework dont add items in ``qb-core`` resource, require to add items in ``ox_inventory/data/items.lua`` ONLY.
### qb-inventory / ps-inventory
#### Add Items to **(qb-core/shared/items.lua)**
```language
-- // Cameras
camera_pd = {name = 'camera_pd', label = 'PD Camera', weight = 3000,	type = 'item', image = 'camera_pd.png',	unique = true, useable = true, shouldClose = true, combinable = nil, description = ''},
camera_ems = { name = 'camera_ems', label = 'EMS Camera', weight = 3000, type = 'item', image = 'camera_ems.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = '' },
camera_citizen = { name = 'camera_citizen', label = 'Camera', weight = 3000, type = 'item', image = 'camera_citizen.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = '' },
camera_viewer = { name = 'camera_viewer', label = 'Camera Viewer', weight = 1000, type = 'item', image = 'camera_viewer.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = '' },
camera_paper = { name = 'camera_paper', label = 'Camera Signal Paper', weight = 200, type = 'item', image = 'camera_paper.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = '' },
camera_tablet = { name = 'camera_tablet', label = 'CamView Tablet', weight = 2000, type = 'item', image = 'camera_tablet.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = '' },
camera_personaltablet = { name = 'camera_personaltablet', label = 'Personal CamView', weight = 2000, type = 'item', image = 'camera_personaltablet.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = '' },
camera_personal = { name = 'camera_personal', label = 'Personal Camera', weight = 3000, type = 'item', image = 'camera_personal.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = '' },
vpn = {name = 'vpn', label = 'VPN Router', weight = 1000, type = 'item', image = 'vpn.png', unique = true, useable = false, shouldClose = false, combinable = nil, description = ''},
```

### codem-inventory
#### Add Items to **(codem-inventory/config/itemlist.lua)**
```language
-- // Cameras
camera_pd = {name = 'camera_pd', label = 'PD Camera', weight = 3000,	type = 'item', image = 'camera_pd.png',	unique = true, useable = true, shouldClose = true, combinable = nil, description = ''},
camera_ems = { name = 'camera_ems', label = 'EMS Camera', weight = 3000, type = 'item', image = 'camera_ems.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = '' },
camera_citizen = { name = 'camera_citizen', label = 'Camera', weight = 3000, type = 'item', image = 'camera_citizen.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = '' },
camera_viewer = { name = 'camera_viewer', label = 'Camera Viewer', weight = 1000, type = 'item', image = 'camera_viewer.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = '' },
camera_paper = { name = 'camera_paper', label = 'Camera Signal Paper', weight = 200, type = 'item', image = 'camera_paper.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = '' },
camera_tablet = { name = 'camera_tablet', label = 'CamView Tablet', weight = 2000, type = 'item', image = 'camera_tablet.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = '' },
camera_personaltablet = { name = 'camera_personaltablet', label = 'Personal CamView', weight = 2000, type = 'item', image = 'camera_personaltablet.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = '' },
camera_personal = { name = 'camera_personal', label = 'Personal Camera', weight = 3000, type = 'item', image = 'camera_personal.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = '' },
vpn = {name = 'vpn', label = 'VPN Router', weight = 1000, type = 'item', image = 'vpn.png', unique = true, useable = false, shouldClose = false, combinable = nil, description = ''},
```

### qs-inventory
#### Add Items to **(qs-inventory\shared\item.lua)**
```language
-- // Cameras
    ["camera_pd"] = {
        ["name"] = 'camera_pd',
        ["label"] = 'PD Camera',
        ["weight"] = 3000,
        ["type"] = 'item',
        ["image"] = 'camera_pd.png',
        ["unique"] = true,
        ["useable"] = true,
        ["shouldClose"] = true,
        ["combinable"] = nil,
        ["description"] = ''
    },

    ["camera_ems"] = {
        ["name"] = 'camera_ems',
        ["label"] = 'EMS Camera',
        ["weight"] = 3000,
        ["type"] = 'item',
        ["image"] = 'camera_ems.png',
        ["unique"] = true,
        ["useable"] = true,
        ["shouldClose"] = true,
        ["combinable"] = nil,
        ["description"] = ''
    },

    ["camera_citizen"] = {
        ["name"] = 'camera_citizen',
        ["label"] = 'Camera',
        ["weight"] = 3000,
        ["type"] = 'item',
        ["image"] = 'camera_citizen.png',
        ["unique"] = true,
        ["useable"] = true,
        ["shouldClose"] = true,
        ["combinable"] = nil,
        ["description"] = ''
    },

    ["camera_viewer"] = {
        ["name"] = 'camera_viewer',
        ["label"] = 'Camera Viewer',
        ["weight"] = 1000,
        ["type"] = 'item',
        ["image"] = 'camera_viewer.png',
        ["unique"] = true,
        ["useable"] = true,
        ["shouldClose"] = true,
        ["combinable"] = nil,
        ["description"] = ''
    },

    ["camera_paper"] = {
        ["name"] = 'camera_paper',
        ["label"] = 'Camera Signal Paper',
        ["weight"] = 200,
        ["type"] = 'item',
        ["image"] = 'camera_paper.png',
        ["unique"] = true,
        ["useable"] = true,
        ["shouldClose"] = true,
        ["combinable"] = nil,
        ["description"] = ''
    },

    ["camera_tablet"] = {
        ["name"] = 'camera_tablet',
        ["label"] = 'CamView Tablet',
        ["weight"] = 2000,
        ["type"] = 'item',
        ["image"] = 'camera_tablet.png',
        ["unique"] = true,
        ["useable"] = true,
        ["shouldClose"] = true,
        ["combinable"] = nil,
        ["description"] = ''
    },

    ["camera_personaltablet"] = {
        ["name"] = 'camera_personaltablet',
        ["label"] = 'Personal CamView',
        ["weight"] = 2000,
        ["type"] = 'item',
        ["image"] = 'camera_personaltablet.png',
        ["unique"] = true,
        ["useable"] = true,
        ["shouldClose"] = true,
        ["combinable"] = nil,
        ["description"] = ''
    },

    ["camera_personal"] = {
        ["name"] = 'camera_personal',
        ["label"] = 'Personal Camera',
        ["weight"] = 3000,
        ["type"] = 'item',
        ["image"] = 'camera_personal.png',
        ["unique"] = true,
        ["useable"] = true,
        ["shouldClose"] = true,
        ["combinable"] = nil,
        ["description"] = ''
    },

    ["vpn"] = {
        ["name"] = 'vpn',
        ["label"] = 'VPN Router',
        ["weight"] = 1000,
        ["type"] = 'item',
        ["image"] = 'vpn.png',
        ["unique"] = true,
        ["useable"] = false,
        ["shouldClose"] = false,
        ["combinable"] = nil,
        ["description"] = ''
    }
```

### ox_inventory
#### Add Items to **(ox_inventory/data/items.lua)**
```language
['camera_pd'] = {
	label = 'PD Camera',
	weight = 3000,
	stack = false,
	close = true,
	consume = 0,
	server = {
		export = 'sf_camerasecurity.cam_camera_pd'
	},
	client = {
		image = 'camera_pd.png',
	}	
},

['camera_ems'] = {
	label = 'EMS Camera',
	weight = 3000,
	stack = false,
	close = true,
	consume = 0,
	server = {
		export = 'sf_camerasecurity.cam_camera_ems'
	},
	client = {
		image = 'camera_ems.png',
	}	
},

['camera_citizen'] = {
	label = 'Camera',
	weight = 3000,
	stack = false,
	close = true,
	consume = 0,
	server = {
		export = 'sf_camerasecurity.cam_camera_citizen'
	},
	client = {
		image = 'camera_citizen.png',
	}	
},

['camera_viewer'] = {
	label = 'Camera Viewer',
	weight = 1000,
	stack = false,
	close = true,
	consume = 0,
	server = {
		export = 'sf_camerasecurity.cam_camera_viewer'
	},
	client = {
		image = 'camera_viewer.png',
	}	
},

['camera_paper'] = {
	label = 'Camera Signal Paper',
	weight = 200,
	stack = false,
	close = true,
	consume = 0,
	server = {
		export = 'sf_camerasecurity.cam_camera_paper'
	},
	client = {
		image = 'camera_paper.png',
	}	
},

['camera_tablet'] = {
	label = 'CamView Tablet',
	weight = 2000,
	stack = false,
	close = true,
	consume = 0,
	server = {
		export = 'sf_camerasecurity.cam_camera_tablet'
	},
	client = {
		image = 'camera_tablet.png',
	}	
},

['camera_personal'] = {
	label = 'Personal Camera',
	weight = 3000,
	stack = false,
	close = true,
	consume = 0,
	server = {
		export = 'sf_camerasecurity.cam_camera_personal'
	},
	client = {
		image = 'camera_personal.png',
	}	
},

['camera_personaltablet'] = {
	label = 'Personal CamView',
	weight = 2000,
	stack = false,
	close = true,
	consume = 0,
	server = {
		export = 'sf_camerasecurity.cam_camera_personaltablet'
	},
	client = {
		image = 'camera_personaltablet.png',
	}	
},

['vpn'] = {
	label = 'VPN Router',
	weight = 1000,
	stack = false
},

['screwdriverset'] = {
	label = 'Toolkit',
	weight = 1000,
	stack = false
},
```
### This item comming default in qb-core check before add please
```language
screwdriverset               = { name = 'screwdriverset', label = 'Toolkit', weight = 1000, type = 'item', image = 'screwdriverset.png', unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Very useful to screw... screws...' },
```
## Final step check the **config.lua** if you want modify some config.
