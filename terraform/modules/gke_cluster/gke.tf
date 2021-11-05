/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

module "gke" {
  source             = "terraform-google-modules/kubernetes-engine/google//modules/beta-public-cluster"
  version            = "~> 16.0"
  project_id         = var.project
  name               = var.gke_name
  region             = var.region
  zones              = [var.zone]
  network            = "gke-vpc"
  subnetwork         = "gke-vpc"
  ip_range_pods      = ""
  ip_range_services  = ""
  config_connector   = true
  remove_default_node_pool = true

  node_pools = [
    {
      name            = "default-node-pool"
      machine_type    = "e2-standard-4"
      node_locations  = var.zone
      min_count       = 1
      max_count       = 2
    }
  ]
}

module "wi" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  version             = "~> 16.0.1"
  gcp_sa_name         = "cnrmsa-${module.gke.name}"
  cluster_name        = module.gke.name
  name                = "cnrm-controller-manager"
  location            = var.zone
  use_existing_k8s_sa = true
  annotate_k8s_sa     = false
  namespace           = "cnrm-system"
  project_id          = var.project
  roles               = ["roles/cloudsql.admin", "roles/pubsub.admin"]
}