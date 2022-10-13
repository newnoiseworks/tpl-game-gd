# The Promised Land
### An open-source multiplayer farming game

This project uses [omgd](https://github.com/newnoiseworks/omgd), [Godot](https://godotengine.org), [Heroic Labs' Nakama](https://heroiclabs.com/nakama-opensource). We'll try and keep them all at the latest versions.

### Full Pre-requisite list of tools:

1. Git
1. Godot 3.3.2
1. Docker w/ `docker-compose` (Docker for desktop is fine)
1. [omgd](https://github.com/newnoiseworks/omgd)
  1.1. [gg](https://github.com/newnoiseworks/gg)


#### Deployment requirements:

1. GCP account w/ billing enabled && GCP compute engine API enabled
  1.1. [GCloud SDK](https://cloud.google.com/sdk/docs/install) installed and signed in w/ `gcloud` cli tool
1. [Terraform](https://www.terraform.io/)
1. [Itch.io's Butler](https://itch.io/docs/butler)

## Local Setup

Clone this repo, ensure docker is running, then use the basic `omgd` commands to build the profiles, then the templates, and manage the local server

1. `$ omgd build-profiles`
1. `$ omgd build-templates`
1. `$ omgd server-start --tail` 
1. Open the `game` folder in Godot
1. Click play, the project should show a login screen, sign in and you should see the server you started in the above step(s) react to it in the console output
