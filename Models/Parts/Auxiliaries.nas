# In this file we put some parameters in /sim/G91 location to make them accessible in single player
# and multiplayer

print("***** Auxiliaries.nas is loadading...");

 
var sync_canopy_prop = func(name) { 
    setlistener("/fdm/jsbsim/systems/" ~ name, func {
        var val = getprop("/fdm/jsbsim/systems/" ~ name);
        setprop("/sim/G91/" ~ name, val);
    });
};

var sync_stores_prop = func(name) { 
    setlistener("/fdm/jsbsim/systems/store/" ~ name, func {
        var val = getprop("/fdm/jsbsim/systems/store/" ~ name);
        setprop("/sim/G91/stores/" ~ name, val);
    });
};

var sync_hp_prop = func(name) { 
    setlistener("/fdm/jsbsim/systems/" ~ name, func {
        var val = getprop("/fdm/jsbsim/systems/" ~ name);
        setprop("/sim/G91/stores/" ~ name, val);
    });
};

var sync_weapon_opt_prop = func(name) { 
    setprop("/fdm/jsbsim/systems/" ~ name, '0');
    setlistener("/fdm/jsbsim/systems/" ~ name, func {
        var val = getprop("/fdm/jsbsim/systems/" ~ name);
        setprop("/sim/G91/stores/" ~ name, val);
    });
};

var sync_surfaces_prop = func(name) { 
    setlistener("/fdm/jsbsim/fcs/" ~ name, func {
        var val = getprop("/fdm/jsbsim/fcs/" ~ name);
        setprop("/sim/G91/control-surfaces/" ~ name, val);
    });
};

sync_dragChute_prop = func(name) { 
    setlistener("/fdm/jsbsim/systems/dragchute/" ~ name, func {
        var val = getprop("/fdm/jsbsim/systems/dragchute/" ~ name);
        setprop("/sim/G91/dragchute/" ~ name, val);
    });
};

# Canopy
sync_canopy_prop("canopy/position");

# Stores
sync_stores_prop("stations/dx/internal/type");
sync_stores_prop("stations/dx/external/type");
sync_stores_prop("stations/sx/internal/type");
sync_stores_prop("stations/sx/external/type");

# HardPoints
sync_hp_prop("stations/stationSxInternal/typeHardpoint");
sync_hp_prop("stations/stationDxInternal/typeHardpoint");
sync_hp_prop("stations/stationSxExternal/typeHardpoint");
sync_hp_prop("stations/stationDxExternal/typeHardpoint");

# armyTypeFuse and armyTypeSpecial
sync_weapon_opt_prop("stations/stationSxInternal/armyTypeFuse");
sync_weapon_opt_prop("stations/stationSxInternal/armyTypeSpecial");
sync_weapon_opt_prop("stations/stationDxInternal/armyTypeFuse");
sync_weapon_opt_prop("stations/stationDxInternal/armyTypeSpecial");
sync_weapon_opt_prop("stations/stationSxExternal/armyTypeFuse");
sync_weapon_opt_prop("stations/stationSxExternal/armyTypeSpecial");
sync_weapon_opt_prop("stations/stationDxExternal/armyTypeFuse");
sync_weapon_opt_prop("stations/stationDxExternal/armyTypeSpecial");

#Nose Wheel 
setlistener("/fdm/jsbsim/systems/gears/gear[0]/slip-angle-deg-lag", func {
    var val = getprop("/fdm/jsbsim/systems/gears/gear[0]/slip-angle-deg-lag");
    setprop("/sim/G91/gear/unit[0]/nws", val);
});

# NOTE: JSBSim overwrites these properties every frame, so Nasal listeners
# will NOT be triggered when their values change. This is because the changes
# are not made via setprop() from Nasal, but internally by the FDM.
#
# As a workaround, we use a polling function (with settimer) to detect changes
# and mirror the values into custom properties under /sim/G91/.

var last_wheel_speed = nil;
var last_compression = nil;

var poll_gear_state = func {
    var ws = getprop("/fdm/jsbsim/gear/unit[0]/wheel-speed-fps");
    if (ws != nil and ws != last_wheel_speed) {
        setprop("/sim/G91/gear/unit[0]/wheel-speed-fps", ws);
        last_wheel_speed = ws;
    }

    var comp = getprop("/fdm/jsbsim/gear/unit[0]/compression-ft");
    if (comp != nil and comp != last_compression) {
        setprop("/sim/G91/gear/unit[0]/compression-ft", comp);
        last_compression = comp;
    }

    # richiama la funzione ogni 0.1 secondi
    settimer(poll_gear_state, 0.1);
};

# Avvio polling
poll_gear_state();

#Airbrake
setlistener("/fdm/jsbsim/systems/airbrake/speedbrake-pos-norm", func {
    var val = getprop("/fdm/jsbsim/systems/airbrake/speedbrake-pos-norm");
    setprop("/sim/G91/airbrake/speedbrake-pos-norm", val);
});

#Control-Surfaces
sync_surfaces_prop("left-aileron-pos-deg");
sync_surfaces_prop("right-aileron-pos-deg");
sync_surfaces_prop("pitch-deg");
sync_surfaces_prop("rudder-deg");

#Drag Chute
sync_dragChute_prop("beta-deg");
sync_dragChute_prop("alpha-deg");
sync_dragChute_prop("open-big-chute");
sync_dragChute_prop("open-little-chute");
sync_dragChute_prop("door-chute");
sync_dragChute_prop("active");

print("***** Auxiliaries.nas is executeed.");
