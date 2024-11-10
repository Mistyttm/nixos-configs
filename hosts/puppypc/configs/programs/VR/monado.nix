{ pkgs, ... }: {
    services.monado = {
        enable = true;
        package = pkgs.monado;
    };
}
