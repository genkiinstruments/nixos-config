{ config, ... }:
{
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
              href = "{{HOMEPAGE_VAR_JELLYFIN_URL}}";
              description = "media management";
              widget = {
                type = "jellyfin";
                url = "{{HOMEPAGE_VAR_JELLYFIN_URL}}";
                key = "{{HOMEPAGE_VAR_JELLYFIN_API_KEY}}";
              };
            };
          }
          {
            Radarr = {
              icon = "radarr.png";
              href = "{{HOMEPAGE_VAR_RADARR_URL}}";
              description = "film management";
              widget = {
                type = "radarr";
                url = "{{HOMEPAGE_VAR_RADARR_URL}}";
                key = "{{HOMEPAGE_VAR_RADARR_API_KEY}}";
              };
            };
          }
          {
            Sonarr = {
              icon = "sonarr.png";
              href = "{{HOMEPAGE_VAR_SONARR_URL}}";
              description = "tv management";
              widget = {
                type = "sonarr";
                url = "{{HOMEPAGE_VAR_SONARR_URL}}";
                key = "{{HOMEPAGE_VAR_SONARR_API_KEY}}";
              };
            };
          }
          {
            Bazarr = {
              icon = "bazarr.png";
              href = "{{HOMEPAGE_VAR_BAZARR_URL}}/";
              description = "subtitles management";
              widget = {
                type = "bazarr";
                url = "{{HOMEPAGE_VAR_BAZARR_URL}}";
                key = "{{HOMEPAGE_VAR_BAZARR_API_KEY}}";
              };
            };
          }
          {
            Prowlarr = {
              icon = "prowlarr.png";
              href = "{{HOMEPAGE_VAR_PROWLARR_URL}}";
              description = "index management";
              widget = {
                type = "prowlarr";
                url = "{{HOMEPAGE_VAR_PROWLARR_URL}}";
                key = "{{HOMEPAGE_VAR_PROWLARR_API_KEY}}";
              };
            };
          }
          {
            Sabnzbd = {
              icon = "sabnzbd.png";
              href = "{{HOMEPAGE_VAR_SABNZBD_URL}}/";
              description = "download client";
              widget = {
                type = "sabnzbd";
                url = "{{HOMEPAGE_VAR_SABNZBD_URL}}";
                key = "{{HOMEPAGE_VAR_SABNZBD_API_KEY}}";
              };
            };
          }
        ];
      }
    ];
    settings = {
      title = "joip homepage";
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
          latitude = "{{HOMEPAGE_VAR_LATITUDE}}";
          longitude = "{{HOMEPAGE_VAR_LONGITUDE}}";
          units = "metric";
        };
      }
    ];
  };
}
