print("***** SFOM_83A_01.nas is loaded and executed");

var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/button", 126, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/inclination", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/isLightActive", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/collimatorLight", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/alpha", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/collimator_red", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/collimator_green", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/collimator_blue", 0, "DOUBLE");

var TRUE = 1;
var FALSE = 0;

var SCREEN_WIDTH = 512;
var SCREEN_HEIGHT = 690;

var RECTICLE_WIDTH = 384; # real image is 1024*1024
var RECTICLE_HEIGHT = 512; # WIDTH * 4/3 because the image is seen in a 45 deg angle

var COLOR_FOREGROUND = [0.75,1,0.25]; # between yellow and green with some white
var COLOR_BACKGROUND = [1.0,1.0,1.0, 0.0]; # almost black with a bit of green

var GunSight = {
    new: func(_ident) {
        var gs_obj = {parents: [GunSight]};
        gs_obj.gs_canvas = canvas.new({
                             "name": "gs_canvas",
                             "size": [SCREEN_WIDTH, SCREEN_HEIGHT],  # tranbg.png is 512*512
                             "view": [SCREEN_WIDTH, SCREEN_HEIGHT],
                             "mipmapping": 0
        });

        gs_obj.input = {
            current_view_x_offset  : "sim/current-view/x-offset-m",
            current_view_y_offset  : "sim/current-view/y-offset-m",
            button                 : "sim/G91/gauge/SFOM_83A/button",
            view_config_x_offset   : "sim/view/config/x-offset-m",
            view_config_y_offset   : "sim/view/config/y-offset-m",
            view_internal          : "sim/current-view/internal",
            collimator_light_sw    : "fdm/jsbsim/systems/electric/bus[1]/collimator-lighting/sw",
            sun_angular_deg        : "sim/G91/ambient-data/sun-angular-deg",
            chrome_red             : "rendering/scene/chrome-light/red",
            chrome_green           : "rendering/scene/chrome-light/green",
            chrome_blue            : "rendering/scene/chrome-light/blue",
            light_active           : "sim/G91/gauge/SFOM_83A/isLightActive",
            light_intensity_bat    : "fdm/jsbsim/systems/warning-lights/light-intensity-by-bus1-tension",
            light_collimator_fuse  : "fdm/jsbsim/systems/electric/bus[1]/collimator-lighting/fuse",
            light_collimator_i     : "fdm/jsbsim/systems/electric/bus[1]/collimator-lighting/I",
            collimator_alpha       : "sim/G91/gauge/SFOM_83A/alpha",
            collimator_light       : "sim/G91/gauge/SFOM_83A/collimatorLight",
            collimator_red         : "sim/G91/gauge/SFOM_83A/collimator_red",
            collimator_green       : "sim/G91/gauge/SFOM_83A/collimator_green",
            collimator_blue        : "sim/G91/gauge/SFOM_83A/collimator_blue",
        };

        foreach(var name; keys(gs_obj.input)) {
            gs_obj.input[name] = props.globals.getNode(gs_obj.input[name], 1);
        }

        #gs_obj.gs_canvas.addPlacement({"node": "vtm_ac_object"});
        gs_obj.gs_canvas.addPlacement({"node": "Collimator_glass_TargetDOWN"});
        gs_obj.gs_canvas.setColorBackground(COLOR_BACKGROUND);

        gs_obj.root = gs_obj.gs_canvas.createGroup("root");
        gs_obj.root.setTranslation(0.5 * SCREEN_WIDTH, 0.5 * SCREEN_HEIGHT);

        gs_obj._createReticle();

        gs_obj.recipient = emesary.Recipient.new(_ident);
        gs_obj.recipient.parent_obj = gs_obj;

        gs_obj.recipient.Receive = func(notification) {
            if (notification.NotificationType == "FrameNotification") {
                me.parent_obj._update(notification);
                return emesary.Transmitter.ReceiptStatus_OK;
            }
            return emesary.Transmitter.ReceiptStatus_NotProcessed;
        };
        emesary.GlobalTransmitter.Register(gs_obj.recipient);

        gs_obj.valButton = 0;
        gs_obj.xOffset0 = 0;
        gs_obj.xOffset = 0;
        gs_obj.xOffset_prec = 0;
        gs_obj.yOffset0 = 0;
        gs_obj.yOffset = 0;
        gs_obj.yOffset_prec = 0;

        return gs_obj;
    },

    _createReticle: func() {
        me.reticle_group = me.root.createChild("group", "reticle_group");

        # sfom83A_path = "Models/Parts/Canopy/Gauges/SFOM_83A/SFOM_83A_03_Cross_1024.png";
        me.reticle_cross = me.reticle_group.createChild("image")
                                           .setFile("Models/Parts/Canopy/Gauges/SFOM_83A/SFOM_83A_03_Cross_1024.png")
                                           .setSize(RECTICLE_WIDTH, RECTICLE_HEIGHT);

        me.reticle_group.show();
    },

    _update: func(noti = nil) {
        #if (math.mod(noti.FrameCount, 2) > 0) {
        #    return;
        #}

        if (me.input.view_internal.getValue() == TRUE) {
            me.valButton = me.input.button.getValue();
            me.xOffset0 = me.input.view_config_x_offset.getValue();
            me.yOffset0 = me.input.view_config_y_offset.getValue();
            me._getViewXOffset();
            me._getViewYOffset();
            me._setCross();
            me._calcColorCrossSFOM83A();
        }
    },

    _getViewXOffset: func() {
        me.xOffset = me.xOffset0 - me.input.current_view_x_offset.getValue();
        if (math.abs(me.xOffset - me.xOffset_prec) > 0.0001) {
            me.xOffset_prec = me.xOffset;
        }
    },

    _getViewYOffset: func() {
        me.yOffset = me.yOffset0 - me.input.current_view_y_offset.getValue();
        if (math.abs(me.yOffset - me.yOffset_prec) > 0.0001) {
            me.yOffset_prec = me.yOffset;
        }
    },

    _setCross: func() {
        var me_x = me.xOffset * 10000 + 67;
        var me_y = me.yOffset * (-11100) + me.valButton;
        #print("me_x: "~me_x~" - me_y: "~me_y);
        me.reticle_group.setTranslation(me_x - RECTICLE_WIDTH/2, me_y - RECTICLE_HEIGHT/2);
    },

    _calcColorCrossSFOM83A: func() {
        var lightIntesity = me.input.collimator_light_sw.getValue();
        var ambientRedLight = 0.0;
        var ambientGreenLight = 0.0;
        var ambientBlueLight = 0.0;
        var sun_angular_deg = me.input.sun_angular_deg.getValue();
        var sun_direct_Light = 0.25 + math.pow((1 - sun_angular_deg * 0.01745 / 3.1428),2) * 0.75;
        ambientRedLight = me.input.chrome_red.getValue();
        ambientGreenLight = me.input.chrome_green.getValue();
        ambientBlueLight = me.input.chrome_blue.getValue() * 1.05;
        var collimatorLight = (ambientRedLight + ambientGreenLight + ambientBlueLight) / 3;
        whiteLight_sun = collimatorLight * (1 + sun_direct_Light) / 4.0;
        if (lightIntesity <= 0.01) {
            me.input.light_active.setValue(FALSE);
        } else {
            me.input.light_active.setValue(TRUE);
            var lightIntesityBattery = me.input.light_intensity_bat.getValue();
            var lightIntesityFuse = me.input.light_collimator_fuse.getValue();
            me.input.light_collimator_i.setValue(0.2 * lightIntesityBattery * lightIntesityFuse * lightIntesity);
            lightIntesity = lightIntesity * 0.6 * lightIntesityBattery * lightIntesityFuse;
            ambientRedLight = 1.0;
            ambientGreenLight = 0.5;
            ambientBlueLight = 0.0;
            whiteLight_sun = lightIntesity - whiteLight_sun * 0.9;
        }
        me.input.collimator_alpha.setValue(whiteLight_sun);
        me.input.collimator_light.setValue(collimatorLight);
        me.input.collimator_red.setValue(ambientRedLight);
        me.input.collimator_green.setValue(ambientGreenLight);
        me.input.collimator_blue.setValue(ambientBlueLight);

        me.reticle_cross.setColorFill(ambientRedLight, ambientGreenLight, ambientBlueLight, whiteLight_sun);
    },
};

var gun_sight = nil;
var gun_sight = GunSight.new("GunSight");
