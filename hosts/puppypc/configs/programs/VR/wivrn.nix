{ pkgs, ... }: {
    services.wivrn = {
        enable = true;
        package = pkgs.wivrn;
        openFirewall = true;
        defaultRuntime = true;
        autoStart = true;
        config = {
            enable = true;
            json = {
                # 50 Mb/s
                bitrate = 50000000;
                encoders = [
                    {
                    encoder = "nvenc";
#                     codec = "h265";
                    # 1.0 x 1.0 scaling
                    width = 1.0;
                    height = 1.0;
                    offset_x = 0.0;
                    offset_y = 0.0;
                    }
                ];
                application = [ pkgs.wlx-overlay-s ];
            };
        };
    };
}
