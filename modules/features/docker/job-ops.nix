{...}: {
  flake.nixosModules.job-ops = {...}: {
    virtualisation.oci-containers.containers.job-ops = {
      image = "ghcr.io/dakheera47/job-ops:latest";
      autoStart = true;
      ports = ["3005:3001"];
    };
  };
}
