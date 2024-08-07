{ self, config }:
{
  age.secrets = {
    dashboard-env = {
      file = "${self}/secrets/homepage-dashboard-env.age";
      owner = "root";
      group = "users";
      mode = "400";
    };
  };

  services.homepage-dashboard = {
    environmentFile = config.age.secrets.dashboard-env.path;
    bookmarks = [
      {
        dev = [
          {
            github = [
              {
                abbr = "GH";
                href = "https://github.com/";
                icon = "github-light.png";
              }
            ];
          }
          {
            "homepage docs" = [
              {
                abbr = "HD";
                href = "https://gethomepage.dev";
                icon = "homepage.png";
              }
            ];
          }
        ];
      }
    ];
    services = [
      {
        media = [
          {
            Jellyfin = {
              icon = "jellyfin.png";
              href = "{{JELLYFIN_URL}}";
              description = "media management";
              widget = {
                type = "jellyfin";
                url = "{{JELLYFIN_URL}}";
                key = "{{JELLYFIN_API_KEY}}";
              };
            };
          }
          {
            Radarr = {
              icon = "radarr.png";
              href = "{{RADARR_URL}}";
              description = "film management";
              widget = {
                type = "radarr";
                url = "{{RADARR_URL}}";
                key = "{{RADARR_API_KEY}}";
              };
            };
          }
          {
            Sonarr = {
              icon = "sonarr.png";
              href = "{{SONARR_URL}}";
              description = "tv management";
              widget = {
                type = "sonarr";
                url = "{{SONARR_URL}}";
                key = "{{SONARR_API_KEY}}";
              };
            };
          }
          {
            Prowlarr = {
              icon = "prowlarr.png";
              href = "{{PROWLARR_URL}}";
              description = "index management";
              widget = {
                type = "prowlarr";
                url = "{{PROWLARR_URL}}";
                key = "{{PROWLARR_API_KEY}}";
              };
            };
          }
          {
            Sabnzbd = {
              icon = "sabnzbd.png";
              href = "{{SABNZBD_URL}}/";
              description = "download client";
              widget = {
                type = "sabnzbd";
                url = "{{SABNZBD_URL}}";
                key = "{{SABNZBD_API_KEY}}";
              };
            };
          }
        ];
      }
      {
        infra = [
          {
            Files = {
              description = "file manager";
              icon = "files.png";
              href = "https://files.jnsgr.uk";
            };
          }
          {
            "Syncthing (thor)" = {
              description = "syncthing ui for thor";
              icon = "syncthing.png";
              href = "https://thor.sync.jnsgr.uk";
            };
          }
          {
            "Syncthing (kara)" = {
              description = "syncthing ui for kara";
              icon = "syncthing.png";
              href = "https://kara.sync.jnsgr.uk";
            };
          }
          {
            "Syncthing (freyja)" = {
              description = "syncthing ui for freyja";
              icon = "syncthing.png";
              href = "https://freyja.sync.jnsgr.uk";
            };
          }
        ];
      }
    ];
    settings = {
      title = "joip homepage";
      # favicon = "https://jnsgr.uk/favicon.ico";
      headerStyle = "clean";
      layout = {
        media = {
          style = "row";
          columns = 3;
        };
        infra = {
          style = "row";
          columns = 4;
        };
      };
    };
    widgets = [
      {
        search = {
          provider = "google";
          target = "_blank";
        };
      }
      {
        resources = {
          label = "system";
          cpu = true;
          memory = true;
        };
      }
      {
        resources = {
          label = "storage";
          disk = [ "/data" ];
        };
      }
      {
        openmeteo = {
          label = "Reykjavik";
          timezone = "Europe/London";
          latitude = "{{LATITUDE}}";
          longitude = "{{LONGITUDE}}";
          units = "metric";
        };
      }
    ];
  };
}
