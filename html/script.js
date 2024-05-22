document.onreadystatechange = () => {
    if (document.readyState === "complete") {
        window.addEventListener('message', function(event) {

            if (event.data.type == "enablecam") {
                CameraApp.OpenCameras(event.data.label, event.data.connected, event.data.id, event.data.time, event.data.address);
            } else if (event.data.type == "disablecam") {
                CameraApp.CloseCameras();
            }
        });
    };
};

const CameraApp = new Vue({
    el: "#camcontainer",

    data: {
        camerasOpen: false,
        cameraLabel: ":)",
        connectLabel: "CONNECTED",
        ipLabel: "192.168.0.1",
        dateLabel: "04/09/1999",
        timeLabel: "16:27:49",
    },

    methods: {
        OpenCameras(label, connected, cameraId, time, address) {
            var today = new Date();
            var date = today.getDate()+'/'+(today.getMonth()+1)+'/'+today.getFullYear();
            var formatTime = "00:" + time

            this.camerasOpen = true;
            this.ipLabel = cameraId;
            if (connected) {
                $("#blockscreen").css("display", "none");
                this.cameraLabel = label;
                this.connectLabel = "CONNECTED";
                this.dateLabel = date;
                this.timeLabel = address+" | "+formatTime;

                $("#connectedlabel").removeClass("disconnect");
                $("#connectedlabel").addClass("connect");
            } else {
                $("#blockscreen").css("display", "block");
                this.cameraLabel = "ERROR #400: BAD REQUEST"
                this.connectLabel = "CONNECTION FAILED";
                this.dateLabel = "ERROR";
                this.timeLabel = "ERROR";

                $("#connectedlabel").removeClass("connect");
                $("#connectedlabel").addClass("disconnect");
            }
            
        },

        CloseCameras() {
            this.camerasOpen = false;
            $("#blockscreen").css("display", "none");
        },

        UpdateCameraLabel(label) {
            this.cameraLabel = label;
        },

        UpdateCameraTime(time) {
            var formatTime = "00:" + time
            this.timeLabel = formatTime;
        },
    }
});
