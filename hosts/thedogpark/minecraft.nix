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
            #Ommey = "0843c8a8-8532-44e2-96a4-5ceccbf97c2";
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
        package = pkgs.fabricServers.fabric-1_21_4;
        jvmOpts = "-Xmx6144M -Xms6144M -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+ParallelRefProcEnabled -XX:+PerfDisableSharedMem -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1HeapRegionSize=8M -XX:G1HeapWastePercent=5 -XX:G1MaxNewSizePercent=40 -XX:G1MixedGCCountTarget=4 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1NewSizePercent=30 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15 -XX:MaxGCPauseMillis=200 -XX:MaxTenuringThreshold=1 -XX:SurvivorRatio=32 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true";
        symlinks = {
            mods = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
                BalmFabric = fetchurl { url = "https://cdn.modrinth.com/data/MBAkmtvl/versions/9pTQ0wCu/balm-fabric-1.21.4-21.4.5.jar"; sha512 = "cb7ae3fd9be8a9c2bdaee53787dab640fc09009e259fbf5e11566c16665835b43528603bda5716c1d8f84eb40abb5b8573b6448e77194b9779fa703bda1c4c29"; };
                CalcMod = fetchurl { url = "https://cdn.modrinth.com/data/XoHTb2Ap/versions/1vi9VuRV/calcmod-1.3.3%2Bfabric.1.21.4.jar"; sha512 = "5b0ae264171d6c329250d35c3c54a9681312a7fa897ab2ac92dedc30f234dd2ce60f5c6fdd9dc2c0a309add8e5d8be9b9332ba80e9bf4423e5e653dc3667aff9"; };
                FabricAPI = fetchurl { url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/IrJDerMf/fabric-api-0.114.1%2B1.21.4.jar"; sha512 = "ce8e14be350154c5b3b8346b122d9a1a4721f129b1263584b1b94e2038bb9d787bfc127b858aa07487d961d460adf16687a6d914ce5d6036efea12703726347c"; };
                FabricLanguageKotlin = fetchurl { url = "https://cdn.modrinth.com/data/Ha28R6CL/versions/csX9r2wS/fabric-language-kotlin-1.13.0%2Bkotlin.2.1.0.jar"; sha512 = "bd6acac5e2196aae0095ec453aec46d54e0d925289895fac94b1426cabd3db7e275302502475c61b9719fc8f026e7aaa305122dcdf374c58620bc38b8b4e99a7"; };
                ModernFix = fetchurl { url = "https://cdn.modrinth.com/data/nmDcB62a/versions/gx7PIV8n/modernfix-fabric-5.20.1%2Bmc1.21.4.jar"; sha512 = "e1596a89dc100f454c445d64b5ebf59f1788de22270a4ca52837337abe6a76c517c771e234ededbadf5b51dbb62efe1bc0eccee841c45bc263f9406d8348dfe8"; };
                # Dynmap = fetchurl { url = "https://cdn.modrinth.com/data/fRQREgAc/versions/ipBhc6VW/Dynmap-3.7-beta-6-fabric-1.21.jar"; sha512 = "dc279ab68847fa52db38a2bd5d2a1ecc5b9779e606f1f0efafeaac2166787d2b317a9821b3f2fdc9ea76c8fc8818eba6caf989f9b3b73bdf665f9c773676c848"; };
                c2me = fetchurl { url = "https://cdn.modrinth.com/data/VSNURh3q/versions/fBvLHC54/c2me-fabric-mc1.21.4-0.3.1.0.jar"; sha512 = "c1903fa2e703832d1d946d02826b9e2fe08229032eea182942ff15797bdc3d4afd49a05f429814611c5b7dcccc9ab853693c3efb22cd9522f83ec04e15a6ec88"; };
                FerriteCore = fetchurl { url = "https://cdn.modrinth.com/data/uXXizFIs/versions/IPM0JlHd/ferritecore-7.1.1-fabric.jar"; sha512 = "f41dc9e8b28327a1e29b14667cb42ae5e7e17bcfa4495260f6f851a80d4b08d98a30d5c52b110007ee325f02dac7431e3fad4560c6840af0bf347afad48c5aac"; };
                RepurposedStructures = fetchurl { url = "https://cdn.modrinth.com/data/muf0XoRe/versions/d8GJlOgV/repurposed_structures-7.5.13%2B1.21.4-fabric.jar"; sha512 = "ceeac621156e1cc57bb62b3354d5b4f24670df769083da9f6e0d9403ac2f12cf0dc623f04020c9eae832c06b6b0798eb622fac9fed20485dba8fa9936fae8126"; };
                Explorify = fetchurl { url = "https://cdn.modrinth.com/data/HSfsxuTo/versions/yRSH0sWM/Explorify%20v1.6.2%20f10-48.jar"; sha512 = "3d9ec324a1cbe4d98bb4b47bea721e1b629e11ba9b2c07d6da7a844b941f2ce71092edfbe56c62c8e14c7eda15652986de464b80ececb22334181510f374ccbb"; };
                Collective = fetchurl { url = "https://cdn.modrinth.com/data/e0M1UDsY/versions/F3ciVO4i/collective-1.21.4-7.89.jar"; sha512 = "8659df746343e697388b878b52d8eb49027ca528a75f7549177539bf21af26c4f0053acf4552abb36c8d5e5010d6d07976ba64e2b256cda4145785a6acab795d"; };
                # IndividualKeepInventory = fetchurl { url = "https://cdn.modrinth.com/data/LfkUkM76/versions/5ttMNZ2t/individualkeepinv-1.1.3-1.21.jar"; sha512 = "121c576d07263cb4baae689233fb5b78dc2752e4e265f160466fcf379b8b795ac7184a26d0c5b1a3a1cd4e3c5a02243c5ff790bfb726f9d77f28d7e222ee9a99"; };
                ViewDistanceFix = fetchurl { url = "https://cdn.modrinth.com/data/nxrXbh5K/versions/JHg6ZYop/viewdistancefix-fabric-1.21.4-1.0.2.jar"; sha512 = "803b4d83b4c09c231b66c3f5fd068b4f55491c743207455fda8eb175a70ab51b5c6f09185d589555829906b44da1843e8ac722ea39919c4cc2a15dc4d5493b13"; };
                # NetherPortalFix = fetchurl { url = "https://cdn.modrinth.com/data/nPZr02ET/versions/KtMN6zDF/netherportalfix-fabric-1.21.1-21.1.1.jar"; sha512 = "1ffc7f265b6236450d4439bb3c79f9c25ffa031a953be9a057893a23f75e40078262135bec67e28e8383d60a464c77c87bb2211e906cd4913a3b6755e513acc9"; };
                NoChatReports = fetchurl { url = "https://cdn.modrinth.com/data/qQyHxfxd/versions/9xt05630/NoChatReports-FABRIC-1.21.4-v2.11.0.jar"; sha512 = "d343b05c8e50f1de15791ff622ad44eeca6cdcb21e960a267a17d71506c61ca79b1c824167779e44d778ca18dcbdebe594ff234fbe355b68d25cdb5b6afd6e4f"; };
                DungeonsAndTaverns = fetchurl { url = "https://cdn.modrinth.com/data/tpehi7ww/versions/PAUVovtf/dungeons-and-taverns-v4.6.jar"; sha512 = "e590953bd84048a3766bfdd0027bf4dc3ef4289dd428ff032e49fb50fc15c3cc4476f50d9fff53b3aee028db002981d4f4f0aeb47d11454a000c54dcc76d0791"; };
                LeashablePlayers = fetchurl { url = "https://cdn.modrinth.com/data/BKyMf6XK/versions/ikLeZ0BV/leashmod-1.1.0.jar"; sha512 = "bde72458f443518220ca12f967faf9084132b4c14c138700878139e4672a7d36f1c78f405e41484fc041da3c9cc1e56068cd7fbfd3d0814c8fa7ff7614040233"; };
                VillagerNames = fetchurl { url = "https://cdn.modrinth.com/data/gqRXDo8B/versions/vlScJPLF/villagernames-1.21.4-8.1.jar"; sha512 = "7febcdb4ad7e82b64507a1c142d0613dfe4e09a6094174c095dc4812cccb1d0bebe73a1e1c31e69107de6ad29aab4a9e1e75155eb48b6c12c672bba0ac9b1fc3"; };
                ArchitecturyAPI = fetchurl { url = "https://cdn.modrinth.com/data/lhGA9TYQ/versions/XRwibvvn/architectury-15.0.1-fabric.jar"; sha512 = "df0e163a560439c1911c584821a643c665b13bbd541db9a9f318cdf33db0aee4573e3c901e4a3aad585e10013de1b4dc62143dce0855a2c915fcd0b35ee28263"; };
                Chunky = fetchurl { url = "https://cdn.modrinth.com/data/fALzjamp/versions/VkAgASL1/Chunky-Fabric-1.4.27.jar"; sha512 = "a89f94947e7c3992e01e46be8967d2a6593334333a546b4fff5fdb02a1f5a6b83c93adc4c72a9b9b1f14f9299efcaa8a5d7f5eeedf3da541c7e72abc5e2724c6"; };
                MidnightLib = fetchurl { url = "https://cdn.modrinth.com/data/codAaoxh/versions/TEo961AO/midnightlib-fabric-1.6.6%2B1.21.4.jar"; sha512 = "26340fdd01d3d7499f2654244b9debaeab9fddacf3a2fd3c59fd01b9f5ca9624ee84d44a29fec74570ae16db3bd9e0a84c8b2726647f9473fa90eeaca2ec991d"; };
            });
        };
      };
    #   servers.magicalCreate = {
    #     enable = true;
    #     autoStart = true;
    #     enableReload = true;
    #     whitelist = {
    #         Misty_TTM = "e914b64b-5b4c-4ca0-a655-2b7dd28d2ebb";
    #     };
    #     serverProperties = {
    #         allow-flight = false;
    #         allow-nether = true;
    #         broadcast-console-to-ops = true;
    #         difficulty = 3;
    #         enable-command-block = true;
    #         enable-status = true;
    #         enforce-secure-profile = false;
    #         enforce-whitelist = true;
    #         gamemode = 0;
    #         generate-structures = true;
    #         level-name = "magicalCreate";
    #         max-players = 5;
    #         motd = "Magical Create for Nox and Misty";
    #         online-mode = true;
    #         pause-when-empty-seconds = 120;
    #         pvp = true;
    #         simulation-distance = 10;
    #         spawn-animals=true;
    #         spawn-monsters = true;
    #         spawn-npcs = true;
    #         view-distance=16;
    #         white-list = true;
    #     };
    #     package = pkgs.fabricServers.fabric-1_20_1;
    #     jvmOpts = "-Xmx4096M -Xms4096M -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+ParallelRefProcEnabled -XX:+PerfDisableSharedMem -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1HeapRegionSize=8M -XX:G1HeapWastePercent=5 -XX:G1MaxNewSizePercent=40 -XX:G1MixedGCCountTarget=4 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1NewSizePercent=30 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15 -XX:MaxGCPauseMillis=200 -XX:MaxTenuringThreshold=1 -XX:SurvivorRatio=32 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true";
    #     symlinks = {
    #         mods = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
                
    #         });
    #     };
    #   };
    };
}
