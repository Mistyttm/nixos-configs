{ config, pkgs, nix-minecraft, lib, fetchurl, ... }: {
    services.minecraft-servers = {
      enable = true;
      eula = true;
      openFirewall = true;
      servers.skyship = {
        enable = true;
        autoStart = true;
        restart = "always";
        enableReload = true;
        whitelist = {
            Misty_TTM = "e914b64b-5b4c-4ca0-a655-2b7dd28d2ebb";
            Ommey = "0843c8a8-8532-44e2-96a4-5ceccbf97c2";
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
            query.port = 25565;
            simulation-distance = 10;
            spawn-animals=true;
            spawn-monsters = true;
            spawn-npcs = true;
            view-distance=16;
            white-list = true;
        };
        package = pkgs.minecraftServers.fabric-1_21;
        jvmOpts = "-Xmx6144M -Xms6144M -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+ParallelRefProcEnabled -XX:+PerfDisableSharedMem -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1HeapRegionSize=8M -XX:G1HeapWastePercent=5 -XX:G1MaxNewSizePercent=40 -XX:G1MixedGCCountTarget=4 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1NewSizePercent=30 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15 -XX:MaxGCPauseMillis=200 -XX:MaxTenuringThreshold=1 -XX:SurvivorRatio=32 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true";
        symlinks = {
            mods = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
                FabricAPI = builtins.fetchurl { url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/oGwyXeEI/fabric-api-0.102.0%2B1.21.jar"; hash = "sha512=11732c4e36c3909360a24aa42a44da89048706cf10aaafa0404d7153cbc7395ff68a130f7b497828d6932740e004416b692650c3fbcc1f32babd7cb6eb9791d8"; };
                AudioPlayer = builtins.fetchurl { url = "https://cdn.modrinth.com/data/SRlzjEBS/versions/j4Ln78VF/audioplayer-fabric-1.21.1-1.10.3.jar"; sha512 = "74542c232e9926732d2e295fcb2e3524d2f777d85319bc6369259510a0c95ba6a328f2310b6c054af9ff4f9b82a6e85ecf0971aa1301643e673044a2b165dc3a"; };
                FabricLanguageKotlin = builtins.fetchurl { url = "https://cdn.modrinth.com/data/Ha28R6CL/versions/kdDGGNEt/fabric-language-kotlin-1.12.0%2Bkotlin.2.0.10.jar"; sha512 = "e6765b777159fb1facf462dcbabcb6539ba0a89b55556a288121f4bf9e3f2b2f9b851107656d87ec3eb2cb27df13457aaf94f011739b98fa498e08abb7caea71"; };
                ModernFix = builtins.fetchurl { url = "https://cdn.modrinth.com/data/nmDcB62a/versions/i8GSONFm/modernfix-fabric-5.19.1%2Bmc1.21.jar"; sha512 = "68b4c5f4be272461a25e61924f6a8b15e50e3c47cef3bcc7866435d186b915574c8cc8adb96116a36fe48f7cf9a3f8e442f9cb85184e50b4cb4348dc4ebb0c84"; };
                Dynmap = builtins.fetchurl { url = "https://cdn.modrinth.com/data/fRQREgAc/versions/ipBhc6VW/Dynmap-3.7-beta-6-fabric-1.21.jar"; sha512 = "dc279ab68847fa52db38a2bd5d2a1ecc5b9779e606f1f0efafeaac2166787d2b317a9821b3f2fdc9ea76c8fc8818eba6caf989f9b3b73bdf665f9c773676c848"; };
                c2me = builtins.fetchurl { url = "https://cdn.modrinth.com/data/VSNURh3q/versions/fEWDAK3p/c2me-fabric-mc1.21-0.2.0%2Balpha.11.109.jar"; sha512 = "f9517e40de00da3d6cd11c01cc56cc5af143cb81eb3835cdc29fa5062cbc1d0fbb828e99a1e6239a6008c629757fc7ac78257de5f0741229703795d8f9172e8b"; };
                FerriteCore = builtins.fetchurl { url = "https://cdn.modrinth.com/data/uXXizFIs/versions/wmIZ4wP4/ferritecore-7.0.0-fabric.jar"; sha512 = "0f2f9b5aebd71ef3064fc94df964296ac6ee8ea12221098b9df037bdcaaca7bccd473c981795f4d57ff3d49da3ef81f13a42566880b9f11dc64645e9c8ad5d4f"; };
                RepurposedStructures = fetchurl { url = "https://cdn.modrinth.com/data/muf0XoRe/versions/ayr5NDIc/repurposed_structures-7.5.4%2B1.21-fabric.jar"; sha512 = "d05cb59e2e57bc77569194c946d091f182516172574b364ea990c569994c1edc18335bab93745c0c35d842e2b686d52e43fca4fa417813df89f27e8e42a12110"; };
                Explorify = builtins.fetchurl { url = "https://cdn.modrinth.com/data/HSfsxuTo/versions/ovtuGAG4/Explorify%20v1.6.1%20f10-48.jar"; sha512 = "826e19bb067ff2e42b18ca7b26b0adc0af3be146c5a281a9e4e0d1b13331fcb78085bfe038b22e54b17bfd5c7d668f55e280cbb332b0cd75aaaafc8ea13b03fe"; };
                Collective = builtins.fetchurl { url = "https://cdn.modrinth.com/data/e0M1UDsY/versions/13do3Fe4/collective-1.21.1-7.84.jar"; sha512 = "2bcd62f2b74a10b603e68786db669aaeaa3498eac766fd208851e24f5807a2fd95135a0fec2b6308f64931275a412310166427390d7fca513a6811e6a4c5e969"; };
                IndividualKeepInventory = builtins.fetchurl { url = "https://cdn.modrinth.com/data/LfkUkM76/versions/5ttMNZ2t/individualkeepinv-1.1.3-1.21.jar"; sha512 = "121c576d07263cb4baae689233fb5b78dc2752e4e265f160466fcf379b8b795ac7184a26d0c5b1a3a1cd4e3c5a02243c5ff790bfb726f9d77f28d7e222ee9a99"; };
                ViewDistanceFix = builtins.fetchurl { url = "https://cdn.modrinth.com/data/nxrXbh5K/versions/MYTZEnn2/viewdistancefix-fabric-1.21.1-1.0.2.jar"; sha512 = "aa2d7ef5ec40e63ababdee89cf131e713a7d33d891a73332d559e5f07a5cbf1d39331cccbbfb6a812b8cc0d9123683d584cd343e0392d184d7a47db00556b441"; };
                NoChatReports = builtins.fetchurl { url = "https://cdn.modrinth.com/data/qQyHxfxd/versions/riMhCAII/NoChatReports-FABRIC-1.21-v2.8.0.jar"; sha512 = "092837afc0fcb5208561062f8e4cd69971efa94c0180ae377e318d35d8f278abbf1552e4a577be882dc7e870f884779bc36caf808c8bc90bb05490f1e034ddb8"; };
                DungeonsAndTaverns = builtins.fetchurl { url = "https://cdn.modrinth.com/data/tpehi7ww/versions/PoMcAQWW/dungeons-and-taverns-v4.3.jar"; sha512 = "1411b97a5773c23996f75ebdd62a5afd018af2bec0f88892bfe57e095e0a71b79816304ae1ce146d8d33c3792216457d1d4cb3b8fdee87f9f632084df1edd3b6"; };
                LeashablePlayers = builtins.fetchurl { url = "https://cdn.modrinth.com/data/BKyMf6XK/versions/ikLeZ0BV/leashmod-1.1.0.jar"; sha512 = "bde72458f443518220ca12f967faf9084132b4c14c138700878139e4672a7d36f1c78f405e41484fc041da3c9cc1e56068cd7fbfd3d0814c8fa7ff7614040233"; };
                VillagerNames = builtins.fetchurl { url = "https://cdn.modrinth.com/data/gqRXDo8B/versions/WPsLTKwG/villagernames-1.21.1-8.1.jar"; sha512 = "fddecb49904e20decaed967060e286e09f99636d27622f55c6a3f86c71fd31ae2dff8caa36a387213bf6465f1560efc0840f53a7e5e4b6d58b2c173c25884666"; };
                ArchitecturyAPI = builtins.fetchurl { url = "https://cdn.modrinth.com/data/lhGA9TYQ/versions/afBcyXjI/architectury-13.0.6-fabric.jar"; sha512 = "e1b2aeeb5ce17fe05314814274cc116c8f2aba325f5edc766caaf52445c69c79fd0f3235842d24df11346b3505a5befa5782a95b1992266097e558dd394d715b"; };
                Chunky = builtins.fetchurl { url = "https://cdn.modrinth.com/data/fALzjamp/versions/dPliWter/Chunky-1.4.16.jar"; sha512 = "7e862f4db563bbb5cfa8bc0c260c9a97b7662f28d0f8405355c33d7b4100ce05378b39ed37c5d75d2919a40c244a3011bb4ba63f9d53f10d50b11b32656ea395"; };
                MidnightLib = builtins.fetchurl { url = "https://cdn.modrinth.com/data/codAaoxh/versions/onYewt68/midnightlib-fabric-1.5.8.jar"; sha512 = "af4b730786eb9c2958f53209d260a97a03b8d10b903b02ea90a06fc6ea57982e6048c67d735b884e7ad3b0006eb81edba1917ea71018c595d4453a6af4945d84"; };
                SimpleVoiceChat = builtins.fetchurl { url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/nS19YToN/voicechat-bukkit-2.5.20.jar"; sha512 = "c62814171e0d896353d0fa89dd81cefb071f36a5063a37c0ef9fa5c9c412546e0e42d5bf5f6966eb39f7294012f264dc63337ecc444cf9e8d7497f43b39e17d8"; };
            });
        };
      };
    };
}
