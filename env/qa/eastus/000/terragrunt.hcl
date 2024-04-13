
# This file has been generated using the launch-cli
include "root" {
  path = find_in_parent_folders()
}

include "common" {
  path = "${get_repo_root()}/service.hcl"
}