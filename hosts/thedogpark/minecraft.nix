{ pkgs, ... }:
let
    fetchurl = pkgs.fetchurl;
in {
    services.minecraft-servers = {
      enable = true;
      eula = true;
      openFirewall = true;
      servers.skyship = {
        enable = true;
        autoStart = true;
        enableReload = true;
        whitelist = {
            Misty_TTM = "e914b64b-5b4c-4ca0-a655-2b7dd28d2ebb";
#            Ommey = "0843c8a8-8532-44e2-96a4-5ceccbf97c2";
            DizzyinaTizzy = "f5b5008c-f44d-44cd-8fcb-492895ae7ce9";
            Vanity_Dolls = "9ce829ce-a7c8-4cd8-ac28-73ee6739d784";
            The_Menagerie = "e0da066f-e6e3-46a8-9a16-f9a8161c7e15";
        };
        serverProperties = {
            allow-flight = false;
            allow-nether = true;
            broadcast-console-to-ops = true;
            difficulty = 3;
            enable-command-block = true;
            enable-status = true;
            enforce-secure-profile = false;
            enforce-whitelist = true;
            gamemode = 0;
            generate-structures = true;
            level-name = "skyship";
            max-players = 5;
            motd = "Skyship Hex Horizon but Minecraft";
            online-mode = true;
            pause-when-empty-seconds = 120;
            pvp = true;
            simulation-distance = 10;
            spawn-animals=true;
            spawn-monsters = true;
            spawn-npcs = true;
            view-distance=16;
            white-list = true;
        };
        package = pkgs.fabricServers.fabric-1_21_1      ;
        jvmOpts = "-Xmx6144M -Xms6144M -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+ParallelRefProcEnabled -XX:+PerfDisableSharedMem -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1HeapRegionSize=8M -XX:G1HeapWastePercent=5 -XX:G1MaxNewSizePercent=40 -XX:G1MixedGCCountTarget=4 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1NewSizePercent=30 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15 -XX:MaxGCPauseMillis=200 -XX:MaxTenuringThreshold=1 -XX:SurvivorRatio=32 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true";
        symlinks = {
            mods = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
                BalmFabric = fetchurl { url = "https://cdn.modrinth.com/data/MBAkmtvl/versions/8y2siHEz/balm-fabric-1.21.1-21.0.20.jar"; sha512 = "5590bac4a759d43cba192d54052226d20bff13e6199ff468f79774ae550ff622535dc0a5be632f1834f2cbb92321c1c5697b096368348ff9ca620a83b4f1cb22"; };
                CalcMod = fetchurl { url = "https://cdn.modrinth.com/data/XoHTb2Ap/versions/LE8aEZ5E/calcmod-1.3.2%2Bfabric.1.21.jar"; sha512 = "cd6e2859661f2020a52d1f61596e1db8156af69cf8879cf297237cb80ea5a955c1cb9eb6ee4fd59c3538411779d121fab0333b9e915f863e9c605a89b6bb74fb"; };
                FabricAPI = fetchurl { url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/gQS3JbZO/fabric-api-0.103.0%2B1.21.1.jar"; sha512 = "085e985d3000afb0d0d799fdf83f7f084dd240e9852ccb4d94ad13fc3d3fad90b00b02dcc493e3c38a66ae4757389582eccf89238569bacae638b9ffd9885ebc"; };
                FabricLanguageKotlin = fetchurl { url = "https://cdn.modrinth.com/data/Ha28R6CL/versions/FayzGq0c/fabric-language-kotlin-1.12.1%2Bkotlin.2.0.20.jar"; sha512 = "0bb8c5ef1cec3ee48e00af14fee16e4d0c72f93268952125aecc8b444197324a8f5c8a8f6535314e6d0cf0124770323bc005a0cb5a7f132030de0228f206efb7"; };
                ModernFix = fetchurl { url = "https://cdn.modrinth.com/data/nmDcB62a/versions/i8GSONFm/modernfix-fabric-5.19.1%2Bmc1.21.jar"; sha512 = "68b4c5f4be272461a25e61924f6a8b15e50e3c47cef3bcc7866435d186b915574c8cc8adb96116a36fe48f7cf9a3f8e442f9cb85184e50b4cb4348dc4ebb0c84"; };
                # Dynmap = fetchurl { url = "https://cdn.modrinth.com/data/fRQREgAc/versions/ipBhc6VW/Dynmap-3.7-beta-6-fabric-1.21.jar"; sha512 = "dc279ab68847fa52db38a2bd5d2a1ecc5b9779e606f1f0efafeaac2166787d2b317a9821b3f2fdc9ea76c8fc8818eba6caf989f9b3b73bdf665f9c773676c848"; };
                c2me = fetchurl { url = "https://cdn.modrinth.com/data/VSNURh3q/versions/zrRZhnUj/c2me-fabric-mc1.21.1-0.3.0%2Balpha.0.204.jar"; sha512 = "127ad45890d60eefbae0aa9347ec786bf557778d87a00eda857eb8551cff25afb0fa3e5a7a6fa8ba2b0b10614a06d590429ac07068cdd1a560e4b3b6e3797a81"; };
                FerriteCore = fetchurl { url = "https://cdn.modrinth.com/data/uXXizFIs/versions/wmIZ4wP4/ferritecore-7.0.0-fabric.jar"; sha512 = "0f2f9b5aebd71ef3064fc94df964296ac6ee8ea12221098b9df037bdcaaca7bccd473c981795f4d57ff3d49da3ef81f13a42566880b9f11dc64645e9c8ad5d4f"; };
                RepurposedStructures = fetchurl { url = "https://cdn.modrinth.com/data/muf0XoRe/versions/kyBAwt1N/repurposed_structures-7.5.9%2B1.21.1-fabric.jar"; sha512 = "6e232a91e74fdae7b395becd9c6ac8721032cf9c39b4e3e1c34e40bf7267bd052af1527549a28248a0d3f975731911494a91b5444fbc19fa7e9cd41f6ebd69fd"; };
                Explorify = fetchurl { url = "https://cdn.modrinth.com/data/HSfsxuTo/versions/ovtuGAG4/Explorify%20v1.6.1%20f10-48.jar"; sha512 = "826e19bb067ff2e42b18ca7b26b0adc0af3be146c5a281a9e4e0d1b13331fcb78085bfe038b22e54b17bfd5c7d668f55e280cbb332b0cd75aaaafc8ea13b03fe"; };
                Collective = fetchurl { url = "https://cdn.modrinth.com/data/e0M1UDsY/versions/13do3Fe4/collective-1.21.1-7.84.jar"; sha512 = "2bcd62f2b74a10b603e68786db669aaeaa3498eac766fd208851e24f5807a2fd95135a0fec2b6308f64931275a412310166427390d7fca513a6811e6a4c5e969"; };
                IndividualKeepInventory = fetchurl { url = "https://cdn.modrinth.com/data/LfkUkM76/versions/5ttMNZ2t/individualkeepinv-1.1.3-1.21.jar"; sha512 = "121c576d07263cb4baae689233fb5b78dc2752e4e265f160466fcf379b8b795ac7184a26d0c5b1a3a1cd4e3c5a02243c5ff790bfb726f9d77f28d7e222ee9a99"; };
                ViewDistanceFix = fetchurl { url = "https://cdn.modrinth.com/data/nxrXbh5K/versions/MYTZEnn2/viewdistancefix-fabric-1.21.1-1.0.2.jar"; sha512 = "aa2d7ef5ec40e63ababdee89cf131e713a7d33d891a73332d559e5f07a5cbf1d39331cccbbfb6a812b8cc0d9123683d584cd343e0392d184d7a47db00556b441"; };
                # NetherPortalFix = fetchurl { url = "https://cdn.modrinth.com/data/nPZr02ET/versions/KtMN6zDF/netherportalfix-fabric-1.21.1-21.1.1.jar"; sha512 = "1ffc7f265b6236450d4439bb3c79f9c25ffa031a953be9a057893a23f75e40078262135bec67e28e8383d60a464c77c87bb2211e906cd4913a3b6755e513acc9"; };
                NoChatReports = fetchurl { url = "https://cdn.modrinth.com/data/qQyHxfxd/versions/riMhCAII/NoChatReports-FABRIC-1.21-v2.8.0.jar"; sha512 = "092837afc0fcb5208561062f8e4cd69971efa94c0180ae377e318d35d8f278abbf1552e4a577be882dc7e870f884779bc36caf808c8bc90bb05490f1e034ddb8"; };
                DungeonsAndTaverns = fetchurl { url = "https://cdn.modrinth.com/data/tpehi7ww/versions/QmeQn0Mp/dungeons-and-taverns-v4.3.jar"; sha512 = "0a86dad1b41d4513db9f6349aa6ed01e0a696ac2a45d1e5c48705060e43abbafdd0838f2fed15144598fb85770d73036b2f91af3faa3b15b38c0d0e547bc9636"; };
                LeashablePlayers = fetchurl { url = "https://cdn.modrinth.com/data/BKyMf6XK/versions/ikLeZ0BV/leashmod-1.1.0.jar"; sha512 = "bde72458f443518220ca12f967faf9084132b4c14c138700878139e4672a7d36f1c78f405e41484fc041da3c9cc1e56068cd7fbfd3d0814c8fa7ff7614040233"; };
                VillagerNames = fetchurl { url = "https://cdn.modrinth.com/data/gqRXDo8B/versions/WPsLTKwG/villagernames-1.21.1-8.1.jar"; sha512 = "fddecb49904e20decaed967060e286e09f99636d27622f55c6a3f86c71fd31ae2dff8caa36a387213bf6465f1560efc0840f53a7e5e4b6d58b2c173c25884666"; };
                ArchitecturyAPI = fetchurl { url = "https://cdn.modrinth.com/data/lhGA9TYQ/versions/afBcyXjI/architectury-13.0.6-fabric.jar"; sha512 = "e1b2aeeb5ce17fe05314814274cc116c8f2aba325f5edc766caaf52445c69c79fd0f3235842d24df11346b3505a5befa5782a95b1992266097e558dd394d715b"; };
                Chunky = fetchurl { url = "https://cdn.modrinth.com/data/fALzjamp/versions/dPliWter/Chunky-1.4.16.jar"; sha512 = "7e862f4db563bbb5cfa8bc0c260c9a97b7662f28d0f8405355c33d7b4100ce05378b39ed37c5d75d2919a40c244a3011bb4ba63f9d53f10d50b11b32656ea395"; };
                MidnightLib = fetchurl { url = "https://cdn.modrinth.com/data/codAaoxh/versions/CtLJXKCX/midnightlib-fabric-1.6.2.jar"; sha512 = "03807586fe0d793987b7e687ca42fc1c3bbd92a5c0f8076a242a7389153856fa5d3d7bdf33f2711f0bb25f8abb43c6d0eeb104907b67e09916e981ec25759f3e"; };
            });
        };
      };
    };
}
